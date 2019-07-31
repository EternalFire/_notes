
local poker

if _UseInGame then
    poker = import("game.poker")
else
    poker = require("poker")
end

local CardColor = poker.CardColor
local CardColors = poker.CardColors
local CardValues = poker.CardValues
local ColorEmojiDict = poker.ColorEmojiDict
local EmojiColorDict = poker.EmojiColorDict

local CardType = {
    Cow0 = 0,
    Cow1 = 1,
    Cow2 = 2,
    Cow3 = 3,
    Cow4 = 4,
    Cow5 = 5,
    Cow6 = 6,
    Cow7 = 7,
    Cow8 = 8,
    Cow9 = 9,
    Cow10 = 10,
    Bomb = 11,
    JQKs = 12,
    SmallCow = 13,
}
local CardTypeNameDict = {
    [CardType.Cow0] = "无牛",
    [CardType.Cow1] = "牛一",
    [CardType.Cow2] = "牛二",
    [CardType.Cow3] = "牛三",
    [CardType.Cow4] = "牛四",
    [CardType.Cow5] = "牛五",
    [CardType.Cow6] = "牛六",
    [CardType.Cow7] = "牛七",
    [CardType.Cow8] = "牛八",
    [CardType.Cow9] = "牛九",
    [CardType.Cow10] = "牛牛",
    [CardType.Bomb] = "四炸",
    [CardType.JQKs] = "五花牛",
    [CardType.SmallCow] = "五小牛",
}
local CardTypeRateDict = {
    [CardType.Cow0] = 1,
    [CardType.Cow1] = 1,
    [CardType.Cow2] = 1,
    [CardType.Cow3] = 1,
    [CardType.Cow4] = 1,
    [CardType.Cow5] = 1,
    [CardType.Cow6] = 1,
    [CardType.Cow7] = 2,
    [CardType.Cow8] = 2,
    [CardType.Cow9] = 2,
    [CardType.Cow10] = 3,
    [CardType.Bomb] = 4,
    [CardType.JQKs] = 5,
    [CardType.SmallCow] = 5,
}
local CardsCmpResult = {
    Win = 1,
    Peace = 2,
    Lose = 3,
}

local function CreateRobcows()
    local Robcows = {}

    -- Robcows.CardColor = {
    --     Diamond= 0x00,
    --     Club   = 0x10,
    --     Heart  = 0x20,
    --     Spade  = 0x30,
    --     -- Joker  = 0x40,
    -- }
    Robcows.CardColor = CardColor

    Robcows.CardColors = {
        Robcows.CardColor.Diamond,
        Robcows.CardColor.Club,
        Robcows.CardColor.Heart,
        Robcows.CardColor.Spade,
    }

    Robcows.CardValues = {}
    for i = 1, 13 do
        table.insert(Robcows.CardValues, CardValues[i])
    end

    Robcows.ColorEmojiDict = ColorEmojiDict
    Robcows.EmojiColorDict = EmojiColorDict
    Robcows.CardType = CardType
    Robcows.CardTypeNameDict = CardTypeNameDict
    Robcows.CardTypeRateDict = CardTypeRateDict
    Robcows.CardsCmpResult = CardsCmpResult

    ---card data
    ---input "colorValue" or (color, value)
    ---@return {color, value}
    function Robcows:createCard(...)
        return poker.createCard(...)
    end

    function Robcows:createAllCards()
        local all_cards = {}

        for _, c in ipairs(Robcows.CardColors) do
            for _, v in ipairs(Robcows.CardValues) do
                table.insert(all_cards, self:createCard(c, v))
            end
        end

        return all_cards
    end

    function Robcows:cv(card)
        local color, value = card[1], card[2]
        return value * 100 + color
    end

    function Robcows:_cardVal(cardValue)
        return math.min(CardValues[10], cardValue)
    end

    function Robcows:getCardVal(card)
        return self:_cardVal(card[2])
    end

    --- is cardA bigger than cardB
    function Robcows.compareCard(cardA, cardB)
        local cvA = Robcows:cv(cardA)
        local cvB = Robcows:cv(cardB)
        return cvA > cvB
    end

    function Robcows.compareCards(cardsA, cardTypeA, cardsB, cardTypeB)
        if type(cardsA) == "table" and type(cardsB) == "table" then
            if CardTypeNameDict[cardTypeA] ~= nil and CardTypeNameDict[cardTypeB] ~= nil then
                local rateA = CardTypeRateDict[cardTypeA]
                local rateB = CardTypeRateDict[cardTypeB]

                if cardTypeA > cardTypeB then
                    return Robcows.CardsCmpResult.Win, rateA, rateB
                elseif cardTypeA < cardTypeB then
                    return Robcows.CardsCmpResult.Lose, rateA, rateB
                else
                    local ret = Robcows.compareCard(cardsA[1], cardsB[1])
                    if ret then
                        return Robcows.CardsCmpResult.Win, rateA, rateB
                    else
                        return Robcows.CardsCmpResult.Lose, rateA, rateB
                    end
                end
            end
        end
    end

    ------------------------------------------
    ---
    function Robcows:select3Cards(cards)
        if type(cards) == "table" and #cards == 5 then
            local candidates = {}
            local card1, card2, card3
            local value1, value2, value3
            local sum3 = 0

            -- 1
            for i = 1, 5 do
                card1 = cards[i]
                value1 = self:getCardVal(card1)
                -- 2
                for j = 2, 5 do
                    if i ~= j then
                        card2 = cards[j]
                        value2 = self:getCardVal(card2)
                        -- 3
                        for k = 3, 5 do
                            if j ~= k and i ~= k then
                                card3 = cards[k]
                                value3 = self:getCardVal(card3)
                                sum3 = value1 + value2 + value3

                                if sum3 > 0 and sum3 % 10 == 0 then
                                    local added = false
                                    local flag1 = false
                                    local flag2 = false
                                    local flag3 = false

                                    for index = 1, #candidates do
                                        for _i, _v in ipairs(candidates[index]) do
                                            if _v == card1 then
                                                flag1 = true
                                            elseif _v == card2 then
                                                flag2 = true
                                            elseif _v == card3 then
                                                flag3 = true
                                            end
                                        end

                                        if flag1 and flag2 and flag3 then
                                            added = true
                                            break
                                        end
                                    end

                                    if not added then
                                        table.insert(candidates, {card1, card2, card3})
                                    end
                                end
                            end
                        end
                    end
                end
            end

            return candidates
        end
    end

    function Robcows:makeCardType(cards, findAll)
        if findAll == nil then findAll = false end

        local _cardsWithType = {}

        local retSmallCow = self:checkSmallCow(cards)
        if retSmallCow then
            _cardsWithType[CardType.SmallCow] = { cards }

            if not findAll then
                return _cardsWithType
            end
        end

        local retJQK = self:checkJQKs(cards)
        if retJQK then
            _cardsWithType[CardType.JQKs] = { cards }

            if not findAll then
                return _cardsWithType
            end
        end

        local retBomb = self:checkBomb(cards)
        if retBomb then
            _cardsWithType[CardType.Bomb] = { cards }

            if not findAll then
                return _cardsWithType
            end
        end

        local candidates = self:select3Cards(cards)
        if candidates and #candidates > 0 then

            for _, _3Cards in ipairs(candidates) do
                local retCowX, level = self:checkCowX(cards, _3Cards)
                if retCowX then
                    _cardsWithType[level] = _cardsWithType[level] or {}

                    local _5Cards = {}
                    local mark = {}
                    for _, v in ipairs(_3Cards) do
                        mark[self:cv(v)] = true
                        table.insert(_5Cards, v)
                    end

                    local _2Cards = {}
                    for _, v in ipairs(cards) do
                        if not mark[self:cv(v)] then
                            table.insert(_2Cards, v)
                        end
                    end
                    table.sort(_2Cards, Robcows.compareCard)

                    for _,v in ipairs(_2Cards) do
                        table.insert(_5Cards, v)
                    end

                    table.insert(_cardsWithType[level], _5Cards)
                end
            end

            return _cardsWithType
        end

        if not retSmallCow and not retJQK and not retBomb then
            _cardsWithType[CardType.Cow0] = { cards }
        end

        return _cardsWithType
    end

    function Robcows:sortByCardType(cards, cardType)
        if type(cards) == "table" and #cards == 5 then
            local result = {}

            for _, card in ipairs(cards) do
                table.insert(result, card)
            end

            if cardType == CardType.Bomb then
                local cnt = poker.counter(result)
                local tmp = {}
                local lastCard

                for _, _cards in pairs(cnt.valueCardsDict) do
                    if #_cards == 4 then

                        for j, card in ipairs(_cards) do
                            table.insert(tmp, card)
                        end

                        table.sort(tmp, Robcows.compareCard)

                    elseif #_cards == 1 then
                        lastCard = _cards[1]
                    end
                end

                if lastCard ~= nil then
                    table.insert(tmp, lastCard)
                    return tmp --
                end
            end

            table.sort(result, Robcows.compareCard)
            return result
        end

        return cards
    end

    function Robcows:printCardsWithType(cardsWithType)
        for k, list in pairs(cardsWithType or {}) do
            print(CardTypeNameDict[k], "#list = ", #list)
            for _, v in ipairs(list) do
                poker.printCards(v)
            end
            print()
        end
    end
    ------------------------------------------
    --- check card type
    function Robcows:checkCowX(cards, selectedCards)
        if type(cards) == "table" and #cards == 5 and type(selectedCards) == "table" and #selectedCards == 3 then
            local mark = {}
            local sum = 0

            for _, card in ipairs(selectedCards) do
                if card then
                    local card_cv = self:cv(card)
                    mark[card_cv] = true

                    local value = self:getCardVal(card)
                    sum = sum + value
                end
            end

            if math.floor(sum / 10) >= 1 and sum % 10 == 0 then
                local sumRest = 0

                for _, card in ipairs(cards) do
                    if card then
                        local card_cv = self:cv(card)
                        if not mark[card_cv] then
                            local value = self:getCardVal(card)
                            sumRest = sumRest + value
                        end
                    end
                end

                if sumRest > 0 then
                    if math.floor(sumRest / 10) >= 1  and sumRest % 10 == 0 then
                        return true, CardType.Cow10
                    else
                        local level = sumRest % 10
                        return true, level
                    end
                end
            else
                return false, CardType.Cow0
            end
        end
        return false, CardType.Cow0
    end

    function Robcows:checkBomb(cards)
        if type(cards) == "table" and #cards == 5 then
            local cnt = poker.counter(cards)
            if type(cnt.valueCardsDict) == "table" then
                for _, list in pairs(cnt.valueCardsDict) do
                    if #list == 4 then
                        return true
                    end
                end
            end
        end
        return false
    end

    function Robcows:checkJQKs(cards)
        if type(cards) == "table" and #cards == 5 then
            local ret = true

            for i = 1, #cards do
                if not poker.isJQK(cards[i]) then
                    ret = false
                    break
                end
            end

            return ret
        end

        return false
    end

    function Robcows:checkSmallCow(cards)
        if type(cards) == "table" and #cards == 5 then
            local ret = true
            local sum = 0

            -- sum card value
            for i = 1, #cards do
                local card = cards[i]
                local value = self:getCardVal(card)

                if value < 5 then
                    sum = sum + value
                else
                    ret = false
                    break
                end
            end

            if sum >= 10 then
                ret = false
            end

            return ret, sum
        end
        return false, 0
    end
    ------------------------------------------

    return Robcows
end

local Robcows = CreateRobcows()

local function test()
    local cards = Robcows:createAllCards()

    ------------------------------------------
    --
    -- test print cards
    -- poker.printCards(cards)
    --
    -- local cv1 = poker.createCard("♥Q")
    -- poker.printCards({cv1})
    ------------------------------------------
    --
    -- test compare
    -- local cardA = cards[44]
    -- local cardB = cards[31]
    -- local tCards = {cardB, cardA}
    -- local ret = Robcows.compareCard(cardA, cardB)
    -- poker.printCards(tCards)
    -- table.sort(tCards, Robcows.compareCard)
    -- poker.printCards(tCards)
    -- print(ret)
    ------------------------------------------
    --
    -- test sort
    -- table.sort(cards, Robcows.compareCard)
    -- poker.printCards(cards)
    --
    -- local cards_1 = poker.createCards("♣2", "♥2", "♦9", "♥2", "♠2")
    -- local cards_1_s = Robcows:sortByCardType(cards_1, CardType.Bomb)
    -- poker.printCards(cards_1)
    -- poker.printCards(cards_1_s)
    -- print()
    --
    -- local cards_2 = poker.createCards("♣2", "♥2", "♦9", "♥2", "♠2")
    -- local cards_2_s = Robcows:sortByCardType(cards_2)
    -- poker.printCards(cards_2)
    -- poker.printCards(cards_2_s)
    ------------------------------------------
    --
    -- test shuffle
    -- poker.shuffleCards(cards)
    -- poker.printCards(cards)
    ------------------------------------------
    --
    -- test all cards
    -- local cards_1 = poker.createAllCards()
    -- poker.printCards(cards_1)
    -- poker.shuffleCards(cards_1)
    -- poker.printCards(cards_1)
    ------------------------------------------
    --
    -- test check small cow
    -- local cards_1 = poker.createCards("♣3", "♥2", "♦A", "♥A", "♠2")
    -- poker.printCards(cards_1)
    -- local retSmallCow, sum = Robcows:checkSmallCow(cards_1)
    -- print("checkSmallCow() ", retSmallCow, sum)

    -- local cards_2 = poker.createCards("♣7", "♥2", "♦Q", "♠6", "♦K")
    -- poker.printCards(cards_2)
    -- local retSmallCow = Robcows:checkSmallCow(cards_2)
    -- print("2. checkSmallCow() ", retSmallCow, sum)

    -- local cards_3 = poker.createCards("♣5,♥A,♦A,♦2,♠A")
    -- poker.printCards(cards_3)
    -- local retSmallCow = Robcows:checkSmallCow(cards_3)
    -- print("3. checkSmallCow() ", retSmallCow, sum)
    ------------------------------------------
    --
    -- test check JQK
    -- local cards_1 = poker.createCards("♣3", "♥2", "♦A", "♥A", "♠2")
    -- poker.printCards(cards_1)
    -- local retJQK = Robcows:checkJQKs(cards_1)
    -- print("checkJQK cards_1", retJQK) -- false

    -- local cards_2 = poker.createCards("♣K", "♥K", "♦K", "♥Q", "♠J")
    -- poker.printCards(cards_2)
    -- local retJQK = Robcows:checkJQKs(cards_2)
    -- print("checkJQK cards_2", retJQK) -- true

    -- local cards_3 = poker.createCards("♥A", "♦A", "♥3", "♣A", "♠A")
    -- poker.printCards(cards_3)
    -- local retJQK = Robcows:checkJQKs(cards_3)
    -- print("checkJQK cards_3", retJQK) -- false
    ------------------------------------------
    --
    -- test check bomb
    -- local cards_1 = poker.createCards("♣3", "♥2", "♦A", "♥A", "♠2")
    -- poker.printCards(cards_1)
    -- local retBomb = Robcows:checkBomb(cards_1)
    -- print("checkBomb cards_1", retBomb) -- false

    -- local cards_2 = poker.createCards("♥K", "♦K", "♥Q", "♣K", "♠K")
    -- poker.printCards(cards_2)
    -- local retJQK = Robcows:checkJQKs(cards_2)
    -- print("checkJQK cards_2", retJQK) -- true

    -- local retBomb = Robcows:checkBomb(cards_2)
    -- print("checkBomb cards_2", retBomb) -- true

    -- local cards_3 = poker.createCards("♥A", "♦A", "♥3", "♣A", "♠A")
    -- poker.printCards(cards_3)
    -- local retBomb = Robcows:checkBomb(cards_3)
    -- print("checkBomb cards_3", retBomb) -- true
    ------------------------------------------
    --
    -- check cowX
    -- local cards_1 = poker.createCards("♣3", "♥J", "♦7", "♥A", "♠2")
    -- local cards_1_selected = poker.createCards("♣3", "♥J", "♦7")
    -- poker.printCards(cards_1)
    -- local retCow, level = Robcows:checkCowX(cards_1, cards_1_selected)
    -- print("checkCowX cards_1", retCow, level)

    -- local cards_2 = poker.createCards("♣Q", "♥J", "♦7", "♥A", "♠2")
    -- local cards_2_selected = poker.createCards("♣Q", "♥J", "♦7")
    -- poker.printCards(cards_2)
    -- local retCow, level = Robcows:checkCowX(cards_2, cards_2_selected)
    -- print("checkCowX cards_2", retCow, level)

    -- local cards_3 = poker.createCards("♣Q", "♥8", "♦7", "♥A", "♠2")
    -- local cards_3_selected = poker.createCards("♣Q", "♥8", "♠2")
    -- poker.printCards(cards_3)
    -- local retCow, level = Robcows:checkCowX(cards_3, cards_3_selected)
    -- print("checkCowX cards_3", retCow, level)

    -- local cards_4 = poker.createCards("♣Q", "♥8", "♦Q", "♥K", "♠2")
    -- local cards_4_selected = poker.createCards("♣Q", "♥8", "♠2")
    -- poker.printCards(cards_4)
    -- local retCow, level = Robcows:checkCowX(cards_4, cards_4_selected)
    -- print("checkCowX cards_4", retCow, level)
    ------------------------------------------
    --
    -- test select 3 cards
    -- local cards_1 = poker.createCards("♣3", "♥J", "♦7", "♥10", "♠2")
    -- poker.printCards(cards_1)
    -- local list = Robcows:select3Cards(cards_1)
    -- if list then
    --     for i,v in ipairs(list) do
    --         poker.printCards(v)
    --     end
    -- end
    -- print()
    -- local cards_2 = poker.createCards("♣5", "♥J", "♦7", "♥5", "♠2")
    -- poker.printCards(cards_2)
    -- local list = Robcows:select3Cards(cards_2)
    -- if list then
    --     for i,v in ipairs(list) do
    --         poker.printCards(v)
    --     end
    -- end
    ------------------------------------------
    --
    -- make card type
    -- local cards_1 = poker.createCards("♣3", "♥J", "♦7", "♥10", "♠2")
    -- local cardsWithType = Robcows:makeCardType(cards_1)
    -- Robcows:printCardsWithType(cardsWithType)

    -- local cards_1 = poker.createCards("♣3", "♥3", "♦7", "♥10", "♠2")
    -- local cardsWithType = Robcows:makeCardType(cards_1)
    -- Robcows:printCardsWithType(cardsWithType)

    -- local cards_1 = poker.createCards("♣4", "♥K", "♦7", "♥A", "♠J")
    -- local cardsWithType = Robcows:makeCardType(cards_1)
    -- Robcows:printCardsWithType(cardsWithType)

    -- local cards_1 = poker.createCards("♣4", "♥K", "♦6", "♥10", "♠J")
    -- local cardsWithType = Robcows:makeCardType(cards_1)
    -- Robcows:printCardsWithType(cardsWithType)

    -- local cards_1 = poker.createCards("♣Q", "♥K", "♦10", "♥10", "♠J")
    -- local cardsWithType = Robcows:makeCardType(cards_1)
    -- Robcows:printCardsWithType(cardsWithType)

    -- local cards_1 = poker.createCards("♣K", "♥K", "♦K", "♥10", "♠K")
    -- local cardsWithType = Robcows:makeCardType(cards_1)
    -- Robcows:printCardsWithType(cardsWithType)

    -- local cards_1 = poker.createCards("♣A", "♥A", "♦A", "♥4", "♠A")
    -- local cardsWithType = Robcows:makeCardType(cards_1, true)
    -- Robcows:printCardsWithType(cardsWithType)

    -- local cards_1 = poker.createCards("♣9", "♥4", "♦6", "♥10", "♠Q")
    -- local cardsWithType = Robcows:makeCardType(cards_1)
    -- Robcows:printCardsWithType(cardsWithType)
    ------------------------------------------

    print()
end
-- test()

local function test2()
    local StateMachine = require("statemachine")
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

    local gameState = require("gamestate")
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
                player.cardType = CardType.Cow0
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
    sm:transfer("s_turn_start")

    -- simple engine
    local t1 = os.clock()
    local dt = 1
    local delta = 0.1

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
-- test2()

return Robcows

--[[
0  ♦A, ♦2, ♦3, ♦4, ♦5, ♦6, ♦7, ♦8, ♦9, ♦10, ♦J, ♦Q, ♦K,
13 ♣A, ♣2, ♣3, ♣4, ♣5, ♣6, ♣7, ♣8, ♣9, ♣10, ♣J, ♣Q, ♣K,
26 ♥A, ♥2, ♥3, ♥4, ♥5, ♥6, ♥7, ♥8, ♥9, ♥10, ♥J, ♥Q, ♥K,
39 ♠A, ♠2, ♠3, ♠4, ♠5, ♠6, ♠7, ♠8, ♠9, ♠10, ♠J, ♠Q, ♠K
 ]]
