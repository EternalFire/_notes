
local runTest = false

-- Matrix(m x n), row(height, y): m, col(width, x): n
local function createMatMap(m, n)
    local Mat = {}
    Mat.w = n
    Mat.h = m
    Mat.list = {}
    Mat.rowMap = {}
    Mat.colMap = {}

    function Mat:calcIndex(x, y)
        return (y - 1) * self.w + x
    end

    function Mat:calcXY(index)
        local x = (index - 1) % self.w + 1
        local y = math.floor((index - 1) / self.w) + 1
        return x, y
    end

    function Mat:checkInside(x, y)
        if x >= 1 and x <= self.w and y >= 1 and y <= self.h then
            return true
        end
        return false
    end

    -- ..., y1, ...
    -- ..., y0, ...
    function Mat:isUpNeighbor(x0, y0, x1, y1)
        if x0 == x1 and y0 - y1 == 1 then
            if self:checkInside(x0, y0) and self:checkInside(x1, y1) then
                return true
            end
        end
        return false
    end

    -- ..., y0, ...
    -- ..., y1, ...
    function Mat:isDownNeighbor(x0, y0, x1, y1)
        if x0 == x1 and y1 - y0 == 1 then
            if self:checkInside(x0, y0) and self:checkInside(x1, y1) then
                return true
            end
        end
        return false
    end

    -- ..., x1, x0, ...
    function Mat:isLeftNeighbor(x0, y0, x1, y1)
        if y0 == y1 and x0 - x1 == 1 then
            if self:checkInside(x0, y0) and self:checkInside(x1, y1) then
                return true
            end
        end
        return false
    end

    -- ..., x0, x1, ...
    function Mat:isRightNeighbor(x0, y0, x1, y1)
        if y0 == y1 and x1 - x0 == 1 then
            if self:checkInside(x0, y0) and self:checkInside(x1, y1) then
                return true
            end
        end
        return false
    end

    function Mat:isUpSide(x0, y0, x1, y1)
        if x0 == x1 and y0 > y1 then
            return true
        end
        return false
    end

    function Mat:isDownSide(x0, y0, x1, y1)
        if x0 == x1 and y0 < y1 then
            return true
        end
        return false
    end

    function Mat:isLeftSide(x0, y0, x1, y1)
        if y0 == y1 and x1 < x0 then
            return true
        end
        return false
    end

    function Mat:isRightSide(x0, y0, x1, y1)
        if y0 == y1 and x1 > x0 then
            return true
        end
        return false
    end

    function Mat:createNode(index, value)
        local Node = {
            index = index or 0,
            x = 0,
            y = 0,
            value = value,
        }
        return Node
    end

    function Mat:addNode(node)
        if node then
            table.insert(self.list, node)
            node.index = #self.list
            node.x, node.y = self:calcXY(node.index)

            self.rowMap[node.y] = self.rowMap[node.y] or {}
            self.rowMap[node.y][node.x] = node

            self.colMap[node.x] = self.colMap[node.x] or {}
            self.colMap[node.x][node.y] = node
        end
    end

    function Mat:updateNodeValue(x, y, value)
        local index = self:calcIndex(x, y)
        local node = self.list[index]
        if node then
            node.value = value
        end
    end

    function Mat:set(x, y, value)
        if type(x) == "table" then
            self:setByList(x)
        else
            self:updateNodeValue(x, y, value)
        end
    end

    function Mat:setByList(valueList)
        if valueList then
            for i = 1, #valueList do
                local value = valueList[i]
                local x, y = self:calcXY(i)
                self:updateNodeValue(x, y, value)
            end
        end
    end

    function Mat:get(x, y)
        return self.colMap[x][y]
    end

    function Mat:walk(callback, beginIndex, endIndex)
        if type(callback) == "function" then
            beginIndex = beginIndex or 1
            endIndex = endIndex or #self.list
            for i = beginIndex, endIndex do
                local node = self.list[i]
                if node then
                    callback(i, node.x, node.y, node.value, node)
                end
            end
        end
    end

    function Mat:walkRow(callback, beginRow)
        if type(callback) == "function" then
            beginRow = beginRow or 1
            for y = beginRow, self.h do
                callback(y, self.rowMap[y])
            end
        end
    end

    function Mat:walkCol(callback, beginCol)
        if type(callback) == "function" then
            beginCol = beginCol or 1
            for x = beginCol, self.w do
                callback(x, self.colMap[x])
            end
        end
    end

    function Mat:walkCross(callback, startX, startY)
        self:walk(function(i, x, y, value, node)
            if startX == x and startY == y then
                return
            end
            if startX == x or startY == y then
                callback(i, x, y, value, node)
            end
        end)
    end

    function Mat:find(targetValue)
        local nodeList = {}
        self:walk(function(i, x, y, value, node)
            if value == targetValue then
                table.insert(nodeList, node)
            end
        end)
        return nodeList
    end


    function Mat:init()
        local len = self.w * self.h
        for i = 1, len do
            local node = self:createNode(i)
            self:addNode(node)
        end
    end

    function Mat:printInfo()
        print("width = ", self.w)
        print("height = ", self.h)
        print("len = ", #self.list)
        print("len of rowMap =", #self.rowMap)
        print("len of colMap =", #self.colMap)

        for i = 1, self.h do
            print("row", i, "len = ", #self.rowMap[i])
        end
        for i = 1, self.w do
            print("col", i, "len = ", #self.colMap[i])
        end
    end

    function Mat:printMat()
        -- local t = {}
        for i, rowList in ipairs(self.rowMap or {}) do
            if i == 1 then
                local t0 = {}
                for j = 1, self.w do
                    table.insert(t0, string.format("%8s", j))
                end
                print(table.concat(t0, " "))
                print("----------------------")
            end

            local t1 = {}
            for j, node in ipairs(rowList or {}) do

                local field = string.format("%s", node.value)

                if j == 1 then
                    field = string.format("%s | %s", node.y, node.value)
                end

                table.insert(t1, string.format("%8s", field))
            end
            -- table.insert(t, table.concat(t1))
            print(table.concat(t1, " "))
        end
    end

    Mat:init()

    return Mat
end

local function test()
    local mat32 = createMatMap(3, 2)
    mat32:printInfo()

    mat32:walk(function(i, x, y, value, node)
        if x == y then
            node.value = 1
        else
            mat32:updateNodeValue(x, y, 0)
        end
    end)

    -- mat32:walk(function(i, x, y, value, node)
    --     print(i, value)
    -- end)

    -- mat32:walkCol(function(x, nodeList)
    --     print(x)
    --     if nodeList then
    --         for i = 1, #nodeList do
    --             local node = nodeList[i]
    --             if node then
    --                 print("", node.index, node.x, node.y, node.value)
    --             end
    --         end
    --     end
    -- end)

    mat32:printMat()
end

if runTest then test() end

local export = {
    createMatMap = createMatMap,
    test = test
}

return export