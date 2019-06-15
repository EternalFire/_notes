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
    rt = nil,

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
                return
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
                return
            end

            imgui.pushButtonRepeat(true);
            imgui.beginGroup()
                imgui.dummy(50, 20); imgui.sameLine(); if imgui.button("Up") then
                    -- print ("click [button up panel]")
                    if State.processUp then State.processUp() end
                end
            imgui.endGroup()

            if imgui.button("Left") then
                -- print ("click [button left panel]")
                if State.processLeft then State.processLeft() end
            end

            imgui.sameLine()
            if imgui.button("Down") then
                -- print ("click [button down panel]")
                if State.processDown then State.processDown() end
            end

            imgui.sameLine()
            if imgui.button("Right") then
                -- print ("click [button right panel]")
                if State.processRight then State.processRight() end
            end
            imgui.popButtonRepeat();

            imgui.endToLua()
		end
    end

    local function capturePanel()
        imgui.begin("Capture What?")

            if imgui.button("Scene") then
                setTimeout(function() captureNode(State.rt, State.scene, "scene-"..tostring(os.time()), false) end, 0.02)
            end

            if imgui.button("Particle") then
                setTimeout(function() captureNode(State.rt, State.emitter:getParent(), "particleBatch-"..tostring(os.time()), true) end, 0.02)
            end

        imgui.endToLua()
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

        imgui.endToLua() -- end of imgui.begin

        imgui.setNextWindowPosCenter()
        showControlPanel()

        -- imgui.setNextWindowPos(100, 20)
        capturePanel()
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

    local renderTexture = cc.RenderTexture:create(display.width, display.height, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
    renderTexture:setPosition(cc.p(0, -100000))
    State.layer:addChild(renderTexture)
    State.rt = renderTexture
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

    -- setTimeout(function()
    --     if State.rt then
    --         State.rt:begin()

    --             -- capture layer
    --             -- State.layer:visit()

    --             -- capture scene
    --             State.scene:visit()

    --             -- capture particle
    --             -- State.emitter:getParent():visit()

    --         State.rt:endToLua()

    --         -- save image
    --         -- local png = string.format("image-%d.png", os.time())
    --         local jpg = string.format("image-%d.jpg", os.time())

    --         -- State.rt:saveToFile(png, cc.IMAGE_FORMAT_PNG)
    --         State.rt:saveToFile(jpg, cc.IMAGE_FORMAT_JPEG)

    --         setTimeout(function() State.rt:clear(0,0,0,0) end, 0.02)
    --     end
    -- end, 5)

    -- setTimeout(function() captureNode(State.rt, State.scene, "scene-"..tostring(os.time()), false) end, 2)

    -- setTimeout(function() captureNode(State.rt, State.emitter:getParent(), "particleBatch-"..tostring(os.time()), true) end, 4)

    -- captureNode(State.rt, State.scene, "scene-"..tostring(os.time()), false)
    -- captureNode(State.rt, State.emitter:getParent(), "particleBatch-"..tostring(os.time()), true)
end

function captureNode(renderTexture, node, fileBasename, isRGBA)
    if renderTexture ~= nil and node ~= nil and fileBasename ~= nil and isRGBA ~= nil then
        renderTexture:begin()
        do
            node:visit()
        end
        renderTexture:endToLua()

        local fileName = fileBasename..(isRGBA and ".png" or ".jpg")
        renderTexture:saveToFile(fileName, (isRGBA and cc.IMAGE_FORMAT_PNG or cc.IMAGE_FORMAT_JPEG), isRGBA)
        setTimeout(function() renderTexture:clear(0,0,0,0) end, 0.1)
    end
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

function setInterval(callback, sec)
    local id
    local function _runSchedule()
        if callback then
            callback()
        end
    end

    sec = sec or 0
    id = cc.Director:getInstance():getScheduler():scheduleScriptFunc(_runSchedule, sec, false);
end


local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end