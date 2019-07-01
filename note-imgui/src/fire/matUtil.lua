

local runTest = true
local matUtil = {}

local function _checkContinualNode(nodeList, times, isVertical)
    local list = {}
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
                num = 0
                list = {}
            end

            pre = node
        end
    end

    if num < times then
        list = nil
    end

    return list
end

---find the nodes with the same value in matMap
---and the number of neighbor greater than times
---@return NodeList with the same value
function matUtil.findCrossNodesContinually(mat, x0, y0, times)
    if mat then
        times = times or 1
        times = math.max(1, times)

        local vertical, horizontal = matUtil.findCrossNodes(mat, x0, y0)

        local vNodeList = _checkContinualNode(vertical, times, true)
        local hNodeList = _checkContinualNode(horizontal, times, false)

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

function matUtil.findCrossNodes(mat, x0, y0)
    local vertical = {}
    local horizontal = {}
    local target = mat:get(x0, y0)

    mat:walkCross(function(i, x, y, value, node)
        if value == target.value then
            if mat:isUpSide(target.x, target.y, x, y) or mat:isDownSide(target.x, target.y, x, y) then
                table.insert(vertical, node)
            end

            if mat:isLeftSide(target.x, target.y, x, y) or mat:isRightSide(target.x, target.y, x, y) then
                table.insert(horizontal, node)
            end
        end
    end, target.x, target.y)

    if #vertical > 0 then
        table.insert(vertical, target)
    end

    if #horizontal > 0 then
        table.insert(horizontal, target)
    end

    local function cmpIndex(nodeA, nodeB)
        return nodeA.index < nodeB.index
    end

    table.sort(vertical, cmpIndex)
    table.sort(horizontal, cmpIndex)

    return vertical, horizontal
end

if runTest then
    function matUtil.test()
        local MatMap = require("matMap")
        local createMatMap = MatMap.createMatMap

        local mat = createMatMap(4, 4)
        mat:set({
            1, 2, 3, 1,
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
        local vertical, horizontal = matUtil.findCrossNodesContinually(mat, 1, 3, 3)
        if vertical then
            print("vertical continual match")
        end

        if horizontal then
            print("horizontal continual match")
        end

        print()
    end


    matUtil.test()
end

return matUtil