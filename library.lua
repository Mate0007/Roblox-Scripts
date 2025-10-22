-- Surfy UI Library v2.0 - Enhanced & Organized
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- Main Library Table
local SurfyUI = {
    Version = "2.0.0",
    Themes = {
        Aqua = {
            Primary = Color3.fromRGB(0, 230, 255),
            PrimaryDark = Color3.fromRGB(0, 180, 230),
            PrimaryBright = Color3.fromRGB(100, 255, 255),
            Secondary = Color3.fromRGB(0, 150, 200),
            Background = Color3.fromRGB(12, 15, 25),
            Surface = Color3.fromRGB(18, 22, 35),
            SurfaceLight = Color3.fromRGB(25, 30, 45),
            ModuleBackground = Color3.fromRGB(22, 27, 40),
            Text = Color3.fromRGB(255, 255, 255),
            TextDim = Color3.fromRGB(150, 170, 200),
            Active = Color3.fromRGB(0, 255, 200),
        },
        Dark = {
            Primary = Color3.fromRGB(220, 220, 220),
            PrimaryDark = Color3.fromRGB(180, 180, 180),
            PrimaryBright = Color3.fromRGB(255, 255, 255),
            Secondary = Color3.fromRGB(120, 120, 120),
            Background = Color3.fromRGB(20, 20, 20),
            Surface = Color3.fromRGB(30, 30, 30),
            SurfaceLight = Color3.fromRGB(45, 45, 45),
            ModuleBackground = Color3.fromRGB(35, 35, 35),
            Text = Color3.fromRGB(255, 255, 255),
            TextDim = Color3.fromRGB(170, 170, 170),
            Active = Color3.fromRGB(100, 255, 100),
        }
    }
}

-- Current Theme
SurfyUI.Theme = SurfyUI.Themes.Aqua

-- Utility Functions
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
    stroke.Color = color or SurfyUI.Theme.Primary
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0.5
    stroke.Parent = obj
    return stroke
end

-- Lucide Icon System
local LucideCache = {}
local function GetLucideIcon(iconName)
    if LucideCache[iconName] then
        return LucideCache[iconName]
    end
    
    -- Common preset icons for performance
    local presetIcons = {
        -- Tab Icons
        ["sword"] = "rbxassetid://7733992358",
        ["shield"] = "rbxassetid://7733992358",
        ["target"] = "rbxassetid://7733992358",
        ["crosshair"] = "rbxassetid://7733992358",
        
        ["eye"] = "rbxassetid://7733920644",
        ["palette"] = "rbxassetid://7733920644",
        ["monitor"] = "rbxassetid://7733920644",
        
        ["move"] = "rbxassetid://7734000129",
        ["running"] = "rbxassetid://7734000129",
        ["jump"] = "rbxassetid://7734000129",
        
        ["settings"] = "rbxassetid://7734053495",
        ["sliders"] = "rbxassetid://7734053495",
        ["wrench"] = "rbxassetid://7734053495",
        ["user"] = "rbxassetid://7734053495",
        
        -- Action Icons
        ["toggle"] = "rbxassetid://7734053495",
        ["slider"] = "rbxassetid://7734053495",
        ["list"] = "rbxassetid://7734053495",
        ["button"] = "rbxassetid://7734053495",
        ["key"] = "rbxassetid://7734053495",
        ["palette"] = "rbxassetid://7734053495",
    }
    
    if presetIcons[iconName] then
        LucideCache[iconName] = presetIcons[iconName]
        return presetIcons[iconName]
    end
    
    -- Fallback to API for custom icons
    local success, result = pcall(function()
        local url = "https://api.lucide.dev/icons/" .. iconName
        return HttpService:GetAsync(url)
    end)
    
    if success and result then
        -- Parse SVG and convert to ImageLabel (simplified)
        LucideCache[iconName] = presetIcons.settings -- Fallback for now
        return presetIcons.settings
    end
    
    -- Final fallback
    return presetIcons.settings
end

local function CreateIcon(parent, iconName, size, color)
    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, size or 24, 0, size or 24)
    icon.Position = UDim2.new(0.5, -(size or 24)/2, 0.5, -(size or 24)/2)
    icon.BackgroundTransparency = 1
    icon.ImageColor3 = color or SurfyUI.Theme.TextDim
    icon.ZIndex = 10001
    icon.Image = GetLucideIcon(iconName)
    icon.Parent = parent
    
    return icon
end

-- Window Class
local Window = {}
Window.__index = Window

function Window.new(config)
    config = config or {}
    
    local self = setmetatable({}, Window)
    
    self.Config = {
        Name = config.Name or "Surfy UI",
        Theme = config.Theme or "Aqua",
        IconOffset = config.IconOffset or 0,
        AutoShow = config.AutoShow or true
    }
    
    self.Tabs = {}
    self.CurrentTab = nil
    self.IsOpen = false
    
    -- Set theme
    if SurfyUI.Themes[self.Config.Theme] then
        SurfyUI.Theme = SurfyUI.Themes[self.Config.Theme]
    end
    
    self:CreateUI()
    
    if self.Config.AutoShow then
        self:Show()
    end
    
    return self
end

function Window:CreateUI()
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "SurfyUI"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.DisplayOrder = 999999
    self.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Icon Bar
    self.IconBar = Instance.new("Frame")
    self.IconBar.Name = "IconBar"
    self.IconBar.Size = UDim2.new(0, 0, 0, 50)
    self.IconBar.Position = UDim2.new(0.5, 0, 1, -65 - self.Config.IconOffset)
    self.IconBar.AnchorPoint = Vector2.new(0.5, 0)
    self.IconBar.BackgroundTransparency = 1
    self.IconBar.ZIndex = 10000
    self.IconBar.Parent = self.ScreenGui
    
    self.IconLayout = Instance.new("UIListLayout")
    self.IconLayout.FillDirection = Enum.FillDirection.Horizontal
    self.IconLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    self.IconLayout.Padding = UDim.new(0, 10)
    self.IconLayout.Parent = self.IconBar
    
    -- Connection Line
    self.ConnectionLine = Instance.new("Frame")
    self.ConnectionLine.Name = "ConnectionLine"
    self.ConnectionLine.Size = UDim2.new(0, 0, 0, 1)
    self.ConnectionLine.Position = UDim2.new(0.5, 0, 1, -85 - self.Config.IconOffset)
    self.ConnectionLine.AnchorPoint = Vector2.new(0.5, 0.5)
    self.ConnectionLine.BackgroundColor3 = SurfyUI.Theme.Primary
    self.ConnectionLine.BackgroundTransparency = 1
    self.ConnectionLine.BorderSizePixel = 0
    self.ConnectionLine.ZIndex = 9997
    self.ConnectionLine.Visible = false
    self.ConnectionLine.Parent = self.ScreenGui
    
    AddGradient(self.ConnectionLine, SurfyUI.Theme.Primary, SurfyUI.Theme.PrimaryBright, 0)
    
    -- Tab Name Display
    self.TabNameContainer = Instance.new("Frame")
    self.TabNameContainer.Name = "TabNameContainer"
    self.TabNameContainer.Size = UDim2.new(0, 240, 0, 48)
    self.TabNameContainer.Position = UDim2.new(0.5, -120, 1, -65 - self.Config.IconOffset)
    self.TabNameContainer.BackgroundColor3 = SurfyUI.Theme.Surface
    self.TabNameContainer.BackgroundTransparency = 1
    self.TabNameContainer.BorderSizePixel = 0
    self.TabNameContainer.ZIndex = 9999
    self.TabNameContainer.Parent = self.ScreenGui
    
    Round(self.TabNameContainer, 12)
    AddStroke(self.TabNameContainer, SurfyUI.Theme.Primary, 2, 1)
    
    self.TabNameLabel = Instance.new("TextLabel")
    self.TabNameLabel.Name = "TabNameLabel"
    self.TabNameLabel.Size = UDim2.new(1, 0, 1, 0)
    self.TabNameLabel.Position = UDim2.new(0, 0, 0, 0)
    self.TabNameLabel.BackgroundTransparency = 1
    self.TabNameLabel.Text = ""
    self.TabNameLabel.TextColor3 = SurfyUI.Theme.Primary
    self.TabNameLabel.TextSize = 22
    self.TabNameLabel.Font = Enum.Font.GothamBold
    self.TabNameLabel.TextXAlignment = Enum.TextXAlignment.Center
    self.TabNameLabel.TextTransparency = 1
    self.TabNameLabel.ZIndex = 10000
    self.TabNameLabel.Parent = self.TabNameContainer
    
    -- Main Drawer
    self.Drawer = Instance.new("Frame")
    self.Drawer.Name = "Drawer"
    self.Drawer.Size = UDim2.new(0, 600, 0, 0)
    self.Drawer.Position = UDim2.new(0.5, -300, 1, -65 - self.Config.IconOffset)
    self.Drawer.BackgroundColor3 = SurfyUI.Theme.Background
    self.Drawer.BackgroundTransparency = 0.25
    self.Drawer.BorderSizePixel = 0
    self.Drawer.ClipsDescendants = true
    self.Drawer.Visible = false
    self.Drawer.ZIndex = 9998
    self.Drawer.Parent = self.ScreenGui
    
    Round(self.Drawer, 16)
    self.DrawerStroke = AddStroke(self.Drawer, SurfyUI.Theme.Primary, 2, 0.4)
    
    local DrawerOverlay = Instance.new("Frame")
    DrawerOverlay.Size = UDim2.new(1, 0, 1, 0)
    DrawerOverlay.BackgroundTransparency = 0.96
    DrawerOverlay.BorderSizePixel = 0
    DrawerOverlay.ZIndex = 9998
    DrawerOverlay.Parent = self.Drawer
    
    Round(DrawerOverlay, 16)
    AddGradient(DrawerOverlay, SurfyUI.Theme.Primary, SurfyUI.Theme.Background, 180)
    
    -- Stroke Covers for Tab Name Integration
    self.LeftStrokeCover = Instance.new("Frame")
    self.LeftStrokeCover.Name = "LeftStrokeCover"
    self.LeftStrokeCover.Size = UDim2.new(0, 120, 0, 4)
    self.LeftStrokeCover.Position = UDim2.new(0.5, -120, 0, -2)
    self.LeftStrokeCover.BackgroundColor3 = SurfyUI.Theme.Background
    self.LeftStrokeCover.BackgroundTransparency = 0.25
    self.LeftStrokeCover.BorderSizePixel = 0
    self.LeftStrokeCover.ZIndex = 9999
    self.LeftStrokeCover.Visible = false
    self.LeftStrokeCover.Parent = self.Drawer
    
    self.RightStrokeCover = Instance.new("Frame")
    self.RightStrokeCover.Name = "RightStrokeCover"
    self.RightStrokeCover.Size = UDim2.new(0, 120, 0, 4)
    self.RightStrokeCover.Position = UDim2.new(0.5, 0, 0, -2)
    self.RightStrokeCover.BackgroundColor3 = SurfyUI.Theme.Background
    self.RightStrokeCover.BackgroundTransparency = 0.25
    self.RightStrokeCover.BorderSizePixel = 0
    self.RightStrokeCover.ZIndex = 9999
    self.RightStrokeCover.Visible = false
    self.RightStrokeCover.Parent = self.Drawer
    
    -- Module Container
    self.ModuleList = Instance.new("ScrollingFrame")
    self.ModuleList.Name = "ModuleList"
    self.ModuleList.Size = UDim2.new(1, -40, 1, -20)
    self.ModuleList.Position = UDim2.new(0, 20, 0, 10)
    self.ModuleList.BackgroundTransparency = 1
    self.ModuleList.BorderSizePixel = 0
    self.ModuleList.ScrollBarThickness = 0
    self.ModuleList.ScrollBarImageColor3 = SurfyUI.Theme.Primary
    self.ModuleList.ScrollBarImageTransparency = 1
    self.ModuleList.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.ModuleList.ZIndex = 9999
    self.ModuleList.Parent = self.Drawer
    
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Padding = UDim.new(0, 12)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Parent = self.ModuleList
    
    ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.ModuleList.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 20)
    end)
end

function Window:Show()
    if self.IsOpen then return end
    self.IsOpen = true
    
    self.Drawer.Visible = true
    self.ConnectionLine.Visible = true
    
    self.DrawerStroke.Transparency = 0.4
    
    if self.CurrentTab then
        self.TabNameLabel.Text = self.CurrentTab.Name:upper()
        self.TabNameContainer.BackgroundTransparency = 1
        
        -- Animated opening
        Tween(self.Drawer, {
            Size = UDim2.new(0, 600, 0, 400), 
            Position = UDim2.new(0.5, -300, 1, -480 - self.Config.IconOffset)
        }, 0.5, Enum.EasingStyle.Exponential)
        
        Tween(self.TabNameContainer, {
            Position = UDim2.new(0.5, -120, 1, -520 - self.Config.IconOffset),
            BackgroundTransparency = 0.2
        }, 0.5, Enum.EasingStyle.Exponential)
        
        Tween(self.TabNameContainer:FindFirstChildOfClass("UIStroke"), {Transparency = 0.4}, 0.5)
        Tween(self.TabNameLabel, {TextTransparency = 0}, 0.5, Enum.EasingStyle.Exponential)
        
        self.LeftStrokeCover.Visible = true
        self.RightStrokeCover.Visible = true
    end
    
    self.ConnectionLine.BackgroundTransparency = 1
    self.ConnectionLine.Size = UDim2.new(0, 0, 0, 1)
    Tween(self.ConnectionLine, {
        Size = UDim2.new(0, 80, 0, 1), 
        BackgroundTransparency = 0.3
    }, 0.5, Enum.EasingStyle.Exponential)
end

function Window:Hide()
    if not self.IsOpen then return end
    self.IsOpen = false
    
    self.LeftStrokeCover.Visible = false
    self.RightStrokeCover.Visible = false
    
    Tween(self.TabNameLabel, {TextTransparency = 1}, 0.4, Enum.EasingStyle.Exponential)
    Tween(self.TabNameContainer, {
        Position = UDim2.new(0.5, -120, 1, -65 - self.Config.IconOffset),
        BackgroundTransparency = 1
    }, 0.4, Enum.EasingStyle.Exponential)
    Tween(self.TabNameContainer:FindFirstChildOfClass("UIStroke"), {Transparency = 1}, 0.4)
    
    local closePos = UDim2.new(0.5, -300, 1, -65 - self.Config.IconOffset)
    Tween(self.Drawer, {
        Size = UDim2.new(0, 600, 0, 0), 
        Position = closePos
    }, 0.4, Enum.EasingStyle.Exponential)
    
    Tween(self.ConnectionLine, {
        Size = UDim2.new(0, 0, 0, 1), 
        BackgroundTransparency = 1
    }, 0.2, Enum.EasingStyle.Exponential)
    
    task.wait(0.1)
    self.ConnectionLine.Visible = false
    
    task.delay(0.3, function()
        Tween(self.DrawerStroke, {Transparency = 1}, 0.1, Enum.EasingStyle.Exponential)
    end)
    
    task.wait(0.4)
    self.Drawer.Visible = false
end

function Window:Toggle()
    if self.IsOpen then
        if self.CurrentTab then
            Tween(self.CurrentTab.Cube, {BackgroundTransparency = 0.3}, 0.2)
            Tween(self.CurrentTab.Icon, {ImageColor3 = SurfyUI.Theme.TextDim}, 0.2)
            self.CurrentTab = nil
        end
        self:Hide()
    else
        if #self.Tabs > 0 and not self.CurrentTab then
            self:SelectTab(self.Tabs[1])
        else
            self:Show()
        end
    end
end

function Window:SelectTab(tab)
    if self.CurrentTab then
        Tween(self.CurrentTab.Cube, {BackgroundTransparency = 0.3}, 0.2)
        Tween(self.CurrentTab.Icon, {ImageColor3 = SurfyUI.Theme.TextDim}, 0.2)
    end
    
    self.CurrentTab = tab
    Tween(tab.Cube, {BackgroundTransparency = 0}, 0.3, Enum.EasingStyle.Exponential)
    Tween(tab.Icon, {ImageColor3 = SurfyUI.Theme.Primary}, 0.3, Enum.EasingStyle.Exponential)
    
    if self.TabNameLabel then
        self.TabNameLabel.Text = tab.Name:upper()
        if self.IsOpen then
            Tween(self.TabNameLabel, {TextTransparency = 0}, 0.2, Enum.EasingStyle.Exponential)
            Tween(self.TabNameContainer, {BackgroundTransparency = 0.2}, 0.2)
            Tween(self.TabNameContainer:FindFirstChildOfClass("UIStroke"), {Transparency = 0.4}, 0.2)
            
            self.LeftStrokeCover.Visible = true
            self.RightStrokeCover.Visible = true
        end
    end
    
    self:RefreshModules()
    
    if not self.IsOpen then
        self:Show()
    end
end

function Window:RefreshModules()
    for _, child in ipairs(self.ModuleList:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    
    if not self.CurrentTab then return end
    
    table.sort(self.CurrentTab.Modules, function(a, b)
        return a.LayoutOrder < b.LayoutOrder
    end)
    
    local lastSection = nil
    
    for _, module in ipairs(self.CurrentTab.Modules) do
        if module.Section and module.Section ~= lastSection then
            lastSection = module.Section
            
            local SectionContainer = Instance.new("Frame")
            SectionContainer.Name = "Section_" .. module.Section.Name
            SectionContainer.Size = UDim2.new(1, 0, 0, 35)
            SectionContainer.BackgroundTransparency = 1
            SectionContainer.BorderSizePixel = 0
            SectionContainer.ZIndex = 9999
            SectionContainer.LayoutOrder = module.LayoutOrder - 0.5
            SectionContainer.Parent = self.ModuleList
            
            local SectionHeader = Instance.new("TextLabel")
            SectionHeader.Size = UDim2.new(1, -20, 1, 0)
            SectionHeader.Position = UDim2.new(0, 10, 0, 0)
            SectionHeader.BackgroundTransparency = 1
            SectionHeader.Text = module.Section.Name
            SectionHeader.TextColor3 = SurfyUI.Theme.Primary
            SectionHeader.TextSize = 15
            SectionHeader.Font = Enum.Font.GothamBold
            SectionHeader.TextXAlignment = Enum.TextXAlignment.Left
            SectionHeader.TextYAlignment = Enum.TextYAlignment.Center
            SectionHeader.ZIndex = 10000
            SectionHeader.Parent = SectionContainer
        end
        
        module:Render(self.ModuleList)
    end
end

function Window:AddTab(config)
    config = config or {}
    
    local Tab = {
        Name = config.Name or "Tab",
        Icon = config.Icon or "settings",
        Sections = {},
        Modules = {}
    }
    
    table.insert(self.Tabs, Tab)
    
    local Cube = Instance.new("TextButton")
    Cube.Name = Tab.Name
    Cube.Size = UDim2.new(0, 50, 0, 50)
    Cube.BackgroundColor3 = SurfyUI.Theme.Surface
    Cube.BackgroundTransparency = 0.3
    Cube.Text = ""
    Cube.ZIndex = 10000
    Cube.Parent = self.IconBar
    
    Round(Cube, 12)
    AddStroke(Cube, SurfyUI.Theme.Primary, 2, 0.6)
    
    local Icon = CreateIcon(Cube, Tab.Icon, 24, SurfyUI.Theme.TextDim)
    
    Tab.Cube = Cube
    Tab.Icon = Icon
    
    Cube.MouseButton1Click:Connect(function()
        if self.CurrentTab == Tab then
            Tween(Cube, {BackgroundTransparency = 0.3}, 0.2)
            Tween(Icon, {ImageColor3 = SurfyUI.Theme.TextDim}, 0.2)
            self.CurrentTab = nil
            self:Hide()
        else
            self:SelectTab(Tab)
        end
    end)
    
    Cube.MouseEnter:Connect(function()
        Tween(Cube, {BackgroundTransparency = 0.1}, 0.2, Enum.EasingStyle.Exponential)
        Tween(Icon, {ImageColor3 = SurfyUI.Theme.Primary}, 0.2, Enum.EasingStyle.Exponential)
    end)
    
    Cube.MouseLeave:Connect(function()
        if self.CurrentTab ~= Tab then
            Tween(Cube, {BackgroundTransparency = 0.3}, 0.2, Enum.EasingStyle.Exponential)
            Tween(Icon, {ImageColor3 = SurfyUI.Theme.TextDim}, 0.2, Enum.EasingStyle.Exponential)
        end
    end)
    
    task.wait()
    local totalWidth = #self.Tabs * 60
    self.IconBar.Size = UDim2.new(0, totalWidth, 0, 50)
    
    if #self.Tabs == 1 and not self.CurrentTab then
        self.CurrentTab = Tab
        Tween(Cube, {BackgroundTransparency = 0}, 0.3, Enum.EasingStyle.Exponential)
        Tween(Icon, {ImageColor3 = SurfyUI.Theme.Primary}, 0.3, Enum.EasingStyle.Exponential)
    end
    
    return Tab
end

function Window:AddSection(tab, config)
    config = config or {}
    
    local Section = {
        Name = config.Name or "Section",
        Tab = tab
    }
    
    table.insert(tab.Sections, Section)
    return Section
end

-- Element Creation Methods
function Window:AddToggle(section, config)
    config = config or {}
    
    local Module = {
        Name = config.Title or "Toggle",
        Enabled = config.Default or false,
        Callback = config.Callback,
        LayoutOrder = config.LayoutOrder or 999,
        Section = section
    }
    
    function Module:Render(parent)
        local Container = Instance.new("Frame")
        Container.Size = UDim2.new(1, 0, 0, 48)
        Container.BackgroundColor3 = SurfyUI.Theme.ModuleBackground
        Container.BackgroundTransparency = 0.3
        Container.BorderSizePixel = 0
        Container.ZIndex = 9999
        Container.LayoutOrder = self.LayoutOrder
        Container.Parent = parent
        
        Round(Container, 10)
        AddStroke(Container, SurfyUI.Theme.Surface, 1, 0.7)
        
        local Indicator = Instance.new("Frame")
        Indicator.Size = UDim2.new(0, 4, 0.65, 0)
        Indicator.Position = UDim2.new(0, 0, 0.175, 0)
        Indicator.BackgroundColor3 = SurfyUI.Theme.Primary
        Indicator.BackgroundTransparency = self.Enabled and 0 or 1
        Indicator.BorderSizePixel = 0
        Indicator.ZIndex = 10000
        Indicator.Parent = Container
        
        Round(Indicator, 2)
        
        if self.Enabled then
            AddGradient(Indicator, SurfyUI.Theme.PrimaryBright, SurfyUI.Theme.Primary, 90)
        end
        
        local NameLabel = Instance.new("TextLabel")
        NameLabel.Size = UDim2.new(1, -30, 1, 0)
        NameLabel.Position = UDim2.new(0, 15, 0, 0)
        NameLabel.BackgroundTransparency = 1
        NameLabel.Text = self.Name
        NameLabel.TextColor3 = self.Enabled and SurfyUI.Theme.Primary or SurfyUI.Theme.Text
        NameLabel.TextSize = 14
        NameLabel.Font = Enum.Font.GothamBold
        NameLabel.TextXAlignment = Enum.TextXAlignment.Left
        NameLabel.ZIndex = 10000
        NameLabel.Parent = Container
        
        Module.Container = Container
        Module.Indicator = Indicator
        Module.NameLabel = NameLabel
        
        Container.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                self:Toggle()
            end
        end)
    end
    
    function Module:Toggle()
        self.Enabled = not self.Enabled
        
        if self.Container then
            Tween(self.Indicator, {BackgroundTransparency = self.Enabled and 0 or 1}, 0.3, Enum.EasingStyle.Exponential)
            Tween(self.NameLabel, {TextColor3 = self.Enabled and SurfyUI.Theme.Primary or SurfyUI.Theme.Text}, 0.3, Enum.EasingStyle.Exponential)
            
            if self.Enabled then
                Tween(self.Container, {BackgroundColor3 = SurfyUI.Theme.SurfaceLight}, 0.3, Enum.EasingStyle.Exponential)
                for _, child in ipairs(self.Indicator:GetChildren()) do
                    if child:IsA("UIGradient") then child:Destroy() end
                end
                AddGradient(self.Indicator, SurfyUI.Theme.PrimaryBright, SurfyUI.Theme.Primary, 90)
            else
                Tween(self.Container, {BackgroundColor3 = SurfyUI.Theme.ModuleBackground}, 0.3, Enum.EasingStyle.Exponential)
            end
        end
        
        if self.Callback then
            self.Callback(self.Enabled)
        end
    end
    
    table.insert(section.Tab.Modules, Module)
    return Module
end

function Window:AddSlider(section, config)
    config = config or {}
    
    local Module = {
        Name = config.Title or "Slider",
        Value = config.Default or config.Min or 0,
        Min = config.Min or 0,
        Max = config.Max or 100,
        Rounding = config.Rounding or 0,
        Callback = config.Callback,
        IsDragging = false,
        LayoutOrder = config.LayoutOrder or 999,
        Section = section,
    }
    
    function Module:Render(parent)
        local Container = Instance.new("Frame")
        Container.Size = UDim2.new(1, 0, 0, 58)
        Container.BackgroundColor3 = SurfyUI.Theme.ModuleBackground
        Container.BackgroundTransparency = 0.3
        Container.BorderSizePixel = 0
        Container.ZIndex = 9999
        Container.LayoutOrder = self.LayoutOrder
        Container.Parent = parent
        
        Round(Container, 10)
        AddStroke(Container, SurfyUI.Theme.Surface, 1, 0.7)
        
        local NameLabel = Instance.new("TextLabel")
        NameLabel.Size = UDim2.new(0, 200, 0, 18)
        NameLabel.Position = UDim2.new(0, 15, 0, 10)
        NameLabel.BackgroundTransparency = 1
        NameLabel.Text = self.Name
        NameLabel.TextColor3 = SurfyUI.Theme.Text
        NameLabel.TextSize = 13
        NameLabel.Font = Enum.Font.GothamBold
        NameLabel.TextXAlignment = Enum.TextXAlignment.Left
        NameLabel.ZIndex = 10000
        NameLabel.Parent = Container
        
        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.Size = UDim2.new(0, 60, 0, 18)
        ValueLabel.Position = UDim2.new(1, -70, 0, 10)
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Text = tostring(self.Value)
        ValueLabel.TextColor3 = SurfyUI.Theme.Primary
        ValueLabel.TextSize = 13
        ValueLabel.Font = Enum.Font.GothamBold
        ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
        ValueLabel.ZIndex = 10000
        ValueLabel.Parent = Container
        
        local Track = Instance.new("Frame")
        Track.Size = UDim2.new(1, -30, 0, 6)
        Track.Position = UDim2.new(0, 15, 1, -20)
        Track.BackgroundColor3 = SurfyUI.Theme.Secondary
        Track.BackgroundTransparency = 0.4
        Track.BorderSizePixel = 0
        Track.ZIndex = 9999
        Track.Parent = Container
        
        Round(Track, 3)
        
        local normalizedValue = (self.Value - self.Min) / (self.Max - self.Min)
        
        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new(normalizedValue, 0, 1, 0)
        Fill.BackgroundColor3 = SurfyUI.Theme.Primary
        Fill.BackgroundTransparency = 0.2
        Fill.BorderSizePixel = 0
        Fill.ZIndex = 10000
        Fill.Parent = Track
        
        Round(Fill, 3)
        AddGradient(Fill, SurfyUI.Theme.Primary, SurfyUI.Theme.PrimaryBright, 0)
        
        local Knob = Instance.new("TextButton")
        Knob.Size = UDim2.new(0, 16, 0, 16)
        Knob.Position = UDim2.new(normalizedValue, -8, 0.5, -8)
        Knob.BackgroundColor3 = Color3.new(1, 1, 1)
        Knob.Text = ""
        Knob.ZIndex = 10001
        Knob.Parent = Track
        
        Round(Knob, 8)
        AddStroke(Knob, SurfyUI.Theme.Primary, 2, 0.3)
        
        Module.Container = Container
        Module.ValueLabel = ValueLabel
        Module.Fill = Fill
        Module.Knob = Knob
        Module.Track = Track
        
        local function UpdateSlider(input)
            if not input then return end
            
            local trackAbsolutePos = Track.AbsolutePosition
            local trackAbsoluteSize = Track.AbsoluteSize
            
            if trackAbsoluteSize.X <= 0 then return end
            
            local mouseX = input.Position.X
            local relX = (mouseX - trackAbsolutePos.X) / trackAbsoluteSize.X
            local clampedX = math.clamp(relX, 0, 1)
            
            local newValue = math.floor((self.Min + (self.Max - self.Min) * clampedX) * (10 ^ self.Rounding)) / (10 ^ self.Rounding)
            
            if newValue ~= self.Value then
                self.Value = newValue
                ValueLabel.Text = tostring(self.Value)
                
                Tween(Fill, {Size = UDim2.new(clampedX, 0, 1, 0)}, 0.1, Enum.EasingStyle.Exponential)
                Tween(Knob, {Position = UDim2.new(clampedX, -8, 0.5, -8)}, 0.1, Enum.EasingStyle.Exponential)
                
                if self.Callback then
                    self.Callback(self.Value)
                end
            end
        end
        
        local function onTrackInput(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                self.IsDragging = true
                UpdateSlider(input)
            end
        end
        
        Track.InputBegan:Connect(onTrackInput)
        
        Knob.MouseButton1Down:Connect(function()
            self.IsDragging = true
            Tween(Knob, {Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(Knob.Position.X.Scale, -9, 0.5, -9)}, 0.2, Enum.EasingStyle.Exponential)
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                self.IsDragging = false
                if Knob then
                    Tween(Knob, {Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(Knob.Position.X.Scale, -8, 0.5, -8)}, 0.2, Enum.EasingStyle.Exponential)
                end
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement and self.IsDragging then
                UpdateSlider(input)
            end
        end)
    end
    
    function Module:SetValue(value)
        self.Value = math.clamp(value, self.Min, self.Max)
        if self.ValueLabel and self.Fill and self.Knob then
            self.ValueLabel.Text = tostring(self.Value)
            local normalized = (self.Value - self.Min) / (self.Max - self.Min)
            Tween(self.Fill, {Size = UDim2.new(normalized, 0, 1, 0)}, 0.2, Enum.EasingStyle.Exponential)
            Tween(self.Knob, {Position = UDim2.new(normalized, -8, 0.5, -8)}, 0.2, Enum.EasingStyle.Exponential)
        end
        if self.Callback then
            self.Callback(self.Value)
        end
    end
    
    table.insert(section.Tab.Modules, Module)
    return Module
end

function Window:AddButton(section, config)
    config = config or {}
    
    local Module = {
        Name = config.Title or "Button",
        Callback = config.Callback,
        LayoutOrder = config.LayoutOrder or 999,
        Section = section
    }
    
    function Module:Render(parent)
        local Container = Instance.new("TextButton")
        Container.Size = UDim2.new(1, 0, 0, 48)
        Container.BackgroundColor3 = SurfyUI.Theme.ModuleBackground
        Container.BackgroundTransparency = 0.3
        Container.BorderSizePixel = 0
        Container.ZIndex = 9999
        Container.LayoutOrder = self.LayoutOrder
        Container.Text = ""
        Container.Parent = parent
        
        Round(Container, 10)
        AddStroke(Container, SurfyUI.Theme.Surface, 1, 0.7)
        
        local NameLabel = Instance.new("TextLabel")
        NameLabel.Size = UDim2.new(1, -30, 1, 0)
        NameLabel.Position = UDim2.new(0, 15, 0, 0)
        NameLabel.BackgroundTransparency = 1
        NameLabel.Text = self.Name
        NameLabel.TextColor3 = SurfyUI.Theme.Text
        NameLabel.TextSize = 14
        NameLabel.Font = Enum.Font.GothamBold
        NameLabel.TextXAlignment = Enum.TextXAlignment.Center
        NameLabel.ZIndex = 10000
        NameLabel.Parent = Container
        
        Module.Container = Container
        Module.NameLabel = NameLabel
        
        Container.MouseEnter:Connect(function()
            Tween(Container, {BackgroundColor3 = SurfyUI.Theme.SurfaceLight}, 0.2, Enum.EasingStyle.Exponential)
            Tween(NameLabel, {TextColor3 = SurfyUI.Theme.Primary}, 0.2, Enum.EasingStyle.Exponential)
        end)
        
        Container.MouseLeave:Connect(function()
            Tween(Container, {BackgroundColor3 = SurfyUI.Theme.ModuleBackground}, 0.2, Enum.EasingStyle.Exponential)
            Tween(NameLabel, {TextColor3 = SurfyUI.Theme.Text}, 0.2, Enum.EasingStyle.Exponential)
        end)
        
        Container.MouseButton1Click:Connect(function()
            Tween(Container, {BackgroundColor3 = SurfyUI.Theme.Primary}, 0.1, Enum.EasingStyle.Exponential)
            Tween(NameLabel, {TextColor3 = Color3.new(1, 1, 1)}, 0.1, Enum.EasingStyle.Exponential)
            
            task.wait(0.1)
            
            Tween(Container, {BackgroundColor3 = SurfyUI.Theme.ModuleBackground}, 0.2, Enum.EasingStyle.Exponential)
            Tween(NameLabel, {TextColor3 = SurfyUI.Theme.Text}, 0.2, Enum.EasingStyle.Exponential)
            
            if self.Callback then
                self.Callback()
            end
        end)
    end
    
    table.insert(section.Tab.Modules, Module)
    return Module
end

function Window:AddDropdown(section, config)
    config = config or {}
    
    local Module = {
        Name = config.Title or "Dropdown",
        Value = config.Default or config.Options[1],
        Options = config.Options or {"Option 1"},
        Callback = config.Callback,
        IsOpen = false,
        LayoutOrder = config.LayoutOrder or 999,
        Section = section
    }
    
    function Module:Render(parent)
        local Container = Instance.new("Frame")
        Container.Size = UDim2.new(1, 0, 0, 48)
        Container.BackgroundColor3 = SurfyUI.Theme.ModuleBackground
        Container.BackgroundTransparency = 0.3
        Container.BorderSizePixel = 0
        Container.ZIndex = 9999
        Container.ClipsDescendants = false
        Container.LayoutOrder = self.LayoutOrder
        Container.Parent = parent
        
        Round(Container, 10)
        AddStroke(Container, SurfyUI.Theme.Surface, 1, 0.7)
        
        local NameLabel = Instance.new("TextLabel")
        NameLabel.Size = UDim2.new(0, 200, 1, 0)
        NameLabel.Position = UDim2.new(0, 15, 0, 0)
        NameLabel.BackgroundTransparency = 1
        NameLabel.Text = self.Name
        NameLabel.TextColor3 = SurfyUI.Theme.Text
        NameLabel.TextSize = 13
        NameLabel.Font = Enum.Font.GothamBold
        NameLabel.TextXAlignment = Enum.TextXAlignment.Left
        NameLabel.ZIndex = 10000
        NameLabel.Parent = Container
        
        local DropBtn = Instance.new("TextButton")
        DropBtn.Size = UDim2.new(0, 140, 0, 32)
        DropBtn.Position = UDim2.new(1, -150, 0.5, -16)
        DropBtn.BackgroundColor3 = SurfyUI.Theme.Secondary
        DropBtn.BackgroundTransparency = 0.4
        DropBtn.Text = self.Value
        DropBtn.TextColor3 = SurfyUI.Theme.Text
        DropBtn.TextSize = 12
        DropBtn.Font = Enum.Font.GothamMedium
        DropBtn.TextXAlignment = Enum.TextXAlignment.Center
        DropBtn.ZIndex = 10000
        DropBtn.Parent = Container
        
        Round(DropBtn, 8)
        
        local Arrow = Instance.new("TextLabel")
        Arrow.Size = UDim2.new(0, 20, 1, 0)
        Arrow.Position = UDim2.new(1, -20, 0, 0)
        Arrow.BackgroundTransparency = 1
        Arrow.Text = "▼"
        Arrow.TextColor3 = SurfyUI.Theme.TextDim
        Arrow.TextSize = 10
        Arrow.Font = Enum.Font.GothamBold
        Arrow.ZIndex = 10001
        Arrow.Parent = DropBtn
        
        Module.Container = Container
        Module.DropBtn = DropBtn
        Module.Arrow = Arrow
        
        DropBtn.MouseButton1Click:Connect(function()
            self.IsOpen = not self.IsOpen
            
            if self.IsOpen then
                local OptionsFrame = Instance.new("Frame")
                OptionsFrame.Name = "Options"
                OptionsFrame.Size = UDim2.new(0, 140, 0, 0)
                OptionsFrame.Position = UDim2.new(1, -150, 1, 8)
                OptionsFrame.BackgroundColor3 = SurfyUI.Theme.Surface
                OptionsFrame.BackgroundTransparency = 0.15
                OptionsFrame.BorderSizePixel = 0
                OptionsFrame.ZIndex = 15000
                OptionsFrame.Parent = Container
                
                Round(OptionsFrame, 8)
                AddStroke(OptionsFrame, SurfyUI.Theme.Primary, 1.5, 0.4)
                
                local OptLayout = Instance.new("UIListLayout")
                OptLayout.Padding = UDim.new(0, 4)
                OptLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                OptLayout.Parent = OptionsFrame
                
                local OptPadding = Instance.new("UIPadding")
                OptPadding.PaddingTop = UDim.new(0, 6)
                OptPadding.PaddingBottom = UDim.new(0, 6)
                OptPadding.PaddingLeft = UDim.new(0, 6)
                OptPadding.PaddingRight = UDim.new(0, 6)
                OptPadding.Parent = OptionsFrame
                
                for _, option in ipairs(self.Options) do
                    local OptBtn = Instance.new("TextButton")
                    OptBtn.Size = UDim2.new(1, -12, 0, 30)
                    OptBtn.BackgroundColor3 = SurfyUI.Theme.SurfaceLight
                    OptBtn.BackgroundTransparency = 1
                    OptBtn.Text = option
                    OptBtn.TextColor3 = (self.Value == option) and SurfyUI.Theme.Primary or SurfyUI.Theme.Text
                    OptBtn.TextSize = 12
                    OptBtn.Font = Enum.Font.GothamMedium
                    OptBtn.TextXAlignment = Enum.TextXAlignment.Center
                    OptBtn.ZIndex = 15001
                    OptBtn.Parent = OptionsFrame
                    
                    Round(OptBtn, 6)
                    
                    OptBtn.MouseEnter:Connect(function()
                        Tween(OptBtn, {BackgroundTransparency = 0.5}, 0.2, Enum.EasingStyle.Exponential)
                    end)
                    
                    OptBtn.MouseLeave:Connect(function()
                        Tween(OptBtn, {BackgroundTransparency = 1}, 0.2, Enum.EasingStyle.Exponential)
                    end)
                    
                    OptBtn.MouseButton1Click:Connect(function()
                        self.Value = option
                        DropBtn.Text = option
                        OptionsFrame:Destroy()
                        self.IsOpen = false
                        Tween(Arrow, {Rotation = 0}, 0.2, Enum.EasingStyle.Exponential)
                        
                        if self.Callback then
                            self.Callback(option)
                        end
                    end)
                end
                
                local targetHeight = (#self.Options * 34) + 12
                Tween(OptionsFrame, {Size = UDim2.new(0, 140, 0, targetHeight)}, 0.3, Enum.EasingStyle.Exponential)
                Tween(Arrow, {Rotation = 180}, 0.2, Enum.EasingStyle.Exponential)
            else
                if Container:FindFirstChild("Options") then
                    Container.Options:Destroy()
                end
                Tween(Arrow, {Rotation = 0}, 0.2, Enum.EasingStyle.Exponential)
            end
        end)
    end
    
    table.insert(section.Tab.Modules, Module)
    return Module
end

function Window:AddKeybind(section, config)
    config = config or {}
    
    local Module = {
        Name = config.Title or "Keybind",
        Key = config.Default or Enum.KeyCode.Unknown,
        Callback = config.Callback,
        IsBinding = false,
        LayoutOrder = config.LayoutOrder or 999,
        Section = section
    }
    
    function Module:Render(parent)
        local Container = Instance.new("Frame")
        Container.Size = UDim2.new(1, 0, 0, 48)
        Container.BackgroundColor3 = SurfyUI.Theme.ModuleBackground
        Container.BackgroundTransparency = 0.3
        Container.BorderSizePixel = 0
        Container.ZIndex = 9999
        Container.LayoutOrder = self.LayoutOrder
        Container.Parent = parent
        
        Round(Container, 10)
        AddStroke(Container, SurfyUI.Theme.Surface, 1, 0.7)
        
        local NameLabel = Instance.new("TextLabel")
        NameLabel.Size = UDim2.new(0, 200, 1, 0)
        NameLabel.Position = UDim2.new(0, 15, 0, 0)
        NameLabel.BackgroundTransparency = 1
        NameLabel.Text = self.Name
        NameLabel.TextColor3 = SurfyUI.Theme.Text
        NameLabel.TextSize = 13
        NameLabel.Font = Enum.Font.GothamBold
        NameLabel.TextXAlignment = Enum.TextXAlignment.Left
        NameLabel.ZIndex = 10000
        NameLabel.Parent = Container
        
        local function GetKeyName(key)
            if key == Enum.KeyCode.Unknown then return "NONE"
            elseif key == Enum.UserInputType.MouseButton1 then return "M1"
            elseif key == Enum.UserInputType.MouseButton2 then return "M2"
            else return key.Name:upper() end
        end
        
        local KeybindLabel = Instance.new("TextButton")
        KeybindLabel.Size = UDim2.new(0, 80, 0, 28)
        KeybindLabel.Position = UDim2.new(1, -90, 0.5, -14)
        KeybindLabel.BackgroundColor3 = SurfyUI.Theme.Secondary
        KeybindLabel.BackgroundTransparency = 0.4
        KeybindLabel.Text = GetKeyName(self.Key)
        KeybindLabel.TextColor3 = SurfyUI.Theme.TextDim
        KeybindLabel.TextSize = 11
        KeybindLabel.Font = Enum.Font.GothamBold
        KeybindLabel.ZIndex = 10000
        KeybindLabel.Parent = Container
        
        Round(KeybindLabel, 8)
        
        Module.Container = Container
        Module.KeybindLabel = KeybindLabel
        
        KeybindLabel.MouseButton1Click:Connect(function()
            self.IsBinding = true
            KeybindLabel.Text = "..."
            KeybindLabel.TextColor3 = SurfyUI.Theme.Primary
            
            local connection
            connection = UserInputService.InputBegan:Connect(function(input2)
                if input2.KeyCode ~= Enum.KeyCode.Unknown then
                    self.Key = input2.KeyCode
                elseif input2.UserInputType == Enum.UserInputType.MouseButton1 or
                       input2.UserInputType == Enum.UserInputType.MouseButton2 then
                    self.Key = input2.UserInputType
                end
                
                KeybindLabel.Text = GetKeyName(self.Key)
                KeybindLabel.TextColor3 = SurfyUI.Theme.TextDim
                self.IsBinding = false
                connection:Disconnect()
            end)
        end)
    end
    
    table.insert(section.Tab.Modules, Module)
    return Module
end

-- Notification System
function SurfyUI:CreateNotification(config)
    config = config or {}
    
    local ScreenGui = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("SurfyUI")
    if not ScreenGui then return end
    
    local Notification = Instance.new("Frame")
    Notification.Name = "Notification"
    Notification.Size = UDim2.new(0, 360, 0, 85)
    Notification.Position = UDim2.new(1, 380, 1, -110)
    Notification.BackgroundColor3 = SurfyUI.Theme.Surface
    Notification.BackgroundTransparency = 0.15
    Notification.BorderSizePixel = 0
    Notification.ZIndex = 10000
    Notification.Parent = ScreenGui
    
    Round(Notification, 12)
    AddStroke(Notification, SurfyUI.Theme.Primary, 1.5, 0.4)
    
    local Overlay = Instance.new("Frame")
    Overlay.Size = UDim2.new(1, 0, 1, 0)
    Overlay.BackgroundTransparency = 0.92
    Overlay.BorderSizePixel = 0
    Overlay.ZIndex = 10000
    Overlay.Parent = Notification
    
    Round(Overlay, 12)
    AddGradient(Overlay, SurfyUI.Theme.Primary, SurfyUI.Theme.Background, 135)
    
    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 6, 0, 6)
    Dot.Position = UDim2.new(0, 16, 0, 20)
    Dot.BackgroundColor3 = SurfyUI.Theme.Active
    Dot.BorderSizePixel = 0
    Dot.ZIndex = 10001
    Dot.Parent = Notification
    
    Round(Dot, 3)
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -70, 0, 22)
    Title.Position = UDim2.new(0, 32, 0, 12)
    Title.BackgroundTransparency = 1
    Title.Text = config.Title or "Notification"
    Title.TextColor3 = SurfyUI.Theme.Text
    Title.TextSize = 14
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 10001
    Title.Parent = Notification
    
    local Description = Instance.new("TextLabel")
    Description.Size = UDim2.new(1, -70, 0, 40)
    Description.Position = UDim2.new(0, 32, 0, 36)
    Description.BackgroundTransparency = 1
    Description.Text = config.Description or ""
    Description.TextColor3 = SurfyUI.Theme.TextDim
    Description.TextSize = 12
    Description.Font = Enum.Font.Gotham
    Description.TextXAlignment = Enum.TextXAlignment.Left
    Description.TextYAlignment = Enum.TextYAlignment.Top
    Description.TextWrapped = true
    Description.ZIndex = 10001
    Description.Parent = Notification
    
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 20, 0, 20)
    CloseBtn.Position = UDim2.new(1, -28, 0, 10)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = SurfyUI.Theme.TextDim
    CloseBtn.TextSize = 20
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.ZIndex = 10002
    CloseBtn.Parent = Notification
    
    Tween(Notification, {Position = UDim2.new(1, -370, 1, -110)}, 0.6, Enum.EasingStyle.Exponential)
    
    local function Remove()
        Tween(Notification, {Position = UDim2.new(1, 380, 1, -110)}, 0.5, Enum.EasingStyle.Exponential)
        task.wait(0.5)
        Notification:Destroy()
    end
    
    CloseBtn.MouseButton1Click:Connect(Remove)
    task.delay(config.Duration or 4, Remove)
end

-- Main Library Function
function SurfyUI:CreateWindow(config)
    return Window.new(config)
end

return SurfyUI
