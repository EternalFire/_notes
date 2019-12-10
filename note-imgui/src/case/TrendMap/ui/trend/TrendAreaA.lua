--
-- 显示区
--

local WinType = DragonTigerCFG.WinType

local TrendAreaA = class("TrendAreaA")

function TrendAreaA:ctor(rootWidget)
    self.rootWidget = rootWidget
    self.show_panel = rootWidget.show_panel
    self.img_pro_0 = rootWidget.img_pro_0 -- D 进度条
    self.img_pro_1 = rootWidget.img_pro_1 -- T 进度条

    self.lbl_pro_0 = rootWidget.lbl_pro_0 -- D 百分比
    self.lbl_pro_1 = rootWidget.lbl_pro_1 -- T 百分比

    self.Sprite_4 = rootWidget.Sprite_4 -- 20局指示牌

    -- 游戏结果图标列表
    self.iconList = {
        self.rootWidget.img_1_1,
        self.rootWidget.img_1_2,
        self.rootWidget.img_1_3,
        self.rootWidget.img_1_4,
        self.rootWidget.img_1_5,
        self.rootWidget.img_1_6,
        self.rootWidget.img_1_7,
        self.rootWidget.img_1_8,
        self.rootWidget.img_1_9,
        self.rootWidget.img_1_10,
        self.rootWidget.img_1_11,
        self.rootWidget.img_1_12,
        self.rootWidget.img_1_13,
        self.rootWidget.img_1_14,
        self.rootWidget.img_1_15,
        self.rootWidget.img_1_16,
        self.rootWidget.img_1_17,
        self.rootWidget.img_1_18,
        self.rootWidget.img_1_19,
        self.rootWidget.img_1_20,
    }

    self.iconTextureTable = {}
    self.iconTextureTable[WinType.D] = "UI/Trend/icon_1.png"
    self.iconTextureTable[WinType.P] = "UI/Trend/icon_2.png"
    self.iconTextureTable[WinType.T] = "UI/Trend/icon_3.png"

    self:clear()
end

-- 根据最近20局的结果列表刷新视图
-- modelA is AreaA
function TrendAreaA:updateView(modelA)
    local recentList = modelA.gameResultList
    local t_num = modelA.TCount
    local d_num = modelA.DCount
    local all = d_num + t_num
    local pD, pT = modelA:getResultPercent()

    for i = 1, #self.iconList do
 --   if i == 20 and args.ani == true then
  --       self.show_panel:getChildByName("img_1_"..i):setScale(3);
        
  --       local actions = cc.Sequence:create(cc.ScaleTo:create(0.4,1.0),cc.FadeIn:create(0.2),cc.FadeOut:create(0.2),cc.FadeIn:create(0.2),cc.FadeOut:create(0.2),cc.FadeIn:create(0.2));
  --       self.show_panel:getChildByName("img_1_"..i):runAction(actions);
  --     end
        local winType = recentList[i]
        self:updateIcon(i, winType)
    end

    if pT == 0 and pD == 0 then
        self.lbl_pro_0:setString("");
        self.lbl_pro_1:setString("");
    else
        self.lbl_pro_0:setString(pD.."%");
        self.lbl_pro_1:setString(pT.."%");
    end

    local uiPercentD = 0.5
    local uiPercentT = 0.5

    if all ~= 0 then
        uiPercentD = math.min(0.9, math.max(0.1, d_num/all))
        uiPercentT = math.min(0.9, math.max(0.1, t_num/all))
    end

    self.img_pro_0:setScaleX(uiPercentD);
    self.img_pro_1:setScaleX(uiPercentT);

    local d_x = self.img_pro_0:getPositionX();
    local d_w = self.img_pro_0:getContentSize().width;
    -- local d_posx = d_x + (d_w*(d_num/all));
    local d_posx = d_x + (d_w*(uiPercentD));

    local t_x = self.img_pro_1:getPositionX();
    local t_w = self.img_pro_1:getContentSize().width;
    -- local t_posx = t_x - (t_w*(t_num/all));
    local t_posx = t_x - (t_w*(uiPercentT));

    self.lbl_pro_0:setPositionX(d_posx);
    self.lbl_pro_1:setPositionX(t_posx);

    self.Sprite_4:setPositionX(t_posx - 100);
end

function TrendAreaA:updateIcon(index, winType)
    local icon = self.iconList[index]
    local texture = self.iconTextureTable[winType]
    if icon then
        if texture then
            icon:setVisible(true)
            icon:loadTexture(texture)
        else
            icon:setVisible(false)
        end
    end
end

function TrendAreaA:hideAllIcons()
    for i = 1, #self.iconList do
        self.iconList[i]:setVisible(false)
    end
end

function TrendAreaA:clear()
    self:hideAllIcons()

    self.lbl_pro_0:setString("")
    self.lbl_pro_1:setString("")
    self.img_pro_0:setScaleX(0.5)
    self.img_pro_1:setScaleX(0.5)
end

return TrendAreaA