
local Type = require "Type"
local NodeType = Type.NodeType
local NodeActRet = Type.NodeActRet

local Node = require "Node"
local ActType = require "ActType"


--- createNode{actType = "WaitForSeconds", data = 5 }
--- WaitForSeconds{actType = "WaitForSeconds", data = 5 }
local function WaitForSeconds(param)
    local _param = clone(param)

    _param.type = ActType.WaitForSeconds.type
    _param.actType = ActType.WaitForSeconds.actType
    _param.onEnter = function(node, state, pre_state)
        --
    end
    _param.onDone = function(node, state)
        node.state.ret = NodeActRet.GoodJob
    end
    _param.onTick = function(node, state, dt)
        -- print(node.text, "wait ", state.tickedTime, node.state.data)
        if state.tickedTime >= node.state.data then
            state:done()
        end
    end

    return Node(_param)
end

return WaitForSeconds
