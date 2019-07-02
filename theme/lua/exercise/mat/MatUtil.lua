local MatUtil = {}

function MatUtil.makeMat3x5List(list)
    local result = {}
    for i = 1, 5 do
        for j = i, i + 10, 5 do
            if list[j] ~= nil then
                table.insert(result, list[j])
            else
                table.insert(result, 0)
            end
        end
    end
    return result
end

function MatUtil.makeMat5x3List(list)
    local result = {}
    for i = 1, 3 do
        for j = i, i + 12, 3 do
            if list[j] ~= nil then
                table.insert(result, list[j])
            else
                table.insert(result, 0)
            end
        end
    end
    return result
end

function MatUtil.shuffle(list, stride)
    local start = 1
    local endIndex = start + stride
    local result = {}
    local element
    local times = math.floor(#list / stride)
    local used = {}

    math.randomseed(os.clock() * os.time())

    for tt = 1, times do
        for i = start, endIndex - 1, stride do
            local indexList = {}

            for j = i, i + stride - 1 do
                element = list[j]
                if element then
                    table.insert(indexList, j)
                end
            end

            if #indexList > 0 then
                local ordered = {} -- index order
                while #indexList > 0 do
                    local randomIndex = math.random(1, #indexList)
                    table.insert(ordered, indexList[randomIndex])
                    table.remove(indexList, randomIndex)
                end

                for pos = 1, #ordered do
                    local indexInList = ordered[pos]
                    used[indexInList] = true
                    element = list[indexInList]
                    if element then
                        table.insert(result, element)
                    end
                end
            end
        end

        start = start + stride
        endIndex = start + stride
    end

    for i = 1, #list do
        if not used[i] then
            table.insert(result, list[i])
        end
    end

    --    for i = 1, #result do
    --      print(i, result[i])
    --    end

    return result
end

function MatUtil._test()

    --shuffle({1,2,3,4,5,}, 3)

    local list = {
        3, 3, 3, 2, 2,
        9, 1, 9, 1, 7,
        2, 2, 3, 6, 4
    }

    local m35List = MatUtil.makeMat3x5List(list)
    local m53List = MatUtil.makeMat5x3List(m35List)

    --for i = 1, #m35List do
    --  print(i, m35List[i])
    --end

    --print("-------------------")

    --for i = 1, #m53List do
    --  print(i, m53List[i])
    --end

    local new35List = MatUtil.shuffle(m35List, 3)
    local new53List = MatUtil.makeMat5x3List(new35List)
    for i = 1, #new53List do
        print(i, new53List[i])
    end
end

return MatUtil
