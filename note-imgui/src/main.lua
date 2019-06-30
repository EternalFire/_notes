-- cc.FileUtils:getInstance():addSearchPath("Resources")
-- cc.FileUtils:getInstance():addSearchPath("Resources/res")
-- cc.FileUtils:getInstance():addSearchPath("Resources/src")
cc.FileUtils:getInstance():setPopupNotify(false)

require "config"
require "cocos.init"
local fire_main = require "fire.init"


local function main()
    -- require("mobdebug").start()
    -- require("app.MyApp"):create():run()

    if CC_SHOW_FPS then
        cc.Director:getInstance():setDisplayStats(true)
    end

    print("fire_main", fire_main, type(fire_main))
    if fire_main and type(fire_main) == "function" then
        fire_main()
    end
end



local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end