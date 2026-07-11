local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- VORTEX THEME
local VORTEX_RED = Color3.fromRGB(200, 20, 20)
local VORTEX_RED_DARK = Color3.fromRGB(130, 10, 10)
local VORTEX_RED_LIGHT = Color3.fromRGB(230, 60, 60)
local VORTEX_BLUE = Color3.fromRGB(20, 80, 220)
local VORTEX_WHITE = Color3.fromRGB(255, 255, 255)
local VORTEX_DARK = Color3.fromRGB(12, 8, 20)
local VORTEX_DARKER = Color3.fromRGB(8, 4, 12)
local VORTEX_DIM = Color3.fromRGB(100, 80, 140)
local BLACK = Color3.fromRGB(0, 0, 0)

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- STATE
local AntiBatEnabled = false
local HitCancelEnabled = false
local CurrentKeybind = Enum.KeyCode.O
local WaitingForKeybind = false
local isMinimized = false
local AntiBatConn = nil
local AntiRagdollConn = nil
local HitCancelConn = nil

-- ============================================================
-- ANTI BAT CORE
-- ============================================================
local function startAntiBat()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    if AntiBatConn then AntiBatConn:Disconnect() end
    
    AntiBatConn = RunService.Heartbeat:Connect(function()
        if not root or not root.Parent then return end
        local origXZ = Vector3.new(root.Velocity.X, 0, root.Velocity.Z)
        root.Velocity = Vector3.new(1000, root.Velocity.Y, 1000)
        RunService.RenderStepped:Wait()
        root.Velocity = Vector3.new(origXZ.X, root.Velocity.Y, origXZ.Z)
    end)
end

local function stopAntiBat()
    if AntiBatConn then
        AntiBatConn:Disconnect()
        AntiBatConn = nil
    end
end

-- ============================================================
-- HIT CANCEL
-- ============================================================
local function startHitCancel()
    HitCancelEnabled = true
    if HitCancelConn then return end
    
    local function cancelHit(obj)
        pcall(function()
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                if obj.Name:lower():find("hit") or obj.Name:lower():find("damage") or obj.Name:lower():find("attack") or obj.Name:lower():find("bat") then
                    local oldFire = obj.FireServer
                    obj.FireServer = function(self, ...)
                        local args = {...}
                        if type(args[1]) == "Instance" and args[1]:IsDescendantOf(LocalPlayer.Character) then
                            return
                        end
                        return oldFire(self, ...)
                    end
                end
            end
        end)
    end
    
    for _, obj in ipairs(game:GetDescendants()) do
        cancelHit(obj)
    end
    
    HitCancelConn = game.DescendantAdded:Connect(function(obj)
        if HitCancelEnabled then
            cancelHit(obj)
        end
    end)
end

local function stopHitCancel()
    HitCancelEnabled = false
    if HitCancelConn then
        HitCancelConn:Disconnect()
        HitCancelConn = nil
    end
end

-- ============================================================
-- ANTI RAGDOLL
-- ============================================================
local function startAntiRagdoll()
    if AntiRagdollConn then return end
    AntiRagdollConn = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hum2 = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if hum2 then
            local st = hum2:GetState()
            if st == Enum.HumanoidStateType.Physics or st == Enum.HumanoidStateType.Ragdoll or st == Enum.HumanoidStateType.FallingDown then
                hum2:ChangeState(Enum.HumanoidStateType.Running)
                workspace.CurrentCamera.CameraSubject = hum2
                pcall(function()
                    local pm = LocalPlayer.PlayerScripts:FindFirstChild("PlayerModule")
                    if pm then require(pm:FindFirstChild("ControlModule")):Enable() end
                end)
                if root then
                    root.Velocity = Vector3.new(0,0,0)
                    root.RotVelocity = Vector3.new(0,0,0)
                end
            end
        end
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("Motor6D") and not obj.Enabled then
                obj.Enabled = true
            end
        end
    end)
end

local function stopAntiRagdoll()
    if AntiRagdollConn then
        AntiRagdollConn:Disconnect()
        AntiRagdollConn = nil
    end
end

-- ============================================================
-- KEYBIND SAVE/LOAD
-- ============================================================
local keybindFile = "VortexAntiBat_Keybind.txt"
local stateFile = "VortexAntiBat_State.txt"

local function loadKeybind()
    if isfile and isfile(keybindFile) then
        local success, savedData = pcall(function() return readfile(keybindFile) end)
        if success and savedData then
            for _, enum in ipairs(Enum.KeyCode:GetEnumItems()) do
                if enum.Name == savedData then
                    CurrentKeybind = enum
                    break
                end
            end
        end
    end
end

local function saveKeybind()
    if writefile then
        pcall(function() writefile(keybindFile, CurrentKeybind.Name) end)
    end
end

loadKeybind()

-- ============================================================
-- SLIDING TOGGLE FUNCTION
-- ============================================================
local function createToggle(parent, label, yPos, onToggle)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,-20,0,48)
    row.Position = UDim2.new(0,10,0,yPos)
    row.BackgroundColor3 = VORTEX_DARKER
    row.BorderSizePixel = 0
    row.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,10)
    corner.Parent = row
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = VORTEX_RED_DARK
    stroke.Transparency = 0.3
    stroke.Parent = row
    
    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(1,-70,0,16)
    labelText.Position = UDim2.new(0,10,0,5)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = VORTEX_WHITE
    labelText.TextSize = 11
    labelText.Font = Enum.Font.GothamBold
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = row
    
    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.new(1,-70,0,12)
    statusText.Position = UDim2.new(0,10,0,23)
    statusText.BackgroundTransparency = 1
    statusText.Text = "○ INACTIVE"
    statusText.TextColor3 = VORTEX_DIM
    statusText.TextSize = 8
    statusText.Font = Enum.Font.GothamMedium
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.Parent = row
    
    local toggleBg = Instance.new("Frame")
    toggleBg.Size = UDim2.new(0,44,0,24)
    toggleBg.Position = UDim2.new(1,-54,0.5,-12)
    toggleBg.BackgroundColor3 = VORTEX_DARK
    toggleBg.BorderSizePixel = 0
    toggleBg.Parent = row
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0,12)
    toggleCorner.Parent = toggleBg
    
    local toggleStroke = Instance.new("UIStroke")
    toggleStroke.Color = VORTEX_RED_DARK
    toggleStroke.Transparency = 0.3
    toggleStroke.Parent = toggleBg
    
    local toggleDot = Instance.new("Frame")
    toggleDot.Size = UDim2.new(0,18,0,18)
    toggleDot.Position = UDim2.new(0,2,0.5,-9)
    toggleDot.BackgroundColor3 = VORTEX_DIM
    toggleDot.BorderSizePixel = 0
    toggleDot.Parent = toggleBg
    
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(0,9)
    dotCorner.Parent = toggleDot
    
    local clickBtn = Instance.new("TextButton")
    clickBtn.Size = UDim2.new(1,0,1,0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.Parent = row
    
    local isOn = false
    
    local function updateUI(state)
        isOn = state
        if state then
            statusText.Text = "● ACTIVE"
            statusText.TextColor3 = VORTEX_RED_LIGHT
            toggleBg.BackgroundColor3 = VORTEX_RED
            toggleStroke.Color = VORTEX_RED
            toggleStroke.Transparency = 0
            row.BackgroundColor3 = VORTEX_DARK
            stroke.Color = VORTEX_RED
            stroke.Transparency = 0.5
            TweenService:Create(toggleDot, TweenInfo.new(0.2, Enum.EasingStyle.Back), {Position = UDim2.new(1,-20,0.5,-9)}):Play()
            TweenService:Create(toggleDot, TweenInfo.new(0.2), {BackgroundColor3 = VORTEX_WHITE}):Play()
        else
            statusText.Text = "○ INACTIVE"
            statusText.TextColor3 = VORTEX_DIM
            toggleBg.BackgroundColor3 = VORTEX_DARK
            toggleStroke.Color = VORTEX_RED_DARK
            toggleStroke.Transparency = 0.3
            row.BackgroundColor3 = VORTEX_DARKER
            stroke.Color = VORTEX_RED_DARK
            stroke.Transparency = 0.3
            TweenService:Create(toggleDot, TweenInfo.new(0.2, Enum.EasingStyle.Back), {Position = UDim2.new(0,2,0.5,-9)}):Play()
            TweenService:Create(toggleDot, TweenInfo.new(0.2), {BackgroundColor3 = VORTEX_DIM}):Play()
        end
    end
    
    clickBtn.MouseButton1Click:Connect(function()
        local newState = not isOn
        updateUI(newState)
        if onToggle then onToggle(newState) end
    end)
    
    return {update = updateUI, getState = function() return isOn end, statusText = statusText}
end

-- ============================================================
-- UI - VORTEX THEME
-- ============================================================
pcall(function()
    for _, old in ipairs(LocalPlayer:WaitForChild("PlayerGui"):GetChildren()) do
        if old.Name == "VortexAntiBat" then old:Destroy() end
    end
end)

local VortexAntiBat = Instance.new("ScreenGui")
VortexAntiBat.Name = "VortexAntiBat"
VortexAntiBat.ResetOnSpawn = false
VortexAntiBat.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Name = "Frame"
Frame.ClipsDescendants = true
Frame.Position = UDim2.new(0.04,0,0.25,0)
Frame.Size = UDim2.new(0,220,0,240)
Frame.BackgroundColor3 = VORTEX_DARKER
Frame.BorderSizePixel = 0
Frame.Parent = VortexAntiBat

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0,18)
UICorner.Parent = Frame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = VORTEX_RED
UIStroke.Thickness = 1.5
UIStroke.Transparency = 0.3
UIStroke.Parent = Frame

local dragging, dragStart, startPos
Frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position
        local conn
        conn = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                conn:Disconnect()
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1,0,0,38)
Header.BackgroundColor3 = VORTEX_DARK
Header.BorderSizePixel = 0
Header.Parent = Frame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0,18)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,-16,1,0)
Title.Position = UDim2.new(0,14,0,0)
Title.BackgroundTransparency = 1
Title.Text = "🌀 Vortex Anti Bat"
Title.TextColor3 = VORTEX_WHITE
Title.TextSize = 12
Title.Font = Enum.Font.GothamBlack
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Version = Instance.new("Frame")
Version.Size = UDim2.new(0,28,0,14)
Version.Position = UDim2.new(1,-36,0.5,-7)
Version.BackgroundColor3 = VORTEX_DARKER
Version.BorderSizePixel = 0
Version.Parent = Header

local VersionCorner = Instance.new("UICorner")
VersionCorner.CornerRadius = UDim.new(0,7)
VersionCorner.Parent = Version

local VersionText = Instance.new("TextLabel")
VersionText.Size = UDim2.new(1,0,1,0)
VersionText.BackgroundTransparency = 1
VersionText.Text = "v3"
VersionText.TextColor3 = VORTEX_DIM
VersionText.TextSize = 7
VersionText.Font = Enum.Font.GothamBold
VersionText.Parent = Version

local Separator = Instance.new("Frame")
Separator.Position = UDim2.new(0,12,0,38)
Separator.Size = UDim2.new(1,-24,0,1)
Separator.BackgroundColor3 = VORTEX_RED
Separator.BackgroundTransparency = 0.3
Separator.BorderSizePixel = 0
Separator.Parent = Frame

local antiBatToggle = createToggle(Frame, "Anti Bat", 46, function(state)
    AntiBatEnabled = state
    if state then 
        startAntiBat() 
        startAntiRagdoll()
        startHitCancel()
    else 
        stopAntiBat() 
        stopAntiRagdoll()
        stopHitCancel()
    end
end)

local KeyRow = Instance.new("Frame")
KeyRow.Position = UDim2.new(0,10,0,100)
KeyRow.Size = UDim2.new(1,-20,0,38)
KeyRow.BackgroundColor3 = VORTEX_DARKER
KeyRow.BorderSizePixel = 0
KeyRow.Parent = Frame

local KeyCorner = Instance.new("UICorner")
KeyCorner.CornerRadius = UDim.new(0,10)
KeyCorner.Parent = KeyRow

local KeyStroke = Instance.new("UIStroke")
KeyStroke.Color = VORTEX_RED_DARK
KeyStroke.Transparency = 0.3
KeyStroke.Parent = KeyRow

local KeyLabel = Instance.new("TextLabel")
KeyLabel.Size = UDim2.new(0.5,0,1,0)
KeyLabel.Position = UDim2.new(0,10,0,0)
KeyLabel.BackgroundTransparency = 1
KeyLabel.Text = "Keybind"
KeyLabel.TextColor3 = VORTEX_WHITE
KeyLabel.TextSize = 10
KeyLabel.Font = Enum.Font.GothamBold
KeyLabel.TextXAlignment = Enum.TextXAlignment.Left
KeyLabel.Parent = KeyRow

local KeyButton = Instance.new("TextButton")
KeyButton.Size = UDim2.new(0,55,0,22)
KeyButton.Position = UDim2.new(1,-63,0.5,-11)
KeyButton.BackgroundColor3 = VORTEX_DARKER
KeyButton.BorderSizePixel = 0
KeyButton.Text = "O"
KeyButton.TextColor3 = VORTEX_WHITE
KeyButton.TextSize = 8
KeyButton.Font = Enum.Font.GothamBold
KeyButton.Parent = KeyRow

local KeyButtonCorner = Instance.new("UICorner")
KeyButtonCorner.CornerRadius = UDim.new(0,5)
KeyButtonCorner.Parent = KeyButton

local KeyButtonStroke = Instance.new("UIStroke")
KeyButtonStroke.Color = VORTEX_RED_DARK
KeyButtonStroke.Transparency = 0.3
KeyButtonStroke.Parent = KeyButton

local SaveRow = Instance.new("Frame")
SaveRow.Position = UDim2.new(0,10,0,144)
SaveRow.Size = UDim2.new(1,-20,0,28)
SaveRow.BackgroundTransparency = 1
SaveRow.Parent = Frame

local SaveButton = Instance.new("TextButton")
SaveButton.Size = UDim2.new(1,0,0,28)
SaveButton.Position = UDim2.new(0,0,0,0)
SaveButton.BackgroundColor3 = VORTEX_RED
SaveButton.BorderSizePixel = 0
SaveButton.Text = "💾 Save Config"
SaveButton.TextColor3 = VORTEX_WHITE
SaveButton.TextSize = 9
SaveButton.Font = Enum.Font.GothamBold
SaveButton.Parent = SaveRow

local SaveCorner = Instance.new("UICorner")
SaveCorner.CornerRadius = UDim.new(0,6)
SaveCorner.Parent = SaveButton

-- ============================================================
-- KEYBIND SYSTEM
-- ============================================================
KeyButton.MouseButton1Click:Connect(function()
    if WaitingForKeybind then return end
    WaitingForKeybind = true
    KeyButton.Text = "..."
end)

SaveButton.MouseButton1Click:Connect(function()
    saveKeybind()
    if writefile then
        pcall(function() writefile(stateFile, tostring(AntiBatEnabled)) end)
    end
    SaveButton.Text = "✅ Saved!"
    task.wait(0.5)
    SaveButton.Text = "💾 Save Config"
end)

UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    
    if inp.KeyCode == Enum.KeyCode.LeftControl then
        isMinimized = not isMinimized
        if isMinimized then
            Frame.Size = UDim2.new(0,220,0,38)
            Frame.ClipsDescendants = false
        else
            Frame.Size = UDim2.new(0,220,0,240)
            Frame.ClipsDescendants = true
        end
    end
    
    if WaitingForKeybind and inp.UserInputType == Enum.UserInputType.Keyboard then
        CurrentKeybind = inp.KeyCode
        WaitingForKeybind = false
        KeyButton.Text = CurrentKeybind.Name
        saveKeybind()
    end
    
    if not WaitingForKeybind and inp.UserInputType == Enum.UserInputType.Keyboard then
        if inp.KeyCode == CurrentKeybind then
            local newState = not AntiBatEnabled
            antiBatToggle.update(newState)
            AntiBatEnabled = newState
            if newState then 
                startAntiBat() 
                startAntiRagdoll()
                startHitCancel()
            else 
                stopAntiBat() 
                stopAntiRagdoll()
                stopHitCancel()
            end
        end
    end
end)

-- ============================================================
-- CHARACTER RESPAWN
-- ============================================================
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
    Humanoid = newChar:WaitForChild("Humanoid")
    if AntiBatEnabled then
        task.wait(0.3)
        startAntiBat()
        startHitCancel()
    end
    task.wait(0.5)
    startAntiRagdoll()
end)

-- ============================================================
-- LOAD SAVED STATE
-- ============================================================
if isfile and isfile(stateFile) then
    pcall(function()
        local data = readfile(stateFile)
        if data == "true" then
            AntiBatEnabled = true
            startAntiBat()
            startHitCancel()
            antiBatToggle.update(true)
        end
    end)
end

startAntiRagdoll()
print("🌀 Vortex Anti Bat - Loaded!")
print("discord.gg/d7Yxt78KE")