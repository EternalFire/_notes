
local ui_config = require("fire.ui.config")
local Edge = {}

function Edge.new(param)
    local edge = { classname = "Edge" }

    local meta_edge = {}
    meta_edge.__index = Edge
    setmetatable(edge, meta_edge)

    edge:ctor(param)

    local meta = {}
    meta.__index = edge
    meta.__newindex = function(t, key, value)

    end

    local proxy = {}
    setmetatable(proxy, meta)
    return proxy
end

function Edge:ctor(param)
    self.node = nil
    self.draw = nil
    self.arrow = nil
    self.arrowNode = nil

    self.beganPos = nil
    self.movedPos = nil
    self.color = cc.c4f(math.random(0,1), math.random(0,1), math.random(0,1))
    self.color = cc.c4f(0.8, 0, 0, 1.0)
    self.lineWidth = 4
    self.size = cc.size(10, 10)

    --- @type fun(touchLocation:cc.vec2)
    self.callback = nil

    if param then
        if type(param.callback) == "function" then
            self.callback = param.callback
        end

        if param.size then
            self.size.width = param.size.width
            self.size.height = param.size.height
        end
    end

    local size = self.size

    local node = cc.Node:create()
    node:setContentSize(size)
    node:setAnchorPoint(cc.p(0.5, 0.5))

        local draw = cc.DrawNode:create()
        node:addChild(draw)

        local layerColor = cc.LayerColor:create(cc.c4b(240, 40, 40, 190), size.width, size.height)
        node:addChild(layerColor)

        local arrow = cc.DrawNode:create()
        node:addChild(arrow)

        local arrow_node = cc.Node:create()
        arrow_node:setContentSize(cc.size(size.width * 2, size.height * 2))
        arrow_node:setAnchorPoint(cc.p(0.5, 0.5))
        arrow_node:setVisible(false)
        node:addChild(arrow_node)

            local layerColor_1 = cc.LayerColor:create(cc.c4b(4, 4, 20, 0), size.width, size.height)
            arrow_node:addChild(layerColor_1)

    self.node = node
    self.draw = draw
    self.arrow = arrow
    self.arrowNode = arrow_node

    -- touch listener
    local option = {
        isSwallow = true,
        -- isTouchMove = true,
        boxOrRadius = math.max(size.height, size.width) * 2,
        beganCB = function(isInside, touchLocation, positionInNode)
            if isInside then
                self.beganPos = cc.p(size.width / 2, size.height / 2)
            end
            return isInside
        end,
        movedCB = function(touchLocation)
            local positionInNode = self.node:convertToNodeSpace(touchLocation)
            self.movedPos = positionInNode
            self:drawArrow(self.beganPos, self.movedPos)
        end,
        endedCB = function(isInSide, touchLocation, positionInNode, touch)
            -- self.movedPos = positionInNode
            -- self:drawArrow(self.beganPos, self.movedPos)

            if self.callback then
                self.callback(touchLocation)
            end
        end,
        cancelledCB = function()
            self.arrow:clear()
            self.draw:clear()
            self.arrowNode:setVisible(false)
        end,
    }
    createTouchListener(node, option)
    createTouchListener(arrow_node, option)
end

function Edge:drawArrow(from_pos, to_pos, isWorldSpace)
    local size = self.size
    from_pos = from_pos or cc.p(size.width / 2, size.height / 2)

    if isWorldSpace then
        if to_pos then
            to_pos = self.node:convertToNodeSpace(to_pos)
        end
    end

    if to_pos and from_pos and not cc.pFuzzyEqual(from_pos, to_pos, 5) then
        local lineWidth = self.lineWidth
        local line = self.draw
        local color = self.color
        local arrow = self.arrow
        local arrowNode = self.arrowNode

        local array = {}
        local arrow_array = {}
        local arrow_array_1 = {}
        local arrow_color = cc.c4f(0.9, 0, 0, 1)
        local arrow_border_color = cc.c4f(0, 0, 0, 0)

        line:clear()
        line:setLineWidth(lineWidth)

        array[1] = from_pos
        array[2] = to_pos
        -- self.draw:drawCardinalSpline(array, 0.5, 20, self.color)
        -- self.draw:drawCatmullRom(array, 20, self.color)
        -- self.draw:drawLine(self.beganPos, self.movedPos, self.color)
        self.draw:drawSegment(array[1], array[2], 2, color)

        local dir = cc.pNormalize(cc.pSub(from_pos, to_pos))
        local dst = cc.pAdd(to_pos, cc.pMul(dir, -20))
        -- local dst1 = cc.pAdd(self.movedPos, cc.pMul(dir, -15))
        local dst1 = to_pos
        --                                                                angle  len
        local p1 = cc.pAdd(dst1, cc.pMul(cc.pRotateByAngle(dir, cc.p(0,0),  10), -30))
        local p2 = cc.pAdd(dst1, cc.pMul(cc.pRotateByAngle(dir, cc.p(0,0), -10), -30))
        arrow_array[1] = p1
        arrow_array[2] = dst
        arrow_array[3] = dst1

        arrow_array_1[1] = p2
        arrow_array_1[2] = dst
        arrow_array_1[3] = dst1

        arrow:clear()
        arrow:setLineWidth(lineWidth + 1)
        arrow:drawPolygon(arrow_array, #arrow_array, arrow_color, 0, arrow_border_color)
        arrow:drawPolygon(arrow_array_1, #arrow_array_1, arrow_color, 0, arrow_border_color)

        arrowNode:setPosition(to_pos)
        arrowNode:setVisible(true)
    end
end

return Edge
