
function main()
    print("enter main()")

    Window = {}
    Window.prototype = { x = 0, y = 0, width = 100, height = 80 }
    Window.metatable = {}

    function Window.new(object)
        setmetatable(object, Window.metatable)
        return object
    end

    --Window.metatable.__index = function(table, key)
    --    return Window.prototype[key]
    --end

    --Window.metatable.__index = Window.prototype

    Window.metatable.__index = function(table, key)
        local value = Window.prototype[key]
        print(string.format("read   key: [%s] value:", key), value)

        if value == nil then
            --print(string.format("key: [%s] value is nil", key))
            --return nil

            --table[key] = 0
            --return table[key]

            local defaultValue = 0
            print(string.format("crete key: [%s], set %s", key, defaultValue))
            rawset(table, key, defaultValue);
            return rawget(table, key)
        end
        return value
    end

    Window.metatable.__newindex = function(table, key, newValue)
        print(string.format("update key: [%s] from", key), table[key], "to", newValue)
        --table[key] = newValue
        rawset(table, key, newValue);
    end


    --local a = { x = 15, z = 29 }
    local a = {}
    local w = Window.new(a)

    --print(w.x, w.y, w.z)
    --print(w.width)

    print(w.width11)
    print(w.width12)
    print(w.width13)

    --print(a.x, a.y, a.z)

    a.x1 = 10001
    print("a.x1=", a.x1)

    a["x1"] = -10
    print("a.x1=", a.x1)

    a["x2"] = 8421
    print("a.x2=", a.x2)
    print("exit main()")

    return
end


main();