
cc.FileUtils:getInstance():setPopupNotify(false)

require "config"
require "cocos.init"

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
    end

    --
    -- when you move panel, imgui will save setting in local disk
    --
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
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
