
local ui_config = require("fire.ui.config")
local Slot = {}

function Slot.new(param)
    local slot = { classname = "Slot" }
    local meta_slot = {
        __index = Slot
    }
    setmetatable(slot, meta_slot)

    slot:ctor(param)

    local meta = {}
    meta.__index = slot
    meta.__newindex = function(t, key, value)
        if key == "posToCheck" then
            slot[key] = slot[key] or cc.p(0,0)
            slot[key].x = value.x
            slot[key].y = value.y
        elseif key == "callback" then
            if type(value) == "function" then
                slot[key] = value
            end
        else
            slot[key] = value
        end
    end

    local proxy = {}
    setmetatable(proxy, meta)
    return proxy
end

function Slot:ctor(param)
    self.node = nil
    self.layerColor = nil

    self.radius = 100
    self.size = cc.size(0, 0)
    self.bgColor = cc.c4b(20, 20, 100, 200)
    ---@field cc.vec2 world position
    self.posToCheck = nil
    self.callback = nil

    if param then
        if type(param.radius) == "number" then
            self.radius = param.radius
        end

        if type(param.callback) == "function" then
            self.callback = param.callback
        end
    end

    self:setRadius(self.radius)

    local bgColor = self.bgColor
    local size = self.size

    local node = cc.Node:create()
    node:setContentSize(size)
    node:setAnchorPoint(cc.p(0.5, 0.5))

        local layerColor = cc.LayerColor:create(bgColor, size.width, size.height)
        node:addChild(layerColor)

    self.node = node
    self.layerColor = layerColor

    -- check pos whether inside slot
    local timer_id = setInterval(function(dt)
        if self.posToCheck then
            self:checkPos(self.posToCheck, self.callback)
            self.posToCheck = nil
        end
    end, 0.1)

    -- self.node:onNodeEvent("enter", function()
    --     -- print("onNodeEvent [enter]")
    -- end)

    self.node:onNodeEvent("exit", function()
        -- print("onNodeEvent [exit]")
        clearTimer(timer_id)
    end)

    -- self.node:onNodeEvent("enterTransitionFinish", function()
    --     -- print("onNodeEvent [enterTransitionFinish]")
    -- end)

    -- self.node:onNodeEvent("exitTransitionStart", function()
    --     -- print("onNodeEvent [exitTransitionStart]")
    -- end)

    -- self.node:onNodeEvent("cleanup", function()
    --     -- print("onNodeEvent [cleanup]")
    -- end)
end

function Slot:setRadius(r)
    self.radius = r
    self.size.width = math.max(10, self.radius * 2)
    self.size.height = self.size.width
end

function Slot:checkPos(worldPos, callback)
    local p = self.node:convertToNodeSpaceAR(worldPos)
    local per = cc.pGetLength(p) / math.max(1, self.radius)
    local isInside = false

    if per <= 1 then
        isInside = true
    end

    if callback then
        callback(isInside, 1 - per)
    end

    return isInside
end

return Slot
