--
-- 曱甴路列视图
--
local DEFItemCom = _game_require("ui.trend.DEFItemCom")
local UITrendItemF = class("UITrendItemF")

function UITrendItemF:ctor()
    self.textureTable = {
        ["true"] = "UI/UItrend/B_small.png",
        ["false"] = "UI/UItrend/R_small.png",
    }
    self.itemCom = DEFItemCom.new(self.textureTable)
    self.rootWidget = self.itemCom.rootWidget

end


return UITrendItemF
