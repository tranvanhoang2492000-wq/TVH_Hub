local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Library = {}

local THEME = {
    Background = Color3.fromRGB(13, 11, 20),
    Header = Color3.fromRGB(22, 17, 34),
    Sidebar = Color3.fromRGB(18, 14, 28),
    Card = Color3.fromRGB(27, 21, 42),
    CardHover = Color3.fromRGB(36, 28, 56),
    Accent = Color3.fromRGB(168, 85, 247),
    TextMain = Color3.fromRGB(245, 245, 250),
    TextDark = Color3.fromRGB(150, 142, 170),
    Border = Color3.fromRGB(48, 38, 72),
    Overlay = Color3.fromRGB(6, 4, 10),
    BtnMinimize = Color3.fromRGB(255, 255, 255),
    BtnMinimizeHover = Color3.fromRGB(200, 200, 210),
    BtnClose = Color3.fromRGB(235, 55, 75),
    BtnCloseHover = Color3.fromRGB(255, 75, 95)
}

local function EnableSmoothDrag(frame, dragHandle)
    dragHandle = dragHandle or frame
    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

function Library:Notify(title, message, duration)
    duration = duration or 3

    local NotifContainer = CoreGui:FindFirstChild("TVHNotifContainer")
    if not NotifContainer then
        NotifContainer = Instance.new("ScreenGui")
        NotifContainer.Name = "TVHNotifContainer"
        NotifContainer.Parent = CoreGui
        
        local Holder = Instance.new("Frame")
        Holder.Name = "Holder"
        Holder.Size = UDim2.new(0, 260, 1, 0)
        Holder.Position = UDim2.new(1, -270, 0, 20)
        Holder.BackgroundTransparency = 1
        Holder.Parent = NotifContainer

        local List = Instance.new("UIListLayout")
        List.Padding = UDim.new(0, 8)
        List.VerticalAlignment = Enum.VerticalAlignment.Bottom
        List.SortOrder = Enum.SortOrder.LayoutOrder
        List.Parent = Holder
    end

    local Holder = NotifContainer.Holder

    local NotifFrame = Instance.new("Frame")
    NotifFrame.Size = UDim2.new(1, 0, 0, 60)
    NotifFrame.BackgroundColor3 = THEME.Card
    NotifFrame.Position = UDim2.new(1, 300, 0, 0)
    NotifFrame.Parent = Holder

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = NotifFrame

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = THEME.Accent
    Stroke.Thickness = 1.2
    Stroke.Parent = NotifFrame

    local NotifTitle = Instance.new("TextLabel")
    NotifTitle.Size = UDim2.new(1, -20, 0, 20)
    NotifTitle.Position = UDim2.new(0, 10, 0, 6)
    NotifTitle.Text = title or "TVH Hub"
    NotifTitle.Font = Enum.Font.GothamBold
    NotifTitle.TextSize = 13
    NotifTitle.TextColor3 = THEME.Accent
    NotifTitle.TextXAlignment = Enum.TextXAlignment.Left
    NotifTitle.BackgroundTransparency = 1
    NotifTitle.Parent = NotifFrame

    local NotifMsg = Instance.new("TextLabel")
    NotifMsg.Size = UDim2.new(1, -20, 0, 28)
    NotifMsg.Position = UDim2.new(0, 10, 0, 26)
    NotifMsg.Text = message or ""
    NotifMsg.Font = Enum.Font.Gotham
    NotifMsg.TextSize = 11
    NotifMsg.TextColor3 = THEME.TextMain
    NotifMsg.TextXAlignment = Enum.TextXAlignment.Left
    NotifMsg.TextWrapped = true
    NotifMsg.BackgroundTransparency = 1
    NotifMsg.Parent = NotifFrame

    TweenService:Create(NotifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
    
    task.delay(duration, function()
        local hideTween = TweenService:Create(NotifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1.5, 0, 0, 0)})
        hideTween:Play()
        hideTween.Completed:Connect(function() NotifFrame:Destroy() end)
    end)
end

function Library:CreateWindow(hubTitle, iconAssetId, configFileName)
    iconAssetId = iconAssetId or "rbxassetid://73075320811076"
    configFileName = configFileName or "TVH_Config.json"

    -- Quản lý Save / Load JSON
    local ConfigData = {}

    local function SaveConfig()
        if writefile then
            local success, err = pcall(function()
                writefile(configFileName, HttpService:JSONEncode(ConfigData))
            end)
        end
    end

    local function LoadConfig()
        if isfile and readfile and isfile(configFileName) then
            local success, result = pcall(function()
                return HttpService:JSONDecode(readfile(configFileName))
            end)
            if success and type(result) == "table" then
                ConfigData = result
            end
        end
    end

    LoadConfig()

    if CoreGui:FindFirstChild("TVH_HubUI") then
        CoreGui.TVH_HubUI:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "TVH_HubUI"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local ToggleIcon = Instance.new("ImageButton")
    ToggleIcon.Name = "ToggleIcon"
    ToggleIcon.Size = UDim2.new(0, 52, 0, 52)
    ToggleIcon.Position = UDim2.new(0, 20, 0.2, 0)
    ToggleIcon.BackgroundColor3 = THEME.Background
    ToggleIcon.Image = iconAssetId
    ToggleIcon.AutoButtonColor = false
    ToggleIcon.Parent = ScreenGui

    local IconCorner = Instance.new("UICorner")
    IconCorner.CornerRadius = UDim.new(1, 0)
    IconCorner.Parent = ToggleIcon

    local IconStroke = Instance.new("UIStroke")
    IconStroke.Thickness = 3
    IconStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    IconStroke.Parent = ToggleIcon

    local IconGradient = Instance.new("UIGradient")
    IconGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 128)),
        ColorSequenceKeypoint.new(0.20, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.40, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.60, Color3.fromRGB(0, 255, 128)),
        ColorSequenceKeypoint.new(0.80, Color3.fromRGB(0, 180, 255)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(168, 85, 247))
    })
    IconGradient.Parent = IconStroke

    RunService.RenderStepped:Connect(function(delta)
        IconGradient.Rotation = (IconGradient.Rotation + (140 * delta)) % 360
    end)

    EnableSmoothDrag(ToggleIcon)

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 580, 0, 380)
    MainFrame.Position = UDim2.new(0.5, -290, 0.5, -190)
    MainFrame.BackgroundColor3 = THEME.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = THEME.Border
    MainStroke.Thickness = 1.5
    MainStroke.Parent = MainFrame

    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 45)
    Header.BackgroundColor3 = THEME.Header
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame

    EnableSmoothDrag(MainFrame, Header)

    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 12)
    HeaderCorner.Parent = Header

    local AccentLine = Instance.new("Frame")
    AccentLine.Size = UDim2.new(1, 0, 0, 2)
    AccentLine.Position = UDim2.new(0, 0, 1, -2)
    AccentLine.BackgroundColor3 = THEME.Accent
    AccentLine.BorderSizePixel = 0
    AccentLine.Parent = Header

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(0, 250, 1, 0)
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.Text = hubTitle or "TVH Hub"
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 16
    TitleLabel.TextColor3 = THEME.TextMain
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Parent = Header

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "CloseBtn"
    CloseBtn.Size = UDim2.new(0, 28, 0, 28)
    CloseBtn.Position = UDim2.new(1, -36, 0.5, -14)
    CloseBtn.BackgroundColor3 = THEME.BtnClose
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 13
    CloseBtn.AutoButtonColor = false
    CloseBtn.Parent = Header

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 8)
    CloseCorner.Parent = CloseBtn

    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Name = "MinimizeBtn"
    MinimizeBtn.Size = UDim2.new(0, 28, 0, 28)
    MinimizeBtn.Position = UDim2.new(1, -70, 0.5, -14)
    MinimizeBtn.BackgroundColor3 = THEME.BtnMinimize
    MinimizeBtn.Text = "—"
    MinimizeBtn.TextColor3 = Color3.fromRGB(20, 20, 20)
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.TextSize = 13
    MinimizeBtn.AutoButtonColor = false
    MinimizeBtn.Parent = Header

    local MinimizeCorner = Instance.new("UICorner")
    MinimizeCorner.CornerRadius = UDim.new(0, 8)
    MinimizeCorner.Parent = MinimizeBtn

    local isOpen = true
    local function ToggleWindow()
        isOpen = not isOpen
        if isOpen then
            MainFrame.Visible = true
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 580, 0, 380),
                Position = UDim2.new(0.5, -290, 0.5, -190)
            }):Play()
        else
            local anim = TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0)
            })
            anim:Play()
            anim.Completed:Connect(function()
                if not isOpen then MainFrame.Visible = false end
            end)
        end
    end

    ToggleIcon.MouseButton1Click:Connect(ToggleWindow)
    MinimizeBtn.MouseButton1Click:Connect(ToggleWindow)
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 150, 1, -45)
    Sidebar.Position = UDim2.new(0, 0, 0, 45)
    Sidebar.BackgroundColor3 = THEME.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame

    local SidebarList = Instance.new("UIListLayout")
    SidebarList.Padding = UDim.new(0, 6)
    SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
    SidebarList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    SidebarList.Parent = Sidebar

    local SidebarPadding = Instance.new("UIPadding")
    SidebarPadding.PaddingTop = UDim.new(0, 12)
    SidebarPadding.Parent = Sidebar

    local ContentArea = Instance.new("Frame")
    ContentArea.Size = UDim2.new(1, -150, 1, -45)
    ContentArea.Position = UDim2.new(0, 150, 0, 45)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = MainFrame

    local Window = {}
    local tabs = {}

    function Window:CreateTab(tabName, tabIconId)
        tabIconId = tabIconId or "rbxassetid://73075320811076"

        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(0, 130, 0, 36)
        TabBtn.BackgroundColor3 = THEME.Card
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = ""
        TabBtn.AutoButtonColor = false
        TabBtn.Parent = Sidebar

        local TabBtnCorner = Instance.new("UICorner")
        TabBtnCorner.CornerRadius = UDim.new(0, 8)
        TabBtnCorner.Parent = TabBtn

        local TabList = Instance.new("UIListLayout")
        TabList.FillDirection = Enum.FillDirection.Horizontal
        TabList.VerticalAlignment = Enum.VerticalAlignment.Center
        TabList.SortOrder = Enum.SortOrder.LayoutOrder
        TabList.Padding = UDim.new(0, 8)
        TabList.Parent = TabBtn

        local TabPadding = Instance.new("UIPadding")
        TabPadding.PaddingLeft = UDim.new(0, 10)
        TabPadding.Parent = TabBtn

        local TabIcon = Instance.new("ImageLabel")
        TabIcon.Size = UDim2.new(0, 18, 0, 18)
        TabIcon.BackgroundTransparency = 1
        TabIcon.Image = tabIconId
        TabIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
        TabIcon.Parent = TabBtn

        local TabLabel = Instance.new("TextLabel")
        TabLabel.Size = UDim2.new(1, -30, 1, 0)
        TabLabel.BackgroundTransparency = 1
        TabLabel.Text = tabName
        TabLabel.Font = Enum.Font.GothamMedium
        TabLabel.TextSize = 13
        TabLabel.TextColor3 = THEME.TextDark
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabLabel.Parent = TabBtn

        local TabPage = Instance.new("ScrollingFrame")
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundTransparency = 1
        TabPage.Visible = false
        TabPage.ScrollBarThickness = 3
        TabPage.ScrollBarImageColor3 = THEME.Accent
        TabPage.Parent = ContentArea

        local PageList = Instance.new("UIListLayout")
        PageList.Padding = UDim.new(0, 8)
        PageList.SortOrder = Enum.SortOrder.LayoutOrder
        PageList.HorizontalAlignment = Enum.HorizontalAlignment.Center
        PageList.Parent = TabPage

        local PagePadding = Instance.new("UIPadding")
        PagePadding.PaddingTop = UDim.new(0, 12)
        PagePadding.PaddingBottom = UDim.new(0, 12)
        PagePadding.Parent = TabPage

        PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabPage.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 24)
        end)

        local function SelectTab()
            for _, t in pairs(tabs) do
                TweenService:Create(t.Btn, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
                TweenService:Create(t.Label, TweenInfo.new(0.2), {TextColor3 = THEME.TextDark}):Play()
                TweenService:Create(t.Icon, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
                t.Page.Visible = false
            end
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
            TweenService:Create(TabLabel, TweenInfo.new(0.2), {TextColor3 = THEME.TextMain}):Play()
            TweenService:Create(TabIcon, TweenInfo.new(0.2), {ImageColor3 = THEME.Accent}):Play()
            TabPage.Visible = true
        end

        TabBtn.MouseButton1Click:Connect(SelectTab)
        table.insert(tabs, {Btn = TabBtn, Label = TabLabel, Icon = TabIcon, Page = TabPage})
        if #tabs == 1 then SelectTab() end

        local Elements = {}

        function Elements:CreateButton(btnText, callback)
            callback = callback or function() end
            local ButtonFrame = Instance.new("TextButton")
            ButtonFrame.Size = UDim2.new(0, 390, 0, 38)
            ButtonFrame.BackgroundColor3 = THEME.Card
            ButtonFrame.Text = btnText
            ButtonFrame.Font = Enum.Font.GothamMedium
            ButtonFrame.TextSize = 13
            ButtonFrame.TextColor3 = THEME.TextMain
            ButtonFrame.AutoButtonColor = false
            ButtonFrame.Parent = TabPage

            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 8)
            Corner.Parent = ButtonFrame

            ButtonFrame.MouseButton1Click:Connect(function()
                pcall(callback)
            end)
        end

        function Elements:CreateToggle(toggleText, defaultState, callback)
            callback = callback or function() end
            
            -- Tự lấy dữ liệu đã lưu từ JSON, nếu chưa có thì lấy defaultState
            local toggled = defaultState or false
            if ConfigData[toggleText] ~= nil then
                toggled = ConfigData[toggleText]
            else
                ConfigData[toggleText] = toggled
            end

            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Size = UDim2.new(0, 390, 0, 38)
            ToggleFrame.BackgroundColor3 = THEME.Card
            ToggleFrame.Parent = TabPage

            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 8)
            Corner.Parent = ToggleFrame

            local Title = Instance.new("TextLabel")
            Title.Size = UDim2.new(0, 250, 1, 0)
            Title.Position = UDim2.new(0, 12, 0, 0)
            Title.Text = toggleText
            Title.Font = Enum.Font.GothamMedium
            Title.TextSize = 13
            Title.TextColor3 = THEME.TextMain
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.BackgroundTransparency = 1
            Title.Parent = ToggleFrame

            local Switch = Instance.new("TextButton")
            Switch.Size = UDim2.new(0, 42, 0, 22)
            Switch.Position = UDim2.new(1, -52, 0.5, -11)
            Switch.BackgroundColor3 = toggled and THEME.Accent or THEME.Header
            Switch.Text = ""
            Switch.Parent = ToggleFrame

            local SwitchCorner = Instance.new("UICorner")
            SwitchCorner.CornerRadius = UDim.new(1, 0)
            SwitchCorner.Parent = Switch

            local Knob = Instance.new("Frame")
            Knob.Size = UDim2.new(0, 16, 0, 16)
            Knob.Position = toggled and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
            Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Knob.Parent = Switch

            local KnobCorner = Instance.new("UICorner")
            KnobCorner.CornerRadius = UDim.new(1, 0)
            KnobCorner.Parent = Knob

            local function FireToggle(state)
                local targetPos = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
                local targetColor = state and THEME.Accent or THEME.Header
                TweenService:Create(Knob, TweenInfo.new(0.2), {Position = targetPos}):Play()
                TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
                
                -- Cập nhật vào Config & Lưu file JSON
                ConfigData[toggleText] = state
                SaveConfig()

                pcall(callback, state)
            end

            -- Chạy callback lần đầu theo trạng thái đã lưu
            task.spawn(function() pcall(callback, toggled) end)

            Switch.MouseButton1Click:Connect(function()
                toggled = not toggled
                FireToggle(toggled)
            end)
        end

        function Elements:CreateSlider(sliderText, min, max, default, callback)
            callback = callback or function() end
            
            local value = default or min
            if ConfigData[sliderText] ~= nil then
                value = ConfigData[sliderText]
            else
                ConfigData[sliderText] = value
            end

            local SliderFrame = Instance.new("Frame")
            SliderFrame.Size = UDim2.new(0, 390, 0, 50)
            SliderFrame.BackgroundColor3 = THEME.Card
            SliderFrame.Parent = TabPage

            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 8)
            Corner.Parent = SliderFrame

            local Title = Instance.new("TextLabel")
            Title.Size = UDim2.new(0, 200, 0, 25)
            Title.Position = UDim2.new(0, 12, 0, 2)
            Title.Text = sliderText
            Title.Font = Enum.Font.GothamMedium
            Title.TextSize = 13
            Title.TextColor3 = THEME.TextMain
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.BackgroundTransparency = 1
            Title.Parent = SliderFrame

            local ValLabel = Instance.new("TextLabel")
            ValLabel.Size = UDim2.new(0, 50, 0, 25)
            ValLabel.Position = UDim2.new(1, -62, 0, 2)
            ValLabel.Text = tostring(value)
            ValLabel.Font = Enum.Font.GothamBold
            ValLabel.TextSize = 12
            ValLabel.TextColor3 = THEME.Accent
            ValLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValLabel.BackgroundTransparency = 1
            ValLabel.Parent = SliderFrame

            local Bar = Instance.new("Frame")
            Bar.Size = UDim2.new(1, -24, 0, 6)
            Bar.Position = UDim2.new(0, 12, 1, -14)
            Bar.BackgroundColor3 = THEME.Header
            Bar.BorderSizePixel = 0
            Bar.Parent = SliderFrame

            local BarCorner = Instance.new("UICorner")
            BarCorner.CornerRadius = UDim.new(1, 0)
            BarCorner.Parent = Bar

            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
            Fill.BackgroundColor3 = THEME.Accent
            Fill.BorderSizePixel = 0
            Fill.Parent = Bar

            local FillCorner = Instance.new("UICorner")
            FillCorner.CornerRadius = UDim.new(1, 0)
            FillCorner.Parent = Fill

            local sliding = false
            local function UpdateSlider(input)
                local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                value = math.floor(min + (max - min) * pos)
                ValLabel.Text = tostring(value)
                TweenService:Create(Fill, TweenInfo.new(0.05), {Size = UDim2.new(pos, 0, 1, 0)}):Play()
                
                ConfigData[sliderText] = value
                SaveConfig()

                pcall(callback, value)
            end

            task.spawn(function() pcall(callback, value) end)

            Bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = true
                    UpdateSlider(input)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    UpdateSlider(input)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = false
                end
            end)
        end

        function Elements:CreateDropdown(dropdownText, options, default, callback)
            callback = callback or function() end
            options = options or {}

            local selected = default or options[1] or "None"
            if ConfigData[dropdownText] ~= nil then
                selected = ConfigData[dropdownText]
            else
                ConfigData[dropdownText] = selected
            end

            local dropped = false

            local DropFrame = Instance.new("Frame")
            DropFrame.Size = UDim2.new(0, 390, 0, 38)
            DropFrame.BackgroundColor3 = THEME.Card
            DropFrame.ClipsDescendants = true
            DropFrame.Parent = TabPage

            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 8)
            Corner.Parent = DropFrame

            local Title = Instance.new("TextLabel")
            Title.Size = UDim2.new(0, 180, 0, 38)
            Title.Position = UDim2.new(0, 12, 0, 0)
            Title.Text = dropdownText
            Title.Font = Enum.Font.GothamMedium
            Title.TextSize = 13
            Title.TextColor3 = THEME.TextMain
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.BackgroundTransparency = 1
            Title.Parent = DropFrame

            local SelectedLabel = Instance.new("TextButton")
            SelectedLabel.Size = UDim2.new(0, 140, 0, 26)
            SelectedLabel.Position = UDim2.new(1, -152, 0, 6)
            SelectedLabel.BackgroundColor3 = THEME.Header
            SelectedLabel.Text = selected .. "  ▼"
            SelectedLabel.Font = Enum.Font.Gotham
            SelectedLabel.TextSize = 11
            SelectedLabel.TextColor3 = THEME.Accent
            SelectedLabel.Parent = DropFrame

            local SelCorner = Instance.new("UICorner")
            SelCorner.CornerRadius = UDim.new(0, 6)
            SelCorner.Parent = SelectedLabel

            local Container = Instance.new("Frame")
            Container.Size = UDim2.new(1, -24, 0, 0)
            Container.Position = UDim2.new(0, 12, 0, 42)
            Container.BackgroundTransparency = 1
            Container.Parent = DropFrame

            local ContainerList = Instance.new("UIListLayout")
            ContainerList.Padding = UDim.new(0, 4)
            ContainerList.SortOrder = Enum.SortOrder.LayoutOrder
            ContainerList.Parent = Container

            for _, opt in pairs(options) do
                local OptBtn = Instance.new("TextButton")
                OptBtn.Size = UDim2.new(1, 0, 0, 26)
                OptBtn.BackgroundColor3 = THEME.Header
                OptBtn.Text = opt
                OptBtn.Font = Enum.Font.Gotham
                OptBtn.TextSize = 11
                OptBtn.TextColor3 = THEME.TextDark
                OptBtn.Parent = Container

                local OptCorner = Instance.new("UICorner")
                OptCorner.CornerRadius = UDim.new(0, 6)
                OptCorner.Parent = OptBtn

                OptBtn.MouseButton1Click:Connect(function()
                    selected = opt
                    SelectedLabel.Text = selected .. "  ▼"
                    dropped = false
                    TweenService:Create(DropFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, 390, 0, 38)}):Play()
                    
                    ConfigData[dropdownText] = selected
                    SaveConfig()

                    pcall(callback, selected)
                end)
            end

            task.spawn(function() pcall(callback, selected) end)

            SelectedLabel.MouseButton1Click:Connect(function()
                dropped = not dropped
                local targetHeight = dropped and (45 + (#options * 30)) or 38
                SelectedLabel.Text = selected .. (dropped and "  ▲" or "  ▼")
                TweenService:Create(DropFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, 390, 0, targetHeight)}):Play()
            end)
        end

        function Elements:CreateSection(sectionName, sectionIconId)
            local SecFrame = Instance.new("Frame")
            SecFrame.Size = UDim2.new(0, 390, 0, 28)
            SecFrame.BackgroundTransparency = 1
            SecFrame.Parent = TabPage

            local SecList = Instance.new("UIListLayout")
            SecList.FillDirection = Enum.FillDirection.Horizontal
            SecList.VerticalAlignment = Enum.VerticalAlignment.Center
            SecList.SortOrder = Enum.SortOrder.LayoutOrder
            SecList.Padding = UDim.new(0, 6)
            SecList.Parent = SecFrame

            local SecPadding = Instance.new("UIPadding")
            SecPadding.PaddingLeft = UDim.new(0, 12)
            SecPadding.Parent = SecFrame

            if sectionIconId then
                local SecIcon = Instance.new("ImageLabel")
                SecIcon.Size = UDim2.new(0, 14, 0, 14)
                SecIcon.BackgroundTransparency = 1
                SecIcon.Image = sectionIconId
                SecIcon.ImageColor3 = THEME.Accent
                SecIcon.Parent = SecFrame
            end

            local Text = Instance.new("TextLabel")
            Text.Size = UDim2.new(1, -20, 1, 0)
            Text.Text = sectionName
            Text.Font = Enum.Font.GothamBold
            Text.TextSize = 11
            Text.TextColor3 = THEME.Accent
            Text.TextXAlignment = Enum.TextXAlignment.Left
            Text.BackgroundTransparency = 1
            Text.Parent = SecFrame
        end

        return Elements
    end

    return Window
end

return Library
