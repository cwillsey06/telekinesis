local player = game.Players.LocalPlayer
if player.Character or player.CharacterAdded:Wait() then
    require(script.Parent)
end