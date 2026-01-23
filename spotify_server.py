from flask import Flask, request, jsonify, send_file
from pathlib import Path
import json
import subprocess
import threading
import time
import os
from urllib.parse import urlparse, parse_qs
import shutil
import logging
from pathlib import Path
try:
	from dotenv import load_dotenv
	load_dotenv()
except Exception:
	env_path = Path(__file__).parent / ".env"
	if env_path.exists():
		with open(env_path, "r", encoding="utf-8") as f:
			for line in f:
				line = line.strip()
				if not line or line.startswith("#"):
					continue
				if "=" in line:
					k, v = line.split("=", 1)
					os.environ.setdefault(k.strip(), v.strip().strip('"').strip("'"))
		print("Loaded .env from project directory")

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

# WORKSPACE_FOLDER = Path(__file__).parent / "roblox spotify"
WORKSPACE_FOLDER = Path(__file__).parent / "fart"
WORKSPACE_FOLDER.mkdir(parents=True, exist_ok=True)

IMAGES_FOLDER = WORKSPACE_FOLDER / "images"
IMAGES_FOLDER.mkdir(parents=True, exist_ok=True)

SPOTIFY_CLIENT_ID = os.getenv("SPOTIPY_CLIENT_ID") or os.getenv("SPOTIFY_CLIENT_ID")
SPOTIFY_CLIENT_SECRET = os.getenv("SPOTIPY_CLIENT_SECRET") or os.getenv("SPOTIFY_CLIENT_SECRET")

HOST = os.getenv("HOST", "localhost")
PORT = int(os.getenv("PORT", "5000"))

def check_dependencies():
	"""Ensure required external executables are available."""
	missing = []
	if shutil.which("ffplay") is None and shutil.which("ffmpeg") is None:
		missing.append("ffplay/ffmpeg")
	if missing:
		logging.error("Missing dependencies: %s. Install ffmpeg/ffplay and ensure they're in PATH.", ", ".join(missing))
		print(f"Error: Missing dependencies: {', '.join(missing)}. Install ffmpeg/ffplay and ensure they're in PATH.")
		exit(1)

check_dependencies()

def download_image(image_url):
	"""Download image from URL and save to workspace. Returns filename or None"""
	if not image_url:
		return None
	
	try:
		import hashlib
		url_hash = hashlib.md5(image_url.encode()).hexdigest()
		image_filename = f"{url_hash}.jpg"
		image_path = IMAGES_FOLDER / image_filename
		
		if image_path.exists():
			return image_filename
		
		response = requests.get(image_url, timeout=10)
		if response.status_code == 200:
			with open(image_path, 'wb') as f:
				f.write(response.content)
			return image_filename
	except Exception as e:
		print(f"Image download error: {e}")
	
	return None

def get_spotify_client():
	"""Initialize Spotify client"""
	auth_manager = SpotifyClientCredentials(
		client_id=SPOTIFY_CLIENT_ID,
		client_secret=SPOTIFY_CLIENT_SECRET
	)
	return spotipy.Spotify(auth_manager=auth_manager)

def get_spotify_client_with_creds(client_id, client_secret):
	"""Return a Spotify client initialized with provided credentials."""
	if not client_id or not client_secret:
		raise ValueError("Missing Spotify credentials")
	auth_manager = SpotifyClientCredentials(client_id=client_id, client_secret=client_secret)
	return spotipy.Spotify(auth_manager=auth_manager)

def extract_track_id(spotify_link):
	"""Extract track ID from Spotify link"""
	parsed_url = urlparse(spotify_link)
	if "spotify.com" in parsed_url.netloc:
		if "track" in parsed_url.path:
			return parsed_url.path.split("/")[-1].split("?")[0]
	return None

def fetch_song_data(spotify_link, client_id=None, client_secret=None):
	"""Fetch song metadata from Spotify"""
	try:
		sp = get_spotify_client_with_creds(client_id or SPOTIFY_CLIENT_ID, client_secret or SPOTIFY_CLIENT_SECRET)
		track_id = extract_track_id(spotify_link)
		
		if not track_id:
			return {"error": "Invalid Spotify link"}
		
		track = sp.track(track_id)
		
		image_url = track["album"]["images"][0]["url"] if track["album"]["images"] else ""
		image_filename = download_image(image_url) if image_url else None
		
		song_data = {
			"title": track["name"],
			"artist": ", ".join([artist["name"] for artist in track["artists"]]),
			"image": image_filename,
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

@app.route("/image/<filename>", methods=["GET"])
def serve_image(filename):
	"""Serve downloaded images from workspace"""
	image_path = IMAGES_FOLDER / filename
	if image_path.exists():
		return send_file(str(image_path), mimetype='image/jpeg')
	return jsonify({"error": "Image not found"}), 404

@app.route("/fetch", methods=["GET"])
def fetch():
	"""Fetch song data and download from YouTube (legacy endpoint)"""
	link = request.args.get("link")
	client_id = request.args.get("client_id") or SPOTIFY_CLIENT_ID
	client_secret = request.args.get("client_secret") or SPOTIFY_CLIENT_SECRET
	if not client_id or not client_secret:
		return jsonify({"error": "No client_id. Pass client_id & client_secret query params or set SPOTIPY_CLIENT_ID/SPOTIPY_CLIENT_SECRET environment variables."}), 400
	
	if not link:
		return jsonify({"error": "No link provided"}), 400
	
	song_data = fetch_song_data(link, client_id=client_id, client_secret=client_secret)
	if "error" in song_data:
		return jsonify(song_data), 400
	
	audio_path = download_song(song_data)
	song_data["path"] = audio_path
	
	return jsonify(song_data), 200

@app.route("/spotify/fetch", methods=["GET"])
def spotify_fetch():
	"""Fetch song data from Spotify link and download from YouTube"""
	link = request.args.get("link")
	client_id = request.args.get("client_id") or SPOTIFY_CLIENT_ID
	client_secret = request.args.get("client_secret") or SPOTIFY_CLIENT_SECRET
	if not client_id or not client_secret:
		return jsonify({"error": "No client_id. Pass client_id & client_secret query params or set SPOTIPY_CLIENT_ID/SPOTIPY_CLIENT_SECRET environment variables."}), 400
	
	if not link:
		return jsonify({"error": "No link provided"}), 400
	
	song_data = fetch_song_data(link, client_id=client_id, client_secret=client_secret)
	if "error" in song_data:
		return jsonify(song_data), 400
	
	audio_path = download_song(song_data)
	song_data["path"] = audio_path
	
	return jsonify(song_data), 200

@app.route("/youtube/fetch", methods=["GET"])
def youtube_fetch():
	"""Fetch song data from YouTube link"""
	link = request.args.get("link")
	
	if not link:
		return jsonify({"error": "No link provided"}), 400
	
	try:
		print(f"Fetching YouTube video: {link}")
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
			info = ydl.extract_info(link, download=False)
			
			if not info:
				return jsonify({"error": "Could not fetch video information"}), 404
			
			video_id = info.get("id", "unknown")
			title = info.get("title", "Unknown")
			thumbnail_url = info.get("thumbnail", "")
			
			output_path = WORKSPACE_FOLDER / f"{video_id}.mp3"
			
			image_filename = download_image(thumbnail_url) if thumbnail_url else None
			
			if not output_path.exists():
				download_opts = {
					"format": "bestaudio[ext=m4a]/bestaudio/best",
					"postprocessors": [{
						"key": "FFmpegExtractAudio",
						"preferredcodec": "mp3",
						"preferredquality": "192",
					}],
					"outtmpl": str(WORKSPACE_FOLDER / f"{video_id}"),
					"quiet": False,
					"no_warnings": False,
					"socket_timeout": 30,
					"http_headers": {
						"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
					},
					"cookiefile": str(cookie_file) if cookie_file.exists() else None,
				}
				
				with yt_dlp.YoutubeDL(download_opts) as ydl:
					ydl.extract_info(link, download=True)
			
			song_data = {
				"title": title,
				"artist": "YouTube",
				"image": image_filename,
				"track_id": video_id,
				"path": str(output_path)
			}
			
			print(f"Downloaded: {title}")
			return jsonify(song_data), 200
	
	except Exception as e:
		print(f"YouTube fetch error: {e}")
		return jsonify({"error": str(e)}), 500

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
				stdout=subprocess.PIPE,
				stderr=subprocess.PIPE
			)
			
			time.sleep(0.2)
			if current_process.poll() is not None:
				err = current_process.stderr.read().decode("utf-8", errors="ignore") if current_process.stderr else ""
				current_process = None
				return jsonify({"error": "ffplay failed to start", "stderr": err}), 500
			
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
				stdout=subprocess.PIPE,
				stderr=subprocess.PIPE
			)
			
			time.sleep(0.2)
			if current_process.poll() is not None:
				err = current_process.stderr.read().decode("utf-8", errors="ignore") if current_process.stderr else ""
				current_process = None
				return jsonify({"error": "ffplay failed to start", "stderr": err}), 500
			
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
			thumbnail_url = video.get("thumbnail", "")
			
			output_path = WORKSPACE_FOLDER / f"{track_id}.mp3"
			
			image_filename = download_image(thumbnail_url) if thumbnail_url else None
			
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
				"image": image_filename,
				"track_id": track_id,
				"path": str(output_path)
			}
			
			print(f"Found and downloaded: {title}")
			return jsonify(song_data), 200
	
	except Exception as e:
		print(f"Search error: {e}")
		return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
	print(f"🎵 Spotify Music Bot Server running on http://{HOST}:{PORT}")
	print("Tip: To route output into Roblox Voice Chat, install a virtual audio cable (e.g., VB-Audio Cable), set the virtual cable as the system default playback device, then select the cable as the microphone/input in Roblox settings.")
	print("Ensure SPOTIPY_CLIENT_ID and SPOTIPY_CLIENT_SECRET are set in the environment, or pass client_id & client_secret with /fetch.")
	app.run(host=HOST, port=PORT, debug=False)