
local ui_config = require("fire.ui.config")
local InputText = {}

function InputText.new(param)
    local inputText = { classname = "InputText" }

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

function InputText:ctor(param)
    self.node = nil
    self.layerColor = nil
    self.editBox = nil

    self.text = "input"
    self.size = cc.size(80, 60)
    self.bgColor = cc.c4b(20, 20, 20, 255)
    self.fontSize = ui_config.default.fontSize
    self.endCallback = nil

    if param then
        if type(param.endCallback) == "function" then
            self.endCallback = param.endCallback
        end

        -- ...
    end

    local size = self.size
    local bgSize = cc.size(size.width * 0.98, size.height * 0.98)
    local bgColor = self.bgColor
    local res = ""
    local fontSize = self.fontSize

    local function editboxEventHandler(eventType)
        if eventType == "began" then
            -- triggered when an edit box gains focus after keyboard is shown
        elseif eventType == "ended" then
            -- triggered when an edit box loses focus after keyboard is hidden.
            local changed = self.text ~= self.editBox:getText()
            local before = self.text
            local after = self.editBox:getText()

            if changed then
                self.text = after
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
        editBox:registerScriptEditBoxHandler(editboxEventHandler)
        node:addChild(editBox)

    self.node = node
    self.layerColor = layerColor
    self.editBox = editBox
end

return InputText
