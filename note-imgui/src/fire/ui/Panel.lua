
local ui_config = require("fire.ui.config")
local Panel = {}

function Panel.new(param)
    local panel = { classname = "Panel" }

    local meta_panel = { __index = Panel }
    setmetatable(panel, meta_panel)

    panel:ctor(param)

    local meta = {}
    meta.__index = panel
    meta.__newindex = function(t, key, value)
        if key == "innerSize" then
            panel:setInnerSize(value)
        elseif key == "text" then

        end
    end

    local proxy = {}
    setmetatable(proxy, meta)

    return proxy
end

function Panel:ctor(param)
    self.node = nil
    self.layerColor = nil
    self.scrollView = nil
    self.titleLabel = nil
    self.closeLabel = nil

    self.size = cc.size(240, 180)
    self.bgColor = cc.c4b(20, 20, 20, 200)
    self.fontSize = ui_config.default.fontSize
    self.text = "title"
    self.touchListener = nil

    if param then
        local properties = { "size", "text", "bgColor" }
        for _, value in ipairs(properties) do
            if param[value] then
                self[value] = param[value]
            end
        end
    end

    local size = self.size
    local bgColor = self.bgColor
    local fontSize = self.fontSize
    local text = self.text
    local fontSize_1 = 24

    -------------------------------
    local node = cc.Node:create()
    node:setContentSize(size)
    node:setAnchorPoint(cc.p(0.5, 0.5))

        local layerColor = cc.LayerColor:create(bgColor, size.width, size.height)
        node:addChild(layerColor)

        local scrollView = ccui.ScrollView:create()
        scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        scrollView:setContentSize(cc.size(size.width, size.height - 25))
        scrollView:setInnerContainerSize(cc.size(size.width, size.height))
        scrollView:setScrollBarPositionFromCorner(cc.p(4, 4))
        node:addChild(scrollView)

        local label = cc.Label:create()
        label:setString(text)
        label:setSystemFontSize(fontSize)
        node:addChild(label)
        label:setPosition(cc.p(label:getContentSize().width / 2 + 10, size.height - fontSize / 2))

        local label_1 = cc.Label:create()
        label_1:setPosition(cc.p(size.width - fontSize_1 / 2, size.height - fontSize_1 / 2))
        label_1:setString("X")
        label_1:setSystemFontSize(fontSize_1)
        node:addChild(label_1)

    self.node = node
    self.layerColor = layerColor
    self.scrollView = scrollView
    self.titleLabel = label
    self.closeLabel = label_1
    -------------------------------

    local option = {
        isSwallow = true,
        isTouchMove = true,
    }
    self.touchListener = createTouchListener(node, option)

    createTouchListener(self.closeLabel, {
        isSwallow = true,
        endedCB = function(isInside)
            if isInside then
                self.node:removeFromParent()
            end
        end,
    })
end

function Panel:addChild(child)
    if child then
        self.scrollView:addChild(child)
    end
end

function Panel:setInnerSize(size)
    if size then
        local innerSize = size
        innerSize.width = math.min(innerSize.width, self.size.width)
        innerSize.height = math.max(innerSize.height, self.size.height)
        self.scrollView:setInnerContainerSize(innerSize)
    end
end

function Panel:removeTouchListener()
    removeTouchListener(self.node, self.touchListener)
    self.touchListener = nil
end

return Panel
