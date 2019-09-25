
-- type
-- action
-- style

local ui_config = require("fire.ui.config")
local Button = {}

function Button.new(param)
    local btn = { classname = "Button" }

    function btn:ctor(param)
        -- property
        self.node = nil
        self.layerColor = nil
        self.label = nil

        self.text = "button"
        self.size = cc.size(80, 60)
        self.bgColor = cc.c4b(20, 20, 20, 255)
        self.fontSize = ui_config.default.fontSize
        self.callback = nil

        -- update with param
        if param then
            if param.text then
                self.text = param.text
            end

            if type(param.callback) == "function" then
                self.callback = param.callback
            end
            -- ...
        end

        local text = self.text
        local size = self.size
        local bgColor = self.bgColor
        local fontSize = self.fontSize

        -- init ui
        local node = cc.Node:create()
        node:setContentSize(size)
        node:setAnchorPoint(cc.p(0.5, 0.5))

            local layerColor = cc.LayerColor:create(bgColor, size.width * 0.98, size.height * 0.98)
            node:addChild(layerColor)

            local label = cc.Label:create()
            label:setPosition(cc.p(size.width / 2, size.height / 2))
            label:setString(text)
            label:setSystemFontSize(fontSize)
            node:addChild(label)

        -- touch listener
        local option = {
            isSwallow = true,
            -- isTouchMove = true,
            beganCB = function(isInside)
                if isInside then
                    self.node:runAction(cc.ScaleTo:create(0.1, 1.1))
                end
                return isInside
            end,
            endedCB = function()
                self.node:runAction(cc.ScaleTo:create(0.05, 1))
                if self.callback then self.callback() end
            end,
            cancelledCB = function()
                self.node:runAction(cc.ScaleTo:create(0.05, 1))
            end,
        }
        createTouchListener(node, option)

        self.node = node
        self.layerColor = layerColor
        self.label = label
    end

    btn:ctor(param)

    -- update ui by property
    local meta = {}
    meta.__index = btn
    meta.__newindex = function(t, key, value)
        btn[key] = value

        if key == "text" then
            if btn.label then
                btn.label:setString(btn.text)
            end
        end
    end

    local proxy = {}
    setmetatable(proxy, meta)

    return proxy
end

return Button
