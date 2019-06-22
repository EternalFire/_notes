function GetArrResult(itemIdList)
    local w = 5
    local h = 3
    local n = w * h
    local list = itemIdList
    local allNodes
    local rowMap
    local colMap
    local spValue_1 = 1
    local pathNodes

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
        return math.floor((index - 1) / w) + 1
    end

    local function colIndex(index)
        return (index - 1) % w + 1
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

    local function initPath()
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
                        if value == spValue_1 then
                            -- for i, parent in ipairs(_node1.parents) do
                            --     if parent and (parent.value == value1 or parent.value == spValue_1) then
                            --         if colMap and colMap[1] then
                            --             for j = 1, #colMap[1] do
                            --                 local colNode = colMap[1][j]
                            --                 if colNode and (colNode.value == parent.value or colNode.value == spValue_1) then
                            --                     sameValue = true
                            --                     break
                            --                 end
                            --             end
                            --         end
                            --     end

                            --     if sameValue then
                            --         break
                            --     end
                            -- end -- for

                            sameValue = true
                        end
                    end
                end

                if sameValue then
                    table.insert(_node.children, _node1)
                    table.insert(_node1.parents, _node)
                end
            end, x + 1)
        end)
    end

    local function depthWalk(callback, node)
        if node and callback then
            local stack = {}
            local path = {}
            local element = node
            local elementIndex = node.index
            table.insert(stack, elementIndex)

            while #stack > 0 do
                elementIndex = stack[#stack]
                element = getNodeByIndex(elementIndex)

                table.remove(stack, #stack)

                local _noChildAfterSpValue = false

                -- check special value
                if element.value == spValue_1 and #element.children ~= 0 then
                    _noChildAfterSpValue = true

                    for i = 1, #element.children do
                        local child = element.children[i]
                        if child and (child.value == node.value or child.value == spValue_1) then
                            _noChildAfterSpValue = false
                            break
                        end
                    end
                end

                if #element.children == 0 or _noChildAfterSpValue then
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
                        table.insert(stack, child.index)
                        path[child.index] = element.index
                    end
                end
            end
        end
    end

    local function filterPathList(pathList)
        local _pathList = {}
        if pathList then
            local _firstNode = getNodeByIndex(pathList[1])
            local preColIndex = 0
            if _firstNode then
                for i, _index in ipairs(pathList) do
                    local nodeInPath = getNodeByIndex(_index)
                    if nodeInPath then
                        local col = colIndex(_index)
                        if col == preColIndex + 1 then
                            if nodeInPath.value == _firstNode.value or nodeInPath.value == spValue_1 then
                                _pathList = _pathList or {}
                                table.insert(_pathList, _index)
                                preColIndex = col
                            end
                        else
                            return {}
                        end
                    end
                end -- for
            end
        end
        return _pathList
    end

    local function printChildren()
        iterateAllNodesByCol(function(_node, x, y, index, value, children)
            -- print(string.format("%d %d", index, value))

            print(string.format("- x:%d", x))
            print(string.format("  i:%d v:%d", index, value))
            for i, child in ipairs(children) do
                print(string.format("    i:%d v:%d", child.index, child.value))
            end
        end)
    end

    local function _run()
        local result = {}

        initAllNodes()
        initPath()

        print(allNodes)

        -- check children
        -- printChildren()

        -- if 1 then return result end;

        local pathRecord = {}
        local visited = {}
        local _pathListStr = ""
        iterateColList(function(_node, x, y, index, value, children)
            depthWalk(function(pathList, root)
                -- print(string.format("depthWalk: %s\t\tindex: %d", table.concat(pathList, ","), root.index))

                local _pathList = filterPathList(pathList)

                if #_pathList >= 3 then
                    _pathListStr = table.concat(_pathList, ",")
                    if _pathList and not visited[_pathListStr] then
                        print(string.format("depthWalk: %s\t\tindex: %d", table.concat(pathList, ","), root.index))

                        table.insert(pathRecord, _pathList)
                        visited[_pathListStr] = true

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

        print("---------------------------")
        for i = 1, #result do
            print(i, table.concat(result[i], "~"))
        end

        return result
    end

    return _run()
end

local _result
-- test
--_result = GetArrResult({
--   7,9,7,9,5,
--   9,9,9,2,1,
--   2,11,11,6,4
--})

 _result = GetArrResult({
     3, 3, 3, 2, 2,
     9, 1, 9, 1, 7,
     2, 2, 3, 6, 4
 })



print("end")

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