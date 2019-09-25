
local ui_config = require("fire.ui.config")
local Panel = {}

function Panel.new(param)
    local panel = { classname = "Panel" }

    function panel:ctor(param)
        self.node = nil
        self.layerColor = nil

        self.size = cc.size(240, 180)
        self.bgColor = cc.c4b(20, 20, 20, 200)

        if param then
            local properties = { "size" }
            for _, value in ipairs(properties) do
                if param[value] then
                    self[value] = param[value]
                end
            end
        end

        local size = self.size
        local bgColor = self.bgColor

        -------------------------------
        local node = cc.Node:create()
        node:setContentSize(size)
        node:setAnchorPoint(cc.p(0.5, 0.5))

            local layerColor = cc.LayerColor:create(bgColor, size.width, size.height)
            node:addChild(layerColor)
        -------------------------------

        local option = {
            isSwallow = true,
            isTouchMove = true,
        }
        createTouchListener(node, option)

        self.node = node
        self.layerColor = layerColor
    end

    panel:ctor(param)

    local meta = {}
    meta.__index = panel
    meta.__newindex = function(t, key, value)

    end

    local proxy = {}
    setmetatable(proxy, meta)

    return proxy
end

return Panel
