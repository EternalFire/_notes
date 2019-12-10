--
-- 曱甴路视图组件
--
local UITrendItemF = _game_require("ui.trend.UITrendItemF")
local DEFAreaCom = _game_require("ui.trend.DEFAreaCom")
local TrendAreaF = class("TrendAreaF")

function TrendAreaF:ctor(listView)
    self.listView = listView
    self.itemList = {} -- 列数组, 元素是 UITrendItemF 对象
    self.maxLen = 9
    self.areaCom = DEFAreaCom.new(self, true)

    for i = 1, self.maxLen do
        local item = UITrendItemF.new()
        self.listView:pushBackCustomItem(item.rootWidget)

        self.itemList[i] = item

        if i % 2 == 0 then
            item.itemCom:setBrightDarkBg()
        else
            item.itemCom:setDarkBrightBg()
        end
    end
end

function TrendAreaF:updateItem(col, row, value)
    self.areaCom:updateItem(col, row, value)
end

function TrendAreaF:newItem()
    local item = UITrendItemF.new()
    self.listView:pushBackCustomItem(item.rootWidget)
    self.itemList[#self.itemList + 1] = item

    local i = #self.itemList
    if i % 2 == 0 then
        item.itemCom:setBrightDarkBg()
    else
        item.itemCom:setDarkBrightBg()
    end

    return item
end

return TrendAreaF