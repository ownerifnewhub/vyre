--[[
   VORTEX AUTO GRAB - Loadstring Version
   Copy and paste this entire code to execute
--]]

repeat task.wait() until game:IsLoaded()

print("🌀 Vortex Auto Grab Loaded!")

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local TS         = game:GetService("TweenService")
local UIS        = game:GetService("UserInputService")
local LP         = Players.LocalPlayer

-- ============================================================
-- SETTINGS
-- ============================================================
local StealRadius = 55

-- ============================================================
-- STEAL STATE
-- ============================================================
local Steal = {
	AutoStealEnabled = false,
	StealRadius = StealRadius,
	StealDuration = 0.1,
	Mode = "half",
	HalfFireRange = 10,
	HalfHoldMin = 1.3,
	HalfHoldMax = 2.6,
	HalfEntryDelay = 0.3,
	Data = {}
}
local isStealing = false
local stealStartTime = nil
local stealEndTime = nil
local stealCompleted = false
local autoConn = nil
local progressFill, progressTitle

local function isMyPlotByName(plotName)
	local plots = workspace:FindFirstChild("Plots")
	if not plots then return false end
	local plot = plots:FindFirstChild(plotName)
	if not plot then return false end
	local sign = plot:FindFirstChild("PlotSign")
	if sign then
		local yb = sign:FindFirstChild("YourBase")
		if yb and yb:IsA("BillboardGui") then return yb.Enabled == true end
	end
	return false
end

local function findNearestPrompt()
	local char = LP.Character
	if not char then return nil end
	local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
	if not root then return nil end
	local plots = workspace:FindFirstChild("Plots")
	if not plots then return nil end
	local nearest, dist = nil, math.huge
	for _, plot in ipairs(plots:GetChildren()) do
		if plot:IsA("Model") and not isMyPlotByName(plot.Name) then
			local pods = plot:FindFirstChild("AnimalPodiums")
			if pods then
				for _, pod in ipairs(pods:GetChildren()) do
					local base = pod:FindFirstChild("Base")
					local sp = base and base:FindFirstChild("Spawn")
					if sp then
						local d = (sp.Position - root.Position).Magnitude
						if d <= Steal.StealRadius and d < dist then
							local found = nil
							local att = sp:FindFirstChild("PromptAttachment")
							if att then
								for _, pr in ipairs(att:GetChildren()) do
									if pr:IsA("ProximityPrompt") and pr.ActionText and pr.ActionText:find("Steal") then found = pr end
								end
							end
							if not found then
								for _, pr in ipairs(sp:GetDescendants()) do
									if pr:IsA("ProximityPrompt") and pr.ActionText and pr.ActionText:find("Steal") then found = pr end
								end
							end
							if found then nearest, dist = found, d end
						end
					end
				end
			end
		end
	end
	return nearest
end

local function _promptDist(prompt)
	local char = LP.Character
	if not char then return math.huge end
	local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
	if not root then return math.huge end
	local part = prompt.Parent
	if part and part:IsA("Attachment") then part = part.Parent end
	if part and part:IsA("BasePart") then return (part.Position - root.Position).Magnitude end
	local ok, cf = pcall(function() return prompt.Parent and prompt.Parent.WorldPosition end)
	if ok and cf then return (cf - root.Position).Magnitude end
	return math.huge
end

local function executeSteal(prompt)
	if isStealing then return end
	if not Steal.Data[prompt] then
		Steal.Data[prompt] = {hold = {}, trigger = {}, ready = true}
		if getconnections then
			for _, c in ipairs(getconnections(prompt.PromptButtonHoldBegan)) do
				if c.Function then table.insert(Steal.Data[prompt].hold, c.Function) end
			end
			for _, c in ipairs(getconnections(prompt.Triggered)) do
				if c.Function then table.insert(Steal.Data[prompt].trigger, c.Function) end
			end
		end
	end
	local data = Steal.Data[prompt]
	if not data.ready then return end
	data.ready = false
	isStealing = true
	stealCompleted = false
	stealStartTime = tick()
	stealEndTime = nil

	task.spawn(function()
		for _, fn in ipairs(data.hold) do task.spawn(fn) end
		task.wait(Steal.HalfHoldMin)
		local inRange = _promptDist(prompt) <= Steal.HalfFireRange
		while true do
			local el = tick() - stealStartTime
			if el > Steal.HalfHoldMax or not prompt.Parent then break end
			if _promptDist(prompt) <= Steal.HalfFireRange then
				if not inRange then task.wait(Steal.HalfEntryDelay) end
				for _, fn in ipairs(data.trigger) do task.spawn(fn) end
				break
			end
			task.wait()
		end
		stealCompleted = true
		stealEndTime = tick()
		task.wait(0.5)
		data.ready = true
		isStealing = false
		stealCompleted = false
	end)
end

local function startAutoSteal()
	if autoConn then return end
	autoConn = RunService.Heartbeat:Connect(function()
		if not Steal.AutoStealEnabled or isStealing then return end
		local p = findNearestPrompt()
		if p then executeSteal(p) end
	end)
end

_G.AutoSteal = Steal

-- ============================================================
-- BUILD UI - VORTEX THEME (Red + Blue + Black)
-- ============================================================
local VORTEX_RED = Color3.fromRGB(200, 20, 20)
local VORTEX_BLUE = Color3.fromRGB(20, 80, 220)
local VORTEX_WHITE = Color3.fromRGB(255, 255, 255)
local VORTEX_DARK = Color3.fromRGB(8, 4, 12)
local VORTEX_DARKER = Color3.fromRGB(5, 5, 6)
local VORTEX_DIM = Color3.fromRGB(100, 80, 140)

local VortexAutoGrabGUI = Instance.new("ScreenGui")
VortexAutoGrabGUI.Name = "VortexAutoGrabGUI"
VortexAutoGrabGUI.IgnoreGuiInset = true
VortexAutoGrabGUI.ResetOnSpawn = false
VortexAutoGrabGUI.DisplayOrder = 999
VortexAutoGrabGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
VortexAutoGrabGUI.Parent = LP:WaitForChild("PlayerGui")

-- Shadow
local StealBarShadow = Instance.new("Frame")
StealBarShadow.Name = "StealBarShadow"
StealBarShadow.ZIndex = 9
StealBarShadow.Position = UDim2.new(0.5,-139,0,131)
StealBarShadow.Size = UDim2.new(0,285,0,32)
StealBarShadow.BackgroundColor3 = Color3.fromRGB(0,0,0)
StealBarShadow.BackgroundTransparency = 0.55
StealBarShadow.BorderSizePixel = 0
StealBarShadow.Parent = VortexAutoGrabGUI

local UICorner = Instance.new("UICorner")
UICorner.Name = "UICorner"
UICorner.CornerRadius = UDim.new(0,14)
UICorner.Parent = StealBarShadow

-- Main Bar
local StealBar = Instance.new("TextButton")
StealBar.Name = "StealBar"
StealBar.ZIndex = 10
StealBar.ClipsDescendants = true
StealBar.Position = UDim2.new(0.5,-142,0,128)
StealBar.Size = UDim2.new(0,285,0,32)
StealBar.BackgroundColor3 = VORTEX_DARKER
StealBar.BackgroundTransparency = 0.04
StealBar.BorderSizePixel = 0
StealBar.Text = ""
StealBar.AutoButtonColor = false
StealBar.Parent = VortexAutoGrabGUI

local UICorner2 = Instance.new("UICorner")
UICorner2.Name = "UICorner"
UICorner2.CornerRadius = UDim.new(0,14)
UICorner2.Parent = StealBar

local UIStroke = Instance.new("UIStroke")
UIStroke.Name = "UIStroke"
UIStroke.Color = VORTEX_RED
UIStroke.Thickness = 1.4
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke.Transparency = 0.18
UIStroke.Parent = StealBar

local UIGradient = Instance.new("UIGradient")
UIGradient.Name = "UIGradient"
UIGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, VORTEX_RED),
	ColorSequenceKeypoint.new(0.55, VORTEX_DARKER),
	ColorSequenceKeypoint.new(1, VORTEX_BLUE)
})
UIGradient.Rotation = 90
UIGradient.Parent = StealBar

-- Progress Fill
local LeftToRightFill = Instance.new("Frame")
LeftToRightFill.Name = "LeftToRightFill"
LeftToRightFill.ZIndex = 11
LeftToRightFill.Size = UDim2.new(0,0,1,0)
LeftToRightFill.BackgroundColor3 = VORTEX_WHITE
LeftToRightFill.BackgroundTransparency = 0.82
LeftToRightFill.BorderSizePixel = 0
LeftToRightFill.Parent = StealBar

local UICorner3 = Instance.new("UICorner")
UICorner3.Name = "UICorner"
UICorner3.CornerRadius = UDim.new(0,14)
UICorner3.Parent = LeftToRightFill

-- Title
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.ZIndex = 12
Title.Position = UDim2.new(0,12,0,0)
Title.Size = UDim2.new(1,-42,1,0)
Title.BackgroundTransparency = 1
Title.Text = "🌀 VORTEX GRAB  |  0%"
Title.TextColor3 = VORTEX_WHITE
Title.TextSize = 12
Title.Font = Enum.Font.GothamBlack
Title.TextStrokeTransparency = 0.45
Title.Parent = StealBar

progressFill = LeftToRightFill
progressTitle = Title

-- Settings Gear
local SettingsGear = Instance.new("TextButton")
SettingsGear.Name = "SettingsGear"
SettingsGear.ZIndex = 13
SettingsGear.Position = UDim2.new(1,-29,0.5,-12)
SettingsGear.Size = UDim2.new(0,24,0,24)
SettingsGear.BackgroundColor3 = VORTEX_DARKER
SettingsGear.BackgroundTransparency = 0.18
SettingsGear.BorderSizePixel = 0
SettingsGear.Text = "⚙"
SettingsGear.TextColor3 = VORTEX_WHITE
SettingsGear.TextSize = 13
SettingsGear.Font = Enum.Font.GothamBlack
SettingsGear.AutoButtonColor = false
SettingsGear.Parent = StealBar

local UICorner4 = Instance.new("UICorner")
UICorner4.Name = "UICorner"
UICorner4.CornerRadius = UDim.new(0,10)
UICorner4.Parent = SettingsGear

local UIStroke2 = Instance.new("UIStroke")
UIStroke2.Name = "UIStroke"
UIStroke2.Color = VORTEX_BLUE
UIStroke2.Thickness = 1
UIStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke2.Transparency = 0.3
UIStroke2.Parent = SettingsGear

-- Radius Dropdown
local RadiusDropdown = Instance.new("Frame")
RadiusDropdown.Name = "RadiusDropdown"
RadiusDropdown.ZIndex = 20
RadiusDropdown.Position = UDim2.new(0.5,-33,0,166)
RadiusDropdown.Size = UDim2.new(0,176,0,62)
RadiusDropdown.BackgroundColor3 = VORTEX_DARKER
RadiusDropdown.BackgroundTransparency = 0.04
RadiusDropdown.BorderSizePixel = 0
RadiusDropdown.Visible = false
RadiusDropdown.Parent = VortexAutoGrabGUI

local UICorner5 = Instance.new("UICorner")
UICorner5.Name = "UICorner"
UICorner5.CornerRadius = UDim.new(0,14)
UICorner5.Parent = RadiusDropdown

local UIStroke3 = Instance.new("UIStroke")
UIStroke3.Name = "UIStroke"
UIStroke3.Color = VORTEX_RED
UIStroke3.Thickness = 1.2
UIStroke3.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke3.Transparency = 0.22
UIStroke3.Parent = RadiusDropdown

local UIGradient2 = Instance.new("UIGradient")
UIGradient2.Name = "UIGradient"
UIGradient2.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, VORTEX_RED),
	ColorSequenceKeypoint.new(0.5, VORTEX_DARKER),
	ColorSequenceKeypoint.new(1, VORTEX_BLUE)
})
UIGradient2.Rotation = 90
UIGradient2.Parent = RadiusDropdown

local TextLabel = Instance.new("TextLabel")
TextLabel.Name = "TextLabel"
TextLabel.ZIndex = 21
TextLabel.Position = UDim2.new(0,12,0,0)
TextLabel.Size = UDim2.new(1,-78,1,0)
TextLabel.BackgroundTransparency = 1
TextLabel.Text = "RADIUS"
TextLabel.TextColor3 = VORTEX_WHITE
TextLabel.TextSize = 12
TextLabel.Font = Enum.Font.GothamBlack
TextLabel.TextXAlignment = Enum.TextXAlignment.Left
TextLabel.Parent = RadiusDropdown

local RadiusBox = Instance.new("TextBox")
RadiusBox.Name = "RadiusBox"
RadiusBox.ZIndex = 22
RadiusBox.Position = UDim2.new(1,-64,0.5,-15)
RadiusBox.Size = UDim2.new(0,54,0,30)
RadiusBox.BackgroundColor3 = VORTEX_WHITE
RadiusBox.BorderSizePixel = 0
RadiusBox.Text = tostring(StealRadius)
RadiusBox.TextColor3 = VORTEX_DARK
RadiusBox.TextSize = 13
RadiusBox.Font = Enum.Font.GothamBlack
RadiusBox.ClearTextOnFocus = false
RadiusBox.Parent = RadiusDropdown

local UICorner6 = Instance.new("UICorner")
UICorner6.Name = "UICorner"
UICorner6.CornerRadius = UDim.new(0,12)
UICorner6.Parent = RadiusBox

local UIStroke4 = Instance.new("UIStroke")
UIStroke4.Name = "UIStroke"
UIStroke4.Color = VORTEX_BLUE
UIStroke4.Thickness = 1.5
UIStroke4.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke4.Transparency = 0.3
UIStroke4.Parent = RadiusBox

-- ============================================================
-- FUNCTIONALITY
-- ============================================================

-- Toggle radius dropdown
SettingsGear.Activated:Connect(function()
	RadiusDropdown.Visible = not RadiusDropdown.Visible
end)

-- Update radius when textbox changes
RadiusBox.FocusLost:Connect(function(enterPressed)
	local val = tonumber(RadiusBox.Text)
	if val and val > 0 then
		StealRadius = math.clamp(math.floor(val), 1, 500)
		Steal.StealRadius = StealRadius
		RadiusBox.Text = tostring(StealRadius)
	else
		RadiusBox.Text = tostring(StealRadius)
	end
end)

-- Drive progress fill and title
local _lastPct = 0
local _visualSpeed = 0.35
local _decaySpeed = 1.5
RunService.RenderStepped:Connect(function(dt)
	local targetPct = 0
	if isStealing and stealStartTime then
		if stealCompleted then
			local timeSinceComplete = tick() - (stealEndTime or tick())
			if timeSinceComplete < 0.3 then
				targetPct = 1
			else
				targetPct = math.max(0, 1 - (timeSinceComplete - 0.3) * _decaySpeed)
			end
		else
			local rawPct = math.clamp((tick() - stealStartTime) / math.max(Steal.HalfHoldMin, 0.01), 0, 1)
			targetPct = rawPct
		end
	else
		targetPct = 0
	end

	_lastPct = _lastPct + (targetPct - _lastPct) * math.min(dt * _visualSpeed * 60, 1)
	local f = math.clamp(_lastPct, 0, 1)
	progressFill.Size = UDim2.new(f, 0, 1, 0)

	progressTitle.Text = "🌀 VORTEX GRAB  |  " .. math.floor(f * 100) .. "%"
end)

-- Drag handling
local dragging, dragStart, startPos, startShadowPos, startDropdownPos = false, nil, nil, nil, nil
StealBar.InputBegan:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = inp.Position
		startPos = StealBar.Position
		startShadowPos = StealBarShadow.Position
		startDropdownPos = RadiusDropdown.Position
		inp.Changed:Connect(function()
			if inp.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)

UIS.InputChanged:Connect(function(inp)
	if not dragging then return end
	if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
		local dx = inp.Position.X - dragStart.X
		local dy = inp.Position.Y - dragStart.Y
		local cam = workspace.CurrentCamera
		local vp = cam and cam.ViewportSize or Vector2.new(1000, 1000)
		local sz = StealBar.AbsoluteSize
		local newXScalePx = startPos.X.Scale * vp.X
		local newX = math.clamp(newXScalePx + startPos.X.Offset + dx, sz.X / 2, vp.X - sz.X / 2)
		local newY = math.clamp(startPos.Y.Scale * vp.Y + startPos.Y.Offset + dy, 0, vp.Y - sz.Y)
		StealBar.Position = UDim2.new(startPos.X.Scale, newX - newXScalePx, startPos.Y.Scale, newY - startPos.Y.Scale * vp.Y)
		StealBarShadow.Position = UDim2.new(startShadowPos.X.Scale, startShadowPos.X.Offset + dx, startShadowPos.Y.Scale, startShadowPos.Y.Offset + dy)
		RadiusDropdown.Position = UDim2.new(startDropdownPos.X.Scale, startDropdownPos.X.Offset + dx, startDropdownPos.Y.Scale, startDropdownPos.Y.Offset + dy)
	end
end)

-- Auto steal always on
Steal.AutoStealEnabled = true
pcall(startAutoSteal)

print("🌀 Vortex Auto Grab loaded successfully!")
print("⚙ Click the gear icon to adjust radius")