-- Surfy TC2 - Vape-Style Bottom Drawer UI
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

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

-- Icons for categories
SurfyUI.Icons = {
    Combat = "⚔",
    Visuals = "👁",
    Movement = "🏃",
    Player = "👤",
    World = "🌍",
    Misc = "⚙"
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
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Bottom Bar (Always Visible)
    local BottomBar = Instance.new("Frame")
    BottomBar.Name = "BottomBar"
    BottomBar.Size = UDim2.new(0, 500, 0, 60)
    BottomBar.Position = UDim2.new(0.5, -250, 1, -70)
    BottomBar.BackgroundColor3 = SurfyUI.Theme.Surface
    BottomBar.BackgroundTransparency = 0.1
    BottomBar.BorderSizePixel = 0
    BottomBar.Parent = ScreenGui
    
    Round(BottomBar, 16)
    AddStroke(BottomBar, SurfyUI.Theme.Primary, 2, 0.3)
    
    -- Glow effect
    local BarGlow = Instance.new("ImageLabel")
    BarGlow.BackgroundTransparency = 1
    BarGlow.Position = UDim2.new(0, -20, 0, -20)
    BarGlow.Size = UDim2.new(1, 40, 1, 40)
    BarGlow.ZIndex = 0
    BarGlow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    BarGlow.ImageColor3 = SurfyUI.Theme.Primary
    BarGlow.ImageTransparency = 0.8
    BarGlow.Parent = BottomBar
    
    -- Drag Handle
    local DragHandle = Instance.new("Frame")
    DragHandle.Name = "DragHandle"
    DragHandle.Size = UDim2.new(0, 50, 0, 5)
    DragHandle.Position = UDim2.new(0.5, -25, 0, 8)
    DragHandle.BackgroundColor3 = SurfyUI.Theme.Primary
    DragHandle.BackgroundTransparency = 0.3
    DragHandle.BorderSizePixel = 0
    DragHandle.Parent = BottomBar
    
    Round(DragHandle, 3)
    
    -- Category Icons Container
    local IconContainer = Instance.new("Frame")
    IconContainer.Name = "Icons"
    IconContainer.Size = UDim2.new(1, -20, 0, 40)
    IconContainer.Position = UDim2.new(0, 10, 0, 15)
    IconContainer.BackgroundTransparency = 1
    IconContainer.Parent = BottomBar
    
    local IconLayout = Instance.new("UIListLayout")
    IconLayout.FillDirection = Enum.FillDirection.Horizontal
    IconLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    IconLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    IconLayout.Padding = UDim.new(0, 15)
    IconLayout.Parent = IconContainer
    
    -- Main Drawer (Hidden by default)
    local Drawer = Instance.new("Frame")
    Drawer.Name = "Drawer"
    Drawer.Size = UDim2.new(0, 600, 0, 0)
    Drawer.Position = UDim2.new(0.5, -300, 1, -70)
    Drawer.BackgroundColor3 = SurfyUI.Theme.Background
    Drawer.BackgroundTransparency = 0.05
    Drawer.BorderSizePixel = 0
    Drawer.ClipsDescendants = true
    Drawer.Visible = false
    Drawer.Parent = ScreenGui
    
    Round(Drawer, 20)
    AddStroke(Drawer, SurfyUI.Theme.Primary, 2, 0.4)
    
    -- Drawer gradient overlay
    local DrawerOverlay = Instance.new("Frame")
    DrawerOverlay.Size = UDim2.new(1, 0, 1, 0)
    DrawerOverlay.BackgroundTransparency = 0.95
    DrawerOverlay.BorderSizePixel = 0
    DrawerOverlay.Parent = Drawer
    
    Round(DrawerOverlay, 20)
    AddGradient(DrawerOverlay, SurfyUI.Theme.Primary, SurfyUI.Theme.Background, 180)
    
    -- Module List Container
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
    Window.DragHandle = DragHandle
    
    -- Drag functionality
    local dragging = false
    local dragStart, startPos
    
    DragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position.Y
            startPos = Drawer.Position.Y.Offset
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position.Y - dragStart
            local newY = math.clamp(startPos + delta, -400, 0)
            
            if newY < -50 and not Window.IsOpen then
                Window:Open()
            elseif newY > -50 and Window.IsOpen then
                Window:Close()
            end
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    function Window:Open()
        if self.IsOpen then return end
        self.IsOpen = true
        
        Drawer.Visible = true
        Tween(Drawer, {Size = UDim2.new(0, 600, 0, 400), Position = UDim2.new(0.5, -300, 1, -475)}, 0.4, Enum.EasingStyle.Back)
        Tween(DragHandle, {BackgroundTransparency = 0.1}, 0.3)
    end
    
    function Window:Close()
        if not self.IsOpen then return end
        self.IsOpen = false
        
        Tween(Drawer, {Size = UDim2.new(0, 600, 0, 0), Position = UDim2.new(0.5, -300, 1, -70)}, 0.3, Enum.EasingStyle.Quint)
        Tween(DragHandle, {BackgroundTransparency = 0.3}, 0.3)
        
        task.wait(0.3)
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
        Icon = icon or "⚙",
        Modules = {},
        Button = nil
    }
    
    table.insert(self.Categories, Category)
    
    -- Create icon button
    local IconButton = Instance.new("TextButton")
    IconButton.Name = name
    IconButton.Size = UDim2.new(0, 50, 0, 40)
    IconButton.BackgroundColor3 = SurfyUI.Theme.SurfaceLight
    IconButton.BackgroundTransparency = 0.4
    IconButton.Text = icon
    IconButton.TextSize = 20
    IconButton.Font = Enum.Font.GothamBold
    IconButton.TextColor3 = SurfyUI.Theme.TextDim
    IconButton.Parent = self.IconContainer
    
    Round(IconButton, 10)
    
    -- Glow indicator
    local Glow = Instance.new("Frame")
    Glow.Name = "Glow"
    Glow.Size = UDim2.new(1, 4, 0, 3)
    Glow.Position = UDim2.new(0, -2, 1, -3)
    Glow.BackgroundColor3 = SurfyUI.Theme.Primary
    Glow.BackgroundTransparency = 1
    Glow.BorderSizePixel = 0
    Glow.Parent = IconButton
    
    Round(Glow, 2)
    
    Category.Button = IconButton
    Category.Glow = Glow
    
    IconButton.MouseButton1Click:Connect(function()
        self:SelectCategory(Category)
    end)
    
    IconButton.MouseEnter:Connect(function()
        Tween(IconButton, {BackgroundTransparency = 0.2}, 0.2)
    end)
    
    IconButton.MouseLeave:Connect(function()
        if self.CurrentCategory ~= Category then
            Tween(IconButton, {BackgroundTransparency = 0.4}, 0.2)
        end
    end)
    
    if not self.CurrentCategory then
        self:SelectCategory(Category)
    end
    
    return Category
end

function SurfyUI:SelectCategory(category)
    if self.CurrentCategory then
        Tween(self.CurrentCategory.Button, {BackgroundTransparency = 0.4, TextColor3 = SurfyUI.Theme.TextDim}, 0.2)
        Tween(self.CurrentCategory.Glow, {BackgroundTransparency = 1}, 0.2)
    end
    
    self.CurrentCategory = category
    Tween(category.Button, {BackgroundTransparency = 0.1, TextColor3 = SurfyUI.Theme.Primary}, 0.3)
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
            self.Callback(self.Enabled)
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
        Dropdown.ZIndex = 10
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
            ModeBtn.Parent = Dropdown
            
            Round(ModeBtn, 6)
            
            if self.Mode == mode then
                AddStroke(ModeBtn, SurfyUI.Theme.Primary, 1, 0.5)
            end
            
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
