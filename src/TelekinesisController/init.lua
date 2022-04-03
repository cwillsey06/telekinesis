-- init.lua
-- Coltrane Willsey
-- 2022-03-31 [15:18]

local util = script.Util
local SelectionBox = require(util.selectionbox)
local Caretaker = require(util.caretaker)
local bind = require(util.bind)
local new = require(util.new)

local TelekinesisService = game:GetService("ReplicatedStorage"):WaitForChild("TelekinesisService")

local Selector = SelectionBox.new({
    Outline = {Color = Color3.fromRGB(129, 112, 255)},
    Surface = {Transparency = 0.8}
})
Selector.IgnoreAnchoredObjects = true

local TelekinesisController = {}
TelekinesisController.CurrentObjects = {}
TelekinesisController.CurrentMode = "Grab"

function TelekinesisController.SwapMode()
    if TelekinesisController.CurrentMode == "Grab" then
        Selector:Stop()
        TelekinesisController.CurrentMode = "Throw"
    else
        Selector:Start()
        TelekinesisController.CurrentMode = "Grab"
    end
end

function TelekinesisController.GrabObject(object)
    if not TelekinesisController.CurrentMode == "Grab" then return end
    TelekinesisService.GrabObject:InvokeServer(object)
    table.insert(TelekinesisController.CurrentObjects, object)
    table.insert(Selector.Filter, object)
end

function TelekinesisController.ThrowObject(ray)
    if not TelekinesisController.CurrentMode == "Throw" then return end
    table.remove(TelekinesisController.CurrentObjects, #TelekinesisController.CurrentObjects)
    TelekinesisService.ThrowObject:InvokeServer(ray)
end

bind({Enum.KeyCode.Q}, TelekinesisController.SwapMode)

Selector.Clicked:Connect(function(_, ray)
    if TelekinesisController.CurrentMode == "Grab" then
        local target = Selector:GetTarget()
        if target then
            TelekinesisController.GrabObject(target)
        end
    else
        TelekinesisController.ThrowObject(ray)
    end
end)

Selector:Start()

return {}