
local ui_config = require("fire.ui.config")
local ToggleButton = { classname = "ToggleButton" }

function ToggleButton.new(param)
    local toggleButton = {}
    setmetatable(toggleButton, { __index = ToggleButton })

    toggleButton:ctor(param)

    local proxy = {}
    setmetatable(proxy, { __index = toggleButton,
        __newindex = function(t, key, value)
            toggleButton[key] = value
        end
    })
    return proxy
end

function ToggleButton:ctor(param)
    self.node = nil
    self.drawBg = nil
    self.label = nil

    self.size = cc.size(80, 60)
    self.bgColor = cc.c4f(0.1, 0.1, 0.1, 1)
    self.toggleColor = cc.c4f(0.3, 0.55, 0.3, 1)
    self.text = "toggle"
    self.fontSize = ui_config.default.fontSize
    self.callback = nil
    self.touchListener = nil
    self.isOn = false

    if param then
        local properties = { "size", "text", "callback" }
        for _, value in ipairs(properties) do
            if param[value] then
                self[value] = param[value]
            end
        end
    end

    local size = self.size
    local text = self.text
    local bgColor = self.bgColor
    local toggleColor = self.toggleColor
    local fontSize = self.fontSize

    local node = cc.Node:create()
    node:setContentSize(size)
    node:setAnchorPoint(cc.p(0.5, 0.5))

        local drawBg = cc.DrawNode:create()
        drawBg:drawSolidRect(cc.p(0,0), cc.pFromSize(size), bgColor)
        node:addChild(drawBg)

        local label = cc.Label:create()
        label:setPosition(cc.p(size.width / 2, size.height / 2))
        label:setString(text)
        label:setSystemFontSize(fontSize)
        node:addChild(label)

    self.node = node
    self.drawBg = drawBg
    self.label = label

    createTouchListener(self.node, {
        isSwallow = true,
        endedCB = function(isInside)
            if isInside then
                self:switch()

                if self.callback then
                    self.callback(self.isOn)
                end
            end
        end,
    })
end

function ToggleButton:removeTouchListener()
    removeTouchListener(self.node, self.touchListener)
    self.touchListener = nil
end

function ToggleButton:toggleOn()
    if not self.isOn then
        self.drawBg:clear()
        self.drawBg:drawSolidRect(cc.p(0,0), cc.pFromSize(self.size), self.toggleColor)
    end

    self.isOn = true
end

function ToggleButton:toggleOff()
    if self.isOn then
        self.drawBg:clear()
        self.drawBg:drawSolidRect(cc.p(0,0), cc.pFromSize(self.size), self.bgColor)
    end

    self.isOn = false
end

function ToggleButton:switch()
    if self.isOn then
        self:toggleOff()
        return
    end

    self:toggleOn()
end

return ToggleButton
