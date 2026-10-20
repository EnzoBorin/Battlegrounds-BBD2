
local AnimationConfig = {
    PebyxBrod = {
        Idle = "rbxassetid://75788131968030",
        Walk = "rbxassetid://86208714546792"
    }
}

return AnimationConfig


-- MovementClient.client.lua

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local animationConfig = require(
    ReplicatedStorage:WaitForChild("Shared"):WaitForChild("AnimationConfig")
)

local characterConfig = animationConfig.PebyxBrod

local function setupCharacter(character)
    local humanoid = character:WaitForChild("Humanoid")
    local animator = humanoid:WaitForChild("Animator")

    -- Evita conflito com as animações padrão do Roblox.
    local defaultAnimate = character:FindFirstChild("Animate")
    if defaultAnimate then
        defaultAnimate.Disabled = true
    end

    local function loadAnimation(animationId, priority)
        local animation = Instance.new("Animation")
        animation.AnimationId = animationId

        local track = animator:LoadAnimation(animation)
        track.Priority = priority
        track.Looped = true

        return track
    end

    local idleTrack = loadAnimation(
        characterConfig.Idle,
        Enum.AnimationPriority.Idle
    )

    local walkTrack = loadAnimation(
        characterConfig.Walk,
        Enum.AnimationPriority.Movement
    )

    local currentTrack

    local function playTrack(track)
        if currentTrack == track then
            return
        end

        if currentTrack and currentTrack.IsPlaying then
            currentTrack:Stop(0.2)
        end

        currentTrack = track
        currentTrack:Play(0.2)
    end

    local function updateMovement(speed)
        if humanoid.Health <= 0 then
            return
        end

        if speed > 0.1 then
            playTrack(walkTrack)
        else
            playTrack(idleTrack)
        end
    end

    humanoid.Running:Connect(updateMovement)
    updateMovement(humanoid.MoveDirection.Magnitude > 0 and 1 or 0)

    humanoid.Died:Connect(function()
        idleTrack:Stop()
        walkTrack:Stop()
    end)
end

if player.Character then
    task.spawn(setupCharacter, player.Character)
end

player.CharacterAdded:Connect(setupCharacter)
