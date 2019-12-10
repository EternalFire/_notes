--
-- 大眼仔列视图
--
local DEFItemCom = _game_require("ui.trend.DEFItemCom")
local UITrendItemD = class("UITrendItemD")

function UITrendItemD:ctor()
    self.textureTable = {
        ["true"] = "UI/UItrend/icon_B_small.png",
        ["false"] = "UI/UItrend/icon_R_small.png",
    }

    self.itemCom = DEFItemCom.new(self.textureTable)
    self.rootWidget = self.itemCom.rootWidget
end

return UITrendItemD
