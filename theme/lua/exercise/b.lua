function GetArrResult(itemIdList)
    local w = 5
    local h = 3
    local n = w * h
    local list = itemIdList
    local allNodes
    local rowMap
    local colMap
    local spValue_1 = 1

    if not list or #list < n then
        return {}
    end

    local function createNode(index, value)
        local node = {
            index = index,
            value = value,
            children = {},
        }
        return node
    end

    local function rowIndex(index)
        return math.floor((index - 1) / w + 1)
    end

    local function colIndex(index)
        return math.floor((index - 1) % w + 1)
    end

    local function initAllNodes()
        local rIndex, cIndex, _node

        allNodes = {}
        rowMap = {}
        colMap = {}

        for index = 1, n do
            table.insert(allNodes, createNode(index, list[index]))
            _node = allNodes[index]

            rIndex = rowIndex(index)
            rowMap[rIndex] = rowMap[rIndex] or {}
            table.insert(rowMap[rIndex], _node)

            cIndex = colIndex(index)
            colMap[cIndex] = colMap[cIndex] or {}
            table.insert(colMap[cIndex], _node)
        end
    end

    local function iterateAllNodesByCol(callback, beginX, beginY)
        local _node, _nodes
        beginX = beginX or 1
        beginY = beginY or 1

        if colMap then
            for x = beginX, w do
                _nodes = colMap[x]

                if _nodes then
                    for y = beginY, h do
                        _node = _nodes[y]

                        if _node and callback then
                            local index = _node.index
                            local value = _node.value
                            local children = _node.children
                            callback(_node, x, y, index, value, children)
                        end
                    end -- for y
                end
            end -- for x
        end
    end

    local function iterateColList(callback, x, beginY)
        local _node, _nodes
        if colMap and colMap[x] then
            beginY = beginY or 1
            _nodes = colMap[x]

            if _nodes then
                for y = beginY, h do
                    _node = _nodes[y]
                    if _node and callback then
                        local index = _node.index
                        local value = _node.value
                        local children = _node.children
                        callback(_node, x, y, index, value, children)
                    end
                end
            end
        end
    end

    local function getNodeByIndex(index)
        if (allNodes) then
            return allNodes[index]
        end
    end

    local function depthWalk(callback, node)
        if node and callback then
            callback(node)

            for i = 1, #node.children do
                local child = node.children[i]
                depthWalk(callback, child)
            end
        end
    end

    local function _run()
        local result = {}

        initAllNodes()

        iterateAllNodesByCol(function(_node, x, y, index, value, children)
            iterateColList(function(_node1, x1, y1, index1, value1, children1)
                local sameValue = false
                if x == 1 then
                    if value ~= spValue_1 and (value == value1 or value1 == spValue_1) then
                        sameValue = true
                    end
                else
                    if value == value1 or value1 == spValue_1 then
                        sameValue = true
                    end
                end

                if sameValue then
                    table.insert(_node.children, _node1)
                end
            end, x + 1)
        end)

        print(allNodes)

        -- iterateAllNodesByCol(function(_node, x, y, index, value, children)
        --     print(string.format("(%d %d)", index, value))

        --     local t = {}
        --     for i = 1, #children do
        --         local c = children[i]
        --         table.insert(t, string.format("(%d %d)", c.index, c.value))
        --     end
        --     print("", table.concat(t, ","))
        -- end)
        local visited = {}
        local pathRecord = {}
        iterateColList(function(_node, x, y, index, value, children)
            depthWalk(function(__node)
                print(__node.index, __node.value)
            end, _node)
        end, 1)

        return result
    end

    return _run()
end

-- test
GetArrResult({7,9,7,9,5,9,9,9,2,1,2,11,11,6,4})

--[[

"7,9,7,9,5,9,9,9,2,1,2,11,11,6,4"

1   2   3   4   5  i
----------------------
7,  9,  7,  9,  5,

6   7   8   9  10  i
----------------------
9,  9,  9,  2,  1,

11 12  13  14  15  i
--------------------
2, 11, 11, 6,  4


]]