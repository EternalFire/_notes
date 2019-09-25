
local function test_ui()
    local layer = State.bgLayer

    local Button = require("fire.ui.Button")
    local btn = Button.new{
        callback = function()
            print("click1!!!!!!!!!!")
        end
    }
    btn.node:addTo(layer)
    btn.node:move(110,110)

    local InputText = require("fire.ui.InputText")
    local inputText = InputText.new{
        endCallback = function(changed, before, after)
            print("endCallback =>", changed, before, after)
        end
    }
    inputText.node:addTo(layer)
    inputText.node:move(210,210)

    -------------------------------------------
    -- test panel
    local Panel = require("fire.ui.Panel")
    local panel = Panel.new{
        size = cc.size(400, 400),
    }
    panel.node:addTo(layer)
    panel.node:move(display.cx, display.cy)

    local innerSize = cc.size(panel.size.width, panel.size.height * 2)
    panel.innerSize = innerSize

    for i = 1, 4 do
        local btn1 = Button.new()
        panel:addChild(btn1.node)
        local result = calcCellInfo{size = innerSize, maxCol = 4, maxRow = 8, col = i, row = 1, spanCol = 0, spanRow = 0}
        btn1.node:move(result.x, result.y)
    end

    for i = 1, 1 do
        local btn1 = Button.new()
        panel:addChild(btn1.node)
        local result = calcCellInfo{size = innerSize, maxCol = 4, maxRow = 8, col = i, row = 2, spanCol = 1, spanRow = 3}
        btn1.node:move(result.x, result.y)
    end

    -- local result = calcCellInfo{size = panel.size, maxCol = 4, maxRow = 4, col = 2, row = 4, spanCol = 1, spanRow = 0}
    -- btn.node:setPosition(btn.node:getParent():convertToNodeSpace(panel.node:convertToWorldSpace(cc.p(result.x, result.y))))
    -------------------------------------------

    local Edge = require("fire.ui.Edge")
    local e1 = Edge.new("e1_")
    e1.node:addTo(layer)
    e1.node:move(200, 500)
end

return test_ui




