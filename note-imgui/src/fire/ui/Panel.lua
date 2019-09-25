
local ui_config = require("fire.ui.config")
local Panel = {}

function Panel.new(param)
    local panel = { classname = "Panel" }

    function panel:ctor(param)
        self.node = nil
        self.layerColor = nil
        self.scrollView = nil

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

            local scrollView = ccui.ScrollView:create()
            scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
            scrollView:setContentSize(cc.size(size.width, size.height - 20))
            scrollView:setInnerContainerSize(cc.size(size.width, size.height))
            scrollView:setScrollBarPositionFromCorner(cc.p(4, 4))
            node:addChild(scrollView)
        -------------------------------

        local option = {
            isSwallow = true,
            isTouchMove = true,
        }
        createTouchListener(node, option)

        self.node = node
        self.layerColor = layerColor
        self.scrollView = scrollView
    end
    function panel:addChild(child)
        if child then
            self.scrollView:addChild(child)
        end
    end
    function panel:setInnerSize(size)
        if size then
            local innerSize = size
            innerSize.width = math.min(innerSize.width, self.size.width)
            innerSize.height = math.max(innerSize.height, self.size.height)
            self.scrollView:setInnerContainerSize(innerSize)
        end
    end

    panel:ctor(param)

    local meta = {}
    meta.__index = panel
    meta.__newindex = function(t, key, value)
        if key == "innerSize" then
            panel:setInnerSize(value)
        end
    end

    local proxy = {}
    setmetatable(proxy, meta)

    return proxy
end

return Panel
