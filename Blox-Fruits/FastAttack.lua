local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local Net = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Net")
local RegisterAttack = Net and Net:FindFirstChild("RE/RegisterAttack")
local RegisterHit = Net and Net:FindFirstChild("RE/RegisterHit")

if not RegisterAttack or not RegisterHit then
    return
end

local UserIDSlice = tostring(LocalPlayer.UserId):sub(2, 4)
local getupvalue = debug and (debug.getupvalue or getupvalues)

local function GetLiveSessionID()
    if not getupvalue then return nil end
    local success, result = pcall(function()
        local sendHitsFn = getrenv()._G.SendHitsToServer
        if not sendHitsFn then return nil end
        local combatThread = getupvalue(sendHitsFn, 1)
        if not combatThread then return nil end
        return UserIDSlice .. tostring(combatThread):sub(11, 15)
    end)

    return success and result or nil
end

local OverlapParams = OverlapParams.new()
OverlapParams.FilterType = Enum.RaycastFilterType.Exclude

local MaxAttackDistance = 45
local TargetHitParts = {}
local ProcessedModels = {}

local function UltraFastMultiTargetAttack()
    local character = LocalPlayer.Character
    if not character then return end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    local sessionID = GetLiveSessionID()
    if not sessionID then return end

    table.clear(TargetHitParts)
    table.clear(ProcessedModels)
    OverlapParams.FilterDescendantsInstances = {character}

    local nearbyParts = Workspace:GetPartBoundsInRadius(rootPart.Position, MaxAttackDistance, OverlapParams)
    local hitCount = 0

    for i = 1, #nearbyParts do
        local part = nearbyParts[i]
        local model = part.Parent

        if model and not ProcessedModels[model] then
            if model:IsA("Accessory") or model:IsA("Tool") then
                model = model.Parent
            end

            if model and not ProcessedModels[model] then
                ProcessedModels[model] = true

                local humanoid = model:FindFirstChildOfClass("Humanoid")
                local targetRoot = model:FindFirstChild("HumanoidRootPart")

                if humanoid and humanoid.Health > 0 and targetRoot then
                    local targetHitPart = model:FindFirstChild("RightLowerLeg") 
                        or targetRoot 
                        or model:FindFirstChild("UpperTorso") 
                        or model:FindFirstChild("Head")

                    if targetHitPart then
                        hitCount = hitCount + 1
                        TargetHitParts[hitCount] = targetHitPart
                    end
                end
            end
        end
    end

    if hitCount > 0 then
        RegisterAttack:FireServer(0)

        for i = 1, hitCount do
            RegisterHit:FireServer(TargetHitParts[i], {}, nil, sessionID)
        end
    end
end

RunService.Stepped:Connect(UltraFastMultiTargetAttack)
