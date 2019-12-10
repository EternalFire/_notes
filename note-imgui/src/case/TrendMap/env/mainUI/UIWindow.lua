local UIWindow = class("UIWindow")
UIWindow.layer = 1      --1：最下层 2:二级界面,游戏  3:弹窗  4：提示  5:充值提示，horn  10：测试
UIWindow.releaseTexture = false

function UIWindow:ctor(uiName, resName, layerNode)
    --UI名字
    self.uiName = uiName
    self.bInit = false
    self.initFun = {}
    --窗口
    self.rootWidget = cc.CSLoader:createWidget(resName)
    -- self.rootWidget = cc.CSLoader:createNodeWithFlatBuffersFile(resName)
    self.rootWidget:retain()
    self.rootWidget:setVisible(false)
    _getAllChildNode(self.rootWidget)
    --层节点
    self.layerNode = layerNode
    self.layerNode:addChild(self.rootWidget)

    if self.onCreate ~= nil then
        self:onCreate();
    end
end

-- 退后台前台的处理
function UIWindow:bindBackground()
    -- local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    -- self.backgroundListener = cc.EventListenerCustom:create("APP_ENTER_BACKGROUND_EVENT",_CallSelfFun(self, self.onEnterBackground))
    -- eventDispatcher:addEventListenerWithFixedPriority(self.backgroundListener, 1)
    -- self.foregriundListener = cc.EventListenerCustom:create("APP_ENTER_FOREGROUND_EVENT",_CallSelfFun(self, self.onEnterForeground))
    -- eventDispatcher:addEventListenerWithFixedPriority(self.foregriundListener, 1)
end
function UIWindow:onEnterBackground()
    self:stopInit()
    if self.onBackground then
        self.onBackground(self)
    end
end
function UIWindow:onEnterForeground()
    if self.onForeground then
        self.onForeground(self)
    end
end

function UIWindow:destroy()
    if self.onDestroy ~= nil then
        self:onDestroy()
    end
    self:setInit(false)
    self.rootWidget:removeFromParent()
    self.rootWidget:release()
    self.rootWidget = nil
    if self.backgroundListener then
        local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
        eventDispatcher:removeEventListener(self.backgroundListener)
        eventDispatcher:removeEventListener(self.foregriundListener)
    end
    if self.onDestoryEnd ~= nil then
        self:onDestoryEnd()
    end
    if self.releaseTexture then
        cc.Director:getInstance():requestReleaseTexture();
    end
end

function UIWindow:show()
    self.rootWidget:setVisible(true)
    -- self.layerNode:moveTop(self.rootWidget)

    if self.onShow ~= nil then
        self:onShow();
    end

	if self.initData ~= nil then
		self:initData();
	end
end

function UIWindow:createShowAction(rootwidget)
    rootwidget:stopAllActions();
	rootwidget:setScale(0);
	rootwidget:setOpacity(0);
	local action = cc.Sequence:create(cc.Spawn:create(cc.ScaleTo:create(0.2,1.1),cc.FadeIn:create(0.2)),cc.ScaleTo:create(0.1,1));
	rootwidget:runAction(action);
end

function UIWindow:createCloseAction(rootwidget, uiPath)
	function callFunc()
        _EventMgr:processEvent(_EventType.DestroyUI, uiPath);
	end
    rootwidget:stopAllActions();
	local action = cc.Sequence:create(cc.Spawn:create(cc.ScaleTo:create(0.1,0),cc.FadeOut:create(0.1)),cc.CallFunc:create(callFunc));
	rootwidget:runAction(action);
end

function UIWindow:createInputBox()
    if self.inputBoxUI == nil then
        self.inputBoxUI = cc.CSLoader:createWidget("UI/M_Input.csb");
        self.inputBoxTxt = ccui.Helper:seekWidgetByName(self.inputBoxUI, "InputTxt");
        self.rootWidget:addChild(self.inputBoxUI, 1);
    end
end

function UIWindow:removeInputBox()
    if self.inputBoxUI == nil then
        self.inputBoxUI:removeFromParent();
        self.inputBoxUI = nil
    end
end

function UIWindow:syncInputBox(widget)
    if widget ~= nil and self.inputBoxTxt ~= nil then
        self.inputBoxTxt:setString(widget:getString());
    end
end

function UIWindow:hide()
    self.rootWidget:setVisible(false)

    if self.onHide ~= nil then
        self:onHide()
    end
end

function UIWindow:isShow()
    return self.rootWidget:isVisible() == true;
end
-- 每一帧load
function UIWindow:frameLoading(...)
    local AllFun = {...}
    local count = 1
    self.frameHandle = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
        if count > #AllFun then -- 当load完结时删除定时器
            -- print("~~~~~load完结~~~~~~~~~")
            self:stopInit()
            self:setInit(true)
            return
        end
        -- 为初始化调用初始化
        if not self.initFun[count] then
            -- print("~~~~~~~~初始化第"..count.."帧~~~~~~~~~~~~~~", #AllFun, AllFun[count])
            AllFun[count](false)
            self.initFun[count] = AllFun[count]
        else
            -- print("~~~~~~~~第"..count.."帧以初始化~~~~~~~~~~~~~~", #AllFun, AllFun[count])
            self.initFun[count](true)
        end
        count = count + 1
    end, 0, false)
end
function UIWindow:stopInit()
    if self.frameHandle then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.frameHandle)
    end
end
function UIWindow:isInit()
    return self.bInit
end
function UIWindow:setInit(bInit)
    self.bInit = bInit
end
return UIWindow;