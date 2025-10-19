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

function SurfyUI:CreateSlider(section, config)
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
        Section = section
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
        
        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new((self.Value - self.Min) / (self.Max - self.Min), 0, 1, 0)
        Fill.BackgroundColor3 = SurfyUI.Theme.Primary
        Fill.BackgroundTransparency = 0.2
        Fill.BorderSizePixel = 0
        Fill.ZIndex = 10000
        Fill.Parent = Track
        
        Round(Fill, 3)
        AddGradient(Fill, SurfyUI.Theme.Primary, SurfyUI.Theme.PrimaryBright, 0)
        
        local Knob = Instance.new("TextButton")
        Knob.Size = UDim2.new(0, 16, 0, 16)
        Knob.Position = UDim2.new(Fill.Size.X.Scale, -8, 0.5, -8)
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
        
        local function UpdateSlider(input)
            local relX = (input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X
            local value = math.clamp(relX, 0, 1)
            
            self.Value = math.floor((self.Min + (self.Max - self.Min) * value) * (10 ^ self.Rounding)) / (10 ^ self.Rounding)
            ValueLabel.Text = tostring(self.Value)
            
            Tween(Fill, {Size = UDim2.new(value, 0, 1, 0)}, 0.1, Enum.EasingStyle.Exponential)
            Tween(Knob, {Position = UDim2.new(value, -8, 0.5, -8)}, 0.1, Enum.EasingStyle.Exponential)
            
            if self.Callback then
                self.Callback(self.Value)
            end
        end
        
        Knob.MouseButton1Down:Connect(function()
            self.IsDragging = true
            Tween(Knob, {Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(Knob.Position.X.Scale, -9, 0.5, -9)}, 0.2, Enum.EasingStyle.Exponential)
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                self.IsDragging = false
                Tween(Knob, {Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(Knob.Position.X.Scale, -8, 0.5, -8)}, 0.2, Enum.EasingStyle.Exponential)
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement and self.IsDragging then
                UpdateSlider(input)
            end
        end)
    end
    
    table.insert(section.Tab.Modules, Module)
    return Module
end

function SurfyUI:CreateDropdown(section, config)
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

function SurfyUI:CreateButton(section, config)
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

function SurfyUI:CreateKeybind(section, config)
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

function SurfyUI:CreateColorPicker(section, config)
    config = config or {}
    
    local Module = {
        Name = config.Title or "Color",
        Value = config.Default or Color3.fromRGB(0, 230, 255),
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
    
    table.insert(section.Tab.Modules, Module)
    return Module
end

return SurfyUI
