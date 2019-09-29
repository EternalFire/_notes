
local ui_config = require("fire.ui.config")
local Slider = { classname = "Slider" }

function Slider.new(param)
    local slider = {}
    setmetatable(slider, { __index = Slider })

    slider:ctor(param)

    local proxy = {}
    setmetatable(proxy, {
        __index = slider,
        __newindex = function(t, key, value)

        end
    })
    return proxy
end

function Slider:ctor(param)
    self.node = nil
    self.layerColor = nil
    self.block = nil

    self.size = cc.size(100, 30)
    self.blockSize = cc.size(10, 35)
    self.bgColor = cc.c4b(20, 20, 20, 190)
    self.blockColor = cc.c4b(10, 10, 10, 250)
    self.callback = nil -- (per)

    if param then
        if param.size then
            self.size.width = param.size.width
            self.size.height = param.size.height
        end

        if type(param.callback) == "function" then
            self.callback = param.callback
        end
    end

    local size = self.size
    local bgColor = self.bgColor
    local blockColor = self.blockColor
    local blockSize = self.blockSize

    local node = cc.Node:create()
    node:setContentSize(size)
    node:setAnchorPoint(cc.p(0.5, 0.5))

        local layerColor = cc.LayerColor:create(bgColor, size.width, size.height)
        layerColor:setAnchorPoint(cc.p(0.5, 0.5))
        layerColor:setIgnoreAnchorPointForPosition(false)
        layerColor:setPosition(cc.p(size.width / 2, size.height / 2))
        node:addChild(layerColor)

        local block = cc.LayerColor:create(blockColor, blockSize.width, blockSize.height)
        block:setAnchorPoint(cc.p(0.5, 0.5))
        block:setIgnoreAnchorPointForPosition(false)
        block:setPosition(cc.p(0, size.height / 2))
        node:addChild(block)

    self.node = node
    self.layerColor = layerColor
    self.block = block

    -------------------------------------------
    local option = {
        isSwallow = true,
        -- isTouchMove = true,
        beganCB = function(isInside)
            if isInside then
            end
            return isInside
        end,
        movedCB = function(touchLocation, touch)
            local p = self.node:convertToNodeSpace(touchLocation)
            self:setBlockPos(p)
            self:onPer(self.block:getPositionX(), self.size.width, self.callback)
        end,
        endedCB = function(isInside)

        end,
        cancelledCB = function()

        end,
    }
    createTouchListener(block, option)

    local option_1 = {
        isSwallow = true,
        -- isTouchMove = true,
        beganCB = function(isInside)
            if isInside then
            end
            return isInside
        end,
        endedCB = function(isInside, touchLocation, positionInNode)
            self:setBlockPos(positionInNode)
            self:onPer(self.block:getPositionX(), self.size.width, self.callback)
        end,
        cancelledCB = function()

        end,
    }
    createTouchListener(node, option_1)

end

function Slider:setBlockPos(positionInNode)
    local value = math.min(math.max(positionInNode.x, 0), self.size.width)
    self.block:setPositionX(value)
end

function Slider:onPer(cur, max, callback)
    local _max = math.max(1, max)
    local per = math.floor(cur / _max * 1000) / 1000

    if callback then
        callback(per)
    end
end

return Slider
