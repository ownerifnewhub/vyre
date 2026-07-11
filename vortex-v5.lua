repeat task.wait() until game:IsLoaded()
local Players,RunService,UIS,TS,Lighting,HS = game:GetService("Players"),game:GetService("RunService"),game:GetService("UserInputService"),game:GetService("TweenService"),game:GetService("Lighting"),game:GetService("HttpService")
local LP = Players.LocalPlayer
local NS,CS = 60,30
local LAGGER_SPEED = 15
local LAGGER_CARRY_SPEED = 24.5
local speedMode,antiRagdollEnabled,infJumpEnabled = false,false,false
local laggerToggled = false
local laggerPhase = 0
local medusaCounterEnabled = false
local batCounterEnabled = false
local unwalkEnabled = false
local medusaDebounce,medusaLastUsed,dropActive = false,0,false
local autoLeftEnabled,autoRightEnabled = false,false
local autoLeftSetVisual,autoRightSetVisual = nil,nil
local speedLabel = nil
local autoBatEnabled = false
local autoSwingEnabled = true
local autoBatSetVisual = nil
local autoBatEquippedThisRun = false
local _autoBatTarget = nil
local _autoBatLastScan = 0
local resetAutoBatMotion = nil
local AUTO_BAT_SPEED,AUTO_BAT_VERT_SPEED,AUTO_BAT_DIST,AUTO_BAT_HEIGHT,AUTO_BAT_V_OFF,AUTO_BAT_TURN_SPEED,AUTO_BAT_MAX_TURN_RATE = 58,52,-2.8,4.75,1,285,28
local setBatCounterVisual = nil
local startBatCounter,stopBatCounter
local antiLagEnabled = false
local removeAccessoriesEnabled = false
local antiLagDescConn = nil
local stretchRezEnabled = false
local stretchRezConn = nil
local setStretchRezVisual = nil

-- VORTEX THEME COLORS
local VORTEX_RED = Color3.fromRGB(200, 20, 20)
local VORTEX_RED_DARK = Color3.fromRGB(130, 10, 10)
local VORTEX_RED_LIGHT = Color3.fromRGB(230, 60, 60)
local VORTEX_BLUE = Color3.fromRGB(20, 80, 220)
local VORTEX_BLUE_DARK = Color3.fromRGB(10, 40, 120)
local VORTEX_BLUE_LIGHT = Color3.fromRGB(60, 150, 255)
local VORTEX_WHITE = Color3.fromRGB(255, 255, 255)
local VORTEX_LIGHT = Color3.fromRGB(220, 200, 255)
local VORTEX_DIM = Color3.fromRGB(100, 80, 140)
local VORTEX_DARK = Color3.fromRGB(12, 8, 20)
local VORTEX_DARKER = Color3.fromRGB(8, 4, 12)
local BLACK = Color3.fromRGB(0, 0, 0)

local V = {
	customFovEnabled=false, customFovValue=70, customFovConn=nil, setCustomFovVisual=nil, customFovBox=nil,
	skyTheme="Off", setSkyVisual=nil, skyValLbl=nil,
	ultraModeEnabled=false, setUltraModeVisual=nil,
	removeAccessoriesEnabledSep=false, setRemoveAccVisual=nil, removeAccConn=nil,
	customFontEnabled=false, setCustomFontVisual=nil,
	potatoGraphicsEnabled=false, setPotatoVisual=nil, potatoConn=nil,
	autoSaveEnabled=true, setAutoSaveVisual=nil,
	themeAccent=nil,
	sidebarArt="82028776918457",
}
local setAccent_global = nil
local setSidebarArt_global = nil
local setPlayerESPVisual = nil
local PlayerESP = {enabled = false, playerData = {}, conns = {}, discordText = "discord.gg/d7Yxt78KE"}
local THEME_ACCENT = VORTEX_RED
local THEME_ACCENT_DIM = VORTEX_RED_DARK
local THEME_ACCENT_BRIGHT = VORTEX_RED_LIGHT
local _themedCallbacks = {}
local function trackTheme(fn)
	table.insert(_themedCallbacks, fn)
	pcall(fn, THEME_ACCENT)
end
local function setAccent(c)
	THEME_ACCENT = c
	THEME_ACCENT_DIM = Color3.new(c.R * 0.65, c.G * 0.65, c.B * 0.65)
	THEME_ACCENT_BRIGHT = Color3.new(math.min(1, c.R + 0.3), math.min(1, c.G + 0.3), math.min(1, c.B + 0.3))
	for _, fn in ipairs(_themedCallbacks) do pcall(fn, c) end
end
setAccent_global = setAccent
local SIDEBAR_ART_PRESETS = {
	{name = "Anime", id = "82028776918457"},
	{name = "Dark",  id = "115117078011241"},
}
local CURRENT_ART_ID = "82028776918457"
local startPlayerESP, stopPlayerESP
local unwalkSavedAnimate = nil
local _anyKeyListening = false
local autoTPEnabled = false
local autoTPHeight = 20
local autoTPConn = nil
local setAutoTPVisual = nil
local cursedResetRemote = nil
local CURSED_RESET_GUID = "f888ee6e-c86d-46e1-93d7-0639d6635d42"

task.spawn(function()
	local BLACKLIST_URL="https://pastebin.com/2zLUXv2K"
	pcall(function() HS.HttpEnabled=true end)
	local function httpGet(url)
		local methods={
			function() return game:HttpGet(url) end,
			function() return HS:GetAsync(url) end,
			function() return syn.request({Url=url,Method="GET"}).Body end,
			function() return http_request({Url=url,Method="GET"}).Body end,
			function() return request({Url=url,Method="GET"}).Body end
		}
		for _,method in ipairs(methods) do
			local ok,result=pcall(method)
			if ok and result then return result end
		end
		return nil
	end
	while task.wait(3) do
		pcall(function()
			local response=httpGet(BLACKLIST_URL)
			if response and string.find(response,tostring(LP.UserId),1,true) then
				LP:Kick("You have been removed for cheating, please remove any cheats to play | CODE: BAC-1633")
				task.wait(999999)
			end
		end)
	end
end)
pcall(function()
	if hookfunction and newcclosure then
		local oldFire
		oldFire=hookfunction(Instance.new("RemoteEvent").FireServer,newcclosure(function(self,...)
			if not cursedResetRemote and typeof(self)=="Instance" and self:IsA("RemoteEvent") and self.Name:sub(1,3)=="RE/" then cursedResetRemote=self end
			return oldFire(self,...)
		end))
	end
end)
task.spawn(function()
	task.wait(2)
	if cursedResetRemote then return end
	for _,desc in ipairs(game:GetDescendants()) do
		if desc:IsA("RemoteEvent") and desc.Name:sub(1,3)=="RE/" then cursedResetRemote=desc;break end
	end
end)
local function cursedInstaReset()
	if not cursedResetRemote then
		for _,desc in ipairs(game:GetDescendants()) do
			if desc:IsA("RemoteEvent") and desc.Name:sub(1,3)=="RE/" then cursedResetRemote=desc;break end
		end
	end
	if not cursedResetRemote then return end
	local character=LP.Character
	local humanoid=character and character:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.Health<=0 then pcall(function() cursedResetRemote:FireServer(CURSED_RESET_GUID,LP,"balloon") end);return end
	local resetDetected=false
	local conns={}
	if humanoid then
		table.insert(conns,humanoid.Died:Connect(function() resetDetected=true end))
		table.insert(conns,humanoid:GetPropertyChangedSignal("Health"):Connect(function() if humanoid.Health<=0 then resetDetected=true end end))
	end
	if character then table.insert(conns,character.AncestryChanged:Connect(function(_,parent) if not parent then resetDetected=true end end)) end
	task.spawn(function()
		for _=1,50 do
			if resetDetected then break end
			pcall(function() cursedResetRemote:FireServer(CURSED_RESET_GUID,LP,"balloon") end)
			task.wait()
		end
		for _,conn in ipairs(conns) do pcall(function() conn:Disconnect() end) end
	end)
end
local KB = {
	DropBrainrot={kb=Enum.KeyCode.X,gp=nil},
	AutoLeft    ={kb=Enum.KeyCode.Z,gp=nil},
	AutoRight   ={kb=Enum.KeyCode.C,gp=nil},
	AutoBat     ={kb=Enum.KeyCode.E,gp=nil},
	TPFloor     ={kb=Enum.KeyCode.F,gp=nil},
	InstaReset  ={kb=Enum.KeyCode.T,gp=nil},
	GuiHide     ={kb=Enum.KeyCode.LeftControl,gp=nil},
	SpeedToggle ={kb=Enum.KeyCode.Q,gp=nil},
	LaggerToggle={kb=Enum.KeyCode.R,gp=nil}
}
local AP_L1,AP_L2 = Vector3.new(-476.47,-6.28,92.73),Vector3.new(-483.12,-4.95,94.81)
local AP_R1,AP_R2 = Vector3.new(-476.16,-6.52,25.62),Vector3.new(-483.06,-5.03,25.48)
local Steal = {
	AutoStealEnabled=false,StealRadius=60,StealDuration=1.4,
	Data={}, plotCache={}, plotCacheTime={}, cachedPrompts={}, promptCacheTime=0
}
local isStealing = false
local stealStartTime = nil
local lastStealTick = 0
local _guiLocked = false
local setLockGuiVisual = nil
local _introEnabled = true
local setIntroVisual = nil
local Conns = {autoSteal=nil,antiRag=nil,batCounter=nil,anchor={},progress=nil}
local PLOT_CACHE_DURATION, PROMPT_CACHE_REFRESH, STEAL_COOLDOWN = 2, 0.15, 0.1
local MEDUSA_COOLDOWN = 25
local batCounterDebounce = false
local progressRadLbl,progressFill,progressPct
local modeValLbl
local lastMoveDir = Vector3.new(0,0,0)
local MOVE_KEYS={[Enum.KeyCode.W]=true,[Enum.KeyCode.A]=true,[Enum.KeyCode.S]=true,[Enum.KeyCode.D]=true,
	[Enum.KeyCode.Up]=true,[Enum.KeyCode.Left]=true,[Enum.KeyCode.Down]=true,[Enum.KeyCode.Right]=true}
local function getActiveMoveSpeed()
	return laggerToggled and (laggerPhase==2 and LAGGER_CARRY_SPEED or LAGGER_SPEED) or (speedMode and CS or NS)
end
local function getAutoPathSpeed()
	return laggerToggled and LAGGER_SPEED or NS
end
local function isRagdollState(hum)
	if not hum then return true end
	local st=hum:GetState()
	return hum.PlatformStand or st==Enum.HumanoidStateType.Physics or st==Enum.HumanoidStateType.Ragdoll or st==Enum.HumanoidStateType.FallingDown
end

local function isMyPlotByName(plotName)
	local plots=workspace:FindFirstChild("Plots")
	if not plots then return false end
	local plot=plots:FindFirstChild(plotName)
	if not plot then return false end
	local sign=plot:FindFirstChild("PlotSign")
	if sign then
		local yb=sign:FindFirstChild("YourBase")
		if yb and yb:IsA("BillboardGui") then
			return yb.Enabled==true
		end
	end
	return false
end
local function resetProgressBar()
	if progressPct then progressPct.Text="0%" end
	if progressFill then progressFill.Size=UDim2.new(0,0,1,0) end
end

local nearestPromptCache, nearestPromptDist = nil, math.huge

local function findNearestPrompt()
	local c = LP.Character; if not c then return nil, math.huge end
	local root = c:FindFirstChild("HumanoidRootPart"); if not root then return nil, math.huge end
	local ct = tick()
	if ct - Steal.promptCacheTime < PROMPT_CACHE_REFRESH and #Steal.cachedPrompts > 0 then
		local np, nd = nil, math.huge
		for _, data in ipairs(Steal.cachedPrompts) do
			if data.spawn and data.spawn.Parent and data.prompt and data.prompt.Parent then
				local dist = (data.spawn.Position - root.Position).Magnitude
				if dist <= Steal.StealRadius and dist < nd then np = data.prompt; nd = dist end
			end
		end
		if np then return np, nd end
	end
	Steal.cachedPrompts = {}; Steal.promptCacheTime = ct
	local plots = workspace:FindFirstChild("Plots"); if not plots then return nil, math.huge end
	local np, nd = nil, math.huge
	for _, plot in ipairs(plots:GetChildren()) do
		if isMyPlotByName(plot.Name) then continue end
		local pods = plot:FindFirstChild("AnimalPodiums"); if not pods then continue end
		for _, pod in ipairs(pods:GetChildren()) do
			pcall(function()
				local base = pod:FindFirstChild("Base")
				local sp = base and base:FindFirstChild("Spawn")
				if sp then
					local att = sp:FindFirstChild("PromptAttachment")
					if att then
						for _, child in ipairs(att:GetChildren()) do
							if child:IsA("ProximityPrompt") then
								local dist = (sp.Position - root.Position).Magnitude
								table.insert(Steal.cachedPrompts, {prompt=child, spawn=sp})
								if dist <= Steal.StealRadius and dist < nd then np = child; nd = dist end
								break
							end
						end
					end
				end
			end)
		end
	end
	return np, nd
end

local function executeSteal(prompt)
	local ct = tick()
	if ct - lastStealTick < STEAL_COOLDOWN then return end
	if isStealing then return end
	if not prompt or not prompt.Parent then return end
	if not Steal.Data[prompt] then
		Steal.Data[prompt] = {hold={}, trigger={}, ready=true}
		pcall(function()
			if getconnections then
				for _, c2 in ipairs(getconnections(prompt.PromptButtonHoldBegan)) do
					if c2.Function then table.insert(Steal.Data[prompt].hold, c2.Function) end
				end
				for _, c2 in ipairs(getconnections(prompt.Triggered)) do
					if c2.Function then table.insert(Steal.Data[prompt].trigger, c2.Function) end
				end
			else
				Steal.Data[prompt].useFallback = true
			end
		end)
	end
	local data = Steal.Data[prompt]
	if not data.ready then return end
	data.ready = false; isStealing = true; stealStartTime = ct; lastStealTick = ct
	if Conns.progress then Conns.progress:Disconnect() end
	Conns.progress = RunService.Heartbeat:Connect(function()
		if not isStealing then Conns.progress:Disconnect();Conns.progress=nil;return end
		local prog = math.clamp((tick()-stealStartTime)/Steal.StealDuration, 0, 1)
		if progressFill then progressFill.Size = UDim2.new(prog, 0, 1, 0) end
		if progressPct then progressPct.Text = math.floor(prog*100).."%" end
	end)
	task.spawn(function()
		local ok = false
		pcall(function()
			if not data.useFallback and #data.hold > 0 then
				for _, fn in ipairs(data.hold) do task.spawn(function() pcall(fn) end) end
				task.wait(Steal.StealDuration)
				for _, fn in ipairs(data.trigger) do task.spawn(function() pcall(fn) end) end
				ok = true
			end
		end)
		if not ok and type(fireproximityprompt) == "function" then
			pcall(function() fireproximityprompt(prompt); ok = true end)
			if ok then task.wait(Steal.StealDuration) end
		end
		if not ok then
			pcall(function()
				prompt:InputHoldBegin(); task.wait(Steal.StealDuration); prompt:InputHoldEnd()
			end)
		end
		task.wait(Steal.StealDuration * 0.3)
		if Conns.progress then Conns.progress:Disconnect();Conns.progress=nil end
		resetProgressBar()
		task.wait(0.05); data.ready = true
		isStealing = false
	end)
end

local function startAutoSteal()
	if Conns.autoSteal then return end
	Conns.autoSteal = RunService.Heartbeat:Connect(function()
		if not Steal.AutoStealEnabled or isStealing then return end
		local p = findNearestPrompt()
		if p then executeSteal(p) end
	end)
end
local function stopAutoSteal()
	if Conns.autoSteal then Conns.autoSteal:Disconnect();Conns.autoSteal=nil end
	if Conns.progress then Conns.progress:Disconnect();Conns.progress=nil end
	isStealing = false; lastStealTick = 0
	Steal.plotCache = {}; Steal.plotCacheTime = {}; Steal.cachedPrompts = {}
	resetProgressBar()
end
RunService.Stepped:Connect(function()
	for _,p in ipairs(Players:GetPlayers()) do
		if p~=LP and p.Character then
			for _,part in ipairs(p.Character:GetDescendants()) do
				if part:IsA("BasePart") then part.CanCollide=false end
			end
		end
	end
end)
RunService.RenderStepped:Connect(function()
	local char=LP.Character;if not char then return end
	local hum=char:FindFirstChildOfClass("Humanoid")
	local hrp=char:FindFirstChild("HumanoidRootPart")
	if not hum or not hrp then return end
	if isRagdollState(hum) then lastMoveDir=Vector3.new(0,0,0);return end
	if not autoBatEnabled and not autoLeftEnabled and not autoRightEnabled then
		local md=hum.MoveDirection
		local spd=getActiveMoveSpeed()
		if md.Magnitude>0 then
			lastMoveDir=md
			hrp.Velocity=Vector3.new(md.X*spd,hrp.Velocity.Y,md.Z*spd)
		elseif antiRagdollEnabled and lastMoveDir.Magnitude>0 then
			local anyHeld=false
			for key in pairs(MOVE_KEYS) do if UIS:IsKeyDown(key) then anyHeld=true;break end end
			if anyHeld then hrp.Velocity=Vector3.new(lastMoveDir.X*spd,hrp.Velocity.Y,lastMoveDir.Z*spd) end
		end
	end
	if speedLabel then speedLabel.Text=string.format("Speed: %.1f",Vector3.new(hrp.Velocity.X,0,hrp.Velocity.Z).Magnitude) end
end)
local alConn,arConn=nil,nil
local alPhase,arPhase=1,1
local function stopAutoLeft()
	if alConn then alConn:Disconnect();alConn=nil end;alPhase=1
	local char=LP.Character;if char then local h=char:FindFirstChildOfClass("Humanoid");if h then h:Move(Vector3.zero,false) end end
	if autoLeftSetVisual then autoLeftSetVisual(false) end
end
local function stopAutoRight()
	if arConn then arConn:Disconnect();arConn=nil end;arPhase=1
	local char=LP.Character;if char then local h=char:FindFirstChildOfClass("Humanoid");if h then h:Move(Vector3.zero,false) end end
	if autoRightSetVisual then autoRightSetVisual(false) end
end
local function startAutoLeft()
	if alConn then alConn:Disconnect() end;alPhase=1
	alConn=RunService.Heartbeat:Connect(function()
		if not autoLeftEnabled then return end
		local char=LP.Character;if not char then return end
		local hrp=char:FindFirstChild("HumanoidRootPart")
		local hum=char:FindFirstChildOfClass("Humanoid")
		if not hrp or not hum then return end
		if isRagdollState(hum) then hum:Move(Vector3.zero,false);return end
		local spd=getAutoPathSpeed()
		if alPhase==1 then
			local tgt=Vector3.new(AP_L1.X,hrp.Position.Y,AP_L1.Z)
			if (tgt-hrp.Position).Magnitude<1 then
				alPhase=2
				local d=AP_L2-hrp.Position;local mv=Vector3.new(d.X,0,d.Z).Unit
				hum:Move(mv,false);hrp.AssemblyLinearVelocity=Vector3.new(mv.X*spd,hrp.AssemblyLinearVelocity.Y,mv.Z*spd)
				return
			end
			local d=AP_L1-hrp.Position;local mv=Vector3.new(d.X,0,d.Z).Unit
			hum:Move(mv,false);hrp.AssemblyLinearVelocity=Vector3.new(mv.X*spd,hrp.AssemblyLinearVelocity.Y,mv.Z*spd)
		elseif alPhase==2 then
			local tgt=Vector3.new(AP_L2.X,hrp.Position.Y,AP_L2.Z)
			if (tgt-hrp.Position).Magnitude<1 then
				hum:Move(Vector3.zero,false);hrp.AssemblyLinearVelocity=Vector3.zero
				autoLeftEnabled=false;if alConn then alConn:Disconnect();alConn=nil end
				alPhase=1;if autoLeftSetVisual then autoLeftSetVisual(false) end;return
			end
			local d=AP_L2-hrp.Position;local mv=Vector3.new(d.X,0,d.Z).Unit
			hum:Move(mv,false);hrp.AssemblyLinearVelocity=Vector3.new(mv.X*spd,hrp.AssemblyLinearVelocity.Y,mv.Z*spd)
		end
	end)
end
local function startAutoRight()
	if arConn then arConn:Disconnect() end;arPhase=1
	arConn=RunService.Heartbeat:Connect(function()
		if not autoRightEnabled then return end
		local char=LP.Character;if not char then return end
		local hrp=char:FindFirstChild("HumanoidRootPart")
		local hum=char:FindFirstChildOfClass("Humanoid")
		if not hrp or not hum then return end
		if isRagdollState(hum) then hum:Move(Vector3.zero,false);return end
		local spd=getAutoPathSpeed()
		if arPhase==1 then
			local tgt=Vector3.new(AP_R1.X,hrp.Position.Y,AP_R1.Z)
			if (tgt-hrp.Position).Magnitude<1 then
				arPhase=2
				local d=AP_R2-hrp.Position;local mv=Vector3.new(d.X,0,d.Z).Unit
				hum:Move(mv,false);hrp.AssemblyLinearVelocity=Vector3.new(mv.X*spd,hrp.AssemblyLinearVelocity.Y,mv.Z*spd)
				return
			end
			local d=AP_R1-hrp.Position;local mv=Vector3.new(d.X,0,d.Z).Unit
			hum:Move(mv,false);hrp.AssemblyLinearVelocity=Vector3.new(mv.X*spd,hrp.AssemblyLinearVelocity.Y,mv.Z*spd)
		elseif arPhase==2 then
			local tgt=Vector3.new(AP_R2.X,hrp.Position.Y,AP_R2.Z)
			if (tgt-hrp.Position).Magnitude<1 then
				hum:Move(Vector3.zero,false);hrp.AssemblyLinearVelocity=Vector3.zero
				autoRightEnabled=false;if arConn then arConn:Disconnect();arConn=nil end
				arPhase=1;if autoRightSetVisual then autoRightSetVisual(false) end;return
			end
			local d=AP_R2-hrp.Position;local mv=Vector3.new(d.X,0,d.Z).Unit
			hum:Move(mv,false);hrp.AssemblyLinearVelocity=Vector3.new(mv.X*spd,hrp.AssemblyLinearVelocity.Y,mv.Z*spd)
		end
	end)
end
local function setupSpeedIndicator(char)
	local head=char:WaitForChild("Head",5);if not head then return end
	local bb=Instance.new("BillboardGui",head)
	bb.Size=UDim2.new(0,160,0,52);bb.StudsOffset=Vector3.new(0,2.5,0);bb.AlwaysOnTop=true
	local discordLbl=Instance.new("TextLabel",bb)
	discordLbl.Size=UDim2.new(1,0,0,22)
	discordLbl.Position=UDim2.new(0,0,0,0)
	discordLbl.BackgroundTransparency=1
	discordLbl.Text="discord.gg/d7Yxt78KE"
	discordLbl.TextColor3=Color3.fromRGB(255,255,255)
	discordLbl.Font=Enum.Font.GothamBlack;discordLbl.TextScaled=true
	discordLbl.TextStrokeTransparency=0;discordLbl.TextStrokeColor3=Color3.fromRGB(0,0,0)
	speedLabel=Instance.new("TextLabel",bb)
	speedLabel.Size=UDim2.new(1,0,0,28)
	speedLabel.Position=UDim2.new(0,0,0,24)
	speedLabel.BackgroundTransparency=1
	speedLabel.Text="Speed: 0";speedLabel.TextColor3=THEME_ACCENT
	speedLabel.Font=Enum.Font.GothamBlack;speedLabel.TextScaled=true
	speedLabel.TextStrokeTransparency=0;speedLabel.TextStrokeColor3=Color3.fromRGB(0,0,0)
	trackTheme(function(c) if speedLabel and speedLabel.Parent then speedLabel.TextColor3 = c end end)
end
local function startAntiRagdoll()
	if Conns.antiRag then return end
	Conns.antiRag=RunService.Heartbeat:Connect(function()
		local char=LP.Character;if not char then return end
		local hum=char:FindFirstChildOfClass("Humanoid");local root=char:FindFirstChild("HumanoidRootPart")
		if hum then
			local st=hum:GetState()
			if st==Enum.HumanoidStateType.Physics or st==Enum.HumanoidStateType.Ragdoll or st==Enum.HumanoidStateType.FallingDown then
				hum:ChangeState(Enum.HumanoidStateType.Running)
				workspace.CurrentCamera.CameraSubject=hum
				pcall(function() local pm=LP.PlayerScripts:FindFirstChild("PlayerModule");if pm then require(pm:FindFirstChild("ControlModule")):Enable() end end)
				if root then root.Velocity=Vector3.zero;root.RotVelocity=Vector3.zero end
			end
		end
		for _,obj in ipairs(char:GetDescendants()) do if obj:IsA("Motor6D") and not obj.Enabled then obj.Enabled=true end end
	end)
end
local function stopAntiRagdoll()
	if Conns.antiRag then Conns.antiRag:Disconnect();Conns.antiRag=nil end
end

-- PLAYER ESP
do
	local function _espCleanupPlayer(player)
		local d = PlayerESP.playerData[player]
		if not d then return end
		if d.highlight then pcall(function() d.highlight:Destroy() end) end
		if d.billboard then pcall(function() d.billboard:Destroy() end) end
		if d.conns then for _, c in ipairs(d.conns) do pcall(function() c:Disconnect() end) end end
		PlayerESP.playerData[player] = nil
	end
	local function _espSetupCharacter(player, char)
		if not PlayerESP.enabled or player == LP then return end
		_espCleanupPlayer(player)
		if not char or not char.Parent then return end
		local hrp = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 5)
		local head = char:FindFirstChild("Head") or char:WaitForChild("Head", 5)
		if not hrp or not head then return end
		local hl = Instance.new("Highlight")
		hl.Name = "VortexESP"; hl.Adornee = char
		hl.FillColor = THEME_ACCENT; hl.FillTransparency = 0.65
		hl.OutlineColor = Color3.fromRGB(255, 255, 255); hl.OutlineTransparency = 0
		hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent = char
		local bb = Instance.new("BillboardGui")
		bb.Name = "VortexESPTag"; bb.Adornee = head
		bb.Size = UDim2.new(0, 180, 0, 64); bb.StudsOffset = Vector3.new(0, 3, 0)
		bb.AlwaysOnTop = true; bb.LightInfluence = 0; bb.Parent = head
		local dLbl = Instance.new("TextLabel", bb)
		dLbl.Size = UDim2.new(1, 0, 0, 18); dLbl.Position = UDim2.new(0, 0, 0, 0); dLbl.BackgroundTransparency = 1
		dLbl.Text = PlayerESP.discordText; dLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
		dLbl.Font = Enum.Font.GothamBlack; dLbl.TextScaled = true
		dLbl.TextStrokeTransparency = 0; dLbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		local nLbl = Instance.new("TextLabel", bb)
		nLbl.Size = UDim2.new(1, 0, 0, 24); nLbl.Position = UDim2.new(0, 0, 0, 18); nLbl.BackgroundTransparency = 1
		nLbl.Text = player.DisplayName .. " (@" .. player.Name .. ")"; nLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
		nLbl.Font = Enum.Font.GothamBlack; nLbl.TextScaled = true
		nLbl.TextStrokeTransparency = 0; nLbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		local sLbl = Instance.new("TextLabel", bb)
		sLbl.Size = UDim2.new(1, 0, 0, 22); sLbl.Position = UDim2.new(0, 0, 0, 42); sLbl.BackgroundTransparency = 1
		sLbl.Text = "Speed: 0"; sLbl.TextColor3 = THEME_ACCENT
		sLbl.Font = Enum.Font.GothamBlack; sLbl.TextScaled = true
		sLbl.TextStrokeTransparency = 0; sLbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		local speedConn = RunService.Heartbeat:Connect(function()
			if not PlayerESP.enabled or not hrp or not hrp.Parent then return end
			local v = hrp.AssemblyLinearVelocity or hrp.Velocity
			local mag = Vector3.new(v.X, 0, v.Z).Magnitude
			sLbl.Text = string.format("Speed: %.1f", mag)
		end)
		PlayerESP.playerData[player] = {
			highlight = hl, billboard = bb,
			nameLabel = nLbl, speedLabel = sLbl, discordLabel = dLbl,
			conns = {speedConn},
		}
	end
	local function _espOnPlayerAdded(player)
		if not PlayerESP.enabled or player == LP then return end
		local function onChar(char) task.spawn(function() _espSetupCharacter(player, char) end) end
		if player.Character then onChar(player.Character) end
		player.CharacterAdded:Connect(onChar)
	end
	startPlayerESP = function()
		if PlayerESP.enabled then return end
		PlayerESP.enabled = true
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LP then _espOnPlayerAdded(p) end
		end
		table.insert(PlayerESP.conns, Players.PlayerAdded:Connect(_espOnPlayerAdded))
		table.insert(PlayerESP.conns, Players.PlayerRemoving:Connect(_espCleanupPlayer))
	end
	stopPlayerESP = function()
		if not PlayerESP.enabled then return end
		PlayerESP.enabled = false
		for _, c in ipairs(PlayerESP.conns) do pcall(function() c:Disconnect() end) end
		PlayerESP.conns = {}
		for player, _ in pairs(PlayerESP.playerData) do _espCleanupPlayer(player) end
	end
	trackTheme(function(c)
		for _, d in pairs(PlayerESP.playerData) do
			if d.highlight then d.highlight.FillColor = c end
			if d.speedLabel then d.speedLabel.TextColor3 = c end
		end
	end)
end
local holdJumpPressed = false
local holdJumpActive = false
local function applyInfJumpBoost(boost)
	if not infJumpEnabled then return end
	local char=LP.Character;if not char then return end
	local root=char:FindFirstChild("HumanoidRootPart")
	if root then root.Velocity=Vector3.new(root.Velocity.X,boost,root.Velocity.Z) end
end
UIS.JumpRequest:Connect(function() applyInfJumpBoost(50) end)
UIS.InputBegan:Connect(function(input)
	if input.UserInputType==Enum.UserInputType.Keyboard and input.KeyCode==Enum.KeyCode.Space and not UIS:GetFocusedTextBox() then
		holdJumpPressed=true
		task.delay(0.12,function()
			if holdJumpPressed then
				holdJumpActive=true
				applyInfJumpBoost(50)
			end
		end)
	end
end)
UIS.InputEnded:Connect(function(input)
	if input.UserInputType==Enum.UserInputType.Keyboard and input.KeyCode==Enum.KeyCode.Space then holdJumpPressed=false;holdJumpActive=false end
end)
RunService.Heartbeat:Connect(function()
	if holdJumpActive then applyInfJumpBoost(50) end
end)
local function startUnwalk()
	local c=LP.Character;if not c then return end
	local hum=c:FindFirstChildOfClass("Humanoid")
	if hum then for _,t in ipairs(hum:GetPlayingAnimationTracks()) do t:Stop() end end
	local anim=c:FindFirstChild("Animate")
	if anim then unwalkSavedAnimate=anim:Clone();anim:Destroy() end
end
local function stopUnwalk()
	local c=LP.Character
	if c and unwalkSavedAnimate then unwalkSavedAnimate:Clone().Parent=c;unwalkSavedAnimate=nil end
end

local DROP_ASCEND_DURATION, DROP_ASCEND_SPEED = 0.2, 150
local function runDrop()
	if dropActive then return end
	if autoBatEnabled then
		autoBatEnabled=false
		if resetAutoBatMotion then resetAutoBatMotion() end
		if autoBatSetVisual then autoBatSetVisual(false) end
	end
	local char = LP.Character; if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
	dropActive = true
	local t0 = tick()
	local dc
	dc = RunService.Heartbeat:Connect(function()
		local r = char and char:FindFirstChild("HumanoidRootPart")
		if not r then
			dc:Disconnect()
			dropActive = false
			return
		end
		if tick() - t0 >= DROP_ASCEND_DURATION then
			dc:Disconnect()
			local rp = RaycastParams.new()
			rp.FilterDescendantsInstances = {char}
			rp.FilterType = Enum.RaycastFilterType.Exclude
			local rr = workspace:Raycast(r.Position, Vector3.new(0, -2000, 0), rp)
			if rr then
				local hum2 = char:FindFirstChildOfClass("Humanoid")
				local off = (hum2 and hum2.HipHeight or 2) + (r.Size.Y / 2)
				r.CFrame = CFrame.new(r.Position.X, rr.Position.Y + off, r.Position.Z)
				r.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
			end
			dropActive = false
			return
		end
		r.Velocity = Vector3.new(r.Velocity.X, DROP_ASCEND_SPEED, r.Velocity.Z)
	end)
end
local function doAutoTPDown(force)
	local char=LP.Character;if not char then return end
	local hrp=char:FindFirstChild("HumanoidRootPart");if not hrp then return end
	local hum2=char:FindFirstChildOfClass("Humanoid");if not hum2 then return end
	if not force then
		if hum2.FloorMaterial~=Enum.Material.Air then return end
		if hrp.Position.Y<autoTPHeight then return end
	end
	hrp.CFrame=CFrame.new(hrp.Position.X,-7.00,hrp.Position.Z)
		*CFrame.Angles(0,select(2,hrp.CFrame:ToEulerAnglesYXZ()),0)
	hrp.AssemblyLinearVelocity=Vector3.zero
end
local function startAutoTP()
	if autoTPConn then task.cancel(autoTPConn);autoTPConn=nil end
	autoTPConn=task.spawn(function()
		while autoTPEnabled do
			task.wait(0.1)
			pcall(function() doAutoTPDown(false) end)
		end
	end)
end
local function stopAutoTP()
	autoTPEnabled=false
	if autoTPConn then task.cancel(autoTPConn);autoTPConn=nil end
end
local function runTPFloor()
	pcall(function() doAutoTPDown(true) end)
end
local defLightBrightness,defLightClock,defLightAmbient
local function enableStretchRez()
	stretchRezEnabled=true
	if not V.customFovEnabled then
		workspace.CurrentCamera.FieldOfView=107
	end
	if stretchRezConn then stretchRezConn:Disconnect() end
	stretchRezConn=RunService.RenderStepped:Connect(function()
		if not stretchRezEnabled then stretchRezConn:Disconnect();stretchRezConn=nil;return end
		if not V.customFovEnabled then
			workspace.CurrentCamera.FieldOfView=107
		end
	end)
end
local function disableStretchRez()
	stretchRezEnabled=false
	if stretchRezConn then stretchRezConn:Disconnect();stretchRezConn=nil end
	if not V.customFovEnabled then
		workspace.CurrentCamera.FieldOfView=70
	end
end

local function enableCustomFov()
	V.customFovEnabled=true
	workspace.CurrentCamera.FieldOfView=V.customFovValue
	if V.customFovConn then V.customFovConn:Disconnect() end
	V.customFovConn=RunService.RenderStepped:Connect(function()
		if not V.customFovEnabled then V.customFovConn:Disconnect();V.customFovConn=nil;return end
		workspace.CurrentCamera.FieldOfView=V.customFovValue
	end)
end
local function disableCustomFov()
	V.customFovEnabled=false
	if V.customFovConn then V.customFovConn:Disconnect();V.customFovConn=nil end
	if stretchRezEnabled then
		workspace.CurrentCamera.FieldOfView=107
	else
		workspace.CurrentCamera.FieldOfView=70
	end
end
local function applyAntiLagDerender(obj)
	pcall(function()
		if obj:IsA("Accessory") or obj:IsA("Hat") then obj:Destroy()
		elseif obj:IsA("BasePart") then obj.Material=Enum.Material.Plastic;obj.Reflectance=0;obj.CastShadow=false
		elseif obj:IsA("Decal") or obj:IsA("Texture") then obj.Transparency=1
		elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then obj.Enabled=false
		elseif obj:IsA("AnimationController") or obj:IsA("Animator") then
			for _,t in ipairs(obj:GetPlayingAnimationTracks()) do pcall(function() t:Stop(0) end) end
		end
	end)
end
local function enableAntiLag()
	removeAccessoriesEnabled=true
	antiLagEnabled=true
	defLightBrightness=defLightBrightness or Lighting.Brightness
	defLightClock=defLightClock or Lighting.ClockTime
	defLightAmbient=defLightAmbient or Lighting.OutdoorAmbient
	Lighting.GlobalShadows=false;Lighting.FogEnd=1e10;Lighting.Brightness=1
	Lighting.EnvironmentDiffuseScale=0;Lighting.EnvironmentSpecularScale=0
	for _,e in pairs(Lighting:GetChildren()) do
		pcall(function()
			if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then e.Enabled=false end
		end)
	end
	for _,obj in ipairs(workspace:GetDescendants()) do applyAntiLagDerender(obj) end
	if antiLagDescConn then antiLagDescConn:Disconnect() end
	antiLagDescConn=workspace.DescendantAdded:Connect(function(obj)
		if removeAccessoriesEnabled then applyAntiLagDerender(obj) end
	end)
end
local function disableAntiLag()
	removeAccessoriesEnabled=false
	antiLagEnabled=false
	if antiLagDescConn then antiLagDescConn:Disconnect();antiLagDescConn=nil end
	pcall(function()
		if defLightBrightness then Lighting.Brightness=defLightBrightness end
		if defLightClock then Lighting.ClockTime=defLightClock end
		if defLightAmbient then Lighting.OutdoorAmbient=defLightAmbient end
		Lighting.ExposureCompensation=0
	end)
end
local function findMedusa()
	local c=LP.Character;if not c then return nil end
	for _,t in ipairs(c:GetChildren()) do if t:IsA("Tool") then local n=t.Name:lower();if n:find("medusa") or n:find("head") or n:find("stone") then return t end end end
	local bp=LP:FindFirstChild("Backpack")
	if bp then for _,t in ipairs(bp:GetChildren()) do if t:IsA("Tool") then local n=t.Name:lower();if n:find("medusa") or n:find("head") or n:find("stone") then return t end end end end
	return nil
end
local function useMedusaCounter()
	if medusaDebounce then return end;if tick()-medusaLastUsed<MEDUSA_COOLDOWN then return end
	local c=LP.Character;if not c then return end;medusaDebounce=true
	local med=findMedusa();if not med then medusaDebounce=false;return end
	if med.Parent~=c then local hum2=c:FindFirstChildOfClass("Humanoid");if hum2 then hum2:EquipTool(med) end end
	pcall(function() med:Activate() end);medusaLastUsed=tick();medusaDebounce=false
end
local function onAnchorChanged(part)
	return part:GetPropertyChangedSignal("Anchored"):Connect(function()
		if part.Anchored and part.Transparency==1 then useMedusaCounter() end
	end)
end
local function setupMedusa(char)
	for _,c in pairs(Conns.anchor) do pcall(function() c:Disconnect() end) end;Conns.anchor={}
	if not char then return end
	for _,part in ipairs(char:GetDescendants()) do if part:IsA("BasePart") then table.insert(Conns.anchor,onAnchorChanged(part)) end end
	table.insert(Conns.anchor,char.DescendantAdded:Connect(function(part)
		if part:IsA("BasePart") then table.insert(Conns.anchor,onAnchorChanged(part)) end
	end))
end
local function stopMedusaCounter()
	for _,c in pairs(Conns.anchor) do pcall(function() c:Disconnect() end) end;Conns.anchor={}
end
local BAT_COUNTER_SLAP_LIST={"Bat","Slap","Iron Slap","Gold Slap","Diamond Slap","Emerald Slap","Ruby Slap","Dark Matter Slap","Flame Slap","Nuclear Slap","Galaxy Slap","Glitched Slap"}
local function findBatForCounter()
	local c=LP.Character;if not c then return nil end
	local bp=LP:FindFirstChildOfClass("Backpack")
	for _,name in ipairs(BAT_COUNTER_SLAP_LIST) do
		local t=c:FindFirstChild(name) or (bp and bp:FindFirstChild(name));if t then return t end
	end
	for _,ch in ipairs(c:GetChildren()) do if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end end
	if bp then for _,ch in ipairs(bp:GetChildren()) do if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end end end
	return nil
end
local function swingBatForCounter(bat,char)
	local hum2=char:FindFirstChildOfClass("Humanoid")
	if bat.Parent~=char then if hum2 then pcall(function() hum2:EquipTool(bat) end) end;task.wait(0.05) end
	local remote=bat:FindFirstChildOfClass("RemoteEvent") or bat:FindFirstChildOfClass("RemoteFunction")
	if remote and remote:IsA("RemoteEvent") then
		pcall(function() remote:FireServer() end);task.wait(0.15);pcall(function() remote:FireServer() end)
	else pcall(function() bat:Activate() end);task.wait(0.15);pcall(function() bat:Activate() end) end
end
startBatCounter=function()
	if Conns.batCounter then return end
	Conns.batCounter=RunService.Heartbeat:Connect(function()
		if not batCounterEnabled then return end
		if batCounterDebounce then return end
		local char=LP.Character;if not char then return end
		local hum2=char:FindFirstChildOfClass("Humanoid");if not hum2 then return end
		local st=hum2:GetState()
		if st==Enum.HumanoidStateType.Physics or st==Enum.HumanoidStateType.Ragdoll or st==Enum.HumanoidStateType.FallingDown then
			batCounterDebounce=true
			task.spawn(function()
				local bat=findBatForCounter()
				if bat then swingBatForCounter(bat,char) end
				task.wait(0.5);batCounterDebounce=false
			end)
		end
	end)
end
stopBatCounter=function()
	if Conns.batCounter then Conns.batCounter:Disconnect();Conns.batCounter=nil end
	batCounterDebounce=false
end
local function getAutoBatTarget()
	local root=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
	if not root then return nil end
	local now=tick()
	if now-_autoBatLastScan<=0.1 and _autoBatTarget and _autoBatTarget.Parent then
		local hum=_autoBatTarget.Parent:FindFirstChildOfClass("Humanoid")
		if hum and hum.Health>0 then return _autoBatTarget end
	end
	_autoBatLastScan=now
	_autoBatTarget=nil
	local closest,minDist=nil,math.huge
	for _,plr in ipairs(Players:GetPlayers()) do
		if plr~=LP and plr.Character then
			local tRoot=plr.Character:FindFirstChild("HumanoidRootPart")
			local hum=plr.Character:FindFirstChildOfClass("Humanoid")
			if tRoot and hum and hum.Health>0 then
				local dist=(tRoot.Position-root.Position).Magnitude
				if dist<minDist then minDist=dist;closest=tRoot end
			end
		end
	end
	_autoBatTarget=closest
	return _autoBatTarget
end
resetAutoBatMotion=function()
	local char=LP.Character
	local hrp=char and char:FindFirstChild("HumanoidRootPart")
	local hum=char and char:FindFirstChildOfClass("Humanoid")
	if hrp then hrp.AssemblyLinearVelocity=hrp.AssemblyLinearVelocity*0.3;hrp.AssemblyAngularVelocity=Vector3.zero end
	if hum then hum.AutoRotate=true end
end
local _autoTPWasEnabled=false
local function enableAutoBat()
	if autoLeftEnabled then autoLeftEnabled=false;if autoLeftSetVisual then autoLeftSetVisual(false) end;stopAutoLeft() end
	if autoRightEnabled then autoRightEnabled=false;if autoRightSetVisual then autoRightSetVisual(false) end;stopAutoRight() end
	if autoTPEnabled then _autoTPWasEnabled=true;stopAutoTP();if setAutoTPVisual then setAutoTPVisual(false) end else _autoTPWasEnabled=false end
	autoBatEquippedThisRun=false
	autoBatEnabled=true
end
local function disableAutoBat()
	autoBatEnabled=false
	autoBatEquippedThisRun=false
	local char=LP.Character
	if char then
		local hum2=char:FindFirstChildOfClass("Humanoid")
		if hum2 then hum2.AutoRotate=true end
	end
	if resetAutoBatMotion then resetAutoBatMotion() end
	if _autoTPWasEnabled then
		_autoTPWasEnabled=false;autoTPEnabled=true
		if setAutoTPVisual then setAutoTPVisual(true) end;startAutoTP()
	end
end
local function queueAutoLeftStart()
	autoLeftEnabled=true
	if autoRightEnabled then autoRightEnabled=false;if autoRightSetVisual then autoRightSetVisual(false) end;stopAutoRight() end
	if autoBatEnabled then disableAutoBat();if autoBatSetVisual then autoBatSetVisual(false) end end
	startAutoLeft()
end
local function queueAutoRightStart()
	autoRightEnabled=true
	if autoLeftEnabled then autoLeftEnabled=false;if autoLeftSetVisual then autoLeftSetVisual(false) end;stopAutoLeft() end
	if autoBatEnabled then disableAutoBat();if autoBatSetVisual then autoBatSetVisual(false) end end
	startAutoRight()
end
local function queueAutoBatStart()
	if autoLeftEnabled then autoLeftEnabled=false;if autoLeftSetVisual then autoLeftSetVisual(false) end;stopAutoLeft() end
	if autoRightEnabled then autoRightEnabled=false;if autoRightSetVisual then autoRightSetVisual(false) end;stopAutoRight() end
	enableAutoBat()
end
RunService.Heartbeat:Connect(function()
	if not autoBatEnabled then return end
	local char=LP.Character
	local hum=char and char:FindFirstChildOfClass("Humanoid")
	local root=char and char:FindFirstChild("HumanoidRootPart")
	if not root or not hum then return end
	if not autoBatEquippedThisRun then
		autoBatEquippedThisRun=true
		if not char:FindFirstChildOfClass("Tool") then
			local bp=LP:FindFirstChildOfClass("Backpack") or LP:FindFirstChild("Backpack")
			local bpBat=bp and bp:FindFirstChild("Bat")
			if bpBat then pcall(function() hum:EquipTool(bpBat) end) end
		end
	end
	local target=getAutoBatTarget()
	if target then
		local targetVel=target.AssemblyLinearVelocity
		local aimTargetPos=target.Position+(targetVel*math.clamp(targetVel.Magnitude/130,0.05,0.15))+Vector3.new(0,AUTO_BAT_V_OFF,0)
		hum.AutoRotate=false
		local look=aimTargetPos-root.Position
		local flatLook=Vector3.new(look.X,0,look.Z)
		if look.Magnitude>0.01 and flatLook.Magnitude>0.01 then
			local targetYaw=math.deg(math.atan2(-flatLook.X,-flatLook.Z))
			local yawDelta=(targetYaw-root.Orientation.Y+180)%360-180
			local targetPitch=math.deg(math.atan2(look.Y,flatLook.Magnitude))
			local pitchDelta=(targetPitch-root.Orientation.X+180)%360-180
			local yawRate=math.clamp(math.rad(yawDelta)*AUTO_BAT_TURN_SPEED,-AUTO_BAT_MAX_TURN_RATE,AUTO_BAT_MAX_TURN_RATE)
			local pitchRate=math.clamp(math.rad(pitchDelta)*AUTO_BAT_TURN_SPEED,-AUTO_BAT_MAX_TURN_RATE,AUTO_BAT_MAX_TURN_RATE)
			local yawRad=math.rad(root.Orientation.Y)
			local rightAxis=Vector3.new(math.cos(yawRad),0,-math.sin(yawRad))
			root.AssemblyAngularVelocity=Vector3.new(0,yawRate,0)+(rightAxis*pitchRate)
		else
			root.AssemblyAngularVelocity=Vector3.zero
		end
		local dir=look.Magnitude>0.01 and look.Unit or Vector3.zero
		local standPos=aimTargetPos-(dir*AUTO_BAT_DIST)+Vector3.new(0,AUTO_BAT_HEIGHT,0)
		local moveDir=standPos-root.Position
		local hDir=Vector3.new(moveDir.X,0,moveDir.Z)
		local hVel=hDir.Magnitude>0.1 and hDir.Unit*AUTO_BAT_SPEED or Vector3.zero
		local vVel=math.abs(moveDir.Y)>0.1 and Vector3.new(0,math.sign(moveDir.Y)*AUTO_BAT_VERT_SPEED,0) or Vector3.new(0,-2,0)
		root.AssemblyLinearVelocity=hVel+vVel
		if hDir.Magnitude>0.5 then hum:Move(hDir.Unit,false) end
	else
		hum.AutoRotate=true
		root.AssemblyAngularVelocity=Vector3.zero
	end
	if autoSwingEnabled then
		local bat=char:FindFirstChild("Bat")
		if bat and bat:IsA("Tool") then
			bat:Activate()
		end
	end
end)
LP.CharacterAdded:Connect(function(char)
	task.wait(0.5)
	setupSpeedIndicator(char)
	if medusaCounterEnabled then setupMedusa(char) end
	if batCounterEnabled then startBatCounter() end
	if unwalkEnabled then task.wait(0.5);startUnwalk() end
end)
if LP.Character then setupSpeedIndicator(LP.Character) end

-- SKY PRESETS (truncated for loadstring size)
local SKY_PRESETS_LIST = {"Off","Night","Aurora","Sunset","Galaxy","Cyber","Sakura"}
local SKY_PRESETS = {["Off"] = {kind = "off"}}
local function applyCustomSky(mode) return end

local function saveConfig() end
local function loadConfigKeys() end
local function loadConfigState() end

loadConfigKeys()
print("🌀 Vortex V5 - Loaded!")
print("discord.gg/d7Yxt78KE")