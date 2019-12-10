--
-- 珠盘区视图组件
--
local UITrendItemB = _game_require("ui.trend.UITrendItemB")

local TrendAreaB = class("TrendAreaB")

function TrendAreaB:ctor(listView)    
    self.listView = listView
    self.itemList = {} -- 列数组, 元素是 UITrendItemB 对象
    self.maxLen = 18 -- 最多18列

    for i = 1, self.maxLen do
        local item = UITrendItemB.new()
        self.listView:pushBackCustomItem(item.rootWidget)

        self.itemList[i] = item

        if i % 2 == 0 then
            item:setDarkBrightBg()
        else
            item:setBrightDarkBg()
        end
    end
end

function TrendAreaB:updateIcon(col, row, winType)
    local item = self.itemList[col]
    if item then
        item:updateIcon(row, winType)
    end

    -- 初始可见8列
    if col > 8 then
        self.listView:jumpToPercentHorizontal(col / #self.itemList * 100)
    end
end

function TrendAreaB:clear()
    local item
    for i = 1, #self.itemList do
        item = self.itemList[i]
        if (item) then
            item:clear()
        end
    end

    self.listView:jumpToPercentHorizontal(0)
end

return TrendAreaB