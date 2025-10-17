-- Surfy TC2 Library - Enhanced Visual Design
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Surfy UI Library
local SurfyUI = {}
SurfyUI.__index = SurfyUI

-- Aqua Color Theme
SurfyUI.Theme = {
    Primary = Color3.fromRGB(0, 180, 255),
    PrimaryLight = Color3.fromRGB(100, 220, 255),
    PrimaryDark = Color3.fromRGB(0, 140, 200),
    Secondary = Color3.fromRGB(25, 35, 45),
    Background = Color3.fromRGB(15, 20, 30),
    Surface = Color3.fromRGB(30, 40, 50),
    SurfaceLight = Color3.fromRGB(45, 55, 70),
    Text = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(160, 180, 200),
    Success = Color3.fromRGB(0, 200, 100),
    Error = Color3.fromRGB(255, 80, 80),
    Warning = Color3.fromRGB(255, 170, 0)
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

local function AddStroke(Object, Color, Thickness, Transparency)
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color or SurfyUI.Theme.Primary
    Stroke.Thickness = Thickness or 1
    Stroke.Transparency = Transparency or 0.7
    Stroke.Parent = Object
    return Stroke
end

local function AddGradient(Object, ColorStart, ColorEnd, Rotation)
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, ColorStart),
        ColorSequenceKeypoint.new(1, ColorEnd)
    }
    Gradient.Rotation = Rotation or 90
    Gradient.Parent = Object
    return Gradient
end

-- Notification System
SurfyUI.NotificationQueue = {}

function SurfyUI:CreateNotification(Config)
    Config = Config or {}
    
    local NotifContainer = self.NotificationContainer
    
    local Notification = Instance.new("Frame")
    Notification.Name = "Notification"
    Notification.Size = UDim2.new(0, 350, 0, 80)
    Notification.Position = UDim2.new(1, 370, 1, -100 - (#self.NotificationQueue * 90))
    Notification.BackgroundColor3 = SurfyUI.Theme.Surface
    Notification.BackgroundTransparency = 0.15
    Notification.BorderSizePixel = 0
    Notification.Parent = NotifContainer
    
    RoundCorners(Notification, 12)
    
    -- Modern gradient overlay
    local GradientOverlay = Instance.new("Frame")
    GradientOverlay.Name = "Gradient"
    GradientOverlay.Size = UDim2.new(1, 0, 1, 0)
    GradientOverlay.BackgroundTransparency = 0.5
    GradientOverlay.BorderSizePixel = 0
    GradientOverlay.Parent = Notification
    
    RoundCorners(GradientOverlay, 12)
    AddGradient(GradientOverlay, SurfyUI.Theme.Primary, SurfyUI.Theme.Background, 135)
    
    -- Top accent line
    local TopAccent = Instance.new("Frame")
    TopAccent.Name = "TopAccent"
    TopAccent.Size = UDim2.new(1, 0, 0, 3)
    TopAccent.BackgroundColor3 = SurfyUI.Theme.Primary
    TopAccent.BorderSizePixel = 0
    TopAccent.Parent = Notification
    
    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 12)
    TopCorner.Parent = TopAccent
    
    -- Cover bottom of accent
    local AccentCover = Instance.new("Frame")
    AccentCover.Size = UDim2.new(1, 0, 0, 3)
    AccentCover.Position = UDim2.new(0, 0, 1, -3)
    AccentCover.BackgroundColor3 = SurfyUI.Theme.Primary
    AccentCover.BorderSizePixel = 0
    AccentCover.Parent = TopAccent
    
    -- Icon/Status indicator
    local StatusIcon = Instance.new("Frame")
    StatusIcon.Name = "Icon"
    StatusIcon.Size = UDim2.new(0, 8, 0, 8)
    StatusIcon.Position = UDim2.new(0, 15, 0, 18)
    StatusIcon.BackgroundColor3 = SurfyUI.Theme.Success
    StatusIcon.BorderSizePixel = 0
    StatusIcon.Parent = Notification
    
    RoundCorners(StatusIcon, 4)
    
    -- Pulse animation for icon
    task.spawn(function()
        while Notification.Parent do
            Tween(StatusIcon, {BackgroundTransparency = 0.5}, 0.8)
            task.wait(0.8)
            if not Notification.Parent then break end
            Tween(StatusIcon, {BackgroundTransparency = 0}, 0.8)
            task.wait(0.8)
        end
    end)
    
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -40, 0, 22)
    Title.Position = UDim2.new(0, 30, 0, 12)
    Title.BackgroundTransparency = 1
    Title.Text = Config.Title or "Notification"
    Title.TextColor3 = SurfyUI.Theme.Text
    Title.TextSize = 14
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextYAlignment = Enum.TextYAlignment.Top
    Title.Parent = Notification
    
    local Description = Instance.new("TextLabel")
    Description.Name = "Description"
    Description.Size = UDim2.new(1, -40, 0, 40)
    Description.Position = UDim2.new(0, 30, 0, 35)
    Description.BackgroundTransparency = 1
    Description.Text = Config.Description or ""
    Description.TextColor3 = SurfyUI.Theme.SubText
    Description.TextSize = 12
    Description.Font = Enum.Font.Gotham
    Description.TextXAlignment = Enum.TextXAlignment.Left
    Description.TextYAlignment = Enum.TextYAlignment.Top
    Description.TextWrapped = true
    Description.Parent = Notification
    
    -- Close button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "Close"
    CloseBtn.Size = UDim2.new(0, 20, 0, 20)
    CloseBtn.Position = UDim2.new(1, -28, 0, 8)
    CloseBtn.BackgroundColor3 = SurfyUI.Theme.Error
    CloseBtn.BackgroundTransparency = 0.7
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = SurfyUI.Theme.Text
    CloseBtn.TextSize = 16
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Parent = Notification
    
    RoundCorners(CloseBtn, 10)
    
    CloseBtn.MouseEnter:Connect(function()
        Tween(CloseBtn, {BackgroundTransparency = 0.3}, 0.2)
    end)
    
    CloseBtn.MouseLeave:Connect(function()
        Tween(CloseBtn, {BackgroundTransparency = 0.7}, 0.2)
    end)
    
    table.insert(self.NotificationQueue, Notification)
    
    Tween(Notification, {Position = UDim2.new(1, -360, 1, -100 - ((#self.NotificationQueue - 1) * 90))}, 0.5, Enum.EasingStyle.Back)
    
    local function RemoveNotification()
        Tween(Notification, {Position = UDim2.new(1, 370, 1, Notification.Position.Y.Offset)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.4)
        
        for i, notif in ipairs(self.NotificationQueue) do
            if notif == Notification then
                table.remove(self.NotificationQueue, i)
                break
            end
        end
        
        Notification:Destroy()
        
        for i, notif in ipairs(self.NotificationQueue) do
            Tween(notif, {Position = UDim2.new(1, -360, 1, -100 - ((i - 1) * 90))}, 0.3)
        end
    end
    
    CloseBtn.MouseButton1Click:Connect(RemoveNotification)
    
    task.delay(Config.Duration or 4, RemoveNotification)
end

-- Create Window
function SurfyUI:CreateWindow(Config)
    Config = Config or {}
    
    local Window = {
        Tabs = {},
        CurrentTab = nil,
        IsMinimized = false,
        IsVisible = false,
        SavedPosition = nil
    }
    setmetatable(Window, SurfyUI)
    
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    Window.ScreenGui = Instance.new("ScreenGui")
    Window.ScreenGui.Name = "SurfyUI"
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
    Window.MainFrame.Size = UDim2.new(0, 700, 0, 450)
    Window.MainFrame.Position = UDim2.new(0.5, -350, 0.5, -225)
    Window.MainFrame.BackgroundColor3 = SurfyUI.Theme.Background
    Window.MainFrame.BackgroundTransparency = 0.1
    Window.MainFrame.BorderSizePixel = 0
    Window.MainFrame.Visible = false
    Window.MainFrame.ClipsDescendants = true
    Window.MainFrame.Parent = Window.ScreenGui
    
    RoundCorners(Window.MainFrame, 16)
    AddStroke(Window.MainFrame, SurfyUI.Theme.Primary, 2, 0.6)
    
    -- Enhanced glow effect
    local Glow = Instance.new("ImageLabel")
    Glow.Name = "Glow"
    Glow.BackgroundTransparency = 1
    Glow.Position = UDim2.new(0, -30, 0, -30)
    Glow.Size = UDim2.new(1, 60, 1, 60)
    Glow.ZIndex = 0
    Glow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    Glow.ImageColor3 = SurfyUI.Theme.Primary
    Glow.ImageTransparency = 0.7
    Glow.ScaleType = Enum.ScaleType.Slice
    Glow.SliceCenter = Rect.new(10, 10, 10, 10)
    Glow.Parent = Window.MainFrame
    
    -- Animated Background
    local AnimatedBG = Instance.new("Frame")
    AnimatedBG.Name = "AnimatedBackground"
    AnimatedBG.Size = UDim2.new(1, 0, 1, 0)
    AnimatedBG.BackgroundTransparency = 0.97
    AnimatedBG.BorderSizePixel = 0
    AnimatedBG.ZIndex = 0
    AnimatedBG.Parent = Window.MainFrame
    
    local BGGradient = Instance.new("UIGradient")
    BGGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, SurfyUI.Theme.Primary),
        ColorSequenceKeypoint.new(0.5, SurfyUI.Theme.PrimaryLight),
        ColorSequenceKeypoint.new(1, SurfyUI.Theme.Primary)
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
    Window.Header.Size = UDim2.new(1, 0, 0, 50)
    Window.Header.BackgroundColor3 = SurfyUI.Theme.Surface
    Window.Header.BackgroundTransparency = 0.3
    Window.Header.BorderSizePixel = 0
    Window.Header.Parent = Window.MainFrame
    
    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 16)
    HeaderCorner.Parent = Window.Header
    
    local HeaderBottom = Instance.new("Frame")
    HeaderBottom.Size = UDim2.new(1, 0, 0, 16)
    HeaderBottom.Position = UDim2.new(0, 0, 1, -16)
    HeaderBottom.BackgroundColor3 = SurfyUI.Theme.Surface
    HeaderBottom.BackgroundTransparency = 0.3
    HeaderBottom.BorderSizePixel = 0
    HeaderBottom.Parent = Window.Header
    
    Window.Title = Instance.new("TextLabel")
    Window.Title.Name = "Title"
    Window.Title.Size = UDim2.new(0, 200, 1, 0)
    Window.Title.Position = UDim2.new(0, 20, 0, 0)
    Window.Title.BackgroundTransparency = 1
    Window.Title.Text = Config.Title or "Surfy TC2"
    Window.Title.TextColor3 = SurfyUI.Theme.Text
    Window.Title.TextSize = 16
    Window.Title.Font = Enum.Font.GothamBold
    Window.Title.TextXAlignment = Enum.TextXAlignment.Left
    Window.Title.Parent = Window.Header
    
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Name = "Subtitle"
    Subtitle.Size = UDim2.new(0, 200, 0, 15)
    Subtitle.Position = UDim2.new(0, 20, 0, 28)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = "Premium UI Library"
    Subtitle.TextColor3 = SurfyUI.Theme.SubText
    Subtitle.TextSize = 11
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left
    Subtitle.Parent = Window.Header
    
    Window.MinimizeButton = Instance.new("TextButton")
    Window.MinimizeButton.Name = "MinimizeButton"
    Window.MinimizeButton.Size = UDim2.new(0, 32, 0, 32)
    Window.MinimizeButton.Position = UDim2.new(1, -80, 0.5, -16)
    Window.MinimizeButton.BackgroundColor3 = SurfyUI.Theme.SurfaceLight
    Window.MinimizeButton.BackgroundTransparency = 0.4
    Window.MinimizeButton.TextColor3 = SurfyUI.Theme.Text
    Window.MinimizeButton.Text = "━"
    Window.MinimizeButton.TextSize = 16
    Window.MinimizeButton.Font = Enum.Font.GothamBold
    Window.MinimizeButton.Parent = Window.Header
    
    RoundCorners(Window.MinimizeButton, 8)
    
    Window.CloseButton = Instance.new("TextButton")
    Window.CloseButton.Name = "CloseButton"
    Window.CloseButton.Size = UDim2.new(0, 32, 0, 32)
    Window.CloseButton.Position = UDim2.new(1, -44, 0.5, -16)
    Window.CloseButton.BackgroundColor3 = SurfyUI.Theme.Error
    Window.CloseButton.BackgroundTransparency = 0.4
    Window.CloseButton.TextColor3 = Color3.new(1, 1, 1)
    Window.CloseButton.Text = "×"
    Window.CloseButton.TextSize = 20
    Window.CloseButton.Font = Enum.Font.GothamBold
    Window.CloseButton.Parent = Window.Header
    
    RoundCorners(Window.CloseButton, 8)
    
    Window.MinimizeButton.MouseEnter:Connect(function()
        Tween(Window.MinimizeButton, {BackgroundTransparency = 0.1}, 0.2)
    end)
    Window.MinimizeButton.MouseLeave:Connect(function()
        Tween(Window.MinimizeButton, {BackgroundTransparency = 0.4}, 0.2)
    end)
    
    Window.CloseButton.MouseEnter:Connect(function()
        Tween(Window.CloseButton, {BackgroundTransparency = 0.1}, 0.2)
    end)
    Window.CloseButton.MouseLeave:Connect(function()
        Tween(Window.CloseButton, {BackgroundTransparency = 0.4}, 0.2)
    end)
    
    Window.TabContainer = Instance.new("Frame")
    Window.TabContainer.Name = "TabContainer"
    Window.TabContainer.Size = UDim2.new(0, 150, 1, -50)
    Window.TabContainer.Position = UDim2.new(0, 0, 0, 50)
    Window.TabContainer.BackgroundColor3 = SurfyUI.Theme.Secondary
    Window.TabContainer.BackgroundTransparency = 0.3
    Window.TabContainer.BorderSizePixel = 0
    Window.TabContainer.ClipsDescendants = true
    Window.TabContainer.Parent = Window.MainFrame
    
    Window.ContentContainer = Instance.new("Frame")
    Window.ContentContainer.Name = "ContentContainer"
    Window.ContentContainer.Size = UDim2.new(1, -150, 1, -50)
    Window.ContentContainer.Position = UDim2.new(0, 150, 0, 50)
    Window.ContentContainer.BackgroundColor3 = SurfyUI.Theme.Background
    Window.ContentContainer.BackgroundTransparency = 0.3
    Window.ContentContainer.BorderSizePixel = 0
    Window.ContentContainer.ClipsDescendants = true
    Window.ContentContainer.Parent = Window.MainFrame
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 10)
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = Window.TabContainer
    
    local UIPadding = Instance.new("UIPadding")
    UIPadding.PaddingTop = UDim.new(0, 15)
    UIPadding.PaddingBottom = UDim.new(0, 15)
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
                self.MainFrame.Size = UDim2.new(0, 700, 0, 0)
                Tween(self.MainFrame, {Size = UDim2.new(0, 700, 0, 450)}, 0.4, Enum.EasingStyle.Back)
            else
                self.MainFrame.Size = UDim2.new(0, 700, 0, 0)
                self.MainFrame.Position = UDim2.new(0.5, -350, 0.5, 0)
                Tween(self.MainFrame, {
                    Size = UDim2.new(0, 700, 0, 450),
                    Position = UDim2.new(0.5, -350, 0.5, -225)
                }, 0.4, Enum.EasingStyle.Back)
            end
            
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            UserInputService.MouseIconEnabled = true
        else
            self.SavedPosition = self.MainFrame.Position
            
            Tween(self.MainFrame, {Size = UDim2.new(0, 700, 0, 0)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            
            task.delay(0.3, function()
                self.MainFrame.Visible = false
            end)
            
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            UserInputService.MouseIconEnabled = true
        end
    end
    
    function Window:ToggleMinimize()
        self.IsMinimized = not self.IsMinimized
        if self.IsMinimized then
            Tween(self.MainFrame, {Size = UDim2.new(0, 700, 0, 50)}, 0.3, Enum.EasingStyle.Quint)
            self.ContentContainer.Visible = false
            self.TabContainer.Visible = false
        else
            Tween(self.MainFrame, {Size = UDim2.new(0, 700, 0, 450)}, 0.3, Enum.EasingStyle.Quint)
            task.wait(0.15)
            self.ContentContainer.Visible = true
            self.TabContainer.Visible = true
        end
    end
    
    return Window
end

function SurfyUI:CreateTab(Name)
    local Tab = {
        Name = Name,
        Sections = {}
    }
    
    local TabButton = Instance.new("TextButton")
    TabButton.Name = Name .. "Tab"
    TabButton.Size = UDim2.new(0.88, 0, 0, 48)
    TabButton.BackgroundColor3 = SurfyUI.Theme.Surface
    TabButton.BackgroundTransparency = 0.5
    TabButton.TextColor3 = SurfyUI.Theme.SubText
    TabButton.Text = Name
    TabButton.TextSize = 14
    TabButton.Font = Enum.Font.GothamSemibold
    TabButton.Parent = self.TabContainer
    
    RoundCorners(TabButton, 10)
    
    local TabAccent = Instance.new("Frame")
    TabAccent.Name = "Accent"
    TabAccent.Size = UDim2.new(0, 3, 0.7, 0)
    TabAccent.Position = UDim2.new(0, 0, 0.15, 0)
    TabAccent.BackgroundColor3 = SurfyUI.Theme.Primary
    TabAccent.BackgroundTransparency = 1
    TabAccent.BorderSizePixel = 0
    TabAccent.Parent = TabButton
    
    local AccentCorner = Instance.new("UICorner")
    AccentCorner.CornerRadius = UDim.new(0, 3)
    AccentCorner.Parent = TabAccent
    
    TabButton.MouseEnter:Connect(function()
        if not Tab.IsActive then
            Tween(TabButton, {BackgroundTransparency = 0.3}, 0.2)
        end
    end)
    TabButton.MouseLeave:Connect(function()
        if not Tab.IsActive then
            Tween(TabButton, {BackgroundTransparency = 0.5}, 0.2)
        end
    end)
    
    local TabContent = Instance.new("ScrollingFrame")
    TabContent.Name = Name .. "Content"
    TabContent.Size = UDim2.new(1, 0, 1, 0)
    TabContent.BackgroundTransparency = 1
    TabContent.BorderSizePixel = 0
    TabContent.ScrollBarThickness = 4
    TabContent.ScrollBarImageColor3 = SurfyUI.Theme.Primary
    TabContent.ScrollBarImageTransparency = 0.5
    TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabContent.Visible = false
    TabContent.Parent = self.ContentContainer
    
    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.Padding = UDim.new(0, 18)
    ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.Parent = TabContent
    
    local ContentPadding = Instance.new("UIPadding")
    ContentPadding.PaddingTop = UDim.new(0, 20)
    ContentPadding.PaddingBottom = UDim.new(0, 20)
    ContentPadding.Parent = TabContent
    
    ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 40)
    end)
    
    Tab.Button = TabButton
    Tab.Content = TabContent
    Tab.Accent = TabAccent
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

function SurfyUI:SwitchTab(Tab)
    if self.CurrentTab then
        self.CurrentTab.Content.Visible = false
        self.CurrentTab.IsActive = false
        Tween(self.CurrentTab.Button, {
            BackgroundColor3 = SurfyUI.Theme.Surface, 
            BackgroundTransparency = 0.5,
            TextColor3 = SurfyUI.Theme.SubText
        }, 0.2)
        Tween(self.CurrentTab.Accent, {BackgroundTransparency = 1}, 0.2)
    end
    
    self.CurrentTab = Tab
    Tab.Content.Visible = true
    Tab.IsActive = true
    Tween(Tab.Button, {
        BackgroundColor3 = SurfyUI.Theme.Primary, 
        BackgroundTransparency = 0.2,
        TextColor3 = SurfyUI.Theme.Text
    }, 0.3, Enum.EasingStyle.Quint)
    Tween(Tab.Accent, {BackgroundTransparency = 0}, 0.3)
end

function SurfyUI:CreateSection(Tab, Name)
    local Section = {
        Name = Name,
        ElementOrder = 0
    }
    
    local SectionContainer = Instance.new("Frame")
    SectionContainer.Name = Name .. "Container"
    SectionContainer.Size = UDim2.new(0.95, 0, 0, 0)
    SectionContainer.AutomaticSize = Enum.AutomaticSize.Y
    SectionContainer.BackgroundTransparency = 1
    SectionContainer.LayoutOrder = #Tab.Content:GetChildren()
    SectionContainer.Parent = Tab.Content
    
    local SectionTitle = Instance.new("TextLabel")
    SectionTitle.Name = "Title"
    SectionTitle.Size = UDim2.new(1, 0, 0, 28)
    SectionTitle.BackgroundTransparency = 1
    SectionTitle.Text = Name
    SectionTitle.TextColor3 = SurfyUI.Theme.Text
    SectionTitle.TextSize = 15
    SectionTitle.Font = Enum.Font.GothamBold
    SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    SectionTitle.Parent = SectionContainer
    
    local SectionCard = Instance.new("Frame")
    SectionCard.Name = "Card"
    SectionCard.Size = UDim2.new(1, 0, 0, 0)
    SectionCard.Position = UDim2.new(0, 0, 0, 32)
    SectionCard.AutomaticSize = Enum.AutomaticSize.Y
    SectionCard.BackgroundColor3 = SurfyUI.Theme.Surface
    SectionCard.BackgroundTransparency = 0.4
    SectionCard.Parent = SectionContainer
    
    RoundCorners(SectionCard, 14)
    AddStroke(SectionCard, SurfyUI.Theme.Primary, 1, 0.8)
    
    local CardLayout = Instance.new("UIListLayout")
    CardLayout.Padding = UDim.new(0, 10)
    CardLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    CardLayout.SortOrder = Enum.SortOrder.LayoutOrder
    CardLayout.Parent = SectionCard
    
    local CardPadding = Instance.new("UIPadding")
    CardPadding.PaddingTop = UDim.new(0, 14)
    CardPadding.PaddingBottom = UDim.new(0, 14)
    CardPadding.PaddingLeft = UDim.new(0, 8)
    CardPadding.PaddingRight = UDim.new(0, 8)
    CardPadding.Parent = SectionCard
    
    Section.Frame = SectionCard
    
    return Section
end

-- Keybind System
function SurfyUI:CreateKeybind(Section, Config)
    Config = Config or {}
    
    local Keybind = {
        Key = Config.Default or Enum.KeyCode.Unknown,
        Callback = Config.Callback,
        IsBinding = false
    }
    
    -- Element Card
    local ElementCard = Instance.new("Frame")
    ElementCard.Name = Config.Title .. "Card"
    ElementCard.Size = UDim2.new(1, -16, 0, 40)
    ElementCard.BackgroundColor3 = SurfyUI.Theme.SurfaceLight
    ElementCard.BackgroundTransparency = 0.5
    ElementCard.LayoutOrder = Config.LayoutOrder or Section.ElementOrder
    ElementCard.Parent = Section.Frame
    
    RoundCorners(ElementCard, 10)
    
    Section.ElementOrder = Section.ElementOrder + 1
    
    local KeybindLabel = Instance.new("TextLabel")
    KeybindLabel.Name = "Label"
    KeybindLabel.Size = UDim2.new(0.5, 0, 1, 0)
    KeybindLabel.Position = UDim2.new(0, 12, 0, 0)
    KeybindLabel.BackgroundTransparency = 1
    KeybindLabel.Text = Config.Title or "Keybind"
    KeybindLabel.TextColor3 = SurfyUI.Theme.Text
    KeybindLabel.TextSize = 13
    KeybindLabel.Font = Enum.Font.GothamMedium
    KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
    KeybindLabel.TextYAlignment = Enum.TextYAlignment.Center
    KeybindLabel.Parent = ElementCard
    
    local function GetKeyName(key)
        if key == Enum.UserInputType.MouseButton1 then return "LMB"
        elseif key == Enum.UserInputType.MouseButton2 then return "RMB"
        elseif key == Enum.UserInputType.MouseButton3 then return "MMB"
        elseif key == Enum.KeyCode.Unknown then return "None"
        else return key.Name end
    end
    
    local KeybindButton = Instance.new("TextButton")
    KeybindButton.Name = "KeybindButton"
    KeybindButton.Size = UDim2.new(0, 75, 0, 28)
    KeybindButton.Position = UDim2.new(1, -82, 0.5, -14)
    KeybindButton.BackgroundColor3 = SurfyUI.Theme.Secondary
    KeybindButton.BackgroundTransparency = 0.3
    KeybindButton.Text = GetKeyName(Keybind.Key)
    KeybindButton.TextColor3 = SurfyUI.Theme.Text
    KeybindButton.TextSize = 12
    KeybindButton.Font = Enum.Font.GothamMedium
    KeybindButton.Parent = ElementCard
    
    RoundCorners(KeybindButton, 8)
    
    local Connection
    KeybindButton.MouseButton1Click:Connect(function()
        Keybind.IsBinding = true
        KeybindButton.Text = "..."
        Tween(KeybindButton, {BackgroundColor3 = SurfyUI.Theme.Primary, BackgroundTransparency = 0.1}, 0.2)
        
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
            
            Tween(KeybindButton, {BackgroundColor3 = SurfyUI.Theme.Secondary, BackgroundTransparency = 0.3}, 0.2)
            Keybind.IsBinding = false
            Connection:Disconnect()
        end)
    end)
    
    return Keybind
end

function SurfyUI:CreateToggleWithKeybind(Section, Config)
    Config = Config or {}
    
    local ToggleKeybind = {
        Value = Config.Default or false,
        Key = Config.DefaultKey or Enum.KeyCode.Unknown,
        Callback = Config.Callback,
        KeybindCallback = Config.KeybindCallback,
        IsBinding = false
    }
    
    -- Element Card
    local ElementCard = Instance.new("Frame")
    ElementCard.Name = Config.Title .. "Card"
    ElementCard.Size = UDim2.new(1, -16, 0, 40)
    ElementCard.BackgroundColor3 = SurfyUI.Theme.SurfaceLight
    ElementCard.BackgroundTransparency = 0.5
    ElementCard.LayoutOrder = Config.LayoutOrder or Section.ElementOrder
    ElementCard.Parent = Section.Frame
    
    RoundCorners(ElementCard, 10)
    
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
    ToggleLabel.Size = UDim2.new(1, -130, 1, 0)
    ToggleLabel.Position = UDim2.new(0, 12, 0, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = Config.Title or "Toggle"
    ToggleLabel.TextColor3 = SurfyUI.Theme.Text
    ToggleLabel.TextSize = 13
    ToggleLabel.Font = Enum.Font.GothamMedium
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.TextYAlignment = Enum.TextYAlignment.Center
    ToggleLabel.Parent = ElementCard
    
    local KeybindButton = Instance.new("TextButton")
    KeybindButton.Name = "KeybindButton"
    KeybindButton.Size = UDim2.new(0, 50, 0, 28)
    KeybindButton.Position = UDim2.new(1, -116, 0.5, -14)
    KeybindButton.BackgroundColor3 = SurfyUI.Theme.Secondary
    KeybindButton.BackgroundTransparency = 0.3
    KeybindButton.Text = GetKeyName(ToggleKeybind.Key)
    KeybindButton.TextColor3 = SurfyUI.Theme.Text
    KeybindButton.TextSize = 10
    KeybindButton.Font = Enum.Font.GothamMedium
    KeybindButton.Parent = ElementCard
    
    RoundCorners(KeybindButton, 8)
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "Toggle"
    ToggleButton.Size = UDim2.new(0, 48, 0, 26)
    ToggleButton.Position = UDim2.new(1, -56, 0.5, -13)
    ToggleButton.BackgroundColor3 = ToggleKeybind.Value and SurfyUI.Theme.Success or SurfyUI.Theme.Secondary
    ToggleButton.BackgroundTransparency = 0.2
    ToggleButton.Text = ""
    ToggleButton.Parent = ElementCard
    
    RoundCorners(ToggleButton, 13)
    
    local ToggleKnob = Instance.new("Frame")
    ToggleKnob.Name = "Knob"
    ToggleKnob.Size = UDim2.new(0, 20, 0, 20)
    ToggleKnob.Position = ToggleKeybind.Value and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
    ToggleKnob.BackgroundColor3 = Color3.new(1, 1, 1)
    ToggleKnob.Parent = ToggleButton
    
    RoundCorners(ToggleKnob, 10)
    AddStroke(ToggleKnob, SurfyUI.Theme.Primary, 1.5, 0.7)
    
    local function ToggleValue()
        ToggleKeybind.Value = not ToggleKeybind.Value
        
        if ToggleKeybind.Value then
            Tween(ToggleButton, {BackgroundColor3 = SurfyUI.Theme.Success, BackgroundTransparency = 0}, 0.3)
            Tween(ToggleKnob, {Position = UDim2.new(1, -23, 0.5, -10)}, 0.3, Enum.EasingStyle.Quint)
        else
            Tween(ToggleButton, {BackgroundColor3 = SurfyUI.Theme.Secondary, BackgroundTransparency = 0.2}, 0.3)
            Tween(ToggleKnob, {Position = UDim2.new(0, 3, 0.5, -10)}, 0.3, Enum.EasingStyle.Quint)
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
        Tween(KeybindButton, {BackgroundColor3 = SurfyUI.Theme.Primary, BackgroundTransparency = 0.1}, 0.2)
        
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
            
            Tween(KeybindButton, {BackgroundColor3 = SurfyUI.Theme.Secondary, BackgroundTransparency = 0.3}, 0.2)
            ToggleKeybind.IsBinding = false
            Connection:Disconnect()
        end)
    end)
    
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

function SurfyUI:CreateToggle(Section, Config)
    Config = Config or {}
    
    local Toggle = {
        Value = Config.Default or false,
        Callback = Config.Callback
    }
    
    -- Element Card
    local ElementCard = Instance.new("Frame")
    ElementCard.Name = Config.Title .. "Card"
    ElementCard.Size = UDim2.new(1, -16, 0, 40)
    ElementCard.BackgroundColor3 = SurfyUI.Theme.SurfaceLight
    ElementCard.BackgroundTransparency = 0.5
    ElementCard.LayoutOrder = Config.LayoutOrder or Section.ElementOrder
    ElementCard.Parent = Section.Frame
    
    RoundCorners(ElementCard, 10)
    
    Section.ElementOrder = Section.ElementOrder + 1
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Name = "Label"
    ToggleLabel.Size = UDim2.new(0.65, 0, 1, 0)
    ToggleLabel.Position = UDim2.new(0, 12, 0, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = Config.Title or "Toggle"
    ToggleLabel.TextColor3 = SurfyUI.Theme.Text
    ToggleLabel.TextSize = 13
    ToggleLabel.Font = Enum.Font.GothamMedium
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.TextYAlignment = Enum.TextYAlignment.Center
    ToggleLabel.Parent = ElementCard
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "Toggle"
    ToggleButton.Size = UDim2.new(0, 48, 0, 26)
    ToggleButton.Position = UDim2.new(1, -56, 0.5, -13)
    ToggleButton.BackgroundColor3 = Toggle.Value and SurfyUI.Theme.Success or SurfyUI.Theme.Secondary
    ToggleButton.BackgroundTransparency = 0.2
    ToggleButton.Text = ""
    ToggleButton.Parent = ElementCard
    
    RoundCorners(ToggleButton, 13)
    
    local ToggleKnob = Instance.new("Frame")
    ToggleKnob.Name = "Knob"
    ToggleKnob.Size = UDim2.new(0, 20, 0, 20)
    ToggleKnob.Position = Toggle.Value and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
    ToggleKnob.BackgroundColor3 = Color3.new(1, 1, 1)
    ToggleKnob.Parent = ToggleButton
    
    RoundCorners(ToggleKnob, 10)
    AddStroke(ToggleKnob, SurfyUI.Theme.Primary, 1.5, 0.7)
    
    ToggleButton.MouseButton1Click:Connect(function()
        Toggle.Value = not Toggle.Value
        
        if Toggle.Value then
            Tween(ToggleButton, {BackgroundColor3 = SurfyUI.Theme.Success, BackgroundTransparency = 0}, 0.3)
            Tween(ToggleKnob, {Position = UDim2.new(1, -23, 0.5, -10)}, 0.3, Enum.EasingStyle.Quint)
        else
            Tween(ToggleButton, {BackgroundColor3 = SurfyUI.Theme.Secondary, BackgroundTransparency = 0.2}, 0.3)
            Tween(ToggleKnob, {Position = UDim2.new(0, 3, 0.5, -10)}, 0.3, Enum.EasingStyle.Quint)
        end
        
        if Toggle.Callback then
            Toggle.Callback(Toggle.Value)
        end
    end)
    
    return Toggle
end

function SurfyUI:CreateSlider(Section, Config)
    Config = Config or {}
    
    local Slider = {
        Value = Config.Default or Config.Min or 0,
        Min = Config.Min or 0,
        Max = Config.Max or 100,
        Rounding = Config.Rounding or 0,
        Callback = Config.Callback,
        IsDragging = false
    }
    
    -- Element Card
    local ElementCard = Instance.new("Frame")
    ElementCard.Name = Config.Title .. "Card"
    ElementCard.Size = UDim2.new(1, -16, 0, 60)
    ElementCard.BackgroundColor3 = SurfyUI.Theme.SurfaceLight
    ElementCard.BackgroundTransparency = 0.5
    ElementCard.LayoutOrder = Config.LayoutOrder or Section.ElementOrder
    ElementCard.Parent = Section.Frame
    
    RoundCorners(ElementCard, 10)
    
    Section.ElementOrder = Section.ElementOrder + 1
    
    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Name = "Label"
    SliderLabel.Size = UDim2.new(1, 0, 0, 22)
    SliderLabel.Position = UDim2.new(0, 12, 0, 8)
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Text = Config.Title or "Slider"
    SliderLabel.TextColor3 = SurfyUI.Theme.Text
    SliderLabel.TextSize = 13
    SliderLabel.Font = Enum.Font.GothamMedium
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    SliderLabel.Parent = ElementCard
    
    local SliderValue = Instance.new("TextLabel")
    SliderValue.Name = "Value"
    SliderValue.Size = UDim2.new(0, 70, 0, 22)
    SliderValue.Position = UDim2.new(1, -78, 0, 8)
    SliderValue.BackgroundTransparency = 1
    SliderValue.Text = tostring(Slider.Value)
    SliderValue.TextColor3 = SurfyUI.Theme.Primary
    SliderValue.TextSize = 13
    SliderValue.Font = Enum.Font.GothamBold
    SliderValue.TextXAlignment = Enum.TextXAlignment.Right
    SliderValue.Parent = ElementCard
    
    local SliderTrack = Instance.new("Frame")
    SliderTrack.Name = "Track"
    SliderTrack.Size = UDim2.new(1, -24, 0, 6)
    SliderTrack.Position = UDim2.new(0, 12, 1, -22)
    SliderTrack.BackgroundColor3 = SurfyUI.Theme.Secondary
    SliderTrack.BackgroundTransparency = 0.3
    SliderTrack.Parent = ElementCard
    
    RoundCorners(SliderTrack, 3)
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Name = "Fill"
    SliderFill.Size = UDim2.new((Slider.Value - Slider.Min) / (Slider.Max - Slider.Min), 0, 1, 0)
    SliderFill.BackgroundColor3 = SurfyUI.Theme.Primary
    SliderFill.BackgroundTransparency = 0.2
    SliderFill.Parent = SliderTrack
    
    RoundCorners(SliderFill, 3)
    AddGradient(SliderFill, SurfyUI.Theme.Primary, SurfyUI.Theme.PrimaryLight, 0)
    
    local SliderButton = Instance.new("TextButton")
    SliderButton.Name = "Button"
    SliderButton.Size = UDim2.new(0, 16, 0, 16)
    SliderButton.Position = UDim2.new(SliderFill.Size.X.Scale, -8, 0.5, -8)
    SliderButton.BackgroundColor3 = Color3.new(1, 1, 1)
    SliderButton.BackgroundTransparency = 0
    SliderButton.Text = ""
    SliderButton.ZIndex = 2
    SliderButton.Parent = SliderTrack
    
    RoundCorners(SliderButton, 8)
    AddStroke(SliderButton, SurfyUI.Theme.Primary, 2, 0.3)
    
    local RunService = game:GetService("RunService")
    
    local pulseConnection
    
    local function UpdateSlider(Input)
        local RelativeX = (Input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X
        local Value = math.clamp(RelativeX, 0, 1)
        
        Slider.Value = math.floor((Slider.Min + (Slider.Max - Slider.Min) * Value) * (10 ^ Slider.Rounding)) / (10 ^ Slider.Rounding)
        SliderValue.Text = tostring(Slider.Value)
        
        Tween(SliderFill, {Size = UDim2.new(Value, 0, 1, 0)}, 0.1)
        Tween(SliderButton, {Position = UDim2.new(Value, -8, 0.5, -8)}, 0.1)
        
        if Slider.Callback then
            Slider.Callback(Slider.Value)
        end
    end
    
    SliderButton.MouseButton1Down:Connect(function()
        Slider.IsDragging = true
        Tween(SliderButton, {Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(SliderButton.Position.X.Scale, -9, 0.5, -9)}, 0.2)
        
        pulseConnection = RunService.Heartbeat:Connect(function()
            if Slider.IsDragging then
                local pulse = math.abs(math.sin(tick() * 8))
                SliderFill.BackgroundColor3 = SurfyUI.Theme.Primary:Lerp(SurfyUI.Theme.PrimaryLight, pulse * 0.5)
            end
        end)
    end)
    
    UserInputService.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Slider.IsDragging = false
            Tween(SliderButton, {Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(SliderButton.Position.X.Scale, -8, 0.5, -8)}, 0.2)
            if pulseConnection then
                pulseConnection:Disconnect()
                pulseConnection = nil
                SliderFill.BackgroundColor3 = SurfyUI.Theme.Primary
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

function SurfyUI:CreateColorPicker(Section, Config)
    Config = Config or {}
    
    local ColorPicker = {
        Value = Config.Default or Color3.fromRGB(0, 180, 255),
        Callback = Config.Callback
    }
    
    -- Element Card
    local ElementCard = Instance.new("Frame")
    ElementCard.Name = Config.Title .. "Card"
    ElementCard.Size = UDim2.new(1, -16, 0, 40)
    ElementCard.BackgroundColor3 = SurfyUI.Theme.SurfaceLight
    ElementCard.BackgroundTransparency = 0.5
    ElementCard.LayoutOrder = Config.LayoutOrder or Section.ElementOrder
    ElementCard.Parent = Section.Frame
    
    RoundCorners(ElementCard, 10)
    
    Section.ElementOrder = Section.ElementOrder + 1
    
    local PickerLabel = Instance.new("TextLabel")
    PickerLabel.Name = "Label"
    PickerLabel.Size = UDim2.new(0.65, 0, 1, 0)
    PickerLabel.Position = UDim2.new(0, 12, 0, 0)
    PickerLabel.BackgroundTransparency = 1
    PickerLabel.Text = Config.Title or "Color"
    PickerLabel.TextColor3 = SurfyUI.Theme.Text
    PickerLabel.TextSize = 13
    PickerLabel.Font = Enum.Font.GothamMedium
    PickerLabel.TextXAlignment = Enum.TextXAlignment.Left
    PickerLabel.TextYAlignment = Enum.TextYAlignment.Center
    PickerLabel.Parent = ElementCard
    
    local ColorButton = Instance.new("TextButton")
    ColorButton.Name = "ColorButton"
    ColorButton.Size = UDim2.new(0, 60, 0, 28)
    ColorButton.Position = UDim2.new(1, -68, 0.5, -14)
    ColorButton.BackgroundColor3 = ColorPicker.Value
    ColorButton.BackgroundTransparency = 0.1
    ColorButton.Text = ""
    ColorButton.Parent = ElementCard
    
    RoundCorners(ColorButton, 8)
    AddStroke(ColorButton, Color3.new(1, 1, 1), 2, 0.7)
    
    local colors = {
        Color3.fromRGB(255, 50, 50),
        Color3.fromRGB(255, 150, 50),
        Color3.fromRGB(255, 255, 50),
        Color3.fromRGB(50, 255, 50),
        Color3.fromRGB(50, 255, 255),
        Color3.fromRGB(50, 150, 255),
        Color3.fromRGB(150, 50, 255),
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

function SurfyUI:CreateDropdown(Section, Config)
    Config = Config or {}
    
    local Dropdown = {
        Value = Config.Default or Config.Options[1],
        Options = Config.Options or {"Option 1"},
        Callback = Config.Callback,
        IsOpen = false
    }
    
    -- Element Card
    local ElementCard = Instance.new("Frame")
    ElementCard.Name = Config.Title .. "Card"
    ElementCard.Size = UDim2.new(1, -16, 0, 40)
    ElementCard.BackgroundColor3 = SurfyUI.Theme.SurfaceLight
    ElementCard.BackgroundTransparency = 0.5
    ElementCard.LayoutOrder = Config.LayoutOrder or Section.ElementOrder
    ElementCard.Parent = Section.Frame
    ElementCard.ClipsDescendants = false
    ElementCard.ZIndex = 10
    
    RoundCorners(ElementCard, 10)
    
    Section.ElementOrder = Section.ElementOrder + 1
    
    local DropdownLabel = Instance.new("TextLabel")
    DropdownLabel.Name = "Label"
    DropdownLabel.Size = UDim2.new(0.4, 0, 1, 0)
    DropdownLabel.Position = UDim2.new(0, 12, 0, 0)
    DropdownLabel.BackgroundTransparency = 1
    DropdownLabel.Text = Config.Title or "Dropdown"
    DropdownLabel.TextColor3 = SurfyUI.Theme.Text
    DropdownLabel.TextSize = 13
    DropdownLabel.Font = Enum.Font.GothamMedium
    DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
    DropdownLabel.TextYAlignment = Enum.TextYAlignment.Center
    DropdownLabel.Parent = ElementCard
    
    local DropdownButton = Instance.new("TextButton")
    DropdownButton.Name = "Button"
    DropdownButton.Size = UDim2.new(0, 130, 0, 28)
    DropdownButton.Position = UDim2.new(1, -138, 0.5, -14)
    DropdownButton.BackgroundColor3 = SurfyUI.Theme.Secondary
    DropdownButton.BackgroundTransparency = 0.3
    DropdownButton.Text = "  " .. Dropdown.Value
    DropdownButton.TextColor3 = SurfyUI.Theme.Text
    DropdownButton.TextSize = 12
    DropdownButton.Font = Enum.Font.GothamMedium
    DropdownButton.TextXAlignment = Enum.TextXAlignment.Left
    DropdownButton.Parent = ElementCard
    
    RoundCorners(DropdownButton, 8)
    
    local Arrow = Instance.new("TextLabel")
    Arrow.Name = "Arrow"
    Arrow.Size = UDim2.new(0, 24, 1, 0)
    Arrow.Position = UDim2.new(1, -24, 0, 0)
    Arrow.BackgroundTransparency = 1
    Arrow.Text = "▼"
    Arrow.TextColor3 = SurfyUI.Theme.SubText
    Arrow.TextSize = 10
    Arrow.Font = Enum.Font.GothamBold
    Arrow.Parent = DropdownButton
    
    local OptionsContainer = Instance.new("Frame")
    OptionsContainer.Name = "Options"
    OptionsContainer.Size = UDim2.new(0, 130, 0, 0)
    OptionsContainer.Position = UDim2.new(1, -138, 1, 6)
    OptionsContainer.BackgroundColor3 = SurfyUI.Theme.Surface
    OptionsContainer.BackgroundTransparency = 0.2
    OptionsContainer.BorderSizePixel = 0
    OptionsContainer.Visible = false
    OptionsContainer.ZIndex = 15
    OptionsContainer.Parent = ElementCard
    
    RoundCorners(OptionsContainer, 8)
    AddStroke(OptionsContainer, SurfyUI.Theme.Primary, 1, 0.6)
    
    local OptionsLayout = Instance.new("UIListLayout")
    OptionsLayout.Padding = UDim.new(0, 2)
    OptionsLayout.Parent = OptionsContainer
    
    local OptionsPadding = Instance.new("UIPadding")
    OptionsPadding.PaddingTop = UDim.new(0, 4)
    OptionsPadding.PaddingBottom = UDim.new(0, 4)
    OptionsPadding.PaddingLeft = UDim.new(0, 4)
    OptionsPadding.PaddingRight = UDim.new(0, 4)
    OptionsPadding.Parent = OptionsContainer
    
    for _, option in ipairs(Dropdown.Options) do
        local OptionButton = Instance.new("TextButton")
        OptionButton.Name = option
        OptionButton.Size = UDim2.new(1, -8, 0, 24)
        OptionButton.BackgroundColor3 = SurfyUI.Theme.SurfaceLight
        OptionButton.BackgroundTransparency = option == Dropdown.Value and 0.2 or 0.6
        OptionButton.Text = " " .. option
        OptionButton.TextColor3 = SurfyUI.Theme.Text
        OptionButton.TextSize = 11
        OptionButton.Font = Enum.Font.GothamMedium
        OptionButton.TextXAlignment = Enum.TextXAlignment.Left
        OptionButton.ZIndex = 16
        OptionButton.Parent = OptionsContainer
        
        RoundCorners(OptionButton, 6)
        
        if option == Dropdown.Value then
            AddStroke(OptionButton, SurfyUI.Theme.Primary, 1, 0.5)
        end
        
        OptionButton.MouseEnter:Connect(function()
            if option ~= Dropdown.Value then
                Tween(OptionButton, {BackgroundTransparency = 0.4}, 0.2)
            end
        end)
        
        OptionButton.MouseLeave:Connect(function()
            if option ~= Dropdown.Value then
                Tween(OptionButton, {BackgroundTransparency = 0.6}, 0.2)
            end
        end)
        
        OptionButton.MouseButton1Click:Connect(function()
            Dropdown.Value = option
            DropdownButton.Text = "  " .. option
            
            for _, btn in ipairs(OptionsContainer:GetChildren()) do
                if btn:IsA("TextButton") then
                    Tween(btn, {BackgroundTransparency = btn.Name == option and 0.2 or 0.6}, 0.2)
                    
                    -- Remove old strokes and add to selected
                    for _, child in ipairs(btn:GetChildren()) do
                        if child:IsA("UIStroke") then
                            child:Destroy()
                        end
                    end
                    
                    if btn.Name == option then
                        AddStroke(btn, SurfyUI.Theme.Primary, 1, 0.5)
                    end
                end
            end
            
            Dropdown.IsOpen = false
            Tween(OptionsContainer, {Size = UDim2.new(0, 130, 0, 0)}, 0.2)
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
            OptionsContainer.Size = UDim2.new(0, 130, 0, 0)
            local targetHeight = (#Dropdown.Options * 26) + 8
            Tween(OptionsContainer, {Size = UDim2.new(0, 130, 0, targetHeight)}, 0.3, Enum.EasingStyle.Back)
            Tween(Arrow, {Rotation = 180}, 0.2)
        else
            Tween(OptionsContainer, {Size = UDim2.new(0, 130, 0, 0)}, 0.2)
            Tween(Arrow, {Rotation = 0}, 0.2)
            task.wait(0.2)
            OptionsContainer.Visible = false
        end
    end)
    
    return Dropdown
end

function SurfyUI:CreateButton(Section, Config)
    Config = Config or {}
    
    local Button = {
        Callback = Config.Callback
    }
    
    -- Element Card
    local ElementCard = Instance.new("Frame")
    ElementCard.Name = Config.Title .. "Card"
    ElementCard.Size = UDim2.new(1, -16, 0, 40)
    ElementCard.BackgroundColor3 = SurfyUI.Theme.Primary
    ElementCard.BackgroundTransparency = 0.3
    ElementCard.LayoutOrder = Config.LayoutOrder or Section.ElementOrder
    ElementCard.Parent = Section.Frame
    
    RoundCorners(ElementCard, 10)
    AddStroke(ElementCard, SurfyUI.Theme.PrimaryLight, 1.5, 0.5)
    AddGradient(ElementCard, SurfyUI.Theme.Primary, SurfyUI.Theme.PrimaryDark, 45)
    
    Section.ElementOrder = Section.ElementOrder + 1
    
    local ButtonElement = Instance.new("TextButton")
    ButtonElement.Name = "Button"
    ButtonElement.Size = UDim2.new(1, 0, 1, 0)
    ButtonElement.BackgroundTransparency = 1
    ButtonElement.Text = Config.Title or "Button"
    ButtonElement.TextColor3 = SurfyUI.Theme.Text
    ButtonElement.TextSize = 14
    ButtonElement.Font = Enum.Font.GothamBold
    ButtonElement.Parent = ElementCard
    
    ButtonElement.MouseEnter:Connect(function()
        Tween(ElementCard, {BackgroundTransparency = 0.1}, 0.2)
    end)
    
    ButtonElement.MouseLeave:Connect(function()
        Tween(ElementCard, {BackgroundTransparency = 0.3}, 0.2)
    end)
    
    ButtonElement.MouseButton1Click:Connect(function()
        -- Click animation
        Tween(ElementCard, {Size = UDim2.new(1, -16, 0, 38)}, 0.1)
        task.wait(0.1)
        Tween(ElementCard, {Size = UDim2.new(1, -16, 0, 40)}, 0.1)
        
        if Button.Callback then
            Button.Callback()
        end
    end)
    
    return Button
end

function SurfyUI:CreateLabel(Section, Config)
    Config = Config or {}
    
    local Label = {
        Text = Config.Text or "Label"
    }
    
    -- Element Card
    local ElementCard = Instance.new("Frame")
    ElementCard.Name = "LabelCard"
    ElementCard.Size = UDim2.new(1, -16, 0, 35)
    ElementCard.BackgroundColor3 = SurfyUI.Theme.SurfaceLight
    ElementCard.BackgroundTransparency = 0.6
    ElementCard.LayoutOrder = Config.LayoutOrder or Section.ElementOrder
    ElementCard.Parent = Section.Frame
    
    RoundCorners(ElementCard, 10)
    
    Section.ElementOrder = Section.ElementOrder + 1
    
    local LabelElement = Instance.new("TextLabel")
    LabelElement.Name = "Label"
    LabelElement.Size = UDim2.new(1, -20, 1, 0)
    LabelElement.Position = UDim2.new(0, 10, 0, 0)
    LabelElement.BackgroundTransparency = 1
    LabelElement.Text = Label.Text
    LabelElement.TextColor3 = SurfyUI.Theme.SubText
    LabelElement.TextSize = 12
    LabelElement.Font = Enum.Font.Gotham
    LabelElement.TextXAlignment = Enum.TextXAlignment.Left
    LabelElement.TextWrapped = true
    LabelElement.Parent = ElementCard
    
    function Label:SetText(newText)
        self.Text = newText
        LabelElement.Text = newText
    end
    
    return Label
end

function SurfyUI:CreateTextBox(Section, Config)
    Config = Config or {}
    
    local TextBox = {
        Value = Config.Default or "",
        Callback = Config.Callback
    }
    
    -- Element Card
    local ElementCard = Instance.new("Frame")
    ElementCard.Name = Config.Title .. "Card"
    ElementCard.Size = UDim2.new(1, -16, 0, 40)
    ElementCard.BackgroundColor3 = SurfyUI.Theme.SurfaceLight
    ElementCard.BackgroundTransparency = 0.5
    ElementCard.LayoutOrder = Config.LayoutOrder or Section.ElementOrder
    ElementCard.Parent = Section.Frame
    
    RoundCorners(ElementCard, 10)
    
    Section.ElementOrder = Section.ElementOrder + 1
    
    local TextBoxLabel = Instance.new("TextLabel")
    TextBoxLabel.Name = "Label"
    TextBoxLabel.Size = UDim2.new(0.35, 0, 1, 0)
    TextBoxLabel.Position = UDim2.new(0, 12, 0, 0)
    TextBoxLabel.BackgroundTransparency = 1
    TextBoxLabel.Text = Config.Title or "TextBox"
    TextBoxLabel.TextColor3 = SurfyUI.Theme.Text
    TextBoxLabel.TextSize = 13
    TextBoxLabel.Font = Enum.Font.GothamMedium
    TextBoxLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextBoxLabel.TextYAlignment = Enum.TextYAlignment.Center
    TextBoxLabel.Parent = ElementCard
    
    local TextBoxElement = Instance.new("TextBox")
    TextBoxElement.Name = "TextBox"
    TextBoxElement.Size = UDim2.new(0, 150, 0, 28)
    TextBoxElement.Position = UDim2.new(1, -158, 0.5, -14)
    TextBoxElement.BackgroundColor3 = SurfyUI.Theme.Secondary
    TextBoxElement.BackgroundTransparency = 0.3
    TextBoxElement.Text = TextBox.Value
    TextBoxElement.PlaceholderText = Config.Placeholder or "Enter text..."
    TextBoxElement.TextColor3 = SurfyUI.Theme.Text
    TextBoxElement.PlaceholderColor3 = SurfyUI.Theme.SubText
    TextBoxElement.TextSize = 12
    TextBoxElement.Font = Enum.Font.Gotham
    TextBoxElement.ClearTextOnFocus = false
    TextBoxElement.Parent = ElementCard
    
    RoundCorners(TextBoxElement, 8)
    AddStroke(TextBoxElement, SurfyUI.Theme.Primary, 1, 0.8)
    
    local TextPadding = Instance.new("UIPadding")
    TextPadding.PaddingLeft = UDim.new(0, 8)
    TextPadding.PaddingRight = UDim.new(0, 8)
    TextPadding.Parent = TextBoxElement
    
    TextBoxElement.Focused:Connect(function()
        Tween(TextBoxElement, {BackgroundTransparency = 0.1}, 0.2)
    end)
    
    TextBoxElement.FocusLost:Connect(function(enterPressed)
        Tween(TextBoxElement, {BackgroundTransparency = 0.3}, 0.2)
        
        if enterPressed then
            TextBox.Value = TextBoxElement.Text
            if TextBox.Callback then
                TextBox.Callback(TextBox.Value)
            end
        end
    end)
    
    function TextBox:SetValue(value)
        self.Value = value
        TextBoxElement.Text = value
    end
    
    return TextBox
end

return SurfyUI
