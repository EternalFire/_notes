
local poker = {}

local CardColor = {
    Diamond= 1,
    Club   = 2,
    Heart  = 3,
    Spade  = 4,
    Joker  = 5,
}

local CardColors = {
    CardColor.Diamond,
    CardColor.Club,
    CardColor.Heart,
    CardColor.Spade,
    CardColor.Joker,
}

local CardValues = {
    --[[
    A,2,3,4,5,6,7,8,9,10, J,Q,K, small joker, big joker
    ]]
    1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
}

local CardValue_A = CardValues[1]
local CardValue_J = CardValues[11]
local CardValue_Q = CardValues[12]
local CardValue_K = CardValues[13]
local CardValue_Small_Joker = CardValues[14]
local CardValue_Big_Joker = CardValues[15]

local CardValueStrDict = {
    [CardValue_A]  = "A",
    [CardValue_J] = "J",
    [CardValue_Q] = "Q",
    [CardValue_K] = "K",
    [CardValue_Small_Joker] = "S", -- small joker
    [CardValue_Big_Joker] = "B", -- big joker
}

local StrCardValueDict = {
    ["A"] = CardValue_A,
    ["J"] = CardValue_J,
    ["Q"] = CardValue_Q,
    ["K"] = CardValue_K,
    ["S"] = CardValue_Small_Joker, -- small joker
    ["B"] = CardValue_Big_Joker, -- big joker
}

local ColorEmojiDict = {
    [CardColor.Diamond] = "♦",
    [CardColor.Club]    = "♣",
    [CardColor.Heart]   = "♥",
    [CardColor.Spade]   = "♠",
    [CardColor.Joker]   = "🃏",
}

local EmojiColorDict = {
    ["♦"] = CardColor.Diamond,
    ["♣"] = CardColor.Club,
    ["♥"] = CardColor.Heart,
    ["♠"] = CardColor.Spade,
    ["🃏"] = CardColor.Joker,
}

local function cardValueToStr(value)
    if type(value) == "number" then
        local s = CardValueStrDict[value]
        if s == nil then
            s = tostring(value)
        end
        return s
    end

    return ""
end

local function strToCardValue(str)
    if type(str) == "string" then
        local v = StrCardValueDict[str]
        if v == nil then
            v = tonumber(str)
        end
        return v
    end
    return 0
end

---card data
---input "colorValue" or (color, value)
---@return {color, value}
local function createCard(...)
    local param = {...}
    local len = #param
    if len > 0 then
        local color, value
        if len == 1 and type(param[1]) == "string" then
            local s = param[1] -- "ColorValue"
            local list
            local sColor

            for colorEmoji, cValue in pairs(EmojiColorDict) do
                list = string.split(s, colorEmoji)
                if #list > 1 then
                    sColor = colorEmoji
                    color = cValue
                    value = strToCardValue(list[2])
                    break
                end
            end

            return {color, value}
        elseif len == 2 then
            color = param[1]
            value = param[2]

            return {color, value}
        end
    end
end

local function cardToStr(card)
    if type(card) == "table" then
        local color, value = card[1], card[2]
        local sColor = ColorEmojiDict[color]
        local sValue

        if sColor ~= nil then
            sValue = cardValueToStr(value)
            return sColor..sValue
        end
    else
        print("card is not table")
    end

    return ""
end

local function printCards(cards)
    if type(cards) == "table" then
        local sCards = {}

        for i, card in ipairs(cards) do
            table.insert(sCards, cardToStr(card))
        end

        print(table.concat(sCards, ", "))
    end
end

local function shuffleCards(cards)
    if type(cards) == "table" then
        local mark = {}
        local len = #cards
        math.randomseed(os.time() * math.random(1, 10 * len))

        for i = 1, len do
            local from = i
            local to = math.random(1, len)
            -- if not mark[from] or not mark[to] then
            if not mark[from] and not mark[to] then
                cards[from], cards[to] = cards[to], cards[from]
                mark[from] = true
                mark[to] = true
                -- print("shuffle from ", from, " to ", to)
            end
        end
    end
end

local function createAllCards()
    local all_cards = {}

    for i, c in ipairs(CardColors) do
        if i == CardColor.Joker then
            table.insert(all_cards, createCard(c, CardValue_Small_Joker))
            table.insert(all_cards, createCard(c, CardValue_Big_Joker))
        else
            for _, v in ipairs(CardValues) do
                if v ~= CardValue_Small_Joker and v ~= CardValue_Big_Joker then
                    table.insert(all_cards, createCard(c, v))
                end
            end
        end
    end

    return all_cards
end

local function createCards(...)
    local list = {...}
    local t = {}

    if #list > 0 then
        if type(list[1]) == "string" then
            local listSplitted = string.split(list[1], ",")
            if #listSplitted > 1 then
                list = listSplitted
            end
        end
    end

    for _, v in ipairs(list) do
        local card = createCard(v)
        if card ~= nil then
            table.insert(t, card)
        end
    end

    return t
end

local function counter(cards)
    local list = cards or {}
    local result = {
        colorCardsDict = {}, -- key: color, value: cards
        valueCardsDict = {}, -- key: card value, value: cards
    }

    for _, card in ipairs(list) do
        if card then
            local color, value = card[1], card[2]

            result.colorCardsDict[color] = result.colorCardsDict[color] or {}
            table.insert(result.colorCardsDict[color], card)

            result.valueCardsDict[value] = result.valueCardsDict[value] or {}
            table.insert(result.valueCardsDict[value], card)
        end
    end

    return result
end

local function isJQK(card)
    if card then
        local color, value = card[1], card[2]
        return value == CardValue_J or value == CardValue_Q or value == CardValue_K
    end
    return false
end


poker.CardColor = CardColor
poker.CardColors = CardColors
poker.CardValues = CardValues
poker.ColorEmojiDict = ColorEmojiDict
poker.EmojiColorDict = EmojiColorDict

poker.createCard = createCard
poker.cardToStr = cardToStr
poker.printCards = printCards
poker.shuffleCards = shuffleCards
poker.createAllCards = createAllCards
poker.createCards = createCards
poker.counter = counter

poker.isJQK = isJQK


return poker
