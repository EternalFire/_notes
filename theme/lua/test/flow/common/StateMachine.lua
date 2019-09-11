
local _debug_state = true

local function createState(param)
    if type(param) == "table" then
        local state = {
            name = param["name"],
            transfer = param["transfer"], -- method, return next state name
            onEnter = param["onEnter"], -- method
            onLeave = param["onLeave"],
            onTick = param["onTick"],
            onPause = param["onPause"],
            onResume = param["onResume"],
            onInterrupt = param["onInterrupt"],
            onDone = param["onDone"],
            data = param["data"], -- other data

            isDone = false,
            isEntered = false,
            isPaused = false,
            isTicking = false,
            tickedCount = 0,
            tickedTime = 0,
            preState = nil,

            done = function(self)
                if _debug_state then
                    print(os.clock(), "done ", self.name)
                end

                self.isDone = true
                self.isTicking = false
                self.isPaused = false

                if type(self.onDone) == "function" then
                    self:onDone()
                end
            end,
            enter = function(self, preState)
                if _debug_state then
                    -- print(os.clock(), "enter ", self.name)
                end

                self.isEntered = true
                self.isTicking = true
                self.isPaused = false
                self.tickedCount = 0
                self.tickedTime = 0
                self.preState = preState

                if type(self.onEnter) == "function" then
                    self:onEnter(preState)
                end
            end,
            leave = function(self)
                if _debug_state then
                    -- print(os.clock(), "leave ", self.name)
                end

                self.isEntered = false
                self.isTicking = false
                self.isDone = false

                if type(self.onLeave) == "function" then
                    self:onLeave()
                end
            end,
            tick = function(self, dt)
                if not self.isPaused then
                    self.tickedCount = self.tickedCount + 1
                    self.tickedTime = self.tickedTime + dt

                    if type(self.onTick) == "function" then
                        self:onTick(dt)
                    end
                end
            end,
            pause = function(self)
                if _debug_state then
                    print(os.clock(), "pause ", self.name)
                end

                self.isPaused = true

                if type(self.onPause) == "function" then
                    self:onPause()
                end
            end,
            resume = function(self)
                if _debug_state then
                    print(os.clock(), "resume ", self.name)
                end

                self.isPaused = false

                if type(self.onResume) == "function" then
                    self:onResume()
                end
            end,
            interrupt = function(self)
                if _debug_state then
                    print(os.clock(), "interrupt ", self.name)
                end

                self.isDone = false
                self.isTicking = false
                self.isPaused = false

                if type(self.onInterrupt) == "function" then
                    self:onInterrupt()
                end
            end,
        }

        return state
    end
end

--- state.enter() => state.tick() => state.done() => state.transfer(), get next_state => state.leave()
--- next_state.enter() => ...
local function createStateMachine(param)
    if type(param) == "table" then
        local machine = {
            stateDict = {},
            currentState = nil,
            transfer = function(self, nextState)
                local state = self.stateDict[nextState]
                local cur = self.currentState

                if state ~= nil then
                    if cur ~= nil then
                        if cur.isEntered then
                            if not cur.isDone then
                                cur:interrupt()
                            end

                            cur:leave()
                        end
                    end

                    self.currentState = state
                    state:enter(cur)
                    -- self.currentState = state
                end
            end,
            tick = function(self, dt)
                local cur = self.currentState
                local stateDict = self.stateDict

                if cur then
                    -- state done
                    if cur.isDone and cur.isEntered then
                        local nextStateName = cur:transfer()
                        cur:leave()

                        local nextState = stateDict[nextStateName]
                        if nextState then
                            self.currentState = nextState
                            nextState:enter(cur)
                            -- self.currentState = nextState
                        end
                    end

                    if cur.isTicking then
                        cur:tick(dt)
                    end
                end
            end,
            pause = function(self)
                local cur = self.currentState
                if cur then
                    cur:pause()
                end
            end,
            resume = function(self)
                local cur = self.currentState
                if cur then
                    cur:resume()
                end
            end,
        }

        if type(param.states) == "table" then
            for _, state in ipairs(param.states) do
                if state and state.name then
                    machine.stateDict[state.name] = state
                end
            end
        end

        return machine
    end
end


-- local s1 = createState({
--     name = "s1",
--     transfer = function(s)
--         print(s.name, s.isEntered, s.isDone)
--         return "next_state_name"
--     end,
--     onEnter = function(s, preState)end,
--     onLeave = function(s)end,
--     onTick = function(s, dt)end,
--     onPause = function(s)end,
--     onResume = function(s)end,
--     onInterrupt = function(s)end,
-- })

local StateMachine = {}
StateMachine.createState = createState
StateMachine.create = createStateMachine

return StateMachine