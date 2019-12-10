
local _print = print
-- local print = logToFile
local print = _print

-- local GameResult = {
--     Peace = 0,
--     D = 1, -- 龙
--     T = 2, -- 虎
-- }

local GameResult = {
    Peace = 2,
    D = 1, -- 龙
    T = 3, -- 虎
}

-- 显示区
local AreaA = {
    DCount = 0,
    TCount = 0,
    length = 0,
    gameResultList = nil,
}

function AreaA:init()
    self.DCount = 0
    self.TCount = 0
    self.length = 20
    self.gameResultList = {}
end

function AreaA:getResultPercent()
    local D = 0
    local T = 0
    if self.DCount + self.TCount ~= 0 then
        D = math.floor(self.DCount / (self.DCount + self.TCount) * 100)
        T = 100 - D
    end
    return D, T
end

function AreaA:fill(gameResult)
    if (gameResult == GameResult.D) then
        self.DCount = self.DCount + 1
    elseif gameResult == GameResult.T then
        self.TCount = self.TCount + 1
    end

    local len = #self.gameResultList
    local maxLen = self.length
    if (len >= maxLen) then
        local x = table.remove(self.gameResultList, 1)

        if (x == GameResult.D) then
            self.DCount = self.DCount - 1
        elseif x == GameResult.T then
            self.TCount = self.TCount - 1
        end
    end

    table.insert(self.gameResultList, gameResult)
end


-- function testAreaA()
--     local areaA = AreaA
--     areaA:init()

--     local testList = { 1,1,1,1,1, 0,0,0,2,2, 0,1,2,0,1, 2,2,0,0,0  }
--     for i,v in ipairs(testList) do
--         areaA:fill(v)
--     end

--     print(table.concat( areaA.gameResultList, ", " ))
--     print(areaA:getResultPercent())
--     print()


--     areaA:fill(GameResult.T)
--     print(table.concat( areaA.gameResultList, ", " ))
--     print(areaA:getResultPercent())

--     areaA:fill(GameResult.Peace)
--     print(table.concat( areaA.gameResultList, ", " ))
--     print(areaA:getResultPercent())
-- end

-- testAreaA()

-- 珠盘区
local AreaB = {
    rowCount = 0,
    colCount = 0,
    length = 0,
    gameResultList = nil,
}

function AreaB:init()
    self.rowCount = 6
    self.colCount = 18
    self.length = 100
    self.gameResultList = {}
end

function AreaB:fill(gameResult)
    local len = #self.gameResultList
    local maxLen = self.length
    if (len >= maxLen) then
        --table.remove(self.gameResultList, 1)
        return
    end

    table.insert(self.gameResultList, gameResult)
end

function AreaB:isFull()
    return self.length <= #self.gameResultList
end

function AreaB:getResultLen()
    return #self.gameResultList
end

function AreaB:departGameList()
    local rows = self.rowCount
    local len = #self.gameResultList
    local n = math.ceil(len / rows)
    local ret = {}

    for i = 1, n do
        local s = (i - 1) * rows + 1
        local e = s + rows - 1
        local k = 1
        ret[i] = {}

        for j = s, e do
            if (self.gameResultList[j] ~= nil) then
                ret[i][k] = self.gameResultList[j]
                k = k + 1
            end
        end
    end

    return ret
end

function AreaB:getColRow()
    local rows = self.rowCount
    local len = #self.gameResultList
    local col = math.ceil(len / rows)
    local row = len % rows
    if row == 0 then
        row = rows
    end
    return col, row
end

function AreaB:show()
    local s = "isFull: ".. tostring(self:isFull()).."\n"

    local list = self:departGameList()
    for i,v in ipairs(list) do
        s = s..table.concat(v, ", ").."\n"
    end

    print(s)
end

-- function testAreaB()
--     local testList = {
--         1,1,1,1,1,2,
--         0,0,0,2,2,0,
--         1,0,1,2,0,1,
--         2,2,0,0,0,2,
--         0,0,1,2,1,2,
--         2,0,1,0,1,0,
--         0,2,1,0,1,0,
--         1,1,1,1,1,2,
--         0,0,0,2,2,0,
--         1,0,1,2,0,1,
--         2,2,0,0,0,2,
--         0,0,1,2,1,2,
--         2,0,1,0,1,0,
--         0,2,1,0,1,0,
--         0,0,0,2,2,0,
--         1,0,1,2,0,1,
--         2,2,0,0,0,2,
--         0,0,1,2,1,2,
--     }
--     local areaB = AreaB

--     areaB:init()
--     for i,v in ipairs(testList) do
--         areaB:fill(v)
--     end

--     print(areaB:isFull())

--     local ret = areaB:departGameList()

--     print(ret)


-- end

-- testAreaB()

-- 大路
local createAreaCItem = function()
    local cItem = {
        gameResult = nil,
        num = 0, -- 数字
    }
    return cItem
end


local AreaC = {
    rowCount = 0,
    initColCount = 0,
    length = 0,
    cItemList = nil,
    curIndex = 0,
    lastGameResult = nil,
    lastCItemRow = nil,
    lastCItemCol = nil,
}

function AreaC:init()
    self.rowCount = 6
    self.initColCount = 24
    self.length = self.initColCount
    self.cItemList = {}
    self.curIndex = 1
    self.lastGameResult = nil -- 最后一个添加的结果
    self.lastCItemRow = nil -- 最后一个添加的结果所在行的索引
    self.lastCItemCol = nil -- 最后一个添加的结果所在列的索引
end

function AreaC:fill(gameResult)
    local len = #self.cItemList
    local maxLen = self.length
    if (len > maxLen) then
        self.length = self.length + 1
    end

    local list = self.cItemList[self.curIndex]
    if not list then
        self.cItemList[self.curIndex] = {}
        list = self.cItemList[self.curIndex]
    end

    local lastItem = list[#list]
    if (lastItem ~= nil) then
        -- 判断 本次结果 是否和 上一个结果 相同
        if (lastItem.gameResult == gameResult) then
        -- if (self.lastGameResult == gameResult) then
            if (gameResult == GameResult.D or gameResult == GameResult.T) then

                local item = createAreaCItem()
                item.gameResult = gameResult

                list[#list + 1] = item
            else
                -- is Peace
                lastItem.num = lastItem.num + 1
            end
        else
            if (gameResult ~= GameResult.Peace) then
                if (lastItem.gameResult == GameResult.Peace) then
                    lastItem.gameResult = gameResult
                else
                    -- 新开一列
                    local newList = {}
                    self.cItemList[len + 1] = newList
                    self.curIndex = #self.cItemList

                    local item = createAreaCItem()
                    item.gameResult = gameResult
                    newList[#newList + 1] = item

                    list = newList
                end
            else
                -- is Peace
                -- local item = createAreaCItem()
                -- item.gameResult = gameResult
                -- item.num = 1

                -- list[#list + 1] = item
                lastItem.num = lastItem.num + 1
            end
        end
    else
        -- lastItem is nil
        local item = createAreaCItem()
        item.gameResult = gameResult

        if (gameResult == GameResult.Peace) then
            item.num = 1
        end

        list[#list + 1] = item
    end

    self.lastGameResult = gameResult
    self.lastCItemCol = self.curIndex
    self.lastCItemRow = #list
end

-- 当前大路列数
function AreaC:getItemLen()
    return #self.cItemList
end

function AreaC:getItem(colIndex, rowIndex)
    if self.cItemList then
        local colList = self.cItemList[colIndex]
        if colList then
            return colList[rowIndex]
        end
    end
end

function AreaC:clearItemList()

end

function AreaC:show()
    local ss = ""
    local list = self.cItemList
    for i,v in ipairs(list) do
        local _list = v
        local str = ""

        for j, cItem in ipairs(_list) do
            local gameResult = cItem.gameResult
            local num = cItem.num

            if num ~= nil then
                str = str .. "(" .. gameResult .. "," .. num .. "), "
            else
                str = str .. "(" .. gameResult .. "), "
            end
        end

        if #str > 0 then
            -- print(str)
            ss = ss .. str .. "\n"
        end
    end

    print(ss)
end

function AreaC:walkItemList(callback)
    if not callback then
        return
    end

    local list = self.cItemList
    for i,v in ipairs(list) do
        local _list = v
        if _list then
            for j, cItem in ipairs(_list) do
                local gameResult = cItem.gameResult
                callback(gameResult)
            end
        end
    end
end

-- 获取下一个元素所在行与列
function AreaC:getNextColRow(gameResult)
    local col = self.lastCItemCol
    local row = self.lastCItemRow
    local len = #self.cItemList    

    local list = self.cItemList[self.curIndex]
    if not list then
        list = {}
    end

    local lastItem = list[#list]
    if (lastItem ~= nil) then
        -- 判断 本次结果 是否和 上一个结果 相同
        if (lastItem.gameResult == gameResult) then
            if (gameResult == GameResult.D or gameResult == GameResult.T) then

                row = row + 1
            else
                -- is Peace
            end
        else
            if (gameResult ~= GameResult.Peace) then
                if (lastItem.gameResult == GameResult.Peace) then
                    -- lastItem.gameResult = gameResult
                else
                    -- 新开一列
                    col = col + 1
                    row = 1
                end
            else
                -- is Peace
                -- lastItem.num = lastItem.num + 1
            end
        end
    else
        if gameResult ~= GameResult.Peace then
            row = row + 1
        end
    end

    return col, row
end

-- 齐整
function AreaC:isBalanced(curIndex, refIndex)
    local list = self.cItemList
    if list then
        local curList = list[curIndex]
        local refList = list[refIndex]
        if (curList and refList and #curList == #refList) then
            return true
        end
    end
    return false
end

-- 有无
function AreaC:hasNeighbor(curIndex, refIndex, rowIndex)
    local list = self.cItemList
    if list then
        local curList = list[curIndex]
        local refList = list[refIndex]
        if (curList and refList) then
            local curItem = curList[rowIndex]
            local refItem = refList[rowIndex]
            if (curItem and refItem) then
                return true
            end
        end
    end
    return false
end

-- 直落
function AreaC:isStraight(curIndex, refIndex, rowIndex)
    local list = self.cItemList
    if list then
        local curList = list[curIndex]
        local refList = list[refIndex]
        if (curList and refList) then
            if (rowIndex > 0) then
                local lastRow = rowIndex - 1
                local ret = self:hasNeighbor(curIndex, refIndex, lastRow)
                if not ret then
                    return true
                end
            end
        end
    end
    return false
end

-- 有无(预测)
function AreaC:hasNeighborTest(curIndex, refIndex, rowIndex, prediction)
    local list = self.cItemList
    if list then
        local curList = list[curIndex] or {}
        local refList = list[refIndex]
        if (curList and refList) then
            local curItem = curList[rowIndex] or prediction
            local refItem = refList[rowIndex]
            if (curItem and refItem) then
                return true
            end
        end
    end
    return false
end

-- 直落(预测)
function AreaC:isStraightTest(curIndex, refIndex, rowIndex, prediction)
    local list = self.cItemList
    if list then
        local curList = list[curIndex] or {}
        local refList = list[refIndex]
        if (curList and refList) then
            if (rowIndex > 0) then
                local lastRow = rowIndex - 1
                local ret = self:hasNeighbor(curIndex, refIndex, lastRow)
                if not ret then
                    return true
                end
            end
        end
    end
    return false
end

-- 某一列是否有非和局结果
function AreaC:hasDorT(colIndex)
    local list = self.cItemList
    if list then
        local colList = list[colIndex]
        if colList then
            for i,v in ipairs(colList) do
                if v and (v.gameResult == GameResult.D or v.gameResult == GameResult.T) then
                    return true
                end
            end
        end
    end
    return false
end

-- function testAreaC()
--     local testList = {
--         1,2,2,2,1,1,
--         -- 1,2,1,1,1,2,
--         2,2,0,2,0,1,
--         -- 1,1,2,1,2,2,
--         -- 1,1,1,1,2,1,
--         -- 1,
--     }

--     local areaC = AreaC
--     areaC:init()

--     for i,v in ipairs(testList) do
--         areaC:fill(v)
--     end

--     areaC:show()
--     print()

--     -- areaC:walkItemList(function(x)
--     --     print(x)
--     -- end)
-- end

-- testAreaC()

-- 大眼仔

-- 填充下三路
-- 参数:
--       refColA, refColB: 判断齐整的列索引
--       refColIndex: 参考列的列索引
-- 返回: 
--       true: left;
--       false: right;
local fillDEF = function(areaC, colInAreaC, rowInAreaC, refColA, refColB, refColIndex)
    if rowInAreaC == 1 then
        -- 判断齐整
        local balance = areaC:isBalanced(refColA, refColB)
        if balance then
            return false -- right
        else
            return true -- left
        end            
    else 
        -- 判断直落
        local straight = areaC:isStraight(colInAreaC, refColIndex, rowInAreaC)
        if straight then
            return false;-- right
        else
            -- 判断有无
            local ret = areaC:hasNeighbor(colInAreaC, refColIndex, rowInAreaC)
            if ret then
                return false;-- right
            else
                return true;-- left
            end
        end
    end
end

-- 预测下三路结果
-- 参数:
--      prediction: 假设出现的游戏结果
local preFillDEF = function(areaC, colInAreaC, rowInAreaC, refColA, refColB, refColIndex, prediction)
    if rowInAreaC == 1 then
        -- 判断齐整
        local balance = areaC:isBalanced(refColA, refColB)
        if balance then
            return false -- right
        else
            return true -- left
        end            
    else 
        -- 判断直落
        local straight = areaC:isStraightTest(colInAreaC, refColIndex, rowInAreaC, prediction)
        if straight then
            return false;-- right
        else
            -- 判断有无
            local ret = areaC:hasNeighborTest(colInAreaC, refColIndex, rowInAreaC, prediction)
            if ret then
                return false;-- right
            else
                return true;-- left
            end
        end
    end
end

local createAreaDItem = function()
    local DItem = {
        leftList = nil,
        rightList = nil,
    }
    return DItem
end

local AreaD = {
    areaC = nil, -- 大路对象
    rowCount = 0,
    initColCount = 0,
    length = 0,
    dItemList = nil,
    isLastModifyLeft = nil, -- 上一次是否添加到左侧
    startColInAreaC = 0, -- 大路中的起始列
    startRowInAreaC = 0, -- 大路中的起始行
}

function AreaD:init(areaC)
    if not areaC then print("areaC is nil") end

    self.areaC = areaC
    self.rowCount = 6
    self.initColCount = 12
    self.length = self.initColCount
    self.dItemList = { }
    self.isLastModifyLeft = nil

    -- 从大路的第二行第二列开始
    self.startColInAreaC = 2
    self.startRowInAreaC = 2
end

-- 大路添加元素后调用, 生成大眼仔的元素
-- 参数:
--      gameResult: 一局的结果
--      colInAreaC: 当前所在大路中的列索引
--      rowInAreaC: 当前所在大路中的行索引
function AreaD:fill(gameResult, colInAreaC, rowInAreaC)
    -- 跳过 Peace
    if (gameResult == GameResult.Peace) then
        return
    end

    -- 从大路的 第M行(startRowInAreaC) 第N列(startColInAreaC) 开始
    if colInAreaC == self.startColInAreaC and rowInAreaC < self.startRowInAreaC then
        return
    end

    if colInAreaC >= self.startColInAreaC and rowInAreaC >= 1 then
        local len = #self.dItemList
        local item = self.dItemList[len]
        if not item then
            item = self:createAreaItem()
            self.dItemList[len + 1] = item
        end

        -- 判断齐整的两列
        local refColA = self:getRefColA(colInAreaC)
        local refColB = self:getRefColB(colInAreaC)
        local refCol = self:getRefCol(colInAreaC)
        local ret = fillDEF(self.areaC, colInAreaC, rowInAreaC, refColA, refColB, refCol)

        if self.isLastModifyLeft == nil then
            if ret then
                -- left
                item.leftList = item.leftList or {}
                table.insert(item.leftList, ret)

                self.isLastModifyLeft = true
            else
                -- right
                item.rightList = item.rightList or {}
                table.insert(item.rightList, ret)

                self.isLastModifyLeft = false
            end
        else
            if ret then
                -- left
                if ret == self.isLastModifyLeft then
                    -- 与上次修改的列相同
                    item.leftList = item.leftList or {}
                    table.insert(item.leftList, ret)
                else
                    if not item.leftList or #item.leftList == 0 then
                        item.leftList = item.leftList or {}
                        table.insert(item.leftList, ret)
                    else
                        -- 新建一列
                        local newItem = self:createAreaItem()
                        self.dItemList[len + 1] = newItem

                        newItem.leftList = {}
                        table.insert(newItem.leftList, ret)
                    end
                end

                self.isLastModifyLeft = true
            else
                -- right
                if ret == self.isLastModifyLeft then
                    -- 与上次修改的列相同
                    item.rightList = item.rightList or {}
                    table.insert(item.rightList, ret)
                else
                    if not item.rightList or #item.rightList == 0 then
                        item.rightList = item.rightList or {}
                        table.insert(item.rightList, ret)
                    else
                        -- 新建一列
                        local newItem = self:createAreaItem()
                        self.dItemList[len + 1] = newItem

                        newItem.rightList = {}
                        table.insert(newItem.rightList, ret)
                    end
                end

                self.isLastModifyLeft = false
            end
        end
    end

    self.length = #self.dItemList
end

-- 前一列
function AreaD:getRefColA(colInAreaC)
    return colInAreaC - 1
end

-- 前两列
-- AreaE, AreaF 需要重写
function AreaD:getRefColB(colInAreaC)
    return colInAreaC - 2
end

-- 参考列
-- AreaE, AreaF 需要重写
function AreaD:getRefCol(colInAreaC)
    return colInAreaC - 1
end

function AreaD:createAreaItem()
    return createAreaDItem()
end

-- 预测结果
function AreaD:predict(gameResult, colInAreaC, rowInAreaC)
    -- 跳过 Peace
    if (gameResult == GameResult.Peace) then
        return
    end

    -- 从大路的 第M行(startRowInAreaC) 第N列(startColInAreaC) 开始
    if colInAreaC == self.startColInAreaC and rowInAreaC < self.startRowInAreaC then
        return
    end

    if colInAreaC >= self.startColInAreaC and rowInAreaC >= 1 then

        -- 判断齐整的两列
        local refColA = self:getRefColA(colInAreaC)
        local refColB = self:getRefColB(colInAreaC)
        local refCol = self:getRefCol(colInAreaC)
        local ret = preFillDEF(self.areaC, colInAreaC, rowInAreaC, refColA, refColB, refCol, gameResult)
        return ret
    end
end

function AreaD:show()
    if self.dItemList then
        local str = ""
        for i,v in ipairs(self.dItemList) do
            local dItem = v
            if dItem then
                local leftCount = dItem.leftList and #dItem.leftList or 0
                local rightCount = dItem.rightList and #dItem.rightList or 0        
                local s = "left: "..leftCount.." right:"..rightCount
                str = str..s.."\n"
            end
        end
        print(str)
    end
end

-- function testAreaD()
--     -- local testList = {
--     --     2, 1, 1, 1, 1, 1,
--     --     2, 1, 0, 2, 2, 1,
--     -- }

--     local testList = {
--         1,2,2,2,1,1,
--         1,2,1,1,1,2,
--         0,1,1,1,1,1,
--         1,1,2,1,2,2,
--         1,1,1,1,2,1,
--         1,
--     }

--     local areaC = AreaC
--     areaC:init()

--     local areaD = AreaD
--     areaD:init(areaC)

--     for i,v in ipairs(testList) do
--         areaC:fill(v)
--         -- print(v, areaC.lastCItemRow, areaC.lastCItemCol)
--         areaD:fill(v, areaC.lastCItemCol, areaC.lastCItemRow)
--     end

--     areaC:show()
--     print()

--     areaD:show()
--     print()
-- end

-- testAreaD()

-- 小路
local AreaE = {}
setmetatable(AreaE, { __index = AreaD })

function AreaE:init(areaC)
    -- getmetatable(self).__index:init(areaC)
    self.areaC = areaC
    self.rowCount = 6
    self.initColCount = 12
    self.length = self.initColCount
    self.dItemList = { }
    self.isLastModifyLeft = nil

    -- 从大路的第二行第三列开始
    self.startColInAreaC = 3
    self.startRowInAreaC = 2
end

function AreaE:getRefColB(colInAreaC)
    return colInAreaC - 3
end

function AreaE:getRefCol(colInAreaC)
    return colInAreaC - 2
end

-- function testAreaE()
--     local testList = {
--         1,2,2,2,1,1,
--         1,2,1,1,1,2,
--         0,1,1,1,1,1,
--         1,1,2,1,2,2,
--         1,1,1,1,2,1,
--         1,
--     }

--     local areaC = AreaC
--     areaC:init()

--     local areaD = AreaD
--     areaD:init(areaC)

--     local areaE = AreaE
--     areaE:init(areaC)

--     for i,v in ipairs(testList) do
--         areaC:fill(v)
--         -- print(v, areaC.lastCItemRow, areaC.lastCItemCol)
--         areaD:fill(v, areaC.lastCItemCol, areaC.lastCItemRow)
--         areaE:fill(v, areaC.lastCItemCol, areaC.lastCItemRow)
--     end

--     areaC:show()
--     print()

--     areaD:show()
--     print()

--     areaE:show()
--     print()
    
-- end

-- testAreaE()

-- 曱甴路
local AreaF = {}
setmetatable(AreaF, { __index = AreaD })

function AreaF:init(areaC)
    self.areaC = areaC
    self.rowCount = 6
    self.initColCount = 12
    self.length = self.initColCount
    self.dItemList = { }
    self.isLastModifyLeft = nil

    -- 从大路的第二行第四列开始
    self.startColInAreaC = 4
    self.startRowInAreaC = 2
end

function AreaF:getRefColB(colInAreaC)
    return colInAreaC - 4
end

function AreaF:getRefCol(colInAreaC)
    return colInAreaC - 3
end

-- function testAreaF()
--     local testList = {
--         1,2,2,2,1,1,
--         1,2,1,1,1,2,
--         0,1,1,1,1,1,
--         1,1,2,1,2,2,
--         1,1,1,1,2,1,
--         1,
--     }

--     local areaC = AreaC
--     areaC:init()

--     local areaD = AreaD
--     areaD:init(areaC)

--     local areaE = AreaE
--     areaE:init(areaC)

--     local areaF = AreaF
--     areaF:init(areaC)

--     for i,v in ipairs(testList) do
--         areaC:fill(v)
--         -- print(v, areaC.lastCItemRow, areaC.lastCItemCol)
--         areaD:fill(v, areaC.lastCItemCol, areaC.lastCItemRow)
--         areaE:fill(v, areaC.lastCItemCol, areaC.lastCItemRow)
--         areaF:fill(v, areaC.lastCItemCol, areaC.lastCItemRow)
--     end

--     areaC:show()
--     print()

--     areaD:show()
--     print()

--     areaE:show()
--     print()
    
--     areaF:show()
--     print()

-- end

-- testAreaF()

-- 预期区
local AreaG = {
    areaC = nil,
    areaD = nil,
    areaE = nil,
    areaF = nil,
}

function AreaG:init(areaC, areaD, areaE, areaF)
    self.areaC = areaC
    self.areaD = areaD
    self.areaE = areaE
    self.areaF = areaF
end

-- 预测DEF区域的结果
function AreaG:predict(prediction)
    local areaC = self.areaC
    local areaD = self.areaD
    local areaE = self.areaE
    local areaF = self.areaF

    -- 预测的行列
    local col, row = areaC:getNextColRow(prediction)
    local predictionD = areaD:predict(prediction, col, row)
    local predictionE = areaE:predict(prediction, col, row)
    local predictionF = areaF:predict(prediction, col, row)

    return predictionD, predictionE, predictionF
end

-- function testAreaG()
--     local testList = {
--         1,2,2,2,1,1,
--         1,2,1,1,1,2,
--         0,1,1,1,1,1,
--         1,1,2,1,2,2,
--         1,1,1,1,2,1,
--         1,
--     }

--     local areaC = AreaC
--     areaC:init()

--     local areaD = AreaD
--     areaD:init(areaC)

--     local areaE = AreaE
--     areaE:init(areaC)

--     local areaF = AreaF
--     areaF:init(areaC)

--     local areaG = AreaG
--     areaG:init(areaC, areaD, areaE, areaF)

--     for i,v in ipairs(testList) do
--         areaC:fill(v)
--         -- print(v, areaC.lastCItemRow, areaC.lastCItemCol)

--         -- areaD:fill(v, areaC.lastCItemCol, areaC.lastCItemRow)
--         -- areaE:fill(v, areaC.lastCItemCol, areaC.lastCItemRow)
--         -- areaF:fill(v, areaC.lastCItemCol, areaC.lastCItemRow)
--     end

--     -- areaC:show()
--     -- print()

--     -- areaD:show()
--     -- print()

--     -- areaE:show()
--     -- print()
    
--     -- areaF:show()
--     -- print()

--     print(areaG:predict(GameResult.D))
--     print(areaG:predict(GameResult.T))

--     print()
-- end

-- testAreaG()

-- 统计区
local AreaH = {
    totalCountD = 0,
    totalCountT = 0,
    totalCountP = 0,
}

function AreaH:init()
    self:clear()
end

function AreaH:clear()
    self.totalCountD = 0
    self.totalCountT = 0
    self.totalCountP = 0
end

function AreaH:addGameResult(gameResult)
    if gameResult == GameResult.D then
        self.totalCountD = self.totalCountD + 1
    elseif gameResult == GameResult.T then
        self.totalCountT = self.totalCountT + 1
    elseif gameResult == GameResult.Peace then
        self.totalCountP = self.totalCountP + 1
    end
end

function AreaH:total()
    return self.totalCountD + self.totalCountP + self.totalCountT;
end

-- function testAreaH()
--     -- local testList = {
--     --     1,2,2,2,1,1,
--     --     1,2,1,1,1,2,
--     --     0,1,1,1,1,1,
--     --     1,1,2,1,2,2,
--     --     1,1,1,1,2,1,
--     --     1,
--     -- }

--     local testList = {
--         2, 1, 1, 1, 1, 1,
--         2, 1, 0, 2, 2, 1,
--         1, 1, 2, 2, 0, 2,
--         0, 1, 2, 2, 2, 1,
--         2, 1, 1, 1, 2, 2,
--         1, 2, 1, 2, 0, 1,
--         1, 1, 1, 1, 1, 1,
--         1, 2, 2, 1, 2, 2,
--         2, 1, 2, 1, 1, 1,
--         2, 1, 2, 2, 0, 2,
--         2, 0, 1, 2, 1, 1,
--         1, 2, 1, 1,
--     }

--     local areaA = AreaA
--     areaA:init()

--     local areaB = AreaB
--     areaB:init()

--     local areaC = AreaC
--     areaC:init()

--     local areaD = AreaD
--     areaD:init(areaC)

--     local areaE = AreaE
--     areaE:init(areaC)

--     local areaF = AreaF
--     areaF:init(areaC)

--     local areaG = AreaG
--     areaG:init(areaC, areaD, areaE, areaF)

--     local areaH = AreaH
--     areaH:init()

--     for i,v in ipairs(testList) do
--         areaH:addGameResult(v)

--         areaA:fill(v)
--         areaB:fill(v)
--         areaC:fill(v)
--         -- print(v, areaC.lastCItemRow, areaC.lastCItemCol)

--         areaD:fill(v, areaC.lastCItemCol, areaC.lastCItemRow)
--         areaE:fill(v, areaC.lastCItemCol, areaC.lastCItemRow)
--         areaF:fill(v, areaC.lastCItemCol, areaC.lastCItemRow)

--         areaG:predict(GameResult.D)
--         areaG:predict(GameResult.T)
--     end

--     print("概率:")
--     local pD, pT = areaA:getResultPercent()
--     print("P(D): "..pD, "P(T): "..pT)
--     print()

--     print("珠盘区:")
--     areaB:show()
--     print()

--     print("大路:")
--     areaC:show()
--     print()

--     print("大眼仔:")
--     areaD:show()
--     print()

--     print("小路:")
--     areaE:show()
--     print()

--     print("曱甴路:")
--     areaF:show()
--     print()

--     print("预测 D:")
--     print(areaG:predict(GameResult.D))
--     print("预测 T:")
--     print(areaG:predict(GameResult.T))
--     print()

--     print("统计:")
--     print("D: "..areaH.totalCountD, "T: "..areaH.totalCountT, "P: "..areaH.totalCountP, "Total: "..areaH:total())
--     print()
-- end

-- testAreaH()

local t = { 
    areaA = AreaA, 
    areaB = AreaB, 
    areaC = AreaC, 
    areaD = AreaD, 
    areaE = AreaE, 
    areaF = AreaF, 
    areaG = AreaG, 
    areaH = AreaH, 
}

function t:init()
    local areaA = AreaA
    areaA:init()

    local areaB = AreaB
    areaB:init()

    local areaC = AreaC
    areaC:init()

    local areaD = AreaD
    areaD:init(areaC)

    local areaE = AreaE
    areaE:init(areaC)

    local areaF = AreaF
    areaF:init(areaC)

    local areaG = AreaG
    areaG:init(areaC, areaD, areaE, areaF)

    local areaH = AreaH
    areaH:init()
end

function t:fill(gameResult)
    local v = gameResult
    self.areaH:addGameResult(v)

    self.areaA:fill(v)
    self.areaB:fill(v)
    self.areaC:fill(v)
    -- print(v, areaC.lastCItemRow, areaC.lastCItemCol)

    self.areaD:fill(v, self.areaC.lastCItemCol, self.areaC.lastCItemRow)
    self.areaE:fill(v, self.areaC.lastCItemCol, self.areaC.lastCItemRow)
    self.areaF:fill(v, self.areaC.lastCItemCol, self.areaC.lastCItemRow)

    -- self.areaG:predict(GameResult.D)
    -- self.areaG:predict(GameResult.T)

    -- self.areaB:show()
    -- self.areaC:show()
    -- self.areaD:show()
end

function t:clear()
    local areaB = AreaB
    areaB:init()

    local areaC = AreaC
    areaC:init()

    local areaD = AreaD
    areaD:init(areaC)

    local areaE = AreaE
    areaE:init(areaC)

    local areaF = AreaF
    areaF:init(areaC)

    local areaG = AreaG
    areaG:init(areaC, areaD, areaE, areaF)

    local areaH = AreaH
    areaH:init()
end

return t