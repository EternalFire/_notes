
local ui_config = require("fire.ui.config")
local MenuItem = { classname = "MenuItem" }

function MenuItem.new(param)
    local menuItem = {}
    setmetatable(menuItem, { __index = MenuItem })
    menuItem:init(param)

    local proxy = {}
    setmetatable(proxy, {
        __index = menuItem,
        __newindex = function(t, key, value)
            if key == "isHighLight" then
                menuItem:updateView(value)
            else
                menuItem[key] = value
            end
        end
    })
    return proxy
end

function MenuItem:init(param)
    self.node = nil
    self.layerColor = nil
    self.label = nil

    self.menu = nil
    self.fontSize = ui_config.default.fontSize
    self.size = cc.size(30, self.fontSize)
    self.text = "item"
    self.callback = nil
    self.bgColor = cc.c4b(20, 20, 20, 200)
    self.highlightColor = cc.c4b(20, 120, 120, 220)
    self.child = nil -- 子菜单参数
    self.isHighLight = false -- 是否选中
    self.autoControlStyle = true -- 使用默认的表现

    if param then
        local properties = { "text", "callback", "child", "autoControlStyle" }
        for _, value in ipairs(properties) do
            if param[value] ~= nil then
                self[value] = param[value]
            end
        end
    end

    local size = self.size
    local bgColor = self.bgColor
    local text = self.text
    local fontSize = self.fontSize

    local node = cc.Node:create()
    node:setContentSize(self.size)
    node:setAnchorPoint(cc.p(0.5, 0.5))

        local layerColor = cc.LayerColor:create(bgColor, size.width, size.height)
        node:addChild(layerColor)

        local label = cc.Label:create()
        label:setString(text)
        label:setSystemFontSize(fontSize)
        node:addChild(label)
        label:setPosition(cc.p(label:getContentSize().width / 2, size.height - fontSize / 2))

    self.node = node
    self.layerColor = layerColor
    self.label = label

    createTouchListener(self.node, {
        isSwallow = true,
        beganCB = function(isInside)
            if isInside then
            else
                if self.autoControlStyle then
                    self:updateView(false)
                end
            end
            return isInside
        end,
        endedCB = function(isInside)
            if isInside then
                if self.autoControlStyle then
                    self:updateView(true)
                end

                if self.callback then
                    self.callback()
                end
            end
        end,
    })
end

function MenuItem:resize()
    local labelSize = self.label:getContentSize()

    self.node:setContentSize(labelSize)
    self.label:setPositionX(labelSize.width / 2)
    self.layerColor:setContentSize(labelSize.width, labelSize.height)

    self.size.width = labelSize.width
    self.size.height = labelSize.height
end

function MenuItem:updateView(isHighLight)
    self.isHighLight = isHighLight

    if isHighLight then
        self.layerColor:initWithColor(self.highlightColor, self.size.width, self.size.height)
    else
        self.layerColor:initWithColor(self.bgColor, self.size.width, self.size.height)
    end
end

return MenuItem
