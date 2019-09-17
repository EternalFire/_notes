
local s = [=[
挂起(suspended)     运行(running)

            停止(dead)

co = coroutine.create(f) -- suspended
coroutine.resume(co) -- running
coroutine.status(co) -- dead, 函数运行结束
coroutine.yield() -- suspended
]=]

local common = require("common")
local co

local f = function()
    local i = 1
    local s = ""
    while true do
        s = "fff status = "..coroutine.status(co)
        coroutine.yield(i, s)
        i = i + 1
    end
end

function waitForSec(sec, cb)
    local t0 = os.clock()
    local t1 = os.clock()

    while(t1 - t0 < sec) do
        t1 = os.clock()
    end

    if cb then
        cb(t1)
    end
end

function _waitForSec_V2(sec)
    local t0 = os.clock()
    local t1 = os.clock()

    while(t1 - t0 < sec) do
        t1 = os.clock()
    end

    coroutine.yield(t1)
end
local waitForSec_V2 = function(sec)
    return coroutine.wrap(_waitForSec_V2)(sec)
end

local waitForSec_V3 = function(sec)
    local _co = coroutine.create(_waitForSec_V2)
    local ret, t = coroutine.resume(_co, sec)
    return t
end

function _waitForSec_V4(sec)
    local t0 = os.clock()
    local t1 = os.clock()

    coroutine.yield()

    while(t1 - t0 < sec) do
        t1 = os.clock()
    end

    coroutine.yield(t1)
end
local test_waitForSec_V4 = function(sec)
    print("start at ", os.clock())
    local _co = coroutine.create(_waitForSec_V4)
    local ret, t = coroutine.resume(_co, sec)
    print("1:", ret, t)

    local t0 = os.clock()
    local sum = 0
    for i = 1, 10000000 do
        sum = sum + 1
    end
    local t1 = os.clock()
    print("2: cost =", t1-t0, sum)

    print("3: clock = ", os.clock())
    local ret, t = coroutine.resume(_co, sec)
    print("4: clock = ", os.clock(), ret, t)
    return t
end

function _waitForSec_V5(sec)
    local t0 = os.clock()
    local t1 = os.clock()

    while 1 do
        t1 = os.clock()

        if t1 - t0 >= sec then
            local data = coroutine.yield(true, t1, t0)
            print("out of time", data)
            t0 = os.clock()
        else
            local data = coroutine.yield(false, t1, t0)
            print("in time", data)
            break
        end
    end
end

local _asyncStep1 = function()
    waitForSec_V3(2.0)
    coroutine.yield({"result of asyncStep1"})
end
local asyncStep1 = function()
    return coroutine.wrap(_asyncStep1)()
end

local _asyncStep2 = function(v)
    waitForSec_V3(1.0)
    if v then
        common.logTable(v, "param")
        coroutine.yield({"result of asyncStep2"})
    else
        coroutine.yield({"result of asyncStep2......"})
    end
end
local asyncStep2 = function(v)
    return coroutine.wrap(_asyncStep2)(v)
end

local doAction = function()
    local ret1 = asyncStep1()
    common.logTable(ret1, "ret1")
    local ret2 = asyncStep2(ret1)
    common.logTable(ret2)
end



local State = {}
local initState, mainLoop, subLoop

local main = function()
--    local ret
--    co = coroutine.create(f)

--    for i = 1, 2 do
--        ret = {coroutine.resume(co)}
--        table.insert(ret, coroutine.status(co))
--        common.logTable(ret, "ret")
--    end

--    print("111: ", os.clock())

--    waitForSec(1.0, function(t)
--        print("222: ", os.clock(), t)
--    end)

--    print("111: ", os.clock())
--    local t = waitForSec_V2(1.0)
--    print("222: ", os.clock(), t)
--    local t = waitForSec_V2(1.0)
--    print("333: ", os.clock(), t)
--    local t = waitForSec_V2(1.0)
--    print("4: ", os.clock(), t)

--    print("111: ", os.clock())
--    local t = waitForSec_V3(1.0)
--    print("222: ", os.clock(), t)
--    local t = waitForSec_V3(1.0)
--    print("333: ", os.clock(), t)
--    local t = waitForSec_V3(1.0)
--    print("4: ", os.clock(), t)

--    local ret1 = asyncStep1()
--    common.logTable(ret1, "ret1")
--    local ret2 = asyncStep2(ret1)
--    common.logTable(ret2)

    -- State = initState(State)
    -- mainLoop()

   doAction()
end

initState = function(argState)
    local state = argState or {}

    local co = coroutine.create(_waitForSec_V5)
    state.wait = co

    return state
end

mainLoop = function()
    local t0 = os.clock()
    local t1 = os.clock()
    local dt
    while(true) do
        t1 = os.clock()
        dt = t1 - t0
        if dt >= 1.0 then

            print(os.clock(), "do sth in main loop")
            subLoop(dt)

            t0 = t1
        else
            -- continue
        end
    end
end

subLoop = function(dt)
--    if coroutine.status(State.wait) == "suspended" then
--        coroutine.resume(State.wait, 1)
--    end
    print("State.wait's status = ", coroutine.status(State.wait))
    local ret = {coroutine.resume(State.wait, 2)}
    common.logTable(ret)
    print("do sth in sub loop")
end

main()

