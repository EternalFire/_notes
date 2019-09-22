
local function test_ui()
    local Button = require("fire.ui.Button")
    local btn = Button.new{
        callback = function()
            print("click1!!!!!!!!!!")
        end
    }
    btn.node:addTo(State.bgLayer)
    btn.node:move(110,110)

    -- btn.text11 = "100"
end

return test_ui

