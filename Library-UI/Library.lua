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
    BtnMaximize = Color3.fromRGB(255, 255, 255),
    BtnClose = Color3.fromRGB(235, 55, 75)
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
        Holder.Size = UDim2.new(0, 210, 1, -40)
        Holder.Position = UDim2.new(1, -220, 0, 20)
        Holder.BackgroundTransparency = 1
        Holder.Parent = NotifContainer

        local List = Instance.new("UIListLayout")
        List.Padding = UDim.new(0, 6)
        List.VerticalAlignment = Enum.VerticalAlignment.Bottom
        List.HorizontalAlignment = Enum.HorizontalAlignment.Right
        List.SortOrder = Enum.SortOrder.LayoutOrder
        List.Parent = Holder
    end

    local Holder = NotifContainer.Holder

    local NotifFrame = Instance.new("Frame")
    NotifFrame.Size = UDim2.new(0, 200, 0, 46)
    NotifFrame.BackgroundColor3 = THEME.Card
    NotifFrame.Position = UDim2.new(1, 220, 0, 0)
    NotifFrame.Parent = Holder

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = NotifFrame

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = THEME.Accent
    Stroke.Thickness = 1
    Stroke.Parent = NotifFrame

    local NotifTitle = Instance.new("TextLabel")
    NotifTitle.Size = UDim2.new(1, -16, 0, 16)
    NotifTitle.Position = UDim2.new(0, 8, 0, 4)
    NotifTitle.Text = title or "Thông báo"
    NotifTitle.Font = Enum.Font.GothamBold
    NotifTitle.TextSize = 11
    NotifTitle.TextColor3 = THEME.Accent
    NotifTitle.TextXAlignment = Enum.TextXAlignment.Left
    NotifTitle.BackgroundTransparency = 1
    NotifTitle.Parent = NotifFrame

    local NotifMsg = Instance.new("TextLabel")
    NotifMsg.Size = UDim2.new(1, -16, 0, 20)
    NotifMsg.Position = UDim2.new(0, 8, 0, 20)
    NotifMsg.Text = message or ""
    NotifMsg.Font = Enum.Font.Gotham
    NotifMsg.TextSize = 10
    NotifMsg.TextColor3 = THEME.TextMain
    NotifMsg.TextXAlignment = Enum.TextXAlignment.Left
    NotifMsg.TextWrapped = true
    NotifMsg.BackgroundTransparency = 1
    NotifMsg.Parent = NotifFrame

    TweenService:Create(NotifFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
    
    task.delay(duration, function()
        local hideTween = TweenService:Create(NotifFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, 220, 0, 0)})
        hideTween:Play()
        hideTween.Completed:Connect(function() NotifFrame:Destroy() end)
    end)
end

function Library:CreateWindow(hubTitle, iconAssetId, configFileName)
    iconAssetId = iconAssetId or "rbxassetid://73075320811076"
    configFileName = configFileName or "TVH_Config.json"

    local ConfigData = {}

    local function SaveConfig()
        if writefile then
            pcall(function()
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
    ToggleIcon.Size = UDim2.new(0, 46, 0, 46)
    ToggleIcon.Position = UDim2.new(0, 15, 0.2, 0)
    ToggleIcon.BackgroundColor3 = THEME.Background
    ToggleIcon.Image = iconAssetId
    ToggleIcon.AutoButtonColor = false
    ToggleIcon.Parent = ScreenGui

    local IconCorner = Instance.new("UICorner")
    IconCorner.CornerRadius = UDim.new(1, 0)
    IconCorner.Parent = ToggleIcon

    local IconStroke = Instance.new("UIStroke")
    IconStroke.Thickness = 2.5
    IconStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    IconStroke.Parent = ToggleIcon

    local IconGradient = Instance.new("UIGradient")
    IconGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 128)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 128)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(168, 85, 247))
    })
    IconGradient.Parent = IconStroke

    RunService.RenderStepped:Connect(function(delta)
        IconGradient.Rotation = (IconGradient.Rotation + (140 * delta)) % 360
    end)

    EnableSmoothDrag(ToggleIcon)

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 500, 0, 320)
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -160)
    MainFrame.BackgroundColor3 = THEME.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = false
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = THEME.Border
    MainStroke.Thickness = 1.2
    MainStroke.Parent = MainFrame

    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 38)
    Header.BackgroundColor3 = THEME.Header
    Header.BorderSizePixel = 0
    Header.ZIndex = 2
    Header.Parent = MainFrame

    EnableSmoothDrag(MainFrame, Header)

    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 10)
    HeaderCorner.Parent = Header

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(0, 200, 1, 0)
    TitleLabel.Position = UDim2.new(0, 12, 0, 0)
    TitleLabel.Text = hubTitle or "TVH Hub"
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 14
    TitleLabel.TextColor3 = THEME.TextMain
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.ZIndex = 3
    TitleLabel.Parent = Header

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "CloseBtn"
    CloseBtn.Size = UDim2.new(0, 24, 0, 24)
    CloseBtn.Position = UDim2.new(1, -30, 0.5, -12)
    CloseBtn.BackgroundColor3 = THEME.BtnClose
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 13
    CloseBtn.TextXAlignment = Enum.TextXAlignment.Center
    CloseBtn.TextYAlignment = Enum.TextYAlignment.Center
    CloseBtn.AutoButtonColor = false
    CloseBtn.ZIndex = 100
    CloseBtn.Parent = Header

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseBtn

    local MaximizeBtn = Instance.new("TextButton")
    MaximizeBtn.Name = "MaximizeBtn"
    MaximizeBtn.Size = UDim2.new(0, 24, 0, 24)
    MaximizeBtn.Position = UDim2.new(1, -58, 0.5, -12)
    MaximizeBtn.BackgroundColor3 = THEME.BtnMaximize
    MaximizeBtn.Text = "□"
    MaximizeBtn.TextColor3 = Color3.fromRGB(20, 20, 20)
    MaximizeBtn.Font = Enum.Font.GothamBold
    MaximizeBtn.TextSize = 14
    MaximizeBtn.TextXAlignment = Enum.TextXAlignment.Center
    MaximizeBtn.TextYAlignment = Enum.TextYAlignment.Center
    MaximizeBtn.AutoButtonColor = false
    MaximizeBtn.ZIndex = 100
    MaximizeBtn.Parent = Header

    local MaximizeCorner = Instance.new("UICorner")
    MaximizeCorner.CornerRadius = UDim.new(0, 6)
    MaximizeCorner.Parent = MaximizeBtn


    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Name = "MinimizeBtn"
    MinimizeBtn.Size = UDim2.new(0, 24, 0, 24)
    MinimizeBtn.Position = UDim2.new(1, -86, 0.5, -12)
    MinimizeBtn.BackgroundColor3 = THEME.BtnMinimize
    MinimizeBtn.Text = "-"
    MinimizeBtn.TextColor3 = Color3.fromRGB(20, 20, 20)
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.TextSize = 16
    MinimizeBtn.TextXAlignment = Enum.TextXAlignment.Center
    MinimizeBtn.TextYAlignment = Enum.TextYAlignment.Center
    MinimizeBtn.AutoButtonColor = false
    MinimizeBtn.ZIndex = 100
    MinimizeBtn.Parent = Header

    local MinimizeCorner = Instance.new("UICorner")
    MinimizeCorner.CornerRadius = UDim.new(0, 6)
    MinimizeCorner.Parent = MinimizeBtn


    local isMaximized = false
    local normalSize = MainFrame.Size
    local normalPosition = MainFrame.Position

    MaximizeBtn.MouseButton1Click:Connect(function()
        isMaximized = not isMaximized
        if isMaximized then
            normalSize = MainFrame.Size
            normalPosition = MainFrame.Position

            MaximizeBtn.Text = "❐"
            TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(1, -20, 1, -20),
                Position = UDim2.new(0, 10, 0, 10)
            }):Play()
        else
            MaximizeBtn.Text = "□"
            TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = normalSize,
                Position = normalPosition
            }):Play()
        end
    end)

    local ConfirmOverlay = Instance.new("Frame")
    ConfirmOverlay.Size = UDim2.new(1, 0, 1, 0)
    ConfirmOverlay.BackgroundColor3 = THEME.Overlay
    ConfirmOverlay.BackgroundTransparency = 0.4
    ConfirmOverlay.Visible = false
    ConfirmOverlay.ZIndex = 200
    ConfirmOverlay.Parent = MainFrame

    local ConfirmBox = Instance.new("Frame")
    ConfirmBox.Size = UDim2.new(0, 260, 0, 120)
    ConfirmBox.Position = UDim2.new(0.5, -130, 0.5, -60)
    ConfirmBox.BackgroundColor3 = THEME.Card
    ConfirmBox.ZIndex = 201
    ConfirmBox.Parent = ConfirmOverlay

    local ConfirmCorner = Instance.new("UICorner")
    ConfirmCorner.CornerRadius = UDim.new(0, 8)
    ConfirmCorner.Parent = ConfirmBox

    local ConfirmStroke = Instance.new("UIStroke")
    ConfirmStroke.Color = THEME.Accent
    ConfirmStroke.Thickness = 1
    ConfirmStroke.Parent = ConfirmBox

    local ConfirmTitle = Instance.new("TextLabel")
    ConfirmTitle.Size = UDim2.new(1, 0, 0, 30)
    ConfirmTitle.Position = UDim2.new(0, 0, 0, 10)
    ConfirmTitle.Text = "Xác nhận đóng Window?"
    ConfirmTitle.Font = Enum.Font.GothamBold
    ConfirmTitle.TextSize = 13
    ConfirmTitle.TextColor3 = THEME.TextMain
    ConfirmTitle.BackgroundTransparency = 1
    ConfirmTitle.ZIndex = 202
    ConfirmTitle.Parent = ConfirmBox

    local ConfirmSub = Instance.new("TextLabel")
    ConfirmSub.Size = UDim2.new(1, -20, 0, 20)
    ConfirmSub.Position = UDim2.new(0, 10, 0, 38)
    ConfirmSub.Text = "Bạn có chắc chắn muốn tắt giao diện?"
    ConfirmSub.Font = Enum.Font.Gotham
    ConfirmSub.TextSize = 10
    ConfirmSub.TextColor3 = THEME.TextDark
    ConfirmSub.BackgroundTransparency = 1
    ConfirmSub.ZIndex = 202
    ConfirmSub.Parent = ConfirmBox

    local YesBtn = Instance.new("TextButton")
    YesBtn.Size = UDim2.new(0, 100, 0, 28)
    YesBtn.Position = UDim2.new(0, 20, 1, -38)
    YesBtn.BackgroundColor3 = THEME.BtnClose
    YesBtn.Text = "Đồng ý"
    YesBtn.Font = Enum.Font.GothamBold
    YesBtn.TextSize = 11
    YesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    YesBtn.ZIndex = 202
    YesBtn.Parent = ConfirmBox

    local YesCorner = Instance.new("UICorner")
    YesCorner.CornerRadius = UDim.new(0, 6)
    YesCorner.Parent = YesBtn

    local NoBtn = Instance.new("TextButton")
    NoBtn.Size = UDim2.new(0, 100, 0, 28)
    NoBtn.Position = UDim2.new(1, -120, 1, -38)
    NoBtn.BackgroundColor3 = THEME.Header
    NoBtn.Text = "Hủy"
    NoBtn.Font = Enum.Font.GothamBold
    NoBtn.TextSize = 11
    NoBtn.TextColor3 = THEME.TextMain
    NoBtn.ZIndex = 202
    NoBtn.Parent = ConfirmBox

    local NoCorner = Instance.new("UICorner")
    NoCorner.CornerRadius = UDim.new(0, 6)
    NoCorner.Parent = NoBtn

    CloseBtn.MouseButton1Click:Connect(function()
        ConfirmOverlay.Visible = true
    end)

    YesBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    NoBtn.MouseButton1Click:Connect(function()
        ConfirmOverlay.Visible = false
    end)

    local isOpen = true
    local function ToggleWindow()
        isOpen = not isOpen
        if isOpen then
            MainFrame.Visible = true
            local targetSize = isMaximized and UDim2.new(1, -20, 1, -20) or normalSize
            local targetPos = isMaximized and UDim2.new(0, 10, 0, 10) or normalPosition
            TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = targetSize,
                Position = targetPos
            }):Play()
        else
            local anim = TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
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

    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 130, 1, -38)
    Sidebar.Position = UDim2.new(0, 0, 0, 38)
    Sidebar.BackgroundColor3 = THEME.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame

    local SidebarList = Instance.new("UIListLayout")
    SidebarList.Padding = UDim.new(0, 4)
    SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
    SidebarList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    SidebarList.Parent = Sidebar

    local SidebarPadding = Instance.new("UIPadding")
    SidebarPadding.PaddingTop = UDim.new(0, 8)
    SidebarPadding.Parent = Sidebar

    local ContentArea = Instance.new("Frame")
    ContentArea.Size = UDim2.new(1, -130, 1, -38)
    ContentArea.Position = UDim2.new(0, 130, 0, 38)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = MainFrame

    local Window = {}
    local tabs = {}

    function Window:CreateTab(tabName, tabIconId)
        tabIconId = tabIconId or "rbxassetid://73075320811076"

        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(0, 114, 0, 32)
        TabBtn.BackgroundColor3 = THEME.Card
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = ""
        TabBtn.AutoButtonColor = false
        TabBtn.Parent = Sidebar

        local TabBtnCorner = Instance.new("UICorner")
        TabBtnCorner.CornerRadius = UDim.new(0, 6)
        TabBtnCorner.Parent = TabBtn

        local TabList = Instance.new("UIListLayout")
        TabList.FillDirection = Enum.FillDirection.Horizontal
        TabList.VerticalAlignment = Enum.VerticalAlignment.Center
        TabList.SortOrder = Enum.SortOrder.LayoutOrder
        TabList.Padding = UDim.new(0, 6)
        TabList.Parent = TabBtn

        local TabPadding = Instance.new("UIPadding")
        TabPadding.PaddingLeft = UDim.new(0, 8)
        TabPadding.Parent = TabBtn

        local TabIcon = Instance.new("ImageLabel")
        TabIcon.Size = UDim2.new(0, 16, 0, 16)
        TabIcon.BackgroundTransparency = 1
        TabIcon.Image = tabIconId
        TabIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
        TabIcon.Parent = TabBtn

        local TabLabel = Instance.new("TextLabel")
        TabLabel.Size = UDim2.new(1, -26, 1, 0)
        TabLabel.BackgroundTransparency = 1
        TabLabel.Text = tabName
        TabLabel.Font = Enum.Font.GothamMedium
        TabLabel.TextSize = 11
        TabLabel.TextColor3 = THEME.TextDark
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabLabel.Parent = TabBtn

        local TabPage = Instance.new("ScrollingFrame")
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundTransparency = 1
        TabPage.Visible = false
        TabPage.ScrollBarThickness = 2
        TabPage.ScrollBarImageColor3 = THEME.Accent
        TabPage.Parent = ContentArea

        local PageList = Instance.new("UIListLayout")
        PageList.Padding = UDim.new(0, 6)
        PageList.SortOrder = Enum.SortOrder.LayoutOrder
        PageList.HorizontalAlignment = Enum.HorizontalAlignment.Center
        PageList.Parent = TabPage

        local PagePadding = Instance.new("UIPadding")
        PagePadding.PaddingTop = UDim.new(0, 8)
        PagePadding.PaddingBottom = UDim.new(0, 8)
        PagePadding.Parent = TabPage

        PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabPage.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 16)
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
            ButtonFrame.Size = UDim2.new(1, -20, 0, 32)
            ButtonFrame.BackgroundColor3 = THEME.Card
            ButtonFrame.Text = btnText
            ButtonFrame.Font = Enum.Font.GothamMedium
            ButtonFrame.TextSize = 11
            ButtonFrame.TextColor3 = THEME.TextMain
            ButtonFrame.AutoButtonColor = false
            ButtonFrame.Parent = TabPage

            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 6)
            Corner.Parent = ButtonFrame

            ButtonFrame.MouseButton1Click:Connect(function()
                pcall(callback)
            end)
        end

        function Elements:CreateToggle(toggleText, defaultState, callback)
            callback = callback or function() end
            
            local toggled = defaultState or false
            if ConfigData[toggleText] ~= nil then
                toggled = ConfigData[toggleText]
            else
                ConfigData[toggleText] = toggled
            end

            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Size = UDim2.new(1, -20, 0, 32)
            ToggleFrame.BackgroundColor3 = THEME.Card
            ToggleFrame.Parent = TabPage

            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 6)
            Corner.Parent = ToggleFrame

            local Title = Instance.new("TextLabel")
            Title.Size = UDim2.new(1, -60, 1, 0)
            Title.Position = UDim2.new(0, 10, 0, 0)
            Title.Text = toggleText
            Title.Font = Enum.Font.GothamMedium
            Title.TextSize = 11
            Title.TextColor3 = THEME.TextMain
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.BackgroundTransparency = 1
            Title.Parent = ToggleFrame

            local Switch = Instance.new("TextButton")
            Switch.Size = UDim2.new(0, 36, 0, 18)
            Switch.Position = UDim2.new(1, -44, 0.5, -9)
            Switch.BackgroundColor3 = toggled and THEME.Accent or THEME.Header
            Switch.Text = ""
            Switch.Parent = ToggleFrame

            local SwitchCorner = Instance.new("UICorner")
            SwitchCorner.CornerRadius = UDim.new(1, 0)
            SwitchCorner.Parent = Switch

            local Knob = Instance.new("Frame")
            Knob.Size = UDim2.new(0, 14, 0, 14)
            Knob.Position = toggled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
            Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Knob.Parent = Switch

            local KnobCorner = Instance.new("UICorner")
            KnobCorner.CornerRadius = UDim.new(1, 0)
            KnobCorner.Parent = Knob

            local function FireToggle(state)
                local targetPos = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
                local targetColor = state and THEME.Accent or THEME.Header
                TweenService:Create(Knob, TweenInfo.new(0.15), {Position = targetPos}):Play()
                TweenService:Create(Switch, TweenInfo.new(0.15), {BackgroundColor3 = targetColor}):Play()
                
                ConfigData[toggleText] = state
                SaveConfig()

                pcall(callback, state)
            end

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
            SliderFrame.Size = UDim2.new(1, -20, 0, 42)
            SliderFrame.BackgroundColor3 = THEME.Card
            SliderFrame.Parent = TabPage

            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 6)
            Corner.Parent = SliderFrame

            local Title = Instance.new("TextLabel")
            Title.Size = UDim2.new(1, -70, 0, 20)
            Title.Position = UDim2.new(0, 10, 0, 2)
            Title.Text = sliderText
            Title.Font = Enum.Font.GothamMedium
            Title.TextSize = 11
            Title.TextColor3 = THEME.TextMain
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.BackgroundTransparency = 1
            Title.Parent = SliderFrame

            local ValLabel = Instance.new("TextLabel")
            ValLabel.Size = UDim2.new(0, 50, 0, 20)
            ValLabel.Position = UDim2.new(1, -58, 0, 2)
            ValLabel.Text = tostring(value)
            ValLabel.Font = Enum.Font.GothamBold
            ValLabel.TextSize = 10
            ValLabel.TextColor3 = THEME.Accent
            ValLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValLabel.BackgroundTransparency = 1
            ValLabel.Parent = SliderFrame

            local Bar = Instance.new("Frame")
            Bar.Size = UDim2.new(1, -20, 0, 5)
            Bar.Position = UDim2.new(0, 10, 1, -12)
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
            DropFrame.Size = UDim2.new(1, -20, 0, 32)
            DropFrame.BackgroundColor3 = THEME.Card
            DropFrame.ClipsDescendants = true
            DropFrame.Parent = TabPage

            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 6)
            Corner.Parent = DropFrame

            local Title = Instance.new("TextLabel")
            Title.Size = UDim2.new(1, -140, 0, 32)
            Title.Position = UDim2.new(0, 10, 0, 0)
            Title.Text = dropdownText
            Title.Font = Enum.Font.GothamMedium
            Title.TextSize = 11
            Title.TextColor3 = THEME.TextMain
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.BackgroundTransparency = 1
            Title.Parent = DropFrame

            local SelectedLabel = Instance.new("TextButton")
            SelectedLabel.Size = UDim2.new(0, 120, 0, 22)
            SelectedLabel.Position = UDim2.new(1, -128, 0, 5)
            SelectedLabel.BackgroundColor3 = THEME.Header
            SelectedLabel.Text = selected .. "  v"
            SelectedLabel.Font = Enum.Font.Gotham
            SelectedLabel.TextSize = 10
            SelectedLabel.TextColor3 = THEME.Accent
            SelectedLabel.Parent = DropFrame

            local SelCorner = Instance.new("UICorner")
            SelCorner.CornerRadius = UDim.new(0, 4)
            SelCorner.Parent = SelectedLabel

            local Container = Instance.new("Frame")
            Container.Size = UDim2.new(1, -20, 0, 0)
            Container.Position = UDim2.new(0, 10, 0, 34)
            Container.BackgroundTransparency = 1
            Container.Parent = DropFrame

            local ContainerList = Instance.new("UIListLayout")
            ContainerList.Padding = UDim.new(0, 3)
            ContainerList.SortOrder = Enum.SortOrder.LayoutOrder
            ContainerList.Parent = Container

            for _, opt in pairs(options) do
                local OptBtn = Instance.new("TextButton")
                OptBtn.Size = UDim2.new(1, 0, 0, 22)
                OptBtn.BackgroundColor3 = THEME.Header
                OptBtn.Text = opt
                OptBtn.Font = Enum.Font.Gotham
                OptBtn.TextSize = 10
                OptBtn.TextColor3 = THEME.TextDark
                OptBtn.Parent = Container

                local OptCorner = Instance.new("UICorner")
                OptCorner.CornerRadius = UDim.new(0, 4)
                OptCorner.Parent = OptBtn

                OptBtn.MouseButton1Click:Connect(function()
                    selected = opt
                    SelectedLabel.Text = selected .. "  v"
                    dropped = false
                    TweenService:Create(DropFrame, TweenInfo.new(0.15), {Size = UDim2.new(1, -20, 0, 32)}):Play()
                    
                    ConfigData[dropdownText] = selected
                    SaveConfig()

                    pcall(callback, selected)
                end)
            end

            task.spawn(function() pcall(callback, selected) end)

            SelectedLabel.MouseButton1Click:Connect(function()
                dropped = not dropped
                local targetHeight = dropped and (38 + (#options * 25)) or 32
                SelectedLabel.Text = selected .. (dropped and "  ^" or "  v")
                TweenService:Create(DropFrame, TweenInfo.new(0.15), {Size = UDim2.new(1, -20, 0, targetHeight)}):Play()
            end)
        end

        function Elements:CreateSection(sectionName, sectionIconId)
            local SecFrame = Instance.new("Frame")
            SecFrame.Size = UDim2.new(1, -20, 0, 24)
            SecFrame.BackgroundTransparency = 1
            SecFrame.Parent = TabPage

            local SecList = Instance.new("UIListLayout")
            SecList.FillDirection = Enum.FillDirection.Horizontal
            SecList.VerticalAlignment = Enum.VerticalAlignment.Center
            SecList.SortOrder = Enum.SortOrder.LayoutOrder
            SecList.Padding = UDim.new(0, 5)
            SecList.Parent = SecFrame

            local SecPadding = Instance.new("UIPadding")
            SecPadding.PaddingLeft = UDim.new(0, 10)
            SecPadding.Parent = SecFrame

            if sectionIconId then
                local SecIcon = Instance.new("ImageLabel")
                SecIcon.Size = UDim2.new(0, 12, 0, 12)
                SecIcon.BackgroundTransparency = 1
                SecIcon.Image = sectionIconId
                SecIcon.ImageColor3 = THEME.Accent
                SecIcon.Parent = SecFrame
            end

            local Text = Instance.new("TextLabel")
            Text.Size = UDim2.new(1, -20, 1, 0)
            Text.Text = sectionName
            Text.Font = Enum.Font.GothamBold
            Text.TextSize = 10
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
