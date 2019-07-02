
local runTest = false
local matUtil = {}

local function _checkContinualNode(nodeList, times, isVertical)
    local list = {}
    local savedList = {}
    local pre = nodeList[1]
    local num = 1
    table.insert(list, pre)

    for i = 2, #nodeList do
        local node = nodeList[i]
        local go_on = false

        if node then
            if isVertical then
                if node.y == pre.y + 1 then
                    go_on = true
                end
            else
                if node.x == pre.x + 1 then
                    go_on = true
                end
            end

            if go_on then
                num = num + 1
                table.insert(list, node)
            else
                if num >= times then
                    for j = 1, #list do
                        table.insert(savedList, list[j])
                    end
                end

                num = 1
                list = {node}
            end

            pre = node
        end
    end

    if num < times then
        list = nil

    end

    if #savedList > 0 then
        list = list or {}

        for i = 1, #savedList do
            table.insert(list, savedList[i])
        end
    end

    return list
end

---find the nodes with the same value in matMap
---and the number of neighbor greater than times
---@return NodeList with the same value
function matUtil.findCrossNodesContinually(mat, x0, y0, times, isFindVertical, isFindHorizontal)
    if mat then
        times = times or 1
        times = math.max(1, times)

        if isFindVertical == nil then
            isFindVertical = true
        end

        if isFindHorizontal == nil then
            isFindHorizontal = true
        end

        local vertical, horizontal = matUtil.findCrossNodes(mat, x0, y0, isFindVertical, isFindHorizontal)
        local vNodeList, hNodeList

        if isFindVertical then
            vNodeList = _checkContinualNode(vertical, times, true)
        end

        if isFindHorizontal then
            hNodeList = _checkContinualNode(horizontal, times, false)
        end

        return vNodeList, hNodeList
    end
end

function matUtil.findCrossNodesInDirection(mat, x0, y0)
    local up = {}
    local down = {}
    local left = {}
    local right = {}
    local target = mat:get(x0, y0)

    mat:walkCross(function(i, x, y, value, node)
        if value == target.value then
            if mat:isUpSide(target.x, target.y, x, y) then
                table.insert(up, node)
            end
            if mat:isDownSide(target.x, target.y, x, y) then
                table.insert(down, node)
            end
            if mat:isLeftSide(target.x, target.y, x, y) then
                table.insert(left, node)
            end
            if mat:isRightSide(target.x, target.y, x, y) then
                table.insert(right, node)
            end
        end
    end, target.x, target.y)

    return up, down, left, right
end

function matUtil.findCrossNodes(mat, x0, y0, isFindVertical, isFindHorizontal)
    local vertical = {}
    local horizontal = {}

    if isFindVertical == nil then
        isFindVertical = true
    end

    if isFindHorizontal == nil then
        isFindHorizontal = true
    end

    if isFindVertical or isFindHorizontal then
        local target = mat:get(x0, y0)

        mat:walkCross(function(i, x, y, value, node)
            if value == target.value then

                if isFindVertical then
                    if mat:isUpSide(target.x, target.y, x, y) or mat:isDownSide(target.x, target.y, x, y) then
                        table.insert(vertical, node)
                    end
                end

                if isFindHorizontal then
                    if mat:isLeftSide(target.x, target.y, x, y) or mat:isRightSide(target.x, target.y, x, y) then
                        table.insert(horizontal, node)
                    end
                end
            end
        end, target.x, target.y)

        local toSort = false

        if #vertical > 0 then
            table.insert(vertical, target)
            toSort = true
        end

        if #horizontal > 0 then
            table.insert(horizontal, target)
            toSort = true
        end

        if toSort then
            local function cmpIndex(nodeA, nodeB)
                return nodeA.index < nodeB.index
            end

            table.sort(vertical, cmpIndex)
            table.sort(horizontal, cmpIndex)
        end
    end

    return vertical, horizontal
end

function matUtil.findAllEqualCrossNodesContinually(mat, times)
    times = times or 3
    local vNodes = {} -- { index = { nodeList } }
    local hNodes = {} -- { index = { nodeList } }
    local vRecord = {}
    local hRecord = {}

    mat:walk(function(i, x, y, value, node)
        local isFindVertical = true
        local isFindHorizontal = true

        if vRecord[i] then
            isFindVertical = false
            print("ignore vertical i =", i, x, y)
        end

        if hRecord[i] then
            isFindHorizontal = false
            print("ignore horizontal i =", i, x, y)
        end

        local vertical, horizontal = matUtil.findCrossNodesContinually(mat, x, y, times, isFindVertical, isFindHorizontal)
        if vertical then
            local num = 0
            for _i = 1, #vertical do
                local _node = vertical[_i]
                if _node then
                    if not vRecord[_node.index] then
                        vRecord[_node.index] = true
                        num = num + 1
                    end
                end
            end

            if num == #vertical then
                vNodes[i] = vNodes[i] or {}
                table.insert(vNodes[i], vertical)
            end
        end

        if horizontal then
            local num = 0
            for _i = 1, #horizontal do
                local _node = horizontal[_i]
                if _node then
                    if not hRecord[_node.index] then
                        hRecord[_node.index] = true
                        num = num + 1
                    end
                end
            end

            if num == #horizontal then
                hNodes[i] = hNodes[i] or {}
                table.insert(hNodes[i], horizontal)
            end
        end
    end)
    return vNodes, hNodes
end

if runTest then
    function matUtil.test()
        local MatMap = require("matMap")
        local createMatMap = MatMap.createMatMap

        local mat = createMatMap(4, 4)
        mat:set({
            1, 2, 3, 0,
            1, 0, 0, 0,
            1, 3, 1, 0,
            0, 1, 0, 0,
        })

        mat:printMat()

        -- local list0 = mat:find(0)
        -- local list1 = mat:find(1)
        -- local list2 = mat:find(2)
        -- local list3 = mat:find(3)

        -- local up, down, left, right = matUtil.findCrossNodesInDirection(mat, 3, 2)


        -- local vertical, horizontal = matUtil.findCrossNodesContinually(mat, 4, 4, 2)
        -- if vertical then
        --     print("vertical continual match")
        -- end
        -- if horizontal then
        --     print("horizontal continual match")
        -- end

        local times = 4
        local vNodes = {} -- { index = { nodeList } }
        local hNodes = {} -- { index = { nodeList } }

        vNodes, hNodes = matUtil.findAllEqualCrossNodesContinually(mat, times)

        print()
    end


    matUtil.test()
end

return matUtil