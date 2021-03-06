
local function test_ui()
    local layer = State.bgLayer
    local bgSprite = State.bgSprite

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
        local inputText = InputText.new{
            endCallback = function(changed, before, after)
                print("endCallback =>", changed, before, after)
            end
        }
        inputText.node:addTo(layer)
        inputText.node:move(210,210)

        local inputText1 = InputText.new{
            mode = "Number",
            endCallback = function(changed, before, after)
                print("endCallback =>", changed, before, after)
            end
        }
        inputText1.node:addTo(layer)
        inputText1.node:move(130,210)

        local inputText2 = InputText.new{
            mode = "Integer",
            endCallback = function(changed, before, after)
                print("endCallback =>", changed, before, after)
            end
        }
        inputText2.node:addTo(layer)
        inputText2.node:move(40,210)
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
    do
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
        toggle.node:addTo(layer):move(900, 100)

        markIt{ worldPos = cc.p(900, 100) }
    end
    -------------------------------------------
    local Combobox = require("fire.ui.Combobox")
    do
        local combobox = Combobox.new{
            callback = function(index)
                print("option [", index, "]")
            end,
            data = {
                {
                    text = "option 1",
                    size = cc.size(80, 40),
                    callback = function()
                        print("select option1 !")
                    end
                },
                {
                    text = "option 2",
                    size = cc.size(80, 40),
                    callback = function()
                        print("select option2 !")
                    end
                },
                {
                    text = "option 3",
                    size = cc.size(80, 40),
                    -- callback = function()
                    --     print("select option3")
                    -- end
                },
            },
            defaultIndex = 3,
        }
        combobox.node:addTo(layer):move(900, 100)
    end
    -------------------------------------------
    local Slider = require("fire.ui.Slider")
    do
        local slider = Slider.new{
            callback = function(per)
                bgSprite:setScale(0.5 + 1.5 * per)
            end
        }
        slider.node:addTo(layer):move(400, 600)

        markIt{ worldPos = cc.p(400, 600) }
    end
    -------------------------------------------
    local Progressbar = require("fire.ui.Progressbar")
    do
        local progressbar = Progressbar.new{
            callback = function(per)
                -- print("progress = ", per)
            end
        }
        progressbar.node:addTo(layer):move(300, 100)

        local plus = true
        setInterval(function()
            if plus then
                progressbar.percent = progressbar.percent + 0.1
            else
                progressbar.percent = progressbar.percent - 0.1
            end

            if math.abs(progressbar.percent - 1.0) <= 0.01 then
                plus = false
            elseif progressbar.percent - 0 <= 0.01 then
                plus = true
            end
        end, 0.1)
    end
    -------------------------------------------
    local Menu = require("fire.ui.Menu")
    do
        local menu = Menu.new{
            level = 1,
            -- isHorizontal = false,
            -- size = cc.size(100, 100),
            data = {
                {
                    text = "TrendMap",
                    callback = function()
                        require("case.TrendMap.TrendEnv").play()
                    end
                },
                {
                    text = "sub menu",
                    callback = function()
                        print("2")
                    end,
                    child = {
                        {
                            text = "Landlord CardType",
                            callback = function()
                                require("case.Landlord.TestCardTypePanel").test()
                            end,
                        },
                        {
                            text = "sub 2",
                            callback = function()
                                print("2-22")
                            end,
                        },
                        {
                            text = "sub 3",
                            callback = function()
                                print("2-33")
                            end,
                            child = {
                                {
                                    text = "2-33.01",
                                    callback = function()
                                        print("2-33.01")
                                    end
                                },
                                {
                                    text = "2-33.02",
                                    callback = function()
                                        print("2-33.02")
                                    end
                                },
                                {
                                    text = "2-33.03",
                                    callback = function()
                                        print("2-33.03")
                                    end
                                },
                                {
                                    text = "2-33.04",
                                    child = {
                                        {

                                        },
                                        {
                                            callback = function()
                                                print("??!!??!!")
                                            end
                                        }
                                    }
                                },
                            }
                        }
                    }
                },
                {
                    callback = function()
                        print("3")
                    end,
                    child = {
                        {
                            text = "3-1",
                            callback = function()
                                print("3-1")
                            end
                        },
                        {
                            text = "3-2",
                            callback = function()
                                print("3-2")
                            end
                        },
                    }
                },
                {
                    callback = function()
                        print("4")
                    end
                },
                {
                    child = {
                        {}, {}, {}, {}, {}, {}, {}
                    }
                }
            }
        }
        menu.node:addTo(layer)
            -- :move(display.cx, display.height - menu.size.height / 2)
    end

end

return test_ui
