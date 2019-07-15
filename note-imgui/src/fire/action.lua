
-- fake duration
local max_duration = 99999
local default_duration = 1

-- cc.ActionInterval without create function
-- local Act1 = class("Act1", cc.ActionInterval)

local Act1 = class("Act1", function()
    local instance = cc.DelayTime:create(max_duration)
    return instance
end)

function Act1:ctor(duration, startNow)
    -- self:initWithDuration(max_duration)
    -- self:initWithDuration(duration)
    if duration == nil then duration = default_duration end
    if startNow == nil then startNow = true end

    -- init property
    self._dt = 0
    self._max_dt = duration
    self._isFinished = false
    self._timer = nil

    if startNow then
        self:startAction(duration)
    end
end

function Act1:initWithDuration(duration)
    cc.ActionInterval.initWithDuration(self, duration)
    print("Act1:initWithDuration ", duration, self:isDone())
end

function Act1:_runStep(t)
    if t < 0 then t = -t end

    self._dt = self._dt + t

    if self._dt >= self._max_dt - 0.02 then
        self:finishAction()
    end

    self:_update(t)
end

function Act1:_update(t)
    -- print("Act1 _update ", t, self._dt, self._max_dt)
end

function Act1:_clearTimer()
    if self._timer ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._timer)
        self._timer = nil
    end
end

function Act1:set(param)
    if param then
        local duration = param["duration"]
        if duration ~= nil then
            self._max_dt = duration
        end
    end
end

--- get property array
--- input property name array, like act1:get(""
function Act1:get(...)
    local param = {...}
    if #param > 0 then
        local result = {}
        for i = 1, #param do
            local propertyName = param[i]
            table.insert(result, self[propertyName])
        end
        return result
    end
end

function Act1:startAction(duration)
    if not self._timer then
        if duration ~= nil then
            self._max_dt = duration
        end

        self._dt = 0
        self._isFinished = false
        self._timer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(t)
            self:_runStep(t)
        end, 0, false)
    else
        self:restartAction(duration)
    end
end

function Act1:restartAction(duration)
    print("restartAction duration = ", duration, self._max_dt)
    self:_clearTimer()
    self:startAction(duration)
end

function Act1:finishAction()
    self:_clearTimer()
    self._isFinished = true

    if self._composeInstance then
        self._composeInstance:step(max_duration - self._composeInstance:getElapsed())
        -- print("force done!", self._composeInstance:getElapsed())
    else
        self:step(max_duration)
        -- print("force done!", self:getElapsed())
    end
end

function Act1:clone()
    return Act1:create(self._max_dt)
end

-- instance of cc.Sequence
function Act1:setComposeAction(instance)
    self._composeInstance = instance
end

-- end of Act1
-------------------------------------------------------------

local Wait = class("Wait", Act1)

-------------------------------------------------------------

local CCSAction = class("CCSAction", Act1)

function CCSAction:ctor(param)
    local duration = max_duration
    local startNow = param["startNow"]

    if startNow == nil then
        startNow = true
    end

    -- property
    self.animationInfo = nil
    self.actionTimeline = param["actionTimeline"]
    self.loop = false
    self.times = 1 -- animation played times

    self._curTimes = 0
    self._playParam = nil
    self._nameIndex = 0
    self._playParam = param

    -- base contructor
    self.super.ctor(self, duration, false)

    if startNow then
        self:playAction(param)
    end
end

function CCSAction:playAction(param)
    param = param or self._playParam

    if param then
        self._playParam = param

        local name = param["name"] -- animation name
        local loop = param["loop"]
        local times = param["times"]
        local nameList = param["nameList"]

        if loop ~= nil then
            self.loop = loop
        end

        if times ~= nil then
            self.times = times
        end

        if type(nameList) == "table" and #nameList > 0 then
            if self._nameIndex + 1 > #nameList then
                self._nameIndex = 1
            else
                self._nameIndex = self._nameIndex + 1
            end

            name = nameList[self._nameIndex]
        end

        if self.actionTimeline then
            self.animationInfo = self.actionTimeline:getAnimationInfo(name)

            if self.animationInfo then
                self.actionTimeline:gotoFrameAndPause(self.animationInfo.startIndex)
                self.actionTimeline:play(name, false)
            end

            if not self._timer then
                self:startAction(max_duration)
            end
        end
    end
end

function CCSAction:_update(t)
    if self.actionTimeline and self.animationInfo then
        local playing, cur = self.actionTimeline:isPlaying(), self.actionTimeline:getCurrentFrame()
        if playing then
            if cur >= self.animationInfo.endIndex - 2 and cur <= self.animationInfo.endIndex then

                if self._playParam and type(self._playParam.nameList) == "table" and #self._playParam.nameList > 0  then

                    if self._nameIndex == #self._playParam.nameList then
                        self._curTimes = self._curTimes + 1
                    end
                else
                    self._curTimes = self._curTimes + 1
                end

                if self.loop then
                    self:playAction(self._playParam)
                else
                    if self._curTimes >= self.times then
                        self:finishAction()
                    else
                        self:playAction(self._playParam)
                    end
                end
            end
        end
    end
end

function CCSAction:finishAction()
    print("CCSAction:finishAction()")

    self.super.finishAction(self)

    if self.actionTimeline and self.animationInfo then
        self.actionTimeline:gotoFrameAndPause(self.animationInfo.endIndex)
    end
end

-------------------------------------------------------------

-- local CCSArmatureAction = class("CCSArmatureAction", Act1)

-------------------------------------------------------------

-- test
local function test()

    local scene = display.getRunningScene()
    local node = cc.Node:create()
    node:addTo(scene)

    local function test_Act1()
        local act_1 = Act1:create(3.0)
        act_1:retain()
        print(os.clock(), node, act_1, act_1.__cname)

        local seq = cc.Sequence:create(
            act_1,
            cc.CallFunc:create(function()
                print("done!", os.clock())
                dump(act_1:get("_isFinished"))
            end),
            cc.DelayTime:create(3),
            cc.CallFunc:create(function()
                print("time = ", os.time(), os.clock())
            end)
        )
        seq:retain()

        act_1:setComposeAction(seq)
        node:runAction(seq)

        -- node:runAction(act_1)

        setTimeout(function()
            print(os.clock(), " seq:isDone() = ", seq:isDone())
            act_1:release()
            seq:release()
        end, 10.0)
    end

    local function test_Wait()
        -- local wait = Wait:create(5, false)
        local wait = Wait:create()
        wait:retain()
        print(wait.__cname, os.clock())

        local begin = cc.CallFunc:create(function()
            -- wait:startAction(2) -- reset duration
        end)

        local call = cc.CallFunc:create(function()
            print("finish wait action", os.clock())
            dump(wait:get("_isFinished"))
            wait:release()
        end)

        local seq = cc.Sequence:create(begin, wait, call)
        wait:setComposeAction(seq)

        node:runAction(seq)
    end

    local function test_CCSAction()
        local v = "ccs_skeleton.csb"
        local root = cc.CSLoader:createNode(v)
        local actionTimeline = cc.CSLoader:createTimeline(v)
        root:runAction(actionTimeline)

        local wait = Wait:create(3)

        local param = {
            actionTimeline = actionTimeline,
            name = "animation1",
            nameList = { "animation0", "animation1", "animation0", },
            loop = true,
            times = 1,
            startNow = false,
        }
        local ccsAction = CCSAction:create(param)
        print(ccsAction.__cname, os.clock())

        local call0 = cc.CallFunc:create(function()
            ccsAction:playAction()
        end)

        local call = cc.CallFunc:create(function()
            print("finish ccsAction action", os.clock())
        end)

        local seq = cc.Sequence:create(wait, call0, ccsAction, call)
        wait:setComposeAction(seq)
        ccsAction:setComposeAction(seq)

        node:runAction(seq)

        root:addTo(node):move(300, 400)

        setInterval(function()
            ccsAction:finishAction()
        end, 5)
    end

    -- test_Act1()
    -- test_Wait()
    -- test_CCSAction()
end

local action = {
    Act1 = Act1,
    Wait = Wait,
    CCSAction = CCSAction,
    test = test
}

return action
