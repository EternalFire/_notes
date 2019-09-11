
local Type = require "Type"
local NodeType = Type.NodeType
local NodeActRet = Type.NodeActRet

local Node = require "Node"
local ActType = require "ActType"

--- createNode{actType = "EchoNode", data = "okok"}
local function EchoNode(param)
    local _param = clone(param)

    _param.type = ActType.EchoNode.type
    _param.actType = ActType.EchoNode.actType    
    _param.onEnter = function(node, state, pre_state)
        --
    end
    _param.onDone = function(node, state)
        node.state.ret = node.state.data
    end
    -- _param.onTick = function(node, state, dt)        
    -- end

    return Node(_param)
end

return EchoNode
