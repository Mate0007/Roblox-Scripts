-- Surfy TC2 - Vape-Style Bottom Drawer UI
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

local SurfyUI = {}
SurfyUI.__index = SurfyUI

-- Aqua Gradient Theme
SurfyUI.Theme = {
    Primary = Color3.fromRGB(0, 230, 255),
    PrimaryDark = Color3.fromRGB(0, 180, 230),
    PrimaryBright = Color3.fromRGB(100, 255, 255),
    Secondary = Color3.fromRGB(0, 150, 200),
    Background = Color3.fromRGB(12, 15, 25),
    Surface = Color3.fromRGB(18, 22, 35),
    SurfaceLight = Color3.fromRGB(25, 30, 45),
    Accent = Color3.fromRGB(0, 200, 240),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(150, 170, 200),
    Active = Color3.fromRGB(0, 255, 200),
    Inactive = Color3.fromRGB(60, 70, 90)
}

-- Lucide Icons (SVG paths converted to unicode/text representations)
SurfyUI.Icons = {
    Combat = "⚔",      -- sword
    Visuals = "👁",     -- eye
    Movement = "⚡",    -- zap
    Player = "👤",      -- user
    World = "🌍",       -- globe
    Misc = "⚙"         -- settings
}

local function Tween(obj, props, duration, style)
    local info = TweenInfo.new(duration or 0.3, style or Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    TweenService:Create(obj, info, props):Play()
end

local function Round(obj, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = obj
    return corner
end

local function AddGradient(obj, color1, color2, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new(color1, color2)
    gradient.Rotation = rotation or 90
    gradient.Parent = obj
    return gradient
end

local function AddStroke(obj, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0.5
    stroke.Parent = obj
    return stroke
end

-- Create Lucide-style icon
local function CreateIcon(parent, iconName)
    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, 20, 0, 20)
    icon.Position = UDim2.new(0.5, -10, 0.5, -10)
    icon.BackgroundTransparency = 1
    icon.ImageColor3 = SurfyUI.Theme.TextDim
    icon.ScaleType = Enum.ScaleType.Fit
    
    -- Icon mappings to Roblox asset IDs or create custom frames
    local iconPaths = {
        Combat = "rbxassetid://7733992358",     -- sword icon
        Visuals = "rbxassetid://7733920644",    -- eye icon  
        Movement = "rbxassetid://7734000129",   -- zap icon
        Player = "rbxassetid://7743871002",     -- user icon
        World = "rbxassetid://7733954760",      -- globe icon
        Misc = "rbxassetid://7734053495"        -- settings icon
    }
    
    icon.Image = iconPaths[iconName] or iconPaths.Misc
    icon.Parent = parent
    
    return icon
end

function SurfyUI:CreateNotification(config)
    config = config or {}
    
    local ScreenGui = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("SurfyUI")
    if not ScreenGui then return end
    
    local Notification = Instance.new("Frame")
    Notification.Name = "Notification"
    Notification.Size = UDim2.new(0, 320, 0, 70)
    Notification.Position = UDim2.new(1, 340, 0, 20)
    Notification.BackgroundColor3 = SurfyUI.Theme.Surface
    Notification.BackgroundTransparency = 0.1
    Notification.BorderSizePixel = 0
    Notification.ZIndex = 10000
    Notification.Parent = ScreenGui
    
    Round(Notification, 12)
    AddStroke(Notification, SurfyUI.Theme.Primary, 1.5, 0.4)
    
    -- Gradient overlay
    local Overlay = Instance.new("Frame")
    Overlay.Size = UDim2.new(1, 0, 1, 0)
    Overlay.BackgroundTransparency = 0.92
    Overlay.BorderSizePixel = 0
    Overlay.ZIndex = 10000
    Overlay.Parent = Notification
    
    Round(Overlay, 12)
    AddGradient(Overlay, SurfyUI.Theme.Primary, SurfyUI.Theme.Background, 135)
    
    -- Top accent
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 2)
    TopBar.BackgroundColor3 = SurfyUI.Theme.Primary
    TopBar.BorderSizePixel = 0
    TopBar.ZIndex = 10001
    TopBar.Parent = Notification
    
    AddGradient(TopBar, SurfyUI.Theme.PrimaryBright, SurfyUI.Theme.Primary, 90)
    
    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 12)
    TopCorner.Parent = TopBar
    
    -- Status dot
    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 6, 0, 6)
    Dot.Position = UDim2.new(0, 12, 0, 14)
    Dot.BackgroundColor3 = SurfyUI.Theme.Active
    Dot.BorderSizePixel = 0
    Dot.ZIndex = 10001
    Dot.Parent = Notification
    
    Round(Dot, 3)
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -50, 0, 20)
    Title.Position = UDim2.new(0, 24, 0, 10)
    Title.BackgroundTransparency = 1
    Title.Text = config.Title or "Surfy Loaded"
    Title.TextColor3 = SurfyUI.Theme.Text
    Title.TextSize = 13
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 10001
    Title.Parent = Notification
    
    local Description = Instance.new("TextLabel")
    Description.Size = UDim2.new(1, -50, 0, 35)
    Description.Position = UDim2.new(0, 24, 0, 32)
    Description.BackgroundTransparency = 1
    Description.Text = config.Description or "UI initialized successfully"
    Description.TextColor3 = SurfyUI.Theme.TextDim
    Description.TextSize = 11
    Description.Font = Enum.Font.Gotham
    Description.TextXAlignment = Enum.TextXAlignment.Left
    Description.TextYAlignment = Enum.TextYAlignment.Top
    Description.TextWrapped = true
    Description.ZIndex = 10001
    Description.Parent = Notification
    
    -- Close button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 18, 0, 18)
    CloseBtn.Position = UDim2.new(1, -24, 0, 8)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = SurfyUI.Theme.TextDim
    CloseBtn.TextSize = 18
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.ZIndex = 10002
    CloseBtn.Parent = Notification
    
    CloseBtn.MouseEnter:Connect(function()
        CloseBtn.TextColor3 = SurfyUI.Theme.Text
    end)
    
    CloseBtn.MouseLeave:Connect(function()
        CloseBtn.TextColor3 = SurfyUI.Theme.TextDim
    end)
    
    Tween(Notification, {Position = UDim2.new(1, -330, 0, 20)}, 0.5, Enum.EasingStyle.Back)
    
    local function Remove()
        Tween(Notification, {Position = UDim2.new(1, 340, 0, 20)}, 0.4, Enum.EasingStyle.Back)
        task.wait(0.4)
        Notification:Destroy()
    end
    
    CloseBtn.MouseButton1Click:Connect(Remove)
    task.delay(config.Duration or 4, Remove)
end

function SurfyUI:CreateWindow(config)
    config = config or {}
    
    local Window = {
        Modules = {},
        CurrentCategory = nil,
        IsOpen = false,
        Categories = {}
    }
    setmetatable(Window, SurfyUI)
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SurfyUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 999999
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Send load notification
    task.delay(0.1, function()
        self:CreateNotification({
            Title = "Surfy TC2",
            Description = "Press the line to open menu",
            Duration = 5
        })
    end)
    
    -- Drag Line (JUST A SIMPLE WHITE LINE)
    local DragLine = Instance.new("Frame")
    DragLine.Name = "DragLine"
    DragLine.Size = UDim2.new(0, 60, 0, 3)
    DragLine.Position = UDim2.new(0.5, -30, 1, -15)
    DragLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    DragLine.BackgroundTransparency = 0.3
    DragLine.BorderSizePixel = 0
    DragLine.ZIndex = 10000
    DragLine.Parent = ScreenGui
    
    Round(DragLine, 2)
    
    -- Make the line clickable
    local DragButton = Instance.new("TextButton")
    DragButton.Size = UDim2.new(1, 20, 1, 20)
    DragButton.Position = UDim2.new(0, -10, 0, -10)
    DragButton.BackgroundTransparency = 1
    DragButton.Text = ""
    DragButton.ZIndex = 10001
    DragButton.Parent = DragLine
    
    -- Bottom Bar (Hidden, contains icons)
    local BottomBar = Instance.new("Frame")
    BottomBar.Name = "BottomBar"
    BottomBar.Size = UDim2.new(0, 500, 0, 60)
    BottomBar.Position = UDim2.new(0.5, -250, 1, 10)
    BottomBar.BackgroundColor3 = SurfyUI.Theme.Surface
    BottomBar.BackgroundTransparency = 0.1
    BottomBar.BorderSizePixel = 0
    BottomBar.Visible = false
    BottomBar.ZIndex = 9998
    BottomBar.Parent = ScreenGui
    
    Round(BottomBar, 16)
    AddStroke(BottomBar, SurfyUI.Theme.Primary, 2, 0.3)
    
    -- Glow
    local BarGlow = Instance.new("ImageLabel")
    BarGlow.BackgroundTransparency = 1
    BarGlow.Position = UDim2.new(0, -20, 0, -20)
    BarGlow.Size = UDim2.new(1, 40, 1, 40)
    BarGlow.ZIndex = 9997
    BarGlow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    BarGlow.ImageColor3 = SurfyUI.Theme.Primary
    BarGlow.ImageTransparency = 0.8
    BarGlow.Parent = BottomBar
    
    -- Category Icons Container
    local IconContainer = Instance.new("Frame")
    IconContainer.Name = "Icons"
    IconContainer.Size = UDim2.new(1, -20, 1, 0)
    IconContainer.Position = UDim2.new(0, 10, 0, 0)
    IconContainer.BackgroundTransparency = 1
    IconContainer.ZIndex = 9999
    IconContainer.Parent = BottomBar
    
    local IconLayout = Instance.new("UIListLayout")
    IconLayout.FillDirection = Enum.FillDirection.Horizontal
    IconLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    IconLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    IconLayout.Padding = UDim.new(0, 15)
    IconLayout.Parent = IconContainer
    
    -- Main Drawer
    local Drawer = Instance.new("Frame")
    Drawer.Name = "Drawer"
    Drawer.Size = UDim2.new(0, 600, 0, 0)
    Drawer.Position = UDim2.new(0.5, -300, 1, -60)
    Drawer.BackgroundColor3 = SurfyUI.Theme.Background
    Drawer.BackgroundTransparency = 0.05
    Drawer.BorderSizePixel = 0
    Drawer.ClipsDescendants = true
    Drawer.Visible = false
    Drawer.ZIndex = 9998
    Drawer.Parent = ScreenGui
    
    Round(Drawer, 20)
    AddStroke(Drawer, SurfyUI.Theme.Primary, 2, 0.4)
    
    -- Drawer gradient
    local DrawerOverlay = Instance.new("Frame")
    DrawerOverlay.Size = UDim2.new(1, 0, 1, 0)
    DrawerOverlay.BackgroundTransparency = 0.95
    DrawerOverlay.BorderSizePixel = 0
    DrawerOverlay.ZIndex = 9998
    DrawerOverlay.Parent = Drawer
    
    Round(DrawerOverlay, 20)
    AddGradient(DrawerOverlay, SurfyUI.Theme.Primary, SurfyUI.Theme.Background, 180)
    
    -- Module List
    local ModuleList = Instance.new("ScrollingFrame")
    ModuleList.Name = "ModuleList"
    ModuleList.Size = UDim2.new(1, -40, 1, -30)
    ModuleList.Position = UDim2.new(0, 20, 0, 20)
    ModuleList.BackgroundTransparency = 1
    ModuleList.BorderSizePixel = 0
    ModuleList.ScrollBarThickness = 4
    ModuleList.ScrollBarImageColor3 = SurfyUI.Theme.Primary
    ModuleList.ScrollBarImageTransparency = 0.5
    ModuleList.CanvasSize = UDim2.new(0, 0, 0, 0)
    ModuleList.ZIndex = 9999
    ModuleList.Parent = Drawer
    
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Padding = UDim.new(0, 6)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Parent = ModuleList
    
    ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ModuleList.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 20)
    end)
    
    Window.ScreenGui = ScreenGui
    Window.BottomBar = BottomBar
    Window.Drawer = Drawer
    Window.ModuleList = ModuleList
    Window.IconContainer = IconContainer
    Window.DragLine = DragLine
    Window.DragButton = DragButton
    
    -- Drag functionality
    local dragging = false
    local dragStart, startPos
    
    DragButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position.Y
            startPos = Drawer.Position.Y.Offset
            
            Tween(DragLine, {BackgroundTransparency = 0}, 0.2)
        end
    end)
    
    DragButton.MouseButton1Click:Connect(function()
        if not dragging then
            Window:Toggle()
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position.Y - dragStart
            local newY = math.clamp(startPos + delta, -400, 0)
            
            if newY < -100 and not Window.IsOpen then
                Window:Open()
            elseif newY > -50 and Window.IsOpen then
                Window:Close()
            end
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            Tween(DragLine, {BackgroundTransparency = 0.3}, 0.2)
        end
    end)
    
    function Window:Open()
        if self.IsOpen then return end
        self.IsOpen = true
        
        BottomBar.Visible = true
        Drawer.Visible = true
        
        Tween(BottomBar, {Position = UDim2.new(0.5, -250, 1, -475)}, 0.4, Enum.EasingStyle.Back)
        Tween(Drawer, {Size = UDim2.new(0, 600, 0, 400), Position = UDim2.new(0.5, -300, 1, -480)}, 0.4, Enum.EasingStyle.Back)
        Tween(DragLine, {Position = UDim2.new(0.5, -30, 1, -495)}, 0.4, Enum.EasingStyle.Back)
    end
    
    function Window:Close()
        if not self.IsOpen then return end
        self.IsOpen = false
        
        Tween(BottomBar, {Position = UDim2.new(0.5, -250, 1, 10)}, 0.3, Enum.EasingStyle.Quint)
        Tween(Drawer, {Size = UDim2.new(0, 600, 0, 0), Position = UDim2.new(0.5, -300, 1, -60)}, 0.3, Enum.EasingStyle.Quint)
        Tween(DragLine, {Position = UDim2.new(0.5, -30, 1, -15)}, 0.3, Enum.EasingStyle.Quint)
        
        task.wait(0.3)
        BottomBar.Visible = false
        Drawer.Visible = false
    end
    
    function Window:Toggle()
        if self.IsOpen then
            self:Close()
        else
            self:Open()
        end
    end
    
    return Window
end

function SurfyUI:AddCategory(name, icon)
    local Category = {
        Name = name,
        Icon = icon or "Misc",
        Modules = {},
        Button = nil
    }
    
    table.insert(self.Categories, Category)
    
    -- Create icon button
    local IconButton = Instance.new("TextButton")
    IconButton.Name = name
    IconButton.Size = UDim2.new(0, 50, 0, 50)
    IconButton.BackgroundColor3 = SurfyUI.Theme.SurfaceLight
    IconButton.BackgroundTransparency = 0.4
    IconButton.Text = ""
    IconButton.ZIndex = 9999
    IconButton.Parent = self.IconContainer
    
    Round(IconButton, 12)
    
    -- Add icon
    local IconImage = CreateIcon(IconButton, icon)
    IconImage.ZIndex = 10000
    
    -- Glow indicator
    local Glow = Instance.new("Frame")
    Glow.Name = "Glow"
    Glow.Size = UDim2.new(0.8, 0, 0, 3)
    Glow.Position = UDim2.new(0.1, 0, 1, -6)
    Glow.BackgroundColor3 = SurfyUI.Theme.Primary
    Glow.BackgroundTransparency = 1
    Glow.BorderSizePixel = 0
    Glow.ZIndex = 10000
    Glow.Parent = IconButton
    
    Round(Glow, 2)
    AddGradient(Glow, SurfyUI.Theme.PrimaryBright, SurfyUI.Theme.Primary, 90)
    
    Category.Button = IconButton
    Category.Glow = Glow
    Category.Icon = IconImage
    
    IconButton.MouseButton1Click:Connect(function()
        self:SelectCategory(Category)
    end)
    
    IconButton.MouseEnter:Connect(function()
        Tween(IconButton, {BackgroundTransparency = 0.2}, 0.2)
        Tween(IconImage, {ImageColor3 = SurfyUI.Theme.Primary}, 0.2)
    end)
    
    IconButton.MouseLeave:Connect(function()
        if self.CurrentCategory ~= Category then
            Tween(IconButton, {BackgroundTransparency = 0.4}, 0.2)
            Tween(IconImage, {ImageColor3 = SurfyUI.Theme.TextDim}, 0.2)
        end
    end)
    
    if not self.CurrentCategory then
        self:SelectCategory(Category)
    end
    
    return Category
end

function SurfyUI:SelectCategory(category)
    if self.CurrentCategory then
        Tween(self.CurrentCategory.Button, {BackgroundTransparency = 0.4}, 0.2)
        Tween(self.CurrentCategory.Icon, {ImageColor3 = SurfyUI.Theme.TextDim}, 0.2)
        Tween(self.CurrentCategory.Glow, {BackgroundTransparency = 1}, 0.2)
    end
    
    self.CurrentCategory = category
    Tween(category.Button, {BackgroundTransparency = 0.1}, 0.3)
    Tween(category.Icon, {ImageColor3 = SurfyUI.Theme.Primary}, 0.3)
    Tween(category.Glow, {BackgroundTransparency = 0}, 0.3)
    
    self:RefreshModuleList()
    
    if not self.IsOpen then
        self:Open()
    end
end

function SurfyUI:RefreshModuleList()
    for _, child in ipairs(self.ModuleList:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    if not self.CurrentCategory then return end
    
    for _, module in ipairs(self.CurrentCategory.Modules) do
        module:Render()
    end
end

function SurfyUI:AddToggle(category, config)
    config = config or {}
    
    local Module = {
        Name = config.Name or "Toggle",
        Description = config.Description or "",
        Enabled = config.Default or false,
        Keybind = config.Keybind or Enum.KeyCode.Unknown,
        Callback = config.Callback,
        Mode = config.Mode or nil,
        Modes = config.Modes or nil,
        Category = category
    }
    
    function Module:Render()
        local Container = Instance.new("Frame")
        Container.Name = self.Name
        Container.Size = UDim2.new(1, 0, 0, 45)
        Container.BackgroundColor3 = SurfyUI.Theme.Surface
        Container.BackgroundTransparency = 0.3
        Container.BorderSizePixel = 0
        Container.ZIndex = 9999
        Container.Parent = category.Button.Parent.Parent.Parent.Drawer.ModuleList
        
        Round(Container, 10)
        
        -- Active indicator
        local Indicator = Instance.new("Frame")
        Indicator.Name = "Indicator"
        Indicator.Size = UDim2.new(0, 4, 0.7, 0)
        Indicator.Position = UDim2.new(0, 0, 0.15, 0)
        Indicator.BackgroundColor3 = SurfyUI.Theme.Primary
        Indicator.BackgroundTransparency = self.Enabled and 0 or 1
        Indicator.BorderSizePixel = 0
        Indicator.ZIndex = 10000
        Indicator.Parent = Container
        
        Round(Indicator, 2)
        
        if self.Enabled then
            AddGradient(Indicator, SurfyUI.Theme.PrimaryBright, SurfyUI.Theme.Primary, 90)
        end
        
        -- Module name
        local NameLabel = Instance.new("TextLabel")
        NameLabel.Name = "NameLabel"
        NameLabel.Size = UDim2.new(0, 250, 0, 20)
        NameLabel.Position = UDim2.new(0, 15, 0, 8)
        NameLabel.BackgroundTransparency = 1
        NameLabel.Text = self.Name
        NameLabel.TextColor3 = self.Enabled and SurfyUI.Theme.Primary or SurfyUI.Theme.Text
        NameLabel.TextSize = 14
        NameLabel.Font = Enum.Font.GothamBold
        NameLabel.TextXAlignment = Enum.TextXAlignment.Left
        NameLabel.ZIndex = 10000
        NameLabel.Parent = Container
        
        -- Description
        if self.Description ~= "" then
            local DescLabel = Instance.new("TextLabel")
            DescLabel.Name = "DescLabel"
            DescLabel.Size = UDim2.new(0, 250, 0, 15)
            DescLabel.Position = UDim2.new(0, 15, 0, 26)
            DescLabel.BackgroundTransparency = 1
            DescLabel.Text = self.Description
            DescLabel.TextColor3 = SurfyUI.Theme.TextDim
            DescLabel.TextSize = 10
            DescLabel.Font = Enum.Font.Gotham
            DescLabel.TextXAlignment = Enum.TextXAlignment.Left
            DescLabel.ZIndex = 10000
            DescLabel.Parent = Container
        end
        
        -- Keybind display
        local function GetKeyName(key)
            if key == Enum.KeyCode.Unknown then return "NONE"
            elseif key == Enum.UserInputType.MouseButton1 then return "M1"
            elseif key == Enum.UserInputType.MouseButton2 then return "M2"
            else return key.Name:upper() end
        end
        
        local KeybindLabel = Instance.new("TextLabel")
        KeybindLabel.Name = "Keybind"
        KeybindLabel.Size = UDim2.new(0, 60, 0, 20)
        KeybindLabel.Position = UDim2.new(1, -70, 0.5, -10)
        KeybindLabel.BackgroundColor3 = SurfyUI.Theme.SurfaceLight
        KeybindLabel.BackgroundTransparency = 0.5
        KeybindLabel.Text = GetKeyName(self.Keybind)
        KeybindLabel.TextColor3 = SurfyUI.Theme.TextDim
        KeybindLabel.TextSize = 10
        KeybindLabel.Font = Enum.Font.GothamBold
        KeybindLabel.ZIndex = 10000
        KeybindLabel.Parent = Container
        
        Round(KeybindLabel, 6)
        
        Module.Container = Container
        Module.Indicator = Indicator
        Module.NameLabel = NameLabel
        Module.KeybindLabel = KeybindLabel
        
        -- Left click to toggle
        Container.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                self:Toggle()
            elseif input.UserInputType == Enum.UserInputType.MouseButton2 and self.Modes then
                self:ShowModeMenu()
            end
        end)
        
        -- Keybind listening
        KeybindLabel.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                KeybindLabel.Text = "..."
                KeybindLabel.TextColor3 = SurfyUI.Theme.Primary
                
                local connection
                connection = UserInputService.InputBegan:Connect(function(input2)
                    if input2.KeyCode ~= Enum.KeyCode.Unknown then
                        self.Keybind = input2.KeyCode
                    elseif input2.UserInputType == Enum.UserInputType.MouseButton1 or
                           input2.UserInputType == Enum.UserInputType.MouseButton2 then
                        self.Keybind = input2.UserInputType
                    end
                    
                    KeybindLabel.Text = GetKeyName(self.Keybind)
                    KeybindLabel.TextColor3 = SurfyUI.Theme.TextDim
                    connection:Disconnect()
                end)
            end
        end)
        
        -- Global keybind listener
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if not gameProcessed then
                if (input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode == self.Keybind) or
                   (input.UserInputType == self.Keybind) then
                    self:Toggle()
                end
            end
        end)
    end
    
    function Module:Toggle()
        self.Enabled = not self.Enabled
        
        if self.Container then
            Tween(self.Indicator, {BackgroundTransparency = self.Enabled and 0 or 1}, 0.3)
            Tween(self.NameLabel, {TextColor3 = self.Enabled and SurfyUI.Theme.Primary or SurfyUI.Theme.Text}, 0.3)
            
            if self.Enabled then
                Tween(self.Container, {BackgroundColor3 = SurfyUI.Theme.SurfaceLight}, 0.3)
                
                -- Add gradient to indicator
                for _, child in ipairs(self.Indicator:GetChildren()) do
                    if child:IsA("UIGradient") then
                        child:Destroy()
                    end
                end
                AddGradient(self.Indicator, SurfyUI.Theme.PrimaryBright, SurfyUI.Theme.Primary, 90)
            else
                Tween(self.Container, {BackgroundColor3 = SurfyUI.Theme.Surface}, 0.3)
            end
        end
        
        if self.Callback then
            self.Callback(self.Enabled, self.Mode)
        end
    end
    
    function Module:ShowModeMenu()
        if not self.Modes then return end
        
        -- Create dropdown menu
        local Dropdown = Instance.new("Frame")
        Dropdown.Name = "ModeDropdown"
        Dropdown.Size = UDim2.new(0, 120, 0, 0)
        Dropdown.Position = UDim2.new(1, -125, 0, 45)
        Dropdown.BackgroundColor3 = SurfyUI.Theme.Surface
        Dropdown.BackgroundTransparency = 0.1
        Dropdown.BorderSizePixel = 0
        Dropdown.ZIndex = 10005
        Dropdown.Parent = self.Container
        
        Round(Dropdown, 8)
        AddStroke(Dropdown, SurfyUI.Theme.Primary, 1, 0.5)
        
        local DropLayout = Instance.new("UIListLayout")
        DropLayout.Padding = UDim.new(0, 4)
        DropLayout.Parent = Dropdown
        
        local DropPadding = Instance.new("UIPadding")
        DropPadding.PaddingTop = UDim.new(0, 6)
        DropPadding.PaddingBottom = UDim.new(0, 6)
        DropPadding.PaddingLeft = UDim.new(0, 6)
        DropPadding.PaddingRight = UDim.new(0, 6)
        DropPadding.Parent = Dropdown
        
        for _, mode in ipairs(self.Modes) do
            local ModeBtn = Instance.new("TextButton")
            ModeBtn.Name = mode
            ModeBtn.Size = UDim2.new(1, -12, 0, 26)
            ModeBtn.BackgroundColor3 = SurfyUI.Theme.SurfaceLight
            ModeBtn.BackgroundTransparency = (self.Mode == mode) and 0.2 or 0.6
            ModeBtn.Text = mode
            ModeBtn.TextColor3 = (self.Mode == mode) and SurfyUI.Theme.Primary or SurfyUI.Theme.Text
            ModeBtn.TextSize = 11
            ModeBtn.Font = Enum.Font.GothamMedium
            ModeBtn.ZIndex = 10006
            ModeBtn.Parent = Dropdown
            
            Round(ModeBtn, 6)
            
            if self.Mode == mode then
                AddStroke(ModeBtn, SurfyUI.Theme.Primary, 1, 0.5)
            end
            
            ModeBtn.MouseEnter:Connect(function()
                if self.Mode ~= mode then
                    Tween(ModeBtn, {BackgroundTransparency = 0.4}, 0.2)
                end
            end)
            
            ModeBtn.MouseLeave:Connect(function()
                if self.Mode ~= mode then
                    Tween(ModeBtn, {BackgroundTransparency = 0.6}, 0.2)
                end
            end)
            
            ModeBtn.MouseButton1Click:Connect(function()
                self.Mode = mode
                Dropdown:Destroy()
                
                if self.Callback then
                    self.Callback(self.Enabled, mode)
                end
            end)
        end
        
        local targetHeight = (#self.Modes * 30) + 12
        Tween(Dropdown, {Size = UDim2.new(0, 120, 0, targetHeight)}, 0.3, Enum.EasingStyle.Back)
        
        task.delay(3, function()
            if Dropdown.Parent then
                Tween(Dropdown, {Size = UDim2.new(0, 120, 0, 0)}, 0.2)
                task.wait(0.2)
                Dropdown:Destroy()
            end
        end)
    end
    
    table.insert(category.Modules, Module)
    
    return Module
end

return SurfyUI
