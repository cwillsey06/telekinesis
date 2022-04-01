-- selectionbox.lua
-- Coltrane Willsey
-- 2022-03-31 [15:32]

--[[
    -- TODO: Add documentation
--]]

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local util = script.Parent
local Caretaker = require(util.caretaker)
local new = require(util.new)

local Mouse = game.Players.LocalPlayer:GetMouse()

type SelectionBoxProperties = {
    Outline: {Color: Color3?, Transparency: number?}?,
    Surface: {Color: Color3?, Transparency: number?}?
}

function _createSelectionBox(properties: SelectionBoxProperties?): SelectionBox
    return new("SelectionBox", workspace, {
        Archivable = false;
        LineThickness = 0.02;
        Color3 = properties.Outline.Color;
        SurfaceColor3 = properties.Surface.Color or properties.Outline.Color;
        Transparency = properties.Outline.Transparency;
        SurfaceTransparency = properties.Surface.Transparency;
    })
end

local SelectionBox = {}
SelectionBox.__index = SelectionBox

SelectionBox.Clicked = Mouse.Button1Down

function SelectionBox.new(properties: SelectionBoxProperties?)
    local self = setmetatable({}, SelectionBox)
    self._ct = Caretaker.new()

    self.SelectionBox = _createSelectionBox(properties)
    self._ct:Add(self.SelectionBox)

    return self
end

function SelectionBox:GetTarget()
    return self.SelectionBox.Adornee
end

function SelectionBox:Select(target: Instance)
    pcall(function()
        self.SelectionBox.Adornee = target
    end)
end

function SelectionBox:Deselect()
    self.SelectionBox.Adornee = nil
end

function SelectionBox:Start()
    if self.service_id then
        warn("SelectionBox is already running!")
        return
    end

    local priority = Enum.RenderPriority.Input.Value
    self.service_id = "runner_".. HttpService:GenerateGUID()
    RunService:BindToRenderStep(self.service_id, priority, function()
        if Mouse.Target and not Mouse.Target.Locked then
            self:Select(Mouse.Target)
        else
            self:Deselect()
        end
    end)
end

function SelectionBox:Stop()
    if not self.service_id then
        warn("SelectionBox is not running!")
        return
    end
    
    self:Deselect()
    RunService:UnbindFromRenderStep(self.service_id)
    self.service_id = nil
end

function SelectionBox:Destroy()
    self._ct:Destroy()
end

return SelectionBox
