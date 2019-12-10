--
-- 大路列视图
--
local _getAllChildNode = _getAllChildNode
local WinType = DragonTigerCFG.WinType

local UITrendItemC = class("UITrendItemC")
UITrendItemC.resName = "UI/trend_item_2.csb"

function UITrendItemC:ctor()
    self.rootWidget = nil
    self.iconList = {}
    self.labelList = {}
    self.bgList = {}
    self.length = 6
    self.winTypeList = {}
    self.endIndex = 6 -- 最后一个位置
    
    self.iconTextureTable = {}
    self.iconTextureTable[WinType.D] = "UI/UItrend/icon_B.png"
    self.iconTextureTable[WinType.T] = "UI/UItrend/icon_R.png"

    self.bgTextureTable = {}
    self.bgTextureTable["bright"] = "UI/UItrend/small.png"
    self.bgTextureTable["dark"] = "UI/UItrend/small_1.png"

    self.rootWidget = cc.CSLoader:createWidget(self.resName)
    _getAllChildNode(self.rootWidget)

    self:onCreate();
end

function UITrendItemC:onCreate()
    local list = {
        self.rootWidget.Node_1_0,
        self.rootWidget.Node_1_1,
        self.rootWidget.Node_1_2,
        self.rootWidget.Node_1_3,
        self.rootWidget.Node_1_4,
        self.rootWidget.Node_1_5,
    }
    local node, icon, label, bg

    for i = 1, #list do
        node = list[i]
        icon = node:getChildByName("img_item")
        label = node:getChildByName("Text_1")
        bg = node:getChildByName("img_bg")

        table.insert(self.iconList, icon)
        table.insert(self.labelList, label)
        table.insert(self.bgList, bg)

        self:hideSubItem(i)
    end
end

-- 刷新格子
-- winType: 1龙, 2和, 3虎
function UITrendItemC:updateSubItem(index, winType, num)
    local icon = self.iconList[index]
    local label = self.labelList[index]
    local texture = self.iconTextureTable[winType]

    if icon then
        if texture then
            icon:setVisible(true)
            icon:loadTexture(texture, 1)
            self.winTypeList[index] = winType
        else 
            icon:setVisible(false)
        end
    end

    if label then
        if num > 0 then
            label:setVisible(true)
            label:setString(num)
        else
            label:setVisible(false)
        end
    end
end

-- 横向填充的时候, 需要调用
function UITrendItemC:updateEndIndex(index)
    self.endIndex = index
end

function UITrendItemC:hideSubItem(index)
    local icon = self.iconList[index]
    local label = self.labelList[index]

    if icon then
        icon:setVisible(false)
    end

    if label then
        label:setVisible(false)
    end

    self.winTypeList[index] = nil
end

function UITrendItemC:getRestItemCount()
    local num = 0

    for i = 1, self.length do
        if self:checkFree(i) then
            num = num + 1
        end
    end

    return num
end

-- true: 空闲
function UITrendItemC:checkFree(row)
    return self.winTypeList[row] == nil
end

function UITrendItemC:checkEndIndexFree()
    return self:checkFree(self.endIndex)
end

function UITrendItemC:clear()
    for i = 1, self.length do
        self:hideSubItem(i)
    end

    self:updateEndIndex(self.length)
end

function UITrendItemC:setBrightDarkBg()
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

function UITrendItemC:setDarkBrightBg()
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

function UITrendItemC:getFirstWinType()
    return self.winTypeList[1]
end

function UITrendItemC:getNextFreeRow()
    local row
    for i = 1, self.length do
        if self:checkFree(i) then
            row = i
        else
            break
        end
    end
    return row
end

return UITrendItemC