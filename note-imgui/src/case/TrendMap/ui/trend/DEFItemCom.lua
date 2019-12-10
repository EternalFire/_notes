--
-- 下三路(大眼仔,小路,曱甴路)显示组件
--
local _getAllChildNode = _getAllChildNode
local DEFItemCom = class("DEFItemCom")

--[[ 
    textureTable: 左右两列的纹理. "true": 左边的纹理, "false": 右边的纹理
    textureTable["true"] = "UI/UItrend/icon_B.png"
    textureTable["false"] = "UI/UItrend/icon_R.png"
 ]]
function DEFItemCom:ctor(textureTable)
    self.rootWidget = nil
    self.resName = "UI/trend_item_3.csb"
    self.textureTable = textureTable
    self.leftIconList = nil
    self.rightIconList = nil
    self.leftEndIndex = 6 -- 左列最后一个位置
    self.rightEndIndex = 6 -- 右列最后一个位置
    self.leftValueList = {}
    self.rightValueList = {}

    self.bgTextureTable = {}
    self.bgTextureTable["bright"] = "UI/UItrend/small.png"
    self.bgTextureTable["dark"] = "UI/UItrend/small_1.png"

    self.rootWidget = cc.CSLoader:createWidget(self.resName)
    _getAllChildNode(self.rootWidget)

    self.leftIconList = {
        self.rootWidget.img_0_0,
        self.rootWidget.img_0_1,
        self.rootWidget.img_0_2,
        self.rootWidget.img_0_3,
        self.rootWidget.img_0_4,
        self.rootWidget.img_0_5,
    }

    self.rightIconList = {
        self.rootWidget.img_1_0,
        self.rootWidget.img_1_1,
        self.rootWidget.img_1_2,
        self.rootWidget.img_1_3,
        self.rootWidget.img_1_4,
        self.rootWidget.img_1_5,
    }

    self.bgList = {
        self.rootWidget.img_bg_0,
        self.rootWidget.img_bg_1,
        self.rootWidget.img_bg_2,
    }
    
    self:hideItems()
end

function DEFItemCom:updateSubItem(isLeft, row, value)
    local list = isLeft and self.leftIconList or self.rightIconList
    local valueList = isLeft and self.leftValueList or self.rightValueList

    local icon
    if list then
        icon = list[row]
        if icon then
            icon:loadTexture(self.textureTable[tostring(value)], 1)
            icon:setVisible(true)
            
            valueList[row] = value
        end
    end
end

function DEFItemCom:hideItems()
    local node, list

    list = self.leftIconList
    
    for i = 1, #list do
        node = list[i]
        if node then
            node:setVisible(false)
            self.leftValueList[i] = nil
        end
    end

    list = self.rightIconList
    
    for i = 1, #list do
        node = list[i]
        if node then
            node:setVisible(false)
            self.rightValueList[i] = nil
        end
    end

    node = nil
end

-- 横向填充的时候, 需要调用
function DEFItemCom:updateLeftEndIndex(index)
    self.leftEndIndex = index
end

function DEFItemCom:updateRightEndIndex(index)
    self.rightEndIndex = index
end

-- true: 空闲
function DEFItemCom:checkLeftFree(row)
    return self.leftValueList[row] == nil
end

function DEFItemCom:checkLeftEndIndexFree()
    return self:checkLeftFree(self.leftEndIndex)
end

-- true: 空闲
function DEFItemCom:checkRightFree(row)
    return self.rightValueList[row] == nil
end

function DEFItemCom:checkRightEndIndexFree()
    return self:checkRightFree(self.rightEndIndex)
end

function DEFItemCom:clear()
    self:hideItems()
    self.leftEndIndex = 6
    self.rightEndIndex = 6
end


function DEFItemCom:setBrightDarkBg()
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

function DEFItemCom:setDarkBrightBg()
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


return DEFItemCom