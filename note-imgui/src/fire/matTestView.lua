
local function createMatTestView(parent)

    local tileSize = { width = 100, height = 100 }
    local rowNum = 6
    local colNum = 6
    local initList = {
        1, 2, 3, 0, 1, 3,
        1, 0, 0, 0, 2, 1,
        1, 3, 1, 0, 2, 3,
        0, 1, 0, 0, 1, 1,
        1, 3, 1, 0, 2, 3,
        0, 2, 1, 2, 3, 1,
    }
    local mapSize = { width = (tileSize.width * colNum), height = (tileSize.height * rowNum) }
    local tileNodes = {}

    local function convertTy(ty)
        return rowNum - ty + 1
    end

    local function createColorButton(text, size, callback, color)
        local node = cc.Node:create()
        node:setName("ColorBtn")
        node:setContentSize(size)

        local option = {
            isSwallow = true,
            endedCB = function()
                if callback then callback() end
            end,
        }
        createTouchListener(node, option)

        local bgColor
        if color then
            bgColor = color
        else
            bgColor = cc.c4b(20, 20, 20, 255)
        end

        local tileBg = cc.LayerColor:create(bgColor, size.width * 0.98, size.height * 0.98)
        node:addChild(tileBg)

        local label = cc.Label:create()
        label:setPosition(cc.p(size.width / 2, size.height / 2))
        node:addChild(label)
        label:setString(text)

        return node
    end

    local function createTileNode_0(mapNode, index, mat)
        local tileBg = cc.LayerColor:create(cc.c4b(10, 200, 10, 200), tileSize.width * 0.98, tileSize.height * 0.98)

        local label = cc.Label:create()
        label:setPosition(cc.p(tileSize.width / 2, tileSize.height / 2))
        label:setSystemFontSize(30)
        label:setName("value")

        local node = cc.Node:create()
        node:setCascadeOpacityEnabled(true)
        node:setContentSize(tileSize)
        node:addChild(tileBg)
        node:addChild(label)
        mapNode:addChild(node)

        local tx, ty = mat:calcXY(index)
        local ty_ = convertTy(ty)

        local p = cc.p(0, 0)
        p.x = (tx - 1) * tileSize.width
        p.y = (ty_ - 1) * tileSize.height
        node:setPosition(p)

        local nodeInMat = mat:get(tx, ty)
        if nodeInMat then
            label:setString(tostring(nodeInMat.value))
        else
            label:setString(tostring(index))
        end

        return node;
    end

    local function updateTileNode_0(tileNode, index, mat)
        local label = tileNode:getChildByName("value")
        local tx, ty = mat:calcXY(index)
        local nodeInMat = mat:get(tx, ty)
        label:setString(tostring(nodeInMat.value))
    end

    local function _checkMat(mat)
        local times = 3
        local vNodes = {} -- { index = { nodeList } }
        local hNodes = {} -- { index = { nodeList } }

        vNodes, hNodes = matUtil.findAllEqualCrossNodesContinually(mat, times)
        local toGenValues = {}

        for index, vList in pairs(vNodes) do -- index
            for i = 1, #vList do -------------- { nodeList }
                local nodeList = vList[i]
                for j = 1, #nodeList do ------- nodeInMat
                    local matNode = nodeList[j]
                    toGenValues[matNode] = true
                end
            end
        end

        for index, vList in pairs(hNodes) do
            for i = 1, #vList do
                local nodeList = vList[i]
                for j = 1, #nodeList do
                    local matNode = nodeList[j]
                    toGenValues[matNode] = true
                end
            end
        end

        local refresh = false
        for matNode, _ in pairs(toGenValues) do
            refresh = true

            local value = math.random(0, 3) ------ new value
            mat:set(matNode.x, matNode.y, value)

            local tileNode = tileNodes[matNode.index]
            updateTileNode_0(tileNode, matNode.index, mat)

            local actions = {
                cc.Blink:create(0.5, 2),
            }
            tileNode:runAction(cc.Sequence:create(actions))
        end

        if refresh then
            mat:printMat()
        end
    end

    local mapNode = cc.Node:create()
    mapNode:setContentSize(mapSize)
    mapNode:setPosition(cc.p(220, 0))
    parent:addChild(mapNode)

    local mat = MatMap.createMatMap(rowNum, colNum)
    mat:set(initList)
    mat:printMat()

    mat:walk(function(i, x, y, value, node)
        local node = createTileNode_0(mapNode, i, mat)
        table.insert(tileNodes, node)
    end)


    local option = {
        isTouchMove = true,
        isSwallow = true,
    }
    createTouchListener(mapNode, option)

    local btn = createColorButton("check", cc.size(100, 80), function()
        -- print("1", os.clock())
        _checkMat(mat)
    end)
    mapNode:addChild(btn)
    btn:setPositionX(-100)

    local btn = createColorButton("random", cc.size(100, 80), function()
        local index = math.random(1, mat.len)
        local x, y = mat:calcXY(index)
        mat:set(x, y, math.random(0, 3))

        local tileNode = tileNodes[index]
        updateTileNode_0(tileNode, index, mat)

        local actions = {
            cc.FadeOut:create(0.4),
            cc.FadeIn:create(0.4),
        }
        tileNode:runAction(cc.Sequence:create(actions))

        mat:printMat()
    end)
    mapNode:addChild(btn)
    btn:setPosition(cc.p(-100, 80))


    do
        local colorNode = cc.LayerColor:create(cc.c4b(199, 20, 20, 255), 100, 80)
        colorNode:addTo(mapNode):move(-100, 160)

        local option = {
            isTouchMove = true,
            isSwallow = true,
        }
        createTouchListener(colorNode, option)
    end

end

return createMatTestView