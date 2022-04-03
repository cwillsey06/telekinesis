-- init.lua
-- Coltrane Willsey
-- 2022-04-02 [17:41]

-- init.lua
-- Coltrane Willsey
-- 2022-03-31 [15:18]

local RunService = game:GetService("RunService")

local util = script.Util
local Caretaker = require(util.caretaker)
local new = require(util.new)

local TelekinesisService = {}
TelekinesisService.Client = {}

function TelekinesisService.RevolveObjects(around: BasePart)
    local self = setmetatable({}, TelekinesisService)
    self._ct = Caretaker.new()

    local circle = 2 * math.pi
    local radius = 10

    local function getXAndZPositions(angle)
        local x = math.cos(angle) * radius
        local z = math.sin(angle) * radius
        return x, z
    end

    self._ct:Add(RunService.Heartbeat:Connect(function()
        for i, part in ipairs(TelekinesisService.CurrentObjects) do
            local angle = i * (circle / #TelekinesisService.CurrentObjects)
            local x, z = getXAndZPositions(angle)

            local position = (around.CFrame * CFrame.new(x, 0, z)).Position
            local lookAt = around.Position

            part.CFrame = CFrame.new(position, lookAt)
        end
    end))

    function self:Stop()
        self._ct:Destroy()
    end

    return self
end

function TelekinesisService.Client.GrabObject(player: Player, object: BasePart)
    local CurrentObjects = {}

    local Character = player.Character
    local Root = Character.PrimaryPart

    local _class = {}
    _class._ct = Caretaker.new()
    _class.Object = object

    function _class.Fling()
        _class._ct:Destroy()
        
        _class.Object.CanCollide = true
        _class.Object.Velocity = Root.CFrame.LookVector * Vector3.new(0, 3000, 4000)
    end

    table.insert(CurrentObjects, _class)
    local i = #CurrentObjects

    local Attachment0 = new("Attachment", object)
    local AlignPosition = new("AlignPosition", object, {
        Mode = Enum.PositionAlignmentMode.OneAttachment,
        ApplyAtCenterOfMass = true,
        Attachment0 = Attachment0
    })

    _class._ct:Add(Attachment0)
    _class._ct:Add(AlignPosition)

    local circle = 2 * math.pi
    local radius = 6

    local function getXAndZPositions(angle)
        local x = math.cos(angle) * radius
        local z = math.sin(angle) * radius
        return x, z
    end

    object.CanCollide = false
    _class._ct:Add(RunService.Heartbeat:Connect(function()
        local angle = i * (circle / #CurrentObjects)
        local x, z = getXAndZPositions(angle)

        local position = (Root.CFrame * CFrame.new(x, 0, z)).Position
        AlignPosition.Position = position
    end))

    return _class
end

local folder = new("Folder", game.ReplicatedStorage, {Name = "TelekinesisService"})
for k, v in pairs(TelekinesisService.Client) do
    print(typeof(v))
    if typeof(v) == "function" then
        local _f = new("RemoteFunction", folder, {
            Name = k
        })
        function _f.OnServerInvoke(_player: Player, ...)
            return v(_player, ...)
        end
    end
end

return TelekinesisService