
-- CombatClient.client.lua
-- Detecta o clique esquerdo e solicita um ataque.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

local shared = ReplicatedStorage:WaitForChild("Shared")
local attackEvent = shared:WaitForChild("M1Attack")

local ATTACK_COOLDOWN = 0.45
local canAttack = true

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
		return
	end

	if not canAttack then
		return
	end

	local character = player.Character
	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then
		return
	end

	canAttack = false
	attackEvent:FireServer()

	task.delay(ATTACK_COOLDOWN, function()
		canAttack = true
	end)
end)
