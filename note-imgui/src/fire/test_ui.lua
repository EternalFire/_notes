
local function test_ui()
    local Button = require("fire.ui.Button")
    local btn = Button.new{
        callback = function()
            print("click1!!!!!!!!!!")
        end
    }
    btn.node:addTo(State.bgLayer)
    btn.node:move(110,110)

    local InputText = require("fire.ui.InputText")
    local inputText = InputText.new{
        endCallback = function(changed, before, after)
            print("endCallback =>", changed, before, after)
        end
    }
    inputText.node:addTo(State.bgLayer)
    inputText.node:move(210,210)

    setTimeout(function()
        inputText.text = "93489023748923"
    end, 3)
end

return test_ui

