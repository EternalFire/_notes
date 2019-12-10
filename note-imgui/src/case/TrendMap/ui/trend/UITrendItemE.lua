--
-- 小路列视图
--
local DEFItemCom = _game_require("ui.trend.DEFItemCom")
local UITrendItemE = class("UITrendItemE")

function UITrendItemE:ctor()
    self.textureTable = {
        ["true"] = "UI/UItrend/icon_Fill_B_small.png",
        ["false"] = "UI/UItrend/icon_Fill_R_small.png",
    }
    self.itemCom = DEFItemCom.new(self.textureTable)
    self.rootWidget = self.itemCom.rootWidget

end


return UITrendItemE
