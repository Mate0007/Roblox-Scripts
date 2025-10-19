-- Load the Surfy UI Library with error handling
local success, SurfyUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Mate0007/Roblox-Scripts/refs/heads/main/library.lua"))()
end)

if not success or not SurfyUI then
    warn("Failed to load Surfy UI library!")
    return
end

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RepStorage = game:GetService("ReplicatedStorage")

-- Performance optimization flags
local PERFORMANCE_MODE = true
local ESP_UPDATE_INTERVAL = 0.5
local HITBOX_UPDATE_INTERVAL = 0.3

-- ===== TC2 SCRIPT IMPLEMENTATION =====

local Window = SurfyUI:CreateWindow({
    Title = "Surfy TC2 - v3.0"
})

-- Create tabs in the correct order
local CombatTab = Window:CreateTab("Combat")
local VisualsTab = Window:CreateTab("Visuals")
local MiscTab = Window:CreateTab("Misc")
local SettingsTab = Window:CreateTab("Settings")

-- ===== COMBAT SECTIONS =====
local AimbotSection = SurfyUI:CreateSection(CombatTab, "Aimbot / Aimlock")
local HitboxSection = SurfyUI:CreateSection(CombatTab, "Hitbox Expander")
local RapidFireSection = SurfyUI:CreateSection(CombatTab, "Rapid Fire")

-- ===== VISUALS SECTIONS =====
local PlayerESPSection = SurfyUI:CreateSection(VisualsTab, "Player ESP")

-- ===== MISC SECTIONS =====
local BhopSection = SurfyUI:CreateSection(MiscTab, "Bhop Features")
local AntiFeaturesSection = SurfyUI:CreateSection(MiscTab, "Anti Features")
local VoteSpamSection = SurfyUI:CreateSection(MiscTab, "Vote Spam")

-- ===== SETTINGS SECTIONS =====
local KeybindSection = SurfyUI:CreateSection(SettingsTab, "Keybind Settings")

-- ===== PERFORMANCE OPTIMIZATIONS =====
local lastESPCheck = 0
local lastHitboxCheck = 0
local cachedPlayers = {}
local playerCacheValid = false

-- Cache player list for better performance
local function updatePlayerCache()
    cachedPlayers = Players:GetPlayers()
    playerCacheValid = true
end

Players.PlayerAdded:Connect(updatePlayerCache)
Players.PlayerRemoving:Connect(updatePlayerCache)
updatePlayerCache()

-- ===== AIMBOT / AIMLOCK SYSTEM (OPTIMIZED) =====
local aimbotEnabled = false
local wallcheckEnabled = false
local targetEnemyOnly = true
local aimbotFOV = 100
local targetBodyPart = "Head"
local aimbotSmoothness = 0.5
local isAimbotKeyHeld = false

-- FOV Circle with reduced updates
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.NumSides = 30
fovCircle.Radius = aimbotFOV
fovCircle.Filled = false
fovCircle.Visible = false
fovCircle.ZIndex = 999
fovCircle.Transparency = 1
fovCircle.Color = Color3.fromRGB(0, 180, 255)

-- Optimized wallcheck with caching
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
raycastParams.IgnoreWater = true
local lastWallCheck = {}
local wallCheckCache = {}

local function hasLineOfSight(targetPart)
    if not wallcheckEnabled then return true end
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Head") then return false end
    
    local cacheKey = targetPart and tostring(targetPart)
    if cacheKey and wallCheckCache[cacheKey] and (tick() - lastWallCheck[cacheKey] < 0.1) then
        return wallCheckCache[cacheKey]
    end
    
    local origin = LocalPlayer.Character.Head.Position
    local direction = (targetPart.Position - origin)
    
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetPart.Parent}
    
    local rayResult = workspace:Raycast(origin, direction, raycastParams)
    local result = rayResult == nil
    
    if cacheKey then
        wallCheckCache[cacheKey] = result
        lastWallCheck[cacheKey] = tick()
    end
    
    return result
end

-- Optimized player iteration
local function getClosestPlayerInFOV()
    local closestPlayer = nil
    local shortestDistance = aimbotFOV
    
    local camera = workspace.CurrentCamera
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, player in ipairs(cachedPlayers) do
        if player == LocalPlayer then continue end
        
        local character = player.Character
        if not character then continue end
        
        if targetEnemyOnly and player.Team == LocalPlayer.Team then continue end
        
        local targetPart = character:FindFirstChild(targetBodyPart == "Body" and "Torso" or targetBodyPart)
        if not targetPart then targetPart = character:FindFirstChild("HumanoidRootPart") end
        if not targetPart then continue end
        
        local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
        if not onScreen then continue end
        
        local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
        
        if distance < shortestDistance then
            if hasLineOfSight(targetPart) then
                shortestDistance = distance
                closestPlayer = player
            end
        end
    end
    
    return closestPlayer
end

local function aimAtPlayer(player)
    if not player or not player.Character then return end
    
    local character = player.Character
    local targetPart = character:FindFirstChild(targetBodyPart == "Body" and "Torso" or targetBodyPart)
    if not targetPart then targetPart = character:FindFirstChild("HumanoidRootPart") end
    if not targetPart then return end
    
    local camera = workspace.CurrentCamera
    local targetPos = targetPart.Position
    local currentCFrame = camera.CFrame
    
    local lookVector = (targetPos - currentCFrame.Position).Unit
    local currentLook = currentCFrame.LookVector
    if (lookVector - currentLook).Magnitude > 0.01 then
        local targetCFrame = CFrame.new(camera.CFrame.Position, targetPos)
        camera.CFrame = currentCFrame:Lerp(targetCFrame, aimbotSmoothness)
    end
end

-- ===== AIMBOT CONTROLS =====
local AimbotKeybind = SurfyUI:CreateToggleWithKeybind(AimbotSection, {
    Title = "Aimbot",
    Default = false,
    DefaultKey = Enum.UserInputType.MouseButton2,
    LayoutOrder = 1,
    Callback = function(Value)
        aimbotEnabled = Value
        fovCircle.Visible = Value
        SurfyUI:CreateNotification({
            Title = "Aimbot",
            Description = Value and "Enabled" or "Disabled",
            Duration = 2
        })
    end,
    KeybindCallback = function()
        isAimbotKeyHeld = true
    end
})

UserInputService.InputEnded:Connect(function(input)
    if aimbotEnabled then
        if (input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode == AimbotKeybind.Key) or
           (input.UserInputType == AimbotKeybind.Key) then
            isAimbotKeyHeld = false
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if not aimbotEnabled then 
        if fovCircle.Visible then
            fovCircle.Visible = false
        end
        return 
    end
    
    local mouseLocation = UserInputService:GetMouseLocation()
    fovCircle.Position = mouseLocation
    fovCircle.Radius = aimbotFOV
    
    if isAimbotKeyHeld then
        local target = getClosestPlayerInFOV()
        if target then
            aimAtPlayer(target)
        end
    end
end)

SurfyUI:CreateToggle(AimbotSection, {
    Title = "Wallcheck",
    Default = false,
    LayoutOrder = 2,
    Callback = function(Value)
        wallcheckEnabled = Value
        wallCheckCache = {}
        lastWallCheck = {}
    end
})

SurfyUI:CreateToggle(AimbotSection, {
    Title = "Target Enemy Only",
    Default = true,
    LayoutOrder = 3,
    Callback = function(Value)
        targetEnemyOnly = Value
    end
})

SurfyUI:CreateSlider(AimbotSection, {
    Title = "Aimbot FOV Circle",
    Default = 100,
    Min = 20,
    Max = 300,
    Rounding = 0,
    LayoutOrder = 4,
    Callback = function(Value)
        aimbotFOV = Value
    end
})

SurfyUI:CreateDropdown(AimbotSection, {
    Title = "Target Body Part",
    Options = {"Head", "Neck", "Body"},
    Default = "Head",
    LayoutOrder = 5,
    Callback = function(Value)
        targetBodyPart = Value
    end
})

SurfyUI:CreateSlider(AimbotSection, {
    Title = "Smoothness",
    Default = 0.5,
    Min = 0.1,
    Max = 1,
    Rounding = 2,
    LayoutOrder = 6,
    Callback = function(Value)
        aimbotSmoothness = Value
    end
})

-- ===== OPTIMIZED HITBOX EXPANDER =====
local hitboxEnabled = false
local hitboxSize = 15
local hitboxLoop = nil
local showHitbox = false
local hitboxTarget = "Head"
local ExpandableHitboxes = {
    Head = {"HeadHB"},
    Body = {"Hitbox"}
}

local originalSizes = {
    HeadHB = Vector3.new(2, 2, 2),
    Hitbox = Vector3.new(5.59, 5.175, 5.175)
}

local hitboxCache = {}

local function ExpandPart(part, size, isTarget)
    if not part then return end
    
    part.Massless = true
    part.CanCollide = false
    
    if isTarget then
        part.Transparency = showHitbox and 0.7 or 1
        part.Size = size
        
        if showHitbox and not part:FindFirstChild("HitboxOutline") then
            local outline = Instance.new("SelectionBox")
            outline.Name = "HitboxOutline"
            outline.Adornee = part
            outline.LineThickness = 0.03
            outline.Color3 = Color3.fromRGB(150, 150, 150)
            outline.SurfaceColor3 = Color3.fromRGB(100, 100, 100)
            outline.SurfaceTransparency = 0.8
            outline.Transparency = 0.5
            outline.Parent = part
        elseif not showHitbox and part:FindFirstChild("HitboxOutline") then
            part.HitboxOutline:Destroy()
        end
    else
        part.Transparency = 1
        part.Size = size
    end
end

local function updateHitboxes()
    local currentTime = tick()
    if currentTime - lastHitboxCheck < HITBOX_UPDATE_INTERVAL then return end
    lastHitboxCheck = currentTime
    
    for _, player in ipairs(cachedPlayers) do 
        local Character = player.Character
        if not Character then continue end
        
        local cacheKey = tostring(player.UserId)
        local lastUpdate = hitboxCache[cacheKey]
        
        if lastUpdate and lastUpdate.character == Character and lastUpdate.time > currentTime - 2 then
            continue
        end
        
        if player.Team ~= LocalPlayer.Team then
            for hitboxType, hitboxNames in pairs(ExpandableHitboxes) do
                for _, hitboxName in pairs(hitboxNames) do
                    local hitbox = Character:FindFirstChild(hitboxName)
                    if hitbox then
                        if hitboxType == hitboxTarget then
                            ExpandPart(hitbox, Vector3.one * hitboxSize, true)
                        else
                            ExpandPart(hitbox, originalSizes[hitboxName], false)
                        end
                    end
                end
            end
        else
            for hitboxName, originalSize in pairs(originalSizes) do
                local hitbox = Character:FindFirstChild(hitboxName)
                if hitbox then
                    ExpandPart(hitbox, originalSize, false)
                end
            end
        end
        
        hitboxCache[cacheKey] = {
            character = Character,
            time = currentTime
        }
    end
end

local function resetAllHitboxes()
    for _, player in ipairs(cachedPlayers) do 
        local Character = player.Character
        if Character then
            for hitboxName, originalSize in pairs(originalSizes) do
                local hitbox = Character:FindFirstChild(hitboxName)
                if hitbox then
                    hitbox.Size = originalSize
                    hitbox.Transparency = 1
                    hitbox.Massless = false
                    if hitbox:FindFirstChild("HitboxOutline") then
                        hitbox.HitboxOutline:Destroy()
                    end
                end
            end
        end
    end
    hitboxCache = {}
end

SurfyUI:CreateToggle(HitboxSection, {
    Title = "Hitbox Expander",
    Default = false,
    LayoutOrder = 10,
    Callback = function(Value)
        hitboxEnabled = Value
        if Value then
            hitboxLoop = RunService.Heartbeat:Connect(function()
                if hitboxEnabled then
                    updateHitboxes()
                end
            end)
            SurfyUI:CreateNotification({
                Title = "Hitbox Expander",
                Description = "Enabled",
                Duration = 2
            })
        else
            if hitboxLoop then
                hitboxLoop:Disconnect()
                hitboxLoop = nil
            end
            resetAllHitboxes()
            SurfyUI:CreateNotification({
                Title = "Hitbox Expander",
                Description = "Disabled",
                Duration = 2
            })
        end
    end
})

SurfyUI:CreateDropdown(HitboxSection, {
    Title = "Hitbox Target",
    Options = {"Head", "Body"},
    Default = "Head",
    LayoutOrder = 11,
    Callback = function(Value)
        hitboxTarget = Value
        hitboxCache = {}
    end
})

SurfyUI:CreateSlider(HitboxSection, {
    Title = "Hitbox Size",
    Default = 15,
    Min = 5,
    Max = 50,
    Rounding = 0,
    LayoutOrder = 12,
    Callback = function(Value)
        hitboxSize = Value
        hitboxCache = {}
    end
})

SurfyUI:CreateToggle(HitboxSection, {
    Title = "Show Hitbox",
    Default = false,
    LayoutOrder = 13,
    Callback = function(Value)
        showHitbox = Value
        hitboxCache = {}
    end
})

-- ===== ULTRA OPTIMIZED RAPID FIRE SYSTEM WITH ROCKET LAUNCHER SUPPORT =====
local rapidFireEnabled = false
local rapidFireRate = 0.2
local isHoldingFireKey = false
local capturedRemote = nil
local spaceFolder = nil
local currentWeaponType = nil
local lastWeaponCheck = 0
local weaponCheckInterval = 1
local isHooked = false

-- Pre-cache references
local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local mouse = LocalPlayer:GetMouse()

-- Constants
local offsetVec = Vector3.new(0, 1.57, 0)
local mapClips = workspace:WaitForChild("Map"):WaitForChild("Clips")
local debris = workspace:WaitForChild("Debris")
local workspaceRefs = {mapClips, debris}

-- Weapon detection strings
local GRENADE_STR = "Grenade"
local GRENADE_LAUNCHER_STR = "Grenade Launcher"
local ROCKET_STR = "Rocket"
local ROCKET_LAUNCHER_STR = "Rocket Launcher"

-- Static arguments (never change)
local staticArgs = {
    [7] = workspaceRefs,
    [9] = false,
    [11] = 0,
    [13] = 111465880
}

-- Reusable args table for Grenade Launcher
local grenadeArgs = {
    nil, -- [1] mousePos
    GRENADE_STR, -- [2]
    nil, -- [3] CFrame
    GRENADE_LAUNCHER_STR, -- [4]
    nil, -- [5] pos
    [7] = workspaceRefs,
    [9] = false,
    [11] = 0
}

-- Reusable args table for Rocket Launcher
local rocketArgs = {
    nil, -- [1] mousePos
    ROCKET_STR, -- [2]
    nil, -- [3] CFrame
    ROCKET_LAUNCHER_STR, -- [4]
    nil, -- [5] pos
    [7] = workspaceRefs,
    [9] = false,
    [11] = 0,
    [13] = 111465880
}

-- Get folder once at startup
local function initFolder()
    if spaceFolder then return true end
    local folder = RepStorage:FindFirstChild("Folder")
    if not folder then return false end
    spaceFolder = folder:FindFirstChild(" ")
    return spaceFolder ~= nil
end

-- Check what weapon player is currently holding (optimized)
local function checkCurrentWeapon()
    local currentTime = tick()
    if currentTime - lastWeaponCheck < weaponCheckInterval then 
        return currentWeaponType 
    end
    lastWeaponCheck = currentTime
    
    local success, weapon = pcall(function()
        local stats = LocalPlayer:FindFirstChild("CurrentLifeStats")
        if not stats then return nil end
        
        local timeAlive = stats:FindFirstChild("TimeAlive")
        if not timeAlive then return nil end
        
        -- Check for Rocket Launcher first
        if timeAlive:FindFirstChild(ROCKET_LAUNCHER_STR) then
            return ROCKET_LAUNCHER_STR
        end
        
        -- Check for Grenade Launcher
        if timeAlive:FindFirstChild(GRENADE_LAUNCHER_STR) then
            return GRENADE_LAUNCHER_STR
        end
        
        return nil
    end)
    
    if success and weapon then
        if currentWeaponType ~= weapon then
            currentWeaponType = weapon
            print("Weapon changed to:", weapon)
        end
        return weapon
    end
    
    return nil
end

-- Build arguments based on current weapon
local function buildWeaponArgs()
    if not hrp or not hrp.Parent then return nil end
    
    local weapon = checkCurrentWeapon()
    if not weapon then return nil end
    
    local pos = hrp.Position
    local targetPos = mouse.Hit.Position
    local firePos = pos + offsetVec
    local direction = (targetPos - firePos).Unit
    
    if weapon == ROCKET_LAUNCHER_STR then
        rocketArgs[1] = targetPos
        rocketArgs[3] = CFrame.new(firePos, firePos + direction)
        rocketArgs[5] = pos
        return rocketArgs
    elseif weapon == GRENADE_LAUNCHER_STR then
        grenadeArgs[1] = targetPos
        grenadeArgs[3] = CFrame.new(firePos, firePos + direction)
        grenadeArgs[5] = pos
        return grenadeArgs
    end
    
    return nil
end

-- Lightweight hook that STAYS ACTIVE
local function setupHook()
    if isHooked then return end
    if not initFolder() then 
        warn("Folder not found for rapid fire!")
        return 
    end
    
    for _, remote in pairs(spaceFolder:GetChildren()) do
        if remote:IsA("RemoteEvent") then
            local mt = getrawmetatable(remote)
            setreadonly(mt, false)
            
            local oldNamecall = mt.__namecall
            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                
                if self == remote and method == "FireServer" and rapidFireEnabled and not capturedRemote then
                    local args = {...}
                    
                    -- Check if this remote fires weapons
                    for i = 1, #args do
                        local v = args[i]
                        if v == GRENADE_STR or v == ROCKET_STR then
                            capturedRemote = remote
                            print("RAPID FIRE: Remote captured - " .. remote.Name)
                            
                            SurfyUI:CreateNotification({
                                Title = "Rapid Fire",
                                Description = "Ready! Hold keybind to spam",
                                Duration = 3
                            })
                            break
                        end
                    end
                end
                
                return oldNamecall(self, ...)
            end)
            
            setreadonly(mt, true)
            isHooked = true
        end
    end
end

-- Optimized fire function with minimal overhead
local function fireWeapon()
    if not capturedRemote or not rapidFireEnabled then return end
    
    local args = buildWeaponArgs()
    if not args then return end
    
    local success, err = pcall(function()
        capturedRemote:FireServer(unpack(args))
    end)
    
    if not success then
        warn("Fire error:", err)
    end
end

-- Single optimized fire loop
local fireConnection = nil
local function startFireLoop()
    if fireConnection then return end
    
    fireConnection = RunService.Heartbeat:Connect(function()
        if not isHoldingFireKey or not rapidFireEnabled then 
            if fireConnection then
                fireConnection:Disconnect()
                fireConnection = nil
            end
            return 
        end
        
        fireWeapon()
        task.wait(rapidFireRate)
    end)
end

-- Update character on respawn
LocalPlayer.CharacterAdded:Connect(function(newChar)
    char = newChar
    hrp = newChar:WaitForChild("HumanoidRootPart")
    currentWeaponType = nil
    lastWeaponCheck = 0
end)

-- Setup hook at script load (only runs once)
task.spawn(function()
    task.wait(1)
    pcall(setupHook)
end)

-- Rapid Fire Toggle with Keybind
local RapidFireKeybind = SurfyUI:CreateToggleWithKeybind(RapidFireSection, {
    Title = "Rapid Fire",
    Default = false,
    DefaultKey = Enum.UserInputType.MouseButton3,
    LayoutOrder = 20,
    Callback = function(Value)
        rapidFireEnabled = Value
        
        if Value then
            if capturedRemote then
                SurfyUI:CreateNotification({
                    Title = "Rapid Fire",
                    Description = "Ready! Hold keybind to spam",
                    Duration = 3
                })
            else
                SurfyUI:CreateNotification({
                    Title = "Rapid Fire",
                    Description = "Shoot weapon once to activate!",
                    Duration = 4
                })
            end
        else
            isHoldingFireKey = false
            if fireConnection then
                fireConnection:Disconnect()
                fireConnection = nil
            end
            
            SurfyUI:CreateNotification({
                Title = "Rapid Fire",
                Description = "Disabled",
                Duration = 2
            })
        end
    end,
    KeybindCallback = function()
        if rapidFireEnabled and capturedRemote then
            isHoldingFireKey = true
            startFireLoop()
        elseif rapidFireEnabled and not capturedRemote then
            SurfyUI:CreateNotification({
                Title = "Rapid Fire",
                Description = "Shoot weapon first!",
                Duration = 2
            })
        end
    end
})

-- Track keybind release
UserInputService.InputEnded:Connect(function(input)
    if rapidFireEnabled then
        if (input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode == RapidFireKeybind.Key) or
           (input.UserInputType == RapidFireKeybind.Key) then
            isHoldingFireKey = false
        end
    end
end)

-- Fire Rate Slider
SurfyUI:CreateSlider(RapidFireSection, {
    Title = "Fire Rate",
    Default = 0.2,
    Min = 0.05,
    Max = 0.5,
    Rounding = 2,
    LayoutOrder = 21,
    Callback = function(Value)
        rapidFireRate = Value
    end
})

-- ===== OPTIMIZED PLAYER ESP SYSTEM =====
local espMasterEnabled = false
local outlinesEnabled = false
local chamsEnabled = false
local teamBasedColoring = false
local espMaxDistance = 9999999
local enemyColor = Color3.fromRGB(255, 50, 50)
local teamColor = Color3.fromRGB(50, 255, 50)

local espCache = {}
local chamsCache = {}
local espUpdateConnection = nil

local function isEnemy(player)
    return player.Team ~= LocalPlayer.Team
end

local function getPlayerColor(player)
    if teamBasedColoring then
        return isEnemy(player) and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(50, 255, 50)
    else
        return isEnemy(player) and enemyColor or teamColor
    end
end

local function clearPlayerESP(player)
    if espCache[player] then
        pcall(function() 
            espCache[player].Enabled = false
            espCache[player]:Destroy() 
        end)
        espCache[player] = nil
    end
    if chamsCache[player] then
        pcall(function() 
            chamsCache[player].Enabled = false
            chamsCache[player]:Destroy() 
        end)
        chamsCache[player] = nil
    end
end

local function clearAllESP()
    for player in pairs(espCache) do
        clearPlayerESP(player)
    end
    for player in pairs(chamsCache) do
        clearPlayerESP(player)
    end
    espCache = {}
    chamsCache = {}
end

local function updateESP()
    if not espMasterEnabled then return end
    
    local currentTime = tick()
    if currentTime - lastESPCheck < ESP_UPDATE_INTERVAL then return end
    lastESPCheck = currentTime
    
    local localCharacter = LocalPlayer.Character
    local localHRP = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
    if not localHRP then return end
    
    for _, player in ipairs(cachedPlayers) do
        if player == LocalPlayer then continue end
        
        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        
        if not character or not hrp then
            clearPlayerESP(player)
            continue
        end
        
        local distance = (hrp.Position - localHRP.Position).Magnitude
        
        if distance > espMaxDistance then
            if espCache[player] then espCache[player].Enabled = false end
            if chamsCache[player] then chamsCache[player].Enabled = false end
            continue
        end
        
        if outlinesEnabled then
            if not espCache[player] or not espCache[player].Parent then
                local highlight = Instance.new("Highlight")
                highlight.Name = "SurfyESP"
                highlight.Adornee = character
                highlight.FillTransparency = 1
                highlight.OutlineColor = getPlayerColor(player)
                highlight.OutlineTransparency = 0
                highlight.Parent = character
                espCache[player] = highlight
            end
            espCache[player].Enabled = true
            espCache[player].OutlineColor = getPlayerColor(player)
        elseif espCache[player] then
            espCache[player].Enabled = false
        end
        
        if chamsEnabled then
            if not chamsCache[player] or not chamsCache[player].Parent then
                local highlight = Instance.new("Highlight")
                highlight.Name = "SurfyChams"
                highlight.Adornee = character
                highlight.FillColor = getPlayerColor(player)
                highlight.FillTransparency = 0.4
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.OutlineTransparency = 0.5
                highlight.Parent = character
                chamsCache[player] = highlight
            end
            chamsCache[player].Enabled = true
            chamsCache[player].FillColor = getPlayerColor(player)
        elseif chamsCache[player] then
            chamsCache[player].Enabled = false
        end
    end
end

-- ===== ESP CONTROLS =====
SurfyUI:CreateToggle(PlayerESPSection, {
    Title = "Player ESP Toggle",
    Default = false,
    LayoutOrder = 30,
    Callback = function(Value)
        espMasterEnabled = Value
        
        if Value then
            if not espUpdateConnection then
                espUpdateConnection = RunService.Heartbeat:Connect(updateESP)
            end
        else
            if espUpdateConnection then
                espUpdateConnection:Disconnect()
                espUpdateConnection = nil
            end
            clearAllESP()
        end
        
        SurfyUI:CreateNotification({
            Title = "Player ESP",
            Description = Value and "Enabled" or "Disabled",
            Duration = 2
        })
    end
})

SurfyUI:CreateToggle(PlayerESPSection, {
    Title = "Outline ESP",
    Default = false,
    LayoutOrder = 31,
    Callback = function(Value)
        outlinesEnabled = Value
        if not Value then
            for _, highlight in pairs(espCache) do
                highlight.Enabled = false
            end
        end
    end
})

SurfyUI:CreateToggle(PlayerESPSection, {
    Title = "Chams ESP",
    Default = false,
    LayoutOrder = 32,
    Callback = function(Value)
        chamsEnabled = Value
        if not Value then
            for _, highlight in pairs(chamsCache) do
                highlight.Enabled = false
            end
        end
    end
})

SurfyUI:CreateToggle(PlayerESPSection, {
    Title = "Team Based Coloring",
    Default = false,
    LayoutOrder = 33,
    Callback = function(Value)
        teamBasedColoring = Value
    end
})

SurfyUI:CreateColorPicker(PlayerESPSection, {
    Title = "Enemy ESP Color",
    Default = Color3.fromRGB(255, 50, 50),
    LayoutOrder = 34,
    Callback = function(Value)
        enemyColor = Value
    end
})

SurfyUI:CreateColorPicker(PlayerESPSection, {
    Title = "Team ESP Color",
    Default = Color3.fromRGB(50, 255, 50),
    LayoutOrder = 35,
    Callback = function(Value)
        teamColor = Value
    end
})

-- ===== OPTIMIZED BHOP SYSTEM =====
local bhopEnabled = false
local bhopMode = "Exploit Bhop"
local legitBhopConnection = nil

local function enableExploitBhop(enabled)
    local success, err = pcall(function()
        if RepStorage:FindFirstChild("VIPSettings") and RepStorage.VIPSettings:FindFirstChild("SpeedDemon") then
            RepStorage.VIPSettings.SpeedDemon.Value = enabled
        end
    end)
    return success
end

local function enableLegitBhop(enabled)
    if legitBhopConnection then
        legitBhopConnection:Disconnect()
        legitBhopConnection = nil
    end
    
    if not enabled then return end
    
    local lastJumpTime = 0
    local jumpCooldown = 0.05
    
    legitBhopConnection = RunService.Heartbeat:Connect(function()
        if not bhopEnabled or bhopMode ~= "Legit Bhop" then return end
        if not LocalPlayer.Character then return end
        
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        
        if not humanoid or not hrp then return end
        
        local isSpaceHeld = UserInputService:IsKeyDown(Enum.KeyCode.Space)
        local currentTime = tick()
        
        if isSpaceHeld and (currentTime - lastJumpTime) >= jumpCooldown then
            local state = humanoid:GetState()
            
            if state == Enum.HumanoidStateType.Landed or 
               state == Enum.HumanoidStateType.Running or
               state == Enum.HumanoidStateType.RunningNoPhysics then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                lastJumpTime = currentTime
            end
        end
    end)
end

SurfyUI:CreateToggle(BhopSection, {
    Title = "Bhop Toggle",
    Default = false,
    LayoutOrder = 40,
    Callback = function(Value)
        bhopEnabled = Value
        
        if Value then
            if bhopMode == "Exploit Bhop" then
                local success = enableExploitBhop(true)
                enableLegitBhop(false)
                SurfyUI:CreateNotification({
                    Title = "Bhop",
                    Description = success and "Exploit Bhop Enabled" or "Failed to enable",
                    Duration = 2
                })
            else
                enableExploitBhop(false)
                enableLegitBhop(true)
                SurfyUI:CreateNotification({
                    Title = "Bhop",
                    Description = "Legit Bhop Enabled",
                    Duration = 2
                })
            end
        else
            enableExploitBhop(false)
            enableLegitBhop(false)
            SurfyUI:CreateNotification({
                Title = "Bhop",
                Description = "Disabled",
                Duration = 2
            })
        end
    end
})

SurfyUI:CreateDropdown(BhopSection, {
    Title = "Bhop Mode",
    Options = {"Exploit Bhop", "Legit Bhop"},
    Default = "Exploit Bhop",
    LayoutOrder = 41,
    Callback = function(Value)
        bhopMode = Value
        
        if bhopEnabled then
            enableExploitBhop(false)
            enableLegitBhop(false)
            
            task.wait(0.1)
            
            if Value == "Exploit Bhop" then
                local success = enableExploitBhop(true)
                SurfyUI:CreateNotification({
                    Title = "Bhop Mode",
                    Description = success and "Switched to Exploit Bhop" or "Failed to switch",
                    Duration = 2
                })
            else
                enableLegitBhop(true)
                SurfyUI:CreateNotification({
                    Title = "Bhop Mode",
                    Description = "Switched to Legit Bhop",
                    Duration = 2
                })
            end
        end
    end
})

-- ===== ANTI FEATURES =====
local noFallDamageEnabled = false
local fallDamageHook = nil

SurfyUI:CreateToggle(AntiFeaturesSection, {
    Title = "No Fall Damage",
    Default = false,
    LayoutOrder = 50,
    Callback = function(Value)
        noFallDamageEnabled = Value
        
        local folder = RepStorage:FindFirstChild("Folder")
        if folder then
            local spaceFolder = folder:FindFirstChild(" ")
            if spaceFolder then
                local fallDamageRemote = spaceFolder:FindFirstChild("FallDamage")
                if fallDamageRemote then
                    if Value then
                        if not fallDamageHook then
                            local mt = getrawmetatable(fallDamageRemote)
                            local oldNamecall = mt.__namecall
                            setreadonly(mt, false)
                            
                            fallDamageHook = newcclosure(function(self, ...)
                                if noFallDamageEnabled and self == fallDamageRemote then
                                    return nil
                                end
                                return oldNamecall(self, ...)
                            end)
                            
                            mt.__namecall = fallDamageHook
                            setreadonly(mt, true)
                        end
                        SurfyUI:CreateNotification({
                            Title = "No Fall Damage",
                            Description = "Enabled",
                            Duration = 2
                        })
                    else
                        if fallDamageHook then
                            local mt = getrawmetatable(fallDamageRemote)
                            local oldNamecall = mt.__namecall
                            setreadonly(mt, false)
                            mt.__namecall = oldNamecall
                            setreadonly(mt, true)
                            fallDamageHook = nil
                        end
                        SurfyUI:CreateNotification({
                            Title = "No Fall Damage",
                            Description = "Disabled",
                            Duration = 2
                        })
                    end
                end
            end
        end
    end
})

-- ===== OPTIMIZED MAP VOTE SPAM =====
local voteSpamEnabled = false
local voteSpamLoop = nil
local mapVotes = {"Map1", "Map2", "Map3", "Map4"}
local currentVoteIndex = 1

SurfyUI:CreateToggle(VoteSpamSection, {
    Title = "Spam Vote Maps",
    Default = false,
    LayoutOrder = 60,
    Callback = function(Value)
        voteSpamEnabled = Value
        
        if Value then
            voteSpamLoop = task.spawn(function()
                while voteSpamEnabled do
                    pcall(function()
                        local events = RepStorage:FindFirstChild("Events")
                        if events then
                            local voteMap = events:FindFirstChild("VoteMap")
                            if voteMap then
                                local args = {mapVotes[currentVoteIndex]}
                                voteMap:FireServer(unpack(args))
                            end
                        end
                    end)
                    
                    currentVoteIndex = currentVoteIndex + 1
                    if currentVoteIndex > #mapVotes then
                        currentVoteIndex = 1
                    end
                    
                    task.wait(0.5)
                end
            end)
            
            SurfyUI:CreateNotification({
                Title = "Vote Spam",
                Description = "Started spamming map votes",
                Duration = 2
            })
        else
            voteSpamEnabled = false
            if voteSpamLoop then
                task.cancel(voteSpamLoop)
                voteSpamLoop = nil
            end
            
            SurfyUI:CreateNotification({
                Title = "Vote Spam",
                Description = "Stopped spamming",
                Duration = 2
            })
        end
    end
})

-- ===== SETTINGS TAB =====
local UIToggleKeybind = SurfyUI:CreateKeybind(KeybindSection, {
    Title = "Toggle UI",
    Default = Enum.KeyCode.RightShift,
    LayoutOrder = 70,
    Callback = function() end
})

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and not UIToggleKeybind.IsBinding then
        if (input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode == UIToggleKeybind.Key) or
           (input.UserInputType == UIToggleKeybind.Key) then
            Window:Toggle()
        end
    end
end)

-- ===== OPTIMIZED PLAYER CONNECTIONS =====
local function setupPlayerESP(player)
    local function characterAdded()
        clearPlayerESP(player)
        task.wait(0.5)
        if espMasterEnabled then
            updateESP()
        end
    end
    
    local function characterRemoving()
        clearPlayerESP(player)
    end
    
    player.CharacterAdded:Connect(characterAdded)
    player.CharacterRemoving:Connect(characterRemoving)
    
    if player.Character then
        characterAdded()
    end
end

for _, player in ipairs(cachedPlayers) do
    if player ~= LocalPlayer then
        setupPlayerESP(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    updatePlayerCache()
    setupPlayerESP(player)
end)

Players.PlayerRemoving:Connect(function(player)
    updatePlayerCache()
    clearPlayerESP(player)
end)

-- Performance cleanup on script termination
game:GetService("ScriptContext").DescendantRemoving:Connect(function(descendant)
    if descendant == script then
        if hitboxLoop then hitboxLoop:Disconnect() end
        if legitBhopConnection then legitBhopConnection:Disconnect() end
        if espUpdateConnection then espUpdateConnection:Disconnect() end
        if fireConnection then fireConnection:Disconnect() end
        if voteSpamEnabled and voteSpamLoop then
            task.cancel(voteSpamLoop)
        end
        
        resetAllHitboxes()
        clearAllESP()
        
        if fovCircle then
            fovCircle:Remove()
        end
        
        enableExploitBhop(false)
        
        if noFallDamageEnabled and fallDamageHook then
            local folder = RepStorage:FindFirstChild("Folder")
            if folder then
                local spaceFolder = folder:FindFirstChild(" ")
                if spaceFolder then
                    local fallDamageRemote = spaceFolder:FindFirstChild("FallDamage")
                    if fallDamageRemote then
                        local mt = getrawmetatable(fallDamageRemote)
                        local oldNamecall = mt.__namecall
                        setreadonly(mt, false)
                        mt.__namecall = oldNamecall
                        setreadonly(mt, true)
                    end
                end
            end
        end
    end
end)

SurfyUI:CreateNotification({
    Title = "Surfy TC2",
    Description = "Surfy TC2 v3.0\nPress RightShift to toggle UI\nRapid Fire: Grenade & Rocket Launcher",
    Duration = 5
})

print("Surfy TC2 v3.0 - Loaded successfully!")
print("Rapid Fire supports: Grenade Launcher & Rocket Launcher")
