--
-- 走势图
--

local WinType = DragonTigerCFG.WinType
local _trendLogic = _game_require("logic.Trend")

local TrendAreaA = _game_require("ui.trend.TrendAreaA")
local TrendAreaB = _game_require("ui.trend.TrendAreaB")
local TrendAreaC = _game_require("ui.trend.TrendAreaC")
local TrendAreaD = _game_require("ui.trend.TrendAreaD")
local TrendAreaE = _game_require("ui.trend.TrendAreaE")
local TrendAreaF = _game_require("ui.trend.TrendAreaF")

local UIWindowClass = _main_require("mainUI.UIWindow")
local UITrendPanel = class("UITrendPanel", UIWindowClass)

UITrendPanel.resName = "UI/TrendPanel.csb"
UITrendPanel.layer = 4

function UITrendPanel:onCreate()

    self.rootWidget.btn_return:addClickEventListener(_CallSelfFun(self, self.onClickClose))

    self.frame = self.rootWidget.frame
    self.ListView_B = self.rootWidget.ListView_B
    self.ListView_C = self.rootWidget.ListView_C
    self.ListView_D = self.rootWidget.ListView_D
    self.ListView_E = self.rootWidget.ListView_E
    self.ListView_F = self.rootWidget.ListView_F

    self.ListView_B:setScrollBarEnabled(false)
    self.ListView_C:setScrollBarEnabled(false)
    self.ListView_D:setScrollBarEnabled(false)
    self.ListView_E:setScrollBarEnabled(false)
    self.ListView_F:setScrollBarEnabled(false)

    self._areaA = TrendAreaA.new(self.rootWidget)
    self._areaB = TrendAreaB.new(self.ListView_B)
    self._areaC = TrendAreaC.new(self.ListView_C)
    self._areaD = TrendAreaD.new(self.ListView_D)
    self._areaE = TrendAreaE.new(self.ListView_E)
    self._areaF = TrendAreaF.new(self.ListView_F)

    -- 预测区纹理
    self.areaGTextureD = {}
    self.areaGTextureE = {}
    self.areaGTextureF = {}
    self.areaGTextureD["true"] = "UI/UItrend/icon_B.png"
    self.areaGTextureD["false"] = "UI/UItrend/icon_R.png"
    self.areaGTextureE["true"] = "UI/UItrend/icon_Fill_B.png"
    self.areaGTextureE["false"] = "UI/UItrend/icon_Fill_R.png"
    self.areaGTextureF["true"] = "UI/UItrend/B.png"
    self.areaGTextureF["false"] = "UI/UItrend/R.png"

    self:hideAreaGIcons()
    self:updateAreaH()
    self:initAreaA()

    -- self.onUpdateMinHistoryHandler = _CallSelfFun(self, self.onUpdateMinHistory);
    -- _EventMgr:registerEventHandler(_GameEventType.UpdateMinHistory,self.onUpdateMinHistoryHandler); --

    -- self.onUpdateTrendHistoryHandler = _CallSelfFun(self, self.onUpdateTrendHistory);
    -- _EventMgr:registerEventHandler(_GameEventType.UpdateTrendHistory, self.onUpdateTrendHistoryHandler);

    ----------------
    -- _GamePlayer:askHistoryTrend(); --
    -- self:initTrendView()
    ----------------

    --
    self:test()
    --
end

function UITrendPanel:initAreaA()
    _trendLogic.areaA:init()
    self:updateAreaA()

    if _GamePlayer then
        local infos = _GamePlayer:getHistoryInfo().history_infos;
        if infos then
            local len = #infos
            print("infos len = ", len)
            local min = 1
            local max = math.min(len, 20)

            for i = max, min, -1 do
                local info = infos[i]
                if info then
                    local newResult = info.win_type
                    _trendLogic.areaA:fill(newResult)
                end
            end

            self:updateAreaA()
        end
    end
end

function UITrendPanel:initTrendView()
    if not _GamePlayer then
        return
    end

    local historyInfos = _GamePlayer:getHistoryTrend().history_infos;

    if not historyInfos or #historyInfos == 0 then

        -- 使用 _GamePlayer:getHistoryInfo(), 只更新 areaA
        -- self:initAreaA() -- onCreate()内已经调用了

        return
    elseif (#historyInfos > 0 and #historyInfos < 20) then
        -- 走势数据不足20条的情况
        -- 使用 _GamePlayer:getHistoryInfo() 更新 所有区域

        local historyInfosLen = #historyInfos

        -- 最新的结果在首个元素
        local infos = _GamePlayer:getHistoryInfo().history_infos;
        if infos then
            _trendLogic.areaA:init()

            local len = #infos
            local min = 1
            local max = math.min(len, 20)

            for i = max, min, -1 do
                local info = infos[i]
                if info then
                    local newResult = info.win_type
                    if i <= historyInfosLen then
                        _trendLogic:fill(newResult)

                        self:updateAreaB(newResult)
                        self:updateAreaC()
                        self:updateAreaD()
                        self:updateAreaE()
                        self:updateAreaF()
                    else
                        _trendLogic.areaA:fill(newResult)
                    end
                end
            end

            self:updateAreaA()
            self:updateAreaG(WinType.D)
            self:updateAreaG(WinType.T)
            self:updateAreaH()
        end

        return
    end

    _trendLogic.areaA:init()
    self:updateAreaA()

    local len = #historyInfos
    local max = len
    local min = 1

    local i = min
    local timer;
    local function tick()
        local historyInfo = historyInfos[i]
        if historyInfo then
            local newResult = historyInfo.win_type
            -- logToFile("initTrendView() i = "..i.." result = "..newResult)

            _trendLogic:fill(newResult)

            self:updateAreaB(newResult)
            self:updateAreaC()
            self:updateAreaD()
            self:updateAreaE()
            self:updateAreaF()
        end

        if i >= max then
            self:updateAreaA()
            self:updateAreaG(WinType.D)
            self:updateAreaG(WinType.T)
            self:updateAreaH()

            return false
        end

        i = i + 1
        return true
    end

    local function run()
        for j = 1, 20 do
            local ret = tick()
            if not ret then
                _TimerClose(timer)
                return
            end
        end
    end
    --                                                                      second
    timer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(run, 1/30, false);
end

function UITrendPanel:onClickClose()
    self._areaC:clear()

	-- _PlayMainSound(1);
    --_M_ClosePanel(self.frame);

    -- _EventMgr:processEvent(_EventType.DestroyUI, "ui.trend.UITrendPanel")
    self:destroy()
end

function UITrendPanel:onUpdateTrendHistory()
    self:initTrendView();
end

function UITrendPanel:onShow()
	--_M_ShowPanel(self.frame)
end

function UITrendPanel:onDestroy()
    _trendLogic:clear()

    -- _EventMgr:unRegisterEventHandler(_GameEventType.UpdateMinHistory, self.onUpdateMinHistoryHandler)
    -- _EventMgr:unRegisterEventHandler(_GameEventType.UpdateTrendHistory, self.onUpdateTrendHistoryHandler)
end

function UITrendPanel:onUpdateMinHistory()
    -------------------------
    -- test
    -- if true then return end;
    -------------------------

    -- logToFile("UITrendPanel:onUpdateMinHistory()")

    local historyInfos = _GamePlayer:getHistoryInfo().history_infos;
    local newResult
    if historyInfos[1] ~= nil then
        newResult = historyInfos[1].win_type
        if newResult == WinType.D or newResult == WinType.P or newResult == WinType.T then
            -- logToFile(newResult, "New_Result")
            self:updateView(newResult)
        end
    end
end

function UITrendPanel:updateView(newResult)
    if _trendLogic.areaH:total() >= 100 then
        self:resetView()
    end

    _trendLogic:fill(newResult)

    self:updateAreaA()
    self:updateAreaB(newResult)
    self:updateAreaC()
    self:updateAreaD()
    self:updateAreaE()
    self:updateAreaF()

    self:updateAreaG(WinType.D)
    self:updateAreaG(WinType.T)
    self:updateAreaH()
end

function UITrendPanel:updateAreaA()
    self._areaA:updateView(_trendLogic.areaA)
end

function UITrendPanel:updateAreaB(winType)
    local areaB = _trendLogic.areaB
    local col, row = areaB:getColRow()
    self._areaB:updateIcon(col, row, winType)
end

function UITrendPanel:updateAreaC()
    local areaC = _trendLogic.areaC
    local col = areaC.lastCItemCol
    local row = areaC.lastCItemRow
    local lastItem = areaC:getItem(col, row)
    if lastItem then
        self._areaC:updateItem(col, row, lastItem.gameResult, lastItem.num)
    end
end

function UITrendPanel:updateAreaD()
    local areaD = _trendLogic.areaD
    local col = #areaD.dItemList
    local row = 1
    local lastItem = areaD.dItemList[col]
    local valueList, value

    if lastItem then
        if areaD.isLastModifyLeft then
            valueList = lastItem.leftList
        else
            valueList = lastItem.rightList
        end

        if valueList ~= nil then
            row = #valueList
            value = valueList[#valueList]
            self._areaD:updateItem(col, row, value)
        end
    end
end
function UITrendPanel:updateAreaE()
    local areaE = _trendLogic.areaE
    local col = #areaE.dItemList
    local row = 1
    local lastItem = areaE.dItemList[col]
    local valueList, value

    if lastItem then
        if areaE.isLastModifyLeft then
            valueList = lastItem.leftList
        else
            valueList = lastItem.rightList
        end

        if valueList ~= nil then
            row = #valueList
            value = valueList[#valueList]
            -- value = not value
            self._areaE:updateItem(col, row, value)
        end
    end
end
function UITrendPanel:updateAreaF()
    local areaF = _trendLogic.areaF
    local col = #areaF.dItemList
    local row = 1
    local lastItem = areaF.dItemList[col]
    local valueList, value

    if lastItem then
        if areaF.isLastModifyLeft then
            valueList = lastItem.leftList
        else
            valueList = lastItem.rightList
        end

        if valueList ~= nil then
            row = #valueList
            value = valueList[#valueList]
            -------------------
            -- value = not value
            -------------------
            self._areaF:updateItem(col, row, value)
        end
    end
end

-- 刷新预测区
function UITrendPanel:updateAreaG(prediction)
    local areaG = _trendLogic.areaG
    local predictionD, predictionE, predictionF = areaG:predict(prediction)
    local iconD, iconE, iconF

    if prediction == WinType.D then
        iconD = self.rootWidget.img_next_0_0
        iconE = self.rootWidget.img_next_0_1
        iconF = self.rootWidget.img_next_0_2
    elseif prediction == WinType.T then
        iconD = self.rootWidget.img_next_1_0
        iconE = self.rootWidget.img_next_1_1
        iconF = self.rootWidget.img_next_1_2
    end

    if iconD then
        if (predictionD ~= nil) then
            iconD:setVisible(true)
            iconD:loadTexture(self.areaGTextureD[tostring(predictionD)], 1)
        else
            iconD:setVisible(false)
        end
    end

    if iconE then
        if (predictionE ~= nil) then
            iconE:setVisible(true)
            -- iconE:loadTexture(self.areaGTextureE[tostring(not predictionE)], 1)
            iconE:loadTexture(self.areaGTextureE[tostring(predictionE)], 1)
        else
            iconE:setVisible(false)
        end
    end

    if iconF then
        if (predictionF ~= nil) then
            iconF:setVisible(true)
            -- iconF:loadTexture(self.areaGTextureF[tostring(not predictionF)], 1)
            iconF:loadTexture(self.areaGTextureF[tostring(predictionF)], 1)
        else
            iconF:setVisible(false)
        end
    end
end

function UITrendPanel:hideAreaGIcons()
    self.rootWidget.img_next_0_0:setVisible(false)
    self.rootWidget.img_next_0_1:setVisible(false)
    self.rootWidget.img_next_0_2:setVisible(false)

    self.rootWidget.img_next_1_0:setVisible(false)
    self.rootWidget.img_next_1_1:setVisible(false)
    self.rootWidget.img_next_1_2:setVisible(false)
end

-- 刷新统计区
function UITrendPanel:updateAreaH()
    local areaH = _trendLogic.areaH
    -- print("D: "..areaH.totalCountD, "T: "..areaH.totalCountT, "P: "..areaH.totalCountP, "Total: "..areaH:total())

    if self.rootWidget.lbl_tigger_num then
        self.rootWidget.lbl_tigger_num:setString("虎 "..areaH.totalCountT)
    end

    if self.rootWidget.lbl_dro_num then
        self.rootWidget.lbl_dro_num:setString("龙 "..areaH.totalCountD)
    end

    if self.rootWidget.lbl_he_num then
        self.rootWidget.lbl_he_num:setString("和 "..areaH.totalCountP)
    end

    if self.rootWidget.lbl_round_num then
        self.rootWidget.lbl_round_num:setString("局数 "..areaH:total())
    end
end

function UITrendPanel:resetView()
    _trendLogic:clear()
    -- self._areaA:clear()
    self._areaB:clear()
    self._areaC:clear()
    self._areaD.areaCom:clear()
    self._areaE.areaCom:clear()
    self._areaF.areaCom:clear()
    self:hideAreaGIcons()
    self:updateAreaH()
end


function UITrendPanel:test()
    ---------------------------------------------------------------------
    -- 点击输入结果
    self.rootWidget.lbl_dro_num:setTouchEnabled(true)
    self.rootWidget.lbl_tigger_num:setTouchEnabled(true)
    self.rootWidget.lbl_he_num:setTouchEnabled(true)
    self.rootWidget.lbl_round_num:setTouchEnabled(true)

    self.rootWidget.lbl_dro_num:addClickEventListener(function()
        self:updateView(1)
    end)
    self.rootWidget.lbl_tigger_num:addClickEventListener(function()
        self:updateView(3)
    end)
    self.rootWidget.lbl_he_num:addClickEventListener(function()
        self:updateView(2)
    end)
    self.rootWidget.lbl_round_num:addClickEventListener(function()
        self:resetView()
    end)
    ---------------------------------------------------------------------

    -- local list = {
    --     1,1,1,1,1,1,
    --     1,3,3,3,3,3,
    --       3,
    --       3,
    --         1,1,1,1,
    --         1,
    --         1,
    --         1,
    -- }

    -- local list = {
    --     1,3,3,3,3,3,
    --     3,3,3,3,3,3,
    --     3,1,1,1,1,1,
    --     1,1,1,1,1,2,
    --     1,2,2,3,3,3,
    --     1,1,1,3,3,3,
    --     3,3,1,1,1,1,
    --     3,
    -- }

    -- local list = {
    --     3, 1, 1, 1, 1, 1,
    --     3, 1, 2, 3, 3, 1,
    --     1, 1, 3, 3, 2, 3,
    --     2, 1, 3, 3, 3, 1,
    --     3, 1, 1, 1, 3, 3,
    --     1, 3, 1, 3, 2, 1,
    --     1, 1, 1, 1, 1, 1,
    --     1, 3, 3, 1, 3, 3,
    --     3, 1, 3, 1, 1, 1,
    --     3, 1, 3, 3, 2, 3,
    --     3, 2, 1, 3, 1, 1,
    --     1, 3, 1, 1,
    -- }

    -- local list = {
    --     1,3,3,3,1,1,
    --     1,3,1,1,1,3,
    --     2,1,1,1,1,1,
    --     1,1,3,1,3,3,
    --     1,1,1,1,3,1,
    --     1,
    -- }

    -- local list = {
    --     1,1,1,1,3,1,
    --     3,3,2,3,3,2
    -- }

    -- local list = {
    --     1, 1, 1, 1, 1, 1,
    --     1, 3, 3, 1, 3, 3,
    --     3, 1, 3, 1, 1, 1,
    --     3, 1, 3, 3, 2, 3,
    --     3, 2, 1, 3, 1, 1,
    --     1, 3, 1, 1,
    -- }

    -- for i, v in ipairs(list) do
    --     self:updateView(v)
    -- end
end


return UITrendPanel