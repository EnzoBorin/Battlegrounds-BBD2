
local AnimationConfig = {
    PebyxBrod = {
        Idle = "rbxassetid://75788131968030",
        Walk = "rbxassetid://86208714546792"
    }
}

return AnimationConfig


local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

local animationConfig = require(
    ReplicatedStorage:WaitForChild("Shared"):WaitForChild("AnimationConfig")
)

local function setupCharacter(character)
    local humanoid = character:WaitForChild("Humanoid")
    local animator = humanoid:WaitForChild("Animator")

    local config = animationConfig.PebyxBrod

    local function loadAnimation(animationId, priority)
        local animation = Instance.new("Animation")
        animation.AnimationId = animationId

        local track = animator:LoadAnimation(animation)
        track.Priority = priority
        track.Looped = true

        return track
    end

    local idleTrack = loadAnimation(
        config.Idle,
        Enum.AnimationPriority.Idle
    )

    local walkTrack = loadAnimation(
        config.Walk,
        Enum.AnimationPriority.Movement
    )

    local currentTrack

    local function playTrack(track)
        if currentTrack == track and track.IsPlaying then
            return
        end

        if currentTrack and currentTrack.IsPlaying then
            currentTrack:Stop(0.2)
        end

        currentTrack = track
        track:Play(0.2)
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

    updateMovement(0)

    humanoid.Died:Connect(function()
        idleTrack:Stop()
        walkTrack:Stop()
    end)
end

if player.Character then
    task.spawn(setupCharacter, player.Character)
end

player.CharacterAdded:Connect(setupCharacter)
