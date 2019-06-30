
print("load patch")

local function test()
    local scene = display.getRunningScene()
    if scene then
        scene:runAction(cc.RotateBy:create(1.0, 360 * 6))
    end
end

return test