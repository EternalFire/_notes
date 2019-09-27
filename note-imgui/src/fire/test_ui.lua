
local function test_ui()
    local layer = State.bgLayer

    -- button
    local Button = require("fire.ui.Button")
    do
        -- local btn = Button.new{
        --     callback = function(isInside)
        --         if isInside then
        --             print("click1!!!!!!!!!!")
        --         end
        --     end
        -- }
        -- btn.node:addTo(layer)
        -- btn.node:move(110,110)
    end

    -- inputText
    local InputText = require("fire.ui.InputText")
    do
        -- local inputText = InputText.new{
        --     endCallback = function(changed, before, after)
        --         print("endCallback =>", changed, before, after)
        --     end
        -- }
        -- inputText.node:addTo(layer)
        -- inputText.node:move(210,210)
    end

    -------------------------------------------
    -- test panel
    local Panel = require("fire.ui.Panel")
    do
        local panel = Panel.new{
            size = cc.size(400, 400),
            text = "panel test!"
        }
        panel.node:addTo(layer)
        panel.node:move(display.cx, display.cy)

        local innerSize = cc.size(panel.size.width, panel.size.height * 2)
        panel.innerSize = innerSize

        for j = 1, 6 do
            for i = 1, 4 do
                local btn1 = Button.new()
                panel:addChild(btn1.node)
                local result = calcCellInfo{size = innerSize, maxCol = 4, maxRow = 8, col = i, row = j, spanCol = 0, spanRow = 0}
                btn1.node:move(result.x, result.y)
            end
        end

        for i = 1, 1 do
            local btn1 = Button.new()
            panel:addChild(btn1.node)
            local result = calcCellInfo{size = innerSize, maxCol = 4, maxRow = 8, col = i, row = 2, spanCol = 1, spanRow = 3}
            btn1.node:move(result.x, result.y)
        end

        -- test calcCellInfo()
        -- local result = calcCellInfo{size = panel.size, maxCol = 4, maxRow = 4, col = 2, row = 4, spanCol = 1, spanRow = 0}
        -- btn.node:setPosition(btn.node:getParent():convertToNodeSpace(panel.node:convertToWorldSpace(cc.p(result.x, result.y))))

        panel:removeTouchListener()
    end
    -------------------------------------------
    local Slot = require("fire.ui.Slot")
    local Edge = require("fire.ui.Edge")
    do
        local slot

        local e1 = Edge.new{
            callback = function(touchLocation)
                if slot then
                    slot.posToCheck = touchLocation
                end
            end
        }
        e1.node:addTo(layer):move(200, 500)

        local e2 = Edge.new()
        e2.node:addTo(layer):move(200, 300)

        local isInSlot = false
        slot = Slot.new{
            radius = 20,
            callback = function(isInside, per)
                isInSlot = isInside
                print(per, " in slot ?  ", isInSlot)
            end
        }
        slot.node:addTo(layer):move(50, 300)

        local option = {
            isSwallow = true,
            isTouchMove = true,
            beganCB = function(isInside, touchLocation, positionInNode)
                if isInside then

                end
                return isInside
            end,
            movedCB = function(touchLocation, touch)
                if isInSlot then
                    e1:drawArrow(nil, touchLocation, true)
                end
            end,
            endedCB = function(isInside)

            end,
            cancelledCB = function()

            end,
        }
        createTouchListener(slot.node, option)

        -- setTimeout(function()
        --     slot.node:removeFromParent()
        -- end, 3)
    end
    -------------------------------------------

    -- local ToggleButton = require("fire.ui.ToggleButton")
    -- local toggleButton = ToggleButton.new{
    --     callback = function(isOn)
    --         print("toggle:", isOn)
    --     end
    -- }
    -- toggleButton.node:addTo(layer):move(700, 40)

    -------------------------------------------
    local Toggle = require("fire.ui.Toggle")
    local toggle = Toggle.new{
        isHorizontal = false,
        callback = function(isOn, index)
            print("toggle callback ", isOn, index)
        end,
        interval = 2,
        data = {
            {
                text = "t1",
                size = cc.size(40, 40),
                callback = function(isOn)
                    print("toggle t1 !", isOn)
                end
            },
            {
                text = "t2",
                size = cc.size(40, 40),
                callback = function(isOn)
                    print("toggle t2 !", isOn)
                end
            },
            {
                text = "t3",
                size = cc.size(40, 40),
                callback = function(isOn)
                    print("toggle t3 !", isOn)
                end
            },
        }
    }
    toggle.node:addTo(layer):move(900, 400)

end

return test_ui
