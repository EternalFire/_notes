
local function initTrendMap()

    _game_require = function (name)
        return require("case.TrendMap." .. name)
    end

    _main_require = function (name)
        return require("case.TrendMap.env." .. name)
    end

    function _CallSelfFun(self, selfFun)
        local callSelfFun = function(...)
            selfFun(self, ...);
        end
        return callSelfFun;
    end

    function _getAllChildNode(rootNode)
        local function saveNode(name,node)
            if rootNode[name] or
                name == "" then return end
            rootNode[name] = node
        end
        local function seach_child(parente)
            local childCount = parente:getChildrenCount()
            if childCount < 1 then
                saveNode(parente:getName(), parente)
            else
                for i = 1, childCount do
                    saveNode(parente:getName(), parente)
                    seach_child(parente:getChildren()[i])
                end
            end
        end
        -- logic
        if not rootNode or rootNode:getChildrenCount() == 0 then return end
        for i=1, rootNode:getChildrenCount() do
            local root = rootNode:getChildren()[i]
            seach_child(root)
        end
    end

    function showUI(name)
        local layer = State.bgLayer

        local windowClass = _game_require(name)
        local window = windowClass.new(name, windowClass.resName, layer)
        window:show()

        local w = window.rootWidget:getContentSize().width
        local layer_w = layer:getContentSize().width
        window.rootWidget:setPositionX((layer_w - w) / 2)
    end

    cc.CSLoader.createWidget = function(self, res)
        local widget
        local node = cc.CSLoader:getInstance():createNodeWithFlatBuffersFile(res)
        -- local size = display.size
        -- node:setContentSize(size)
        -- ccui.Helper:doLayout(node)

        if node:getChildrenCount() > 0 then
            widget = tolua.cast(node:getChildren()[1], "ccui.Widget")
            widget:removeFromParent(false)
        end

        return widget
    end

    cc.FileUtils:getInstance():addSearchPath("res/case/TrendMap")

    DragonTigerCFG = DragonTigerCFG or {}

    DragonTigerCFG.WinType = {
        D = 1, P = 2, T = 3
    }

    _GamePlayer = {
        _historyInfo = {
            history_infos = {}
        },
        getHistoryInfo = function(self)
            return self._historyInfo
        end,
        getHistoryTrend = function(self)
            return self._historyInfo
        end,
    }

    local _trendLogic = _game_require("logic.Trend")
    _trendLogic:init()
end

local function play()
    initTrendMap()
    showUI("ui.trend.UITrendPanel")
end

local TrendEnv = {
    play = play,
}

return TrendEnv
