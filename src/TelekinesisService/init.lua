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

TelekinesisService.CurrentObjects = {}

function TelekinesisService.Client.SetLightColor(player: Player, lightColor: Color3)
    local Character = player.Character
    local Root = Character.PrimaryPart

    local Light = Root:FindFirstChild("TeleLight")
    if not Light then
        Light = new("PointLight", Root, {
            Name = "TeleLight",
            Brightness = 2.5,
            Range = 6
        })
    end

    Light.Color = lightColor
end

function TelekinesisService.Client.ThrowObject(_, ray: Ray)
    local object = TelekinesisService.CurrentObjects[#TelekinesisService.CurrentObjects]
    if not object then return end
    object.Throw(ray)
    table.remove(TelekinesisService.CurrentObjects, #TelekinesisService.CurrentObjects)
end

function TelekinesisService.Client.GrabObject(player: Player, object: BasePart)
    local Character = player.Character
    local Root = Character.PrimaryPart

    local _class = {}
    _class._ct = Caretaker.new()
    _class.Object = object

    function _class.Throw(ray: Ray)
        _class._ct:Destroy()
        _class.Object:SetNetworkOwnershipAuto()
        
        _class.Object.CanCollide = true
        _class.Object.AssemblyLinearVelocity = ray.Direction * 125
    end

    table.insert(TelekinesisService.CurrentObjects, _class)
    local i = #TelekinesisService.CurrentObjects

    local Attachment0 = new("Attachment", object)
    local AlignPosition = new("AlignPosition", object, {
        Mode = Enum.PositionAlignmentMode.OneAttachment,
        ApplyAtCenterOfMass = true,
        Attachment0 = Attachment0,
        ReactionForceEnabled = true,
        Responsiveness = 150
    })

    _class._ct:Add(Attachment0)
    _class._ct:Add(AlignPosition)

    local circle = -1 * math.pi
    local radius = -6

    local function getXAndZPositions(angle)
        local x = math.cos(angle) * radius
        local z = math.sin(angle) * radius
        return x, z
    end

    object.CanCollide = false
    object:SetNetworkOwner()

    _class._ct:Add(RunService.Heartbeat:Connect(function()
        local angle = i * (circle / #TelekinesisService.CurrentObjects)
        local x, z = getXAndZPositions(angle)

        local position = (Root.CFrame * CFrame.new(x, 0, z)).Position
        AlignPosition.Position = position
    end))

    return _class
end

return TelekinesisService