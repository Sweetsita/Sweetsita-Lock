--// ðŸ¦‡ SWEETSITA LOCK SYSTEM ðŸ¦‡

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TextChatService = game:GetService("TextChatService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

--// SETTINGS
local Settings = {
	MaxDistance = 160,
	Prediction = 0.18,
	Smooth = 1,
	Offset = Vector3.new(2.5, 2, 8)
}

local lockOn = false
local target = nil
local renderConn

--==================================================
-- COLORS
--==================================================

local BG = Color3.fromRGB(15, 15, 15)
local BUTTON = Color3.fromRGB(28, 28, 28)
local TEXT = Color3.fromRGB(240, 240, 240)
local MUTED = Color3.fromRGB(160, 160, 160)
local ACCENT = Color3.fromRGB(255, 255, 255)
local BAR_BG = Color3.fromRGB(45, 45, 45)

local GREEN = Color3.fromRGB(45, 190, 80)
local RED = Color3.fromRGB(190, 45, 45)

--==================================================
-- GUI
--==================================================

local gui = Instance.new("ScreenGui")
gui.Name = "SweetsitaGUI"
gui.ResetOnSpawn = false
gui.Parent = player.PlayerGui

local clickSound = Instance.new("Sound")
clickSound.SoundId = "rbxassetid://12221967"
clickSound.Volume = 1
clickSound.Parent = gui

--// MAIN FRAME
local frame = Instance.new("Frame")

frame.Size = UDim2.new(0, 210, 0, 300)

frame.Position =
	UDim2.new(
		0,
		-250,
		0.5,
		-150
	)

frame.BackgroundColor3 = BG
frame.Active = true
frame.Draggable = true
frame.BorderSizePixel = 0
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius =
	UDim.new(0, 16)

local stroke = Instance.new("UIStroke")

stroke.Color = ACCENT
stroke.Thickness = 1.5
stroke.Parent = frame

local layout = Instance.new("UIListLayout")

layout.Padding = UDim.new(0, 6)
layout.HorizontalAlignment =
	Enum.HorizontalAlignment.Center
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = frame

--==================================================
-- BUTTON CREATOR
--==================================================

local function makeButton(text)

	local b = Instance.new("TextButton")

	b.Size = UDim2.new(1, -10, 0, 45)

	b.BackgroundColor3 = BUTTON
	b.TextColor3 = TEXT
	b.Font = Enum.Font.GothamBold
	b.TextScaled = true
	b.Text = text

	b.AutoButtonColor = true
	b.BorderSizePixel = 0
	b.Parent = frame

	Instance.new("UICorner", b).CornerRadius =
		UDim.new(0, 10)

	return b
end

--==================================================
-- TITLE
--==================================================

local title = makeButton("Sweet Lock ðŸ¦‡")

title.BackgroundColor3 =
	Color3.fromRGB(22, 22, 22)

title.TextColor3 = ACCENT

title.TextScaled = false
title.TextSize = 18

--==================================================
-- LOCK BUTTONS
--==================================================

local onBtn = makeButton("Lock: ON")
local offBtn = makeButton("Lock: OFF")

--==================================================
-- FIX UI
--==================================================

local fixBtn = makeButton("Fix UI: OFF")

local uiFixed = false

fixBtn.MouseButton1Click:Connect(function()

	clickSound:Play()

	uiFixed = not uiFixed

	if uiFixed then

		frame.Draggable = false

		fixBtn.Text = "Fix UI: ON"
		fixBtn.TextColor3 = TEXT
		fixBtn.BackgroundColor3 = GREEN

	else

		frame.Draggable = true

		fixBtn.Text = "Fix UI: OFF"
		fixBtn.TextColor3 = TEXT
		fixBtn.BackgroundColor3 = RED

	end
end)

--==================================================
-- FPS + PLAYERS
--==================================================

local statsLabel = Instance.new("TextLabel")

statsLabel.Size =
	UDim2.new(1, -20, 0, 24)

statsLabel.BackgroundTransparency = 1

statsLabel.Text =
	"FPS: --  â€¢  PLAYERS: " ..
	#Players:GetPlayers()

statsLabel.TextColor3 = MUTED
statsLabel.Font = Enum.Font.GothamBold
statsLabel.TextSize = 11
statsLabel.TextXAlignment =
	Enum.TextXAlignment.Center

statsLabel.Parent = frame

--// FPS COUNTER
local frameCount = 0
local lastFPSUpdate = tick()

RunService.RenderStepped:Connect(function()

	frameCount += 1

	local now = tick()
	local elapsed = now - lastFPSUpdate

	if elapsed >= 0.5 then

		local fps = math.floor(
			frameCount / elapsed + 0.5
		)

		statsLabel.Text =
			string.format(
				"FPS: %d  â€¢  PLAYERS: %d",
				fps,
				#Players:GetPlayers()
			)

		frameCount = 0
		lastFPSUpdate = now
	end
end)

--==================================================
-- PREDICTION LABEL
--==================================================

local predictionLabel = Instance.new("TextLabel")

predictionLabel.Size =
	UDim2.new(1, -20, 0, 24)

predictionLabel.BackgroundTransparency = 1

predictionLabel.Text =
	string.format(
		"PREDICTION: %.2f",
		Settings.Prediction
	)

predictionLabel.TextColor3 = TEXT
predictionLabel.Font = Enum.Font.GothamBold
predictionLabel.TextSize = 11
predictionLabel.TextXAlignment =
	Enum.TextXAlignment.Left

predictionLabel.Parent = frame

--==================================================
-- PREDICTION SLIDER
--==================================================

local sliderBack = Instance.new("Frame")

sliderBack.Size =
	UDim2.new(1, -20, 0, 8)

sliderBack.BackgroundColor3 = BAR_BG
sliderBack.BorderSizePixel = 0
sliderBack.Parent = frame

Instance.new("UICorner", sliderBack).CornerRadius =
	UDim.new(1, 0)

local sliderFill = Instance.new("Frame")

sliderFill.Size = UDim2.new(
	Settings.Prediction / 0.50,
	0,
	1,
	0
)

sliderFill.BackgroundColor3 = ACCENT
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderBack

Instance.new("UICorner", sliderFill).CornerRadius =
	UDim.new(1, 0)

local sliderButton = Instance.new("TextButton")

sliderButton.Size =
	UDim2.new(1, 0, 1, 0)

sliderButton.BackgroundTransparency = 1
sliderButton.Text = ""
sliderButton.Parent = sliderBack

local sliderDragging = false

local function updatePredictionSlider(input)

	local mouseX = input.Position.X

	local startX =
		sliderBack.AbsolutePosition.X

	local width =
		sliderBack.AbsoluteSize.X

	local percentage = math.clamp(
		(mouseX - startX) / width,
		0,
		1
	)

	Settings.Prediction =
		percentage * 0.50

	sliderFill.Size = UDim2.new(
		percentage,
		0,
		1,
		0
	)

	predictionLabel.Text =
		string.format(
			"PREDICTION: %.2f",
			Settings.Prediction
		)
end

sliderButton.InputBegan:Connect(function(input)

	if input.UserInputType ==
		Enum.UserInputType.MouseButton1
		or input.UserInputType ==
		Enum.UserInputType.Touch then

		sliderDragging = true

		updatePredictionSlider(input)
	end
end)

UserInputService.InputChanged:Connect(function(input)

	if sliderDragging
		and (
			input.UserInputType ==
				Enum.UserInputType.MouseMovement
			or input.UserInputType ==
				Enum.UserInputType.Touch
		) then

		updatePredictionSlider(input)
	end
end)

UserInputService.InputEnded:Connect(function(input)

	if input.UserInputType ==
		Enum.UserInputType.MouseButton1
		or input.UserInputType ==
		Enum.UserInputType.Touch then

		sliderDragging = false
	end
end)

--==================================================
-- MINIMIZE BUTTON
--==================================================

local minBtn = Instance.new("TextButton")

minBtn.Size =
	UDim2.new(0, 30, 0, 30)

minBtn.Position =
	UDim2.new(
		0,
		-35,
		0.5,
		-150
	)

minBtn.BackgroundColor3 = BUTTON
minBtn.TextColor3 = TEXT
minBtn.Font = Enum.Font.GothamBold
minBtn.TextScaled = true
minBtn.Text = "âˆ’"
minBtn.BorderSizePixel = 0
minBtn.ZIndex = 10
minBtn.Parent = gui

Instance.new("UICorner", minBtn).CornerRadius =
	UDim.new(0, 8)

local minStroke = Instance.new("UIStroke")

minStroke.Color = ACCENT
minStroke.Thickness = 1.5
minStroke.Parent = minBtn

--==================================================
-- MINIMIZE POSITION
--==================================================

frame:GetPropertyChangedSignal("Position"):Connect(function()

	minBtn.Position = UDim2.new(
		frame.Position.X.Scale,
		frame.Position.X.Offset + 175,
		frame.Position.Y.Scale,
		frame.Position.Y.Offset + 8
	)
end)

local minimized = false

minBtn.MouseButton1Click:Connect(function()

	clickSound:Play()

	minimized = not minimized

	frame.Visible = not minimized

	if minimized then
		minBtn.Text = "+"
	else
		minBtn.Text = "âˆ’"
	end
end)

--==================================================
-- INTRO ANIMATION
--==================================================

gui.Enabled = true

TweenService:Create(
	frame,
	TweenInfo.new(
		0.8,
		Enum.EasingStyle.Back
	),
	{
		Position =
			UDim2.new(
				0,
				15,
				0.5,
				-150
			)
	}
):Play()

--==================================================
-- STARTUP MESSAGE
--==================================================

task.delay(0.5, function()

	pcall(function()

		local channels =
			TextChatService:FindFirstChild("TextChannels")

		if channels then
		end
	end)

end)

--==================================================
-- HELPERS
--==================================================

local function char()
	return player.Character
end

local function hrp(c)
	return c and
		c:FindFirstChild("HumanoidRootPart")
end

local function hum(c)
	return c and
		c:FindFirstChildOfClass("Humanoid")
end

local function valid(m)

	return m
		and m ~= char()
		and hum(m)
		and hum(m).Health > 0
		and hrp(m)
end

local function getClosest()

	local best
	local dist = math.huge

	local myhrp = hrp(char())

	if not myhrp then
		return
	end

	for _, m in pairs(
		workspace:GetDescendants()
	) do

		if m:IsA("Model")
			and valid(m) then

			local d =
				(
					hrp(m).Position
					- myhrp.Position
				).Magnitude

			if d < dist
				and d < Settings.MaxDistance then

				dist = d
				best = m
			end
		end
	end

	return best
end

local function resetCam()

	camera.CameraType =
		Enum.CameraType.Custom

	UserInputService.MouseBehavior =
		Enum.MouseBehavior.Default
end

--==================================================
-- LOCK LOOP
--==================================================

local function startLock()

	if renderConn then
		return
	end

	lockOn = true

	UserInputService.MouseBehavior =
		Enum.MouseBehavior.LockCenter

	renderConn =
		RunService.RenderStepped:Connect(
		function()

			if not lockOn then
				return
			end

			local c = char()
			local myhrp = hrp(c)

			if not myhrp then
				return
			end

			if not valid(target) then
				target = getClosest()
			end

			if not valid(target) then
				return
			end

			local tpos =
				hrp(target).Position
				+ hrp(target).Velocity
				* Settings.Prediction

			myhrp.CFrame =
				CFrame.new(
					myhrp.Position,
					Vector3.new(
						tpos.X,
						myhrp.Position.Y,
						tpos.Z
					)
				)

			local smooth =
				Settings.Smooth

			local offset =
				Settings.Offset

			local look =
				myhrp.CFrame.LookVector

			local flatLook =
				Vector3.new(
					look.X,
					0,
					look.Z
				)

			if flatLook.Magnitude > 0 then
				flatLook = flatLook.Unit
			else
				flatLook =
					Vector3.new(0,0,-1)
			end

			local flatCF =
				CFrame.lookAt(
					myhrp.Position,
					myhrp.Position
						+ flatLook
				)

			local camPos =
				flatCF:ToWorldSpace(
					CFrame.new(offset)
				)

			local camCF =
				CFrame.new(
					camPos.Position,
					tpos
				)

			camera.CFrame =
				camera.CFrame:Lerp(
					camCF,
					smooth
				)
		end
	)
end

--==================================================
-- STOP LOCK
--==================================================

local function stopLock()

	lockOn = false
	target = nil

	if renderConn then
		renderConn:Disconnect()
	end

	renderConn = nil

	resetCam()

	camera.FieldOfView = 70
end

--==================================================
-- BUTTONS
--==================================================

onBtn.MouseButton1Click:Connect(function()

	clickSound:Play()

	startLock()

	--// VISUAL ONLY
	onBtn.BackgroundColor3 = GREEN
	offBtn.BackgroundColor3 = BUTTON

end)

offBtn.MouseButton1Click:Connect(function()

	clickSound:Play()

	stopLock()

	--// VISUAL ONLY
	offBtn.BackgroundColor3 = RED
	onBtn.BackgroundColor3 = BUTTON

end)

--==================================================
-- CHARACTER RESPAWN
--==================================================

player.CharacterAdded:Connect(function()

	task.wait(0.5)

	stopLock()

end)