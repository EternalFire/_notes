
local ui_config = require("fire.ui.config")
local MenuItem = require("fire.ui.MenuItem")
local Menu = {
    classname = "Menu",
    topMenu = nil,
    levelDict = {},
}

function Menu.new(param)
    local menu = {}
    setmetatable(menu, { __index = Menu })
    menu:init(param)

    local proxy = {}
    setmetatable(proxy, {
        __index = menu,
        __newindex = function(t, key, value)
            if key == "menuRoot" or key == "preMenu" then
                menu[key] = value
            end
        end
    })
    return proxy
end

function Menu:init(param)
    self.node = nil
    self.layerColor = nil

    self.data = nil -- MenuItem param
    self.fontSize = ui_config.default.fontSize
    self.lv1_h_size = cc.size(display.width, self.fontSize * 1.5)
    self.lv1_v_size = cc.size(self.fontSize * 6, display.height)
    self.size = cc.size(0, 0)
    self.interval = 5
    self.isHorizontal = true
    self.bgColor = cc.c4b(33, 33, 33, 240)
    self.items = {}
    self.level = 1
    self.menuRoot = nil -- menu item
    self.preMenu = nil

    self.size.width = self.lv1_h_size.width
    self.size.height = self.lv1_h_size.height

    if param then
        local properties = { "data", "isHorizontal", "size", "level" }
        for _, value in ipairs(properties) do
            if param[value] ~= nil then
                self[value] = param[value]
            end
        end

        if not self.isHorizontal and not param.size then
            self.size.width = self.lv1_v_size.width
            self.size.height = self.lv1_v_size.height
        end
    end

    -- record top menu
    if self.level == 1 then
        Menu.topMenu = self
    end

    -- record menu
    Menu.levelDict[self.level] = Menu.levelDict[self.level] or {}
    table.insert(Menu.levelDict[self.level], self)


    local size = self.size
    local bgColor = self.bgColor

    local node = cc.Node:create()
    node:setContentSize(self.size)
    node:setAnchorPoint(cc.p(0.5, 0.5))

        local layerColor = cc.LayerColor:create(bgColor, size.width, size.height)
        node:addChild(layerColor)

    self.node = node
    self.layerColor = layerColor

    if self.data then
        if #self.data > 0 then
            for i, itemParam in ipairs(self.data) do
                local item_param = clone(itemParam)
                item_param.callback = self:itemCallback(i, itemParam)
                item_param.autoControlStyle = false

                local item = MenuItem.new(item_param)
                table.insert(self.items, item)

                item.node:addTo(node)
            end
        end
    end

    self:resize()

    if self.level == 1 then
        createTouchListener(self.node, {
            isSwallow = true,
            beganCB = function(isInside)
                -- print("get touch !!! !!!")
                self:removeOtherMenu()

                if isInside then
                else

                end
                return isInside
            end,
            endedCB = function(isInside)
                if isInside then

                end
            end,
        })
    end
end

function Menu:itemCallback(index, itemParam)
    return function()
        local menuItem
        for i, item in ipairs(self.items) do
            if i ~= index then
                item:updateView(false)

                if item.menu then
                    self:removeSubMenu(item.menu)
                    item.menu = nil
                end
            else
                item:updateView(true)
                menuItem = item
            end
        end

        -- popup sub menu
        if not menuItem.menu then
            if itemParam.child then
                local subMenu = Menu.new{
                    level = self.level + 1,
                    isHorizontal = false,
                    data = itemParam.child
                }

                subMenu.menuRoot = menuItem
                subMenu.preMenu = self
                subMenu.node:addTo(subMenu.preMenu.node)
                subMenu:resize()

                menuItem.menu = subMenu
            end
        end

        if itemParam.callback then
            itemParam.callback()
        end
    end
end

function Menu:resize()
    local level = self.level
    local w, h = 0, 0
    local item_w, item_h = 0, 0 -- item 最大尺寸
    local interval = self.interval
    local x, y = 0, 0

    -- set size
    for i, item in ipairs(self.items) do
        item:resize()

        item_w = math.max(item_w, item.size.width)
        item_h = math.max(item_h, item.size.height)

        if self.isHorizontal then
            w = w + item.size.width + interval
            h = item_h + interval
        else
            w = item_w + interval
            h = h + item.size.height + interval
        end
    end

    if level == 1 then
        if self.isHorizontal then
            w = self.lv1_h_size.width
        else
            h = self.lv1_v_size.height
        end
    end

    self:updateSize(w, h)

    -- set item position
    if self.isHorizontal then
        w = 0
    else
        h = 0
        y = self.size.height
    end

    for i, item in ipairs(self.items) do
        if self.isHorizontal then
            x = x + w / 2 + item.size.width / 2 + interval
            y = self.size.height / 2
            w = item.size.width
            item.node:move(x, y)
        else
            x = self.size.width / 2
            y = y - (h / 2 + item.size.height / 2 + interval)
            h = item.size.height
            item.node:move(x, y)
        end
    end

    -- set menu position
    if level == 1 then
        if self.isHorizontal then
            self.node:move(display.cx, display.height - self.size.height / 2)
        else
            self.node:move(self.size.width / 2, display.cy)
        end
    else
        if self.preMenu and self.menuRoot then
            local rootNode = self.menuRoot.node
            local preMenuNode = self.preMenu.node

            if rootNode and preMenuNode then
                local p

                if level == 2 then
                    -- down side
                    p = preMenuNode:convertToNodeSpace(rootNode:convertToWorldSpace(cc.p(self.menuRoot.size.width / 2, 0)))
                    p.y = p.y - self.size.height / 2
                else
                    -- right side
                    p = preMenuNode:convertToNodeSpace(rootNode:convertToWorldSpace(cc.p(self.menuRoot.size.width, self.menuRoot.size.height / 2)))
                    p.x = p.x + self.size.width / 2
                    p.y = p.y - (self.size.height / 2 - self.menuRoot.size.height / 2)
                end

                if p then
                    self.node:move(p)
                end
            end
        end
    end
end

function Menu:updateSize(w, h)
    self.size.width = w
    self.size.height = h

    self.node:setContentSize(self.size)
    self.layerColor:initWithColor(self.bgColor, self.size.width, self.size.height)
end

function Menu:removeOtherMenu()
    local list = {}

    for level, menu_list in pairs(Menu.levelDict) do
        if level > 1 and #menu_list > 0 then
            table.insert(list, 1, level)
        end
    end

    table.sort(list, function(a, b) return a - b > 0 end)

    for _, level in ipairs(list) do
        local menu_list = Menu.levelDict[level]

        for i, menu in ipairs(menu_list) do
            if menu then
                -- print("remove other menu .. level = ", menu.level, "root.text = ", menu.menuRoot.text)
                menu.node:removeFromParent()
            end
        end

        Menu.levelDict[level] = {}
    end

    for _, item in ipairs(Menu.topMenu.items) do
        item:updateView(false)
        item.menu = nil
    end
end

function Menu:removeSubMenu(subMenu)
    if subMenu then
        local level = subMenu.level

        for lv, list in pairs(Menu.levelDict) do
            if lv >= level then
                for i, v in ipairs(Menu.levelDict[lv] or {}) do
                    Menu.levelDict[lv][i] = nil
                    table.remove(Menu.levelDict[lv], i)
                    -- print("remove submenu level = ", lv)
                    break
                end
            end
        end

        subMenu.node:removeFromParent()
    end
end

return Menu
