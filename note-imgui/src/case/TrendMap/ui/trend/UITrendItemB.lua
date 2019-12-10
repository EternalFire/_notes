--
-- 珠盘列视图
--
local _getAllChildNode = _getAllChildNode
local WinType = DragonTigerCFG.WinType

local UITrendItemB = class("UITrendItemB")
UITrendItemB.resName = "UI/trend_item_1.csb"

function UITrendItemB:ctor()
    self.rootWidget = nil
    self.iconList = {}
    self.bgList = {}

    self.iconTextureTable = {}
    self.iconTextureTable[WinType.D] = "UI/UItrend/icon_D.png"
    self.iconTextureTable[WinType.P] = "UI/UItrend/icon_H.png"
    self.iconTextureTable[WinType.T] = "UI/UItrend/icon_T.png"

    self.bgTextureTable = {}
    self.bgTextureTable["bright"] = "UI/UItrend/big_2.png"
    self.bgTextureTable["dark"] = "UI/UItrend/big_1.png"

    -- self.rootWidget = cc.CSLoader:createNode(self.resName)
    self.rootWidget = cc.CSLoader:createWidget(self.resName)
    _getAllChildNode(self.rootWidget)

    self:onCreate();
end

function UITrendItemB:onCreate()
    local list = {
        self.rootWidget.Node_1_0,
        self.rootWidget.Node_1_1,
        self.rootWidget.Node_1_2,
        self.rootWidget.Node_1_3,
        self.rootWidget.Node_1_4,
        self.rootWidget.Node_1_5,
    }

    local node, icon, bg
    for i = 1, #list do
        node = list[i]
        icon = node:getChildByName("img_item")
        bg = node:getChildByName("img_bg")
        table.insert(self.iconList, icon)
        table.insert(self.bgList, bg)

        self:updateIcon(i) -- setVisible(false)
    end
end

-- 刷新图标
-- winType: 1龙, 2和, 3虎
function UITrendItemB:updateIcon(index, winType)
    local icon = self.iconList[index]
    local texture = self.iconTextureTable[winType]
    if icon then
        if texture then
            icon:setVisible(true)
            icon:loadTexture(texture, 1)
        else 
            icon:setVisible(false)
        end
    end
end

function UITrendItemB:clear()
    if self.iconList then
        for _, icon in ipairs(self.iconList) do
            icon:setVisible(false)
        end
    end
end

function UITrendItemB:setBrightDarkBg()
    local bg, texture
    for i = 1, #self.bgList do
        bg = self.bgList[i]
        if bg then
            if i % 2 == 0 then
                texture = self.bgTextureTable["dark"]
            else
                texture = self.bgTextureTable["bright"]
            end

            bg:loadTexture(texture, 1)
        end
    end
end

function UITrendItemB:setDarkBrightBg()
    local bg, texture
    for i = 1, #self.bgList do
        bg = self.bgList[i]
        if bg then
            if i % 2 == 0 then
                texture = self.bgTextureTable["bright"]
            else
                texture = self.bgTextureTable["dark"]
            end

            bg:loadTexture(texture, 1)
        end
    end
end

return UITrendItemB