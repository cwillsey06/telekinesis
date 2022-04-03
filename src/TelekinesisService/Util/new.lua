function new(className: string, parent: Instance?, properties: {[string]: any}?): Instance
    local instance
    assert(pcall(function()
        instance = Instance.new(className)
    end), ("ClassName \"%s\" could not be instantiated."):format(className))

    task.defer(function()
        if not properties then return end
        for property, value in pairs(properties) do
            pcall(function()
                instance[property] = value
            end)
        end
    end)

    instance.Parent = parent
    return instance
end

return new