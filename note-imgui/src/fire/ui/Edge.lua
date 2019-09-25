
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

    self.beganPos = nil
    self.movedPos = nil
    self.color = cc.c4f(math.random(0,1), math.random(0,1), math.random(0,1))
    self.color = cc.c4f(0, 0, 0, 1.0)
    self.lineWidth = 4

    local size = cc.size(10, 10)
    local array = {}
    local arrow_array = {}
    local arrow_array_1 = {}

    local node = cc.Node:create()
    node:setContentSize(size)
    node:setAnchorPoint(cc.p(0.5, 0.5))

        local draw = cc.DrawNode:create()
        node:addChild(draw)

        local layerColor = cc.LayerColor:create(cc.c4b(240, 40, 40, 190), size.width, size.height)
        node:addChild(layerColor)

        local arrow = cc.DrawNode:create()
        node:addChild(arrow)

    self.node = node
    self.draw = draw

    -- touch listener
    local option = {
        isSwallow = true,
        -- isTouchMove = true,
        beganCB = function(isInside, touchLocation, positionInNode)
            if isInside then
                self.beganPos = positionInNode
            end
            return isInside
        end,
        movedCB = function(touchLocation)
            local positionInNode = self.node:convertToNodeSpace(touchLocation)
            self.movedPos = positionInNode

            if self.movedPos and self.beganPos and not cc.pFuzzyEqual(self.beganPos, self.movedPos, 5) then
                self.draw:clear()
                self.draw:setLineWidth(self.lineWidth)

                array[1] = self.beganPos
                array[2] = self.movedPos
                -- self.draw:drawCardinalSpline(array, 0.5, 20, self.color)
                -- self.draw:drawCatmullRom(array, 20, self.color)
                -- self.draw:drawLine(self.beganPos, self.movedPos, self.color)
                self.draw:drawSegment(self.beganPos, self.movedPos, 2, self.color)

                local dir = cc.pNormalize(cc.pSub(self.beganPos, self.movedPos))
                local dst = cc.pAdd(self.movedPos, cc.pMul(dir, -20))
                -- local dst1 = cc.pAdd(self.movedPos, cc.pMul(dir, -15))
                local dst1 = self.movedPos
                local p1 = cc.pAdd(dst1, cc.pMul(cc.pRotateByAngle(dir, cc.p(0,0), 10), -30))
                local p2 = cc.pAdd(dst1, cc.pMul(cc.pRotateByAngle(dir, cc.p(0,0), -10), -30))
                arrow_array[1] = p1
                arrow_array[2] = dst
                arrow_array[3] = dst1

                arrow_array_1[1] = p2
                arrow_array_1[2] = dst
                arrow_array_1[3] = dst1

                arrow:clear()
                arrow:setLineWidth(self.lineWidth + 1)
                arrow:drawPolygon(arrow_array, #arrow_array, cc.c4f(1,0,0,1), 0, cc.c4f(0,0,0,1))
                arrow:drawPolygon(arrow_array_1, #arrow_array_1, cc.c4f(1,0,0,1), 0, cc.c4f(0,0,0,1))
            end
        end,
        endedCB = function()
        end,
        cancelledCB = function()
            self.draw:clear()
        end,
    }
    createTouchListener(node, option)

end

return Edge
