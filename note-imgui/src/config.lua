
-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
DEBUG = 2

-- use framework, will disable all deprecated API, false - use legacy API
CC_USE_FRAMEWORK = true

-- show FPS on screen
CC_SHOW_FPS = true

-- disable create unexpected global variable
CC_DISABLE_GLOBAL = false

-- for module display
CC_DESIGN_RESOLUTION = {

    -- 4:3, 1.3333333
    -- width = 1024,
    -- height = 768,

    -- 3:2, 1.5
    -- width = 960,
    -- height = 640,

    -- 1.66666
    -- width = 800,
    -- height = 480,

    -- 1.775, iphone 5
    -- width = 1136,
    -- height = 640,

    -- 16:9, 1.7777777
    width = 1280,
    height = 720,

    -- 1.7786666, iphone 6
    -- width = 1334,
    -- height = 750,

    -- 2.16425, iphone xs max, iphone xr
    -- width = 1792,
    -- height = 828,

    -- 2.165333, iphone x
    -- width = 2436,
    -- height = 1125,

    ---------------------------------------------
    -- autoscale = "FIXED_WIDTH",
    autoscale = "FIXED_HEIGHT",
    -- autoscale = "EXACT_FIT",
    -- autoscale = "NO_BORDER",
    -- autoscale = "SHOW_ALL",
    ---------------------------------------------

    callback = function(framesize)
        local ratio = framesize.width / framesize.height
        if ratio <= 1.34 then
            -- iPad 768*1024(1536*2048) is 4:3 screen
            return {
                autoscale = "FIXED_WIDTH"
                -- autoscale = "SHOW_ALL",
            }
        end
    end
}

--
-- =>
-- display.setAutoScale(CC_DESIGN_RESOLUTION)
--