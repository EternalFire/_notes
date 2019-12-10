--
-- 大眼仔视图组件
--
local UITrendItemD = _game_require("ui.trend.UITrendItemD")
local DEFAreaCom = _game_require("ui.trend.DEFAreaCom")
local TrendAreaD = class("TrendAreaD")

function TrendAreaD:ctor(listView)
    self.listView = listView
    self.itemList = {} -- 列数组, 元素是 UITrendItemD 对象
    self.maxLen = 9
    self.areaCom = DEFAreaCom.new(self, true)

    for i = 1, self.maxLen do
        local item = UITrendItemD.new()
        self.listView:pushBackCustomItem(item.rootWidget)

        self.itemList[i] = item

        if i % 2 == 0 then
            item.itemCom:setDarkBrightBg()
        else
            item.itemCom:setBrightDarkBg()
        end
    end
end

function TrendAreaD:updateItem(col, row, value)
    self.areaCom:updateItem(col, row, value)
end

function TrendAreaD:newItem()
    local item = UITrendItemD.new()
    self.listView:pushBackCustomItem(item.rootWidget)
    self.itemList[#self.itemList + 1] = item

    local i = #self.itemList
    if i % 2 == 0 then
        item.itemCom:setDarkBrightBg()
    else
        item.itemCom:setBrightDarkBg()
    end

    return item
end

return TrendAreaD