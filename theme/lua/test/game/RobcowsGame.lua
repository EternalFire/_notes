
_UseInGame = true

local Robcows
local StateMachine
local poker
local gameState

if _UseInGame then
    Robcows = import("game.robcows")
    StateMachine = import("game.StateMachine")
    poker = import("game.poker")
    gameState = import("game.gameState")
else
    require("__cc")
    Robcows = require("robcows")
    StateMachine = require("statemachine")
    poker = require("poker")
    gameState = require("gamestate")
end

local RobcowsGame = {}

function RobcowsGame:init()
    local createState, createStateMachine = StateMachine.createState, StateMachine.createStateMachine

    local s_turn_start
    local s_choose_banker
    local s_add_rate
    local s_deal
    local s_make_card_type
    local s_pk
    local s_turn_end
    local states
    local sm

    -- local s_turn_start = createState({
    --     name = "s_turn_start",
    --     transfer = function(s)
    --         print(s.name, s.isEntered, s.isDone)
    --     end,
    --     onEnter = function(s)end,
    --     onLeave = function(s)end,
    --     onTick = function(s, dt)end,
    --     onPause = function(s)end,
    --     onResume = function(s)end,
    --     onInterrupt = function(s)end,
    -- })

    gameState:init()

    print("create all cards")
    gameState.allCards = Robcows:createAllCards()

    local s_turn_start = createState({
        name = "s_turn_start",
        transfer = function(s)
            -- print(s.name, s.isEntered, s.isDone)
            return "s_choose_banker"
        end,
        onEnter = function(s)
            -- s:done()
            gameState.usedCard = {}

            gameState:iterateSeat(function(player)
                player.cardType = Robcows.CardType.Cow0
                player.wonGold = 0
            end)
        end,
        onLeave = function(s)end,
        onTick = function(s, dt)
            s:done()
        end,
        onPause = function(s)end,
        onResume = function(s)end,
        onInterrupt = function(s)end,
    })

    local s_choose_banker = createState({
        name = "s_choose_banker",
        transfer = function(s)
            print(s.name, s.isEntered, s.isDone)
            return "s_add_rate"
        end,
        onEnter = function(s)
            gameState:iterateSeat(function(player)
                gameState:chooseBankerRateRandomly(player)
            end)

            local banker = gameState:findBanker()
            print("banker is ", banker._tag)
        end,
        onLeave = function(s)end,
        onTick = function(s, dt)
            -- print(s.name, s.tickedCount, s.tickedTime)
            if s.tickedTime >= 0.44 then

                s:done()
            end
        end,
        onPause = function(s)end,
        onResume = function(s)end,
        onInterrupt = function(s)end,
    })

    local s_add_rate = createState({
        name = "s_add_rate",
        transfer = function(s)
            print(s.name, s.isEntered, s.isDone)
            return "s_deal"
        end,
        onEnter = function(s)
            gameState:iterateSeat(function(player)
                if gameState.banker ~= player then
                    if player.isRobot then
                        gameState:addRateRandomly(player)
                    elseif player.isUser then
                        gameState:addRate(player) -- waiting for player
                    end

                    print(player._tag, player.rateAdd)
                end
            end)
        end,
        onLeave = function(s)end,
        onTick = function(s, dt)
            -- print(s.name, s.tickedCount, s.tickedTime)
            if s.tickedTime >= 1 then
                s:done()
            end
        end,
        onPause = function(s)end,
        onResume = function(s)end,
        onInterrupt = function(s)end,
    })

    local s_deal = createState({
        name = "s_deal",
        transfer = function(s)
            return "s_make_card_type"
        end,
        onEnter = function(s, preState)
            gameState:iterateSeat(function(player)
                gameState:deal(player)
                print(player._tag)
                poker.printCards(player.cards)
            end)
        end,
        onLeave = function(s)end,
        onTick = function(s, dt)
            if s.tickedTime >= 0.2 then
                s:done()
            end
        end,
        onPause = function(s)end,
        onResume = function(s)end,
        onInterrupt = function(s)end,
    })

    local s_make_card_type = createState({
        name = "s_make_card_type",
        transfer = function(s)
            print(s.name, s.isEntered, s.isDone)
            return "s_pk"
        end,
        onEnter = function(s)
            gameState:iterateSeat(function(player)
                print(player._tag)
                -- poker.printCards(player.cards)
                local cardsWithType = Robcows:makeCardType(player.cards)

                for k, list in pairs(cardsWithType) do
                    player.cardType = k
                    player.typeCards = list[1]
                    player.sortedCards = Robcows:sortByCardType(player.typeCards, player.cardType)
                    ------
                    print("player.cardType = ", player.cardType)
                    print("typeCards:")
                    poker.printCards(player.typeCards)
                    print("sortedCards:")
                    poker.printCards(player.sortedCards)
                    ------
                    break
                end

                -- Robcows:printCardsWithType(cardsWithType)
            end)
            -- local cardsWithType = Robcows:makeCardType(cards_1)
            -- Robcows:printCardsWithType(cardsWithType)
        end,
        onLeave = function(s)end,
        onTick = function(s, dt)
            print(s.name, s.tickedCount, s.tickedTime)
            if s.tickedTime >= 0.2 then
                s:done()
            end
        end,
        onPause = function(s)end,
        onResume = function(s)end,
        onInterrupt = function(s)end,
    })

    local s_pk = createState({
        name = "s_pk",
        transfer = function(s)
            print(s.name, s.isEntered, s.isDone)
            return "s_turn_end"
        end,
        onEnter = function(s)
            -- compare to banker
            local banker = gameState.banker
            local betGold = gameState.betGold

            gameState:iterateSeat(function(player)
                if player ~= banker then
                    local retCmp, ratePlayer, rateBanker = Robcows.compareCards(player.sortedCards, player.cardType, banker.sortedCards, banker.cardType)

                    if retCmp == Robcows.CardsCmpResult.Win then
                        -- player win
                        player.wonGold = betGold * player.rateAdd * ratePlayer

                        -- banker lose
                        banker.wonGold = banker.wonGold - player.wonGold

                    elseif retCmp == Robcows.CardsCmpResult.Lose then
                        -- banker win
                        local gold_0 = betGold * banker.rateAdd * rateBanker
                        banker.wonGold = banker.wonGold + gold_0

                        -- player lose
                        player.wonGold = player.wonGold - gold_0
                    end

                    print(player._tag, player.wonGold, banker._tag, banker.wonGold)
                end
            end)
        end,
        onLeave = function(s)end,
        onTick = function(s, dt)
            print(s.name, s.tickedCount, s.tickedTime)
            if s.tickedTime >= 0.1 then
                s:done()
            end
        end,
        onPause = function(s)end,
        onResume = function(s)end,
        onInterrupt = function(s)end,
    })

    local s_turn_end = createState({
        name = "s_turn_end",
        transfer = function(s)
            -- print(s.name, s.isEntered, s.isDone)
            return "s_turn_start"
        end,
        onEnter = function(s)
            -- add money
            print("calculate gold in turn")
            gameState:iterateSeat(function(player)
                player.gold = player.gold + player.wonGold
                print(player._tag, player.gold)
            end)
        end,
        onLeave = function(s)
            print("----------------------------------------")
        end,
        onTick = function(s, dt)
            -- print(s.name, s.tickedCount, s.tickedTime)
            if s.tickedTime >= 5.0 then
                s:done()
            end
        end,
        onPause = function(s)end,
        onResume = function(s)end,
        onInterrupt = function(s)end,
    })

    states = {
        s_turn_start,
        s_choose_banker,
        s_add_rate,
        s_deal,
        s_make_card_type,
        s_pk,
        s_turn_end,
    }
    sm = createStateMachine{ states = states }

    self.machine = sm
    self.gameState = gameState
    self._timer = nil
end

function RobcowsGame:startByClock()
    self:start()

    -- simple engine
    local t1 = os.clock()
    local dt = 1
    local delta = 0.1
    local sm = self.machine

    while 1 do
        if dt >= delta then
            -- print(dt, os.clock())

            if sm and type(sm.tick) == "function" then
                sm:tick(dt)
            end

            t1 = os.clock()
            dt = 0
        else
            dt = os.clock() - t1
        end
    end
end

function RobcowsGame:startByCC()
    local sm = self.machine
    local function run(dt)
        sm:tick(dt)
    end

    self:start()
    --                                                                      second
    self._timer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(run, 1/30, false)
end

function RobcowsGame:start()
    self.machine:transfer("s_turn_start")
end

function RobcowsGame:tick(dt)
    if self.machine then
        self.machine:tick(dt)
    end
end

function RobcowsGame:clear()
    if self._timer then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._timer);
        self._timer = nil
    end
end

if _UseInGame then
else
    RobcowsGame:init()
    RobcowsGame:startByClock()
end

return RobcowsGame