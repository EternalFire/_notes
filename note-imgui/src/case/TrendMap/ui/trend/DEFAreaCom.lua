-- 
-- 用于下三路添加元素的组件
--
local DEFAreaCom = class("DEFAreaCom")

function DEFAreaCom:ctor(trendArea, leftFirstValue)
    self.trendArea = trendArea -- TrendAreaD | TrendAreaE | TrendAreaF
    self.leftFirstValue = leftFirstValue -- true | false
    self.reverse = false
    self._isCheckLeftFirstValue = false
end

function DEFAreaCom:updateItem(col, row, value)

    -- require("mobdebug").start()

    local itemList = self.trendArea.itemList
    local listView = self.trendArea.listView
    local isLeft = value
    local subItemEndIndex

    local item = itemList[col]
    if not item then
        item = self.trendArea:newItem()
    end

    -- 检测首列首行的颜色
    if not self._isCheckLeftFirstValue then
        local item_1 = itemList[1]
        if item_1 and item_1.itemCom:checkLeftFree(1) and self.leftFirstValue ~= value then
            self.reverse = true
        else
            self.reverse = false
        end

        self._isCheckLeftFirstValue = true
    end

    if self.reverse then
        isLeft = not isLeft
    end

    -- logToFile("DEFAreaCom:updateItem() "..col.."  "..row.." "..tostring(value).." r "..tostring(self.reverse))

    if item then
        local itemCom = item.itemCom
        subItemEndIndex = isLeft and itemCom.leftEndIndex or itemCom.rightEndIndex

        if row >= 1 and row <= subItemEndIndex then
            if row == subItemEndIndex then
                local isFree
                if isLeft then
                    isFree = itemCom:checkLeftEndIndexFree()
                else
                    isFree = itemCom:checkRightEndIndexFree()
                end

                if not isFree then
                    -- 最后的位置被占用

                    local endIndex = math.max(1, subItemEndIndex - 1)
                    if isLeft then
                        -- 添加到右子列
                        local _isLeft = false
                        itemCom:updateSubItem(_isLeft, endIndex, value)
                        itemCom:updateRightEndIndex(endIndex)
                    else
                        -- 下一列
                        local nextCol = 1 + col
                        if (nextCol > #itemList) then
                            local _item = self.trendArea:newItem()
                            local _isLeft = true
                            _item.itemCom:updateSubItem(_isLeft, endIndex, value)

                            -----------------------------------------
                            -- itemCom:updateLeftEndIndex(endIndex)
                            _item.itemCom:updateLeftEndIndex(endIndex)--
                            -----------------------------------------

                            self:scrollListView(nextCol)
                        end
                    end

                    return
                end
            end

            itemCom:updateSubItem(isLeft, row, value)
            self:scrollListView(col)
        else
            -- 超过当前列
            -- 找到下一个能插入数据的列
            local offset = row - subItemEndIndex
            local _offset = offset
            local nextCol = col
            local nextItemCom
            if isLeft then
                -- 右子列
                if offset > 0 then
                    offset = offset - 1

                    if (offset == 0) then
                        itemCom:updateSubItem(false, subItemEndIndex, value)
                        itemCom:updateRightEndIndex(subItemEndIndex - 1)
                    end
                end
            end

            while(offset > 0) do
                offset = offset - 2
                nextCol = nextCol + 1
                local nextItem = itemList[nextCol]
                if not nextItem then
                    self.trendArea:newItem()
                    --
                    nextItem = itemList[nextCol]
                    --
                end

                if nextItem then
                    nextItemCom = nextItem.itemCom
                end
            end -- while

            if nextItemCom then
                local _isLeft = isLeft
                if _offset % 2 ~= 0 then
                    _isLeft = not isLeft -- 奇数次数
                end

                nextItemCom:updateSubItem(_isLeft, subItemEndIndex, value)

                if _isLeft then
                    nextItemCom:updateLeftEndIndex(subItemEndIndex - 1)
                else
                    nextItemCom:updateRightEndIndex(subItemEndIndex - 1)
                end

                self:scrollListView(nextCol)
            end
        end
    end
end

function DEFAreaCom:clear()
    self._isCheckLeftFirstValue = false

    local itemList = self.trendArea.itemList
    local listView = self.trendArea.listView

    if itemList then
        for _, item in ipairs(itemList) do
            if item and item.itemCom then
                item.itemCom:clear()
            end
        end

        local item 
        for i = self.trendArea.maxLen + 1, #itemList do
            item = itemList[i]
            if item then
                item.rootWidget:removeFromParent()
                itemList[i].rootWidget = nil
                itemList[i].itemCom = nil
                itemList[i] = nil
                item = nil
            end
        end
    end

    listView:jumpToPercentHorizontal(0)
end

function DEFAreaCom:scrollListView(col)
    local itemList = self.trendArea.itemList
    local listView = self.trendArea.listView
    local maxLen = self.trendArea.maxLen
    local x = col

    if x <= maxLen then
        x = 0
    else
        x = col + 1
    end

    -- self.listView:jumpToPercentHorizontal(math.min(100, x / #self.itemList * 100))
    local percent = math.ceil(x / #itemList * 100)

    listView:runAction(
        cc.Sequence:create(
            cc.DelayTime:create(0.1),
            cc.CallFunc:create(function()
                listView:setBounceEnabled(false)
                listView:scrollToPercentHorizontal(percent, 0.1, true)
            end),
            cc.DelayTime:create(0.1),
            cc.CallFunc:create(function()
                listView:setBounceEnabled(true)
            end)
        )
    )
end

return DEFAreaCom