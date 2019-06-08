-- cc.FileUtils:getInstance():addSearchPath("Resources")
-- cc.FileUtils:getInstance():addSearchPath("Resources/res")
-- cc.FileUtils:getInstance():addSearchPath("Resources/src")
cc.FileUtils:getInstance():setPopupNotify(false)

require "config"
require "cocos.init"

local State = {
    scene = nil,
    layer = nil,
    emitter = nil,

    processUp = nil,
    processDown = nil,
    processLeft = nil,
    processRight = nil,

    moveStep = 10,
}



--[[
    set environment:

    1. copy imgui/ into Classes/ . Use "cocos2dx 3.17.1"

    2. create glview with IMGUIGLViewImpl. Need to modify simulator

    	#include "imgui/CCIMGUIGLViewImpl.h"

    3. modify AppDelegate.cpp

    	#include "imgui/CCIMGUIGLViewImpl.h"
		#include "imgui/CCImGuiLayer.h"
		#include "imgui/CCIMGUI.h"
		#include "imgui/imgui_lua.hpp"

		bool AppDelegate::applicationDidFinishLaunching()
		{
			// ...

			// register api to lua
			luaopen_imgui(L);

			// add imgui layer
			Director::getInstance()->getScheduler()->schedule([=](float dt)
			{
				auto runningScene = Director::getInstance()->getRunningScene();
				if (runningScene && !runningScene->getChildByName("ImGUILayer"))
				{
					runningScene->addChild(ImGuiLayer::create(), INT_MAX, "ImGUILayer");
				}
			}, this, 0, false, "checkIMGUI");
		}
--]]
function case_imgui()
    print("case_imgui......")
    print (imgui.version)
    print (imgui.ImGuiWindowFlags_NoTitleBar)

    -- data
    local buf = "Quick brown fox"
    local float = 3
    -- local isToolbarOpened = true
    local isPanelOpened = 1
    local isControlPanelOpened = 1

    cc.SpriteFrameCache:getInstance():addSpriteFrames("res/AllSprites.plist")

    local function setupMainMenu()
        if imgui.beginMainMenuBar() then
            if imgui.beginMenu("Menu") then
            	if imgui.menuItem("Panel") then isPanelOpened = 1 end
                imgui.endMenu()
            end

            if imgui.beginMenu("Edit") then
                if imgui.menuItem("Undo") then print("undo") end
                if imgui.menuItem("Redo") then print("redo") end
                imgui.separator()
                if imgui.menuItem("Cut") then
                    print("cut")
                end
                imgui.endMenu()
            end

            imgui.endMainMenuBar()
        end
    end

	local function showPanel()
		if isPanelOpened then
			local ret
			ret, isPanelOpened = imgui.begin("Panel", isPanelOpened, {imgui.ImGuiWindowFlags_None})
			if not ret then
				print("collapse...", os.time())
				imgui.endToLua()
			end

			imgui.text("text in panel")
			imgui.text("another text in panel")

			if imgui.button("button in panel") then
				print ("click [button in panel]")
			end

			imgui.endToLua()
		end
    end

    local function showControlPanel()
		if isControlPanelOpened then
			local ret
			ret, isControlPanelOpened = imgui.begin("Control", isControlPanelOpened, {imgui.ImGuiWindowFlags_AlwaysAutoResize})
			if not ret then
				print("collapse...", os.time())
				imgui.endToLua()
			end

            imgui.beginGroup()
                imgui.dummy(50, 20); imgui.sameLine(); if imgui.button("Up") then
                    print ("click [button up panel]")
                    if State.processUp then State.processUp() end
                end
            imgui.endGroup()

            if imgui.button("Left") then
                print ("click [button left panel]")
                if State.processLeft then State.processLeft() end
            end

            imgui.sameLine()
            if imgui.button("Down") then
                print ("click [button down panel]")
                if State.processDown then State.processDown() end
            end

            imgui.sameLine()
            if imgui.button("Right") then
                print ("click [button right panel]")
                if State.processRight then State.processRight() end
			end


            imgui.beginGroup()
                counter = counter or 0
                counter = imgui.text(tostring(counter))

                -- imgui.pushButtonRepeat(true);

                if (imgui.arrowButton("##left", 0)) then counter = counter - 1 end

                imgui.sameLine(0, 20);
                if (imgui.arrowButton("##right", 1)) then counter = counter + 1 end
                -- imgui.popButtonRepeat();
            imgui.endGroup()

			imgui.endToLua()
		end
    end

    -- draw
    imgui.draw = function ()
        setupMainMenu()

        showPanel()

        -- without close button
        imgui.begin("Toolbar")
            if imgui.beginMenuBar() == true then
                if imgui.beginMenu("File") == true then
                    imgui.menuItem("Open")
                    imgui.menuItem("Save")
                    imgui.endMenu()
                end
                imgui.endMenuBar()
            end

            _, buf = imgui.inputText("[lua] input", buf, 256)
            _, float = imgui.sliderFloat("[lua] float", float, 0, 8)

            if imgui.imageButton("res/1.png") then print("image button click 1") end
            imgui.sameLine() if imgui.imageButton("res/1.png") then print("image button click 2") end
            imgui.sameLine() if imgui.imageButton("res/1.png") then print("image button click 3") end
            imgui.sameLine() if imgui.imageButton("res/1.png") then print("image button click 4") end
            imgui.sameLine() if imgui.imageButton("res/1.png") then print("image button click 5") end

            if imgui.imageButton("#CoinSpin01.png") then print("CoinSpin01 1") end
            imgui.sameLine() if imgui.imageButton("#CoinSpin01.png") then print("CoinSpin01 2") end
            imgui.sameLine() if imgui.imageButton("#AddCoinButton.png", 30, 30) then print("AddCoinButton") end

        imgui.endToLua()

        imgui.setNextWindowPosCenter()
        showControlPanel()

    end -- end of imgui.draw

    --
    -- when you move panel, imgui will save setting in local disk
    --
end

function run()
    local scene = display.getRunningScene()
    if not scene then
        print("scene is nil..")
    end

    local layer = display.newLayer():addTo(scene)

    local emitter = cc.ParticleSystemQuad:create("Particles/LavaFlow.plist")
    local batch = cc.ParticleBatchNode:createWithTexture(emitter:getTexture())
    batch:addChild(emitter)
    layer:addChild(batch)

    State.scene = scene
    State.layer = layer
    State.emitter = emitter
    State.processUp = function()
        local target = State.emitter
        target:setPositionY(target:getPositionY() + State.moveStep)
    end
    State.processDown = function()
        local target = State.emitter
        target:setPositionY(target:getPositionY() - State.moveStep)
    end
    State.processLeft = function()
        local target = State.emitter
        target:setPositionX(target:getPositionX() - State.moveStep)
    end
    State.processRight = function()
        local target = State.emitter
        target:setPositionX(target:getPositionX() + State.moveStep)
    end

end

local function main()
    -- require("mobdebug").start()
    -- require("app.MyApp"):create():run()

    if CC_SHOW_FPS then
        cc.Director:getInstance():setDisplayStats(true)
    end

    local scene = display.newScene("scene")
    display.runScene(scene--[[, transition, time, more--]])

    case_imgui()

    setTimeout(function() run() end, 0)
end


function setTimeout(callback, sec)
    local id
    local function _runSchedule()
        clearTimer(id)
        id = nil

        if callback then
            callback()
        end
    end

    sec = sec or 0
    id = cc.Director:getInstance():getScheduler():scheduleScriptFunc(_runSchedule, sec, false);
end

function clearTimer(id)
    if id then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(id)
    end
end


local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end