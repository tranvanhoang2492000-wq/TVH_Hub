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

local decalsYeeted = true
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
    while task.wait(1) do
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

local PosMon = CFrame.new(0, 0, 0)
local BringMobFarm = false
local SetCFarme = 1
local tween = nil

local function Com(...)
	return game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(...)
end

local function GetIsLand(...)
	local RealtargetPos = {...}
	local targetPos = RealtargetPos[1]
	local RealTarget
	if type(targetPos) == "vector" then
		RealTarget = targetPos
	elseif type(targetPos) == "userdata" then
		RealTarget = targetPos.Position
	elseif type(targetPos) == "number" then
		RealTarget = CFrame.new(unpack(RealtargetPos)).p
	end

	local ReturnValue
	local CheckInOut = math.huge
	local Player = game.Players.LocalPlayer
	if Player.Team then
		local PlayerSpawns = game.Workspace._WorldOrigin.PlayerSpawns:FindFirstChild(tostring(Player.Team))
		if PlayerSpawns then
			for _, v in pairs(PlayerSpawns:GetChildren()) do 
				local ReMagnitude = (RealTarget - v:GetModelCFrame().p).Magnitude
				if ReMagnitude < CheckInOut then
					CheckInOut = ReMagnitude
					ReturnValue = v.Name
				end
			end
		end
		if ReturnValue then
			return ReturnValue
		end 
	end
end

local function Bypass(Point)
	local Player = game:GetService("Players").LocalPlayer
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local RootPart = Character:FindFirstChild("HumanoidRootPart")
	local Head = Character:FindFirstChild("Head")

	if not RootPart or not Head then return end

	for _, track in pairs(RootPart:GetChildren()) do
		if track:IsA("BodyVelocity") or track:IsA("BodyGyro") or track.Name == "BodyClip" then
			track:Destroy()
		end
	end

	task.wait(0.5)

	pcall(function()
		Com("AbandonQuest")
	end)

	Head:Destroy()

	if Point then
		RootPart.CFrame = Point * CFrame.new(0, 50, 0)
		task.wait(0.2)
		RootPart.CFrame = Point
		task.wait(0.1)

		RootPart.Anchored = true
		task.wait(0.1)
		RootPart.CFrame = Point
		task.wait(0.5)
		RootPart.Anchored = false

		RootPart.CFrame = Point * CFrame.new(900, 900, 900)
	end

	pcall(function()
		Com("AbandonQuest")
	end)
end

local function toTarget(...)
	local RealtargetPos = {...}
	local targetPos = RealtargetPos[1]
	local RealTarget
	if type(targetPos) == "vector" then
		RealTarget = CFrame.new(targetPos)
	elseif type(targetPos) == "userdata" then
		RealTarget = targetPos
	elseif type(targetPos) == "number" then
		RealTarget = CFrame.new(unpack(RealtargetPos))
	end

	local Player = game.Players.LocalPlayer
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local Humanoid = Character:WaitForChild("Humanoid")
	local Root = Character:WaitForChild("HumanoidRootPart")

	if Humanoid.Health <= 0 then 
		if tween then tween:Cancel() end 
		repeat task.wait() until Humanoid.Health > 0 
		task.wait(0.2) 
	end

	local tweenfunc = {}
	local Distance = (RealTarget.Position - Root.Position).Magnitude
	local Speed = Distance < 1000 and 315 or 300

	if Distance > 3000 then
		local hasSpecialItem = Player.Backpack:FindFirstChild("Special Microchip") or Character:FindFirstChild("Special Microchip") or
			Player.Backpack:FindFirstChild("God's Chalice") or Character:FindFirstChild("God's Chalice") or
			Player.Backpack:FindFirstChild("Hallow Essence") or Character:FindFirstChild("Hallow Essence") or
			Player.Backpack:FindFirstChild("Sweet Chalice") or Character:FindFirstChild("Sweet Chalice")
			
		if not hasSpecialItem then
			pcall(function()
				if tween then tween:Cancel() end

				local targetIsland = tostring(GetIsLand(RealTarget))
				if Player.Data:FindFirstChild("SpawnPoint").Value == targetIsland then 
					task.wait(0.1)
					Com("TeleportToSpawn")
				elseif Player.Data:FindFirstChild("LastSpawnPoint").Value == targetIsland then
					Humanoid:ChangeState(15)
					task.wait(0.1)
					repeat task.wait() until Humanoid.Health > 0
				else
					if Humanoid.Health > 0 then
						Root.CFrame = RealTarget
					end
					task.wait(0.08)
					Humanoid:ChangeState(15)
					repeat task.wait() until Humanoid.Health > 0
					task.wait(0.1)
					Com("SetSpawnPoint")
				end
				task.wait(0.2)
				return
			end)
		end
	end

	local tween_s = game:GetService("TweenService")
	local info = TweenInfo.new(Distance / Speed, Enum.EasingStyle.Linear)
	
	pcall(function()
		tween = tween_s:Create(Root, info, {CFrame = RealTarget})
		tween:Play()
	end)

	function tweenfunc:Stop()
		if tween then tween:Cancel() end
	end 

	function tweenfunc:Wait()
		if tween then tween.Completed:Wait() end
	end 

	return tweenfunc
end

local function InMyNetWork(object)
	if isnetworkowner then
		return isnetworkowner(object)
	else
		local Player = game.Players.LocalPlayer
		if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
			return (object.Position - Player.Character.HumanoidRootPart.Position).Magnitude <= 350
		end
		return false
	end
end

function AutoHaki()
    if not game:GetService("Players").LocalPlayer.Character:FindFirstChild("HasBuso") then
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Buso")
    end
end

local function EquipWeapon(WeaponType)
	pcall(function()
		local Player = game.Players.LocalPlayer
		local Backpack = Player.Backpack
		local Character = Player.Character
		
		for _, v in pairs(Backpack:GetChildren()) do
			if v:IsA("Tool") then
				if WeaponType == "Melee" and v.ToolTip == "Melee" then
					Character.Humanoid:EquipTool(v)
				elseif WeaponType == "Sword" and v.ToolTip == "Sword" then
					Character.Humanoid:EquipTool(v)
				elseif WeaponType == "Blox Fruit" and v.ToolTip == "Blox Fruit" then
					Character.Humanoid:EquipTool(v)
				elseif v.Name == WeaponType then
					Character.Humanoid:EquipTool(v)
				end
			end
		end
	end)
end

local function UnEquipWeapon()
	pcall(function()
		local Player = game.Players.LocalPlayer
		if Player.Character then
			for _, v in pairs(Player.Character:GetChildren()) do
				if v:IsA("Tool") then
					v.Parent = Player.Backpack
				end
			end
		end
	end)
end

task.spawn(function()
	while task.wait() do
		if setscriptable then
			setscriptable(game.Players.LocalPlayer, "SimulationRadius", true)
		end
		if sethiddenproperty then
			sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius", math.huge)
		end
	end
end)

task.spawn(function()
	while task.wait() do
		pcall(function()
			if getgenv().AutoFarmLevel and BringMobFarm then
				for _, v in pairs(game.Workspace.Enemies:GetChildren()) do
					if not string.find(v.Name, "Boss") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") then
						if (v.HumanoidRootPart.Position - PosMon.Position).Magnitude <= 400 then
							if InMyNetWork(v.HumanoidRootPart) then
								v.HumanoidRootPart.CFrame = PosMon
								v.Humanoid.JumpPower = 0
								v.Humanoid.WalkSpeed = 0
								v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
								v.HumanoidRootPart.Transparency = 1
								v.HumanoidRootPart.CanCollide = false
								if v:FindFirstChild("Head") then v.Head.CanCollide = false end
								if v.Humanoid:FindFirstChild("Animator") then
									v.Humanoid.Animator:Destroy()
								end
								v.Humanoid:ChangeState(11)
								v.Humanoid:ChangeState(14)
							end
						end
					end
				end
			end
		end)
	end
end)

MainTab:CreateSection("Farm Chính", "rbxassetid://6031068421")

getgenv().SelectWeapon = "Melee"

MainTab:CreateDropdown("Chọn Vũ Khí", {"Melee", "Sword", "Blox Fruit"}, "Melee", function(selected)
    getgenv().SelectWeapon = selected
    print("Vũ khí đang chọn:", selected)

    if selected == "Blox Fruit" then
        Library:Notify("Cảnh Báo Chọn Mục Trái", "Mục Blox Fruit chỉ dùng được cho Trái Light và Trái Băng!", 5)
    end
end)

local function QuestCheck()
	local LocalPlayer = game:GetService("Players").LocalPlayer
	local Lvl = LocalPlayer.Data.Level.Value
	
	local MobName, QuestName, QuestLevel, Mon, NPCPosition, LevelRequire, MobCFrame
	local MonQ, MobCFrameNuber

	if Lvl >= 1 and Lvl <= 9 then
		LevelRequire = 1
		if tostring(LocalPlayer.Team) == "Marines" then
			MobName = "Trainee [Lv. 5]"
			QuestName = "MarineQuest"
			QuestLevel = 1
			Mon = "Trainee"
			NPCPosition = CFrame.new(-2709.67944, 24.5206585, 2104.24585, -0.744724929, -3.97967455e-08, -0.667371571, 4.32403588e-08, 1, -1.07884304e-07, 0.667371571, -1.09201515e-07, -0.744724929)
		elseif tostring(LocalPlayer.Team) == "Pirates" then
			MobName = "Bandit [Lv. 5]"
			Mon = "Bandit"
			QuestName = "BanditQuest1"
			QuestLevel = 1
			NPCPosition = CFrame.new(1059.99731, 16.9222069, 1549.28162, -0.95466274, 7.29721794e-09, 0.297689587, 1.05190106e-08, 1, 9.22064114e-09, -0.297689587, 1.19340022e-08, -0.95466274)
		end
	end

	if not QuestName then
		local GuideModule = require(game:GetService("ReplicatedStorage").GuideModule)
		local Quests = require(game:GetService("ReplicatedStorage").Quests)
		
		LevelRequire = 0

		for _, v in pairs(GuideModule["Data"]["NPCList"]) do
			for i1, v1 in pairs(v["Levels"]) do
				if Lvl >= v1 and v1 >= LevelRequire then
					NPCPosition = v["CFrame"]
					QuestLevel = i1
					LevelRequire = v1
				end
			end
		end

		for qName, qData in pairs(Quests) do
			for _, taskData in pairs(qData) do
				if taskData["LevelReq"] == LevelRequire and qName ~= "CitizenQuest" then
					QuestName = qName
					for mobKey, _ in pairs(taskData["Task"]) do
						MobName = mobKey
						Mon = string.split(mobKey, " [Lv. ")[1]
					end
				end
			end
		end
	end

	if Lvl >= 375 and Lvl <= 449 then
		local fishmanPortal = Vector3.new(61163.8515625, 11.6796875, 1819.7841796875)
		local Char = LocalPlayer.Character
		local Root = Char and Char:FindFirstChild("HumanoidRootPart")
		
		if Root and (fishmanPortal - Root.Position).Magnitude > 3000 then
			pcall(function()
				game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance", fishmanPortal)
			end)
		end
	end

	if QuestName == "MarineQuest2" then
		QuestName = "MarineQuest2"
		QuestLevel = 1
		MobName = "Chief Petty Officer [Lv. 120]"
		Mon = "Chief Petty Officer"
		LevelRequire = 120
	elseif QuestName == "ImpelQuest" or (Lvl >= 210 and Lvl <= 249) then
		QuestName = "PrisonerQuest"
		QuestLevel = 2
		MobName = "Dangerous Prisoner [Lv. 210]"
		Mon = "Dangerous Prisoner"
		LevelRequire = 210
		NPCPosition = CFrame.new(5310.60547, 0.350014925, 474.946594, 0.0175017118, 0, 0.999846935, 0, 1, 0, -0.999846935, 0, 0.0175017118)
	elseif QuestName == "SkyExp1Quest" then
		if QuestLevel == 1 then
			NPCPosition = CFrame.new(-4721.88867, 843.874695, -1949.96643, 0.996191859, -0, -0.0871884301, 0, 1, -0, 0.0871884301, 0, 0.996191859)
		elseif QuestLevel == 2 then
			NPCPosition = CFrame.new(-7859.09814, 5544.19043, -381.476196, -0.422592998, 0, 0.906319618, 0, 1, 0, -0.906319618, 0, -0.422592998)
		end
	elseif QuestName == "Area2Quest" and QuestLevel == 2 then
		QuestName = "Area2Quest"
		QuestLevel = 1
		MobName = "Swan Pirate [Lv. 775]"
		Mon = "Swan Pirate"
		LevelRequire = 775
	end

	if MobName then
		if not MobName:find("Lv") then
			for _, v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
				local MonLV = string.match(v.Name, "%d+")
				if MonLV and v.Name:find(MobName) and tonumber(MonLV) <= Lvl + 50 then
					MobName = v.Name
					break
				end
			end
		end
		if not MobName:find("Lv") then
			for _, v in pairs(game:GetService("ReplicatedStorage"):GetChildren()) do
				local MonLV = string.match(v.Name, "%d+")
				if MonLV and v.Name:find(MobName) and tonumber(MonLV) <= Lvl + 50 then
					MobName = v.Name
					Mon = string.split(v.Name, " [")[1]
					break
				end
			end
		end
	end

	local matchingCFrames = {}
	if MobName then
		local rawName = string.gsub(MobName, "%s*%[Lv%.%s*%d+%]%s*", "")
		local cleanName = string.gsub(rawName, "%s+", "")
		
		for _, v in pairs(game.Workspace.EnemySpawns:GetChildren()) do
			if v.Name == cleanName or v.Name == rawName or v.Name:find(cleanName) then
				table.insert(matchingCFrames, v.CFrame)
			end
		end
		
		if #matchingCFrames == 0 then
			for _, v in pairs(game.Workspace.Enemies:GetChildren()) do
				if (v.Name == MobName or v.Name:find(rawName)) and v:FindFirstChild("HumanoidRootPart") then
					table.insert(matchingCFrames, v.HumanoidRootPart.CFrame)
				end
			end
		end
	end

	if #matchingCFrames == 0 and NPCPosition then
		table.insert(matchingCFrames, NPCPosition)
	end

	MobCFrame = matchingCFrames

	return {
		[1] = QuestLevel,
		[2] = NPCPosition,
		[3] = MobName,
		[4] = QuestName,
		[5] = LevelRequire,
		[6] = Mon,
		[7] = MobCFrame,
		[8] = MonQ,
		[9] = MobCFrameNuber
	}
end

task.spawn(function()
	while task.wait() do
		pcall(function()
			if not getgenv().AutoFarmLevel then return end

			local Player = game.Players.LocalPlayer
			local QuestGui = Player.PlayerGui.Main.Quest
			local CurrentQuest = QuestCheck()

			if QuestGui.Visible then
				local QuestPos = CurrentQuest[2]
				local MobTarget = CurrentQuest[3]
				local MobCleanName = CurrentQuest[6]
				local SpawnCFrames = CurrentQuest[7]

				if QuestPos and (QuestPos.Position - Player.Character.HumanoidRootPart.Position).Magnitude >= 3000 then
					Bypass(QuestPos)
				end

				local EnemyFound = false
				for _, v in pairs(game.Workspace.Enemies:GetChildren()) do
					if v.Name == MobTarget and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
						EnemyFound = true
						repeat task.wait()
							local QuestTitle = QuestGui.Container.QuestTitle.Title.Text
							if not string.find(QuestTitle, MobCleanName) then
								Com("AbandonQuest")
							else
								PosMon = v.HumanoidRootPart.CFrame
								v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
								v.HumanoidRootPart.CanCollide = false
								v.Humanoid.WalkSpeed = 0
								if v:FindFirstChild("Head") then v.Head.CanCollide = false end
								
								BringMobFarm = true
								EquipWeapon(getgenv().SelectWeapon)
								AutoHaki()
								v.HumanoidRootPart.Transparency = 1
								
								toTarget(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 5))
							end
						until not getgenv().AutoFarmLevel or not v.Parent or v.Humanoid.Health <= 0 or not QuestGui.Visible or not v:FindFirstChild("HumanoidRootPart")
						break
					end
				end

				if not EnemyFound then
					UnEquipWeapon()
					if SpawnCFrames and #SpawnCFrames > 0 then
						if SetCFarme > #SpawnCFrames or SetCFarme < 1 then
							SetCFarme = 1
						end

						local TargetCFrame = SpawnCFrames[SetCFarme]
						if TargetCFrame then
							toTarget(TargetCFrame * CFrame.new(0, 30, 5))
							if (TargetCFrame.Position - Player.Character.HumanoidRootPart.Position).Magnitude <= 50 then
								SetCFarme = SetCFarme + 1
								if SetCFarme > #SpawnCFrames then
									SetCFarme = 1
								end
								task.wait(0.5)
							end
						end
					end
				end
			else
				BringMobFarm = false
				local QuestPos = CurrentQuest[2]
				local QuestName = CurrentQuest[4]
				local QuestLv = CurrentQuest[1]
				local SpawnCFrames = CurrentQuest[7]

				if Player.Data.LastSpawnPoint.Value == tostring(GetIsLand(SpawnCFrames[1])) then
					Com("StartQuest", QuestName, QuestLv)
					task.wait(0.5)
					if SpawnCFrames[1] then
						toTarget(SpawnCFrames[1] * CFrame.new(0, 30, 20))
					end
				else
					if QuestPos and (QuestPos.Position - Player.Character.HumanoidRootPart.Position).Magnitude >= 3000 then
						Bypass(QuestPos)
					else
						repeat 
							task.wait() 
							if QuestPos then toTarget(QuestPos) end
						until not getgenv().AutoFarmLevel or not QuestPos or (QuestPos.Position - Player.Character.HumanoidRootPart.Position).Magnitude <= 20
					end

					if QuestPos and (QuestPos.Position - Player.Character.HumanoidRootPart.Position).Magnitude <= 20 then
						task.wait(0.2)
						Com("StartQuest", QuestName, QuestLv)
						task.wait(0.5)
						if SpawnCFrames[1] then
							toTarget(SpawnCFrames[1] * CFrame.new(0, 30, 20))
						end
					end
				end
			end
		end)
	end
end)

getgenv().AutoFarmLevel = false

MainTab:CreateToggle("Auto Farm Level", false, function(state)
    getgenv().AutoFarmLevel = state
    if not state then
        BringMobFarm = false
        UnEquipWeapon()
        if tween then tween:Cancel() end
    end
end)

SettingTab:CreateSection("Cài Đặt", "rbxassetid://6031280882")

getgenv().CurrentWalkSpeed = 16
getgenv().CurrentJumpPower = 50

SettingTab:CreateSlider("Tốc Độ Chạy (Walk Speed)", 16, 200, 16, function(value)
    getgenv().CurrentWalkSpeed = value
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = value
    end
end)

SettingTab:CreateSlider("Độ Nhảy Cao (Jump Power)", 50, 300, 50, function(value)
    getgenv().CurrentJumpPower = value
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.JumpPower = value
    end
end)

game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
    local humanoid = char:WaitForChild("Humanoid", 10)
    if humanoid then
        humanoid.WalkSpeed = getgenv().CurrentWalkSpeed
        humanoid.JumpPower = getgenv().CurrentJumpPower
    end
end)

SettingTab:CreateButton("Reset Lại Cấu Hình", function()
    if isfile and isfile("Config-TVH_Hub.json") then
        delfile("Config-TVH_Hub.json")
        Library:Notify("Cài Đặt", "Đã xóa cấu hình thành công, hãy re-join hoặc chạy lại script!", 5)
    end
end)

print("[</>] Load Script TVH Hub v1.0.0 Thành Công !")
