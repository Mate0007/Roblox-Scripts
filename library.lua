-- Surfy TC2 - Bottom Drawer UI (FIXED WITH PROPER SECTIONS & CONNECTOR LINE)
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local SurfyUI = {}
SurfyUI.__index = SurfyUI

-- Aqua Theme
SurfyUI.Theme = {
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
end

local function CreateIcon(parent, iconName)
    local iconPaths = {
        Combat = "rbxassetid://7733992358",
        Visuals = "rbxassetid://7733920644",
        Movement = "rbxassetid://7734000129",
        Misc = "rbxassetid://7734053495",
        Settings = "rbxassetid://7734053495"
    }
    
    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, 24, 0, 24)
    icon.Position = UDim2.new(0.5, -12, 0.5, -12)
    icon.BackgroundTransparency = 1
    icon.ImageColor3 = SurfyUI.Theme.TextDim
    icon.Image = iconPaths[iconName] or iconPaths.Misc
    icon.ZIndex = 10001
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
    
    local Overlay = Instance.new("Frame")
    Overlay.Size = UDim2.new(1, 0, 1, 0)
    Overlay.BackgroundTransparency = 0.92
    Overlay.BorderSizePixel = 0
    Overlay.ZIndex = 10000
    Overlay.Parent = Notification
    
    Round(Overlay, 12)
    AddGradient(Overlay, SurfyUI.Theme.Primary, SurfyUI.Theme.Background, 135)
    
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 2)
    TopBar.BackgroundColor3 = SurfyUI.Theme.Primary
    TopBar.BorderSizePixel = 0
    TopBar.ZIndex = 10001
    TopBar.Parent = Notification
    
    AddGradient(TopBar, SurfyUI.Theme.PrimaryBright, SurfyUI.Theme.Primary, 90)
    
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
    Title.Text = config.Title or "Notification"
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
    Description.Text = config.Description or ""
    Description.TextColor3 = SurfyUI.Theme.TextDim
    Description.TextSize = 11
    Description.Font = Enum.Font.Gotham
    Description.TextXAlignment = Enum.TextXAlignment.Left
    Description.TextYAlignment = Enum.TextYAlignment.Top
    Description.TextWrapped = true
    Description.ZIndex = 10001
    Description.Parent = Notification
    
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
        Tabs = {},
        CurrentTab = nil,
        IsOpen = false,
        IconOffset = config.IconOffset or 20
    }
    setmetatable(Window, SurfyUI)
    
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
    IconBar.Position = UDim2.new(0.5, 0, 1, -65)
    IconBar.AnchorPoint = Vector2.new(0.5, 0)
    IconBar.BackgroundTransparency = 1
    IconBar.ZIndex = 10000
    IconBar.Parent = ScreenGui
    
    local IconLayout = Instance.new("UIListLayout")
    IconLayout.FillDirection = Enum.FillDirection.Horizontal
    IconLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    IconLayout.Padding = UDim.new(0, 10)
    IconLayout.Parent = IconBar
    
    -- Connector Line between tabs and drawer
    local ConnectorLine = Instance.new("Frame")
    ConnectorLine.Name = "ConnectorLine"
    ConnectorLine.Size = UDim2.new(0, 1, 0, 0)
    ConnectorLine.Position = UDim2.new(0.5, 0, 1, -65)
    ConnectorLine.AnchorPoint = Vector2.new(0.5, 1)
    ConnectorLine.BackgroundColor3 = SurfyUI.Theme.Primary
    ConnectorLine.BackgroundTransparency = 0.3
    ConnectorLine.BorderSizePixel = 0
    ConnectorLine.ZIndex = 9997
    ConnectorLine.Visible = false
    ConnectorLine.Parent = ScreenGui
    
    AddGradient(ConnectorLine, SurfyUI.Theme.Primary, SurfyUI.Theme.PrimaryBright, 90)
    
    local Drawer = Instance.new("Frame")
    Drawer.Name = "Drawer"
    Drawer.Size = UDim2.new(0, 600, 0, 0)
    Drawer.Position = UDim2.new(0.5, -300, 1, -65)
    Drawer.BackgroundColor3 = SurfyUI.Theme.Background
    Drawer.BackgroundTransparency = 0.05
    Drawer.BorderSizePixel = 0
    Drawer.ClipsDescendants = true
    Drawer.Visible = false
    Drawer.ZIndex = 9998
    Drawer.Parent = ScreenGui
    
    Round(Drawer, 16)
    AddStroke(Drawer, SurfyUI.Theme.Primary, 2, 0.4)
    
    local DrawerOverlay = Instance.new("Frame")
    DrawerOverlay.Size = UDim2.new(1, 0, 1, 0)
    DrawerOverlay.BackgroundTransparency = 0.95
    DrawerOverlay.BorderSizePixel = 0
    DrawerOverlay.ZIndex = 9998
    DrawerOverlay.Parent = Drawer
    
    Round(DrawerOverlay, 16)
    AddGradient(DrawerOverlay, SurfyUI.Theme.Primary, SurfyUI.Theme.Background, 180)
    
    local ModuleList = Instance.new("ScrollingFrame")
    ModuleList.Name = "ModuleList"
    ModuleList.Size = UDim2.new(1, -40, 1, -20)
    ModuleList.Position = UDim2.new(0, 20, 0, 10)
    ModuleList.BackgroundTransparency = 1
    ModuleList.BorderSizePixel = 0
    ModuleList.ScrollBarThickness = 4
    ModuleList.ScrollBarImageColor3 = SurfyUI.Theme.Primary
    ModuleList.ScrollBarImageTransparency = 0.5
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
    Window.ConnectorLine = ConnectorLine
    Window.Drawer = Drawer
    Window.ModuleList = ModuleList
    
    function Window:Open()
        if self.IsOpen then return end
        self.IsOpen = true
        
        Drawer.Visible = true
        ConnectorLine.Visible = true
        
        Tween(Drawer, {Size = UDim2.new(0, 600, 0, 400), Position = UDim2.new(0.5, -300, 1, -475)}, 0.4, Enum.EasingStyle.Back)
        Tween(ConnectorLine, {Size = UDim2.new(0, 1, 0, 10)}, 0.3, Enum.EasingStyle.Quint)
    end
    
    function Window:Close()
        if not self.IsOpen then return end
        self.IsOpen = false
        
        Tween(Drawer, {Size = UDim2.new(0, 600, 0, 0), Position = UDim2.new(0.5, -300, 1, -65)}, 0.3, Enum.EasingStyle.Quint)
        Tween(ConnectorLine, {Size = UDim2.new(0, 1, 0, 0)}, 0.2, Enum.EasingStyle.Quint)
        
        task.wait(0.3)
        Drawer.Visible = false
        ConnectorLine.Visible = false
    end
    
    function Window:Toggle()
        if self.IsOpen then
            if self.CurrentTab then
                Tween(self.CurrentTab.Cube, {BackgroundTransparency = 0.3}, 0.2)
                Tween(self.CurrentTab.Icon, {ImageColor3 = SurfyUI.Theme.TextDim}, 0.2)
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
    
    task.delay(0.1, function()
        self:CreateNotification({
            Title = config.Title or "Surfy UI",
            Description = "Click any icon to open",
            Duration = 5
        })
    end)
    
    return Window
end

function SurfyUI:CreateTab(name)
    local Tab = {
        Name = name,
        Sections = {},
        Modules = {}
    }
    
    table.insert(self.Tabs, Tab)
    
    local Cube = Instance.new("TextButton")
    Cube.Name = name
    Cube.Size = UDim2.new(0, 50, 0, 50)
    Cube.BackgroundColor3 = SurfyUI.Theme.Surface
    Cube.BackgroundTransparency = 0.3
    Cube.Text = ""
    Cube.ZIndex = 10000
    Cube.Parent = self.IconBar
    
    Round(Cube, 12)
    AddStroke(Cube, SurfyUI.Theme.Primary, 2, 0.6)
    
    local Icon = CreateIcon(Cube, name)
    
    Tab.Cube = Cube
    Tab.Icon = Icon
    
    Cube.MouseButton1Click:Connect(function()
        if self.CurrentTab == Tab then
            Tween(Cube, {BackgroundTransparency = 0.3}, 0.2)
            Tween(Icon, {ImageColor3 = SurfyUI.Theme.TextDim}, 0.2)
            self.CurrentTab = nil
            self:Close()
        else
            self:SelectTab(Tab)
        end
    end)
    
    Cube.MouseEnter:Connect(function()
        Tween(Cube, {BackgroundTransparency = 0.1}, 0.2)
        Tween(Icon, {ImageColor3 = SurfyUI.Theme.Primary}, 0.2)
    end)
    
    Cube.MouseLeave:Connect(function()
        if self.CurrentTab ~= Tab then
            Tween(Cube, {BackgroundTransparency = 0.3}, 0.2)
            Tween(Icon, {ImageColor3 = SurfyUI.Theme.TextDim}, 0.2)
        end
    end)
    
    task.wait()
    local totalWidth = #self.Tabs * 60
    self.IconBar.Size = UDim2.new(0, totalWidth, 0, 50)
    
    return Tab
end

function SurfyUI:SelectTab(tab)
    if self.CurrentTab then
        Tween(self.CurrentTab.Cube, {BackgroundTransparency = 0.3}, 0.2)
        Tween(self.CurrentTab.Icon, {ImageColor3 = SurfyUI.Theme.TextDim}, 0.2)
    end
    
    self.CurrentTab = tab
    Tween(tab.Cube, {BackgroundTransparency = 0}, 0.3)
    Tween(tab.Icon, {ImageColor3 = SurfyUI.Theme.Primary}, 0.3)
    
    self:RefreshModules()
    
    if not self.IsOpen then
        self:Open()
    end
end

function SurfyUI:RefreshModules()
    for _, child in ipairs(self.ModuleList:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    
    if not self.CurrentTab then return end
    
    -- Sort modules by their order, sections will be placed where they're defined
    table.sort(self.CurrentTab.Modules, function(a, b)
        return a.LayoutOrder < b.LayoutOrder
    end)
    
    local lastSection = nil
    
    for _, module in ipairs(self.CurrentTab.Modules) do
        -- Check if this module has a different section than the last one
        if module.Section and module.Section ~= lastSection then
            lastSection = module.Section
            
            local SectionContainer = Instance.new("Frame")
            SectionContainer.Name = "Section_" .. module.Section.Name
            SectionContainer.Size = UDim2.new(1, 0, 0, 38)
            SectionContainer.BackgroundTransparency = 1
            SectionContainer.BorderSizePixel = 0
            SectionContainer.ZIndex = 9999
            SectionContainer.LayoutOrder = module.LayoutOrder
            SectionContainer.Parent = self.ModuleList
            
            local SectionHeader = Instance.new("TextLabel")
            SectionHeader.Size = UDim2.new(1, -20, 1, 0)
            SectionHeader.Position = UDim2.new(0, 10, 0, 0)
            SectionHeader.BackgroundTransparency = 1
            SectionHeader.Text = module.Section.Name
            SectionHeader.TextColor3 = SurfyUI.Theme.Text
            SectionHeader.TextSize = 14
            SectionHeader.Font = Enum.Font.GothamBold
            SectionHeader.TextXAlignment = Enum.TextXAlignment.Left
            SectionHeader.TextYAlignment = Enum.TextYAlignment.Center
            SectionHeader.ZIndex = 10000
            SectionHeader.Parent = SectionContainer
        end
        
        module:Render(self.ModuleList)
    end
end

function SurfyUI:CreateSection(tab, name)
    local section = { Name = name, Tab = tab }
    table.insert(tab.Sections, section)
    return section
end

function SurfyUI:CreateToggle(section, config)
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
        Container.BackgroundTransparency = 0.2
        Container.BorderSizePixel = 0
        Container.ZIndex = 9999
        Container.LayoutOrder = self.LayoutOrder + 1
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
            Tween(self.Indicator, {BackgroundTransparency = self.Enabled and 0 or 1}, 0.3)
            Tween(self.NameLabel, {TextColor3 = self.Enabled and SurfyUI.Theme.Primary or SurfyUI.Theme.Text}, 0.3)
            
            if self.Enabled then
                Tween(self.Container, {BackgroundColor3 = SurfyUI.Theme.SurfaceLight}, 0.3)
                for _, child in ipairs(self.Indicator:GetChildren()) do
                    if child:IsA("UIGradient") then child:Destroy() end
                end
                AddGradient(self.Indicator, SurfyUI.Theme.PrimaryBright, SurfyUI.Theme.Primary, 90)
            else
                Tween(self.Container, {BackgroundColor3 = SurfyUI.Theme.ModuleBackground}, 0.3)
            end
        end
        
        if self.Callback then
            self.Callback(self.Enabled)
        end
    end
    
    table.insert(section.Tab.Modules, Module)
    return Module
end

function SurfyUI:CreateToggleWithKeybind(section, config)
    config = config or {}
    
    local Module = {
        Name = config.Title or "Toggle",
        Enabled = config.Default or false,
        Key = config.DefaultKey or Enum.KeyCode.Unknown,
        Callback = config.Callback,
        KeybindCallback = config.KeybindCallback,
        IsBinding = false,
        LayoutOrder = config.LayoutOrder or 999,
        Section = section
    }
    
    function Module:Render(parent)
        local Container = Instance.new("Frame")
        Container.Size = UDim2.new(1, 0, 0, 48)
        Container.BackgroundColor3 = SurfyUI.Theme.ModuleBackground
        Container.BackgroundTransparency = 0.2
        Container.BorderSizePixel = 0
        Container.ZIndex = 9999
        Container.LayoutOrder = self.LayoutOrder + 1
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
        NameLabel.Size = UDim2.new(1, -160, 1, 0)
        NameLabel.Position = UDim2.new(0, 15, 0, 0)
        NameLabel.BackgroundTransparency = 1
        NameLabel.Text = self.Name
        NameLabel.TextColor3 = self.Enabled and SurfyUI.Theme.Primary or SurfyUI.Theme.Text
        NameLabel.TextSize = 14
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
        KeybindLabel.Size = UDim2.new(0, 60, 0, 24)
        KeybindLabel.Position = UDim2.new(1, -70, 0.5, -12)
        KeybindLabel.BackgroundColor3 = SurfyUI.Theme.SurfaceLight
        KeybindLabel.BackgroundTransparency = 0.5
        KeybindLabel.Text = GetKeyName(self.Key)
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
        
        Container.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                self:Toggle()
            end
        end)
        
        KeybindLabel.MouseButton1Click:Connect(function()
            self.IsBinding = true
            KeybindLabel.Text = "..."
            KeybindLabel.TextColor3 = SurfyUI.Theme.Primary
            
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
                KeybindLabel.TextColor3 = SurfyUI.Theme.TextDim
                self.IsBinding = false
                connection:Disconnect()
            end)
        end)
        
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if not gameProcessed and not self.IsBinding then
                if (input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode == self.Key) or
                   (input.UserInputType == self.Key) then
                    if self.KeybindCallback then
                        self.KeybindCallback()
                    end
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
                for _, child in ipairs(self.Indicator:GetChildren()) do
