-- Surfy TC2 - Enhanced UI with Smooth Animations v2
-- Load the FluentUI Library from GitHub
local FluentUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Mate0007/Roblox-Scripts/main/library.lua"))()

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RepStorage = game:GetService("ReplicatedStorage")

-- Anti-AFK
local VirtualUser = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- ===== TC2 SCRIPT IMPLEMENTATION =====

local Window = FluentUI:CreateWindow({
    Title = "Surfy TC2"
})

local CombatTab = Window:CreateTab("Combat")
local VisualsTab = Window:CreateTab("Visuals")
local MiscTab = Window:CreateTab("Misc")
local SettingsTab = Window:CreateTab("Settings")

-- ===== COMBAT SECTIONS =====
local AimbotSection = Window:CreateSection(CombatTab, "Aimbot / Aimlock")
local HitboxSection = Window:CreateSection(CombatTab, "Hitbox Expander")
local RapidFireSection = Window:CreateSection(CombatTab, "Rapid Fire")

-- ===== VISUALS SECTIONS =====
local PlayerESPSection = Window:CreateSection(VisualsTab, "Player ESP")

-- ===== MISC SECTIONS =====
local BhopSection = Window:CreateSection(MiscTab, "Bhop Features")
local VoteSpamSection = Window:CreateSection(MiscTab, "Vote Spam")

-- ===== SETTINGS SECTIONS =====
local KeybindSection = Window:CreateSection(SettingsTab, "Keybind Settings")

-- ===== AIMBOT / AIMLOCK SYSTEM =====
local aimbotEnabled = false
local wallcheckEnabled = false
local targetEnemyOnly = true
local aimbotFOV = 100
local targetBodyPart = "Head"
local aimbotSmoothness = 0.5

local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.NumSides = 50
fovCircle.Radius = aimbotFOV
fovCircle.Filled = false
fovCircle.Visible = false
fovCircle.ZIndex = 999
fovCircle.Transparency = 1
fovCircle.Color = Color3.fromRGB(0, 180, 255)

-- Efficient wallcheck with caching
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
raycastParams.IgnoreWater = true

local function hasLineOfSight(targetPart)
    if not wallcheckEnabled then return true end
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Head") then return false end
    
    local origin = LocalPlayer.Character.Head.Position
    local direction = (targetPart.Position - origin)
    
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetPart.Parent}
    
    local rayResult = workspace:Raycast(origin, direction, raycastParams)
    
    return rayResult == nil
end

local function getClosestPlayerInFOV()
    local closestPlayer = nil
    local shortestDistance = aimbotFOV
    
    local camera = workspace.CurrentCamera
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if targetEnemyOnly and player.Team == LocalPlayer.Team then continue end
            
            local character = player.Character
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
    local targetCFrame = CFrame.new(camera.CFrame.Position, targetPos)
    
    camera.CFrame = currentCFrame:Lerp(targetCFrame, aimbotSmoothness)
end

-- ===== AIMBOT CONTROLS IN CORRECT ORDER =====
local isAimbotKeyHeld = false

local AimbotKeybind = Window:CreateToggleWithKeybind(AimbotSection, {
    Title = "Aimbot",
    Default = false,
    DefaultKey = Enum.UserInputType.MouseButton2,
    LayoutOrder = 1,
    Callback = function(Value)
        aimbotEnabled = Value
        Window:CreateNotification({
            Title = "Aimbot",
            Description = Value and "Enabled" or "Disabled",
            Duration = 2
        })
    end,
    KeybindCallback = function()
        isAimbotKeyHeld = true
    end
})

-- Track keybind release
UserInputService.InputEnded:Connect(function(input)
    if aimbotEnabled then
        if (input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode == AimbotKeybind.Key) or
           (input.UserInputType == AimbotKeybind.Key) then
            isAimbotKeyHeld = false
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        local mouseLocation = UserInputService:GetMouseLocation()
        fovCircle.Position = mouseLocation
        fovCircle.Radius = aimbotFOV
        fovCircle.Visible = true
        
        if isAimbotKeyHeld then
            local target = getClosestPlayerInFOV()
            if target then
                aimAtPlayer(target)
            end
        end
    else
        fovCircle.Visible = false
        isAimbotKeyHeld = false
    end
end)

Window:CreateToggle(AimbotSection, {
    Title = "Wallcheck",
    Default = false,
    LayoutOrder = 2,
    Callback = function(Value)
        wallcheckEnabled = Value
    end
})

Window:CreateToggle(AimbotSection, {
    Title = "Target Enemy Only",
    Default = true,
    LayoutOrder = 3,
    Callback = function(Value)
        targetEnemyOnly = Value
    end
})

Window:CreateSlider(AimbotSection, {
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

Window:CreateDropdown(AimbotSection, {
    Title = "Target Body Part",
    Options = {"Head", "Neck", "Body"},
    Default = "Head",
    LayoutOrder = 5,
    Callback = function(Value)
        targetBodyPart = Value
    end
})

Window:CreateSlider(AimbotSection, {
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

-- ===== HITBOX EXPANDER =====
local hitboxEnabled = false
local hitboxSize = 15
local hitboxLoop = nil
local showHitbox = false
local hitboxTarget = "Head"
local ExpandableHitboxes = {
    Head = {"HeadHB"},
    Body = {"Hitbox"}
}

local function ExpandPart(part, size, isTarget)
    if part then
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
end

local function updateHitboxes()
    for _, player in Players:GetPlayers() do 
        local Character = player.Character
        if Character then
            if player.Team ~= LocalPlayer.Team then
                -- Expand target hitbox
                for hitboxType, hitboxNames in pairs(ExpandableHitboxes) do
                    for _, hitboxName in pairs(hitboxNames) do
                        local hitbox = Character:FindFirstChild(hitboxName)
                        if hitbox then
                            if hitboxType == hitboxTarget then
                                ExpandPart(hitbox, Vector3.one * hitboxSize, true)
                            else
                                -- Reset non-target hitboxes to normal
                                if hitboxName == "HeadHB" then
                                    ExpandPart(hitbox, Vector3.new(2, 2, 2), false)
                                elseif hitboxName == "Hitbox" then
                                    ExpandPart(hitbox, Vector3.new(5.59, 5.175, 5.175), false)
                                end
                            end
                        end
                    end
                end
            else
                -- Reset teammate hitboxes
                ExpandPart(Character:FindFirstChild("HeadHB"), Vector3.new(2, 2, 2), false)
                ExpandPart(Character:FindFirstChild("Hitbox"), Vector3.new(5.59, 5.175, 5.175), false)
            end
        end
    end
end

Window:CreateToggle(HitboxSection, {
    Title = "Hitbox Expander",
    Default = false,
    Callback = function(Value)
        hitboxEnabled = Value
        if Value then
            hitboxLoop = RunService.Heartbeat:Connect(function()
                updateHitboxes()
            end)
            Window:CreateNotification({
                Title = "Hitbox Expander",
                Description = "Enabled",
                Duration = 2
            })
        else
            if hitboxLoop then
                hitboxLoop:Disconnect()
                hitboxLoop = nil
            end
            -- Reset all hitboxes
            for _, player in Players:GetPlayers() do 
                local Character = player.Character
                if Character then
                    local headHB = Character:FindFirstChild("HeadHB")
                    local bodyHB = Character:FindFirstChild("Hitbox")
                    if headHB then
                        headHB.Size = Vector3.new(2, 2, 2)
                        headHB.Transparency = 1
                        if headHB:FindFirstChild("HitboxOutline") then
                            headHB.HitboxOutline:Destroy()
                        end
                    end
                    if bodyHB then
                        bodyHB.Size = Vector3.new(5.59, 5.175, 5.175)
                        bodyHB.Transparency = 1
                        if bodyHB:FindFirstChild("HitboxOutline") then
                            bodyHB.HitboxOutline:Destroy()
                        end
                    end
                end
            end
            Window:CreateNotification({
                Title = "Hitbox Expander",
                Description = "Disabled",
                Duration = 2
            })
        end
    end
})

Window:CreateDropdown(HitboxSection, {
    Title = "Hitbox Target",
    Options = {"Head", "Body"},
    Default = "Head",
    Callback = function(Value)
        hitboxTarget = Value
    end
})

Window:CreateSlider(HitboxSection, {
    Title = "Hitbox Size",
    Default = 15,
    Min = 5,
    Max = 50,
    Rounding = 0,
    Callback = function(Value)
        hitboxSize = Value
    end
})

Window:CreateToggle(HitboxSection, {
    Title = "Show Hitbox",
    Default = false,
    Callback = function(Value)
        showHitbox = Value
        updateHitboxes()
    end
})

-- ===== RAPID FIRE SYSTEM =====
local rapidFireEnabled = false
local rapidFireRate = 0.1
local isHoldingLeftClick = false
local capturedRemote = nil
local spaceFolder = nil
local character = nil
local hrp = nil
local rapidFireLoop = nil
local rapidFireNotification = nil

-- Get folder once
local function initializeFolder()
    if spaceFolder then return true end
    
    local folder = RepStorage:FindFirstChild("Folder")
    if not folder then return false end
    
    spaceFolder = folder:FindFirstChild(" ")
    return spaceFolder ~= nil
end

-- Find remote once and cache it
local function findRemote()
    if capturedRemote then return capturedRemote end
    
    if not initializeFolder() then return nil end
    
    for _, child in pairs(spaceFolder:GetChildren()) do
        if child:IsA("RemoteEvent") then
            capturedRemote = child
            return child
        end
    end
end

-- Optimized args function with caching
local function getGrenadeArgs()
    -- Update character cache if needed
    if not character or not character.Parent then
        character = LocalPlayer.Character
        if not character then return nil end
        hrp = character:FindFirstChild("HumanoidRootPart")
    end
    
    if not hrp then return nil end
    
    local mouse = LocalPlayer:GetMouse()
    local pos = hrp.Position
    local mousePos = mouse.Hit.Position
    local firePos = pos + Vector3.new(0, 1.57, 0)
    local dir = (mousePos - firePos).Unit
    
    return {
        mousePos,
        "Grenade",
        CFrame.new(firePos, firePos + dir),
        "Grenade Launcher",
        pos,
        [9] = false,
        [11] = 0
    }
end

-- Fire loop
local function fireLoop()
    local remote = findRemote()
    if not remote then
        if rapidFireNotification then
            rapidFireNotification = nil
        end
        Window:CreateNotification({
            Title = "Rapid Fire",
            Description = "No remote found!",
            Duration = 3
        })
        return
    end
    
    -- Show persistent notification
    if not rapidFireNotification then
        rapidFireNotification = true
        Window:CreateNotification({
            Title = "Rapid Fire",
            Description = "Only works with grenade launcher for now",
            Duration = 999999
        })
    end
    
    while isHoldingLeftClick and rapidFireEnabled do
        local args = getGrenadeArgs()
        if args then
            pcall(function()
                remote:FireServer(unpack(args))
            end)
        end
        task.wait(rapidFireRate)
    end
end

-- Update character cache when it respawns
LocalPlayer.CharacterAdded:Connect(function(char)
    character = char
    hrp = char:WaitForChild("HumanoidRootPart")
end)

-- Rapid Fire Toggle
Window:CreateToggle(RapidFireSection, {
    Title = "Rapid Fire",
    Default = false,
    LayoutOrder = 1,
    Callback = function(Value)
        rapidFireEnabled = Value
        if Value then
            Window:CreateNotification({
                Title = "Rapid Fire",
                Description = "Enabled - Hold LEFT CLICK to fire",
                Duration = 3
            })
        else
            isHoldingLeftClick = false
            rapidFireNotification = nil
            Window:CreateNotification({
                Title = "Rapid Fire",
                Description = "Disabled",
                Duration = 2
            })
        end
    end
})

-- Fire Rate Slider
Window:CreateSlider(RapidFireSection, {
    Title = "Fire Rate Delay",
    Default = 0.1,
    Min = 0.15,
    Max = 0.5,
    Rounding = 2,
    LayoutOrder = 2,
    Callback = function(Value)
        rapidFireRate = Value
    end
})

-- Left Click Detection
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 and rapidFireEnabled then
        if not isHoldingLeftClick then
            isHoldingLeftClick = true
            task.spawn(fireLoop)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isHoldingLeftClick = false
    end
end)

-- ===== PLAYER ESP SYSTEM =====
local espMasterEnabled = false
local outlinesEnabled = false
local chamsEnabled = false
local teamBasedColoring = false
local espMaxDistance = 500
local enemyColor = Color3.fromRGB(255, 50, 50)
local teamColor = Color3.fromRGB(50, 255, 50)

local espCache = {}
local chamsCache = {}

local function isEnemy(player)
    return player.Team ~= LocalPlayer.Team
end

local function getPlayerColor(player)
    if teamBasedColoring then
        -- Team-based: Red for enemies, Green for teammates
        return isEnemy(player) and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(50, 255, 50)
    else
        -- Custom colors set by user
        return isEnemy(player) and enemyColor or teamColor
    end
end

local function clearPlayerESP(player)
    if espCache[player] then
        pcall(function() espCache[player]:Destroy() end)
        espCache[player] = nil
    end
    if chamsCache[player] then
        pcall(function() chamsCache[player]:Destroy() end)
        chamsCache[player] = nil
    end
end

local function updateESP()
    for _, player in Players:GetPlayers() do
        if player ~= LocalPlayer then
            if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
                clearPlayerESP(player)
                continue
            end
            
            local hrp = player.Character.HumanoidRootPart
            local distance = (hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            
            if distance > espMaxDistance then
                if espCache[player] then espCache[player].Enabled = false end
                if chamsCache[player] then chamsCache[player].Enabled = false end
                continue
            end
            
            if espMasterEnabled then
                if outlinesEnabled then
                    if not espCache[player] or not espCache[player].Parent then
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "SurfyESP"
                        highlight.Adornee = player.Character
                        highlight.FillTransparency = 1
                        highlight.OutlineColor = getPlayerColor(player)
                        highlight.OutlineTransparency = 0
                        highlight.Parent = player.Character
                        espCache[player] = highlight
                    end
                    espCache[player].Enabled = true
                    espCache[player].OutlineColor = getPlayerColor(player)
                else
                    if espCache[player] and espCache[player].Parent then
                        espCache[player].Enabled = false
                    end
                end
                
                if chamsEnabled then
                    if not chamsCache[player] or not chamsCache[player].Parent then
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "SurfyChams"
                        highlight.Adornee = player.Character
                        highlight.FillColor = getPlayerColor(player)
                        highlight.FillTransparency = 0.4
                        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                        highlight.OutlineTransparency = 0.5
                        highlight.Parent = player.Character
                        chamsCache[player] = highlight
                    end
                    chamsCache[player].Enabled = true
                    chamsCache[player].FillColor = getPlayerColor(player)
                else
                    if chamsCache[player] and chamsCache[player].Parent then
                        chamsCache[player].Enabled = false
                    end
                end
            else
                if espCache[player] and espCache[player].Parent then
                    espCache[player].Enabled = false
                end
                if chamsCache[player] and chamsCache[player].Parent then
                    chamsCache[player].Enabled = false
                end
            end
        end
    end
end

-- ===== ESP CONTROLS IN CORRECT ORDER =====
Window:CreateToggle(PlayerESPSection, {
    Title = "Player ESP Toggle",
    Default = false,
    LayoutOrder = 1,
    Callback = function(Value)
        espMasterEnabled = Value
        updateESP()
        Window:CreateNotification({
            Title = "Player ESP",
            Description = Value and "Enabled" or "Disabled",
            Duration = 2
        })
    end
})

Window:CreateToggle(PlayerESPSection, {
    Title = "Outline ESP",
    Default = false,
    LayoutOrder = 2,
    Callback = function(Value)
        outlinesEnabled = Value
        updateESP()
    end
})

Window:CreateToggle(PlayerESPSection, {
    Title = "Chams ESP",
    Default = false,
    LayoutOrder = 3,
    Callback = function(Value)
        chamsEnabled = Value
        updateESP()
    end
})

Window:CreateToggle(PlayerESPSection, {
    Title = "Team Based Coloring",
    Default = false,
    LayoutOrder = 4,
    Callback = function(Value)
        teamBasedColoring = Value
        updateESP()
    end
})

Window:CreateSlider(PlayerESPSection, {
    Title = "ESP Distance",
    Default = 500,
    Min = 50,
    Max = 2000,
    Rounding = 0,
    LayoutOrder = 5,
    Callback = function(Value)
        espMaxDistance = Value
        updateESP()
    end
})

Window:CreateColorPicker(PlayerESPSection, {
    Title = "Enemy ESP Color",
    Default = Color3.fromRGB(255, 50, 50),
    LayoutOrder = 6,
    Callback = function(Value)
        enemyColor = Value
        updateESP()
    end
})

Window:CreateColorPicker(PlayerESPSection, {
    Title = "Team ESP Color", 
    Default = Color3.fromRGB(50, 255, 50),
    LayoutOrder = 7,
    Callback = function(Value)
        teamColor = Value
        updateESP()
    end
})

-- ===== BHOP SYSTEM =====
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

Window:CreateToggle(BhopSection, {
    Title = "Bhop Toggle",
    Default = false,
    LayoutOrder = 1,
    KeybindHint = "Hold Space",
    Callback = function(Value)
        bhopEnabled = Value
        
        if Value then
            if bhopMode == "Exploit Bhop" then
                local success = enableExploitBhop(true)
                enableLegitBhop(false)
                Window:CreateNotification({
                    Title = "Bhop",
                    Description = success and "Exploit Bhop Enabled" or "Failed to enable",
                    Duration = 2
                })
            else
                enableExploitBhop(false)
                enableLegitBhop(true)
                Window:CreateNotification({
                    Title = "Bhop",
                    Description = "Legit Bhop Enabled",
                    Duration = 2
                })
            end
        else
            enableExploitBhop(false)
            enableLegitBhop(false)
            Window:CreateNotification({
                Title = "Bhop",
                Description = "Disabled",
                Duration = 2
            })
        end
    end
})

Window:CreateDropdown(BhopSection, {
    Title = "Bhop Mode",
    Options = {"Exploit Bhop", "Legit Bhop"},
    Default = "Exploit Bhop",
    LayoutOrder = 2,
    Callback = function(Value)
        bhopMode = Value
        
        if bhopEnabled then
            enableExploitBhop(false)
            enableLegitBhop(false)
            
            task.wait(0.1)
            
            if Value == "Exploit Bhop" then
                local success = enableExploitBhop(true)
                Window:CreateNotification({
                    Title = "Bhop Mode",
                    Description = success and "Switched to Exploit Bhop" or "Failed to switch",
                    Duration = 2
                })
            else
                enableLegitBhop(true)
                Window:CreateNotification({
                    Title = "Bhop Mode",
                    Description = "Switched to Legit Bhop",
                    Duration = 2
                })
            end
        end
    end
})

-- ===== MAP VOTE SPAM =====
local voteSpamEnabled = false
local voteSpamLoop = nil
local mapVotes = {"Map1", "Map2", "Map3", "Map4"}
local currentVoteIndex = 1

Window:CreateToggle(VoteSpamSection, {
    Title = "Spam Vote Maps",
    Default = false,
    Callback = function(Value)
        voteSpamEnabled = Value
        
        if Value then
            voteSpamLoop = task.spawn(function()
                while voteSpamEnabled do
                    pcall(function()
                        local args = {mapVotes[currentVoteIndex]}
                        game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("VoteMap"):FireServer(unpack(args))
                    end)
                    
                    currentVoteIndex = currentVoteIndex + 1
                    if currentVoteIndex > #mapVotes then
                        currentVoteIndex = 1
                    end
                    
                    task.wait(0.1)
                end
            end)
            
            Window:CreateNotification({
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
            
            Window:CreateNotification({
                Title = "Vote Spam",
                Description = "Stopped spamming",
                Duration = 2
            })
        end
    end
})

-- ===== SETTINGS TAB =====
local UIToggleKeybind = Window:CreateKeybind(KeybindSection, {
    Title = "Toggle UI",
    Default = Enum.KeyCode.RightShift,
    Callback = function() end
})

-- Override the UI toggle functionality
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and not UIToggleKeybind.IsBinding then
        if (input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode == UIToggleKeybind.Key) or
           (input.UserInputType == UIToggleKeybind.Key) then
            Window:Toggle()
        end
    end
end)

-- ===== PLAYER CONNECTIONS =====
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        clearPlayerESP(player)
        task.wait(0.5)
        updateESP()
    end)
    
    player.CharacterRemoving:Connect(function()
        clearPlayerESP(player)
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    clearPlayerESP(player)
end)

for _, player in Players:GetPlayers() do
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function()
            clearPlayerESP(player)
            task.wait(0.5)
            updateESP()
        end)
        
        player.CharacterRemoving:Connect(function()
            clearPlayerESP(player)
        end)
    end
end

task.spawn(function()
    while task.wait(1) do
        if espMasterEnabled then
            updateESP()
        end
    end
end)

Window:CreateNotification({
    Title = "Surfy TC2",
    Description = "Press RightShift to toggle UI",
    Duration = 4
})

print("Surfy TC2 Enhanced - Loaded Successfully")
