
local ui_config = require("fire.ui.config")
local Progressbar  = { classname = "Progressbar" }

function Progressbar.new(param)
    local progressbar = {}
    setmetatable(progressbar, { __index = Progressbar })

    progressbar:init(param)

    local proxy = {}
    setmetatable(proxy, {
        __index = progressbar,
        __newindex = function(t, key, value)
            if key == "percent" then
                progressbar.percent = value
                progressbar:updateFrontLayer()
            end
        end
    })
    return proxy
end

function Progressbar:init(param)
    self.node = nil
    self.layerColor = nil
    self.frontLayer = nil

    self.size = cc.size(240, 20)
    self.frontSize = cc.size(240, 20)
    self.bgColor = cc.c4b(20, 20, 20, 220)
    self.frontColor = cc.c4b(130, 133, 130, 220)
    self.percent = 1.0
    self.callback = nil

    if param then
        if param.size then
            self.size.width = param.size.width
            self.size.height = param.size.height
        end

        if type(param.percent) == "number" then
            self.percent = param.percent
        end

        if param.callback then
            self.callback = param.callback
        end
    end

    self.frontSize.width = self.size.width
    self.frontSize.height = self.size.height

    local size = self.size
    local bgColor = self.bgColor
    local frontColor = self.frontColor
    local frontSize = self.frontSize


    local node = cc.Node:create()
    node:setContentSize(size)
    node:setAnchorPoint(cc.p(0.5, 0.5))

        local layerColor = cc.LayerColor:create(bgColor, size.width, size.height)
        node:addChild(layerColor)

        local frontLayer = cc.LayerColor:create(frontColor, frontSize.width, frontSize.height)
        frontLayer:setAnchorPoint(cc.p(0, 0.5))
        frontLayer:setIgnoreAnchorPointForPosition(false)
        frontLayer:setPosition(cc.p(0, size.height / 2))
        node:addChild(frontLayer)

    self.node = node
    self.layerColor = layerColor
    self.frontLayer = frontLayer

    self:updateFrontLayer()
end

function Progressbar:updateFrontLayer()
    local size = self.size
    local frontSize = self.frontSize

    if 1.0 - self.percent <= 0.001 or self.percent > 1.0 then
        self.percent = 1.0
    elseif self.percent < 0 then
        self.percent = 0
    end

    local cur = self.percent
    frontSize.width = math.min(size.width, cur / 1.0 * size.width)
    self.frontLayer:initWithColor(self.frontColor, frontSize.width, frontSize.height)

    if self.callback then
        self.callback(self.percent)
    end
end

return Progressbar