print("[</>] Đang Load Game...")

if not game:IsLoaded() then
    game.Loaded:Wait()
end

getgenv().Settings = getgenv().Settings or {
    JoinTeam = true,
    Team = "Pirates"
}

print("[</>] Script By Trần Văn Hoàng !!!")

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/tranvanhoang2492000-wq/TVH_Hub/refs/heads/main/Library-UI/Library.lua"))()

local function GetCommF()
    local Remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
    if Remotes then
        return Remotes:FindFirstChild("CommF_")
    end
end

local function JoinTeam()
    local CommF = GetCommF()
    if not CommF then return end

    if game:GetService("Players").LocalPlayer.Team == nil then
        pcall(function()
            CommF:InvokeServer("SetTeam", getgenv().Settings.Team)
        end)
    end
end

if getgenv().Settings.JoinTeam then
    JoinTeam()
end

local Window = Library:CreateWindow("TVH Hub", "rbxassetid://73075320811076", "Config-TVH_Hub.json")

Library:Notify("TVH Hub", "Đã load game xong!", 5)

local MainTab = Window:CreateTab("Tự Động", "rbxassetid://6031068421")
local SettingTab = Window:CreateTab("Cài Đặt", "rbxassetid://6031280882")

task.spawn(function()
    game:GetService("Players").LocalPlayer.Idled:Connect(function()
        local virtualUser = game:GetService("VirtualUser")
        virtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        virtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end)

local decalsYeeted = false
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Terrain = Workspace.Terrain

Terrain.WaterWaveSize = 0
Terrain.WaterWaveSpeed = 0
Terrain.WaterReflectance = 0
Terrain.WaterTransparency = 0

Lighting.GlobalShadows = false
Lighting.FogEnd = 9e9
Lighting.Brightness = 0

settings().Rendering.QualityLevel = Enum.QualityLevel.Level01

for _, object in game:GetDescendants() do
    if object:IsA("BasePart") and not object:IsA("MeshPart") then
        object.Material = Enum.Material.Plastic
        object.Reflectance = 0
    elseif object:IsA("MeshPart") then
        object.Material = Enum.Material.Plastic
        object.Reflectance = 0
        object.TextureID = "rbxassetid://10385902758728957"
    elseif (object:IsA("Decal") or object:IsA("Texture")) and decalsYeeted then
        object.Transparency = 1
    elseif object:IsA("ParticleEmitter") or object:IsA("Trail") then
        object.Lifetime = NumberRange.new(0)
    elseif object:IsA("Explosion") then
        object.BlastPressure = 1
        object.BlastRadius = 1
    elseif object:IsA("Fire") or object:IsA("SpotLight") or object:IsA("Smoke") or object:IsA("Sparkles") then
        object.Enabled = false
    end
end

for _, effect in Lighting:GetChildren() do
    if effect:IsA("PostEffect") or effect:IsA("DepthOfFieldEffect") then
        effect.Enabled = false
    end
end

task.spawn(function()
    while true do
        task.wait(1)
        pcall(function()
            local map = game:GetService("Workspace"):FindFirstChild("Map")
            local water = map and map:FindFirstChild("WaterBase-Plane")
            
            if water then
                local targetSize = Vector3.new(1000, 112, 1000)
                
                if water.Size ~= targetSize then
                    water.Size = targetSize
                    
                    water.CanCollide = true 
                    
                    water.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 1, 0, 1)
                end
            end
        end)
    end
end)

local targets = {game.Workspace, game.ReplicatedStorage}

for _, container in ipairs(targets) do
    for _, v in ipairs(container:GetDescendants()) do
        if v.Name == "Lava" then
            v:Destroy()
        end
    end
end
   
loadstring(game:HttpGet("https://raw.githubusercontent.com/tranvanhoang2492000-wq/TVH_Hub/refs/heads/main/Blox-Fruits/FastAttack.lua"))()

MainTab:CreateSection("Farm Chính", "rbxassetid://6031068421")

MainTab:CreateDropdown("Chọn Vũ Khí", {"Melee", "Sword", "Blox Fruit"}, "Melee", function(selected)
    print("Vũ khí đang chọn:", selected)
end)

MainTab:CreateToggle("Auto Farm Level", false, function(state)
    print("Auto Farm Level:", state)
end)

SettingTab:CreateSection("Cài Đặt", "rbxassetid://6031280882")

SettingTab:CreateSlider("Tốc Độ Chạy (Walk Speed)", 16, 200, 16, function(value)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = value
    end
end)

SettingTab:CreateSlider("Độ Nhảy Cao (Jump Power)", 50, 300, 50, function(value)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.JumpPower = value
    end
end)

game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
    local humanoid = char:WaitForChild("Humanoid", 10)
    if humanoid then
        humanoid.WalkSpeed = CurrentWalkSpeed
        humanoid.JumpPower = CurrentJumpPower
    end
end)

SettingTab:CreateButton("Reset Lại Cấu Hình", function()
    if isfile and isfile("Config-TVH_Hub.json") then
        delfile("Config-TVH_Hub.json")
        Library:Notify("Cài Đặt", "Đã xóa cấu hình thành công, hãy re-join hoặc chạy lại script!", 5)
    end
end)

print("[</>] Load Script TVH Hub v1.0.0 Thành Công !")