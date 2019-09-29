
local ui_config = require("fire.ui.config")
local ComboboxItem = require("fire.ui.ComboboxItem")
local Combobox = { classname = "Combobox" }

function Combobox.new(param)
    local combobox = {}
    setmetatable(combobox, { __index = Combobox })

    combobox:ctor(param)

    local proxy = {}
    setmetatable(proxy, {
        __index = combobox,
        __newindex = function(t, key, value)

        end
    })
    return proxy
end

function Combobox:ctor(param)
    self.node = nil

    self.size = cc.size(0, 0)
    self.data = nil
    self.items = {}
    self.callback = nil
    self.interval = 2
    self.displayItem = nil
    self.isShowOption = false
    self.defaultIndex = 1  -- 默认项
    self.selectedIndex = 1 -- 选中项
    self.bgColor = cc.c4b(20, 20, 20, 200)

    if param then
        if type(param.data) == "table" then
            self.data = param.data
        end

        if param.callback then self.callback = param.callback end
    end

    local size = self.size
    local interval = self.interval
    local bgColor = self.bgColor
    local itemSize = cc.size(0, 0)
    local _createCallback = function(index, itemParam)
        return function()
            self:selectOption(index)

            if itemParam.callback then
                itemParam.callback()
            end

            if self.callback then
                self.callback(index)
            end
        end
    end

    for i, itemParam in ipairs(self.data) do
        local _param = clone(itemParam)
        _param.callback = _createCallback(i, itemParam)

        local comboboxItem = ComboboxItem.new(_param)
        self.items[i] = comboboxItem

        size.width = math.max(size.width, comboboxItem.size.width)
        size.height = size.height + comboboxItem.size.height

        if itemSize.width == 0 then
            itemSize.width = comboboxItem.size.width
        end

        if itemSize.height == 0 then
            itemSize.height = comboboxItem.size.height
        end

        -- make space for display item
        if i == 1 then
            size.height = size.height + comboboxItem.size.height
        end

        if i < #self.data then
            size.height = size.height + interval
        end
    end


    local node = cc.Node:create()
    node:setContentSize(size)
    node:setAnchorPoint(cc.p(0.5, 0.5))

        local layerColor = cc.LayerColor:create(bgColor, size.width * 1.05, size.height * 1.05)
        layerColor:setAnchorPoint(cc.p(0.5, 0.5))
        layerColor:setIgnoreAnchorPointForPosition(false)
        layerColor:setPosition(cc.p(size.width / 2, size.height / 2))
        node:addChild(layerColor)

        for i, item in ipairs(self.items) do
            local result = calcCellInfo{size = size, maxCol = 1, maxRow = #self.items + 1, col = 1, row = i + 1, spanCol = 0, spanRow = 0}
            item.node:addTo(node):move(result.x, result.y)
        end

        local displayItem = ComboboxItem.new({
            size = itemSize,
            callback = function()
                self:switchDisplayOptions()
            end
        })
        local result = calcCellInfo{size = size, maxCol = 1, maxRow = #self.items + 1, col = 1, row = 1, spanCol = 0, spanRow = 0}
        displayItem.node:addTo(node):move(result.x, result.y)

    self.node = node
    self.displayItem = displayItem


    self:selectOption(self.defaultIndex)
end

function Combobox:showOptions()
    self.isShowOption = true

    for i, item in ipairs(self.items) do
        item.node:setVisible(true)
    end
end

function Combobox:hideOptions()
    self.isShowOption = false

    for i, item in ipairs(self.items) do
        item.node:setVisible(false)
    end
end

function Combobox:switchDisplayOptions()
    if self.isShowOption then
        self:hideOptions()
    else
        self:showOptions()
    end
end

function Combobox:selectOption(index)
    local item = self.items[index]
    if item then
        self.displayItem.text = item.text
    end

    self.selectedIndex = index

    self:hideOptions()
end

return Combobox
