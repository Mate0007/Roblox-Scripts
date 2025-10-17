-- Surfy TC2 Library - Custom Fluent UI Library
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Custom Fluent UI Library
local FluentUI = {}
FluentUI.__index = FluentUI

-- Aqua Color Theme
FluentUI.Theme = {
    Primary = Color3.fromRGB(0, 180, 255),
    PrimaryLight = Color3.fromRGB(100, 220, 255),
    Secondary = Color3.fromRGB(25, 35, 45),
    Background = Color3.fromRGB(20, 30, 40),
    Surface = Color3.fromRGB(40, 50, 60),
    SurfaceLight = Color3.fromRGB(50, 60, 70),
    Text = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(180, 200, 220),
    Success = Color3.fromRGB(0, 200, 100),
    Error = Color3.fromRGB(255, 80, 80)
}

-- Utility Functions
local function Tween(Object, Properties, Duration, Style, Direction)
    local TweenInfo = TweenInfo.new(
        Duration or 0.3, 
        Style or Enum.EasingStyle.Quint, 
        Direction or Enum.EasingDirection.Out
    )
    local Tween = TweenService:Create(Object, TweenInfo, Properties)
    Tween:Play()
    return Tween
end

local function RoundCorners(Object, Radius)
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, Radius or 6)
    UICorner.Parent = Object
    return UICorner
end

-- Notification System
FluentUI.NotificationQueue = {}

function FluentUI:CreateNotification(Config)
    Config = Config or {}
    
    local NotifContainer = self.NotificationContainer
    
    local Notification = Instance.new("Frame")
    Notification.Name = "Notification"
    Notification.Size = UDim2.new(0, 300, 0, 80)
    Notification.Position = UDim2.new(1, 320, 1, -100 - (#self.NotificationQueue * 90))
    Notification.BackgroundColor3 = FluentUI.Theme.Surface
    Notification.BackgroundTransparency = 0.1
    Notification.BorderSizePixel = 0
    Notification.Parent = NotifContainer
    
    RoundCorners(Notification, 8)
    
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.BackgroundTransparency = 1
    Shadow.Position = UDim2.new(0, -15, 0, -15)
    Shadow.Size = UDim2.new(1, 30, 1, 30)
    Shadow.ZIndex = 0
    Shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.7
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(10, 10, 10, 10)
    Shadow.Parent = Notification
    
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -20, 0, 25)
    Title.Position = UDim2.new(0, 10, 0, 10)
    Title.BackgroundTransparency = 1
    Title.Text = Config.Title or "Notification"
    Title.TextColor3 = FluentUI.Theme.Text
    Title.TextSize = 14
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Notification
    
    local Description = Instance.new("TextLabel")
    Description.Name = "Description"
    Description.Size = UDim2.new(1, -20, 0, 35)
    Description.Position = UDim2.new(0, 10, 0, 35)
    Description.BackgroundTransparency = 1
    Description.Text = Config.Description or ""
    Description.TextColor3 = FluentUI.Theme.SubText
    Description.TextSize = 12
    Description.Font = Enum.Font.Gotham
    Description.TextXAlignment = Enum.TextXAlignment.Left
    Description.TextYAlignment = Enum.TextYAlignment.Top
    Description.TextWrapped = true
    Description.Parent = Notification
    
    table.insert(self.NotificationQueue, Notification)
    
    Tween(Notification, {Position = UDim2.new(1, -310, 1, -100 - ((#self.NotificationQueue - 1) * 90))}, 0.5, Enum.EasingStyle.Back)
    
    task.delay(Config.Duration or 3, function()
        Tween(Notification, {Position = UDim2.new(1, 320, 1, Notification.Position.Y.Offset)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.4)
        
        for i, notif in ipairs(self.NotificationQueue) do
            if notif == Notification then
                table.remove(self.NotificationQueue, i)
                break
            end
        end
        
        Notification:Destroy()
        
        for i, notif in ipairs(self.NotificationQueue) do
            Tween(notif, {Position = UDim2.new(1, -310, 1, -100 - ((i - 1) * 90))}, 0.3)
        end
    end)
end

-- Create Window
function FluentUI:CreateWindow(Config)
    Config = Config or {}
    
    local Window = {
        Tabs = {},
        CurrentTab = nil,
        IsMinimized = false,
        IsVisible = false,
        SavedPosition = nil
    }
    setmetatable(Window, FluentUI)
    
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    Window.ScreenGui = Instance.new("ScreenGui")
    Window.ScreenGui.Name = "FluentUI"
    Window.ScreenGui.ResetOnSpawn = false
    Window.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    Window.ScreenGui.DisplayOrder = 999
    Window.ScreenGui.Parent = PlayerGui
    
    Window.NotificationContainer = Instance.new("Frame")
    Window.NotificationContainer.Name = "Notifications"
    Window.NotificationContainer.Size = UDim2.new(1, 0, 1, 0)
    Window.NotificationContainer.BackgroundTransparency = 1
    Window.NotificationContainer.Parent = Window.ScreenGui
    
    self.NotificationContainer = Window.NotificationContainer
    
    Window.MainFrame = Instance.new("Frame")
    Window.MainFrame.Name = "MainFrame"
    Window.MainFrame.Size = UDim2.new(0, 650, 0, 420)
    Window.MainFrame.Position = UDim2.new(0.5, -325, 0.5, -210)
    Window.MainFrame.BackgroundColor3 = FluentUI.Theme.Background
    Window.MainFrame.BackgroundTransparency = 0.15
    Window.MainFrame.BorderSizePixel = 0
    Window.MainFrame.Visible = false
    Window.MainFrame.ClipsDescendants = true
    Window.MainFrame.Parent = Window.ScreenGui
    
    RoundCorners(Window.MainFrame, 14)
    
    -- Animated Background
    local AnimatedBG = Instance.new("Frame")
    AnimatedBG.Name = "AnimatedBackground"
    AnimatedBG.Size = UDim2.new(1, 0, 1, 0)
    AnimatedBG.BackgroundTransparency = 0.95
    AnimatedBG.BorderSizePixel = 0
    AnimatedBG.ZIndex = 0
    AnimatedBG.Parent = Window.MainFrame
    
    local BGGradient = Instance.new("UIGradient")
    BGGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, FluentUI.Theme.Primary),
        ColorSequenceKeypoint.new(0.5, FluentUI.Theme.PrimaryLight),
        ColorSequenceKeypoint.new(1, FluentUI.Theme.Primary)
    }
    BGGradient.Rotation = 45
    BGGradient.Parent = AnimatedBG
    
    task.spawn(function()
        while Window.MainFrame and Window.MainFrame.Parent do
            for i = 0, 360, 2 do
                if not Window.MainFrame or not Window.MainFrame.Parent then break end
                BGGradient.Rotation = i
                task.wait(0.05)
            end
        end
    end)
    
    Window.Header = Instance.new("Frame")
    Window.Header.Name = "Header"
    Window.Header.Size = UDim2.new(1, 0, 0, 40)
    Window.Header.BackgroundColor3 = FluentUI.Theme.Surface
    Window.Header.BackgroundTransparency = 0.2
    Window.Header.BorderSizePixel = 0
    Window.Header.Parent = Window.MainFrame
    
    -- Only round top corners of header
    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 14)
    HeaderCorner.Parent = Window.Header
    
    -- Cover bottom rounded corners
    local HeaderBottom = Instance.new("Frame")
    HeaderBottom.Size = UDim2.new(1, 0, 0, 14)
    HeaderBottom.Position = UDim2.new(0, 0, 1, -14)
    HeaderBottom.BackgroundColor3 = FluentUI.Theme.Surface
    HeaderBottom.BackgroundTransparency = 0.2
    HeaderBottom.BorderSizePixel = 0
    HeaderBottom.Parent = Window.Header
    
    Window.Title = Instance.new("TextLabel")
    Window.Title.Name = "Title"
    Window.Title.Size = UDim2.new(0, 200, 1, 0)
    Window.Title.Position = UDim2.new(0, 15, 0, 0)
    Window.Title.BackgroundTransparency = 1
    Window.Title.Text = Config.Title or "Surfy TC2"
    Window.Title.TextColor3 = FluentUI.Theme.Text
    Window.Title.TextSize = 15
    Window.Title.Font = Enum.Font.GothamBold
    Window.Title.TextXAlignment = Enum.TextXAlignment.Left
    Window.Title.Parent = Window.Header
    
    Window.MinimizeButton = Instance.new("TextButton")
    Window.MinimizeButton.Name = "MinimizeButton"
    Window.MinimizeButton.Size = UDim2.new(0, 28, 0, 28)
    Window.MinimizeButton.Position = UDim2.new(1, -64, 0.5, -14)
    Window.MinimizeButton.BackgroundColor3 = FluentUI.Theme.SurfaceLight
    Window.MinimizeButton.BackgroundTransparency = 0.3
    Window.MinimizeButton.TextColor3 = FluentUI.Theme.Text
    Window.MinimizeButton.Text = "━"
    Window.MinimizeButton.TextSize = 14
    Window.MinimizeButton.Font = Enum.Font.GothamBold
    Window.MinimizeButton.Parent = Window.Header
    
    RoundCorners(Window.MinimizeButton, 6)
    
    Window.CloseButton = Instance.new("TextButton")
    Window.CloseButton.Name = "CloseButton"
    Window.CloseButton.Size = UDim2.new(0, 28, 0, 28)
    Window.CloseButton.Position = UDim2.new(1, -32, 0.5, -14)
    Window.CloseButton.BackgroundColor3 = FluentUI.Theme.Error
    Window.CloseButton.BackgroundTransparency = 0.3
    Window.CloseButton.TextColor3 = Color3.new(1, 1, 1)
    Window.CloseButton.Text = "×"
    Window.CloseButton.TextSize = 18
    Window.CloseButton.Font = Enum.Font.GothamBold
    Window.CloseButton.Parent = Window.Header
    
    RoundCorners(Window.CloseButton, 6)
    
    Window.MinimizeButton.MouseEnter:Connect(function()
        Tween(Window.MinimizeButton, {BackgroundTransparency = 0}, 0.2)
    end)
    Window.MinimizeButton.MouseLeave:Connect(function()
        Tween(Window.MinimizeButton, {BackgroundTransparency = 0.3}, 0.2)
    end)
    
    Window.CloseButton.MouseEnter:Connect(function()
        Tween(Window.CloseButton, {BackgroundTransparency = 0}, 0.2)
    end)
    Window.CloseButton.MouseLeave:Connect(function()
        Tween(Window.CloseButton, {BackgroundTransparency = 0.3}, 0.2)
    end)
    
    Window.TabContainer = Instance.new("Frame")
    Window.TabContainer.Name = "TabContainer"
    Window.TabContainer.Size = UDim2.new(0, 130, 1, -40)
    Window.TabContainer.Position = UDim2.new(0, 0, 0, 40)
    Window.TabContainer.BackgroundColor3 = FluentUI.Theme.Secondary
    Window.TabContainer.BackgroundTransparency = 0.2
    Window.TabContainer.BorderSizePixel = 0
    Window.TabContainer.Parent = Window.MainFrame
    
    Window.ContentContainer = Instance.new("Frame")
    Window.ContentContainer.Name = "ContentContainer"
    Window.ContentContainer.Size = UDim2.new(1, -130, 1, -40)
    Window.ContentContainer.Position = UDim2.new(0, 130, 0, 40)
    Window.ContentContainer.BackgroundColor3 = FluentUI.Theme.Background
    Window.ContentContainer.BackgroundTransparency = 0.2
    Window.ContentContainer.BorderSizePixel = 0
    Window.ContentContainer.ClipsDescendants = true
    Window.ContentContainer.Parent = Window.MainFrame
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 8)
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = Window.TabContainer
    
    local UIPadding = Instance.new("UIPadding")
    UIPadding.PaddingTop = UDim.new(0, 10)
    UIPadding.Parent = Window.TabContainer
    
    Window.CloseButton.MouseButton1Click:Connect(function()
        Window:Toggle()
    end)
    
    Window.MinimizeButton.MouseButton1Click:Connect(function()
        Window:ToggleMinimize()
    end)
    
    local dragging, dragInput, dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        Window.MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    Window.Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Window.MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    Window.Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
    
    function Window:Toggle()
        self.IsVisible = not self.IsVisible
        
        if self.IsVisible then
            self.MainFrame.Visible = true
            
            if self.SavedPosition then
                self.MainFrame.Position = self.SavedPosition
                self.MainFrame.Size = UDim2.new(0, 650, 0, 0)
                Tween(self.MainFrame, {Size = UDim2.new(0, 650, 0, 420)}, 0.4, Enum.EasingStyle.Back)
            else
                self.MainFrame.Size = UDim2.new(0, 650, 0, 0)
                self.MainFrame.Position = UDim2.new(0.5, -325, 0.5, 0)
                Tween(self.MainFrame, {
                    Size = UDim2.new(0, 650, 0, 420),
                    Position = UDim2.new(0.5, -325, 0.5, -210)
                }, 0.4, Enum.EasingStyle.Back)
            end
            
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            UserInputService.MouseIconEnabled = true
        else
            self.SavedPosition = self.MainFrame.Position
            
            Tween(self.MainFrame, {Size = UDim2.new(0, 650, 0, 0)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            
            task.delay(0.3, function()
                self.MainFrame.Visible = false
            end)
            
            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
            UserInputService.MouseIconEnabled = false
        end
    end
    
    function Window:ToggleMinimize()
        self.IsMinimized = not self.IsMinimized
        if self.IsMinimized then
            Tween(self.MainFrame, {Size = UDim2.new(0, 650, 0, 40)}, 0.3, Enum.EasingStyle.Quint)
            self.ContentContainer.Visible = false
            self.TabContainer.Visible = false
        else
            Tween(self.MainFrame, {Size = UDim2.new(0, 650, 0, 420)}, 0.3, Enum.EasingStyle.Quint)
            task.wait(0.15)
            self.ContentContainer.Visible = true
            self.TabContainer.Visible = true
        end
    end
    
    return Window
end

-- Tab Icons
local TabIcons = {
    Combat = "⚔",
    Visuals = "👁",
    Misc = "⚙",
    Settings = "🔧"
}

function FluentUI:CreateTab(Name)
    local Tab = {
        Name = Name,
        Sections = {}
    }
    
    local TabButton = Instance.new("TextButton")
    TabButton.Name = Name .. "Tab"
    TabButton.Size = UDim2.new(0.85, 0, 0, 45)
    TabButton.BackgroundColor3 = FluentUI.Theme.Surface
    TabButton.BackgroundTransparency = 0.4
    TabButton.TextColor3 = FluentUI.Theme.SubText
    TabButton.Text = (TabIcons[Name] or "•") .. "  " .. Name
    TabButton.TextSize = 13
    TabButton.Font = Enum.Font.GothamSemibold
    TabButton.Parent = self.TabContainer
    
    RoundCorners(TabButton, 8)
    
    TabButton.MouseEnter:Connect(function()
        if not Tab.IsActive then
            Tween(TabButton, {BackgroundTransparency = 0.2}, 0.2)
        end
    end)
    TabButton.MouseLeave:Connect(function()
        if not Tab.IsActive then
            Tween(TabButton, {BackgroundTransparency = 0.4}, 0.2)
        end
    end)
    
    local TabContent = Instance.new("ScrollingFrame")
    TabContent.Name = Name .. "Content"
    TabContent.Size = UDim2.new(1, 0, 1, 0)
    TabContent.BackgroundTransparency = 1
    TabContent.BorderSizePixel = 0
    TabContent.ScrollBarThickness = 3
    TabContent.ScrollBarImageColor3 = FluentUI.Theme.Primary
    TabContent.ScrollBarImageTransparency = 0.4
    TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabContent.Visible = false
    TabContent.Parent = self.ContentContainer
    
    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.Padding = UDim.new(0, 15)
    ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.Parent = TabContent
    
    local ContentPadding = Instance.new("UIPadding")
    ContentPadding.PaddingTop = UDim.new(0, 15)
    ContentPadding.PaddingBottom = UDim.new(0, 15)
    ContentPadding.Parent = TabContent
    
    ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 30)
    end)
    
    Tab.Button = TabButton
    Tab.Content = TabContent
    Tab.IsActive = false
    
    TabButton.MouseButton1Click:Connect(function()
        self:SwitchTab(Tab)
    end)
    
    table.insert(self.Tabs, Tab)
    
    if not self.CurrentTab then
        self:SwitchTab(Tab)
    end
    
    return Tab
end

function FluentUI:SwitchTab(Tab)
    if self.CurrentTab then
        self.CurrentTab.Content.Visible = false
        self.CurrentTab.IsActive = false
        Tween(self.CurrentTab.Button, {
            BackgroundColor3 = FluentUI.Theme.Surface, 
            BackgroundTransparency = 0.4,
            TextColor3 = FluentUI.Theme.SubText
        }, 0.2)
    end
    
    self.CurrentTab = Tab
    Tab.Content.Visible = true
    Tab.IsActive = true
    Tween(Tab.Button, {
        BackgroundColor3 = FluentUI.Theme.Primary, 
        BackgroundTransparency = 0,
        TextColor3 = FluentUI.Theme.Text
    }, 0.3, Enum.EasingStyle.Quint)
end

function FluentUI:CreateSection(Tab, Name)
    local Section = {
        Name = Name,
        ElementOrder = 0
    }
    
    local SectionContainer = Instance.new("Frame")
    SectionContainer.Name = Name .. "Container"
    SectionContainer.Size = UDim2.new(0.94, 0, 0, 0)
    SectionContainer.AutomaticSize = Enum.AutomaticSize.Y
    SectionContainer.BackgroundTransparency = 1
    SectionContainer.LayoutOrder = #Tab.Content:GetChildren()
    SectionContainer.Parent = Tab.Content
    
    local SectionTitle = Instance.new("TextLabel")
    SectionTitle.Name = "Title"
    SectionTitle.Size = UDim2.new(1, 0, 0, 25)
    SectionTitle.BackgroundTransparency = 1
    SectionTitle.Text = Name
    SectionTitle.TextColor3 = FluentUI.Theme.Text
    SectionTitle.TextSize = 14
    SectionTitle.Font = Enum.Font.GothamBold
    SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    SectionTitle.Parent = SectionContainer
    
    local SectionCard = Instance.new("Frame")
    SectionCard.Name = "Card"
    SectionCard.Size = UDim2.new(1, 0, 0, 0)
    SectionCard.Position = UDim2.new(0, 0, 0, 30)
    SectionCard.AutomaticSize = Enum.AutomaticSize.Y
    SectionCard.BackgroundColor3 = FluentUI.Theme.Surface
    SectionCard.BackgroundTransparency = 0.3
    SectionCard.Parent = SectionContainer
    
    RoundCorners(SectionCard, 12)
    
    local CardLayout = Instance.new("UIListLayout")
    CardLayout.Padding = UDim.new(0, 8)
    CardLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    CardLayout.SortOrder = Enum.SortOrder.LayoutOrder
    CardLayout.Parent = SectionCard
    
    local CardPadding = Instance.new("UIPadding")
    CardPadding.PaddingTop = UDim.new(0, 12)
    CardPadding.PaddingBottom = UDim.new(0, 12)
    CardPadding.PaddingLeft = UDim.new(0, 5)
    CardPadding.PaddingRight = UDim.new(0, 5)
    CardPadding.Parent = SectionCard
    
    Section.Frame = SectionCard
    
    return Section
end

-- Keybind System
function FluentUI:CreateKeybind(Section, Config)
    Config = Config or {}
    
    local Keybind = {
        Key = Config.Default or Enum.KeyCode.Unknown,
        Callback = Config.Callback,
        IsBinding = false
    }
    
    local KeybindFrame = Instance.new("Frame")
    KeybindFrame.Name = Config.Title .. "Keybind"
    KeybindFrame.Size = UDim2.new(1, -20, 0, 32)
    KeybindFrame.BackgroundTransparency = 1
    KeybindFrame.LayoutOrder = Config.LayoutOrder or Section.ElementOrder
    KeybindFrame.Parent = Section.Frame
    
    Section.ElementOrder = Section.ElementOrder + 1
    
    local KeybindLabel = Instance.new("TextLabel")
    KeybindLabel.Name = "Label"
    KeybindLabel.Size = UDim2.new(0.5, 0, 1, 0)
    KeybindLabel.Position = UDim2.new(0, 5, 0, 0)
    KeybindLabel.BackgroundTransparency = 1
    KeybindLabel.Text = Config.Title or "Keybind"
    KeybindLabel.TextColor3 = FluentUI.Theme.Text
    KeybindLabel.TextSize = 13
    KeybindLabel.Font = Enum.Font.Gotham
    KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
    KeybindLabel.TextYAlignment = Enum.TextYAlignment.Center
    KeybindLabel.Parent = KeybindFrame
    
    local function GetKeyName(key)
        if key == Enum.UserInputType.MouseButton1 then return "LMB"
        elseif key == Enum.UserInputType.MouseButton2 then return "RMB"
        elseif key == Enum.UserInputType.MouseButton3 then return "MMB"
        elseif key == Enum.KeyCode.Unknown then return "None"
        else return key.Name end
    end
    
    local KeybindButton = Instance.new("TextButton")
    KeybindButton.Name = "KeybindButton"
    KeybindButton.Size = UDim2.new(0, 80, 0, 24)
    KeybindButton.Position = UDim2.new(1, -83, 0.5, -12)
    KeybindButton.BackgroundColor3 = FluentUI.Theme.Secondary
    KeybindButton.Text = GetKeyName(Keybind.Key)
    KeybindButton.TextColor3 = FluentUI.Theme.Text
    KeybindButton.TextSize = 11
    KeybindButton.Font = Enum.Font.Gotham
    KeybindButton.Parent = KeybindFrame
    
    RoundCorners(KeybindButton, 6)
    
    local Connection
    KeybindButton.MouseButton1Click:Connect(function()
        Keybind.IsBinding = true
        KeybindButton.Text = "..."
        Tween(KeybindButton, {BackgroundColor3 = FluentUI.Theme.Primary}, 0.2)
        
        Connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if input.KeyCode ~= Enum.KeyCode.Unknown then
                Keybind.Key = input.KeyCode
                KeybindButton.Text = GetKeyName(input.KeyCode)
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 or 
                   input.UserInputType == Enum.UserInputType.MouseButton2 or
                   input.UserInputType == Enum.UserInputType.MouseButton3 then
                Keybind.Key = input.UserInputType
                KeybindButton.Text = GetKeyName(input.UserInputType)
            end
            
            Tween(KeybindButton, {BackgroundColor3 = FluentUI.Theme.Secondary}, 0.2)
            Keybind.IsBinding = false
            Connection:Disconnect()
        end)
    end)
    
    return Keybind
end

function FluentUI:CreateToggleWithKeybind(Section, Config)
    Config = Config or {}
    
    local ToggleKeybind = {
        Value = Config.Default or false,
        Key = Config.DefaultKey or Enum.KeyCode.Unknown,
        Callback = Config.Callback,
        KeybindCallback = Config.KeybindCallback,
        IsBinding = false
    }
    
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = Config.Title .. "ToggleKeybind"
    ToggleFrame.Size = UDim2.new(1, -20, 0, 32)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.LayoutOrder = Config.LayoutOrder or Section.ElementOrder
    ToggleFrame.Parent = Section.Frame
    
    Section.ElementOrder = Section.ElementOrder + 1
    
    local function GetKeyName(key)
        if key == Enum.UserInputType.MouseButton1 then return "LMB"
        elseif key == Enum.UserInputType.MouseButton2 then return "RMB"
        elseif key == Enum.UserInputType.MouseButton3 then return "MMB"
        elseif key == Enum.KeyCode.Unknown then return "None"
        else return key.Name end
    end
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Name = "Label"
    ToggleLabel.Size = UDim2.new(0, 200, 1, 0)
    ToggleLabel.Position = UDim2.new(0, 5, 0, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = Config.Title or "Toggle"
    ToggleLabel.TextColor3 = FluentUI.Theme.Text
    ToggleLabel.TextSize = 13
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.TextYAlignment = Enum.TextYAlignment.Center
    ToggleLabel.Parent = ToggleFrame
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "Toggle"
    ToggleButton.Size = UDim2.new(0, 46, 0, 24)
    ToggleButton.Position = UDim2.new(1, -115, 0.5, -12)
    ToggleButton.BackgroundColor3 = ToggleKeybind.Value and FluentUI.Theme.Success or FluentUI.Theme.Secondary
    ToggleButton.Text = ""
    ToggleButton.Parent = ToggleFrame
    
    RoundCorners(ToggleButton, 12)
    
    local ToggleKnob = Instance.new("Frame")
    ToggleKnob.Name = "Knob"
    ToggleKnob.Size = UDim2.new(0, 18, 0, 18)
    ToggleKnob.Position = ToggleKeybind.Value and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    ToggleKnob.BackgroundColor3 = Color3.new(1, 1, 1)
    ToggleKnob.Parent = ToggleButton
    
    RoundCorners(ToggleKnob, 9)
    
    -- Keybind Button (Right of Toggle)
    local KeybindButton = Instance.new("TextButton")
    KeybindButton.Name = "KeybindButton"
    KeybindButton.Size = UDim2.new(0, 60, 0, 24)
    KeybindButton.Position = UDim2.new(1, -63, 0.5, -12)
    KeybindButton.BackgroundColor3 = FluentUI.Theme.Secondary
    KeybindButton.Text = GetKeyName(ToggleKeybind.Key)
    KeybindButton.TextColor3 = FluentUI.Theme.Text
    KeybindButton.TextSize = 10
    KeybindButton.Font = Enum.Font.Gotham
    KeybindButton.Parent = ToggleFrame
    
    RoundCorners(KeybindButton, 6)
    
    local function ToggleValue()
        ToggleKeybind.Value = not ToggleKeybind.Value
        
        if ToggleKeybind.Value then
            Tween(ToggleButton, {BackgroundColor3 = FluentUI.Theme.Success}, 0.3)
            Tween(ToggleKnob, {Position = UDim2.new(1, -21, 0.5, -9)}, 0.3, Enum.EasingStyle.Quint)
        else
            Tween(ToggleButton, {BackgroundColor3 = FluentUI.Theme.Secondary}, 0.3)
            Tween(ToggleKnob, {Position = UDim2.new(0, 3, 0.5, -9)}, 0.3, Enum.EasingStyle.Quint)
        end
        
        if ToggleKeybind.Callback then
            ToggleKeybind.Callback(ToggleKeybind.Value)
        end
    end
    
    ToggleButton.MouseButton1Click:Connect(ToggleValue)
    
    local Connection
    KeybindButton.MouseButton1Click:Connect(function()
        ToggleKeybind.IsBinding = true
        KeybindButton.Text = "..."
        Tween(KeybindButton, {BackgroundColor3 = FluentUI.Theme.Primary}, 0.2)
        
        Connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if input.KeyCode ~= Enum.KeyCode.Unknown then
                ToggleKeybind.Key = input.KeyCode
                KeybindButton.Text = GetKeyName(input.KeyCode)
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 or
                   input.UserInputType == Enum.UserInputType.MouseButton2 or
                   input.UserInputType == Enum.UserInputType.MouseButton3 then
                ToggleKeybind.Key = input.UserInputType
                KeybindButton.Text = GetKeyName(input.UserInputType)
            end
            
            Tween(KeybindButton, {BackgroundColor3 = FluentUI.Theme.Secondary}, 0.2)
            ToggleKeybind.IsBinding = false
            Connection:Disconnect()
        end)
    end)
    
    -- Keybind activation (does NOT toggle, calls KeybindCallback instead)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not ToggleKeybind.IsBinding and not gameProcessed and ToggleKeybind.Value then
            if (input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode == ToggleKeybind.Key) or
               (input.UserInputType == ToggleKeybind.Key) then
                if ToggleKeybind.KeybindCallback then
                    ToggleKeybind.KeybindCallback()
                end
            end
        end
    end)
    
    return ToggleKeybind
end

function FluentUI:CreateToggle(Section, Config)
    Config = Config or {}
    
    local Toggle = {
        Value = Config.Default or false,
        Callback = Config.Callback
    }
    
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = Config.Title .. "Toggle"
    ToggleFrame.Size = UDim2.new(1, -20, 0, 32)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.LayoutOrder = Config.LayoutOrder or Section.ElementOrder
    ToggleFrame.Parent = Section.Frame
    
    Section.ElementOrder = Section.ElementOrder + 1
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Name = "Label"
    ToggleLabel.Size = UDim2.new(0.65, 0, 1, 0)
    ToggleLabel.Position = UDim2.new(0, 5, 0, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = Config.Title or "Toggle"
    ToggleLabel.TextColor3 = FluentUI.Theme.Text
    ToggleLabel.TextSize = 13
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.TextYAlignment = Enum.TextYAlignment.Center
    ToggleLabel.Parent = ToggleFrame
    
    -- Keybind hint
    if Config.KeybindHint then
        local KeybindHint = Instance.new("TextLabel")
        KeybindHint.Name = "KeybindHint"
        KeybindHint.Size = UDim2.new(1, -10, 0, 12)
        KeybindHint.Position = UDim2.new(0, 5, 1, 2)
        KeybindHint.BackgroundTransparency = 1
        KeybindHint.Text = "Key: " .. Config.KeybindHint
        KeybindHint.TextColor3 = FluentUI.Theme.SubText
        KeybindHint.TextSize = 10
        KeybindHint.Font = Enum.Font.Gotham
        KeybindHint.TextXAlignment = Enum.TextXAlignment.Left
        KeybindHint.TextTransparency = 0.5
        KeybindHint.Parent = ToggleFrame
        
        ToggleFrame.Size = UDim2.new(1, -20, 0, 44)
    end
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "Toggle"
    ToggleButton.Size = UDim2.new(0, 46, 0, 24)
    ToggleButton.Position = UDim2.new(1, -50, 0.5, -12)
    ToggleButton.BackgroundColor3 = Toggle.Value and FluentUI.Theme.Success or FluentUI.Theme.Secondary
    ToggleButton.Text = ""
    ToggleButton.Parent = ToggleFrame
    
    RoundCorners(ToggleButton, 12)
    
    local ToggleKnob = Instance.new("Frame")
    ToggleKnob.Name = "Knob"
    ToggleKnob.Size = UDim2.new(0, 18, 0, 18)
    ToggleKnob.Position = Toggle.Value and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    ToggleKnob.BackgroundColor3 = Color3.new(1, 1, 1)
    ToggleKnob.Parent = ToggleButton
    
    RoundCorners(ToggleKnob, 9)
    
    ToggleButton.MouseButton1Click:Connect(function()
        Toggle.Value = not Toggle.Value
        
        if Toggle.Value then
            Tween(ToggleButton, {BackgroundColor3 = FluentUI.Theme.Success}, 0.3)
            Tween(ToggleKnob, {Position = UDim2.new(1, -21, 0.5, -9)}, 0.3, Enum.EasingStyle.Quint)
        else
            Tween(ToggleButton, {BackgroundColor3 = FluentUI.Theme.Secondary}, 0.3)
            Tween(ToggleKnob, {Position = UDim2.new(0, 3, 0.5, -9)}, 0.3, Enum.EasingStyle.Quint)
        end
        
        if Toggle.Callback then
            Toggle.Callback(Toggle.Value)
        end
    end)
    
    return Toggle
end

function FluentUI:CreateSlider(Section, Config)
    Config = Config or {}
    
    local Slider = {
        Value = Config.Default or Config.Min or 0,
        Min = Config.Min or 0,
        Max = Config.Max or 100,
        Rounding = Config.Rounding or 0,
        Callback = Config.Callback,
        IsDragging = false
    }
    
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Name = Config.Title .. "Slider"
    SliderFrame.Size = UDim2.new(1, -20, 0, 50)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.LayoutOrder = Config.LayoutOrder or Section.ElementOrder
    SliderFrame.Parent = Section.Frame
    
    Section.ElementOrder = Section.ElementOrder + 1
    
    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Name = "Label"
    SliderLabel.Size = UDim2.new(1, 0, 0, 18)
    SliderLabel.Position = UDim2.new(0, 5, 0, 0)
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Text = Config.Title or "Slider"
    SliderLabel.TextColor3 = FluentUI.Theme.Text
    SliderLabel.TextSize = 13
    SliderLabel.Font = Enum.Font.Gotham
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    SliderLabel.Parent = SliderFrame
    
    local SliderValue = Instance.new("TextLabel")
    SliderValue.Name = "Value"
    SliderValue.Size = UDim2.new(0, 60, 0, 18)
    SliderValue.Position = UDim2.new(1, -65, 0, 0)
    SliderValue.BackgroundTransparency = 1
    SliderValue.Text = tostring(Slider.Value)
    SliderValue.TextColor3 = FluentUI.Theme.SubText
    SliderValue.TextSize = 13
    SliderValue.Font = Enum.Font.Gotham
    SliderValue.TextXAlignment = Enum.TextXAlignment.Right
    SliderValue.Parent = SliderFrame
    
    local SliderTrack = Instance.new("Frame")
    SliderTrack.Name = "Track"
    SliderTrack.Size = UDim2.new(1, -10, 0, 5)
    SliderTrack.Position = UDim2.new(0, 5, 1, -18)
    SliderTrack.BackgroundColor3 = FluentUI.Theme.Secondary
    SliderTrack.Parent = SliderFrame
    
    RoundCorners(SliderTrack, 2.5)
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Name = "Fill"
    SliderFill.Size = UDim2.new((Slider.Value - Slider.Min) / (Slider.Max - Slider.Min), 0, 1, 0)
    SliderFill.BackgroundColor3 = FluentUI.Theme.Primary
    SliderFill.Parent = SliderTrack
    
    RoundCorners(SliderFill, 2.5)
    
    local SliderButton = Instance.new("TextButton")
    SliderButton.Name = "Button"
    SliderButton.Size = UDim2.new(0, 14, 0, 14)
    SliderButton.Position = UDim2.new(SliderFill.Size.X.Scale, -7, 0.5, -7)
    SliderButton.BackgroundColor3 = Color3.new(1, 1, 1)
    SliderButton.Text = ""
    SliderButton.ZIndex = 2
    SliderButton.Parent = SliderTrack
    
    RoundCorners(SliderButton, 7)
    
    local RunService = game:GetService("RunService")
    
    -- Pulsing animation when dragging
    local pulseConnection
    
    local function UpdateSlider(Input)
        local RelativeX = (Input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X
        local Value = math.clamp(RelativeX, 0, 1)
        
        Slider.Value = math.floor((Slider.Min + (Slider.Max - Slider.Min) * Value) * (10 ^ Slider.Rounding)) / (10 ^ Slider.Rounding)
        SliderValue.Text = tostring(Slider.Value)
        
        Tween(SliderFill, {Size = UDim2.new(Value, 0, 1, 0)}, 0.1)
        Tween(SliderButton, {Position = UDim2.new(Value, -7, 0.5, -7)}, 0.1)
        
        if Slider.Callback then
            Slider.Callback(Slider.Value)
        end
    end
    
    SliderButton.MouseButton1Down:Connect(function()
        Slider.IsDragging = true
        
        -- Start pulsing animation
        pulseConnection = RunService.Heartbeat:Connect(function()
            if Slider.IsDragging then
                local pulse = math.abs(math.sin(tick() * 8))
                SliderFill.BackgroundColor3 = FluentUI.Theme.Primary:Lerp(FluentUI.Theme.PrimaryLight, pulse * 0.5)
            end
        end)
    end)
    
    UserInputService.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Slider.IsDragging = false
            if pulseConnection then
                pulseConnection:Disconnect()
                pulseConnection = nil
                SliderFill.BackgroundColor3 = FluentUI.Theme.Primary
            end
        end
    end)
    
    UserInputService.InputChanged:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement and Slider.IsDragging then
            UpdateSlider(Input)
        end
    end)
    
    return Slider
end

function FluentUI:CreateColorPicker(Section, Config)
    Config = Config or {}
    
    local ColorPicker = {
        Value = Config.Default or Color3.fromRGB(255, 255, 255),
        Callback = Config.Callback
    }
    
    local PickerFrame = Instance.new("Frame")
    PickerFrame.Name = Config.Title .. "ColorPicker"
    PickerFrame.Size = UDim2.new(1, -20, 0, 32)
    PickerFrame.BackgroundTransparency = 1
    PickerFrame.LayoutOrder = Config.LayoutOrder or Section.ElementOrder
    PickerFrame.Parent = Section.Frame
    
    Section.ElementOrder = Section.ElementOrder + 1
    
    local PickerLabel = Instance.new("TextLabel")
    PickerLabel.Name = "Label"
    PickerLabel.Size = UDim2.new(0.65, 0, 1, 0)
    PickerLabel.Position = UDim2.new(0, 5, 0, 0)
    PickerLabel.BackgroundTransparency = 1
    PickerLabel.Text = Config.Title or "Color"
    PickerLabel.TextColor3 = FluentUI.Theme.Text
    PickerLabel.TextSize = 13
    PickerLabel.Font = Enum.Font.Gotham
    PickerLabel.TextXAlignment = Enum.TextXAlignment.Left
    PickerLabel.TextYAlignment = Enum.TextYAlignment.Center
    PickerLabel.Parent = PickerFrame
    
    local ColorButton = Instance.new("TextButton")
    ColorButton.Name = "ColorButton"
    ColorButton.Size = UDim2.new(0, 55, 0, 24)
    ColorButton.Position = UDim2.new(1, -58, 0.5, -12)
    ColorButton.BackgroundColor3 = ColorPicker.Value
    ColorButton.Text = ""
    ColorButton.Parent = PickerFrame
    
    RoundCorners(ColorButton, 6)
    
    local colors = {
        Color3.fromRGB(255, 50, 50),
        Color3.fromRGB(255, 150, 50),
        Color3.fromRGB(255, 255, 50),
        Color3.fromRGB(50, 255, 50),
        Color3.fromRGB(50, 255, 255),
        Color3.fromRGB(50, 50, 255),
        Color3.fromRGB(255, 50, 255),
        Color3.fromRGB(255, 255, 255)
    }
    
    local currentIndex = 1
    for i, color in ipairs(colors) do
        if color == ColorPicker.Value then
            currentIndex = i
            break
        end
    end
    
    ColorButton.MouseButton1Click:Connect(function()
        currentIndex = (currentIndex % #colors) + 1
        ColorPicker.Value = colors[currentIndex]
        
        Tween(ColorButton, {BackgroundColor3 = ColorPicker.Value}, 0.3)
        
        if ColorPicker.Callback then
            ColorPicker.Callback(ColorPicker.Value)
        end
    end)
    
    return ColorPicker
end

function FluentUI:CreateDropdown(Section, Config)
    Config = Config or {}
    
    local Dropdown = {
        Value = Config.Default or Config.Options[1],
        Options = Config.Options or {"Option 1"},
        Callback = Config.Callback,
        IsOpen = false
    }
    
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Name = Config.Title .. "Dropdown"
    DropdownFrame.Size = UDim2.new(1, -20, 0, 32)
    DropdownFrame.BackgroundTransparency = 1
    DropdownFrame.LayoutOrder = Config.LayoutOrder or Section.ElementOrder
    DropdownFrame.Parent = Section.Frame
    DropdownFrame.ClipsDescendants = false
    DropdownFrame.ZIndex = 10
    
    Section.ElementOrder = Section.ElementOrder + 1
    
    local DropdownLabel = Instance.new("TextLabel")
    DropdownLabel.Name = "Label"
    DropdownLabel.Size = UDim2.new(0.4, 0, 1, 0)
    DropdownLabel.Position = UDim2.new(0, 5, 0, 0)
    DropdownLabel.BackgroundTransparency = 1
    DropdownLabel.Text = Config.Title or "Dropdown"
    DropdownLabel.TextColor3 = FluentUI.Theme.Text
    DropdownLabel.TextSize = 13
    DropdownLabel.Font = Enum.Font.Gotham
    DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
    DropdownLabel.TextYAlignment = Enum.TextYAlignment.Center
    DropdownLabel.Parent = DropdownFrame
    
    local DropdownButton = Instance.new("TextButton")
    DropdownButton.Name = "Button"
    DropdownButton.Size = UDim2.new(0, 120, 0, 24)
    DropdownButton.Position = UDim2.new(1, -123, 0.5, -12)
    DropdownButton.BackgroundColor3 = FluentUI.Theme.Secondary
    DropdownButton.Text = "  " .. Dropdown.Value
    DropdownButton.TextColor3 = FluentUI.Theme.Text
    DropdownButton.TextSize = 12
    DropdownButton.Font = Enum.Font.Gotham
    DropdownButton.TextXAlignment = Enum.TextXAlignment.Left
    DropdownButton.Parent = DropdownFrame
    
    RoundCorners(DropdownButton, 6)
    
    local Arrow = Instance.new("TextLabel")
    Arrow.Name = "Arrow"
    Arrow.Size = UDim2.new(0, 20, 1, 0)
    Arrow.Position = UDim2.new(1, -20, 0, 0)
    Arrow.BackgroundTransparency = 1
    Arrow.Text = "▼"
    Arrow.TextColor3 = FluentUI.Theme.SubText
    Arrow.TextSize = 10
    Arrow.Font = Enum.Font.Gotham
    Arrow.Parent = DropdownButton
    
    local OptionsContainer = Instance.new("Frame")
    OptionsContainer.Name = "Options"
    OptionsContainer.Size = UDim2.new(0, 120, 0, 0)
    OptionsContainer.Position = UDim2.new(1, -123, 1, 4)
    OptionsContainer.BackgroundColor3 = FluentUI.Theme.Surface
    OptionsContainer.BorderSizePixel = 0
    OptionsContainer.Visible = false
    OptionsContainer.ZIndex = 15
    OptionsContainer.Parent = DropdownFrame
    
    RoundCorners(OptionsContainer, 6)
    
    local OptionsLayout = Instance.new("UIListLayout")
    OptionsLayout.Padding = UDim.new(0, 2)
    OptionsLayout.Parent = OptionsContainer
    
    local OptionsPadding = Instance.new("UIPadding")
    OptionsPadding.PaddingTop = UDim.new(0, 4)
    OptionsPadding.PaddingBottom = UDim.new(0, 4)
    OptionsPadding.Parent = OptionsContainer
    
    for _, option in ipairs(Dropdown.Options) do
        local OptionButton = Instance.new("TextButton")
        OptionButton.Name = option
        OptionButton.Size = UDim2.new(1, 0, 0, 24)
        OptionButton.BackgroundColor3 = FluentUI.Theme.SurfaceLight
        OptionButton.BackgroundTransparency = option == Dropdown.Value and 0 or 0.5
        OptionButton.Text = "  " .. option
        OptionButton.TextColor3 = FluentUI.Theme.Text
        OptionButton.TextSize = 11
        OptionButton.Font = Enum.Font.Gotham
        OptionButton.TextXAlignment = Enum.TextXAlignment.Left
        OptionButton.ZIndex = 16
        OptionButton.Parent = OptionsContainer
        
        OptionButton.MouseButton1Click:Connect(function()
            Dropdown.Value = option
            DropdownButton.Text = "  " .. option
            
            for _, btn in ipairs(OptionsContainer:GetChildren()) do
                if btn:IsA("TextButton") then
                    Tween(btn, {BackgroundTransparency = btn.Name == option and 0 or 0.5}, 0.2)
                end
            end
            
            Dropdown.IsOpen = false
            Tween(OptionsContainer, {Size = UDim2.new(0, 120, 0, 0)}, 0.2)
            Tween(Arrow, {Rotation = 0}, 0.2)
            task.wait(0.2)
            OptionsContainer.Visible = false
            
            if Dropdown.Callback then
                Dropdown.Callback(option)
            end
        end)
    end
    
    DropdownButton.MouseButton1Click:Connect(function()
        Dropdown.IsOpen = not Dropdown.IsOpen
        
        if Dropdown.IsOpen then
            OptionsContainer.Visible = true
            OptionsContainer.Size = UDim2.new(0, 120, 0, 0)
            local targetHeight = #Dropdown.Options * 26 + 8
            Tween(OptionsContainer, {Size = UDim2.new(0, 120, 0, targetHeight)}, 0.3, Enum.EasingStyle.Back)
            Tween(Arrow, {Rotation = 180}, 0.2)
        else
            Tween(OptionsContainer, {Size = UDim2.new(0, 120, 0, 0)}, 0.2)
            Tween(Arrow, {Rotation = 0}, 0.2)
            task.wait(0.2)
            OptionsContainer.Visible = false
        end
    end)
    
    return Dropdown
end

return FluentUI
