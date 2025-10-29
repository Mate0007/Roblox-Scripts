local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer

local function sendNotification(title, text, duration)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration or 5,
        Icon = "rbxassetid://6034509993"
    })
end

local function createOverlay()
    local containers = {
        game:GetService("CoreGui"),
        player:WaitForChild("PlayerGui"),
        game:GetService("StarterGui")
    }
    
    local overlays = {}
    
    for _, container in pairs(containers) do
        local overlay = Instance.new("ScreenGui")
        overlay.Name = "BlackOverlay"
        overlay.ResetOnSpawn = false
        overlay.ZIndexBehavior = Enum.ZIndexBehavior.Global
        overlay.DisplayOrder = 99999
        overlay.IgnoreGuiInset = true
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.Position = UDim2.new(0, 0, 0, 0)
        frame.BackgroundColor3 = Color3.new(0, 0, 0)
        frame.BorderSizePixel = 0
        frame.BackgroundTransparency = 0
        frame.Parent = overlay
        
        overlay.Parent = container
        overlay.Enabled = false
        table.insert(overlays, overlay)
    end
    
    return overlays
end

local overlays = createOverlay()
local enabled = false

local function toggleOverlay()
    enabled = not enabled
    for _, overlay in pairs(overlays) do
        overlay.Enabled = enabled
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.T then
        toggleOverlay()
    end
end)

sendNotification("Black Overlay", "Toggle with keybind: T", 60)

print("Black Overlay loaded! Press T to toggle.")
