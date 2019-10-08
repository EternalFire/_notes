
local _timerIDs = {}

function setTimeout(callback, sec)
    local id
    local function _runSchedule(...)
        clearTimer(id)
        id = nil

        if callback then
            callback(...)
        end
    end

    sec = sec or 0
    id = cc.Director:getInstance():getScheduler():scheduleScriptFunc(_runSchedule, sec, false)

    if not _timerIDs[id] then
        _timerIDs[id] = true
    end

    return id
end

function setInterval(callback, sec)
    local id
    local function _runSchedule(...)
        if callback then
            callback(...)
        end
    end

    sec = sec or 0
    id = cc.Director:getInstance():getScheduler():scheduleScriptFunc(_runSchedule, sec, false)

    if not _timerIDs[id] then
        _timerIDs[id] = true
    end

    return id
end

function clearTimer(id)
    if id then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(id)

        if _timerIDs[id] then
            _timerIDs[id] = nil
        end
    end
end

function clearTimersInHelper()
    for id, v in pairs(_timerIDs) do
        if v then clearTimer(id) end
    end
end

function captureNode(renderTexture, node, fileBasename, isRGBA)
    if renderTexture ~= nil and node ~= nil and fileBasename ~= nil and isRGBA ~= nil then
        renderTexture:setKeepMatrix(true)
        renderTexture:begin()
        do
            node:visit()
        end
        renderTexture:endToLua()

        local fileName = fileBasename .. (isRGBA and ".png" or ".jpg")
        renderTexture:saveToFile(fileName, (isRGBA and cc.IMAGE_FORMAT_PNG or cc.IMAGE_FORMAT_JPEG), isRGBA)
        setTimeout(
            function()
                renderTexture:clear(0, 0, 0, 0)
            end,
            0.1
        )
    end
end

function keyboard(doKeyPressed, doKeyReleased)
    local pressedList = {}
    local scene = display.getRunningScene()
    local debug = false

    local function onKeyPressed(keyCode, event)
        if debug then
            print("input key [", keyCode, "]")
        end
        table.insert(pressedList, keyCode)

        if doKeyPressed then
            doKeyPressed(keyCode)
        end
    end

    local function onKeyReleased(keyCode, event)
        if debug then
            print("free key [", keyCode, "]")
        end
        table.removebyvalue(pressedList, keyCode, false)

        if doKeyReleased then
            doKeyReleased(keyCode)
        end
    end

    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(onKeyPressed, cc.Handler.EVENT_KEYBOARD_PRESSED)
    listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED)

    local eventDispatcher = scene:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, scene)

    setInterval(
        function()
            if #pressedList > 0 then
                for i = 1, #pressedList do
                    if debug then
                        print("hold key [", pressedList[i], "]")
                    end
                    if doKeyPressed then
                        doKeyPressed(pressedList[i])
                    end
                end
            else
                -- print("pressedList is empty")
            end
        end,
        0.02
    )
end

function createTouchListener(node, option)
    if node then
        option = option or {}
        local debug = option.debug or false

        local beganCB = option.beganCB -- function
        local movedCB = option.movedCB -- function
        local endedCB = option.endedCB -- function
        local cancelledCB = option.cancelledCB -- function

        local boxOrRadius = option.boxOrRadius -- number or rect
        local op_checkZeroSize = false
        if option.checkZeroSize ~= nil then
            op_checkZeroSize = option.checkZeroSize
        end

        local op_isTouchMove = false
        if option.isTouchMove ~= nil then
            op_isTouchMove = option.isTouchMove
        end
        local op_isSwallow = true
        if option.isSwallow ~= nil then
            op_isSwallow = option.isSwallow
        end

        local listener = cc.EventListenerTouchOneByOne:create()
        local radius, box
        local zeroPoint = cc.p(0, 0)
        local isInside = false

        if boxOrRadius then
            if type(boxOrRadius) == "number" then
                radius = boxOrRadius
            elseif boxOrRadius.x and boxOrRadius.y and boxOrRadius.width and boxOrRadius.height then
                box = boxOrRadius
            end
        end

        local function _checkInside(positionInNode)
            if positionInNode then
                if radius then
                    if debug then
                        print("check circle ", radius, positionInNode.x, positionInNode.y)
                    end

                    if cc.pDistanceSQ(positionInNode, zeroPoint) <= radius * radius then
                        return true
                    end
                elseif box then
                    if debug then
                        print("check box ", positionInNode.x, positionInNode.y)
                    end

                    if cc.rectContainsPoint(box, positionInNode) then
                        return true
                    end
                else
                    local s = node:getContentSize()

                    if debug then
                        print("check default ", positionInNode.x, positionInNode.y, s.width, s.height)
                    end

                    if s.width == 0 or s.height == 0 then
                        if op_checkZeroSize then
                            local min = 10
                            if s.width < min then
                                s.width = min
                            end
                            if s.height < min then
                                s.height = min
                            end
                        else
                            return false
                        end
                    end

                    local rect = cc.rect(0, 0, s.width, s.height)
                    if cc.rectContainsPoint(rect, positionInNode) then
                        return true
                    end
                end
            end

            return false
        end

        local function touchComplete()
            isInside = false
        end

        local function _onTouchBegan(touch, event)
            if not node:isVisible() then
                return false
            end

            local touchLocation = touch:getLocation()
            local positionInNode = node:convertToNodeSpace(touchLocation)
            local target = event:getCurrentTarget()
            isInside = _checkInside(positionInNode)

            if debug then
                print("onTouchBegan", os.clock(), target:getName(), isInside)
            end

            if beganCB then
                return beganCB(isInside, touchLocation, positionInNode)
            else
                if isInside then
                    return true
                end
            end

            return false
        end

        local function _onTouchMoved(touch, event)
            if debug then
                print("onTouchMoved", os.clock())
            end

            if op_isTouchMove then
                local delta = touch:getDelta()
                local pos = cc.p(node:getPosition())
                pos.x = pos.x + delta.x
                pos.y = pos.y + delta.y
                node:setPosition(pos)
            end

            if movedCB then
                local touchLocation = touch:getLocation()
                movedCB(touchLocation, touch)
            end
        end

        local function _onTouchEnded(touch, event)
            if debug then
                print("onTouchEnded", os.clock())
            end

            local _isInside = isInside
            touchComplete()

            if endedCB then
                local touchLocation = touch:getLocation()
                local positionInNode = node:convertToNodeSpace(touchLocation)
                _isInside = _checkInside(positionInNode)
                endedCB(_isInside, touchLocation, positionInNode, touch)
            end
        end

        local function _onTouchCancelled(touch, event)
            if debug then
                print("onTouchCancelled", os.clock())
            end

            local _isInside = isInside
            touchComplete()

            if cancelledCB then
                cancelledCB(_isInside)
            end
        end

        listener:setSwallowTouches(op_isSwallow)
        listener:registerScriptHandler(_onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
        listener:registerScriptHandler(_onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
        listener:registerScriptHandler(_onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
        listener:registerScriptHandler(_onTouchCancelled, cc.Handler.EVENT_TOUCH_CANCELLED)

        local eventDispatcher = node:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, node)

        return listener
    end
end

function removeTouchListener(node, listener)
    if node and listener then
        local eventDispatcher = node:getEventDispatcher()
        eventDispatcher:removeEventListener(listener)
    end
end

---get cell info in grid
---@param param.size cc.Size grid node's contentSize
function calcCellInfo(param)
    param = param or {}
    local size = param.size
    local maxCol = param.maxCol or 1
    local maxRow = param.maxRow or 1
    local col = param.col or 1
    local row = param.row or 1
    local spanCol = param.spanCol or 0
    local spanRow = param.spanRow or 0

    local result = {
        cellSize = nil,
        expandedCellSize = nil,
        col = 1,
        row = 1,
        x = 0,
        y = 0,
    }

    if size then
        local x, y = 0, 0
        local cellSize = cc.size(size.width / maxCol, size.height / maxRow)
        result.cellSize = cellSize

        col = math.min(math.max(col, 1), maxCol)
        row = math.min(math.max(row, 1), maxRow)
        result.col, result.row = col, row

        local expandedCol = math.min(math.max(col + spanCol, 1), maxCol)
        local expandedRow = math.min(math.max(row + spanRow, 1), maxRow)
        local expandedCellSize = cc.size(cellSize.width * (expandedCol - col + 1), cellSize.height * (expandedRow - row + 1))
        result.expandedCellSize = expandedCellSize

        if spanCol == 0 then
            x = cellSize.width * (col - 1) + 0.5 * cellSize.width
        else
            x = cellSize.width * (col - 1) + 0.5 * expandedCellSize.width
        end

        if spanRow == 0 then
            y = size.height - (cellSize.height * (row - 1) + 0.5 * cellSize.height)
        else
            y = size.height - (cellSize.height * (row - 1) + 0.5 * expandedCellSize.height)
        end

        result.x, result.y = x, y
        return result
    end
end

function markIt(param)
    param = param or {}

    local scene = cc.Director:getInstance():getRunningScene()
    if not scene then
        return
    end

    local target = param.target -- node
    local worldPos = param.worldPos
    local color = param.color or cc.c4f(0.8, 0.01, 0.6, 0.7)
    local clear = param.clear -- boolean
    local zOrder = 100000
    local drawName = "mark_it_node"
    local draw = scene:getChildByName(drawName)

    if not draw then
        draw = cc.DrawNode:create()
        draw:addTo(scene)
    end

    if clear then
        draw:clear()
    end

    if target then
        worldPos = target:convertToWorldSpace(cc.p(0,0))
    end

    if worldPos then
        --                                       drawLineToCenter
        --                                             |
        --                                             v
        -- draw:drawCircle(worldPos, 5, math.pi/2, 50, true, 1.0, 1.0, color)

        draw:drawSolidCircle(worldPos, 10, math.pi/2, 50, 1.0, 1.0, color)
    end
end
