-- require("__cc")
-- require("LandDef")
require("case.Landlord.LandDef")

-- local LandLogic = require("LandLogic")
-- local _LandLogic = LandLogic
-- local _LandAssist = require("LandAssist")

--
STYLE_NO		=	0
STYLE_DAN		=	1

STYLE_DUI		=	2

STYLE_3TIAO		=	3
STYLE_3TIAO1	=	4
STYLE_3TIAO2	=	5

STYLE_SHUN		=	6

STYLE_LIANDUI	=	7

STYLE_FEIJI		=	8
STYLE_FEIJI11	=	9
STYLE_FEIJI22	=	10

STYLE_BOMB11	=	11
STYLE_BOMB22	=	12

STYLE_BOMB 		=	13
STYLE_BOMBX		=	14
--

local isPrintToFile = false
local m_debug = true
local m_runTest = false

local print = print

if isPrintToFile then
    local ____print = print
    local path = [[C:\Users\ls\Desktop\tmp\abc.log]]
    local mode = "a+"
    if io.exists(path) then
        print = function(content)
            content = content or ""
            content = content .. "\n"
            io.writefile(path, content, mode)
            ____print(content)
        end
    end
end

local PVs = {
    POKER_VALUE_A,
    POKER_VALUE_2,
    POKER_VALUE_3,
    POKER_VALUE_4,
    POKER_VALUE_5,
    POKER_VALUE_6,
    POKER_VALUE_7,
    POKER_VALUE_8,
    POKER_VALUE_9,
    POKER_VALUE_10,
    POKER_VALUE_J,
    POKER_VALUE_Q,
    POKER_VALUE_K,
}

local Colors = {
    POKER_STYLE_DIAMONDS,
    POKER_STYLE_CLUBS	,
    POKER_STYLE_HEARTS	,
    POKER_STYLE_SPADES	,
}

local JokerColor = POKER_STYLE_EX
local JokerValues = {
    POKER_VALUE_JOKER_SMALL,
    POKER_VALUE_JOKER_LARGE
}
local JokerPVs = {
    PV_S,
    PV_L,
}

local colorEmojiDict = {
    [POKER_STYLE_DIAMONDS] = "♦",
    [POKER_STYLE_CLUBS] = "♣",
    [POKER_STYLE_HEARTS] = "♥",
    [POKER_STYLE_SPADES] = "♠",
    [POKER_STYLE_EX] = "🃏",
}

local e2c = {
    ["♦"] = POKER_STYLE_DIAMONDS,
    ["♣"] = POKER_STYLE_CLUBS,
    ["♥"] = POKER_STYLE_HEARTS,
    ["♠"] = POKER_STYLE_SPADES,
    ["🃏"] = POKER_STYLE_EX,
}

local cardTypeNameDict = {
    [STYLE_NO] = "STYLE_NO",
    [STYLE_DAN] = "单张", -- count == 1
    [STYLE_DUI] = "对子", -- count == 2

    [STYLE_3TIAO]	= "三条", -- count == 3, 排除 2
    [STYLE_3TIAO1]	= "三条带单张", -- count == 4, 三条里面排除2
    [STYLE_3TIAO2]	= "三条带一对", -- count == 5, 三条里面排除2

    [STYLE_SHUN]	= "顺子", -- count>= 5, 排除2, 小王, 大王

    -- 三个以上的 由2个相同数字组成的 牌组, 并且牌组的数字是连续的
    [STYLE_LIANDUI]	= "连对", -- count>= 6, 排除2, 小王, 大王

    -- 两个以上的 由三个相同数字组成的 牌组, 并且牌组的数字是连续的, 排除2
    [STYLE_FEIJI]	= "三连", -- count>= 6
    [STYLE_FEIJI11]	= "三连带同数单牌", -- count>= 8
    [STYLE_FEIJI22]	= "三连带同数对子", -- count>= 10

    [STYLE_BOMB11] = "四条带二张", -- count = 6
    [STYLE_BOMB22] = "四条带二对", -- count = 8
    [STYLE_BOMB] = "炸弹", -- count = 4
    [STYLE_BOMBX] = "火箭", -- count = 2
}

local cardTypeNames = {}
for k, _ in pairs(cardTypeNameDict) do
    table.insert(cardTypeNames, k)
end
table.sort(cardTypeNames)


local function createPokerData(value, color)
    return { value, color }
end

local function createAllPokerData()
    local all = {}
    for _, c in ipairs(Colors) do
        for _, v in ipairs(PVs) do
            table.insert(all, createPokerData(v, c))
        end
    end

    table.insert(all, createPokerData(POKER_VALUE_JOKER_SMALL, JokerColor))
    table.insert(all, createPokerData(POKER_VALUE_JOKER_LARGE, JokerColor))
    return all
end

local function getPokerDataStr(pokerData)
    local value, color = pokerData[1], pokerData[2]
    local sValue
    if value == POKER_VALUE_A and color ~= POKER_STYLE_EX then
        sValue = "A"
    elseif value == POKER_VALUE_J then
        sValue = "J"
    elseif value == POKER_VALUE_Q then
        sValue = "Q"
    elseif value == POKER_VALUE_K then
        sValue = "K"
    else
        sValue = tostring(value)
    end
    local str = sValue..colorEmojiDict[color]
    return str
end

local function printPokerData(data, inline)
    print("len = ".. tostring(#data))
    local t = {}
    for i,v in ipairs(data) do
        table.insert(t, getPokerDataStr(v))
    end

    if inline then
        print(table.concat(t, ","))
    else
        print(table.concat(t, "\n"))
    end
    return t
end

local function printCardType(cardType)
    print("CardType: ".. tostring(cardTypeNameDict[cardType]))
end

local function Poker(sValue, colorEmoji)
    local value
    if sValue == "A" then
        value = POKER_VALUE_A
    elseif sValue == "J" then
        value = POKER_VALUE_J
    elseif sValue == "Q" then
        value = POKER_VALUE_Q
    elseif sValue == "K" then
        value = POKER_VALUE_K
    else
        value = tonumber(sValue)
    end
    return createPokerData(value, e2c[colorEmoji])
end

local function _P(list, sValue, colorEmoji)
    local p = Poker(sValue, colorEmoji)
    if list then
        table.insert(list, p)
    end
    return p
end

local function _Poker(sValueColor)
    local valueColorList
    local sColor
    for colorEmoji,_ in pairs(e2c) do
        valueColorList = string.split(sValueColor, colorEmoji)
        if #valueColorList > 1 then
            sColor = colorEmoji
            break
        end
    end

    if #valueColorList > 1 then
        local sValue = valueColorList[1]
        local colorEmoji = sColor
        local p = Poker(sValue, colorEmoji)
        return p
    end
end

local function _P1(list, sValueColor)
    local p = _Poker(sValueColor)
    if list then
        table.insert(list, p)
    end
    return p
end

local function _getPV(pokerData)
    return _fixlogicpv(pokerData)
end



--[[
    {
        [PV] = { count = 0, indexList = {} }
    }
]]
local _pvDict = {}
local _orderedPV = {}

--[[
    {
        [STYLE] = { indexList = {} }
    }
]]
local _typeDict = {}
local _poker_data

local function _getPVByIndex(index)
    return _getPV(_poker_data[index])
end

----------------------------------------------------------
local _typeChecker = nil

-- 单张
local function check1PV()
    local ret = false
    local indexList = {}

    for pv, t in pairs(_pvDict) do
        if t.count >= 1 then
            ret = true
            table.insert(indexList, t.indexList[1])
            break
        end
    end

    return ret, indexList
end

-- 对子
local function check2SamePV()
    local ret = false
    local indexList = {}

    for pv, t in pairs(_pvDict) do
        if t.count >= 2 then
            ret = true

            for i = 1, 2 do
                table.insert(indexList, t.indexList[i])
            end

            break
        end
    end

    return ret, indexList
end

-- 三条
local function check3SamePV()
    local ret = false
    local indexList = {}

    for pv, t in pairs(_pvDict) do
        if pv < PV_2 then
            if t.count == 3 then
                ret = true
                table.insertto(indexList, t.indexList)
                break
            end
        end
    end

    if not ret then
        for pv, t in pairs(_pvDict) do
            if pv < PV_2 then
                if t.count == 4 then
                    ret = true

                    for _, index in ipairs(t.indexList) do
                        if #indexList < 3 then
                            table.insert(indexList, index)
                        end
                    end

                    break
                end
            end
        end
    end

    return ret, indexList
end

-- 三条带单张
local function check3SamePV_()
    -- 挑选三条
    local ret, indexList = check3SamePV()
    local mark = {}
    indexList = indexList or {}

    if ret then
        ret = false

        for _, index in ipairs(indexList) do
            mark[_getPVByIndex(index)] = true
        end

        -- 挑选单张
        -- for pv, t in pairs(_pvDict) do
        for _, pv in ipairs(_orderedPV) do
            if not mark[pv] then
                local t = _pvDict[pv]
                if t and t.count == 1 then
                    ret = true
                    table.insertto(indexList, t.indexList)
                    mark[pv] = true
                    break
                end
            end
        end

        -- 挑选单张失败, 从其他相同数值的牌组里拆出单张
        if not ret then
            -- for pv, t in pairs(_pvDict) do
            for _, pv in ipairs(_orderedPV) do
                if not mark[pv] then
                    local t = _pvDict[pv]
                    if t and t.count > 1 then
                        ret = true
                        mark[pv] = true
                        local num = 0

                        for _, index in ipairs(t.indexList) do
                            num = num + 1
                            table.insert(indexList, index)

                            if num == 1 then
                                break
                            end
                        end

                        break
                    end
                end
            end
        end
    end

    return ret, indexList
end

-- 三条带一对
local function check3SamePV_PairX1()
    -- 挑选三条
    local ret, indexList = check3SamePV()
    local mark = {}
    indexList = indexList or {}

    if ret then
        ret = false

        for _, index in ipairs(indexList) do
            mark[_getPVByIndex(index)] = true
        end

        -- 挑选一对
        -- for pv, t in pairs(_pvDict) do
        for _, pv in ipairs(_orderedPV) do
            if not mark[pv] then
                local t = _pvDict[pv]
                if t and t.count == 2 then
                    ret = true
                    table.insertto(indexList, t.indexList)
                    mark[pv] = true
                    break
                end
            end
        end -- for

        -- 挑选一对失败, 从其他相同数值的牌组里拆出一对
        if not ret then
            -- for pv, t in pairs(_pvDict) do
            for _, pv in ipairs(_orderedPV) do
                if not mark[pv] then
                local t = _pvDict[pv]
                    if t and t.count > 2 then
                        ret = true
                        mark[pv] = true
                        local num = 0

                        for _, index in ipairs(t.indexList) do
                            num = num + 1
                            table.insert(indexList, index)

                            if num == 2 then
                                break
                            end
                        end

                        break
                    end
                end
            end -- for
        end
    end

    return ret, indexList
end

-- 顺子
local function checkStraight()
    local ret = false
    local indexList = {}
    local startPV = POKER_VALUE_3
    local endPV = PV_A
    local result = {{}}
    local num = 0
    local len5 = 5
    local findStraight = false

    for pv = startPV, endPV do
        local t = _pvDict[pv]
        if t and t.count > 0 then
            num = num + 1
            table.insert(result[#result], t.indexList[1])
        else
            if num >= len5 then
                findStraight = true
            end

            if num > 0 then
                table.insert(result, {})
            end

            num = 0
        end
    end

    if not findStraight then
        if #result[#result] >= len5 then
            findStraight = true
        end
    end

    if findStraight then
        local maxLenIndex = -1
        local maxLen = -1
        for i = 1, #result do
            if #result[i] > maxLen then
                maxLenIndex = i
                maxLen = #result[i]
            end
        end

        if maxLenIndex ~= -1 then
            table.merge(indexList, result[maxLenIndex])
            ret = true
        end
    end

    return ret, indexList
end

-- 连对
local function checkStraightPairs()
    local ret = false
    local indexList = {}
    local startPV = POKER_VALUE_3
    local endPV = PV_A
    local result = {{}}
    local num = 0
    local len3 = 3
    local len3x2 = len3 * 2
    local findStraight = false

    for pv = startPV, endPV do
        local t = _pvDict[pv]
        if t and t.count >= 2 then
            num = num + 1
            table.insert(result[#result], t.indexList[1])
            table.insert(result[#result], t.indexList[2])
        else
            if num >= len3 then
                findStraight = true
            end

            if num > 0 then
                table.insert(result, {})
            end

            num = 0
        end
    end

    if not findStraight then
        if #result[#result] >= len3x2 then
            findStraight = true
        end
    end

    if findStraight then
        local maxLenIndex = -1
        local maxLen = -1
        for i = 1, #result do
            if #result[i] > maxLen then
                maxLenIndex = i
                maxLen = #result[i]
            end
        end

        if maxLenIndex ~= -1 then
            table.merge(indexList, result[maxLenIndex])
            ret = true
        end
    end

    return ret, indexList
end

-- 三连
local function checkStraight3PV()
    local ret = false
    local indexList = {}
    local startPV = POKER_VALUE_3
    local endPV = PV_A
    local result = {{}}
    local num = 0
    local len2 = 2
    local len2x3 = len2 * 3
    local findStraight = false
    local retResult = {}

    for pv = startPV, endPV do
        local t = _pvDict[pv]
        if t and t.count >= 3 then
            num = num + 1

            table.insert(result[#result], t.indexList[1])
            table.insert(result[#result], t.indexList[2])
            table.insert(result[#result], t.indexList[3])
        else
            if num >= len2 then
                findStraight = true
            end

            if num > 0 then
                table.insert(result, {})
            end

            num = 0
        end
    end

    if not findStraight then
        if #result[#result] >= len2x3 then
            findStraight = true
        end
    end

    if findStraight then
        local maxLenIndex = -1
        local maxLen = -1
        for i = 1, #result do
            if #result[i] > maxLen then
                maxLenIndex = i
                maxLen = #result[i]
            end

            if #result[i] >= len2x3 then
                table.insert(retResult, result[i])
            end
        end

        if maxLenIndex ~= -1 then
            table.merge(indexList, result[maxLenIndex])
            ret = true
        end

        table.sort(retResult, function(a, b)
            return #a > #b
        end)
    end

    return ret, indexList, retResult
end

-- 三连带同数单牌
local function checkStraight3PV__N()
    local ret, indexList, straight3List = checkStraight3PV()
    local maxNum = 0
    local mark
    indexList = indexList or {}

    if ret then
        ret = false

        for i = 1, #straight3List do
            mark = {}
            maxNum = #straight3List[i] / 3
            indexList = clone(straight3List[i])

            for _, index in ipairs(indexList) do
                mark[_getPVByIndex(index)] = true
            end

            local singles = {}

            -- 选择 maxNum 个单牌
            for _, pv in ipairs(_orderedPV) do
                if pv <= PV_A then
                    if not mark[pv] then
                        local t = _pvDict[pv]
                        if t then
                            if t.count >= 1 then
                                mark[pv] = true
                                table.insert(singles, t.indexList[1])

                                if #singles == maxNum then
                                    break
                                end
                            end
                        end
                    end
                end
            end -- for

            if #singles == maxNum then
                for _, index in ipairs(singles) do
                    table.insert(indexList, index)
                end

                ret = true
                break
            end

        end -- for
    end

    return ret, indexList
end

-- 三连带同数对子
local function checkStraight3PV_PairXN()
    local ret, indexList, straight3List = checkStraight3PV()
    local mark
    local maxNum = 0
    local pairNum = 0
    local retX2 = false
    indexList = indexList or {}

    if ret then
        ret = false

        for i = 1, #straight3List do
            mark = {}
            maxNum = #straight3List[i] / 3
            indexList = clone(straight3List[i])

            for _, index in ipairs(indexList) do
                mark[_getPVByIndex(index)] = true
            end

            -- 查找 maxNum 个对子
            local pair_s = {}
            for pv, t in pairs(_pvDict) do
                if pv <= PV_A then
                    if not mark[pv] then
                        if t.count >= 2 then
                            mark[pv] = true

                            -- 111
                            for n, index in ipairs(t.indexList or {}) do
                                if n < 3 or t.count == 4 then
                                    table.insert(pair_s, index)

                                    if #pair_s == 2 * maxNum then
                                        retX2 = true
                                        break -- 111
                                    end
                                end
                            end -- for 111
                        end
                    end
                end

                if retX2 then
                    ret = true
                    table.insertto(indexList, pair_s)
                    break
                end
            end -- for

        end -- for
    end

    return ret, indexList
end

-- 四条带二张
local function check4SamePV__()
    local ret = false
    local ret4 = false
    local ret__ = false
    local indexList = {}
    local mark = {}
    local len = 6

    for pv, t in pairs(_pvDict) do
        if t.count == 4 then
            ret4 = true
            table.insertto(indexList, t.indexList)
            mark[pv] = true
            break
        end
    end

    if ret4 then
        for pv, t in pairs(_pvDict) do
            if not mark[pv] then
                if t.indexList and #t.indexList > 0 then
                    mark[pv] = true
                end

                for _, index in ipairs(t.indexList or {}) do
                    table.insert(indexList, index)

                    if #indexList == len then
                        ret__ = true
                        break
                    end
                end -- for

                if ret__ then
                    break
                end
            end
        end -- for
    end

    ret = ret4 and ret__
    return ret, indexList
end

-- 四条带二对
local function check4SamePV_PairX2()
    local ret = false
    local ret4 = false
    local retX2 = false
    local mark = {}
    local indexList = {}
    local pairNum = 0

    for pv, t in pairs(_pvDict) do
        if not mark[pv] then
            if t.count == 4 then
                ret4 = true
                table.insertto(indexList, t.indexList)
                mark[pv] = true
                break
            end
        end
    end

    if ret4 then
        -- 查找两对
        for pv, t in pairs(_pvDict) do
            if not mark[pv] then
                if t.count >= 2 then
                    mark[pv] = true

                    if t.count == 4 then

                        table.insertto(indexList, t.indexList)
                        retX2 = true
                    else
                        local num = 0

                        -- 111
                        for _, index in ipairs(t.indexList or {}) do
                            num = num + 1

                            -- 添加两张牌的索引
                            if num <= 2 then
                                table.insert(indexList, index)

                                if num == 2 then
                                    pairNum = pairNum + 1
                                end

                                -- 查找成功
                                if pairNum == 2 then
                                    retX2 = true
                                    break -- 111
                                end
                            end
                        end -- for 111
                    end
                end
            end

            if retX2 then
                ret = true
                break
            end
        end -- for
    end

    return ret, indexList
end

-- 炸弹
local function check4SamePV()
    local ret = false
    local indexList = {}
    for pv, t in pairs(_pvDict) do
        if t.count == 4 then
            ret = true
            table.insertto(indexList, t.indexList)
            break
        end
    end
    return ret, indexList
end

-- 火箭
local function checkJokers()
    local ret = true
    local indexList = {}
    for i = 1, #JokerPVs do
        local v = JokerPVs[i]
        if _pvDict[v] then
            table.insertto(indexList, _pvDict[v].indexList)
        else
            return false
        end
    end
    return true, indexList
end

local function initTypeChecker()
    if _typeChecker then return end

    local t = {}

    t[STYLE_DAN] = check1PV
    t[STYLE_DUI] = check2SamePV
    t[STYLE_3TIAO] = check3SamePV
    t[STYLE_3TIAO1] = check3SamePV_
    t[STYLE_3TIAO2] = check3SamePV_PairX1

    t[STYLE_SHUN] = checkStraight
    t[STYLE_LIANDUI] = checkStraightPairs

    t[STYLE_FEIJI] = checkStraight3PV
    t[STYLE_FEIJI11] = checkStraight3PV__N
    t[STYLE_FEIJI22] = checkStraight3PV_PairXN

    t[STYLE_BOMB11] = check4SamePV__
    t[STYLE_BOMB22] = check4SamePV_PairX2
    t[STYLE_BOMB] = check4SamePV
    t[STYLE_BOMBX] = checkJokers

    _typeChecker = t
end
----------------------------------------------------------

local function clearDict()
    _pvDict = {}
    _typeDict = {}
    _orderedPV = {}
end

local function initpvDict(_data)
    for i, pokerData in ipairs(_data or {}) do
        local v = _getPV(pokerData)
        if not _pvDict[v] then
            table.insert(_orderedPV, v)
        end

        _pvDict[v] = _pvDict[v] or {}
        _pvDict[v].count = _pvDict[v].count or 0
        _pvDict[v].indexList = _pvDict[v].indexList or {}

        table.insert(_pvDict[v].indexList, i)
        _pvDict[v].count = #_pvDict[v].indexList
    end

    table.sort(_orderedPV)
end

local function initTypeDict(_data)
    _data = _data or {}

    local __debug = true
    local ret, indexList = false, {}

    __debug = m_debug

    for k = 1, #cardTypeNames do
        local checkFunc = _typeChecker[k]

        if type(checkFunc) == "function" then
            ret, indexList = checkFunc()

            if ret then
                _typeDict[k] = indexList
            end

            if __debug then
                print("check ".. cardTypeNameDict[k])
                print("  ret = ".. tostring(ret))
                if type(indexList) == "table" then
                    print("  indexList = ".. table.concat(indexList, ","))

                    local s = ""
                    if #indexList > 0 then
                        local list = {}
                        for i = 1, #indexList do
                            list[#list + 1] = getPokerDataStr(_data[indexList[i]])
                        end
                        s = table.concat(list, ",")
                    end
                    print("              ".. s)
                end
            end
        end
    end -- for
end

local function printPVDict()
    print("_pvDict:")
    for pv, t in pairs(_pvDict) do
        local s = ""
        if #t.indexList > 0 then
            local list = {}
            for i = 1, #t.indexList do
                list[#list + 1] = getPokerDataStr(_poker_data[t.indexList[i]])
            end
            s = table.concat(list, "")
        end

        print(string.format("  pv = %d cnt = %d index = {%s}", pv, t.count, table.concat(t.indexList, ",")))
        if #t.indexList > 0 then
            print(string.format("  {%s}", s))
        end
    end
end

local function getAllCardType(_data)
    _poker_data = _data

    local __debug = true
    __debug = m_debug

    initTypeChecker()
    clearDict()

    initpvDict(_data)

    if __debug then
        printPVDict()
    end

    initTypeDict(_data)

    return _typeDict, _pvDict
end


local function main()
    print("FULL_COUNT ".. FULL_COUNT)

    local _data = createAllPokerData()
    -- printPokerData(_data, true)

    local list = {}
    --------------------------------

    -- _P(list, "A", "♦")
    -- _P(list, "A", "♣")
    -- printPokerData(list)

    --------------------------------

    local function addPoker(s)
        _P1(list, s)
    end

    local function addPokerToList(sList)
        if type(sList) == "string" then
            sList = string.split(sList, ",")
        end

        for i, v in ipairs(sList or {}) do
            addPoker(v)
        end
    end

    local memory = {}
    local function addPokerToListUnique(sList)
        if type(sList) == "string" then
            sList = string.split(sList, ",")
        end

        for i, v in ipairs(sList or {}) do
            if not memory[v] then
                memory[v] = true
                addPoker(v)
            end
        end
    end
    --------------------------------

    -- addPoker("A♥")
    -- addPoker("K♠")
    -- addPoker("1🃏")
    -- addPoker("2🃏")
    -- addPokerToList({
    --     "A♦","Q♠","10♣",
    -- })
    -- printPokerData(list, true)

    --------------------------------

    -- addPokerToList("2♦,3♦,4♦,9♥")
    -- printPokerData(list, true)

    --------------------------------

    -- addPokerToListUnique("2♦,3♦,4♦,9♥,7♦,7♦,7♦,K♥")
    -- printPokerData(list, true)

    --------------------------------

    local cardType
    local pokerData = list
    local pokerData_
    local findData

    -- addPokerToListUnique("1🃏,2🃏")
    -- addPokerToListUnique("3♦,3♣,4♥,5♥,9♠,10♦,Q♥,K♥,10♠,1🃏,2🃏,10♣,10♥")
    -- addPokerToListUnique("3♦,10♦,J♣,3♣,4♥,3♥,10♠,K♦,2♦,4♠,10♣,10♥")
    addPokerToListUnique("3♦,3♣,10♦,10♠,10♣,10♥")
    -- addPokerToListUnique("2♦,2♣,2♥,10♦,10♠")
    -- addPokerToListUnique("K♠,2♦,2♣,5♥,K♦,2♥,A♦,3♦,3♣,4♦,K♥,4♥,A♠,5♦,6♦,10♦,5♠,A♣,10♠,Q♥,J♣,K♣,A♥")
    -- addPokerToListUnique("Q♦,Q♣,Q♥,J♦,J♣,J♥,K♥,K♦,J♠,3♦,10♣,6♥,K♠")
    -- addPokerToListUnique("Q♦,Q♣,Q♥,10♣,5♣,J♦,J♣,J♥,K♥,6♣,6♥,2♣,2♥")
    -- addPokerToListUnique("7♦,7♣,7♥,J♦,J♣,J♥,J♠,6♦,6♣,6♥,K♥,10♥")
    pokerData_ = clone(list)

    -- table.sort(pokerData, _sortfunc)
    printPokerData(pokerData, true)
    -- printPokerData(pokerData_, true)

        -- cardType = LandLogic:GetCardType(pokerData)
        -- printCardType(cardType)

    -- cardType = LandLogic:GetCardType(pokerData)
    -- printCardType(cardType)
    -- findData = _LandAssist:GetCard23Tiao(pokerData)
    -- dump(findData, "GetCard23Tiao")
    -- findData = _LandAssist:GetCard2Dui(pokerData)
    -- dump(findData, "GetCard2Dui")

    local beginTime = os.clock()
    local typeDict, pvDict = getAllCardType(pokerData)
    local endTime = os.clock()
    print(endTime - beginTime)

    -- dump(_fixlogicpv(_Poker("1🃏")))
    -- dump(_fixlogicpv(_Poker("2🃏")))

    local maxLen = 0
    local maxIndex = -1

    for keyCardType, indexList in pairs(typeDict) do
        if #indexList > maxLen then
            maxLen = #indexList
            maxIndex = keyCardType
        end
    end

    if maxIndex ~= -1 then
        local _pokerData = {}
        local indexList = typeDict[maxIndex]
        for _, index in ipairs(indexList) do
            table.insert(_pokerData, pokerData[index])
        end

        print("choose: ", cardTypeNameDict[maxIndex])
        printPokerData(_pokerData, true)
    end
end

if m_runTest then
    main()
end

return {
    getAllCardType = getAllCardType,
    createAllPokerData = createAllPokerData,
    printPokerData = printPokerData,
    cardTypeNameDict = cardTypeNameDict,
}

--[[
A♦,2♦,3♦,4♦,5♦,6♦,7♦,8♦,9♦,10♦,J♦,Q♦,K♦,
A♣,2♣,3♣,4♣,5♣,6♣,7♣,8♣,9♣,10♣,J♣,Q♣,K♣,
A♥,2♥,3♥,4♥,5♥,6♥,7♥,8♥,9♥,10♥,J♥,Q♥,K♥,
A♠,2♠,3♠,4♠,5♠,6♠,7♠,8♠,9♠,10♠,J♠,Q♠,K♠,
1🃏,2🃏
]]

--[[
- 3, 4, 5, 6, 7, 8, 9, 10,
- 11, J
- 12, Q
- 13, K
- 14, A
- 15, 2
- 16, small joker
- 17, large joker
 ]]