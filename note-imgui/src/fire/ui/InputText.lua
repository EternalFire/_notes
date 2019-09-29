
local ui_config = require("fire.ui.config")
local InputText = { classname = "InputText" }

InputText.Mode = {
    Text = "Text",
    Number = "Number",
    Integer = "Integer",
}

function InputText.new(param)
    local inputText = {}

    local meta_inputText = {
        __index = InputText
    }
    setmetatable(inputText, meta_inputText)

    inputText:ctor(param)

    local meta = {}
    meta.__index = inputText
    meta.__newindex = function(t, key, value)
        inputText[key] = value

        if key == "text" then
            if inputText.editBox then
                inputText.editBox:setText(inputText.text)
            end
        end
    end

    local proxy = {}
    setmetatable(proxy, meta)
    return proxy
end

function InputText:init(param)
    if param then
        if type(param.endCallback) == "function" then
            self.endCallback = param.endCallback
        end

        if param.size and param.size.width and param.size.height then
            self.size.width = param.size.width
            self.size.height = param.size.height
        end

        if param.mode and InputText.Mode[param.mode] then
            self.mode = param.mode
        end

        if type(param.min) == "number" then
            self.min = param.min
        end

        if type(param.max) == "number" then
            self.max = param.max
        end

        if type(param.step) == "number" then
            self.step = param.step
        elseif self.mode == InputText.Mode.Number then
            self.step = 0.1
        end

        if type(param.text) == "string" then
            self.text = param.text
        end

        if tonumber(self.text) == nil then
            if self.mode == InputText.Mode.Number then
                self.text = string.format("%.2f", (self.min + self.max) / 2)
            elseif self.mode == InputText.Mode.Integer then
                self.text = string.format("%d", math.floor(self.min + self.max))
            end
        end
    end
end

function InputText:ctor(param)
    self.node = nil
    self.layerColor = nil
    self.editBox = nil

    self.text = "input"
    self.size = cc.size(80, 60)
    self.bgColor = cc.c4b(20, 20, 20, 255)
    self.fontSize = ui_config.default.fontSize
    self.endCallback = nil
    self.mode = InputText.Mode.Text -- 输入模式
    self.min = 0 -- 输入数字时的最小值
    self.max = 100 -- 输入数字时的最大值
    self.step = 1

    self:init(param)

    local size = self.size
    local bgSize = cc.size(size.width * 0.98, size.height * 0.98)
    local bgColor = self.bgColor
    local res = ""
    local fontSize = self.fontSize

    local node = cc.Node:create()
    node:setContentSize(size)
    node:setAnchorPoint(cc.p(0.5, 0.5))

        local layerColor = cc.LayerColor:create(bgColor, bgSize.width, bgSize.height)
        node:addChild(layerColor)

        local editBox = ccui.EditBox:create(bgSize, res)
        editBox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
        editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
        editBox:setText(self.text)
        editBox:setPosition(cc.p(size.width / 2, size.height / 2))
        editBox:setFontSize(fontSize)
        editBox:registerScriptEditBoxHandler(function(eventType)
            self:onEditBoxEvent(eventType)
        end)
        node:addChild(editBox)

        local drag = cc.Node:create()
        drag:setContentSize(size)
        drag:setAnchorPoint(cc.p(0.5, 0.5))
        drag:addTo(node):move(cc.p(size.width / 2, size.height / 2))

    self.node = node
    self.layerColor = layerColor
    self.editBox = editBox

    local option = {
        isSwallow = false,
        -- isTouchMove = true,
        beganCB = function(isInside)
            if self:isInputNumberMode() then
                return isInside
            end

            return false
        end,
        movedCB = function(touchLocation, touch)
            -- local positionInNode = node:convertToNodeSpace(touchLocation)
            local dir = cc.pSub(touchLocation, touch:getStartLocation())
            local len = math.abs(dir.x) / 20
            local per = len / math.max(1, self.size.width)
            local sign = 1

            if dir.x < 0 then
                sign = -1
            end

            local origin = tonumber(self.editBox:getText())
            local value = 0

            if sign == 1 then
                value = math.min(per * 100 * self.step + origin, self.max)
            else
                value = math.max(sign * per * 100 * self.step + origin, self.min)
            end

            value = self:_getTextByMode(value)

            self.editBox:setText(value)
        end,
        -- endedCB = function(isInside)

        -- end,
        -- cancelledCB = function()

        -- end,
    }
    createTouchListener(drag, option)
end

function InputText:onEditBoxEvent(eventType)
    if eventType == "began" then
        -- triggered when an edit box gains focus after keyboard is shown
    elseif eventType == "ended" then
        -- triggered when an edit box loses focus after keyboard is hidden.
        local changed = self.text ~= self.editBox:getText()
        local before = self.text
        local after = self.editBox:getText()

        if self:isInputNumberMode() then
            if tonumber(after) == nil then
                changed = false
            else
                after = self:_getTextByMode(tonumber(after))
            end
        end

        if changed then
            self.text = after
        else
            self.editBox:setText(before)
        end

        if self.endCallback then
            self.endCallback(changed, before, after)
        end
    elseif eventType == "changed" then
        -- triggered when the edit box text was changed.
    elseif eventType == "return" then
        -- triggered when the return button was pressed or the outside area of keyboard was touched.
        -- useless
    end
end

function InputText:isInputNumberMode()
    if self.mode == InputText.Mode.Number or self.mode == InputText.Mode.Integer then
        return true
    end

    return false
end

function InputText:_getTextByMode(_value)
    local value = _value
    value = math.max(math.min(value, self.max), self.min)

    if self.mode == InputText.Mode.Number then
        value = string.format("%.3f", value)
    elseif self.mode == InputText.Mode.Integer then
        value = string.format("%d", value)
    end
    return value
end

return InputText
