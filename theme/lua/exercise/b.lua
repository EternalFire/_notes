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
            parents = {},
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
            local stack = {}
            local path = {}
            local element
            table.insert(stack, node)

            while #stack > 0 do
                element = stack[#stack]
                table.remove(stack, #stack)

                if #element.children == 0 then
                    local i = element.index
                    local pathList = { i }
                    local from
                    while path[i] ~= nil do
                        from = path[i]
                        table.insert(pathList, 1, from)
                        i = from
                    end

                    callback(pathList, node)
                end

                for i = #element.children, 1, -1 do
                    local child = element.children[i]
                    if child then
                        table.insert(stack, child)
                        path[child.index] = element.index
                    end
                end
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
                    if value == spValue_1 then
                        sameValue = true
                    else
                        if value ~= spValue_1 and (value == value1 or value1 == spValue_1) then
                            sameValue = true
                        end
                    end

                else
                    if value == value1 or value1 == spValue_1 then
                        sameValue = true
                    else
                        for i, parent in ipairs(_node1.parents) do
                            if parent and (parent.value == value1 or parent.value == spValue_1) then
                                sameValue = true
                                break
                            end
                        end
                    end
                end

                if sameValue then
                    table.insert(_node.children, _node1)
                    table.insert(_node1.parents, _node)
                end
            end, x + 1)
        end)

        -- print(allNodes)

        local pathRecord = {}
        iterateColList(function(_node, x, y, index, value, children)
            depthWalk(function(pathList, root)
                -- print(table.concat(pathList, ","), root.index)

                local _pathList
                for i, _index in ipairs(pathList) do
                    local nodeInPath = getNodeByIndex(_index)
                    if nodeInPath.value == root.value or nodeInPath.value == spValue_1 then
                        _pathList = _pathList or {}
                        table.insert(_pathList, _index)
                    end
                end

                if _pathList then
                    table.insert(pathRecord, _pathList)

                    if (#_pathList >= 3) then
                        local rowIndexList = {}
                        for i = 1, #_pathList do
                            local _index = _pathList[i]
                            local rIndex = rowIndex(_index)
                            table.insert(rowIndexList, rIndex)
                        end

                        table.insert(result, rowIndexList)
                    end
                end
            end, _node)
        end, 1)

        -- check path
        for i,v in ipairs(pathRecord) do
            print(i, table.concat(v, "--"))
        end

        return result
    end

    return _run()
end

local _result
-- test
--_result = GetArrResult({
--    7,9,7,9,5,
--    9,9,9,2,1,
--    2,11,11,6,4
--})

_result = GetArrResult({
    3, 3, 3, 2, 2,
    9, 1, 9, 1, 7,
    2, 2, 3, 6, 4
})

for i = 1, #_result do
    print(table.concat(_result[i], "~"))
end

--[[

"7,9,7,9,5,9,9,9,2,1,2,11,11,6,4"

1   2   3   4   5  i
----------------------
7,  9,  7,  9,  5,

6   7   8   9  10  i
----------------------
9,  9,  9,  2,  1,

11  12  13  14  15  i
--------------------
2,  11, 11, 6,  4


]]