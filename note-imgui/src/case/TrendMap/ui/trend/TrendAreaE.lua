--
-- 小路视图组件
--
local UITrendItemE = _game_require("ui.trend.UITrendItemE")
local DEFAreaCom = _game_require("ui.trend.DEFAreaCom")
local TrendAreaE = class("TrendAreaE")

function TrendAreaE:ctor(listView)
    self.listView = listView
    self.itemList = {} -- 列数组, 元素是 UITrendItemE 对象
    self.maxLen = 10
    self.areaCom = DEFAreaCom.new(self, true)

    for i = 1, self.maxLen do
        local item = UITrendItemE.new()
        self.listView:pushBackCustomItem(item.rootWidget)

        self.itemList[i] = item

        if i % 2 == 0 then
            item.itemCom:setBrightDarkBg()
        else
            item.itemCom:setDarkBrightBg()
        end
    end
end

function TrendAreaE:updateItem(col, row, value)
    self.areaCom:updateItem(col, row, value)
end

function TrendAreaE:newItem()
    local item = UITrendItemE.new()
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

return TrendAreaE