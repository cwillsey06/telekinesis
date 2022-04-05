local service = require(script.Parent)
local new = require(script.Parent.Util.new)

local folder = new("Folder", game.ReplicatedStorage, {Name = "TelekinesisService"})
for k, v in pairs(service.Client) do
    if typeof(v) == "function" then
        local _f = new("RemoteFunction", folder, {
            Name = k
        })
        function _f.OnServerInvoke(_player: Player, ...)
            return v(_player, ...)
        end
    end
end