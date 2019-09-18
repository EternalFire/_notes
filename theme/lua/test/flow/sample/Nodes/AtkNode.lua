
local Type = require "Type"
local NodeType = Type.NodeType
local NodeActRet = Type.NodeActRet

local Node = require "Node"

local ActType = require "SampleAction" -- 

--- createNode{actType = "AtkNode", data = { x = 30, y = 20, damage = 1 }}
local function AtkNode(param)
    local _param = clone(param)

    _param.type = ActType.AtkNode.type -- 
    _param.actType = ActType.AtkNode.actType -- 

    _param.onEnter = function(node, state, pre_state)
        --
        print("AtkNode onEnter...", node.state.data.x, node.state.data.y, node.state.data.damage)
        state:done()
    end

    _param.onDone = function(node, state)
        node.state.ret = NodeActRet.GoodJob
    end
    -- _param.onTick = function(node, state, dt)        

    -- end

    return Node(_param)
end

return AtkNode
