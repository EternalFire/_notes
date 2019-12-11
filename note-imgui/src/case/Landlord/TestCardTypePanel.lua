
local function test()
    math.randomseed(os.time())

    for i = 1, 10 do
        math.randomseed(math.random(1, os.time()))
    end

    --
    local _m = require("case.Landlord.GetAllCardType")
    local createAllPokerData = _m.createAllPokerData
    local printPokerData = _m.printPokerData
    local getAllCardType = _m.getAllCardType
    local cardTypeNameDict = _m.cardTypeNameDict

    local allPoker = createAllPokerData()
    local curPokers

    local function getPokerStr(pokerDatas, numPerLine)
        if numPerLine == nil then
            numPerLine = 9
        end

        local temp = {}
        local num = 0
        local t = printPokerData(pokerDatas, true)
        for i = 1, #t, numPerLine do
            local t1 = {}

            for j = i, i + numPerLine - 1 do
                if t[j] ~= nil then
                    table.insert(t1, t[j])

                    num = num + 1
                end
            end

            table.insert(temp, table.concat(t1, ","))
        end

        if num < #t then
            for i = num, #t do
                table.insert(temp, t[i])
            end
        end

        return table.concat(temp, "\n")
    end

    local function createPokers()
        local num = 17

        if math.random() < 0.5 then
            num = 21
        end

        local result = {}
        local memory = {}

        while #result < num do
            local index
            while index == nil or memory[index] do
                index = math.random(1, #allPoker)

                if not memory[index] then
                    memory[index] = true
                    table.insert(result, allPoker[index])
                    break
                end
            end
        end

        print(" num, #result ===> ", num, #result)

        return result
    end

    --
    local layer = State.bgLayer
    local Panel = require("fire.ui.Panel")
    local Button = require("fire.ui.Button")

    local panel = Panel.new{
        size = cc.size(800, 650),
        text = "testing card type...",
        bgColor = cc.c4b(40, 40, 40, 255)
    }
    panel.node:addTo(layer)
    panel.node:move(display.cx, display.cy)

    local innerSize = cc.size(panel.size.width, panel.size.height * 2.2)
    panel.innerSize = innerSize

    --
    local label1 = cc.Label:create()
    label1:setAnchorPoint(cc.p(0, 1.0))
    label1:setString("pokers")
    label1:setSystemFontSize(20)
    panel:addChild(label1)

    local result = calcCellInfo{size = innerSize, maxCol = 3, maxRow = 9, col = 1, row = 1, spanCol = 1, spanRow = 0}
    label1:move(result.x, result.y)

    local label2

    --
    local btn = Button.new{
        text = "refresh",
        callback = function(isInside)
            if isInside then
                curPokers = createPokers()

                table.sort(curPokers, _sortfunc)

                if curPokers then
                    local pokerStr = getPokerStr(curPokers, 10)
                    label1:setString(pokerStr)

                    -- 牌型展示
                    local typeDict, pvDict = getAllCardType(curPokers)

                    local tStr = {}
                    for keyCardType, indexList in pairs(typeDict) do
                        local temp = {}
                        if #indexList > 0 then
                            table.insert(temp, cardTypeNameDict[keyCardType]..":")
                            local _pokerData = {}

                            for _, index in ipairs(indexList) do
                                table.insert(_pokerData, curPokers[index])
                            end

                            table.insert(temp, getPokerStr(_pokerData, 21))
                        end

                        table.insert(tStr, table.concat(temp, "\n"))
                    end

                    local str = table.concat(tStr, "\n")
                    label2:setString(str)
                end
            end
        end,
    }
    panel:addChild(btn.node)

    local result = calcCellInfo{size = innerSize, maxCol = 3, maxRow = 9, col = 1, row = 1, spanCol = 0, spanRow = 0}
    btn.node:move(result.x, result.y)

    --
    label2 = cc.Label:create()

    label2:setString("type")
    label2:setAnchorPoint(cc.p(0, 1))
    label2:setSystemFontSize(20)
    panel:addChild(label2)

    local result = calcCellInfo{size = innerSize, maxCol = 3, maxRow = 9, col = 1, row = 1, spanCol = 0, spanRow = 1}
    label2:move(result.x, result.y)

end

return {
    test = test
}
