-- Surfy UI Library v2.0 - PART 1
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local Library = {}
Library.__index = Library

-- Theme Configuration
Library.Theme = {
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
}

-- Lucide Icon Cache
local IconCache = {}

-- Helper Functions
local function Tween(obj, props, duration, style)
    local info = TweenInfo.new(duration or 0.3, style or Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    TweenService:Create(obj, info, props):Play()
end

local function Round(obj, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = obj
end

local function AddGradient(obj, color1, color2, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new(color1, color2)
    gradient.Rotation = rotation or 90
    gradient.Parent = obj
end

local function AddStroke(obj, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0.5
    stroke.Parent = obj
    return stroke
end

-- Fetch Lucide Icon from CDN
local function FetchLucideIcon(iconName)
    if IconCache[iconName] then
        return IconCache[iconName]
    end
    
    local success, result = pcall(function()
        local url = "https://unpkg.com/lucide-static@latest/icons/" .. iconName .. ".svg"
        return HttpService:GetAsync(url)
    end)
    
    if success and result then
        IconCache[iconName] = result
        return result
    end
    
    warn("[Surfy] Failed to load icon:", iconName)
    return nil
end

-- Parse SVG and create Roblox ImageLabel
local function CreateIconFromSVG(parent, iconName, size, color)
    size = size or 24
    color = color or Library.Theme.TextDim
    
    local iconContainer = Instance.new("Frame")
    iconContainer.Size = UDim2.new(0, size, 0, size)
    iconContainer.Position = UDim2.new(0.5, -size/2, 0.5, -size/2)
    iconContainer.BackgroundTransparency = 1
    iconContainer.ZIndex = 10001
    iconContainer.Parent = parent
    
    local svgData = FetchLucideIcon(iconName)
    
    if svgData then
        local icon = Instance.new("ImageLabel")
        icon.Size = UDim2.new(1, 0, 1, 0)
        icon.BackgroundTransparency = 1
        icon.ImageColor3 = color
        icon.ZIndex = 10001
        icon.Image = "rbxassetid://7743878358"
        icon.Parent = iconContainer
        
        return iconContainer, icon
    else
        local icon = Instance.new("ImageLabel")
        icon.Size = UDim2.new(1, 0, 1, 0)
        icon.BackgroundTransparency = 1
        icon.ImageColor3 = color
        icon.Image = "rbxassetid://7743878358"
        icon.ZIndex = 10001
        icon.Parent = iconContainer
        
        return iconContainer, icon
    end
end

-- Notification System
function Library:Notify(config)
    config = config or {}
    
    local ScreenGui = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("SurfyUI")
    if not ScreenGui then return end
    
    local Notification = Instance.new("Frame")
    Notification.Name = "Notification"
    Notification.Size = UDim2.new(0, 360, 0, 85)
    Notification.Position = UDim2.new(1, 380, 1, -110)
    Notification.BackgroundColor3 = Library.Theme.Surface
    Notification.BackgroundTransparency = 0.15
    Notification.BorderSizePixel = 0
    Notification.ZIndex = 10000
    Notification.Parent = ScreenGui
    
    Round(Notification, 12)
    AddStroke(Notification, Library.Theme.Primary, 1.5, 0.4)
    
    local Overlay = Instance.new("Frame")
    Overlay.Size = UDim2.new(1, 0, 1, 0)
    Overlay.BackgroundTransparency = 0.92
    Overlay.BorderSizePixel = 0
    Overlay.ZIndex = 10000
    Overlay.Parent = Notification
    
    Round(Overlay, 12)
    AddGradient(Overlay, Library.Theme.Primary, Library.Theme.Background, 135)
    
    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 6, 0, 6)
    Dot.Position = UDim2.new(0, 16, 0, 20)
    Dot.BackgroundColor3 = Library.Theme.Active
    Dot.BorderSizePixel = 0
    Dot.ZIndex = 10001
    Dot.Parent = Notification
    
    Round(Dot, 3)
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -70, 0, 22)
    Title.Position = UDim2.new(0, 32, 0, 12)
    Title.BackgroundTransparency = 1
    Title.Text = config.Title or "Notification"
    Title.TextColor3 = Library.Theme.Text
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
    Description.TextColor3 = Library.Theme.TextDim
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
    CloseBtn.TextColor3 = Library.Theme.TextDim
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

-- Create Window
function Library:CreateWindow(config)
    config = config or {}
    
    local Window = {
        Name = config.Name or "Surfy UI",
        Tabs = {},
        CurrentTab = nil,
        IsOpen = false,
        IsAnimating = false,
        IconOffset = config.IconOffset or 0,
        ConnectionLineYOffset = 0
    }
    setmetatable(Window, {__index = Library})
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SurfyUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 999999
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    Window.ScreenGui = ScreenGui
    
    local IconBar = Instance.new("Frame")
    IconBar.Name = "IconBar"
    IconBar.Size = UDim2.new(0, 0, 0, 50)
    IconBar.Position = UDim2.new(0.5, 0, 1, -65 - Window.IconOffset)
    IconBar.AnchorPoint = Vector2.new(0.5, 0)
    IconBar.BackgroundTransparency = 1
    IconBar.ZIndex = 10000
    IconBar.Parent = ScreenGui
    
    local IconLayout = Instance.new("UIListLayout")
    IconLayout.FillDirection = Enum.FillDirection.Horizontal
    IconLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    IconLayout.Padding = UDim.new(0, 10)
    IconLayout.Parent = IconBar
    
    -- MOVED DOWN - Change the -435 value to move it up/down (lower number = higher position, higher number = lower position)
    local ConnectionLine = Instance.new("Frame")
    ConnectionLine.Name = "ConnectionLine"
    ConnectionLine.Size = UDim2.new(0, 0, 0, 2)
    ConnectionLine.Position = UDim2.new(0.5, 0, 1, -50 - Window.IconOffset + Window.ConnectionLineYOffset)
    ConnectionLine.AnchorPoint = Vector2.new(0.5, 0.5)
    ConnectionLine.BackgroundColor3 = Library.Theme.Primary
    ConnectionLine.BackgroundTransparency = 1
    ConnectionLine.BorderSizePixel = 0
    ConnectionLine.ZIndex = 9997
    ConnectionLine.Visible = false
    ConnectionLine.Parent = ScreenGui
    
    AddGradient(ConnectionLine, Library.Theme.Primary, Library.Theme.PrimaryBright, 0)
    
    local TabNameContainer = Instance.new("Frame")
    TabNameContainer.Name = "TabNameContainer"
    TabNameContainer.Size = UDim2.new(0, 240, 0, 48)
    TabNameContainer.Position = UDim2.new(0.5, -120, 1, -65 - Window.IconOffset)
    TabNameContainer.BackgroundColor3 = Library.Theme.Surface
    TabNameContainer.BackgroundTransparency = 1
    TabNameContainer.BorderSizePixel = 0
    TabNameContainer.ZIndex = 9999
    TabNameContainer.Parent = ScreenGui
    
    Round(TabNameContainer, 12)
    AddStroke(TabNameContainer, Library.Theme.Primary, 2, 1)
    
    local TabNameLabel = Instance.new("TextLabel")
    TabNameLabel.Name = "TabNameLabel"
    TabNameLabel.Size = UDim2.new(1, 0, 1, 0)
    TabNameLabel.Position = UDim2.new(0, 0, 0, 0)
    TabNameLabel.BackgroundTransparency = 1
    TabNameLabel.Text = ""
    TabNameLabel.TextColor3 = Library.Theme.Primary
    TabNameLabel.TextSize = 22
    TabNameLabel.Font = Enum.Font.GothamBold
    TabNameLabel.TextXAlignment = Enum.TextXAlignment.Center
    TabNameLabel.TextTransparency = 1
    TabNameLabel.ZIndex = 10000
    TabNameLabel.Parent = TabNameContainer
    
    local Drawer = Instance.new("Frame")
    Drawer.Name = "Drawer"
    Drawer.Size = UDim2.new(0, 600, 0, 0)
    Drawer.Position = UDim2.new(0.5, -300, 1, -65 - Window.IconOffset)
    Drawer.BackgroundColor3 = Library.Theme.Background
    Drawer.BackgroundTransparency = 0.25
    Drawer.BorderSizePixel = 0
    Drawer.ClipsDescendants = true
    Drawer.Visible = false
    Drawer.ZIndex = 9998
    Drawer.Parent = ScreenGui
    
    Round(Drawer, 16)
    local DrawerStroke = AddStroke(Drawer, Library.Theme.Primary, 2, 0.4)
    
    local DrawerOverlay = Instance.new("Frame")
    DrawerOverlay.Size = UDim2.new(1, 0, 1, 0)
    DrawerOverlay.BackgroundTransparency = 0.96
    DrawerOverlay.BorderSizePixel = 0
    DrawerOverlay.ZIndex = 9998
    DrawerOverlay.Parent = Drawer
    
    Round(DrawerOverlay, 16)
    AddGradient(DrawerOverlay, Library.Theme.Primary, Library.Theme.Background, 180)
    
    local LeftStrokeCover = Instance.new("Frame")
    LeftStrokeCover.Name = "LeftStrokeCover"
    LeftStrokeCover.Size = UDim2.new(0, 120, 0, 4)
    LeftStrokeCover.Position = UDim2.new(0.5, -120, 0, -2)
    LeftStrokeCover.BackgroundColor3 = Library.Theme.Background
    LeftStrokeCover.BackgroundTransparency = 0.25
    LeftStrokeCover.BorderSizePixel = 0
    LeftStrokeCover.ZIndex = 9999
    LeftStrokeCover.Visible = false
    LeftStrokeCover.Parent = Drawer
    
    local RightStrokeCover = Instance.new("Frame")
    RightStrokeCover.Name = "RightStrokeCover"
    RightStrokeCover.Size = UDim2.new(0, 120, 0, 4)
    RightStrokeCover.Position = UDim2.new(0.5, 0, 0, -2)
    RightStrokeCover.BackgroundColor3 = Library.Theme.Background
    RightStrokeCover.BackgroundTransparency = 0.25
    RightStrokeCover.BorderSizePixel = 0
    RightStrokeCover.ZIndex = 9999
    RightStrokeCover.Visible = false
    RightStrokeCover.Parent = Drawer
    
    local ModuleList = Instance.new("ScrollingFrame")
    ModuleList.Name = "ModuleList"
    ModuleList.Size = UDim2.new(1, -40, 1, -20)
    ModuleList.Position = UDim2.new(0, 20, 0, 10)
    ModuleList.BackgroundTransparency = 1
    ModuleList.BorderSizePixel = 0
    ModuleList.ScrollBarThickness = 0
    ModuleList.ScrollBarImageColor3 = Library.Theme.Primary
    ModuleList.ScrollBarImageTransparency = 1
    ModuleList.CanvasSize = UDim2.new(0, 0, 0, 0)
    ModuleList.ZIndex = 9999
    ModuleList.Parent = Drawer
    
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Padding = UDim.new(0, 8)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Parent = ModuleList
    
    ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ModuleList.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 20)
    end)
    
    Window.IconBar = IconBar
    Window.IconLayout = IconLayout
    Window.Drawer = Drawer
    Window.DrawerStroke = DrawerStroke
    Window.ModuleList = ModuleList
    Window.ConnectionLine = ConnectionLine
    Window.TabNameContainer = TabNameContainer
    Window.TabNameLabel = TabNameLabel
    Window.LeftStrokeCover = LeftStrokeCover
    Window.RightStrokeCover = RightStrokeCover
    
    function Window:Open()
        if self.IsOpen or self.IsAnimating then return end
        self.IsAnimating = true
        self.IsOpen = true
        
        Drawer.Visible = true
        ConnectionLine.Visible = true
        
        self.DrawerStroke.Transparency = 0.4
        
        if self.CurrentTab then
            TabNameLabel.Text = self.CurrentTab.Name:upper()
            TabNameContainer.BackgroundTransparency = 1
            
            Tween(Drawer, {
                Size = UDim2.new(0, 600, 0, 400), 
                Position = UDim2.new(0.5, -300, 1, -480 - self.IconOffset)
            }, 0.7, Enum.EasingStyle.Quart)
            
            Tween(TabNameContainer, {
                Position = UDim2.new(0.5, -120, 1, -520 - self.IconOffset),
                BackgroundTransparency = 0.2
            }, 0.7, Enum.EasingStyle.Quart)
            
            Tween(TabNameContainer:FindFirstChildOfClass("UIStroke"), {Transparency = 0.4}, 0.7)
            Tween(TabNameLabel, {TextTransparency = 0}, 0.7, Enum.EasingStyle.Quart)
            
            LeftStrokeCover.Visible = true
            RightStrokeCover.Visible = true
        end
        
        ConnectionLine.BackgroundTransparency = 1
        ConnectionLine.Size = UDim2.new(0, 0, 0, 2)
        Tween(ConnectionLine, {
            Size = UDim2.new(0, 80, 0, 2), 
            BackgroundTransparency = 0.3
        }, 0.7, Enum.EasingStyle.Quart)
        
        task.wait(0.7)
        self.IsAnimating = false
    end
    
    function Window:Close()
        if not self.IsOpen or self.IsAnimating then return end
        self.IsAnimating = true
        self.IsOpen = false
        
        LeftStrokeCover.Visible = false
        RightStrokeCover.Visible = false
        
        Tween(TabNameLabel, {TextTransparency = 1}, 0.4, Enum.EasingStyle.Quart)
        Tween(TabNameContainer, {
            Position = UDim2.new(0.5, -120, 1, -65 - self.IconOffset),
            BackgroundTransparency = 1
        }, 0.5, Enum.EasingStyle.Quart)
        Tween(TabNameContainer:FindFirstChildOfClass("UIStroke"), {Transparency = 1}, 0.4)
        
        Tween(ConnectionLine, {
            Size = UDim2.new(0, 0, 0, 2), 
            BackgroundTransparency = 1
        }, 0.4, Enum.EasingStyle.Quart)
        
        task.wait(0.2)
        ConnectionLine.Visible = false
        
        Tween(self.DrawerStroke, {Transparency = 1}, 0.2, Enum.EasingStyle.Quart)
        
        local closePos = UDim2.new(0.5, -300, 1, -65 - self.IconOffset)
        Tween(Drawer, {
            Size = UDim2.new(0, 600, 0, 0), 
            Position = closePos
        }, 0.55, Enum.EasingStyle.Quart)
        
        task.wait(0.55)
        Drawer.Visible = false
        
        self.IsAnimating = false
    end
    
    function Window:Toggle()
        if self.IsAnimating then return end
        
        if self.IsOpen then
            if self.CurrentTab then
                Tween(self.CurrentTab.Cube, {BackgroundTransparency = 0.3}, 0.2)
                Tween(self.CurrentTab.Icon, {ImageColor3 = Library.Theme.TextDim}, 0.2)
                self.CurrentTab = nil
            end
            self:Close()
        else
            if #self.Tabs > 0 and not self.CurrentTab then
                self:SelectTab(self.Tabs[1])
            else
                self:Open()
            end
        end
    end
    
    -- TO MOVE THE CONNECTION LINE: Change the number in line that says "1, -180"
    -- LOWER number = line goes UP (example: -300)
    -- HIGHER number = line goes DOWN (example: -100)
    function Window:SetConnectionLineOffset(yOffset)
        self.ConnectionLineYOffset = yOffset
        ConnectionLine.Position = UDim2.new(0.5, 0, 1, -180 - self.IconOffset + self.ConnectionLineYOffset)
    end
    
    return Window
end

-- Create Tab
function Library:AddTab(config)
    config = config or {}
    
    local Tab = {
        Name = config.Name or "Tab",
        Icon = config.Icon or "home",
        Sections = {},
        Modules = {}
    }
    
    table.insert(self.Tabs, Tab)
    
    local Cube = Instance.new("TextButton")
    Cube.Name = Tab.Name
    Cube.Size = UDim2.new(0, 50, 0, 50)
    Cube.BackgroundColor3 = Library.Theme.Surface
    Cube.BackgroundTransparency = 0.3
    Cube.Text = ""
    Cube.ZIndex = 10000
    Cube.Parent = self.IconBar
    
    Round(Cube, 12)
    AddStroke(Cube, Library.Theme.Primary, 2, 0.6)
    
    local IconContainer, Icon = CreateIconFromSVG(Cube, Tab.Icon, 24, Library.Theme.TextDim)
    
    Tab.Cube = Cube
    Tab.Icon = Icon
    Tab.IconContainer = IconContainer
    
    Cube.MouseButton1Click:Connect(function()
        if self.IsAnimating then return end
        
        if self.CurrentTab == Tab then
            Tween(Cube, {BackgroundTransparency = 0.3}, 0.2)
            Tween(Icon, {ImageColor3 = Library.Theme.TextDim}, 0.2)
            self.CurrentTab = nil
            self:Close()
        else
            self:SelectTab(Tab)
        end
    end)
    
    Cube.MouseEnter:Connect(function()
        Tween(Cube, {BackgroundTransparency = 0.1}, 0.2, Enum.EasingStyle.Exponential)
        Tween(Icon, {ImageColor3 = Library.Theme.Primary}, 0.2, Enum.EasingStyle.Exponential)
    end)
    
    Cube.MouseLeave:Connect(function()
        if self.CurrentTab ~= Tab then
            Tween(Cube, {BackgroundTransparency = 0.3}, 0.2, Enum.EasingStyle.Exponential)
            Tween(Icon, {ImageColor3 = Library.Theme.TextDim}, 0.2, Enum.EasingStyle.Exponential)
        end
    end)
    
    task.wait()
    local totalWidth = #self.Tabs * 60
    self.IconBar.Size = UDim2.new(0, totalWidth, 0, 50)
    
    Tab.Window = self
    setmetatable(Tab, {__index = {
        AddSection = function(self, name)
            return Library:AddSection(self, name)
        end
    }})
    
    return Tab
end

function Library:SelectTab(tab)
    if self.IsAnimating then return end
    
    if self.CurrentTab then
        Tween(self.CurrentTab.Cube, {BackgroundTransparency = 0.3}, 0.2)
        Tween(self.CurrentTab.Icon, {ImageColor3 = Library.Theme.TextDim}, 0.2)
    end
    
    self.CurrentTab = tab
    Tween(tab.Cube, {BackgroundTransparency = 0}, 0.3, Enum.EasingStyle.Exponential)
    Tween(tab.Icon, {ImageColor3 = Library.Theme.Primary}, 0.3, Enum.EasingStyle.Exponential)
    
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
        self:Open()
    end
end

function Library:RefreshModules()
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
    local isFirstSection = true
    
    for _, module in ipairs(self.CurrentTab.Modules) do
        if module.Section and module.Section ~= lastSection then
            lastSection = module.Section
            
            local SectionContainer = Instance.new("Frame")
            SectionContainer.Name = "Section_" .. module.Section.Name
            SectionContainer.Size = UDim2.new(1, 0, 0, isFirstSection and 30 or 40)
            SectionContainer.BackgroundTransparency = 1
            SectionContainer.BorderSizePixel = 0
            SectionContainer.ZIndex = 9999
            SectionContainer.LayoutOrder = module.LayoutOrder - 0.5
            SectionContainer.Parent = self.ModuleList
            
            if not isFirstSection then
                local Divider = Instance.new("Frame")
                Divider.Size = UDim2.new(0.85, 0, 0, 3)
                Divider.Position = UDim2.new(0.5, 0, 0, 0)
                Divider.AnchorPoint = Vector2.new(0.5, 0)
                Divider.BackgroundColor3 = Library.Theme.Primary
                Divider.BackgroundTransparency = 0.6
                Divider.BorderSizePixel = 0
                Divider.ZIndex = 9999
                Divider.Parent = SectionContainer
                
                Round(Divider, 1.5)
                AddGradient(Divider, Library.Theme.Primary, Library.Theme.PrimaryBright, 0)
            end
            
            local SectionHeader = Instance.new("TextLabel")
            SectionHeader.Size = UDim2.new(1, -20, 0, 25)
            SectionHeader.Position = UDim2.new(0, 10, 0, isFirstSection and 3 or 12)
            SectionHeader.BackgroundTransparency = 1
            SectionHeader.Text = module.Section.Name
            SectionHeader.TextColor3 = Library.Theme.Primary
            SectionHeader.TextSize = 15
            SectionHeader.Font = Enum.Font.GothamBold
            SectionHeader.TextXAlignment = Enum.TextXAlignment.Left
            SectionHeader.TextYAlignment = Enum.TextYAlignment.Center
            SectionHeader.ZIndex = 10000
            SectionHeader.Parent = SectionContainer
            
            isFirstSection = false
        end
        
        module:Render(self.ModuleList)
    end
end

-- Surfy UI Library v2.0 - PART 2

-- Add Section
function Library:AddSection(tab, name)
    local section = { Name = name, Tab = tab }
    table.insert(tab.Sections, section)
    
    setmetatable(section, {__index = {
        AddToggle = function(self, config)
            return Library:AddToggle(self, config)
        end,
        AddSlider = function(self, config)
            return Library:AddSlider(self, config)
        end,
        AddDropdown = function(self, config)
            return Library:AddDropdown(self, config)
        end,
        AddButton = function(self, config)
            return Library:AddButton(self, config)
        end,
        AddKeybind = function(self, config)
            return Library:AddKeybind(self, config)
        end,
        AddColorPicker = function(self, config)
            return Library:AddColorPicker(self, config)
        end,
    }})
    
    return section
end

-- Add Toggle
function Library:AddToggle(section, config)
    config = config or {}
    
    local Module = {
        Name = config.Name or "Toggle",
        Enabled = config.Default or false,
        Callback = config.Callback,
        LayoutOrder = config.LayoutOrder or (#section.Tab.Modules + 1) * 10,
        Section = section
    }
    
    function Module:Render(parent)
        local Container = Instance.new("Frame")
        Container.Size = UDim2.new(1, 0, 0, 48)
        Container.BackgroundColor3 = Library.Theme.ModuleBackground
        Container.BackgroundTransparency = 0.3
        Container.BorderSizePixel = 0
        Container.ZIndex = 9999
        Container.LayoutOrder = self.LayoutOrder
        Container.Parent = parent
        
        Round(Container, 10)
        AddStroke(Container, Library.Theme.Surface, 1, 0.7)
        
        local Indicator = Instance.new("Frame")
        Indicator.Size = UDim2.new(0, 4, 0.65, 0)
        Indicator.Position = UDim2.new(0, 0, 0.175, 0)
        Indicator.BackgroundColor3 = Library.Theme.Primary
        Indicator.BackgroundTransparency = self.Enabled and 0 or 1
        Indicator.BorderSizePixel = 0
        Indicator.ZIndex = 10000
        Indicator.Parent = Container
        
        Round(Indicator, 2)
        
        if self.Enabled then
            AddGradient(Indicator, Library.Theme.PrimaryBright, Library.Theme.Primary, 90)
        end
        
        local NameLabel = Instance.new("TextLabel")
        NameLabel.Size = UDim2.new(1, -30, 1, 0)
        NameLabel.Position = UDim2.new(0, 15, 0, 0)
        NameLabel.BackgroundTransparency = 1
        NameLabel.Text = self.Name
        NameLabel.TextColor3 = self.Enabled and Library.Theme.Primary or Library.Theme.Text
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
            Tween(self.NameLabel, {TextColor3 = self.Enabled and Library.Theme.Primary or Library.Theme.Text}, 0.3, Enum.EasingStyle.Exponential)
            
            if self.Enabled then
                Tween(self.Container, {BackgroundColor3 = Library.Theme.SurfaceLight}, 0.3, Enum.EasingStyle.Exponential)
                for _, child in ipairs(self.Indicator:GetChildren()) do
                    if child:IsA("UIGradient") then child:Destroy() end
                end
                AddGradient(self.Indicator, Library.Theme.PrimaryBright, Library.Theme.Primary, 90)
            else
                Tween(self.Container, {BackgroundColor3 = Library.Theme.ModuleBackground}, 0.3, Enum.EasingStyle.Exponential)
            end
        end
        
        if self.Callback then
            self.Callback(self.Enabled)
        end
    end
    
    function Module:SetValue(value)
        self.Enabled = value
        if self.Container then
            self:Toggle()
            self:Toggle()
        end
    end
    
    table.insert(section.Tab.Modules, Module)
    return Module
end

-- Add Slider
function Library:AddSlider(section, config)
    config = config or {}
    
    local Module = {
        Name = config.Name or "Slider",
        Value = config.Default or config.Min or 0,
        Min = config.Min or 0,
        Max = config.Max or 100,
        Increment = config.Increment or 1,
        Callback = config.Callback,
        IsDragging = false,
        LayoutOrder = config.LayoutOrder or (#section.Tab.Modules + 1) * 10,
        Section = section
    }
    
    function Module:Render(parent)
        local Container = Instance.new("Frame")
        Container.Size = UDim2.new(1, 0, 0, 58)
        Container.BackgroundColor3 = Library.Theme.ModuleBackground
        Container.BackgroundTransparency = 0.3
        Container.BorderSizePixel = 0
        Container.ZIndex = 9999
        Container.LayoutOrder = self.LayoutOrder
        Container.Parent = parent
        
        Round(Container, 10)
        AddStroke(Container, Library.Theme.Surface, 1, 0.7)
        
        local NameLabel = Instance.new("TextLabel")
        NameLabel.Size = UDim2.new(0, 200, 0, 18)
        NameLabel.Position = UDim2.new(0, 15, 0, 10)
        NameLabel.BackgroundTransparency = 1
        NameLabel.Text = self.Name
        NameLabel.TextColor3 = Library.Theme.Text
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
        ValueLabel.TextColor3 = Library.Theme.Primary
        ValueLabel.TextSize = 13
        ValueLabel.Font = Enum.Font.GothamBold
        ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
        ValueLabel.ZIndex = 10000
        ValueLabel.Parent = Container
        
        local Track = Instance.new("Frame")
        Track.Size = UDim2.new(1, -30, 0, 6)
        Track.Position = UDim2.new(0, 15, 1, -20)
        Track.BackgroundColor3 = Library.Theme.Secondary
        Track.BackgroundTransparency = 0.4
        Track.BorderSizePixel = 0
        Track.ZIndex = 9999
        Track.Parent = Container
        
        Round(Track, 3)
        
        local normalizedValue = (self.Value - self.Min) / (self.Max - self.Min)
        
        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new(normalizedValue, 0, 1, 0)
        Fill.BackgroundColor3 = Library.Theme.Primary
        Fill.BackgroundTransparency = 0.2
        Fill.BorderSizePixel = 0
        Fill.ZIndex = 10000
        Fill.Parent = Track
        
        Round(Fill, 3)
        AddGradient(Fill, Library.Theme.Primary, Library.Theme.PrimaryBright, 0)
        
        local Knob = Instance.new("TextButton")
        Knob.Size = UDim2.new(0, 16, 0, 16)
        Knob.Position = UDim2.new(normalizedValue, -8, 0.5, -8)
        Knob.BackgroundColor3 = Color3.new(1, 1, 1)
        Knob.Text = ""
        Knob.ZIndex = 10001
        Knob.Parent = Track
        
        Round(Knob, 8)
        AddStroke(Knob, Library.Theme.Primary, 2, 0.3)
        
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
            
            local rawValue = self.Min + (self.Max - self.Min) * clampedX
            local newValue = math.floor(rawValue / self.Increment) * self.Increment
            
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

-- Add Dropdown
function Library:AddDropdown(section, config)
    config = config or {}
    
    local Module = {
        Name = config.Name or "Dropdown",
        Value = config.Default or (config.Options and config.Options[1]) or "None",
        Options = config.Options or {"Option 1"},
        Callback = config.Callback,
        IsOpen = false,
        LayoutOrder = config.LayoutOrder or (#section.Tab.Modules + 1) * 10,
        Section = section
    }
    
    function Module:Render(parent)
        local Container = Instance.new("Frame")
        Container.Size = UDim2.new(1, 0, 0, 48)
        Container.BackgroundColor3 = Library.Theme.ModuleBackground
        Container.BackgroundTransparency = 0.3
        Container.BorderSizePixel = 0
        Container.ZIndex = 9999
        Container.ClipsDescendants = false
        Container.LayoutOrder = self.LayoutOrder
        Container.Parent = parent
        
        Round(Container, 10)
        AddStroke(Container, Library.Theme.Surface, 1, 0.7)
        
        local NameLabel = Instance.new("TextLabel")
        NameLabel.Size = UDim2.new(0, 200, 1, 0)
        NameLabel.Position = UDim2.new(0, 15, 0, 0)
        NameLabel.BackgroundTransparency = 1
        NameLabel.Text = self.Name
        NameLabel.TextColor3 = Library.Theme.Text
        NameLabel.TextSize = 13
        NameLabel.Font = Enum.Font.GothamBold
        NameLabel.TextXAlignment = Enum.TextXAlignment.Left
        NameLabel.ZIndex = 10000
        NameLabel.Parent = Container
        
        local DropBtn = Instance.new("TextButton")
        DropBtn.Size = UDim2.new(0, 140, 0, 32)
        DropBtn.Position = UDim2.new(1, -150, 0.5, -16)
        DropBtn.BackgroundColor3 = Library.Theme.Secondary
        DropBtn.BackgroundTransparency = 0.4
        DropBtn.Text = self.Value
        DropBtn.TextColor3 = Library.Theme.Text
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
        Arrow.TextColor3 = Library.Theme.TextDim
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
                OptionsFrame.BackgroundColor3 = Library.Theme.Surface
                OptionsFrame.BackgroundTransparency = 0.15
                OptionsFrame.BorderSizePixel = 0
                OptionsFrame.ZIndex = 15000
                OptionsFrame.Parent = Container
                
                Round(OptionsFrame, 8)
                AddStroke(OptionsFrame, Library.Theme.Primary, 1.5, 0.4)
                
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
                    OptBtn.BackgroundColor3 = Library.Theme.SurfaceLight
                    OptBtn.BackgroundTransparency = 1
                    OptBtn.Text = option
                    OptBtn.TextColor3 = (self.Value == option) and Library.Theme.Primary or Library.Theme.Text
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
    
    function Module:SetValue(value)
        self.Value = value
        if self.DropBtn then
            self.DropBtn.Text = value
        end
        if self.Callback then
            self.Callback(value)
        end
    end
    
    table.insert(section.Tab.Modules, Module)
    return Module
end

-- Add Button
function Library:AddButton(section, config)
    config = config or {}
    
    local Module = {
        Name = config.Name or "Button",
        Callback = config.Callback,
        LayoutOrder = config.LayoutOrder or (#section.Tab.Modules + 1) * 10,
        Section = section
    }
    
    function Module:Render(parent)
        local Container = Instance.new("TextButton")
        Container.Size = UDim2.new(1, 0, 0, 48)
        Container.BackgroundColor3 = Library.Theme.ModuleBackground
        Container.BackgroundTransparency = 0.3
        Container.BorderSizePixel = 0
        Container.ZIndex = 9999
        Container.LayoutOrder = self.LayoutOrder
        Container.Text = ""
        Container.Parent = parent
        
        Round(Container, 10)
        AddStroke(Container, Library.Theme.Surface, 1, 0.7)
        
        local NameLabel = Instance.new("TextLabel")
        NameLabel.Size = UDim2.new(1, -30, 1, 0)
        NameLabel.Position = UDim2.new(0, 15, 0, 0)
        NameLabel.BackgroundTransparency = 1
        NameLabel.Text = self.Name
        NameLabel.TextColor3 = Library.Theme.Text
        NameLabel.TextSize = 14
        NameLabel.Font = Enum.Font.GothamBold
        NameLabel.TextXAlignment = Enum.TextXAlignment.Center
        NameLabel.ZIndex = 10000
        NameLabel.Parent = Container
        
        Module.Container = Container
        Module.NameLabel = NameLabel
        
        Container.MouseEnter:Connect(function()
            Tween(Container, {BackgroundColor3 = Library.Theme.SurfaceLight}, 0.2, Enum.EasingStyle.Exponential)
            Tween(NameLabel, {TextColor3 = Library.Theme.Primary}, 0.2, Enum.EasingStyle.Exponential)
        end)
        
        Container.MouseLeave:Connect(function()
            Tween(Container, {BackgroundColor3 = Library.Theme.ModuleBackground}, 0.2, Enum.EasingStyle.Exponential)
            Tween(NameLabel, {TextColor3 = Library.Theme.Text}, 0.2, Enum.EasingStyle.Exponential)
        end)
        
        Container.MouseButton1Click:Connect(function()
            Tween(Container, {BackgroundColor3 = Library.Theme.Primary}, 0.1, Enum.EasingStyle.Exponential)
            Tween(NameLabel, {TextColor3 = Color3.new(1, 1, 1)}, 0.1, Enum.EasingStyle.Exponential)
            
            task.wait(0.1)
            
            Tween(Container, {BackgroundColor3 = Library.Theme.ModuleBackground}, 0.2, Enum.EasingStyle.Exponential)
            Tween(NameLabel, {TextColor3 = Library.Theme.Text}, 0.2, Enum.EasingStyle.Exponential)
            
            if self.Callback then
                self.Callback()
            end
        end)
    end
    
    table.insert(section.Tab.Modules, Module)
    return Module
end

-- Add Keybind
function Library:AddKeybind(section, config)
    config = config or {}
    
    local Module = {
        Name = config.Name or "Keybind",
        Key = config.Default or Enum.KeyCode.RightShift,
        Callback = config.Callback,
        IsBinding = false,
        LayoutOrder = config.LayoutOrder or (#section.Tab.Modules + 1) * 10,
        Section = section
    }
    
    function Module:Render(parent)
        local Container = Instance.new("Frame")
        Container.Size = UDim2.new(1, 0, 0, 48)
        Container.BackgroundColor3 = Library.Theme.ModuleBackground
        Container.BackgroundTransparency = 0.3
        Container.BorderSizePixel = 0
        Container.ZIndex = 9999
        Container.LayoutOrder = self.LayoutOrder
        Container.Parent = parent
        
        Round(Container, 10)
        AddStroke(Container, Library.Theme.Surface, 1, 0.7)
        
        local NameLabel = Instance.new("TextLabel")
        NameLabel.Size = UDim2.new(0, 200, 1, 0)
        NameLabel.Position = UDim2.new(0, 15, 0, 0)
        NameLabel.BackgroundTransparency = 1
        NameLabel.Text = self.Name
        NameLabel.TextColor3 = Library.Theme.Text
        NameLabel.TextSize = 13
        NameLabel.Font = Enum.Font.GothamBold
        NameLabel.TextXAlignment = Enum.TextXAlignment.Left
        NameLabel.ZIndex = 10000
        NameLabel.Parent = Container
        
        local function GetKeyName(key)
            if key == Enum.KeyCode.Unknown then return "NONE"
            elseif key == Enum.UserInputType.MouseButton1 then return "M1"
            elseif key == Enum.UserInputType.MouseButton2 then return "M2"
            elseif key == Enum.UserInputType.MouseButton3 then return "MMB"
            else return key.Name:upper() end
        end
        
        local KeybindLabel = Instance.new("TextButton")
        KeybindLabel.Size = UDim2.new(0, 80, 0, 28)
        KeybindLabel.Position = UDim2.new(1, -90, 0.5, -14)
        KeybindLabel.BackgroundColor3 = Library.Theme.Secondary
        KeybindLabel.BackgroundTransparency = 0.4
        KeybindLabel.Text = GetKeyName(self.Key)
        KeybindLabel.TextColor3 = Library.Theme.TextDim
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
            KeybindLabel.TextColor3 = Library.Theme.Primary
            
            local connection
            connection = UserInputService.InputBegan:Connect(function(input2)
                if input2.KeyCode ~= Enum.KeyCode.Unknown then
                    self.Key = input2.KeyCode
                elseif input2.UserInputType == Enum.UserInputType.MouseButton1 or
                       input2.UserInputType == Enum.UserInputType.MouseButton2 or
                       input2.UserInputType == Enum.UserInputType.MouseButton3 then
                    self.Key = input2.UserInputType
                end
                
                KeybindLabel.Text = GetKeyName(self.Key)
                KeybindLabel.TextColor3 = Library.Theme.TextDim
                self.IsBinding = false
                connection:Disconnect()
            end)
        end)
        
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if not gameProcessed and not self.IsBinding then
                if (input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode == self.Key) or
                   (input.UserInputType == self.Key) then
                    if self.Callback then
                        self.Callback()
                    end
                end
            end
        end)
    end
    
    table.insert(section.Tab.Modules, Module)
    return Module
end

-- Add ColorPicker
function Library:AddColorPicker(section, config)
    config = config or {}
    
    local Module = {
        Name = config.Name or "Color",
        Value = config.Default or Color3.fromRGB(0, 230, 255),
        Callback = config.Callback,
        LayoutOrder = config.LayoutOrder or (#section.Tab.Modules + 1) * 10,
        Section = section
    }
    
    function Module:Render(parent)
        local Container = Instance.new("Frame")
        Container.Size = UDim2.new(1, 0, 0, 48)
        Container.BackgroundColor3 = Library.Theme.ModuleBackground
        Container.BackgroundTransparency = 0.3
        Container.BorderSizePixel = 0
        Container.ZIndex = 9999
        Container.LayoutOrder = self.LayoutOrder
        Container.Parent = parent
        
        Round(Container, 10)
        AddStroke(Container, Library.Theme.Surface, 1, 0.7)
        
        local NameLabel = Instance.new("TextLabel")
        NameLabel.Size = UDim2.new(0, 200, 1, 0)
        NameLabel.Position = UDim2.new(0, 15, 0, 0)
        NameLabel.BackgroundTransparency = 1
        NameLabel.Text = self.Name
        NameLabel.TextColor3 = Library.Theme.Text
        NameLabel.TextSize = 13
        NameLabel.Font = Enum.Font.GothamBold
        NameLabel.TextXAlignment = Enum.TextXAlignment.Left
        NameLabel.ZIndex = 10000
        NameLabel.Parent = Container
        
        local ColorBtn = Instance.new("TextButton")
        ColorBtn.Size = UDim2.new(0, 60, 0, 28)
        ColorBtn.Position = UDim2.new(1, -70, 0.5, -14)
        ColorBtn.BackgroundColor3 = self.Value
        ColorBtn.BackgroundTransparency = 0.1
        ColorBtn.Text = ""
        ColorBtn.ZIndex = 10000
        ColorBtn.Parent = Container
        
        Round(ColorBtn, 8)
        AddStroke(ColorBtn, Color3.new(1, 1, 1), 2, 0.7)
        
        local colors = {
            Color3.fromRGB(255, 50, 50),
            Color3.fromRGB(255, 150, 50),
            Color3.fromRGB(255, 255, 50),
            Color3.fromRGB(50, 255, 50),
            Color3.fromRGB(50, 255, 255),
            Color3.fromRGB(50, 150, 255),
            Color3.fromRGB(150, 50, 255),
            Color3.fromRGB(255, 255, 255)
        }
        
        local currentIndex = 1
        
        ColorBtn.MouseButton1Click:Connect(function()
            currentIndex = (currentIndex % #colors) + 1
            self.Value = colors[currentIndex]
            
            Tween(ColorBtn, {BackgroundColor3 = self.Value}, 0.3, Enum.EasingStyle.Exponential)
            
            if self.Callback then
                self.Callback(self.Value)
            end
        end)
    end
    
    function Module:SetValue(value)
        self.Value = value
        if self.Callback then
            self.Callback(value)
        end
    end
    
    table.insert(section.Tab.Modules, Module)
    return Module
end

return Library
