local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

if CoreGui:FindFirstChild("TVH_UI") then
    CoreGui.TVH_UI:Destroy()
end

local Library = {
    ToggleKey = Enum.KeyCode.RightControl,
    AccentColor = Color3.fromRGB(0, 210, 255),
    Rainbow = true,
    Theme = {
        Background = Color3.fromRGB(13, 15, 23),
        Sidebar = Color3.fromRGB(18, 20, 31),
        Card = Color3.fromRGB(22, 25, 38),
        CardHover = Color3.fromRGB(28, 32, 48),
        Stroke = Color3.fromRGB(38, 42, 62),
        TextPrimary = Color3.fromRGB(245, 245, 250),
        TextSecondary = Color3.fromRGB(140, 145, 170)
    },
    AccentElements = {},
    RainbowElements = {}
}

local hue = 0
RunService.RenderStepped:Connect(function(delta)
    if Library.Rainbow then
        hue = (hue + delta * 0.2) % 1
        local rainbowColor = Color3.fromHSV(hue, 0.8, 1)
        for _, obj in ipairs(Library.RainbowElements) do
            if obj and obj.Parent then
                if obj:IsA("UIStroke") then
                    obj.Color = rainbowColor
                elseif obj:IsA("ImageLabel") then
                    obj.ImageColor3 = rainbowColor
                end
            end
        end
    end
end)

local function AddRipple(button)
    button.ClipsDescendants = true
    button.MouseButton1Click:Connect(function()
        local mousePos = UserInputService:GetMouseLocation()
        local relativePos = mousePos - button.AbsolutePosition
        
        local circle = Instance.new("Frame")
        circle.Name = "Ripple"
        circle.AnchorPoint = Vector2.new(0.5, 0.5)
        circle.Position = UDim2.new(0, relativePos.X, 0, relativePos.Y - 36)
        circle.Size = UDim2.new(0, 0, 0, 0)
        circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        circle.BackgroundTransparency = 0.6
        circle.Parent = button
        Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

        local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
        local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

        local tween = TweenService:Create(circle, tweenInfo, {
            Size = UDim2.new(0, maxSize, 0, maxSize),
            BackgroundTransparency = 1
        })
        tween:Play()
        tween.Completed:Connect(function() circle:Destroy() end)
    end)
end

local function MakeDraggable(ui, dragArea)
    local dragging, dragInput, dragStart, startPos
    dragArea = dragArea or ui
    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = ui.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    dragArea.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            TweenService:Create(ui, TweenInfo.new(0.08, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }):Play()
        end
    end)
end

local function CreateGlow(parent, color)
    local glow = Instance.new("ImageLabel")
    glow.Name = "GlowEffect"
    glow.AnchorPoint = Vector2.new(0.5, 0.5)
    glow.Position = UDim2.new(0.5, 0, 0.5, 0)
    glow.Size = UDim2.new(1, 40, 1, 40)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://5028857084"
    glow.ImageColor3 = color or Library.AccentColor
    glow.ImageTransparency = 0.65
    glow.ScaleType = Enum.ScaleType.Slice
    glow.SliceCenter = Rect.new(24, 24, 276, 276)
    glow.Parent = parent
    table.insert(Library.AccentElements, {Obj = glow, Prop = "ImageColor3"})
    table.insert(Library.RainbowElements, glow)
    return glow
end

function Library:SetAccentColor(color)
    Library.AccentColor = color
    for _, item in ipairs(Library.AccentElements) do
        if item.Obj and item.Obj.Parent then
            TweenService:Create(item.Obj, TweenInfo.new(0.3), {[item.Prop] = color}):Play()
        end
    end
end

local UI = Instance.new("ScreenGui")
UI.Name = "TVH_UI"
UI.Parent = CoreGui
UI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

function Library:Notify(title, desc, duration)
    duration = duration or 3.5
    local NotificationHolder = UI:FindFirstChild("NotificationHolder")
    if not NotificationHolder then
        NotificationHolder = Instance.new("Frame", UI)
        NotificationHolder.Name = "NotificationHolder"
        NotificationHolder.Size = UDim2.new(0, 280, 1, -40)
        NotificationHolder.Position = UDim2.new(1, -290, 0, 20)
        NotificationHolder.BackgroundTransparency = 1

        local List = Instance.new("UIListLayout", NotificationHolder)
        List.Padding = UDim.new(0, 10)
        List.VerticalAlignment = Enum.VerticalAlignment.Bottom
    end

    local Card = Instance.new("Frame", NotificationHolder)
    Card.Size = UDim2.new(1, 0, 0, 56)
    Card.BackgroundColor3 = Library.Theme.Card
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 12)

    local Stroke = Instance.new("UIStroke", Card)
    Stroke.Color = Library.AccentColor
    Stroke.Thickness = 1.2
    table.insert(Library.AccentElements, {Obj = Stroke, Prop = "Color"})
    table.insert(Library.RainbowElements, Stroke)

    local AccentBar = Instance.new("Frame", Card)
    AccentBar.Size = UDim2.new(0, 4, 1, -16)
    AccentBar.Position = UDim2.new(0, 8, 0, 8)
    AccentBar.BackgroundColor3 = Library.AccentColor
    Instance.new("UICorner", AccentBar).CornerRadius = UDim.new(1, 0)
    table.insert(Library.AccentElements, {Obj = AccentBar, Prop = "BackgroundColor3"})

    local TxtTitle = Instance.new("TextLabel", Card)
    TxtTitle.Text = title
    TxtTitle.Font = Enum.Font.GothamBold
    TxtTitle.TextSize = 12
    TxtTitle.TextColor3 = Library.Theme.TextPrimary
    TxtTitle.Position = UDim2.new(0, 22, 0, 10)
    TxtTitle.TextXAlignment = Enum.TextXAlignment.Left
    TxtTitle.BackgroundTransparency = 1

    local TxtDesc = Instance.new("TextLabel", Card)
    TxtDesc.Text = desc
    TxtDesc.Font = Enum.Font.Gotham
    TxtDesc.TextSize = 10
    TxtDesc.TextColor3 = Library.Theme.TextSecondary
    TxtDesc.Position = UDim2.new(0, 22, 0, 28)
    TxtDesc.TextXAlignment = Enum.TextXAlignment.Left
    TxtDesc.BackgroundTransparency = 1

    Card.Position = UDim2.new(1, 320, 0, 0)
    TweenService:Create(Card, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()

    task.delay(duration, function()
        local hide = TweenService:Create(Card, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(1, 320, 0, 0)})
        hide:Play()
        hide.Completed:Connect(function() Card:Destroy() end)
    end)
end

function Library:CreateWindow(titleText, subtitleText, logoId)
    local Window = {}
    local RegisteredElements = {}

    local DefaultSize = Vector2.new(520, 320)
    local CompactSize = Vector2.new(520, 42)
    local IsCompact = false

    local FloatBtn = Instance.new("Frame", UI)
    FloatBtn.Name = "FloatBtn"
    FloatBtn.Size = UDim2.new(0, 52, 0, 52)
    FloatBtn.Position = UDim2.new(0.03, 0, 0.15, 0)
    FloatBtn.BackgroundColor3 = Library.Theme.Background
    Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(0, 16)

    local FloatStroke = Instance.new("UIStroke", FloatBtn)
    FloatStroke.Color = Library.AccentColor
    FloatStroke.Thickness = 1.5
    table.insert(Library.AccentElements, {Obj = FloatStroke, Prop = "Color"})
    table.insert(Library.RainbowElements, FloatStroke)
    CreateGlow(FloatBtn, Library.AccentColor)

    local FloatIcon = Instance.new("ImageLabel", FloatBtn)
    FloatIcon.Size = UDim2.new(0, 28, 0, 28)
    FloatIcon.Position = UDim2.new(0.5, -14, 0.5, -14)
    FloatIcon.BackgroundTransparency = 1
    FloatIcon.Image = logoId or "rbxassetid://6031280882"
    FloatIcon.ImageColor3 = Library.AccentColor
    table.insert(Library.AccentElements, {Obj = FloatIcon, Prop = "ImageColor3"})

    local FloatTrigger = Instance.new("TextButton", FloatBtn)
    FloatTrigger.Size = UDim2.new(1, 0, 1, 0)
    FloatTrigger.BackgroundTransparency = 1
    FloatTrigger.Text = ""
    AddRipple(FloatTrigger)
    MakeDraggable(FloatBtn, FloatTrigger)

    local Main = Instance.new("Frame", UI)
    Main.Name = "Main"
    Main.Size = UDim2.new(0, DefaultSize.X, 0, DefaultSize.Y)
    Main.Position = UDim2.new(0.5, -DefaultSize.X/2, 0.5, -DefaultSize.Y/2)
    Main.BackgroundColor3 = Library.Theme.Background
    Main.Visible = false
    Main.ClipsDescendants = true
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

    local MainStroke = Instance.new("UIStroke", Main)
    MainStroke.Color = Library.AccentColor
    MainStroke.Thickness = 1.5
    MainStroke.Transparency = 0.1
    table.insert(Library.AccentElements, {Obj = MainStroke, Prop = "Color"})
    table.insert(Library.RainbowElements, MainStroke)

    CreateGlow(Main, Library.AccentColor)

    local Inner = Instance.new("Frame", Main)
    Inner.Size = UDim2.new(1, 0, 1, 0)
    Inner.BackgroundTransparency = 1
    Inner.ClipsDescendants = true
    Instance.new("UICorner", Inner).CornerRadius = UDim.new(0, 12)

    local Sidebar = Instance.new("Frame", Inner)
    Sidebar.Size = UDim2.new(0, 145, 1, 0)
    Sidebar.BackgroundColor3 = Library.Theme.Sidebar
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)

    local Brand = Instance.new("Frame", Sidebar)
    Brand.Size = UDim2.new(1, 0, 0, 50)
    Brand.BackgroundTransparency = 1

    local Icon = Instance.new("ImageLabel", Brand)
    Icon.Size = UDim2.new(0, 20, 0, 20)
    Icon.Position = UDim2.new(0, 10, 0, 15)
    Icon.BackgroundTransparency = 1
    Icon.Image = logoId or "rbxassetid://6031280882"
    Icon.ImageColor3 = Library.AccentColor
    table.insert(Library.AccentElements, {Obj = Icon, Prop = "ImageColor3"})

    local Title = Instance.new("TextLabel", Brand)
    Title.Text = titleText or "TVH HUB"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 12
    Title.TextColor3 = Library.AccentColor
    Title.Position = UDim2.new(0, 36, 0, 12)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1
    table.insert(Library.AccentElements, {Obj = Title, Prop = "TextColor3"})

    local Subtitle = Instance.new("TextLabel", Brand)
    Subtitle.Text = subtitleText or "by Hoàng"
    Subtitle.Font = Enum.Font.GothamBold
    Subtitle.TextSize = 8
    Subtitle.TextColor3 = Color3.fromRGB(0, 255, 170)
    Subtitle.Position = UDim2.new(0, 36, 0, 28)
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left
    Subtitle.BackgroundTransparency = 1

    local SearchBoxFrame = Instance.new("Frame", Sidebar)
    SearchBoxFrame.Size = UDim2.new(1, -16, 0, 26)
    SearchBoxFrame.Position = UDim2.new(0, 8, 0, 50)
    SearchBoxFrame.BackgroundColor3 = Library.Theme.Card
    Instance.new("UICorner", SearchBoxFrame).CornerRadius = UDim.new(0, 6)

    local SearchInput = Instance.new("TextBox", SearchBoxFrame)
    SearchInput.Size = UDim2.new(1, -12, 1, 0)
    SearchInput.Position = UDim2.new(0, 6, 0, 0)
    SearchInput.BackgroundTransparency = 1
    SearchInput.Text = ""
    SearchInput.PlaceholderText = "Search..."
    SearchInput.Font = Enum.Font.Gotham
    SearchInput.TextSize = 9
    SearchInput.TextColor3 = Library.Theme.TextPrimary
    SearchInput.PlaceholderColor3 = Library.Theme.TextSecondary
    SearchInput.TextXAlignment = Enum.TextXAlignment.Left

    local TabHolder = Instance.new("Frame", Sidebar)
    TabHolder.Size = UDim2.new(1, -16, 1, -85)
    TabHolder.Position = UDim2.new(0, 8, 0, 82)
    TabHolder.BackgroundTransparency = 1

    local TabList = Instance.new("UIListLayout", TabHolder)
    TabList.Padding = UDim.new(0, 4)

    local Topbar = Instance.new("Frame", Inner)
    Topbar.Size = UDim2.new(1, -145, 0, 42)
    Topbar.Position = UDim2.new(0, 145, 0, 0)
    Topbar.BackgroundTransparency = 1

    local TopbarDrag = Instance.new("TextButton", Topbar)
    TopbarDrag.Size = UDim2.new(1, -80, 1, 0)
    TopbarDrag.BackgroundTransparency = 1
    TopbarDrag.Text = ""
    MakeDraggable(Main, TopbarDrag)

    local PageTitle = Instance.new("TextLabel", Topbar)
    PageTitle.Text = "Home"
    PageTitle.Font = Enum.Font.GothamBold
    PageTitle.TextSize = 13
    PageTitle.TextColor3 = Library.Theme.TextPrimary
    PageTitle.Position = UDim2.new(0, 12, 0, 12)
    PageTitle.TextXAlignment = Enum.TextXAlignment.Left
    PageTitle.BackgroundTransparency = 1

    local ControlsHolder = Instance.new("Frame", Topbar)
    ControlsHolder.Size = UDim2.new(0, 70, 0, 26)
    ControlsHolder.Position = UDim2.new(1, -75, 0, 8)
    ControlsHolder.BackgroundTransparency = 1

    local ControlList = Instance.new("UIListLayout", ControlsHolder)
    ControlList.FillDirection = Enum.FillDirection.Horizontal
    ControlList.HorizontalAlignment = Enum.HorizontalAlignment.Right
    ControlList.Padding = UDim.new(0, 5)

    local ResizeBtnFrame = Instance.new("Frame", ControlsHolder)
    ResizeBtnFrame.Size = UDim2.new(0, 26, 0, 26)
    ResizeBtnFrame.BackgroundColor3 = Library.Theme.Card
    Instance.new("UICorner", ResizeBtnFrame).CornerRadius = UDim.new(0, 6)

    local ResizeBtn = Instance.new("TextButton", ResizeBtnFrame)
    ResizeBtn.Size = UDim2.new(1, 0, 1, 0)
    ResizeBtn.Text = "—"
    ResizeBtn.Font = Enum.Font.GothamBold
    ResizeBtn.TextSize = 11
    ResizeBtn.TextColor3 = Library.Theme.TextPrimary
    ResizeBtn.BackgroundTransparency = 1
    AddRipple(ResizeBtn)

    local CloseBtnFrame = Instance.new("Frame", ControlsHolder)
    CloseBtnFrame.Size = UDim2.new(0, 26, 0, 26)
    CloseBtnFrame.BackgroundColor3 = Color3.fromRGB(240, 50, 70)
    Instance.new("UICorner", CloseBtnFrame).CornerRadius = UDim.new(0, 6)

    local CloseBtn = Instance.new("TextButton", CloseBtnFrame)
    CloseBtn.Size = UDim2.new(1, 0, 1, 0)
    CloseBtn.Text = "✕"
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 11
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.BackgroundTransparency = 1
    AddRipple(CloseBtn)

    local ContentArea = Instance.new("Frame", Inner)
    ContentArea.Size = UDim2.new(1, -145, 1, -42)
    ContentArea.Position = UDim2.new(0, 145, 0, 42)
    ContentArea.BackgroundTransparency = 1

    ResizeBtn.MouseButton1Click:Connect(function()
        IsCompact = not IsCompact
        if IsCompact then
            ResizeBtn.Text = "🗖"
            ContentArea.Visible = false
            Sidebar.Visible = false
            TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, CompactSize.X, 0, CompactSize.Y)
            }):Play()
        else
            ResizeBtn.Text = "—"
            local tween = TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, DefaultSize.X, 0, DefaultSize.Y)
            })
            tween:Play()
            tween.Completed:Connect(function()
                if not IsCompact then
                    ContentArea.Visible = true
                    Sidebar.Visible = true
                end
            end)
        end
    end)

    local function ToggleUI()
        Main.Visible = not Main.Visible
        if Main.Visible then
            ContentArea.Visible = true
            Sidebar.Visible = true
            IsCompact = false
            ResizeBtn.Text = "—"
            Main.Size = UDim2.new(0, DefaultSize.X, 0, DefaultSize.Y)
        end
    end

    FloatTrigger.MouseButton1Click:Connect(ToggleUI)
    CloseBtn.MouseButton1Click:Connect(ToggleUI)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Library.ToggleKey then ToggleUI() end
    end)

    SearchInput.Changed:Connect(function()
        local query = SearchInput.Text:lower()
        for _, elem in ipairs(RegisteredElements) do
            if elem.Card then
                if query == "" or elem.Name:lower():find(query) then
                    elem.Card.Visible = true
                else
                    elem.Card.Visible = false
                end
            end
        end
    end)

    Window.Tabs = {}

    function Window:CreateTab(tabName, iconId)
        local Tab = {Name = tabName}

        local Btn = Instance.new("TextButton", TabHolder)
        Btn.Size = UDim2.new(1, 0, 0, 32)
        Btn.BackgroundColor3 = Library.Theme.Card
        Btn.BackgroundTransparency = 1
        Btn.Text = ""
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
        AddRipple(Btn)

        local TabIcon = Instance.new("ImageLabel", Btn)
        TabIcon.Size = UDim2.new(0, 16, 0, 16)
        TabIcon.Position = UDim2.new(0, 8, 0.5, -8)
        TabIcon.BackgroundTransparency = 1
        TabIcon.Image = iconId or "rbxassetid://6031280882"
        TabIcon.ImageColor3 = Library.Theme.TextSecondary

        local Label = Instance.new("TextLabel", Btn)
        Label.Text = tabName
        Label.Font = Enum.Font.GothamBold
        Label.TextSize = 10
        Label.TextColor3 = Library.Theme.TextSecondary
        Label.Position = UDim2.new(0, 30, 0, 0)
        Label.Size = UDim2.new(1, -30, 1, 0)
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.BackgroundTransparency = 1

        local Page = Instance.new("ScrollingFrame", ContentArea)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Library.AccentColor
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.Visible = false

        local PagePadding = Instance.new("UIPadding", Page)
        PagePadding.PaddingLeft = UDim.new(0, 10)
        PagePadding.PaddingRight = UDim.new(0, 10)
        PagePadding.PaddingTop = UDim.new(0, 8)
        PagePadding.PaddingBottom = UDim.new(0, 10)

        local Layout = Instance.new("UIListLayout", Page)
        Layout.Padding = UDim.new(0, 6)

        Btn.MouseButton1Click:Connect(function()
            for _, t in pairs(Window.Tabs) do
                TweenService:Create(t.Btn, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
                TweenService:Create(t.Label, TweenInfo.new(0.2), {TextColor3 = Library.Theme.TextSecondary}):Play()
                TweenService:Create(t.Icon, TweenInfo.new(0.2), {ImageColor3 = Library.Theme.TextSecondary}):Play()
                t.Page.Visible = false
            end
            Page.Visible = true
            PageTitle.Text = tabName
            TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundTransparency = 0, BackgroundColor3 = Library.Theme.CardHover}):Play()
            TweenService:Create(Label, TweenInfo.new(0.2), {TextColor3 = Library.AccentColor}):Play()
            TweenService:Create(TabIcon, TweenInfo.new(0.2), {ImageColor3 = Library.AccentColor}):Play()
        end)

        Tab.Btn = Btn
        Tab.Label = Label
        Tab.Icon = TabIcon
        Tab.Page = Page

        table.insert(Window.Tabs, Tab)
        if #Window.Tabs == 1 then
            Page.Visible = true
            PageTitle.Text = tabName
            Btn.BackgroundTransparency = 0
            Btn.BackgroundColor3 = Library.Theme.CardHover
            Label.TextColor3 = Library.AccentColor
            TabIcon.ImageColor3 = Library.AccentColor
        end

        function Tab:CreateCategory(titleText)
            local Frame = Instance.new("Frame", Page)
            Frame.Size = UDim2.new(1, 0, 0, 24)
            Frame.BackgroundTransparency = 1

            local Txt = Instance.new("TextLabel", Frame)
            Txt.Text = titleText:upper()
            Txt.Font = Enum.Font.GothamBold
            Txt.TextSize = 9
            Txt.TextColor3 = Library.AccentColor
            Txt.Position = UDim2.new(0, 2, 0, 4)
            Txt.TextXAlignment = Enum.TextXAlignment.Left
            Txt.BackgroundTransparency = 1
            table.insert(Library.AccentElements, {Obj = Txt, Prop = "TextColor3"})
        end

        function Tab:CreateToggle(name, desc, default, callback)
            local Card = Instance.new("Frame", Page)
            Card.Size = UDim2.new(1, 0, 0, 42)
            Card.BackgroundColor3 = Library.Theme.Card
            Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)

            local Title = Instance.new("TextLabel", Card)
            Title.Text = name
            Title.Font = Enum.Font.GothamBold
            Title.TextSize = 10
            Title.TextColor3 = Library.Theme.TextPrimary
            Title.Position = UDim2.new(0, 10, 0, 6)
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.BackgroundTransparency = 1

            local Sub = Instance.new("TextLabel", Card)
            Sub.Text = desc
            Sub.Font = Enum.Font.Gotham
            Sub.TextSize = 8
            Sub.TextColor3 = Library.Theme.TextSecondary
            Sub.Position = UDim2.new(0, 10, 0, 22)
            Sub.TextXAlignment = Enum.TextXAlignment.Left
            Sub.BackgroundTransparency = 1

            local Switch = Instance.new("TextButton", Card)
            Switch.Size = UDim2.new(0, 36, 0, 18)
            Switch.Position = UDim2.new(1, -46, 0.5, -9)
            Switch.BackgroundColor3 = Library.Theme.Stroke
            Switch.Text = ""
            Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)

            local Knob = Instance.new("Frame", Switch)
            Knob.Size = UDim2.new(0, 14, 0, 14)
            Knob.Position = UDim2.new(0, 2, 0.5, -7)
            Knob.BackgroundColor3 = Library.Theme.TextSecondary
            Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

            local active = default or false
            local function UpdateState()
                TweenService:Create(Switch, TweenInfo.new(0.2), {
                    BackgroundColor3 = active and Library.AccentColor or Library.Theme.Stroke
                }):Play()
                TweenService:Create(Knob, TweenInfo.new(0.2), {
                    Position = active and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
                    BackgroundColor3 = active and Color3.fromRGB(255, 255, 255) or Library.Theme.TextSecondary
                }):Play()
            end

            UpdateState()

            Switch.MouseButton1Click:Connect(function()
                active = not active
                UpdateState()
                callback(active)
            end)

            table.insert(RegisteredElements, {Name = name, Card = Card})
        end

        function Tab:CreateSlider(name, min, max, default, callback)
            local Card = Instance.new("Frame", Page)
            Card.Size = UDim2.new(1, 0, 0, 46)
            Card.BackgroundColor3 = Library.Theme.Card
            Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)

            local Title = Instance.new("TextLabel", Card)
            Title.Text = name
            Title.Font = Enum.Font.GothamBold
            Title.TextSize = 10
            Title.TextColor3 = Library.Theme.TextPrimary
            Title.Position = UDim2.new(0, 10, 0, 6)
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.BackgroundTransparency = 1

            local ValText = Instance.new("TextLabel", Card)
            ValText.Text = tostring(default)
            ValText.Font = Enum.Font.Gotham
            ValText.TextSize = 9
            ValText.TextColor3 = Library.AccentColor
            ValText.Position = UDim2.new(1, -50, 0, 6)
            ValText.Size = UDim2.new(0, 40, 0, 14)
            ValText.TextXAlignment = Enum.TextXAlignment.Right
            ValText.BackgroundTransparency = 1
            table.insert(Library.AccentElements, {Obj = ValText, Prop = "TextColor3"})

            local Track = Instance.new("Frame", Card)
            Track.Size = UDim2.new(1, -20, 0, 6)
            Track.Position = UDim2.new(0, 10, 0, 28)
            Track.BackgroundColor3 = Library.Theme.Stroke
            Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

            local Fill = Instance.new("Frame", Track)
            Fill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
            Fill.BackgroundColor3 = Library.AccentColor
            Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
            table.insert(Library.AccentElements, {Obj = Fill, Prop = "BackgroundColor3"})

            local dragging = false
            local function UpdateSlider(input)
                local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + (max - min) * pos)
                ValText.Text = tostring(val)
                Fill.Size = UDim2.new(pos, 0, 1, 0)
                callback(val)
            end

            Track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    UpdateSlider(input)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    UpdateSlider(input)
                end
            end)

            table.insert(RegisteredElements, {Name = name, Card = Card})
        end

        function Tab:CreateButton(name, callback)
            local Card = Instance.new("Frame", Page)
            Card.Size = UDim2.new(1, 0, 0, 34)
            Card.BackgroundColor3 = Library.Theme.Card
            Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)

            local Btn = Instance.new("TextButton", Card)
            Btn.Size = UDim2.new(1, 0, 1, 0)
            Btn.Text = name
            Btn.Font = Enum.Font.GothamBold
            Btn.TextSize = 10
            Btn.TextColor3 = Library.AccentColor
            Btn.BackgroundTransparency = 1
            AddRipple(Btn)
            table.insert(Library.AccentElements, {Obj = Btn, Prop = "TextColor3"})

            Btn.MouseButton1Click:Connect(function()
                callback()
            end)

            table.insert(RegisteredElements, {Name = name, Card = Card})
        end

        function Tab:CreateDropdown(name, list, default, callback)
            local Card = Instance.new("Frame", Page)
            Card.Size = UDim2.new(1, 0, 0, 42)
            Card.BackgroundColor3 = Library.Theme.Card
            Card.ClipsDescendants = true
            Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)

            local Title = Instance.new("TextLabel", Card)
            Title.Text = name
            Title.Font = Enum.Font.GothamBold
            Title.TextSize = 10
            Title.TextColor3 = Library.Theme.TextPrimary
            Title.Position = UDim2.new(0, 10, 0, 6)
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.BackgroundTransparency = 1

            local Selected = Instance.new("TextLabel", Card)
            Selected.Text = default or "Select..."
            Selected.Font = Enum.Font.Gotham
            Selected.TextSize = 9
            Selected.TextColor3 = Library.Theme.TextSecondary
            Selected.Position = UDim2.new(0, 10, 0, 22)
            Selected.TextXAlignment = Enum.TextXAlignment.Left
            Selected.BackgroundTransparency = 1

            local Arrow = Instance.new("TextLabel", Card)
            Arrow.Text = "▼"
            Arrow.Font = Enum.Font.Gotham
            Arrow.TextSize = 8
            Arrow.TextColor3 = Library.Theme.TextSecondary
            Arrow.Position = UDim2.new(1, -26, 0, 12)
            Arrow.BackgroundTransparency = 1

            local DropBtn = Instance.new("TextButton", Card)
            DropBtn.Size = UDim2.new(1, 0, 0, 42)
            DropBtn.BackgroundTransparency = 1
            DropBtn.Text = ""

            local OptionHolder = Instance.new("Frame", Card)
            OptionHolder.Size = UDim2.new(1, -20, 0, #list * 24)
            OptionHolder.Position = UDim2.new(0, 10, 0, 42)
            OptionHolder.BackgroundTransparency = 1

            local OptionList = Instance.new("UIListLayout", OptionHolder)
            OptionList.Padding = UDim.new(0, 2)

            local open = false
            DropBtn.MouseButton1Click:Connect(function()
                open = not open
                Arrow.Text = open and "▲" or "▼"
                TweenService:Create(Card, TweenInfo.new(0.2), {
                    Size = open and UDim2.new(1, 0, 0, 46 + #list * 24) or UDim2.new(1, 0, 0, 42)
                }):Play()
            end)

            for _, opt in ipairs(list) do
                local OptBtn = Instance.new("TextButton", OptionHolder)
                OptBtn.Size = UDim2.new(1, 0, 0, 22)
                OptBtn.BackgroundColor3 = Library.Theme.Sidebar
                OptBtn.Text = opt
                OptBtn.Font = Enum.Font.Gotham
                OptBtn.TextSize = 9
                OptBtn.TextColor3 = Library.Theme.TextSecondary
                Instance.new("UICorner", OptBtn).CornerRadius = UDim.new(0, 4)

                OptBtn.MouseButton1Click:Connect(function()
                    Selected.Text = opt
                    open = false
                    Arrow.Text = "▼"
                    TweenService:Create(Card, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 42)}):Play()
                    callback(opt)
                end)
            end

            table.insert(RegisteredElements, {Name = name, Card = Card})
        end

        function Tab:CreateTextbox(name, placeholder, callback)
            local Card = Instance.new("Frame", Page)
            Card.Size = UDim2.new(1, 0, 0, 42)
            Card.BackgroundColor3 = Library.Theme.Card
            Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)

            local Title = Instance.new("TextLabel", Card)
            Title.Text = name
            Title.Font = Enum.Font.GothamBold
            Title.TextSize = 10
            Title.TextColor3 = Library.Theme.TextPrimary
            Title.Position = UDim2.new(0, 10, 0, 13)
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.BackgroundTransparency = 1

            local InputFrame = Instance.new("Frame", Card)
            InputFrame.Size = UDim2.new(0, 120, 0, 24)
            InputFrame.Position = UDim2.new(1, -130, 0.5, -12)
            InputFrame.BackgroundColor3 = Library.Theme.Sidebar
            Instance.new("UICorner", InputFrame).CornerRadius = UDim.new(0, 6)

            local Box = Instance.new("TextBox", InputFrame)
            Box.Size = UDim2.new(1, -10, 1, 0)
            Box.Position = UDim2.new(0, 5, 0, 0)
            Box.BackgroundTransparency = 1
            Box.Text = ""
            Box.PlaceholderText = placeholder or "Nhập..."
            Box.Font = Enum.Font.Gotham
            Box.TextSize = 9
            Box.TextColor3 = Library.Theme.TextPrimary
            Box.PlaceholderColor3 = Library.Theme.TextSecondary

            Box.FocusLost:Connect(function(enterPressed)
                if enterPressed then callback(Box.Text) end
            end)

            table.insert(RegisteredElements, {Name = name, Card = Card})
        end

        function Tab:CreateKeybind(name, defaultKey, callback)
            local Card = Instance.new("Frame", Page)
            Card.Size = UDim2.new(1, 0, 0, 42)
            Card.BackgroundColor3 = Library.Theme.Card
            Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)

            local Title = Instance.new("TextLabel", Card)
            Title.Text = name
            Title.Font = Enum.Font.GothamBold
            Title.TextSize = 10
            Title.TextColor3 = Library.Theme.TextPrimary
            Title.Position = UDim2.new(0, 10, 0, 13)
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.BackgroundTransparency = 1

            local BindBtn = Instance.new("TextButton", Card)
            BindBtn.Size = UDim2.new(0, 70, 0, 22)
            BindBtn.Position = UDim2.new(1, -80, 0.5, -11)
            BindBtn.BackgroundColor3 = Library.Theme.Sidebar
            BindBtn.Text = defaultKey.Name
            BindBtn.Font = Enum.Font.GothamBold
            BindBtn.TextSize = 9
            BindBtn.TextColor3 = Library.AccentColor
            Instance.new("UICorner", BindBtn).CornerRadius = UDim.new(0, 6)
            table.insert(Library.AccentElements, {Obj = BindBtn, Prop = "TextColor3"})

            local currKey = defaultKey
            local listening = false

            BindBtn.MouseButton1Click:Connect(function()
                listening = true
                BindBtn.Text = "..."
            end)

            UserInputService.InputBegan:Connect(function(input, gpe)
                if listening and not gpe then
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        currKey = input.KeyCode
                        BindBtn.Text = currKey.Name
                        listening = false
                        callback(currKey)
                    end
                elseif not gpe and input.KeyCode == currKey then
                    callback(currKey)
                end
            end)

            table.insert(RegisteredElements, {Name = name, Card = Card})
        end

        function Tab:CreateInfoCard(titleText, descText)
            local Card = Instance.new("Frame", Page)
            Card.Size = UDim2.new(1, 0, 0, 50)
            Card.BackgroundColor3 = Library.Theme.Card
            Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)

            local Title = Instance.new("TextLabel", Card)
            Title.Text = titleText
            Title.Font = Enum.Font.GothamBold
            Title.TextSize = 10
            Title.TextColor3 = Library.AccentColor
            Title.Position = UDim2.new(0, 10, 0, 8)
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.BackgroundTransparency = 1
            table.insert(Library.AccentElements, {Obj = Title, Prop = "TextColor3"})

            local Desc = Instance.new("TextLabel", Card)
            Desc.Text = descText
            Desc.Font = Enum.Font.Gotham
            Desc.TextSize = 8
            Desc.TextColor3 = Library.Theme.TextSecondary
            Desc.Position = UDim2.new(0, 10, 0, 24)
            Desc.TextXAlignment = Enum.TextXAlignment.Left
            Desc.BackgroundTransparency = 1

            table.insert(RegisteredElements, {Name = titleText, Card = Card})
        end

        function Tab:CreateColorPicker(name, defaultColor, callback)
            local Card = Instance.new("Frame", Page)
            Card.Size = UDim2.new(1, 0, 0, 42)
            Card.BackgroundColor3 = Library.Theme.Card
            Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)

            local Title = Instance.new("TextLabel", Card)
            Title.Text = name
            Title.Font = Enum.Font.GothamBold
            Title.TextSize = 10
            Title.TextColor3 = Library.Theme.TextPrimary
            Title.Position = UDim2.new(0, 10, 0, 13)
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.BackgroundTransparency = 1

            local ColorBox = Instance.new("TextButton", Card)
            ColorBox.Size = UDim2.new(0, 24, 0, 24)
            ColorBox.Position = UDim2.new(1, -34, 0.5, -12)
            ColorBox.BackgroundColor3 = defaultColor or Library.AccentColor
            ColorBox.Text = ""
            Instance.new("UICorner", ColorBox).CornerRadius = UDim.new(0, 6)

            ColorBox.MouseButton1Click:Connect(function()
                Library:SetAccentColor(ColorBox.BackgroundColor3)
                callback(ColorBox.BackgroundColor3)
            end)

            table.insert(RegisteredElements, {Name = name, Card = Card})
        end

        return Tab
    end

    return Window
end

return Library