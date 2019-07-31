
local gameState = {
    players = {},
    robots = {},
    hero = nil,  -- 玩家
    robotNum = 4,

    -- 默认桌子
    seatState = {},
    banker = nil,
    allCards = nil,
    usedCard = nil,
    betGold = 0,

    -- tableState = { seatState = {} }
}

--- 下注金额
local BetGold = {
    Lv1 = 1,
}
local BetGolds = {}
for _, v in pairs(BetGold) do
    table.insert(BetGolds, v)
end

--- 抢庄倍率
local BankerRate = {
    Lv0 = 0,
    Lv1 = 1,
    Lv2 = 2,
    -- Lv3 = 3,
    Lv4 = 4,
}
local BankerRates = {}
for _, v in pairs(BankerRate) do
    table.insert(BankerRates, v)
end
table.sort(BankerRates)

--- 加倍倍率
local AddRate = {
    Lv1 = 5,
    Lv2 = 10,
    Lv3 = 15,
    Lv4 = 20,
    Lv5 = 25,
}

local AddRates = {}
for _, v in pairs(AddRate) do
    table.insert(AddRates, v)
end
table.sort(AddRates)

--- 座位
local Seat = {
    Stand = 0,
    A = 1,
    B = 2,
    C = 3,
    D = 4,
    E = 5,
}

gameState.BetGold = BetGold
gameState.BetGolds = BetGolds
gameState.BankerRate = BankerRate
gameState.BankerRates = BankerRates
gameState.AddRate = AddRate
gameState.AddRates = AddRates
gameState.Seat = Seat

gameState.seatState[Seat.Stand] = {}
gameState.seatState[Seat.A] = {}
gameState.seatState[Seat.B] = {}
gameState.seatState[Seat.C] = {}
gameState.seatState[Seat.D] = {}
gameState.seatState[Seat.E] = {}

function gameState:createPlayer(param)
    local player = {}

    player.id = 0
    player.isRobot = param["isRobot"]
    player.isUser = param["isUser"]
    player.rateBanker = BankerRate.Lv1
    player.rateAdd = AddRate.Lv1
    player.cards = {}
    player.cardType = 0
    player.typeCards = {}
    player.sortedCards = {}
    player.seatIndex = Seat.Stand
    player.gold = 0
    player.wonGold = 0
    player.headUrl = ""
    player.name = ""
    player._tag = ""

    if player.isUser then
        table.insert(self.players, player)
        player.id = #self.players
        player._tag = "user_"..player.id

    elseif player.isRobot then
        table.insert(self.players, player)
        player.id = #self.players
        player._tag = "robot_"..player.id

        table.insert(self.robots, player)
    end

    player.sit = function(self, place)
        self.seatIndex = place
    end

    player.leaveSeat = function(self)
        self.seatIndex = Seat.Stand
    end

    return player
end

function gameState:init()
    -- create players
    print("create players")
    local player = self:createPlayer({ isRobot = false, isUser = true })
    self.hero = player

    for i = 1, self.robotNum do
        local robot = self:createPlayer({ isRobot = true, isUser = false })
    end

    -- init gold
    print("initialize player's gold")
    for i, player in ipairs(self.players) do
        player.gold = 1000
    end

    -- players, have a seat
    print("have a seat...")
    local index = 1
    for place = Seat.A, Seat.E do
        if place == Seat.C then
            self:haveASeat(self.hero, Seat.C)
        else
            local robot = self.robots[index]
            if robot then
                self:haveASeat(robot, place)
                index = index + 1
            end
        end
    end

    self.betGold = BetGold.Lv1
end

function gameState:haveASeat(player, place, tableState)
    if player then
        if player.seatIndex == Seat.Stand then
            player.seatIndex = place

            if not tableState then
                if self.seatState[place] then
                    table.insert(self.seatState[place], player)
                    return true
                end
            else
                --
            end
        end
    end
    return false
end

function gameState:getAway(player, tableState)
    if player then
        if not tableState then
            local list = self.seatState[player.seatIndex]
            if list then
                for i = 1, #list do
                    if list[i] == player then
                        table.remove(list, i)
                        return true
                    end
                end
            end
        else
            --
        end
    end
    return false
end

function gameState:chooseBankerRateRandomly(player)
    if player then
        local list = self.BankerRates
        local index = math.random(2, #list)
        player.rateBanker = list[index]
        return player.rateBanker
    end
end

function gameState:findBanker(tableState)
    if not tableState then
        local bankerRateList = {}
        local bankerRateOrder = {}

        for place, list in pairs(self.seatState) do
            if place ~= Seat.Stand then
                for i = 1, #list do
                    local player = list[i]
                    bankerRateList[player.rateBanker] = bankerRateList[player.rateBanker] or {}
                    table.insert(bankerRateList[player.rateBanker], player)
                    table.insert(bankerRateOrder, player.rateBanker)
                end
            end
        end

        table.sort(bankerRateOrder, function(a, b) return a > b end)

        local r = bankerRateOrder[1]
        if #bankerRateList[r] > 1 then
            local index = math.random(1, #bankerRateList[r])
            self.banker = bankerRateList[r][index]
        else
            self.banker = bankerRateList[r][1]
        end

        return self.banker
    else
        --
    end
end

function gameState:iterateSeat(callback, tableState)
    if not tableState then
        for place, list in pairs(self.seatState) do
            if place ~= Seat.Stand then
                for i = 1, #list do
                    local player = list[i]
                    if callback then
                        callback(player)
                    end
                end
            end
        end
    end
end

function gameState:addRate(player, rate)
    if player then
        if rate == nil then
            rate = AddRate.Lv1
        end

        player.rateAdd = rate
        return rate
    end
end

function gameState:addRateRandomly(player)
    if player then
        local list = self.AddRates
        local index = math.random(1, #list)
        player.rateAdd = list[index]
        return player.rateAdd
    end
end

function gameState:deal(player)
    if player then
        if self.allCards then
            self.usedCard = self.usedCard or {}

            local list = {}
            while #list ~= 5 do
                local i = math.random(1, #self.allCards)
                if not self.usedCard[i] then
                    self.usedCard[i] = true
                    table.insert(list, self.allCards[i])
                end
            end

            player.cards = list
            return list
        end
    end
end

return gameState