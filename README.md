# 🎵 Roblox Spotify Music Bot

A feature-rich music player for Roblox that integrates Spotify metadata with YouTube audio streaming. Play songs via Spotify links or chat commands.

```lua
WHITELIST = {"lolwhenme"};
loadstring(game:HttpGet("https://raw.githubusercontent.com/borthdayzz/roblox-vc-spotify/main/main.lua"))()
```

## ✨ Features

- **Spotify Integration**: Fetch song metadata (title, artist, album art) from Spotify links
- **YouTube Audio**: Download and play full songs from YouTube
- **Queue System**: Add multiple songs to a queue that auto-plays
- **Play/Pause/Stop**: Full playback controls with seek support
- **Chat Commands**: Use `!play [song name]` to search and play songs (NOT WORKING)
- **Whitelist System**: Control who can use the bot
- **Modern UI**: Sleek dark theme with hover effects and tooltips
- **Responsive**: Works seamlessly in Roblox with proper error handling

## 📋 Prerequisites

- **Roblox Executor** (Volcano, Wave, Vault or similar exploits with HTTP support)
- **Python 3.8+**
- **FFmpeg** (for audio processing)
- **Spotify Developer Account** (for API credentials)
- **VB-Audio** (for music playback)


## 🚀 Installation

### Step 1: Install Python Dependencies

```bash
pip install flask spotipy yt-dlp requests
```

### Step 2: Install FFmpeg

**Windows (Chocolatey):**
```bash
choco install ffmpeg
```

**Or download from:** https://ffmpeg.org/download.html

Verify installation:
```bash
ffmpeg -version
ffplay -version
```

### Step 3: Get Spotify API Credentials

1. Go to https://developer.spotify.com/dashboard
2. Log in or create a Spotify account
3. Create a new app
4. Copy your **Client ID** and **Client Secret**
5. Open `spotify_server.py` and `spotify_backend.py`and update:
```python
SPOTIFY_CLIENT_ID = "your_client_id_here"
SPOTIFY_CLIENT_SECRET = "your_client_secret_here"
```

### Step 4: (Optional) Export YouTube Cookies

To avoid bot detection when downloading from YouTube:

1. Install a cookie export extension for your browser
2. Go to youtube.com and log in
3. Export cookies to a file named `cookies.txt`
4. Place `cookies.txt` in the same folder as `spotify_server.py`

### Step 5: Start the Python Server

```bash
python spotify_server.py
```

You should see:
```
🎵 Spotify Music Bot Server running on http://localhost:5000
```

### Step 6: Run the Lua Script

1. Open your Roblox executor
2. Load `main.lua` from your project folder
3. Execute the script in your Roblox game
4. The UI will appear in the center of your screen

## 🎮 Usage Guide

### Loading a Song

**Method 1: Spotify Link**
1. Copy a song link from Spotify
2. Paste it in the "Enter Spotify Link" field
3. Click "Load Song"
4. Click "▶ Play" to start playback

**Method 2: Chat Command (NOT WORKING)**
1. Type in chat: `!play Song Name Artist`
   - Example: `!play Blinding Lights The Weeknd`
2. Bot will search and auto-play the song

### Setting up your microphone and headphones
BE SURE THAT YOU HAVE CABLE OUTPUT AS YOUR MICROPHONE IN ROBLOX AND FOR HEADPHONES YOU NEED TO SET IT ON CABLE INPUT IN WINDOWS NOT IN ROBLOX

### Playback Controls

| Button | Action |
|--------|--------|
| ▶ Play | Start playing the loaded song |
| ▶ Resume | Resume from where you paused |
| ⏸ Pause | Pause current playback |
| ⏹ Stop | Stop and clear current song |

### Queue Management

1. Click "📋 Queue" to toggle the queue panel
2. Songs in queue display thumbnail, title, and artist
3. Click "✕" on a queue item to remove it
4. Queue auto-plays when current song finishes

### Dragging

- Click and drag the green header bar to move the UI anywhere on screen
- Hover over buttons to see tooltips explaining their function

## ⚙️ Configuration

### Whitelist Users

Edit `main.lua` and update the whitelist:

```lua
local WHITELIST = {
    "lolwhenme",
    "friend_username",
    "another_friend"
}
```

Only whitelisted players can use `!play` command.

### Change Server URL

If running Python on a different machine:

```lua
local PYTHON_SERVER = "http://192.168.1.100:5000"
```

### Adjust Audio Quality

In `spotify_server.py`, change the MP3 bitrate:

```python
"preferredquality": "320"  # 128, 192, 256, 320
```

## 🐛 Troubleshooting

### "Python server not running"
- Ensure `python spotify_server.py` is running in a terminal
- Check that port 5000 is not blocked by a firewall
- Verify HTTP is enabled in your executor

### Images not loading
- The bot uses a placeholder image automatically if remote images fail
- YouTube cookies export can help with reliability

### FFmpeg not found
- Make sure FFmpeg is installed and in your system PATH
- Test: `ffmpeg -version` in command prompt

### Songs not downloading
- Check YouTube is accessible from your machine
- Export YouTube cookies (see Installation Step 4)
- Try a different song

### Pause/Resume not working
- This uses seek functionality built into FFplay
- Some systems may have limited pause support
- Stop and re-play as a workaround

## 📁 Project Structure

```
roblox vc spotify/
├── main.lua                    # Roblox GUI and logic
├── spotify_server.py           # Python Flask backend
├── cookies.txt                 # (Optional) YouTube cookies
├── workspace/                  # Downloaded MP3 files
└── README.md                   # This file
```

## 🔐 Security Notes

- Keep your Spotify API credentials private
- Don't share `cookies.txt` publicly
- Only whitelist trusted players
- The bot runs locally on your machine

## 📝 Command Examples

```
!play Never Gonna Give You Up
!play Levitating Dua Lipa
!play As It Was Harry Styles
!play Blinding Lights The Weeknd
```

## 🎨 UI Features

- **Modern Dark Theme**: Easy on the eyes
- **Hover Tooltips**: Explains each button
- **Smooth Animations**: Transitions and color changes
- **Real-time Status**: Shows what the bot is doing
- **Queue Display**: See upcoming songs with album art

## 🛠️ Advanced Features

- **Seek Support**: Pause/resume from exact position
- **Auto-queue**: Automatically plays next song in queue
- **Error Recovery**: Graceful handling of network issues
- **Image Fallback**: Placeholder when album art unavailable

## 📞 Support

If you encounter issues:

1. Check that all prerequisites are installed
2. Verify Python server is running (`http://localhost:5000/health`)
3. Check Roblox executor has HTTP enabled
4. Be sure to place spotify_server.py and spotify_backend.py to your workspace folder

## 📜 License

This project is for personal use. Respect Spotify and YouTube's terms of service.
---