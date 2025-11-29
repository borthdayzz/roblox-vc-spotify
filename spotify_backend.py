import os
import json
import subprocess
import sys
from pathlib import Path
import requests
from urllib.parse import urlparse, parse_qs

try:
	import spotipy
	from spotipy.oauth2 import SpotifyClientCredentials
	import yt_dlp
except ImportError:
	print("Install required packages: pip install spotipy requests yt-dlp")
	sys.exit(1)

WORKSPACE_FOLDER = Path(__file__).parent / "workspace"


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
		
		ydl_opts = {
			"format": "bestaudio/best",
			"postprocessors": [{
				"key": "FFmpegExtractAudio",
				"preferredcodec": "mp3",
				"preferredquality": "192",
			}],
			"outtmpl": str(WORKSPACE_FOLDER / f"{track_id}"),
			"quiet": False,
			"no_warnings": False,
		}
		
		with yt_dlp.YoutubeDL(ydl_opts) as ydl:
			print(f"Downloading: {search_query}")
			ydl.extract_info(f"ytsearch:{search_query}", download=True)
		
		return str(output_path)
	except Exception as e:
		print(f"Download error: {e}")
		return None

def play_through_microphone(audio_path):
	"""Play audio through microphone using VB-Audio or similar"""
	try:
		# For Windows: use VB-Audio Virtual Cable
		# Install: https://vb-audio.com/Cable/
		
		subprocess.Popen([
			"ffplay",
			"-nodisp",
			"-autoexit",
			audio_path
		])
		
		return True
	except Exception as e:
		print(f"Playback error: {e}")
		return False

def main():
	"""Main function"""
	if len(sys.argv) < 2:
		print("Usage: python spotify_backend.py <spotify_link>")
		return
	
	spotify_link = sys.argv[1]
	
	song_data = fetch_song_data(spotify_link)
	if "error" in song_data:
		print(json.dumps({"error": song_data["error"]}))
		return
	
	audio_path = download_song(song_data)
	song_data["path"] = audio_path
	
	print(json.dumps(song_data))

if __name__ == "__main__":
	main()
