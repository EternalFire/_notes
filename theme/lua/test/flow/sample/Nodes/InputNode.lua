
local Type = require "Type"
local NodeType = Type.NodeType
local NodeActRet = Type.NodeActRet

local Node = require "Node"

local ActType = require "SampleAction" -- 

--- createNode{actType = "InputNode"}
local function InputNode(param)    
    local _param = clone(param)

    _param.type = ActType.AtkNode.type
    _param.actType = ActType.AtkNode.actType    

    _param.onEnter = function(node, state, pre_state)
        --
        print("Enter InputNode:\n")
        node.state.data = node.state.data or {}        
        node.state.data.input = io.read()
    end

    _param.onDone = function(node, state)
        node.state.ret = node.state.data.input
    end
    _param.onTick = function(node, state, dt)   
        if node.state.data.input ~= nil and node.state.data.input ~= "" then     
            state:done()
        end
    end

    return Node(_param)
end

return InputNode
