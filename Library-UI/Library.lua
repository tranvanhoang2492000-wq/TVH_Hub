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
        local parentSize = frame.Parent and frame.Parent.AbsoluteSize or Vector2.new(1920, 1080)
        local deltaScaleX = delta.X / parentSize.X
        local deltaScaleY = delta.Y / parentSize.Y

        frame.Position = UDim2.new(
            startPos.X.Scale + deltaScaleX, 0,
            startPos.Y.Scale + deltaScaleY, 0
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
        Holder.Size = UDim2.new(0.25, 0, 0.95, 0)
        Holder.Position = UDim2.new(0.73, 0, 0.02, 0)
        Holder.BackgroundTransparency = 1
        Holder.Parent = NotifContainer

        local List = Instance.new("UIListLayout")
        List.Padding = UDim.new(0.015, 0)
        List.VerticalAlignment = Enum.VerticalAlignment.Bottom
        List.HorizontalAlignment = Enum.HorizontalAlignment.Right
        List.SortOrder = Enum.SortOrder.LayoutOrder
        List.Parent = Holder
    end

    local Holder = NotifContainer.Holder

    local NotifFrame = Instance.new("Frame")
    NotifFrame.AutomaticSize = Enum.AutomaticSize.Y
    NotifFrame.Size = UDim2.new(1, 0, 0, 0)
    NotifFrame.BackgroundColor3 = THEME.Card
    NotifFrame.Position = UDim2.new(1.5, 0, 0, 0)
    NotifFrame.Parent = Holder

    local NotifPadding = Instance.new("UIPadding")
    NotifPadding.PaddingTop = UDim.new(0.05, 0)
    NotifPadding.PaddingBottom = UDim.new(0.05, 0)
    NotifPadding.PaddingLeft = UDim.new(0.04, 0)
    NotifPadding.PaddingRight = UDim.new(0.04, 0)
    NotifPadding.Parent = NotifFrame

    local NotifList = Instance.new("UIListLayout")
    NotifList.SortOrder = Enum.SortOrder.LayoutOrder
    NotifList.Padding = UDim.new(0.02, 0)
    NotifList.Parent = NotifFrame

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0.12, 0)
    Corner.Parent = NotifFrame

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = THEME.Accent
    Stroke.Thickness = 1
    Stroke.Parent = NotifFrame

    local NotifTitle = Instance.new("TextLabel")
    NotifTitle.AutomaticSize = Enum.AutomaticSize.Y
    NotifTitle.Size = UDim2.new(1, 0, 0, 0)
    NotifTitle.Text = title or "Thông báo"
    NotifTitle.Font = Enum.Font.GothamBold
    NotifTitle.TextSize = 13
    NotifTitle.TextColor3 = THEME.Accent
    NotifTitle.TextXAlignment = Enum.TextXAlignment.Left
    NotifTitle.BackgroundTransparency = 1
    NotifTitle.Parent = NotifFrame

    local NotifMsg = Instance.new("TextLabel")
    NotifMsg.AutomaticSize = Enum.AutomaticSize.Y
    NotifMsg.Size = UDim2.new(1, 0, 0, 0)
    NotifMsg.Text = message or ""
    NotifMsg.Font = Enum.Font.Gotham
    NotifMsg.TextSize = 11
    NotifMsg.TextColor3 = THEME.TextMain
    NotifMsg.TextXAlignment = Enum.TextXAlignment.Left
    NotifMsg.TextWrapped = true
    NotifMsg.BackgroundTransparency = 1
    NotifMsg.Parent = NotifFrame

    TweenService:Create(NotifFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
    
    task.delay(duration, function()
        local hideTween = TweenService:Create(NotifFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1.5, 0, 0, 0)})
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
    ToggleIcon.Size = UDim2.new(0.05, 0, 0.088, 0)
    ToggleIcon.Position = UDim2.new(0.02, 0, 0.2, 0)
    ToggleIcon.BackgroundColor3 = THEME.Background
    ToggleIcon.Image = iconAssetId
    ToggleIcon.AutoButtonColor = false
    ToggleIcon.Parent = ScreenGui

    local ToggleAspect = Instance.new("UIAspectRatioConstraint")
    ToggleAspect.AspectRatio = 1
    ToggleAspect.Parent = ToggleIcon

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
    MainFrame.Size = UDim2.new(0.45, 0, 0.55, 0)
    MainFrame.Position = UDim2.new(0.275, 0, 0.225, 0)
    MainFrame.BackgroundColor3 = THEME.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = false
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0.02, 0)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = THEME.Border
    MainStroke.Thickness = 1.2
    MainStroke.Parent = MainFrame

    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0.12, 0)
    Header.BackgroundColor3 = THEME.Header
    Header.BorderSizePixel = 0
    Header.ZIndex = 2
    Header.Parent = MainFrame

    EnableSmoothDrag(MainFrame, Header)

    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0.15, 0)
    HeaderCorner.Parent = Header

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(0.4, 0, 1, 0)
    TitleLabel.Position = UDim2.new(0.03, 0, 0, 0)
    TitleLabel.Text = hubTitle or "TVH Hub"
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextScaled = true
    TitleLabel.TextColor3 = THEME.TextMain
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.ZIndex = 3
    TitleLabel.Parent = Header

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "CloseBtn"
    CloseBtn.Size = UDim2.new(0.05, 0, 0.65, 0)
    CloseBtn.Position = UDim2.new(0.93, 0, 0.175, 0)
    CloseBtn.BackgroundColor3 = THEME.BtnClose
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextScaled = true
    CloseBtn.TextXAlignment = Enum.TextXAlignment.Center
    CloseBtn.TextYAlignment = Enum.TextYAlignment.Center
    CloseBtn.AutoButtonColor = false
    CloseBtn.ZIndex = 100
    CloseBtn.Parent = Header

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0.2, 0)
    CloseCorner.Parent = CloseBtn

    local MaximizeBtn = Instance.new("TextButton")
    MaximizeBtn.Name = "MaximizeBtn"
    MaximizeBtn.Size = UDim2.new(0.05, 0, 0.65, 0)
    MaximizeBtn.Position = UDim2.new(0.87, 0, 0.175, 0)
    MaximizeBtn.BackgroundColor3 = THEME.BtnMaximize
    MaximizeBtn.Text = "□"
    MaximizeBtn.TextColor3 = Color3.fromRGB(20, 20, 20)
    MaximizeBtn.Font = Enum.Font.GothamBold
    MaximizeBtn.TextScaled = true
    MaximizeBtn.TextXAlignment = Enum.TextXAlignment.Center
    MaximizeBtn.TextYAlignment = Enum.TextYAlignment.Center
    MaximizeBtn.AutoButtonColor = false
    MaximizeBtn.ZIndex = 100
    MaximizeBtn.Parent = Header

    local MaximizeCorner = Instance.new("UICorner")
    MaximizeCorner.CornerRadius = UDim.new(0.2, 0)
    MaximizeCorner.Parent = MaximizeBtn

    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Name = "MinimizeBtn"
    MinimizeBtn.Size = UDim2.new(0.05, 0, 0.65, 0)
    MinimizeBtn.Position = UDim2.new(0.81, 0, 0.175, 0)
    MinimizeBtn.BackgroundColor3 = THEME.BtnMinimize
    MinimizeBtn.Text = "-"
    MinimizeBtn.TextColor3 = Color3.fromRGB(20, 20, 20)
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.TextScaled = true
    MinimizeBtn.TextXAlignment = Enum.TextXAlignment.Center
    MinimizeBtn.TextYAlignment = Enum.TextYAlignment.Center
    MinimizeBtn.AutoButtonColor = false
    MinimizeBtn.ZIndex = 100
    MinimizeBtn.Parent = Header

    local MinimizeCorner = Instance.new("UICorner")
    MinimizeCorner.CornerRadius = UDim.new(0.2, 0)
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
                Size = UDim2.new(0.96, 0, 0.96, 0),
                Position = UDim2.new(0.02, 0, 0.02, 0)
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
    ConfirmBox.Size = UDim2.new(0.5, 0, 0.38, 0)
    ConfirmBox.Position = UDim2.new(0.25, 0, 0.31, 0)
    ConfirmBox.BackgroundColor3 = THEME.Card
    ConfirmBox.ZIndex = 201
    ConfirmBox.Parent = ConfirmOverlay

    local ConfirmCorner = Instance.new("UICorner")
    ConfirmCorner.CornerRadius = UDim.new(0.08, 0)
    ConfirmCorner.Parent = ConfirmBox

    local ConfirmStroke = Instance.new("UIStroke")
    ConfirmStroke.Color = THEME.Accent
    ConfirmStroke.Thickness = 1
    ConfirmStroke.Parent = ConfirmBox

    local ConfirmTitle = Instance.new("TextLabel")
    ConfirmTitle.Size = UDim2.new(1, 0, 0.25, 0)
    ConfirmTitle.Position = UDim2.new(0, 0, 0.08, 0)
    ConfirmTitle.Text = "Xác nhận đóng Window?"
    ConfirmTitle.Font = Enum.Font.GothamBold
    ConfirmTitle.TextScaled = true
    ConfirmTitle.TextColor3 = THEME.TextMain
    ConfirmTitle.BackgroundTransparency = 1
    ConfirmTitle.ZIndex = 202
    ConfirmTitle.Parent = ConfirmBox

    local ConfirmSub = Instance.new("TextLabel")
    ConfirmSub.Size = UDim2.new(0.9, 0, 0.2, 0)
    ConfirmSub.Position = UDim2.new(0.05, 0, 0.35, 0)
    ConfirmSub.Text = "Bạn có chắc chắn muốn tắt giao diện?"
    ConfirmSub.Font = Enum.Font.Gotham
    ConfirmSub.TextScaled = true
    ConfirmSub.TextColor3 = THEME.TextDark
    ConfirmSub.BackgroundTransparency = 1
    ConfirmSub.ZIndex = 202
    ConfirmSub.Parent = ConfirmBox

    local YesBtn = Instance.new("TextButton")
    YesBtn.Size = UDim2.new(0.38, 0, 0.23, 0)
    YesBtn.Position = UDim2.new(0.08, 0, 0.68, 0)
    YesBtn.BackgroundColor3 = THEME.BtnClose
    YesBtn.Text = "Đồng ý"
    YesBtn.Font = Enum.Font.GothamBold
    YesBtn.TextScaled = true
    YesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    YesBtn.ZIndex = 202
    YesBtn.Parent = ConfirmBox

    local YesCorner = Instance.new("UICorner")
    YesCorner.CornerRadius = UDim.new(0.2, 0)
    YesCorner.Parent = YesBtn

    local NoBtn = Instance.new("TextButton")
    NoBtn.Size = UDim2.new(0.38, 0, 0.23, 0)
    NoBtn.Position = UDim2.new(0.54, 0, 0.68, 0)
    NoBtn.BackgroundColor3 = THEME.Header
    NoBtn.Text = "Hủy"
    NoBtn.Font = Enum.Font.GothamBold
    NoBtn.TextScaled = true
    NoBtn.TextColor3 = THEME.TextMain
    NoBtn.ZIndex = 202
    NoBtn.Parent = ConfirmBox

    local NoCorner = Instance.new("UICorner")
    NoCorner.CornerRadius = UDim.new(0.2, 0)
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
            local targetSize = isMaximized and UDim2.new(0.96, 0, 0.96, 0) or normalSize
            local targetPos = isMaximized and UDim2.new(0.02, 0, 0.02, 0) or normalPosition
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
    Sidebar.Size = UDim2.new(0.26, 0, 0.88, 0)
    Sidebar.Position = UDim2.new(0, 0, 0.12, 0)
    Sidebar.BackgroundColor3 = THEME.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame

    local SidebarList = Instance.new("UIListLayout")
    SidebarList.Padding = UDim.new(0.012, 0)
    SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
    SidebarList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    SidebarList.Parent = Sidebar

    local SidebarPadding = Instance.new("UIPadding")
    SidebarPadding.PaddingTop = UDim.new(0.025, 0)
    SidebarPadding.Parent = Sidebar

    local ContentArea = Instance.new("Frame")
    ContentArea.Size = UDim2.new(0.74, 0, 0.88, 0)
    ContentArea.Position = UDim2.new(0.26, 0, 0.12, 0)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = MainFrame

    local Window = {}
    local tabs = {}

    function Window:CreateTab(tabName, tabIconId)
        tabIconId = tabIconId or "rbxassetid://73075320811076"

        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(0.88, 0, 0.1, 0)
        TabBtn.BackgroundColor3 = THEME.Card
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = ""
        TabBtn.AutoButtonColor = false
        TabBtn.Parent = Sidebar

        local TabBtnCorner = Instance.new("UICorner")
        TabBtnCorner.CornerRadius = UDim.new(0.18, 0)
        TabBtnCorner.Parent = TabBtn

        local TabList = Instance.new("UIListLayout")
        TabList.FillDirection = Enum.FillDirection.Horizontal
        TabList.VerticalAlignment = Enum.VerticalAlignment.Center
        TabList.SortOrder = Enum.SortOrder.LayoutOrder
        TabList.Padding = UDim.new(0.05, 0)
        TabList.Parent = TabBtn

        local TabPadding = Instance.new("UIPadding")
        TabPadding.PaddingLeft = UDim.new(0.07, 0)
        TabPadding.Parent = TabBtn

        local TabIcon = Instance.new("ImageLabel")
        TabIcon.Size = UDim2.new(0.15, 0, 0.5, 0)
        TabIcon.BackgroundTransparency = 1
        TabIcon.Image = tabIconId
        TabIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
        TabIcon.Parent = TabBtn

        local TabLabel = Instance.new("TextLabel")
        TabLabel.Size = UDim2.new(0.75, 0, 0.6, 0)
        TabLabel.BackgroundTransparency = 1
        TabLabel.Text = tabName
        TabLabel.Font = Enum.Font.GothamMedium
        TabLabel.TextScaled = true
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
        PageList.Padding = UDim.new(0.02, 0)
        PageList.SortOrder = Enum.SortOrder.LayoutOrder
        PageList.HorizontalAlignment = Enum.HorizontalAlignment.Center
        PageList.Parent = TabPage

        local PagePadding = Instance.new("UIPadding")
        PagePadding.PaddingTop = UDim.new(0.025, 0)
        PagePadding.PaddingBottom = UDim.new(0.025, 0)
        PagePadding.Parent = TabPage

        -- Tự động tính toán độ dài ScrollingFrame khi phần tử bên trong thay đổi
        PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabPage.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 20)
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
            ButtonFrame.AutomaticSize = Enum.AutomaticSize.Y
            ButtonFrame.Size = UDim2.new(0.95, 0, 0, 0)
            ButtonFrame.BackgroundColor3 = THEME.Card
            ButtonFrame.Text = ""
            ButtonFrame.AutoButtonColor = false
            ButtonFrame.Parent = TabPage

            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0.18, 0)
            Corner.Parent = ButtonFrame

            local Padding = Instance.new("UIPadding")
            Padding.PaddingTop = UDim.new(0.03, 0)
            Padding.PaddingBottom = UDim.new(0.03, 0)
            Padding.Parent = ButtonFrame

            local TextLabel = Instance.new("TextLabel")
            TextLabel.AutomaticSize = Enum.AutomaticSize.Y
            TextLabel.Size = UDim2.new(1, 0, 0, 0)
            TextLabel.Text = btnText
            TextLabel.Font = Enum.Font.GothamMedium
            TextLabel.TextSize = 12
            TextLabel.TextColor3 = THEME.TextMain
            TextLabel.BackgroundTransparency = 1
            TextLabel.Parent = ButtonFrame

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
            ToggleFrame.AutomaticSize = Enum.AutomaticSize.Y
            ToggleFrame.Size = UDim2.new(0.95, 0, 0, 0)
            ToggleFrame.BackgroundColor3 = THEME.Card
            ToggleFrame.Parent = TabPage

            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0.18, 0)
            Corner.Parent = ToggleFrame

            local Padding = Instance.new("UIPadding")
            Padding.PaddingTop = UDim.new(0.03, 0)
            Padding.PaddingBottom = UDim.new(0.03, 0)
            Padding.PaddingLeft = UDim.new(0.03, 0)
            Padding.PaddingRight = UDim.new(0.03, 0)
            Padding.Parent = ToggleFrame

            local Title = Instance.new("TextLabel")
            Title.AutomaticSize = Enum.AutomaticSize.Y
            Title.Size = UDim2.new(0.8, 0, 0, 0)
            Title.Position = UDim2.new(0, 0, 0, 0)
            Title.Text = toggleText
            Title.Font = Enum.Font.GothamMedium
            Title.TextSize = 12
            Title.TextColor3 = THEME.TextMain
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.BackgroundTransparency = 1
            Title.Parent = ToggleFrame

            local Switch = Instance.new("TextButton")
            Switch.Size = UDim2.new(0.12, 0, 0.8, 0)
            Switch.Position = UDim2.new(0.85, 0, 0.1, 0)
            Switch.BackgroundColor3 = toggled and THEME.Accent or THEME.Header
            Switch.Text = ""
            Switch.Parent = ToggleFrame

            local SwitchCorner = Instance.new("UICorner")
            SwitchCorner.CornerRadius = UDim.new(1, 0)
            SwitchCorner.Parent = Switch

            local Knob = Instance.new("Frame")
            Knob.Size = UDim2.new(0.4, 0, 0.8, 0)
            Knob.Position = toggled and UDim2.new(0.55, 0, 0.1, 0) or UDim2.new(0.05, 0, 0.1, 0)
            Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Knob.Parent = Switch

            local KnobCorner = Instance.new("UICorner")
            KnobCorner.CornerRadius = UDim.new(1, 0)
            KnobCorner.Parent = Knob

            local function FireToggle(state)
                local targetPos = state and UDim2.new(0.55, 0, 0.1, 0) or UDim2.new(0.05, 0, 0.1, 0)
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
            SliderFrame.AutomaticSize = Enum.AutomaticSize.Y
            SliderFrame.Size = UDim2.new(0.95, 0, 0, 0)
            SliderFrame.BackgroundColor3 = THEME.Card
            SliderFrame.Parent = TabPage

            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0.14, 0)
            Corner.Parent = SliderFrame

            local List = Instance.new("UIListLayout")
            List.SortOrder = Enum.SortOrder.LayoutOrder
            List.Padding = UDim.new(0.02, 0)
            List.Parent = SliderFrame

            local Padding = Instance.new("UIPadding")
            Padding.PaddingTop = UDim.new(0.03, 0)
            Padding.PaddingBottom = UDim.new(0.03, 0)
            Padding.PaddingLeft = UDim.new(0.03, 0)
            Padding.PaddingRight = UDim.new(0.03, 0)
            Padding.Parent = SliderFrame

            local TopHolder = Instance.new("Frame")
            TopHolder.AutomaticSize = Enum.AutomaticSize.Y
            TopHolder.Size = UDim2.new(1, 0, 0, 0)
            TopHolder.BackgroundTransparency = 1
            TopHolder.Parent = SliderFrame

            local Title = Instance.new("TextLabel")
            Title.AutomaticSize = Enum.AutomaticSize.Y
            Title.Size = UDim2.new(0.7, 0, 0, 0)
            Title.Text = sliderText
            Title.Font = Enum.Font.GothamMedium
            Title.TextSize = 12
            Title.TextColor3 = THEME.TextMain
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.BackgroundTransparency = 1
            Title.Parent = TopHolder

            local ValLabel = Instance.new("TextLabel")
            ValLabel.AutomaticSize = Enum.AutomaticSize.Y
            ValLabel.Size = UDim2.new(0.25, 0, 0, 0)
            ValLabel.Position = UDim2.new(0.75, 0, 0, 0)
            ValLabel.Text = tostring(value)
            ValLabel.Font = Enum.Font.GothamBold
            ValLabel.TextSize = 12
            ValLabel.TextColor3 = THEME.Accent
            ValLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValLabel.BackgroundTransparency = 1
            ValLabel.Parent = TopHolder

            local Bar = Instance.new("Frame")
            Bar.Size = UDim2.new(1, 0, 0.05, 0)
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
            DropFrame.AutomaticSize = Enum.AutomaticSize.Y
            DropFrame.Size = UDim2.new(0.95, 0, 0, 0)
            DropFrame.BackgroundColor3 = THEME.Card
            DropFrame.ClipsDescendants = true
            DropFrame.Parent = TabPage

            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0.18, 0)
            Corner.Parent = DropFrame

            local List = Instance.new("UIListLayout")
            List.SortOrder = Enum.SortOrder.LayoutOrder
            List.Padding = UDim.new(0.02, 0)
            List.Parent = DropFrame

            local Padding = Instance.new("UIPadding")
            Padding.PaddingTop = UDim.new(0.03, 0)
            Padding.PaddingBottom = UDim.new(0.03, 0)
            Padding.PaddingLeft = UDim.new(0.03, 0)
            Padding.PaddingRight = UDim.new(0.03, 0)
            Padding.Parent = DropFrame

            local TopHolder = Instance.new("Frame")
            TopHolder.AutomaticSize = Enum.AutomaticSize.Y
            TopHolder.Size = UDim2.new(1, 0, 0, 0)
            TopHolder.BackgroundTransparency = 1
            TopHolder.Parent = DropFrame

            local Title = Instance.new("TextLabel")
            Title.AutomaticSize = Enum.AutomaticSize.Y
            Title.Size = UDim2.new(0.6, 0, 0, 0)
            Title.Text = dropdownText
            Title.Font = Enum.Font.GothamMedium
            Title.TextSize = 12
            Title.TextColor3 = THEME.TextMain
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.BackgroundTransparency = 1
            Title.Parent = TopHolder

            local SelectedLabel = Instance.new("TextButton")
            SelectedLabel.AutomaticSize = Enum.AutomaticSize.Y
            SelectedLabel.Size = UDim2.new(0.35, 0, 0, 0)
            SelectedLabel.Position = UDim2.new(0.65, 0, 0, 0)
            SelectedLabel.BackgroundColor3 = THEME.Header
            SelectedLabel.Text = selected .. "  v"
            SelectedLabel.Font = Enum.Font.Gotham
            SelectedLabel.TextSize = 11
            SelectedLabel.TextColor3 = THEME.Accent
            SelectedLabel.Parent = TopHolder

            local SelCorner = Instance.new("UICorner")
            SelCorner.CornerRadius = UDim.new(0.18, 0)
            SelCorner.Parent = SelectedLabel

            local Container = Instance.new("Frame")
            Container.AutomaticSize = Enum.AutomaticSize.Y
            Container.Size = UDim2.new(1, 0, 0, 0)
            Container.BackgroundTransparency = 1
            Container.Visible = false
            Container.Parent = DropFrame

            local ContainerList = Instance.new("UIListLayout")
            ContainerList.Padding = UDim.new(0.02, 0)
            ContainerList.SortOrder = Enum.SortOrder.LayoutOrder
            ContainerList.Parent = Container

            for _, opt in pairs(options) do
                local OptBtn = Instance.new("TextButton")
                OptBtn.AutomaticSize = Enum.AutomaticSize.Y
                OptBtn.Size = UDim2.new(1, 0, 0, 0)
                OptBtn.BackgroundColor3 = THEME.Header
                OptBtn.Text = opt
                OptBtn.Font = Enum.Font.Gotham
                OptBtn.TextSize = 11
                OptBtn.TextColor3 = THEME.TextDark
                OptBtn.Parent = Container

                local OptCorner = Instance.new("UICorner")
                OptCorner.CornerRadius = UDim.new(0.18, 0)
                OptCorner.Parent = OptBtn

                OptBtn.MouseButton1Click:Connect(function()
                    selected = opt
                    SelectedLabel.Text = selected .. "  v"
                    dropped = false
                    Container.Visible = false
                    
                    ConfigData[dropdownText] = selected
                    SaveConfig()

                    pcall(callback, selected)
                end)
            end

            task.spawn(function() pcall(callback, selected) end)

            SelectedLabel.MouseButton1Click:Connect(function()
                dropped = not dropped
                Container.Visible = dropped
                SelectedLabel.Text = selected .. (dropped and "  ^" or "  v")
            end)
        end

        function Elements:CreateSection(sectionName, sectionIconId)
            local SecFrame = Instance.new("Frame")
            SecFrame.AutomaticSize = Enum.AutomaticSize.Y
            SecFrame.Size = UDim2.new(0.95, 0, 0, 0)
            SecFrame.BackgroundTransparency = 1
            SecFrame.Parent = TabPage

            local SecList = Instance.new("UIListLayout")
            SecList.FillDirection = Enum.FillDirection.Horizontal
            SecList.VerticalAlignment = Enum.VerticalAlignment.Center
            SecList.SortOrder = Enum.SortOrder.LayoutOrder
            SecList.Padding = UDim.new(0.02, 0)
            SecList.Parent = SecFrame

            local SecPadding = Instance.new("UIPadding")
            SecPadding.PaddingLeft = UDim.new(0.03, 0)
            SecPadding.Parent = SecFrame

            if sectionIconId then
                local SecIcon = Instance.new("ImageLabel")
                SecIcon.Size = UDim2.new(0.05, 0, 0.05, 0)
                SecIcon.BackgroundTransparency = 1
                SecIcon.Image = sectionIconId
                SecIcon.ImageColor3 = THEME.Accent
                SecIcon.Parent = SecFrame
                
                local Aspect = Instance.new("UIAspectRatioConstraint")
                Aspect.AspectRatio = 1
                Aspect.Parent = SecIcon
            end

            local Text = Instance.new("TextLabel")
            Text.AutomaticSize = Enum.AutomaticSize.Y
            Text.Size = UDim2.new(0.9, 0, 0, 0)
            Text.Text = sectionName
            Text.Font = Enum.Font.GothamBold
            Text.TextSize = 12
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
