-- init.lua
-- Coltrane Willsey
-- 2022-03-31 [15:18]

local util = script.Util
local SelectionBox = require(util.selectionbox)
local Caretaker = require(util.caretaker)
local new = require(util.new)

local TelekinesisService = game:GetService("ReplicatedStorage"):WaitForChild("TelekinesisService")

local primarySelectionBox = SelectionBox.new({
    Outline = {Color = Color3.fromRGB(25, 153, 255)},
    Surface = {Transparency = 0.8}
})
primarySelectionBox.IgnoreAnchoredObjects = true

local secondarySelectionBox = SelectionBox.new({
    Outline = {Color = Color3.fromRGB(255, 191, 25)},
    Surface = {Transparency = 0.8}
})
secondarySelectionBox.IgnoreAnchoredObjects = true


local TelekinesisController = {}
TelekinesisController.CurrentObjects = {}

function TelekinesisController.GrabObject(object)
    TelekinesisService.GrabObject:InvokeServer(object)
end

primarySelectionBox.Clicked:Connect(function()
    local target = primarySelectionBox:GetTarget()
    if target then
        TelekinesisController.GrabObject(target)
    end
end)

primarySelectionBox:Start()

return {}