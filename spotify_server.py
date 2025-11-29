from flask import Flask, request, jsonify
from pathlib import Path
import json
import subprocess
import threading
import time
import os
from urllib.parse import urlparse, parse_qs

try:
	import spotipy
	from spotipy.oauth2 import SpotifyClientCredentials
	import yt_dlp
except ImportError:
	print("Install: pip install flask spotipy yt-dlp")
	exit(1)

current_process = None
is_paused = False
playback_lock = threading.Lock()
playback_start_time = None   # timestamp when playback started (adjusted for seeks)
paused_offset = 0.0          # seconds into track where we paused
current_path = None          # currently playing file path

app = Flask(__name__)

WORKSPACE_FOLDER = Path(__file__).parent / "roblox spotify"
WORKSPACE_FOLDER.mkdir(exist_ok=True)

SPOTIFY_CLIENT_ID = "PLACE_CLIENT_ID_HERE"
SPOTIFY_CLIENT_SECRET = "PLACE_CLIENT_SECRET_HERE"

def get_spotify_client():
	"""Initialize Spotify client"""
	auth_manager = SpotifyClientCredentials(
		client_id=SPOTIFY_CLIENT_ID,
		client_secret=SPOTIFY_CLIENT_SECRET
	)
	return spotipy.Spotify(auth_manager=auth_manager)

def extract_track_id(spotify_link):
	"""Extract track ID from Spotify link"""
	parsed_url = urlparse(spotify_link)
	if "spotify.com" in parsed_url.netloc:
		if "track" in parsed_url.path:
			return parsed_url.path.split("/")[-1].split("?")[0]
	return None

def fetch_song_data(spotify_link):
	"""Fetch song metadata from Spotify"""
	try:
		sp = get_spotify_client()
		track_id = extract_track_id(spotify_link)
		
		if not track_id:
			return {"error": "Invalid Spotify link"}
		
		track = sp.track(track_id)
		
		song_data = {
			"title": track["name"],
			"artist": ", ".join([artist["name"] for artist in track["artists"]]),
			"image": track["album"]["images"][0]["url"] if track["album"]["images"] else "",
			"preview_url": track["preview_url"],
			"track_id": track_id
		}
		
		return song_data
	except Exception as e:
		return {"error": str(e)}

def download_song(track_info):
	"""Download full song from YouTube using yt-dlp"""
	try:
		track_id = track_info["track_id"]
		title = track_info["title"]
		artist = track_info["artist"]
		output_path = WORKSPACE_FOLDER / f"{track_id}.mp3"
		
		if output_path.exists():
			return str(output_path)
		
		search_query = f"{artist} - {title}"
		cookie_file = Path(__file__).parent / "cookies.txt"
		
		ydl_opts = {
			"format": "bestaudio[ext=m4a]/bestaudio/best",
			"postprocessors": [{
				"key": "FFmpegExtractAudio",
				"preferredcodec": "mp3",
				"preferredquality": "192",
			}],
			"outtmpl": str(WORKSPACE_FOLDER / f"{track_id}"),
			"quiet": False,
			"no_warnings": False,
			"socket_timeout": 30,
			"http_headers": {
				"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
			},
			"cookiefile": str(cookie_file) if cookie_file.exists() else None,
		}
		
		with yt_dlp.YoutubeDL(ydl_opts) as ydl:
			print(f"Downloading: {search_query}")
			ydl.extract_info(f"ytsearch:{search_query}", download=True)
		
		return str(output_path)
	except Exception as e:
		print(f"Download error: {e}")
		return None

@app.route("/health", methods=["GET"])
def health():
	"""Check if server is running"""
	return jsonify({"status": "ok"}), 200

@app.route("/fetch", methods=["GET"])
def fetch():
	"""Fetch song data and download from YouTube"""
	link = request.args.get("link")
	
	if not link:
		return jsonify({"error": "No link provided"}), 400
	
	song_data = fetch_song_data(link)
	if "error" in song_data:
		return jsonify(song_data), 400
	
	audio_path = download_song(song_data)
	song_data["path"] = audio_path
	
	return jsonify(song_data), 200

@app.route("/play", methods=["GET"])
def play():
	"""Play song through microphone (supports starting from paused offset)"""
	global current_process, is_paused, playback_start_time, paused_offset, current_path
	
	path = request.args.get("path")
	
	if not path or not os.path.exists(path):
		return jsonify({"error": "File not found"}), 400
	
	try:
		with playback_lock:
			if current_path != path:
				paused_offset = 0.0
				current_path = path
			
			if current_process:
				try:
					current_process.terminate()
					current_process.wait(timeout=1)
				except:
					try:
						current_process.kill()
					except:
						pass
				current_process = None
			

			cmd = ["ffplay", "-nodisp", "-autoexit"]
			if paused_offset and paused_offset > 0:
				cmd += ["-ss", str(paused_offset)]
			cmd += [path]
			
			current_process = subprocess.Popen(
				cmd,
				stdin=subprocess.PIPE,
				stdout=subprocess.DEVNULL,
				stderr=subprocess.DEVNULL
			)
			
			playback_start_time = time.time() - paused_offset
			is_paused = False
		
		print(f"Playing: {path} at {paused_offset:.2f}s")
		return jsonify({"status": "playing", "path": path, "offset": paused_offset}), 200
	except Exception as e:
		return jsonify({"error": str(e)}), 500

@app.route("/pause", methods=["GET"])
def pause():
	"""Pause current song by recording elapsed time and stopping playback"""
	global current_process, is_paused, playback_start_time, paused_offset, current_path
	
	if not current_process or current_process.poll() is not None:
		return jsonify({"error": "No song playing"}), 400
	
	try:
		with playback_lock:
			if playback_start_time:
				paused_offset = time.time() - playback_start_time
			else:
				paused_offset = 0.0
			
			try:
				current_process.terminate()
				current_process.wait(timeout=1)
			except:
				try:
					current_process.kill()
				except:
					pass
			current_process = None
			is_paused = True
		
		print(f"Paused at {paused_offset:.2f}s")
		return jsonify({"status": "paused", "offset": paused_offset}), 200
	except Exception as e:
		print(f"Pause error: {e}")
		return jsonify({"error": str(e)}), 500

@app.route("/resume", methods=["GET"])
def resume():
	"""Resume paused song by restarting ffplay at paused_offset"""
	global current_process, is_paused, playback_start_time, paused_offset, current_path
	
	if not current_path:
		return jsonify({"error": "No song to resume"}), 400
	
	if not os.path.exists(current_path):
		return jsonify({"error": "File not found"}), 400
	
	try:
		with playback_lock:
			if current_process and current_process.poll() is None:
				return jsonify({"status": "already_playing"}), 200
			
			cmd = ["ffplay", "-nodisp", "-autoexit"]
			if paused_offset and paused_offset > 0:
				cmd += ["-ss", str(paused_offset)]
			cmd += [current_path]
			
			current_process = subprocess.Popen(
				cmd,
				stdin=subprocess.PIPE,
				stdout=subprocess.DEVNULL,
				stderr=subprocess.DEVNULL
			)
			
			playback_start_time = time.time() - paused_offset
			is_paused = False
		
		print(f"Resumed: {current_path} at {paused_offset:.2f}s")
		return jsonify({"status": "resumed", "path": current_path, "offset": paused_offset}), 200
	except Exception as e:
		print(f"Resume error: {e}")
		return jsonify({"error": str(e)}), 500

@app.route("/stop", methods=["GET"])
def stop():
	"""Stop current song"""
	global current_process, is_paused
	
	with playback_lock:
		if current_process:
			try:
				current_process.terminate()
				current_process.wait(timeout=1)
			except:
				try:
					current_process.kill()
				except:
					pass
		
		current_process = None
		is_paused = False
	
	print("Song stopped")
	return jsonify({"status": "stopped"}), 200

@app.route("/status", methods=["GET"])
def status():
	"""Check if song is still playing"""
	global current_process
	
	if not current_process:
		return jsonify({"status": "stopped"}), 200
	
	if current_process.poll() is None:
		return jsonify({"status": "playing"}), 200
	else:
		return jsonify({"status": "finished"}), 200

@app.route("/search", methods=["GET"])
def search():
	"""Search for a song by name and download from YouTube"""
	query = request.args.get("query")
	
	if not query or query.strip() == "":
		return jsonify({"error": "No search query provided"}), 400
	
	try:
		print(f"Searching for: {query}")
		cookie_file = Path(__file__).parent / "cookies.txt"
		
		ydl_opts = {
			"format": "bestaudio[ext=m4a]/bestaudio/best",
			"quiet": True,
			"no_warnings": True,
			"socket_timeout": 30,
			"http_headers": {
				"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
			},
			"cookiefile": str(cookie_file) if cookie_file.exists() else None,
		}
		
		with yt_dlp.YoutubeDL(ydl_opts) as ydl:
			info = ydl.extract_info(f"ytsearch1:{query}", download=False)
			
			if not info or "entries" not in info or len(info["entries"]) == 0:
				return jsonify({"error": "No results found"}), 404
			
			video = info["entries"][0]
			title = video.get("title", "Unknown")
			track_id = video.get("id", "unknown")
			thumbnail = video.get("thumbnail", "")
			
			output_path = WORKSPACE_FOLDER / f"{track_id}.mp3"
			
			if not output_path.exists():
				download_opts = {
					"format": "bestaudio[ext=m4a]/bestaudio/best",
					"postprocessors": [{
						"key": "FFmpegExtractAudio",
						"preferredcodec": "mp3",
						"preferredquality": "192",
					}],
					"outtmpl": str(WORKSPACE_FOLDER / f"{track_id}"),
					"quiet": False,
					"no_warnings": False,
					"socket_timeout": 30,
					"http_headers": {
						"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
					},
					"cookiefile": str(cookie_file) if cookie_file.exists() else None,
				}
				
				with yt_dlp.YoutubeDL(download_opts) as ydl:
					ydl.extract_info(f"https://www.youtube.com/watch?v={track_id}", download=True)
			
			song_data = {
				"title": title,
				"artist": "YouTube",
				"image": thumbnail,
				"track_id": track_id,
				"path": str(output_path)
			}
			
			print(f"Found and downloaded: {title}")
			return jsonify(song_data), 200
	
	except Exception as e:
		print(f"Search error: {e}")
		return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
	print("🎵 Spotify Music Bot Server running on http://localhost:5000")
	print("Install Python backend: pip install flask spotipy yt-dlp")
	app.run(host="localhost", port=5000, debug=False)