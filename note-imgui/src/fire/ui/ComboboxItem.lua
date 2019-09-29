
local ui_config = require("fire.ui.config")
local ComboboxItem = { classname = "ComboboxItem" }

function ComboboxItem.new(param)
    local comboboxItem = {}
    setmetatable(comboboxItem, { __index = ComboboxItem })

    comboboxItem:ctor(param)

    local proxy = {}
    setmetatable(proxy, {
        __index = comboboxItem,
        __newindex = function(t, key, value)
            comboboxItem[key] = value

            if key == "text" then
                comboboxItem.label:setString(value)
            end
        end
    })
    return proxy
end

function ComboboxItem:ctor(param)
    self.node = nil
    self.layerColor = nil
    self.label = nil

    self.text = "item"
    self.size = cc.size(80, 60)
    self.bgColor = cc.c4b(20, 20, 20, 255)
    self.fontSize = ui_config.default.fontSize
    self.callback = nil

    if param then
        if param.text then
            self.text = param.text
        end

        if type(param.callback) == "function" then
            self.callback = param.callback
        end

        if param.size then
            self.size.width = param.size.width
            self.size.height = param.size.height
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

    self.node = node
    self.layerColor = layerColor
    self.label = label

    -- touch listener
    local option = {
        isSwallow = true,
        endedCB = function(isInside)
            if self.callback then self.callback(isInside) end
        end,
    }
    createTouchListener(node, option)
end



return ComboboxItem
