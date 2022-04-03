-- init.lua
-- Coltrane Willsey
-- 2022-03-31 [15:18]

local util = script.Util
local SelectionBox = require(util.selectionbox)
local bind = require(util.bind)

local TelekinesisService = game:GetService("ReplicatedStorage"):WaitForChild("TelekinesisService")

local Selector = SelectionBox.new({
    Outline = {Color = Color3.fromRGB(125, 213, 235)},
    Surface = {Transparency = 0.8}
})
Selector.IgnoreAnchoredObjects = true

local TelekinesisController = {}
TelekinesisController.CurrentObjects = {}
TelekinesisController.CurrentMode = "Grab"

function TelekinesisController:StartGrabMode()
    TelekinesisService.SetLightColor:InvokeServer(Color3.fromRGB(125, 213, 235))
    self.CurrentMode = "Grab"
    Selector:Start()
end

function TelekinesisController:StartThrowMode()
    TelekinesisController.CurrentMode = "Throw"
    self.SetLightColor:InvokeServer(Color3.fromRGB(230, 125, 235))
    Selector:Stop()
end

function TelekinesisController.SwapMode()
    if TelekinesisController.CurrentMode == "Grab" then
        TelekinesisController:StartThrowMode()
    else
        TelekinesisController:StartGrabMode()
    end
end

function TelekinesisController:ManipulateObject(object, ray)
    if TelekinesisController.CurrentMode == "Grab" then
        if not object then return end
        TelekinesisService.GrabObject:InvokeServer(object)
        table.insert(self.CurrentObjects, object)
        table.insert(Selector.Filter, object)
    elseif TelekinesisController.CurrentMode == "Throw" then
        table.remove(self.CurrentObjects, #self.CurrentObjects)
        table.remove(Selector.Filter, #Selector.Filter)
        TelekinesisService.ThrowObject:InvokeServer(ray)
    end
end

bind({Enum.KeyCode.Q}, TelekinesisController.SwapMode)

Selector.Clicked:Connect(function(_, ray)
    local target = Selector:GetTarget()
    TelekinesisController:ManipulateObject(target, ray)
end)

TelekinesisController:StartGrabMode()

return {}