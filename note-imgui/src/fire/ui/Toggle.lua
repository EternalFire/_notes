
local ui_config = require("fire.ui.config")
local ToggleButton = require("fire.ui.ToggleButton")
local Toggle = { classname = "Toggle" }

function Toggle.new(param)
    local toggle = {}
    setmetatable(toggle, { __index = Toggle })
    toggle:ctor(param)

    local proxy = {}
    setmetatable(proxy, {
        __index = toggle,
        __newindex = function(t, key, value)

        end
    })
    return proxy
end

function Toggle:ctor(param)
    self.node = nil
    self.layerColor = nil

    self.data = nil
    self.callback = nil
    self.size = cc.size(0, 0)
    self.toggleBtns = {}
    self.isHorizontal = true
    self.bgColor = cc.c4b(20, 20, 20, 200)
    self.interval = 10 -- 间距

    if param then
        if type(param.data) == "table" then
            self.data = param.data -- toggle button param
        end

        if type(param.isHorizontal) == "boolean" then
            self.isHorizontal = param.isHorizontal
        end

        if type(param.callback) == "function" then
            self.callback = param.callback
        end

        if type(param.interval) == "number" then
            self.interval = param.interval
        end
    end

    local size = self.size
    local isHorizontal = self.isHorizontal
    local bgColor = self.bgColor
    local interval = self.interval
    local _createCallback = function(index, toggleBtnParam)
        return function(isOn)
            if isOn then
                for i, toggleBtn in ipairs(self.toggleBtns) do
                    if index ~= i then
                        toggleBtn:toggleOff()
                    else
                        -- toggleBtn:toggleOn()
                    end
                end
            end

            if toggleBtnParam.callback then
                toggleBtnParam.callback(isOn)
            end

            if self.callback then
                self.callback(isOn, index)
            end
        end
    end

    if self.data then
        for i, toggleBtnParam in ipairs(self.data) do
            local _param = clone(toggleBtnParam)
            _param.callback = _createCallback(i, toggleBtnParam)

            local toggleBtn = ToggleButton.new(_param)
            self.toggleBtns[i] = toggleBtn

            if isHorizontal then
                size.width = size.width + toggleBtn.size.width

                if i < #self.data then
                    size.width = size.width + interval
                end

                size.height = math.max(size.height, toggleBtn.size.height)
            else
                size.height = size.height + toggleBtn.size.height

                if i < #self.data then
                    size.height = size.height + interval
                end

                size.width = math.max(size.width, toggleBtn.size.width)
            end
        end
    end

    local node = cc.Node:create()
    node:setContentSize(size)
    node:setAnchorPoint(cc.p(0.5,0.5))

        local layerColor = cc.LayerColor:create(bgColor, size.width, size.height)
        node:addChild(layerColor)

        for i, toggleBtn in ipairs(self.toggleBtns) do
            node:addChild(toggleBtn.node)

            local result

            if isHorizontal then
                result = calcCellInfo{size = size, maxCol = #self.toggleBtns, maxRow = 1, col = i, row = 1, spanCol = 0, spanRow = 0}
            else
                result = calcCellInfo{size = size, maxCol = 1, maxRow = #self.toggleBtns, col = 1, row = i, spanCol = 0, spanRow = 0}
            end

            if result then
                toggleBtn.node:move(result.x, result.y)
            end
        end

    self.node = node
    self.layerColor = layerColor
end


return Toggle
