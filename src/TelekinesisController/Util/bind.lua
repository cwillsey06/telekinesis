-- bind.lua
-- Coltrane Willsey
-- 2022-03-13 [16:54]

--[[
    bind(inputTypes, callback): (binding)
    binding:unbind():
--]]

local UserInputService = game:GetService("UserInputService")

local binding = {}
binding.__index = binding

function bind(inputTypes: {Enum.KeyCode | Enum.UserInputType}, callback: () -> (InputObject), state: string?)
    local self = setmetatable({}, binding)
    
    self.InputConnection = UserInputService["Input".. (state or "Began")]:Connect(function(obj)
        for _, itype in ipairs(inputTypes) do
            if itype == obj.KeyCode or itype == obj.UserInputType then
                callback(obj)
                return
            end
        end
    end)

    return self
end

function binding:unbind()
    self.InputConnection:Disconnect()
end

return bind
