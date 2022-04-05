-- init.lua
-- Coltrane Willsey
-- 2022-03-31 [15:18]

local util = script.Util
local SelectionBox = require(util.selectionbox)
local equals = require(util.equals)
local bind = require(util.bind)

local stateEnum = {
    Dead = -2;
    None = -1;
    Grab = 0;
    Throw = 1;
    OnCooldown = 2;
}

local TelekinesisService = game:GetService("ReplicatedStorage").TelekinesisService

local TelekinesisController = {}
TelekinesisController.State = stateEnum.None
TelekinesisController.CurrentObjects = {}

function TelekinesisController:_onStateChange()
    if self.State == stateEnum.Grab then
        self.SelectionBox:Start()
        TelekinesisService.SetLightColor:InvokeServer(Color3.fromRGB(125, 213, 235))
    elseif self.State == stateEnum.Throw then
        self.SelectionBox:Stop()
        TelekinesisService.SetLightColor:InvokeServer(Color3.fromRGB(230, 125, 235))
    end
end

function TelekinesisController:ChangeState(state)
    self.State = state
    task.defer(self._onStateChange, self)
end

function TelekinesisController:SwapMode()
    if self.state == stateEnum.OnCooldown then return end
    
    if self.State == stateEnum.Grab then
        self:ChangeState(stateEnum.Throw)
    elseif self.State == stateEnum.Throw then
        self:ChangeState(stateEnum.Grab)
    end
end

function TelekinesisController:ManipulateObject()
    if equals.doesNotEqual(self.State, stateEnum.None, stateEnum.Dead, stateEnum.OnCooldown) then
        local index = #self.CurrentObjects
        if self.State == stateEnum.Grab then
            local object = self.SelectionBox:GetTarget()
            if not object or self.CurrentObjects[object] then return end
            
            TelekinesisService.GrabObject:InvokeServer(object)
            table.insert(self.CurrentObjects, object)
        elseif self.State == stateEnum.Throw then
            local mouse = self.SelectionBox:GetMouse()
            TelekinesisService.ThrowObject:InvokeServer(mouse.UnitRay)

            table.remove(self.CurrentObjects, index)
        end

        self.SelectionBox:SetFilter(self.CurrentObjects)
    end
end

--

function TelekinesisController:Init()
    self.SelectionBox = SelectionBox.new({
        Outline = {Color = Color3.fromRGB(125, 213, 235)},
        Surface = {Transparency = 0.8}
    })
    self.SelectionBox.IgnoreAnchoredObjects = true

    self:Start()
end

function TelekinesisController:Start()
    self:ChangeState(stateEnum.Grab)

    bind({Enum.KeyCode.Q}, function()
        self:SwapMode()
    end)

    self.SelectionBox.Clicked:Connect(function()
        self:ManipulateObject()
    end)
end

TelekinesisController:Init()
return TelekinesisController