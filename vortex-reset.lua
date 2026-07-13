print("leaked by slivin and eugene🥷")

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("VortexReset")
if old then old:Destroy() end

-- VORTEX COLORS - BLACK & WHITE ONLY
local WHITE = Color3.fromRGB(255, 255, 255)
local GREY = Color3.fromRGB(180, 180, 180)
local DARK = Color3.fromRGB(5, 5, 7)
local DARKER = Color3.fromRGB(9, 9, 13)

--// Save Config
local CONFIG_FILE = "VortexReset_Config.json"

local _vamp_isfile = isfile or (syn and syn.isfile) or function(path)
    local ok, result = pcall(function()
        return readfile(path)
    end)
    return ok and result ~= nil
end

local _vamp_readfile = readfile or (syn and syn.readfile)
local _vamp_writefile = writefile or (syn and syn.writefile)

local canSaveConfig = type(_vamp_readfile) == "function" and type(_vamp_writefile) == "function"

local savedConfig = {}

local function udim2ToTable(u)
    return {
        xs = u.X.Scale,
        xo = u.X.Offset,
        ys = u.Y.Scale,
        yo = u.Y.Offset
    }
end

local function tableToUDim2(t, fallback)
    if type(t) == "table" then
        return UDim2.new(
            tonumber(t.xs) or fallback.X.Scale,
            tonumber(t.xo) or fallback.X.Offset,
            tonumber(t.ys) or fallback.Y.Scale,
            tonumber(t.yo) or fallback.Y.Offset
        )
    end
    return fallback
end

local function loadVortexConfig()
    if not canSaveConfig then return end
    if not _vamp_isfile(CONFIG_FILE) then return end

    local ok, data = pcall(function()
        return HttpService:JSONDecode(_vamp_readfile(CONFIG_FILE))
    end)

    if ok and type(data) == "table" then
        savedConfig = data
    end
end

local function saveVortexConfig()
    if not canSaveConfig then return end
    pcall(function()
        _vamp_writefile(CONFIG_FILE, HttpService:JSONEncode(savedConfig))
    end)
end

loadVortexConfig()

--// Vortex Insta Reset Logic
_G.VortexResetRemote = _G.VortexResetRemote or nil
_G.VortexResetGuid = _G.VortexResetGuid or "f888ee6e-c86d-46e1-93d7-0639d6635d42"

pcall(function()
    if not _G.VortexResetHooked and hookfunction and newcclosure then
        _G.VortexResetHooked = true

        local oldFire
        oldFire = hookfunction(Instance.new("RemoteEvent").FireServer, newcclosure(function(self, ...)
            if not _G.VortexResetRemote
                and typeof(self) == "Instance"
                and self:IsA("RemoteEvent")
                and self.Name:sub(1, 3) == "RE/" then
                _G.VortexResetRemote = self
            end
            return oldFire(self, ...)
        end))
    end
end)

local function findVortexResetRemote()
    if _G.VortexResetRemote then
        return _G.VortexResetRemote
    end

    for _, desc in ipairs(ReplicatedStorage:GetDescendants()) do
        if desc:IsA("RemoteEvent") and desc.Name:sub(1, 3) == "RE/" then
            _G.VortexResetRemote = desc
            break
        end
    end

    return _G.VortexResetRemote
end

local function vortexInstaReset()
    local remote = findVortexResetRemote()
    if not remote then
        return false
    end

    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    if humanoid and humanoid.Health <= 0 then
        pcall(function()
            remote:FireServer(_G.VortexResetGuid, player, "balloon")
        end)
        return true
    end

    local resetDetected = false
    local resetConns = {}

    if humanoid then
        table.insert(resetConns, humanoid.Died:Connect(function()
            resetDetected = true
        end))

        table.insert(resetConns, humanoid:GetPropertyChangedSignal("Health"):Connect(function()
            if humanoid.Health <= 0 then
                resetDetected = true
            end
        end))
    end

    if character then
        table.insert(resetConns, character.AncestryChanged:Connect(function(_, parent)
            if not parent then
                resetDetected = true
            end
        end))
    end

    task.spawn(function()
        for _ = 1, 10 do
            if resetDetected then
                break
            end

            pcall(function()
                remote:FireServer(_G.VortexResetGuid, player, "balloon")
            end)

            task.wait(0.05)
        end

        for _, conn in ipairs(resetConns) do
            pcall(function()
                conn:Disconnect()
            end)
        end
    end)

    return true
end

_G.VortexInstaReset = vortexInstaReset

--// GUI
local gui = Instance.new("ScreenGui")
gui.Name = "VortexReset"
gui.ResetOnSpawn = false
gui.DisplayOrder = 999
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local isMobileMode = savedConfig.mobileMode == true

local function makeCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = parent
    return c
end

local function makeStroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = thickness
    s.Transparency = transparency or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

-- MAIN FRAME - BLACK BACKGROUND
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 190, 0, 120)
main.Position = tableToUDim2(savedConfig.mainPosition, UDim2.new(0.5, -95, 0.5, -60))
main.BackgroundColor3 = DARK
main.BackgroundTransparency = 0
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.ClipsDescendants = true
main.Parent = gui

makeCorner(main, 9)
makeStroke(main, Color3.fromRGB(30, 30, 35), 1.2, 0)

-- TITLE - WHITE TEXT
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -70, 0, 14)
title.Position = UDim2.new(0, 10, 0, 14)
title.BackgroundTransparency = 1
title.Text = "VORTEX RESET"
title.TextColor3 = WHITE
title.Font = Enum.Font.GothamBlack
title.TextSize = 9
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
title.TextStrokeTransparency = 0.3
title.ZIndex = 11
title.Parent = main

-- SUBTITLE - GREY TEXT
local subtitle = Instance.new("TextLabel")
subtitle.Name = "Subtitle"
subtitle.Size = UDim2.new(1, -70, 0, 8)
subtitle.Position = UDim2.new(0, 10, 0, 26)
subtitle.BackgroundTransparency = 1
subtitle.Text = "instant reset"
subtitle.TextColor3 = GREY
subtitle.Font = Enum.Font.GothamBold
subtitle.TextSize = 5
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
subtitle.TextStrokeTransparency = 0.7
subtitle.ZIndex = 11
subtitle.Parent = main

-- MODE BUTTON
local modeButton = Instance.new("TextButton")
modeButton.Name = "ModeButton"
modeButton.Size = UDim2.new(0, 49, 0, 22)
modeButton.Position = UDim2.new(1, -58, 0, 8)
modeButton.BackgroundColor3 = DARKER
modeButton.BackgroundTransparency = 0
modeButton.BorderSizePixel = 0
modeButton.AutoButtonColor = false
modeButton.Text = "PC"
modeButton.TextColor3 = WHITE
modeButton.Font = Enum.Font.GothamBlack
modeButton.TextSize = 8
modeButton.ZIndex = 12
modeButton.Parent = main

makeCorner(modeButton, 8)
makeStroke(modeButton, Color3.fromRGB(40, 40, 45), 0.8, 0)

-- KEYBIND CARD
local keyCard = Instance.new("Frame")
keyCard.Name = "KeybindCard"
keyCard.Size = UDim2.new(1, -20, 0, 43)
keyCard.Position = UDim2.new(0, 10, 0, 52)
keyCard.BackgroundColor3 = DARKER
keyCard.BackgroundTransparency = 0
keyCard.BorderSizePixel = 0
keyCard.ZIndex = 10
keyCard.Parent = main

makeCorner(keyCard, 10)
makeStroke(keyCard, Color3.fromRGB(40, 40, 45), 0.8, 0)

local keyTitle = Instance.new("TextLabel")
keyTitle.Name = "KeyTitle"
keyTitle.Size = UDim2.new(0, 70, 0, 10)
keyTitle.Position = UDim2.new(0, 10, 0, 8)
keyTitle.BackgroundTransparency = 1
keyTitle.Text = "KEYBIND"
keyTitle.TextColor3 = GREY
keyTitle.Font = Enum.Font.GothamBlack
keyTitle.TextSize = 6
keyTitle.TextXAlignment = Enum.TextXAlignment.Left
keyTitle.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
keyTitle.TextStrokeTransparency = 0.8
keyTitle.ZIndex = 11
keyTitle.Parent = keyCard

-- STATUS DOT - WHITE
local dot = Instance.new("Frame")
dot.Name = "Dot"
dot.Size = UDim2.new(0, 5, 0, 5)
dot.Position = UDim2.new(0, 10, 0, 24)
dot.BackgroundColor3 = WHITE
dot.BackgroundTransparency = 0
dot.BorderSizePixel = 0
dot.ZIndex = 11
dot.Parent = keyCard
makeCorner(dot, 99)
makeStroke(dot, Color3.fromRGB(0, 0, 0), 1, 0.65)

local ready = Instance.new("TextLabel")
ready.Name = "Ready"
ready.Size = UDim2.new(0, 80, 0, 10)
ready.Position = UDim2.new(0, 18, 0, 21)
ready.BackgroundTransparency = 1
ready.Text = "Ready"
ready.TextColor3 = GREY
ready.Font = Enum.Font.Gotham
ready.TextSize = 6
ready.TextXAlignment = Enum.TextXAlignment.Left
ready.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
ready.TextStrokeTransparency = 0.5
ready.ZIndex = 11
ready.Parent = keyCard

local rButton = Instance.new("TextButton")
rButton.Name = "RButton"
rButton.Size = UDim2.new(0, 50, 0, 20)
rButton.Position = UDim2.new(1, -60, 0.5, -10)
rButton.BackgroundColor3 = DARKER
rButton.BackgroundTransparency = 0
rButton.BorderSizePixel = 0
rButton.AutoButtonColor = false
rButton.Text = "R"
rButton.TextColor3 = WHITE
rButton.Font = Enum.Font.GothamBlack
rButton.TextSize = 9
rButton.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
rButton.TextStrokeTransparency = 0.5
rButton.ZIndex = 12
rButton.Parent = keyCard
makeCorner(rButton, 7)
makeStroke(rButton, Color3.fromRGB(40, 40, 45), 0.7, 0)

-- TAP CARD (MOBILE)
local tapCard = Instance.new("TextButton")
tapCard.Name = "TapToReset"
tapCard.Size = UDim2.new(1, -30, 0, 36)
tapCard.Position = UDim2.new(0, 15, 0, 58)
tapCard.BackgroundColor3 = DARKER
tapCard.BackgroundTransparency = 0
tapCard.BorderSizePixel = 0
tapCard.AutoButtonColor = false
tapCard.Text = "TAP TO RESET"
tapCard.TextColor3 = WHITE
tapCard.Font = Enum.Font.GothamBlack
tapCard.TextSize = 9
tapCard.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
tapCard.TextStrokeTransparency = 0.5
tapCard.ZIndex = 13
tapCard.Visible = false
tapCard.Parent = main
makeCorner(tapCard, 9)
makeStroke(tapCard, Color3.fromRGB(40, 40, 45), 0.8, 0)

-- FOOTER - UPDATED DISCORD
local footer = Instance.new("TextLabel")
footer.Name = "Footer"
footer.Size = UDim2.new(1, -20, 0, 10)
footer.Position = UDim2.new(0, 10, 1, -16)
footer.BackgroundTransparency = 1
footer.Text = "discord.gg/d7Yxt78KE"
footer.TextColor3 = GREY
footer.Font = Enum.Font.GothamBold
footer.TextSize = 4
footer.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
footer.TextStrokeTransparency = 0.7
footer.TextXAlignment = Enum.TextXAlignment.Center
footer.ZIndex = 11
footer.Parent = main

-- SAVE POSITION
local savePosDebounce = false
main:GetPropertyChangedSignal("Position"):Connect(function()
    savedConfig.mainPosition = udim2ToTable(main.Position)
    if savePosDebounce then return end
    savePosDebounce = true
    task.delay(0.25, function()
        savePosDebounce = false
        saveVortexConfig()
    end)
end)

local function setMode(mobile)
    isMobileMode = mobile

    if mobile then
        modeButton.Text = "MOB"
        keyCard.Visible = false
        tapCard.Visible = true
    else
        modeButton.Text = "PC"
        keyCard.Visible = true
        tapCard.Visible = false
    end

    savedConfig.mobileMode = isMobileMode
    savedConfig.mainPosition = udim2ToTable(main.Position)
    saveVortexConfig()
end

local resetDebounce = false

local function pressEffect()
    if resetDebounce then return end
    resetDebounce = true

    vortexInstaReset()

    if not isMobileMode then
        ready.Text = "Reseting..."
        ready.TextColor3 = WHITE
        dot.BackgroundColor3 = WHITE
        rButton.TextColor3 = WHITE
    else
        tapCard.Text = "RESETING..."
        tapCard.TextColor3 = WHITE
    end

    task.delay(0.6, function()
        if ready then
            ready.Text = "Ready"
            ready.TextColor3 = GREY
        end
        if dot then
            dot.BackgroundColor3 = WHITE
        end
        if rButton then
            rButton.TextColor3 = WHITE
        end
        if tapCard then
            tapCard.Text = "TAP TO RESET"
            tapCard.TextColor3 = WHITE
        end
        resetDebounce = false
    end)
end

modeButton.MouseButton1Click:Connect(function()
    setMode(not isMobileMode)
end)

rButton.MouseButton1Click:Connect(pressEffect)
tapCard.MouseButton1Click:Connect(pressEffect)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if UserInputService:GetFocusedTextBox() then return end

    if input.KeyCode == Enum.KeyCode.R and not isMobileMode then
        pressEffect()
    end
end)

setMode(isMobileMode)

print("Vortex Reset loaded - discord.gg/d7Yxt78KE")
