local Library = {}
Library.__index = Library

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

function Library.new(config)
    local self = setmetatable({}, Library)
    config = config or {}
    
    self.HubName = config.Name or "TVH Hub"
    self.SubName = config.SubName or "Version : 1.0"
    self.ConfigFile = config.ConfigFile or "TVH_Config.json"
    
    self.AccentObjects = {
        Strokes = {},
        Labels = {},
        ImageLabels = {},
        Buttons = {},
        Fills = {}
    }
    
    self.TabBtns = {}
    
    local rawOptions = {}
    
    self.Options = setmetatable({}, {
        __index = rawOptions,
        __newindex = function(t, key, value)
            rawset(t, key, value)
            rawOptions[key] = value
            self:SaveConfig()
        end
    })
    
    self.Options.AccentColor = config.AccentColor or Color3.fromRGB(0, 220, 255)
    self.Options.ToggleKey = Enum.KeyCode.RightControl
    
    if readfile and isfile and isfile(self.ConfigFile) then
        pcall(function()
            local data = HttpService:JSONDecode(readfile(self.ConfigFile))
            if data then
                for k, v in pairs(data) do
                    if type(v) == "table" and #v == 3 then
                        rawOptions[k] = Color3.new(v[1], v[2], v[3])
                    elseif Enum.KeyCode[v] then
                        rawOptions[k] = Enum.KeyCode[v]
                    else
                        rawOptions[k] = v
                    end
                end
            end
        end)
    end
    
    self:BuildUI()
    return self
end

function Library:SaveConfig()
    if writefile then
        local data = {}
        for k, v in pairs(self.Options) do
            if typeof(v) == "Color3" then
                data[k] = {v.R, v.G, v.B}
            elseif typeof(v) == "EnumItem" then
                data[k] = tostring(v.Name)
            else
                data[k] = v
            end
        end
        pcall(function() writefile(self.ConfigFile, HttpService:JSONEncode(data)) end)
    end
end

function Library:LoadConfig()
    if readfile and isfile and isfile(self.ConfigFile) then
        pcall(function()
            local data = HttpService:JSONDecode(readfile(self.ConfigFile))
            if data then
                for k, v in pairs(data) do
                    if self.Options[k] ~= nil then
                        if typeof(self.Options[k]) == "Color3" and type(v) == "table" then
                            self.Options[k] = Color3.new(v[1], v[2], v[3])
                        elseif typeof(self.Options[k]) == "EnumItem" and Enum.KeyCode[v] then
                            self.Options[k] = Enum.KeyCode[v]
                        else
                            self.Options[k] = v
                        end
                    end
                end
            end
        end)
    end
end

function Library:UpdateAccentColor(newColor)
    self.Options.AccentColor = newColor
    for _, obj in ipairs(self.AccentObjects.Strokes) do pcall(function() obj.Color = newColor end) end
    for _, obj in ipairs(self.AccentObjects.Labels) do pcall(function() obj.TextColor3 = newColor end) end
    for _, obj in ipairs(self.AccentObjects.ImageLabels) do pcall(function() obj.ImageColor3 = newColor end) end
    for _, obj in ipairs(self.AccentObjects.Buttons) do pcall(function() obj.TextColor3 = newColor end) end
    for _, obj in ipairs(self.AccentObjects.Fills) do pcall(function() obj.BackgroundColor3 = newColor end) end
    self:SaveConfig()
end

function Library:CreateGlow(parent, color)
    local glow = Instance.new("ImageLabel")
    glow.Name = "GlowEffect"
    glow.AnchorPoint = Vector2.new(0.5, 0.5)
    glow.Position = UDim2.new(0.5, 0, 0.5, 0)
    glow.Size = UDim2.new(1, 30, 1, 30)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://5028857084"
    glow.ImageColor3 = color or self.Options.AccentColor
    glow.ImageTransparency = 0.5
    glow.ScaleType = Enum.ScaleType.Slice
    glow.SliceCenter = Rect.new(24, 24, 276, 276)
    glow.Parent = parent
    table.insert(self.AccentObjects.ImageLabels, glow)
    return glow
end

function Library:MakeDraggable(ui, dragArea)
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

function Library:BuildUI()
    local UI = Instance.new("ScreenGui")
    UI.Name = "TVH_Hub"
    UI.Parent = CoreGui
    UI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui = UI

    local ToggleBtn = Instance.new("Frame")
    ToggleBtn.Name = "ToggleBtn"
    ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
    ToggleBtn.Position = UDim2.new(0.02, 0, 0.2, 0)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(16, 18, 28)
    ToggleBtn.Parent = UI

    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 14)
    self:CreateGlow(ToggleBtn, self.Options.AccentColor)

    local ToggleStroke = Instance.new("UIStroke", ToggleBtn)
    ToggleStroke.Color = self.Options.AccentColor
    ToggleStroke.Thickness = 1.5
    table.insert(self.AccentObjects.Strokes, ToggleStroke)

    local ToggleIcon = Instance.new("ImageLabel", ToggleBtn)
    ToggleIcon.Size = UDim2.new(0, 26, 0, 26)
    ToggleIcon.Position = UDim2.new(0.5, -13, 0.5, -13)
    ToggleIcon.BackgroundTransparency = 1
    ToggleIcon.Image = "rbxassetid://6031280882"
    ToggleIcon.ImageColor3 = self.Options.AccentColor
    table.insert(self.AccentObjects.ImageLabels, ToggleIcon)

    local ToggleTrigger = Instance.new("TextButton")
    ToggleTrigger.Size = UDim2.new(1, 0, 1, 0)
    ToggleTrigger.BackgroundTransparency = 1
    ToggleTrigger.Text = ""
    ToggleTrigger.Parent = ToggleBtn

    self:MakeDraggable(ToggleBtn, ToggleTrigger)

    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 540, 0, 390)
    Main.Position = UDim2.new(0.5, -270, 0.5, -195)
    Main.BackgroundColor3 = Color3.fromRGB(12, 14, 22)
    Main.BorderSizePixel = 0
    Main.Visible = false
    Main.Parent = UI
    self.MainFrame = Main

    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 16)

    local MainStroke = Instance.new("UIStroke", Main)
    MainStroke.Color = self.Options.AccentColor
    MainStroke.Thickness = 1.5
    MainStroke.Transparency = 0.2
    table.insert(self.AccentObjects.Strokes, MainStroke)

    self:CreateGlow(Main, self.Options.AccentColor)

    local InnerContainer = Instance.new("Frame", Main)
    InnerContainer.Size = UDim2.new(1, 0, 1, 0)
    InnerContainer.BackgroundTransparency = 1
    InnerContainer.ClipsDescendants = true
    Instance.new("UICorner", InnerContainer).CornerRadius = UDim.new(0, 16)

    self:MakeDraggable(Main)

    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 150, 1, 0)
    Sidebar.BackgroundColor3 = Color3.fromRGB(18, 20, 30)
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = InnerContainer

    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 16)

    local SidebarBrand = Instance.new("Frame")
    SidebarBrand.Size = UDim2.new(1, 0, 0, 65)
    SidebarBrand.BackgroundTransparency = 1
    SidebarBrand.Parent = Sidebar

    local BrandIcon = Instance.new("ImageLabel", SidebarBrand)
    BrandIcon.Size = UDim2.new(0, 22, 0, 22)
    BrandIcon.Position = UDim2.new(0, 14, 0, 21)
    BrandIcon.BackgroundTransparency = 1
    BrandIcon.Image = "rbxassetid://6031280882"
    BrandIcon.ImageColor3 = self.Options.AccentColor
    table.insert(self.AccentObjects.ImageLabels, BrandIcon)

    local BrandTitle = Instance.new("TextLabel")
    BrandTitle.Text = self.HubName
    BrandTitle.Font = Enum.Font.GothamBold
    BrandTitle.TextSize = 15
    BrandTitle.TextColor3 = self.Options.AccentColor
    BrandTitle.Position = UDim2.new(0, 42, 0, 16)
    BrandTitle.Size = UDim2.new(1, -48, 0, 18)
    BrandTitle.TextXAlignment = Enum.TextXAlignment.Left
    BrandTitle.BackgroundTransparency = 1
    BrandTitle.Parent = SidebarBrand
    table.insert(self.AccentObjects.Labels, BrandTitle)

    local BrandSub = Instance.new("TextLabel")
    BrandSub.Text = self.SubName
    BrandSub.Font = Enum.Font.GothamBold
    BrandSub.TextSize = 9
    BrandSub.TextColor3 = Color3.fromRGB(0, 255, 170)
    BrandSub.Position = UDim2.new(0, 42, 0, 35)
    BrandSub.Size = UDim2.new(1, -48, 0, 12)
    BrandSub.TextXAlignment = Enum.TextXAlignment.Left
    BrandSub.BackgroundTransparency = 1
    BrandSub.Parent = SidebarBrand

    local BrandDivider = Instance.new("Frame")
    BrandDivider.Size = UDim2.new(1, -24, 0, 1)
    BrandDivider.Position = UDim2.new(0, 12, 0, 60)
    BrandDivider.BackgroundColor3 = Color3.fromRGB(40, 45, 65)
    BrandDivider.BorderSizePixel = 0
    BrandDivider.Parent = Sidebar

    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(1, -16, 1, -75)
    TabContainer.Position = UDim2.new(0, 8, 0, 68)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = Sidebar
    self.TabContainer = TabContainer

    local TabList = Instance.new("UIListLayout", TabContainer)
    TabList.Padding = UDim.new(0, 6)
    TabList.SortOrder = Enum.SortOrder.LayoutOrder

    local Topbar = Instance.new("Frame")
    Topbar.Size = UDim2.new(1, -150, 0, 45)
    Topbar.Position = UDim2.new(0, 150, 0, 0)
    Topbar.BackgroundTransparency = 1
    Topbar.Parent = InnerContainer

    local TopbarDivider = Instance.new("Frame")
    TopbarDivider.Size = UDim2.new(1, 0, 0, 1)
    TopbarDivider.Position = UDim2.new(0, 0, 1, -1)
    TopbarDivider.BackgroundColor3 = Color3.fromRGB(35, 40, 60)
    TopbarDivider.BorderSizePixel = 0
    TopbarDivider.Parent = Topbar

    local PageTitle = Instance.new("TextLabel")
    PageTitle.Text = "Trang Chủ" 
    PageTitle.Font = Enum.Font.GothamBold
    PageTitle.TextSize = 13
    PageTitle.TextColor3 = Color3.fromRGB(240, 240, 255)
    PageTitle.Position = UDim2.new(0, 16, 0, 14)
    PageTitle.Size = UDim2.new(0, 150, 0, 16)
    PageTitle.TextXAlignment = Enum.TextXAlignment.Left
    PageTitle.BackgroundTransparency = 1
    PageTitle.Parent = Topbar
    self.PageTitle = PageTitle

    local FPSBadge = Instance.new("Frame")
    FPSBadge.Size = UDim2.new(0, 75, 0, 24)
    FPSBadge.Position = UDim2.new(1, -120, 0, 10)
    FPSBadge.BackgroundColor3 = Color3.fromRGB(22, 26, 38)
    FPSBadge.Parent = Topbar
    Instance.new("UICorner", FPSBadge).CornerRadius = UDim.new(0, 8)

    local FPSDot = Instance.new("Frame")
    FPSDot.Size = UDim2.new(0, 6, 0, 6)
    FPSDot.Position = UDim2.new(0, 10, 0.5, -3)
    FPSDot.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
    FPSDot.Parent = FPSBadge
    Instance.new("UICorner", FPSDot).CornerRadius = UDim.new(1, 0)

    local FPSLabel = Instance.new("TextLabel")
    FPSLabel.Size = UDim2.new(1, -22, 1, 0)
    FPSLabel.Position = UDim2.new(0, 20, 0, 0)
    FPSLabel.Text = "FPS"
    FPSLabel.Font = Enum.Font.GothamBold
    FPSLabel.TextSize = 10
    FPSLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
    FPSLabel.TextXAlignment = Enum.TextXAlignment.Left
    FPSLabel.BackgroundTransparency = 1
    FPSLabel.Parent = FPSBadge
    self.FPSLabel = FPSLabel
    self.FPSDot = FPSDot

    local CloseBtnFrame = Instance.new("Frame")
    CloseBtnFrame.Size = UDim2.new(0, 26, 0, 26)
    CloseBtnFrame.Position = UDim2.new(1, -36, 0, 9)
    CloseBtnFrame.BackgroundColor3 = Color3.fromRGB(230, 40, 60)
    CloseBtnFrame.Parent = Topbar
    Instance.new("UICorner", CloseBtnFrame).CornerRadius = UDim.new(0, 8)

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(1, 0, 1, 0)
    CloseBtn.Text = "X"
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 13
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Parent = CloseBtnFrame

    local ContentArea = Instance.new("Frame")
    ContentArea.Size = UDim2.new(1, -150, 1, -45)
    ContentArea.Position = UDim2.new(0, 150, 0, 45)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = InnerContainer
    self.ContentArea = ContentArea

    local function ToggleUI()
        Main.Visible = not Main.Visible
        if Main.Visible then
            Main.Size = UDim2.new(0, 440, 0, 310)
            TweenService:Create(Main, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 540, 0, 390)
            }):Play()
        end
    end

    ToggleTrigger.MouseButton1Click:Connect(ToggleUI)
    CloseBtn.MouseButton1Click:Connect(ToggleUI)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == self.Options.ToggleKey then
            ToggleUI()
        end
    end)

    local frames, lastTick = 0, tick()
    RunService.RenderStepped:Connect(function()
        frames = frames + 1
        local now = tick()
        if now - lastTick >= 1 then
            local fps = math.floor(frames / (now - lastTick))
            self.FPSLabel.Text = fps .. " FPS"
            self.FPSDot.BackgroundColor3 = fps >= 50 and Color3.fromRGB(0, 255, 150) or (fps >= 30 and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(255, 60, 60))
            frames = 0
            lastTick = now
        end
    end)
end

function Library:CreateTab(name, iconId)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 36)
    Btn.BackgroundColor3 = Color3.fromRGB(25, 28, 42)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""
    Btn.Parent = self.TabContainer
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)

    local Icon = Instance.new("ImageLabel", Btn)
    Icon.Size = UDim2.new(0, 18, 0, 18)
    Icon.Position = UDim2.new(0, 10, 0.5, -9)
    Icon.BackgroundTransparency = 1
    Icon.Image = iconId or "rbxassetid://6031280882"
    Icon.ImageColor3 = Color3.fromRGB(140, 145, 165)

    local Label = Instance.new("TextLabel", Btn)
    Label.Text = name
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 11
    Label.TextColor3 = Color3.fromRGB(140, 145, 165)
    Label.Position = UDim2.new(0, 36, 0, 0)
    Label.Size = UDim2.new(1, -36, 1, 0)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1

    local Indicator = Instance.new("Frame", Btn)
    Indicator.Size = UDim2.new(0, 3, 0, 18)
    Indicator.Position = UDim2.new(0, 0, 0.5, -9)
    Indicator.BackgroundColor3 = self.Options.AccentColor
    Indicator.BackgroundTransparency = 1
    Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)
    table.insert(self.AccentObjects.Fills, Indicator)

    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 3
    Page.ScrollBarImageColor3 = self.Options.AccentColor
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.Visible = false
    Page.Parent = self.ContentArea

    local PagePadding = Instance.new("UIPadding", Page)
    PagePadding.PaddingLeft = UDim.new(0, 12)
    PagePadding.PaddingRight = UDim.new(0, 12)
    PagePadding.PaddingTop = UDim.new(0, 12)
    PagePadding.PaddingBottom = UDim.new(0, 12)

    local Layout = Instance.new("UIListLayout", Page)
    Layout.Padding = UDim.new(0, 8)

    local selfLib = self
    Btn.MouseButton1Click:Connect(function()
        for _, t in pairs(selfLib.TabBtns) do
            TweenService:Create(t.Btn, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            TweenService:Create(t.Icon, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(140, 145, 165)}):Play()
            TweenService:Create(t.Label, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(140, 145, 165)}):Play()
            TweenService:Create(t.Indicator, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            t.Page.Visible = false
        end
        Page.Visible = true
        if selfLib.PageTitle then
            selfLib.PageTitle.Text = name
        end
        TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(28, 32, 48)}):Play()
        TweenService:Create(Icon, TweenInfo.new(0.2), {ImageColor3 = selfLib.Options.AccentColor}):Play()
        TweenService:Create(Label, TweenInfo.new(0.2), {TextColor3 = selfLib.Options.AccentColor}):Play()
        TweenService:Create(Indicator, TweenInfo.new(0.2), {BackgroundTransparency = 0, BackgroundColor3 = selfLib.Options.AccentColor}):Play()
    end)

    table.insert(self.TabBtns, {Btn = Btn, Icon = Icon, Label = Label, Indicator = Indicator, Page = Page})
    if #self.TabBtns == 1 then
        Page.Visible = true
        Btn.BackgroundTransparency = 0
        Btn.BackgroundColor3 = Color3.fromRGB(28, 32, 48)
        Icon.ImageColor3 = self.Options.AccentColor
        Label.TextColor3 = self.Options.AccentColor
        Indicator.BackgroundTransparency = 0
    end
    return Page
end

function Library:CreateCategory(parent, text)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 22)
    Container.BackgroundTransparency = 1
    Container.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.Text = text
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 9
    Label.TextColor3 = self.Options.AccentColor
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = Container
    table.insert(self.AccentObjects.Labels, Label)

    local Line = Instance.new("Frame")
    Line.Size = UDim2.new(1, 0, 0, 1)
    Line.Position = UDim2.new(0, 0, 1, -1)
    Line.BackgroundColor3 = Color3.fromRGB(35, 40, 60)
    Line.BorderSizePixel = 0
    Line.Parent = Container
end

function Library:CreateToggle(parent, name, desc, callback)
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, 0, 0, 46)
    Card.BackgroundColor3 = Color3.fromRGB(18, 20, 30)
    Card.Parent = parent
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 10)

    local Stroke = Instance.new("UIStroke", Card)
    Stroke.Color = Color3.fromRGB(32, 36, 52)
    Stroke.Thickness = 1

    local Title = Instance.new("TextLabel")
    Title.Text = name
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 10
    Title.TextColor3 = Color3.fromRGB(235, 235, 245)
    Title.Position = UDim2.new(0, 12, 0, 8)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1
    Title.Parent = Card

    local Sub = Instance.new("TextLabel")
    Sub.Text = desc
    Sub.Font = Enum.Font.Gotham
    Sub.TextSize = 8
    Sub.TextColor3 = Color3.fromRGB(120, 125, 145)
    Sub.Position = UDim2.new(0, 12, 0, 24)
    Sub.TextXAlignment = Enum.TextXAlignment.Left
    Sub.BackgroundTransparency = 1
    Sub.Parent = Card

    local Switch = Instance.new("TextButton")
    Switch.Size = UDim2.new(0, 38, 0, 20)
    Switch.Position = UDim2.new(1, -50, 0.5, -10)
    Switch.BackgroundColor3 = Color3.fromRGB(32, 36, 52)
    Switch.Text = ""
    Switch.Parent = Card
    Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 14, 0, 14)
    Knob.Position = UDim2.new(0, 3, 0.5, -7)
    Knob.BackgroundColor3 = Color3.fromRGB(170, 175, 195)
    Knob.Parent = Switch
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    local active = false
    
    local selfLib = self
    Switch.MouseButton1Click:Connect(function()
        active = not active
        TweenService:Create(Switch, TweenInfo.new(0.2), {
            BackgroundColor3 = active and Color3.fromRGB(0, 220, 120) or Color3.fromRGB(32, 36, 52)
        }):Play()
        TweenService:Create(Knob, TweenInfo.new(0.2), {
            Position = active and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7),
            BackgroundColor3 = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(170, 175, 195)
        }):Play()
        TweenService:Create(Stroke, TweenInfo.new(0.2), {
            Color = active and selfLib.Options.AccentColor or Color3.fromRGB(32, 36, 52)
        }):Play()
        
        callback(active)
        selfLib:SaveConfig()
    end)
    return Card
end

function Library:CreateSlider(parent, name, min, max, default, callback)
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, 0, 0, 48)
    Card.BackgroundColor3 = Color3.fromRGB(18, 20, 30)
    Card.Parent = parent
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 10)

    local Stroke = Instance.new("UIStroke", Card)
    Stroke.Color = Color3.fromRGB(32, 36, 52)
    Stroke.Thickness = 1

    local Title = Instance.new("TextLabel")
    Title.Text = name
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 10
    Title.TextColor3 = Color3.fromRGB(235, 235, 245)
    Title.Position = UDim2.new(0, 12, 0, 8)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1
    Title.Parent = Card

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Text = tostring(default)
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextSize = 10
    ValueLabel.TextColor3 = self.Options.AccentColor
    ValueLabel.Position = UDim2.new(1, -52, 0, 8)
    ValueLabel.Size = UDim2.new(0, 40, 0, 12)
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Parent = Card
    table.insert(self.AccentObjects.Labels, ValueLabel)

    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, -24, 0, 4)
    Track.Position = UDim2.new(0, 12, 0, 32)
    Track.BackgroundColor3 = Color3.fromRGB(32, 36, 52)
    Track.Parent = Card
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = self.Options.AccentColor
    Fill.Parent = Track
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

    local Thumb = Instance.new("Frame")
    Thumb.Size = UDim2.new(0, 12, 0, 12)
    Thumb.AnchorPoint = Vector2.new(0.5, 0.5)
    Thumb.Position = UDim2.new(1, 0, 0.5, 0)
    Thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Thumb.Parent = Fill
    Instance.new("UICorner", Thumb).CornerRadius = UDim.new(1, 0)

    local dragging = false
    local selfLib = self
    local function Update(input)
        local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (max - min) * pos)
        TweenService:Create(Fill, TweenInfo.new(0.05), {Size = UDim2.new(pos, 0, 1, 0)}):Play()
        ValueLabel.Text = tostring(val)
        
        callback(val)
        selfLib:SaveConfig()
    end

    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            Update(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then Update(input) end
    end)
    return Card
end

function Library:CreateButton(parent, name, callback)
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, 0, 0, 34)
    Card.BackgroundColor3 = Color3.fromRGB(24, 28, 42)
    Card.Parent = parent
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 10)

    local Stroke = Instance.new("UIStroke", Card)
    Stroke.Color = Color3.fromRGB(40, 46, 68)
    Stroke.Thickness = 1

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.Text = name
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 10
    Btn.TextColor3 = self.Options.AccentColor
    Btn.BackgroundTransparency = 1
    Btn.Parent = Card
    table.insert(self.AccentObjects.Buttons, Btn)

    local selfLib = self
    Btn.MouseButton1Click:Connect(function()
        TweenService:Create(Card, TweenInfo.new(0.1), {BackgroundColor3 = selfLib.Options.AccentColor}):Play()
        TweenService:Create(Btn, TweenInfo.new(0.1), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        task.wait(0.1)
        TweenService:Create(Card, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(24, 28, 42)}):Play()
        TweenService:Create(Btn, TweenInfo.new(0.15), {TextColor3 = selfLib.Options.AccentColor}):Play()
        callback()
    end)
    return Card
end

function Library:CreateInfoCard(parent, title, content)
    local Card = Instance.new("Frame")
    Card.AutomaticSize = Enum.AutomaticSize.Y
    Card.Size = UDim2.new(1, 0, 0, 0)
    Card.BackgroundColor3 = Color3.fromRGB(18, 20, 30)
    Card.Parent = parent
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 10)

    local Stroke = Instance.new("UIStroke", Card)
    Stroke.Color = Color3.fromRGB(32, 36, 52)
    Stroke.Thickness = 1

    local Padding = Instance.new("UIPadding", Card)
    Padding.PaddingTop = UDim.new(0, 8)
    Padding.PaddingBottom = UDim.new(0, 8)
    Padding.PaddingLeft = UDim.new(0, 12)
    Padding.PaddingRight = UDim.new(0, 12)

    local Layout = Instance.new("UIListLayout", Card)
    Layout.Padding = UDim.new(0, 4)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder

    local TxtTitle = Instance.new("TextLabel", Card)
    TxtTitle.LayoutOrder = 1
    TxtTitle.Text = title
    TxtTitle.Font = Enum.Font.GothamBold
    TxtTitle.TextSize = 11
    TxtTitle.TextColor3 = self.Options.AccentColor
    TxtTitle.Size = UDim2.new(1, 0, 0, 14)
    TxtTitle.TextXAlignment = Enum.TextXAlignment.Left
    TxtTitle.BackgroundTransparency = 1
    table.insert(self.AccentObjects.Labels, TxtTitle)

    local TxtContent = Instance.new("TextLabel", Card)
    TxtContent.LayoutOrder = 2
    TxtContent.Text = content
    TxtContent.Font = Enum.Font.Gotham
    TxtContent.TextSize = 9
    TxtContent.TextColor3 = Color3.fromRGB(180, 185, 205)
    TxtContent.AutomaticSize = Enum.AutomaticSize.Y
    TxtContent.Size = UDim2.new(1, 0, 0, 0)
    TxtContent.TextWrapped = true
    TxtContent.TextXAlignment = Enum.TextXAlignment.Left
    TxtContent.BackgroundTransparency = 1
end

return Library