
function uniqueInsert(t, v)
    if not table.indexof(t, v) then
        table.insert(t, v)
    end
end

function chain(chain_str, root)
    root = root or _G
    chain_str = chain_str or ""

    if chain_str == "" then
        return root
    end

    local chain = string.split(chain_str, ".")
    local object = root

    for i = 1, #chain do
        local key = chain[i]
        if type(object[key]) == "table" then
            object = object[key]
        elseif type(object[key]) == "nil" then
            return nil
        end
    end

    return object
end

