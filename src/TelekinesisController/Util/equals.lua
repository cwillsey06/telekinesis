local equals = {}

function equals.doesEqual(a, ...)
    for _, v in ipairs({...}) do
        if a ~= v then return false end
    end
    return true
end

function equals.doesNotEqual(a, ...)
    for _, v in ipairs({...}) do
        if a == v then return false end
    end
    return true
end

return equals