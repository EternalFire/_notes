--
-- 大路区视图组件
--
local WinType = DragonTigerCFG.WinType
local UITrendItemC = _game_require("ui.trend.UITrendItemC")

local TrendAreaC = class("TrendAreaC")

------------------------------------------------------------------
-- TableAreaC
local _nextSamePos = { col = 1, row = 1 } -- 下一个添加相同元素的位置
local _nextDiffPos = { col = 2, row = 1 } -- 下一个添加不同元素的位置
local _tableAreaC = {
    {} , -- col 1
    {} , -- col 2
}
local _rowCount = 6
local _lastResult = nil -- 上次结果
local _lastPos = { col = 1, row = 1 } -- 最后添加的位置
local _lastDataPos = {col = 1, row = 1}
local _viewDataColMap = {}

local function initTableAreaC()
    _nextSamePos.col = 1;
    _nextSamePos.row = 1;

    _nextDiffPos.col = 2;
    _nextDiffPos.row = 1;

    _tableAreaC = {}

    _lastResult = nil

    _lastPos.col = 1;
    _lastPos.row = 1;

    _lastDataPos.col = 1;
    _lastDataPos.row = 1;

    _viewDataColMap = {}
end

local function getTableCol(col)
    if not _tableAreaC[col] then
        local len = #_tableAreaC
        for i = len + 1, col do
            _tableAreaC[i] = _tableAreaC[i] or { }
        end
    end

    return _tableAreaC[col]
end

local function dumpTableAreaC()
    local n = _rowCount
    local str = ""
    for col, list in ipairs(_tableAreaC) do
        str = str..col..": "
        for row = 1, n do
            local item = list[row]
            if item then
                local s = string.format("(%d,%d) ", item[1], item[2])
                str = str..s
            else
                str = str.."(-,-) "
            end
        end
        str = str.."\n"
    end
    print(str)
end

local function _updateItem(col, row, winType, num)
    local dataCol, dataRow = col, row
    local viewCol, viewRow = col, row
    local nextSamePos = _nextSamePos
    local nextDiffPos = _nextDiffPos
    local lastResult = _lastResult
    local rowCount = _rowCount
    local theSame -- 与上一次结果是否相同
    local isInit = false
    local lastPos = _lastPos
    local colMap = _viewDataColMap

    if lastResult == nil then
        lastResult = winType
        isInit = true
    end

    if lastResult == winType or lastResult == WinType.P then
        viewCol = nextSamePos.col
        viewRow = nextSamePos.row
        theSame = true
    else
        viewCol = nextDiffPos.col
        viewRow = nextDiffPos.row
        theSame = false
    end

    -- Peace situation
    if not isInit and theSame and num > 0 then
        local lastItemList = getTableCol(lastPos.col)
        local lastItem = lastItemList[lastPos.row]
        if lastItem then
            lastItem[2] = num

            --!!!--
            return
            --!!!--
        end
    end

    local itemList = getTableCol(viewCol)
    itemList[viewRow] = { winType, num }

    lastPos.col = viewCol
    lastPos.row = viewRow

    colMap[viewCol] = dataCol

    -- find next same pos
    if viewRow < rowCount then
        local nextCol = viewCol
        local nextRow = viewRow + 1
        local nextItem = itemList[nextRow]

        if nextItem then
            nextCol = viewCol + 1
            nextRow = viewRow
        else
            -- fill the row across columns
            if theSame and not isInit then
                if viewCol > 1 then
                    local leftCol = viewCol - 1
                    local leftItemList = getTableCol(leftCol)
                    local leftItem = leftItemList[viewRow]

                    -- check data col between left col and current col
                    local ret = colMap[leftCol] == dataCol

                    if leftItem and (viewRow == 1 or (ret and leftItem[1] == winType)) then
                        nextCol = viewCol + 1
                        nextRow = viewRow
                    end
                end
            end
        end

        nextSamePos.col = nextCol
        nextSamePos.row = nextRow

    elseif viewRow == rowCount then
        nextSamePos.col = viewCol + 1
        nextSamePos.row = viewRow
    end

    if itemList[1] then
        nextDiffPos.col = viewCol + 1
        nextDiffPos.row = 1
    else
        local diffItemList = getTableCol(nextDiffPos.col)
        if diffItemList[1] then
            nextDiffPos.col = viewCol
            nextDiffPos.row = 1
        end
    end

    _nextSamePos = nextSamePos
    _nextDiffPos = nextDiffPos
    _lastResult = winType
    _lastPos = lastPos
    _lastDataPos.col = dataCol
    _lastDataPos.row = dataRow
end
------------------------------------------------------------------





function TrendAreaC:ctor(listView)
    self.listView = listView
    self.itemList = {} -- 列数组, 元素是 UITrendItemC 对象
    self.maxLen = 19
    self.lastWinType = nil
    self.lastCol = 1

    for i = 1, self.maxLen do
        local item = UITrendItemC.new()
        self.listView:pushBackCustomItem(item.rootWidget)

        self.itemList[i] = item

        if i % 2 == 0 then
            item:setDarkBrightBg()
        else
            item:setBrightDarkBg()
        end
    end
end

function TrendAreaC:updateItem(col, row, winType, num)
    _updateItem(col, row, winType, num)

    if _lastPos then
        local _col = _lastPos.col
        local _row = _lastPos.row

        local item = self.itemList[_col]
        if not item then
            item = self:newItem()
        end

        item:updateSubItem(_row, winType, num)
        self:scrollListView(_col)
    end
end

function TrendAreaC:newItem()
    local item = UITrendItemC.new()
    self.listView:pushBackCustomItem(item.rootWidget)
    self.itemList[#self.itemList + 1] = item

    local i = #self.itemList
    if i % 2 == 0 then
        item:setDarkBrightBg()
    else
        item:setBrightDarkBg()
    end

    return item
end

function TrendAreaC:clear()

    initTableAreaC()

    if self.itemList then
        for i, item in ipairs(self.itemList) do
            item:clear()
        end
    end

    local item
    for i = self.maxLen + 1, #self.itemList do
        item = self.itemList[i]
        if item then
            -- item.rootWidget:removeFromParent()
            self.listView:removeChild(item.rootWidget)
            self.itemList[i] = nil
            item = nil
        end
    end

    self.listView:jumpToPercentHorizontal(0)

    self.lastWinType = nil
end

function TrendAreaC:scrollListView(col)
    local x = col

    if x <= self.maxLen then
        x = 0
    else
        x = col + 1
    end

    -- self.listView:jumpToPercentHorizontal(math.min(100, x / #self.itemList * 100))
    local percent = math.ceil(x / #self.itemList * 100)
    -- logToFile("col = "..col.." scrollListView percent = "..percent)

    self.listView:runAction(
        cc.Sequence:create(
            cc.DelayTime:create(0.1),
            cc.CallFunc:create(function()
                self.listView:setBounceEnabled(false)
                self.listView:scrollToPercentHorizontal(percent, 0.1, true)
            end),
            cc.DelayTime:create(0.1),
            cc.CallFunc:create(function()
                self.listView:setBounceEnabled(true)
            end)
        )
    )
end

return TrendAreaC