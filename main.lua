if not game:GetService("GuiService") then
	print("Error: Not running in Roblox environment")
	return
end

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local TextChatService = game:GetService("TextChatService")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SpotifyMusicBot"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 500, 0, 350)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

mainFrame.Size = UDim2.new(0, 500, 0, 350)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
mainFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
mainFrame.BorderSizePixel = 0
local mainCorner = Instance.new("UICorner", mainFrame)
mainCorner.CornerRadius = UDim.new(0, 12)
local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Color = Color3.fromRGB(45, 45, 45)
mainStroke.Transparency = 0.7
mainStroke.Thickness = 1

local mainGrad = Instance.new("UIGradient", mainFrame)
mainGrad.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(28,28,28)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(22,22,22))
}
mainGrad.Rotation = 90

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 42)
header.Position = UDim2.new(0, 0, 0, 0)
header.BackgroundTransparency = 0
header.BackgroundColor3 = Color3.fromRGB(36, 143, 86)
header.BorderSizePixel = 0
header.Parent = mainFrame
local headerCorner = Instance.new("UICorner", header)
headerCorner.CornerRadius = UDim.new(0, 12)
local headerLabel = Instance.new("TextLabel", header)
headerLabel.Size = UDim2.new(1, 0, 1, 0)
headerLabel.BackgroundTransparency = 1
headerLabel.Text = "🎵 Spotify Music Bot"
headerLabel.TextColor3 = Color3.fromRGB(245,245,245)
headerLabel.Font = Enum.Font.GothamBold
headerLabel.TextSize = 18
headerLabel.TextXAlignment = Enum.TextXAlignment.Center
headerLabel.TextYAlignment = Enum.TextYAlignment.Center

local inputLabel = Instance.new("TextLabel")
inputLabel.Name = "InputLabel"
inputLabel.Size = UDim2.new(0.65, -10, 0, 20)
inputLabel.Position = UDim2.new(0, 10, 0, 62)
inputLabel.BackgroundTransparency = 1
inputLabel.Text = "Enter Spotify Link:"
inputLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
inputLabel.TextSize = 14
inputLabel.TextXAlignment = Enum.TextXAlignment.Left
inputLabel.Font = Enum.Font.Gotham
inputLabel.Parent = mainFrame

local modeButton = Instance.new("TextButton")
modeButton.Name = "ModeButton"
modeButton.Size = UDim2.new(0.35, -5, 0, 20)
modeButton.Position = UDim2.new(0.65, 0, 0, 62)
modeButton.BackgroundColor3 = Color3.fromRGB(36, 143, 86)
modeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
modeButton.Text = "Spotify"
modeButton.TextSize = 12
modeButton.Font = Enum.Font.GothamBold
modeButton.BorderSizePixel = 0
modeButton.Parent = mainFrame
local modeCorner = Instance.new("UICorner", modeButton)
modeCorner.CornerRadius = UDim.new(0, 4)

local inputBox = Instance.new("TextBox")
inputBox.Name = "InputBox"
inputBox.Size = UDim2.new(1, -20, 0, 30)
inputBox.Position = UDim2.new(0, 10, 0, 87)
inputBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
inputBox.Text = ""
inputBox.PlaceholderText = "https://open.spotify.com/track/..."
inputBox.TextSize = 12
inputBox.Font = Enum.Font.Gotham
inputBox.BorderSizePixel = 1
inputBox.BorderColor3 = Color3.fromRGB(100, 100, 100)
inputBox.Parent = mainFrame

local loadButton = Instance.new("TextButton")
loadButton.Name = "LoadButton"
loadButton.Size = UDim2.new(1, -20, 0, 35)
loadButton.Position = UDim2.new(0, 10, 0, 127)
loadButton.BackgroundColor3 = Color3.fromRGB(29, 185, 84)
loadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
loadButton.Text = "Load Song"
loadButton.TextSize = 14
loadButton.Font = Enum.Font.GothamBold
loadButton.BorderSizePixel = 0
loadButton.Parent = mainFrame

local infoFrame = Instance.new("Frame")
infoFrame.Name = "InfoFrame"
infoFrame.Size = UDim2.new(1, -20, 0, 120)
infoFrame.Position = UDim2.new(0, 10, 0, 177)
infoFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
infoFrame.BorderSizePixel = 1
infoFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
infoFrame.Parent = mainFrame

local songImage = Instance.new("ImageLabel")
songImage.Name = "SongImage"
songImage.Size = UDim2.new(0, 84, 0, 84)
songImage.Position = UDim2.new(0, 8, 0, 8)
songImage.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
songImage.BorderSizePixel = 0
local imageCorner = Instance.new("UICorner", songImage)
imageCorner.CornerRadius = UDim.new(0, 8)
local imageStroke = Instance.new("UIStroke", songImage)
imageStroke.Color = Color3.fromRGB(60,60,60)
imageStroke.Transparency = 0.6

songImage.Parent = infoFrame

local songTitle = Instance.new("TextLabel")
songTitle.Name = "SongTitle"
songTitle.Size = UDim2.new(1, -110, 0, 40)
songTitle.Position = UDim2.new(0, 100, 0, 10)
songTitle.BackgroundTransparency = 1
songTitle.Text = "No song loaded"
songTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
songTitle.TextSize = 14
songTitle.Font = Enum.Font.GothamSemibold
songTitle.TextXAlignment = Enum.TextXAlignment.Left
songTitle.TextWrapped = true
songTitle.Parent = infoFrame

local songArtist = Instance.new("TextLabel")
songArtist.Name = "SongArtist"
songArtist.Size = UDim2.new(1, -110, 0, 40)
songArtist.Position = UDim2.new(0, 100, 0, 50)
songArtist.BackgroundTransparency = 1
songArtist.Text = "Artist unknown"
songArtist.TextColor3 = Color3.fromRGB(150, 150, 150)
songArtist.TextSize = 12
songArtist.Font = Enum.Font.Gotham
songArtist.TextXAlignment = Enum.TextXAlignment.Left
songArtist.TextWrapped = true
songArtist.Parent = infoFrame

local playButton = Instance.new("TextButton")
playButton.Name = "PlayButton"
playButton.Size = UDim2.new(0.6, -10, 0, 35)
playButton.Position = UDim2.new(0, 10, 0, 310)
playButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
playButton.TextColor3 = Color3.fromRGB(255, 255, 255)
playButton.Text = "▶ Play"
playButton.TextSize = 14
playButton.Font = Enum.Font.GothamBold
playButton.BorderSizePixel = 0
playButton.Parent = mainFrame
playButton.Visible = false

local pauseButton = Instance.new("TextButton")
pauseButton.Name = "PauseButton"
pauseButton.Size = UDim2.new(0.2, -5, 0, 35)
pauseButton.Position = UDim2.new(0.6, 0, 0, 310)
pauseButton.BackgroundColor3 = Color3.fromRGB(180, 180, 60)
pauseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
pauseButton.Text = "⏸ Pause"
pauseButton.TextSize = 14
pauseButton.Font = Enum.Font.GothamBold
pauseButton.BorderSizePixel = 0
pauseButton.Parent = mainFrame
pauseButton.Visible = false

local stopButton = Instance.new("TextButton")
stopButton.Name = "StopButton"
stopButton.Size = UDim2.new(0.2, -5, 0, 35)
stopButton.Position = UDim2.new(0.8, 0, 0, 310)
stopButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
stopButton.Text = "⏹ Stop"
stopButton.TextSize = 14
stopButton.Font = Enum.Font.GothamBold
stopButton.BorderSizePixel = 0
stopButton.Parent = mainFrame
stopButton.Visible = false

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "Status"
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 1, -20)
statusLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
statusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
statusLabel.Text = "Ready"
statusLabel.TextSize = 10
statusLabel.Font = Enum.Font.Gotham
statusLabel.BorderSizePixel = 0
statusLabel.Parent = mainFrame

local currentSongData = nil
local pythonRunning = false
local PYTHON_SERVER = "http://localhost:5000"
local songQueue = {}
local isPlaying = false
local isPaused = false
local playbackThread = nil
local serviceMode = "spotify"  -- "spotify" or "youtube"

local PLACEHOLDER_IMAGE = "rbxassetid://7072716801"

local function setRemoteImage(imgLabel, imageFilename)
	if not imageFilename or imageFilename == "" then
		return
	end

	local ok, res = pcall(function()
		return game:HttpGet(PYTHON_SERVER .. "/image/" .. imageFilename, true)
	end)

	if ok and res and #res > 0 then
		pcall(function() imgLabel.Image = "data:image/jpeg;base64," .. game:GetService("HttpService"):UrlEncode(res) end)
	end
end

local WHITELIST = {
	"lolwhenme"
}

local function isPlayerWhitelisted(playerName)
	for _, whitelistedName in ipairs(WHITELIST) do
		if whitelistedName:lower() == playerName:lower() then
			return true
		end
	end
	return false
end

local function isSpotifyLink(link)
	return link:find("spotify.com") ~= nil and link:find("track") ~= nil
end

local function isYouTubeLink(link)
	return link:find("youtube.com") ~= nil or link:find("youtu.be") ~= nil
end

local function validateLink(link, mode)
	if mode == "spotify" then
		return isSpotifyLink(link)
	elseif mode == "youtube" then
		return isYouTubeLink(link)
	end
	return false
end

local dragging = false
local dragStart = nil
local frameStart = nil

mainFrame.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		frameStart = mainFrame.Position
	end
end)

mainFrame.InputEnded:Connect(function(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input, gameProcessed)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		mainFrame.Position = frameStart + UDim2.new(0, delta.X, 0, delta.Y)
	end
end)

local queueFrame = Instance.new("Frame")
queueFrame.Name = "QueueFrame"
queueFrame.Size = UDim2.new(0, 320, 0, 260)
queueFrame.Position = UDim2.new(0.5, 260, 0.5, -175)
queueFrame.BackgroundColor3 = Color3.fromRGB(28,28,28)
queueFrame.BorderSizePixel = 0
queueFrame.Parent = screenGui
queueFrame.Visible = false

local queueTitle = Instance.new("TextLabel")
queueTitle.Name = "QueueTitle"
queueTitle.Size = UDim2.new(1, 0, 0, 36)
queueTitle.Font = Enum.Font.GothamBold
queueTitle.TextSize = 14
queueTitle.BackgroundColor3 = Color3.fromRGB(40,150,90)
queueTitle.TextColor3 = Color3.fromRGB(255,255,255)
queueTitle.BorderSizePixel = 0
queueTitle.Parent = queueFrame

local queueList = Instance.new("ScrollingFrame")
queueList.Name = "QueueList"
queueList.Size = UDim2.new(1, 0, 1, -30)
queueList.Position = UDim2.new(0, 0, 0, 30)
queueList.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
queueList.BorderSizePixel = 0
queueList.ScrollBarThickness = 5
queueList.CanvasSize = UDim2.new(0, 0, 0, 0)
queueList.Parent = queueFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.Parent = queueList

local queueButton = Instance.new("TextButton")
queueButton.Name = "QueueButton"
queueButton.Size = UDim2.new(0.3, -5, 0, 30)
queueButton.Position = UDim2.new(0.7, 0, 0, 125)
queueButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
queueButton.TextColor3 = Color3.fromRGB(255, 255, 255)
queueButton.Text = "📋 Queue"
queueButton.TextSize = 12
queueButton.Font = Enum.Font.GothamBold
queueButton.BorderSizePixel = 0
queueButton.Parent = mainFrame

local creditsButton = Instance.new("TextButton")
creditsButton.Name = "CreditsButton"
creditsButton.Size = UDim2.new(0, 32, 0, 32)
creditsButton.Position = UDim2.new(1, -42, 0, 5)
creditsButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
creditsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
creditsButton.Text = "ℹ️"
creditsButton.TextSize = 16
creditsButton.Font = Enum.Font.GothamBold
creditsButton.BorderSizePixel = 0
creditsButton.Parent = header
local creditsCorner = Instance.new("UICorner", creditsButton)
creditsCorner.CornerRadius = UDim.new(0, 6)

local creditsModal = Instance.new("Frame")
creditsModal.Name = "CreditsModal"
creditsModal.Size = UDim2.new(0, 320, 0, 220)
creditsModal.Position = UDim2.new(0.5, -160, 0.5, -110)
creditsModal.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
creditsModal.BorderSizePixel = 0
creditsModal.Parent = screenGui
creditsModal.Visible = false
creditsModal.ZIndex = 100

local creditsCornerBg = Instance.new("UICorner", creditsModal)
creditsCornerBg.CornerRadius = UDim.new(0, 12)
local creditsStrokeBg = Instance.new("UIStroke", creditsModal)
creditsStrokeBg.Color = Color3.fromRGB(45, 45, 45)
creditsStrokeBg.Transparency = 0.7
creditsStrokeBg.Thickness = 1

local creditsHeader = Instance.new("Frame", creditsModal)
creditsHeader.Name = "Header"
creditsHeader.Size = UDim2.new(1, 0, 0, 40)
creditsHeader.BackgroundColor3 = Color3.fromRGB(36, 143, 86)
creditsHeader.BorderSizePixel = 0
local creditsHeaderCorner = Instance.new("UICorner", creditsHeader)
creditsHeaderCorner.CornerRadius = UDim.new(0, 12)

local creditsHeaderLabel = Instance.new("TextLabel", creditsHeader)
creditsHeaderLabel.Size = UDim2.new(1, -40, 1, 0)
creditsHeaderLabel.BackgroundTransparency = 1
creditsHeaderLabel.Text = "Credits"
creditsHeaderLabel.TextColor3 = Color3.fromRGB(245, 245, 245)
creditsHeaderLabel.Font = Enum.Font.GothamBold
creditsHeaderLabel.TextSize = 16
creditsHeaderLabel.TextXAlignment = Enum.TextXAlignment.Center
creditsHeaderLabel.TextYAlignment = Enum.TextYAlignment.Center

local closeBtn = Instance.new("TextButton", creditsHeader)
closeBtn.Name = "CloseBtn"
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -36, 0.5, -16)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Text = "✕"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
local closeBtnCorner = Instance.new("UICorner", closeBtn)
closeBtnCorner.CornerRadius = UDim.new(0, 6)

closeBtn.MouseButton1Click:Connect(function()
    creditsModal.Visible = false
end)


local function addToQueue(songData)
	table.insert(songQueue, songData)
	updateQueueUI()
end

local function updateQueueUI()
	for _, child in ipairs(queueList:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	
	for i, song in ipairs(songQueue) do
		local queueItem = Instance.new("Frame")
		queueItem.Size = UDim2.new(1, -16, 0, 56)
		queueItem.Position = UDim2.new(0, 8, 0, (i-1)*61 + 8)
		queueItem.BackgroundColor3 = Color3.fromRGB(34,34,34)
		queueItem.BorderSizePixel = 0
		queueItem.Parent = queueList
		
		local itemCorner = Instance.new("UICorner", queueItem)
		itemCorner.CornerRadius = UDim.new(0, 8)
		local itemStroke = Instance.new("UIStroke", queueItem)
		itemStroke.Color = Color3.fromRGB(50,50,50)
		itemStroke.Transparency = 0.7
		itemStroke.Thickness = 1
		
		local thumb = Instance.new("ImageLabel", queueItem)
		thumb.Size = UDim2.new(0,44,0,44)
		thumb.Position = UDim2.new(0,6,0,6)
		thumb.BackgroundTransparency = 1
		local thumbCorner = Instance.new("UICorner", thumb)
		thumbCorner.CornerRadius = UDim.new(0,6)
		setRemoteImage(thumb, song.image)
		
		local itemTitle = Instance.new("TextLabel", queueItem)
		itemTitle.Size = UDim2.new(1, -64, 0, 26)
		itemTitle.Position = UDim2.new(0, 56, 0, 6)
		itemTitle.BackgroundTransparency = 1
		itemTitle.Text = song.title
		itemTitle.TextColor3 = Color3.fromRGB(240,240,240)
		itemTitle.TextSize = 12
		itemTitle.Font = Enum.Font.GothamSemibold
		itemTitle.TextXAlignment = Enum.TextXAlignment.Left
		itemTitle.TextTruncate = Enum.TextTruncate.AtEnd
		
		local itemArtist = Instance.new("TextLabel", queueItem)
		itemArtist.Size = UDim2.new(1, -64, 0, 18)
		itemArtist.Position = UDim2.new(0, 56, 0, 30)
		itemArtist.BackgroundTransparency = 1
		itemArtist.Text = song.artist
		itemArtist.TextColor3 = Color3.fromRGB(170,170,170)
		itemArtist.TextSize = 10
		itemArtist.Font = Enum.Font.Gotham
		itemArtist.TextXAlignment = Enum.TextXAlignment.Left
		
		local removeBtn = Instance.new("TextButton", queueItem)
		removeBtn.Size = UDim2.new(0, 36, 0, 36)
		removeBtn.Position = UDim2.new(1, -44, 0, 10)
		removeBtn.BackgroundColor3 = Color3.fromRGB(180,80,80)
		removeBtn.TextColor3 = Color3.fromRGB(255,255,255)
		removeBtn.Text = "✕"
		removeBtn.Font = Enum.Font.GothamBold
		removeBtn.TextSize = 14
		local remCorner = Instance.new("UICorner", removeBtn)
		remCorner.CornerRadius = UDim.new(0,6)
		removeBtn.MouseButton1Click:Connect(function()
			table.remove(songQueue, i)
			updateQueueUI()
		end)
	end

	queueList.CanvasSize = UDim2.new(0, 0, 0, #songQueue * 66)
	queueFrame.Visible = #songQueue > 0
end

local playbackMonitor = nil

local function isPythonServerRunning()
	local ok, res = pcall(function()
		return game:HttpGet(PYTHON_SERVER .. "/health")
	end)
	if not ok or not res then
		return false
	end
	local success, data = pcall(function()
		return game:GetService("HttpService"):JSONDecode(res)
	end)
	if success and type(data) == "table" and data.status == "ok" then
		return true
	end
	return false
end

local function startPlaybackMonitor()
	if playbackMonitor then return end
	playbackMonitor = task.spawn(function()
		while true do
			if not isPlaying then
				break
			end

			local ok, res = pcall(function()
				return game:HttpGet(PYTHON_SERVER .. "/status")
			end)

			if not ok or not res then
				break
			end

			local statusData
			local decodeOk = pcall(function()
				statusData = game:GetService("HttpService"):JSONDecode(res)
			end)

			local status = nil
			if decodeOk and type(statusData) == "table" then
				status = statusData.status
			end

			if status == "finished" or status == "stopped" then
				isPlaying = false
				isPaused = false
				playButton.Text = "▶ Play"
				playButton.Visible = true
				pauseButton.Visible = false
				stopButton.Visible = false
				task.wait(0.5)
				if #songQueue > 0 then
					playNextInQueue()
				else
					setStatus("✓ Queue finished", Color3.fromRGB(100, 200, 100))
				end
				break
			end

			task.wait(1)
		end
		playbackMonitor = nil
	end)
end

local function playNextInQueue()
	if #songQueue > 0 then
		local nextSong = table.remove(songQueue, 1)
		updateQueueUI()
		currentSongData = nextSong
		songTitle.Text = nextSong.title
		songArtist.Text = nextSong.artist
		setStatus("🎵 Playing: " .. nextSong.title, Color3.fromRGB(100, 200, 100))

		local success = pcall(function()
			game:HttpGet(PYTHON_SERVER .. "/play?path=" .. nextSong.path)
		end)

		if success then
			isPlaying = true
			isPaused = false
			playButton.Visible = false
			pauseButton.Visible = true
			stopButton.Visible = true
			startPlaybackMonitor()
		else
			setStatus("✗ Failed to play song", Color3.fromRGB(200, 100, 100))
			isPlaying = false
			playButton.Text = "▶ Play"
			playButton.Visible = true
			pauseButton.Visible = false
			stopButton.Visible = false
		end
	else
		isPlaying = false
		isPaused = false
		playButton.Text = "▶ Play"
		playButton.Visible = true
		pauseButton.Visible = false
		stopButton.Visible = false
		setStatus("✓ Queue finished", Color3.fromRGB(100, 200, 100))
	end
end

local function setStatus(text, color)
	statusLabel.Text = text
	statusLabel.TextColor3 = color or Color3.fromRGB(100, 200, 100)
end

local function callPythonBackend(link)
	setStatus("⏳ Fetching song data...", Color3.fromRGB(200, 200, 100))
	
	if not validateLink(link, serviceMode) then
		if serviceMode == "spotify" then
			setStatus("✗ Invalid Spotify link", Color3.fromRGB(200, 100, 100))
		else
			setStatus("✗ Invalid YouTube link", Color3.fromRGB(200, 100, 100))
		end
		return false
	end
	
	local endpoint = "/fetch"
	if serviceMode == "spotify" then
		endpoint = "/spotify/fetch?link=" .. link
	elseif serviceMode == "youtube" then
		endpoint = "/youtube/fetch?link=" .. game:GetService("HttpService"):UrlEncode(link)
	end
	
	local success, result = pcall(function()
		local response = game:HttpGet(PYTHON_SERVER .. endpoint)
		return response
	end)
	
	if success and result then
		local songData = game:GetService("HttpService"):JSONDecode(result)
		
		if songData and not songData.error then
			songTitle.Text = songData.title or "Unknown Title"
			songArtist.Text = songData.artist or "Unknown Artist"
			
			if songData.image then
				setRemoteImage(songImage, songData.image)
			end
			
			if isPlaying then
				addToQueue(songData)
				setStatus("✓ Song added to queue", Color3.fromRGB(100, 200, 100))
			else
				currentSongData = songData
				playButton.Visible = true
				pauseButton.Visible = false
				stopButton.Visible = false
				setStatus("✓ Song loaded (ready to play)", Color3.fromRGB(100, 200, 100))
			end
			
			return true
		else
			setStatus("✗ " .. (songData.error or "Failed to load song"), Color3.fromRGB(200, 100, 100))
			return false
		end
	else
		setStatus("✗ Python server not responding", Color3.fromRGB(200, 100, 100))
		return false
	end
end

local function playSong()
	if not currentSongData then
		setStatus("✗ No song loaded", Color3.fromRGB(200, 100, 100))
		return
	end

	if not isPythonServerRunning() then
		setStatus("Python script is not open!", Color3.fromRGB(200, 100, 100))
		return
	end

	if isPaused then
		isPaused = false
		isPlaying = true
		playButton.Visible = false
		pauseButton.Visible = true
		stopButton.Visible = true
		setStatus("🎵 Resumed: " .. currentSongData.title, Color3.fromRGB(100, 200, 100))

		local success = pcall(function()
			game:HttpGet(PYTHON_SERVER .. "/resume")
		end)

		if not success then
			setStatus("✗ Failed to resume", Color3.fromRGB(200, 100, 100))
			isPaused = true
			playButton.Visible = true
			pauseButton.Visible = false
		else
			startPlaybackMonitor()
		end
		return
	end

	isPlaying = true
	isPaused = false
	playButton.Visible = false
	pauseButton.Visible = true
	stopButton.Visible = true
	setStatus("🎵 Playing: " .. currentSongData.title, Color3.fromRGB(100, 200, 100))

	local success = pcall(function()
		game:HttpGet(PYTHON_SERVER .. "/play?path=" .. currentSongData.path)
	end)

	if not success then
		setStatus("✗ Failed to play song", Color3.fromRGB(200, 100, 100))
		isPlaying = false
		isPaused = false
		playButton.Visible = true
		pauseButton.Visible = false
		stopButton.Visible = false
	else
		startPlaybackMonitor()
	end
end

local function pauseSong()
	if not isPlaying or isPaused then
		return
	end
	
	isPaused = true
	isPlaying = false
	playButton.Visible = true
	playButton.Text = "▶ Resume"
	pauseButton.Visible = false
	stopButton.Visible = true
	setStatus("⏸ Paused: " .. (currentSongData and currentSongData.title or ""), Color3.fromRGB(200, 200, 100))
	
	local success = pcall(function()
		game:HttpGet(PYTHON_SERVER .. "/pause")
	end)
	
	if not success then
		setStatus("✗ Failed to pause", Color3.fromRGB(200, 100, 100))
		isPaused = false
		playButton.Visible = false
		pauseButton.Visible = true
	end
end

local function stopSong()
	pcall(function()
		game:HttpGet(PYTHON_SERVER .. "/stop")
	end)

	isPlaying = false
	isPaused = false
	currentSongData = nil
	playButton.Text = "▶ Play"
	playButton.Visible = false
	pauseButton.Visible = false
	stopButton.Visible = false

	songTitle.Text = "No song loaded"
	songArtist.Text = "Artist unknown"
	setRemoteImage(songImage, nil)

	setStatus("✓ Stopped", Color3.fromRGB(100, 200, 100))
end

local function skipSong()
	pcall(function()
		game:HttpGet(PYTHON_SERVER .. "/stop")
	end)

	task.wait(0.2)

	if #songQueue > 0 then
		setStatus("⏭ Skipping to next song...", Color3.fromRGB(100, 200, 100))
		playNextInQueue()
		pcall(function()
			safeSendChat("⏭ Skipped to next song.")
		end)
	else
		stopSong()
		pcall(function()
			safeSendChat("⏭ Skipped: no more songs, stopped playback.")
		end)
	end
end

local function searchAndPlaySong(songName)
	if not isPythonServerRunning() then
		setStatus("Python script is not open!", Color3.fromRGB(200, 100, 100))
		return
	end
	
	setStatus("Finding " .. songName .. "... Please wait.", Color3.fromRGB(200, 200, 100))
	
	local success, result = pcall(function()
		return game:HttpGet(PYTHON_SERVER .. "/search?query=" .. game:GetService("HttpService"):UrlEncode(songName))
	end)
	
	if not success or not result then
		setStatus("✗ Failed to search for song", Color3.fromRGB(200, 100, 100))
		return
	end
	
	local searchData
	local decodeOk = pcall(function()
		searchData = game:GetService("HttpService"):JSONDecode(result)
	end)
	
	if not decodeOk or not searchData or searchData.error then
		setStatus("✗ Song not found", Color3.fromRGB(200, 100, 100))
		pcall(function()
			safeSendChat("Song not found!")
		end)
		return
	end
	
	currentSongData = searchData
	songTitle.Text = searchData.title or "Unknown Title"
	songArtist.Text = searchData.artist or "Unknown Artist"
	
	if searchData.image then
		setRemoteImage(songImage, searchData.image)
	end
	
	playButton.Visible = true
	setStatus("Successfully found the song! Playing now...", Color3.fromRGB(100, 200, 100))
	pcall(function()
		safeSendChat("Successfully found the song! Playing now...")
	end)
	
	task.wait(0.5)
	playSong()
end

loadButton.MouseButton1Click:Connect(function()
	local link = inputBox.Text
	if link == "" then
		setStatus("✗ Enter a link", Color3.fromRGB(200, 100, 100))
		return
	end
	callPythonBackend(link)
end)

modeButton.MouseButton1Click:Connect(function()
	if serviceMode == "spotify" then
		serviceMode = "youtube"
		modeButton.Text = "YouTube"
		modeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		inputLabel.Text = "Enter YouTube Link:"
		inputBox.PlaceholderText = "https://www.youtube.com/watch?v=..."
		headerLabel.Text = "🎵 YouTube Music Bot"
	else
		serviceMode = "spotify"
		modeButton.Text = "Spotify"
		modeButton.BackgroundColor3 = Color3.fromRGB(36, 143, 86)
		inputLabel.Text = "Enter Spotify Link:"
		inputBox.PlaceholderText = "https://open.spotify.com/track/..."
		headerLabel.Text = "🎵 Spotify Music Bot"
	end
	inputBox.Text = ""
	setStatus("✓ Switched to " .. serviceMode:sub(1,1):upper() .. serviceMode:sub(2), Color3.fromRGB(100, 200, 100))
end)

playButton.MouseButton1Click:Connect(function()
	if not isPythonServerRunning() then
		setStatus("Python script is not open!", Color3.fromRGB(200, 100, 100))
		return
	end
	playSong()
end)

pauseButton.MouseButton1Click:Connect(function()
	if not isPythonServerRunning() then
		setStatus("Python script is not open!", Color3.fromRGB(200, 100, 100))
		return
	end
	pauseSong()
end)

stopButton.MouseButton1Click:Connect(function()
	if not isPythonServerRunning() then
		setStatus("Python script is not open!", Color3.fromRGB(200, 100, 100))
		return
	end
	stopSong()
end)

local CHAT_RATE_LIMIT_SECONDS = 5
local lastChatSentAt = 0
local function safeSendChat(message)
	local now = tick()
	if now - lastChatSentAt < CHAT_RATE_LIMIT_SECONDS then
		return
	end
	lastChatSentAt = now

	pcall(function()
		local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
		if channel then
			channel:SendAsync(message)
		end
	end)
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local function chatMessage(str)
	str = tostring(str)
	if TextChatService and TextChatService.TextChannels and TextChatService.TextChannels:FindFirstChild("RBXGeneral") then
		pcall(function() TextChatService.TextChannels.RBXGeneral:SendAsync(str) end)
	else
		pcall(function()
			if ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") and ReplicatedStorage.DefaultChatSystemChatEvents:FindFirstChild("SayMessageRequest") then
				ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(str, "All")
			end
		end)
	end
end

local function handleChatCommand(speakerName, message)
	message = message or ""
	message = message:match("^%s*(.-)%s*$") or ""
	local lower = message:lower()

	local function notWhitelisted()
		setStatus("✗ You are not whitelisted for this command!", Color3.fromRGB(200, 100, 100))
		pcall(function() safeSendChat("You are not whitelisted!") end)
	end

	if lower:sub(1,6) == "!play " or lower == "!play" then
		if not isPlayerWhitelisted(speakerName) then
			notWhitelisted()
			return
		end
		local songName = (message:sub(7) or ""):match("^%s*(.-)%s*$") or ""
		if songName ~= "" then
			pcall(function() safeSendChat("Finding " .. songName .. "... Please wait.") end)
			searchAndPlaySong(songName)
		else
			setStatus("✗ Usage: !play [song name]", Color3.fromRGB(200, 100, 100))
			pcall(function() safeSendChat("Usage: !play [song name]") end)
		end
	elseif lower == "!stop" then
		if not isPlayerWhitelisted(speakerName) then
			notWhitelisted()
			return
		end
		stopSong()
		pcall(function() safeSendChat("⏹ Playback stopped.") end)
	elseif lower == "!pause" then
		if not isPlayerWhitelisted(speakerName) then
			notWhitelisted()
			return
		end
		pauseSong()
		pcall(function() safeSendChat("⏸ Playback paused.") end)
	elseif lower == "!resume" then
		if not isPlayerWhitelisted(speakerName) then
			notWhitelisted()
			return
		end
		if not isPaused then
			setStatus("✗ No song is paused", Color3.fromRGB(200, 100, 100))
			pcall(function() safeSendChat("No song is paused.") end)
			return
		end
		playSong()
		pcall(function() safeSendChat("▶ Resumed playback.") end)
	elseif lower == "!skip" then
		if not isPlayerWhitelisted(speakerName) then
			notWhitelisted()
			return
		end
		skipSong()
		pcall(function() safeSendChat("⏭ Skipped to next song.") end)
	end
end

for _, plr in ipairs(Players:GetPlayers()) do
	pcall(function()
		plr.Chatted:Connect(function(msg) handleChatCommand(plr.Name, msg) end)
	end)
end
Players.PlayerAdded:Connect(function(plr)
	pcall(function()
		plr.Chatted:Connect(function(msg) handleChatCommand(plr.Name, msg) end)
	end)
end)

pcall(function()
	if TextChatService and TextChatService.OnIncomingMessage then
		TextChatService.OnIncomingMessage:Connect(function(incomingMsg)
			local text = incomingMsg and (incomingMsg.Text or incomingMsg.Message or "")
			local name = incomingMsg and (incomingMsg.FromSpeaker or incomingMsg.SenderName or (incomingMsg.TextSource and incomingMsg.TextSource.Name) or "")
			if text and name and text ~= "" and name ~= "" then
				handleChatCommand(name, text)
			end
		end)
	end
end)

if isPythonServerRunning() then
	setStatus("✓ Ready!", Color3.fromRGB(100, 200, 100))
	pythonRunning = true
else
	setStatus("✗ Python server not running (Start: python spotify_server.py)", Color3.fromRGB(200, 100, 100))
end