
-- CombatServer.server.lua
-- Cria o evento de ataque, verifica a hitbox e aplica dano.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local shared = ReplicatedStorage:FindFirstChild("Shared")

if not shared then
	shared = Instance.new("Folder")
	shared.Name = "Shared"
	shared.Parent = ReplicatedStorage
end

local attackEvent = shared:FindFirstChild("M1Attack")

if not attackEvent then
	attackEvent = Instance.new("RemoteEvent")
	attackEvent.Name = "M1Attack"
	attackEvent.Parent = shared
end

local DAMAGE = 8
local COOLDOWN = 0.45

-- Dimensões da hitbox em studs.
local HITBOX_SIZE = Vector3.new(4, 4, 5)
local HITBOX_FORWARD_OFFSET = 3.5

local lastAttack = {}

local function performAttack(player)
	local now = os.clock()

	if lastAttack[player]
		and now - lastAttack[player] < COOLDOWN then
		return
	end

	local character = player.Character
	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")

	if not humanoid or humanoid.Health <= 0 or not root then
		return
	end

	lastAttack[player] = now

	local hitboxCFrame = root.CFrame
		* CFrame.new(0, 0, -HITBOX_FORWARD_OFFSET)

	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	overlapParams.FilterDescendantsInstances = {character}

	local parts = Workspace:GetPartBoundsInBox(
		hitboxCFrame,
		HITBOX_SIZE,
		overlapParams
	)

	local hitTargets = {}

	for _, part in ipairs(parts) do
		local target = part:FindFirstAncestorOfClass("Model")

		if target and not hitTargets[target] then
			local targetHumanoid =
				target:FindFirstChildOfClass("Humanoid")

			if targetHumanoid and targetHumanoid.Health > 0 then
				hitTargets[target] = true
				targetHumanoid:TakeDamage(DAMAGE)
			end
		end
	end
end

attackEvent.OnServerEvent:Connect(performAttack)

Players.PlayerRemoving:Connect(function(player)
	lastAttack[player] = nil
end)
