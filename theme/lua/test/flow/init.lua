
------------------------------------------
-- environment

package.path = table.concat({
    package.path,
    "lib/?.lua",
    "flow/?.lua",
    "flow/Flow/?.lua",
    "flow/common/?.lua",
    "flow/Nodes/?.lua",
    "flow/Edges/?.lua",
}, ";")

--- flow namespace
_flow_ = {
    type_create_map = nil,
    edge_create_map = nil,    
    FlowStateMachine = nil,
    addActType = function(self, key, actType)
        self.type_create_map[key] = actType
    end,
}

require "game.__cc"
require "helper"

local StateMachine = require "StateMachine"
local saveFlow = require "saveFlow"
local loadFlow = require "loadFlow"

local inState = require "_in_state"
local _in_state = inState._in_state
local _genFlowID = inState._genFlowID
local _genNodeID = inState._genNodeID
local _genEdgeID = inState._genEdgeID

local Type = require "Type"
local EdgeType = Type.EdgeType
local NodeType = Type.NodeType
local NodeActRet = Type.NodeActRet

local ActType = require "ActType"
-- local ActTypeEX = require "ActTypeEX"

local Node = require "Node"
local Edge = require "Edge"
local Flow = require "FlowStruct"
local createNode = require "createNode"
local createEdge = require "createEdge"

-- Node
local type_create_map = {
    [NodeType.Start] = "StartNode",
    [NodeType.End] = "EndNode",
}
_flow_.type_create_map = type_create_map

-- other Nodes
for key, types in pairs(ActType) do
    _flow_:addActType(key, types.actType)
end

dump(_flow_.type_create_map, "_flow_.type_create_map")

-- edge
local edge_create_map = {
    [EdgeType.AutoNodeRet] = "AutoEdge",
    [EdgeType.Custom] = "CustomEdge",
}

_flow_.edge_create_map = edge_create_map
dump(_flow_.edge_create_map, "_flow_.edge_create_map")

------------------------------------------

local _doc = require "flowDoc"

------------------------------------------

local function FlowStateMachine(flow)
    local object = {}
    function object:init(flow)
        self.flow = flow
        self.stateMachine = nil
    end
    function object:buildStateMachine()
        if not self.stateMachine then
            local states = {}

            for i, node in ipairs(self.flow.nodes) do
                local _state = self:createState(node)
                if _state then
                    print(string.format("create state [%s][%s]", _state.name, node.text))
                    table.insert(states, _state)
                end
            end

            local sm = StateMachine.create{ states = states }
            self.stateMachine = sm
        else
            print("state machine is created")
            self:clear()
        end
    end
    function object:createState(node)
        if not node then return end

        local flow = self.flow
        local state_param = {
            name = node.name,
            data = node,
            transfer = function(s)
                local node = s.data
                local next_node_name = self:_transferState(s, node)
                -- print("transfer:", s.name, s.isEntered, s.isDone, next_node_name)
                return next_node_name -- string
            end,
            onEnter = function(s, pre_s)
                -- synchronous
                local node = s.data

                if node.onEnter then
                    node:onEnter(s, pre_s)
                end

                if not node.state.flow_sm and node.state.flow_id then
                    -- todo
                    -- find flow object
                    -- build flow state machine
                end

                if node.state.flow_sm then
                    if type(node.state.flow_sm.buildStateMachine) == "function" then
                        node.state.flow_sm:buildStateMachine()
                    end
                end

                if node.state.flow_sm then
                    node.state.flow_sm:start()
                end

                if node.type == NodeType.Start or node.type == NodeType.End or node.type == NodeType.SyncAction then
                    local is_done = false

                    if node.state.flow_sm then
                        if node.state.flow_sm.stateMachine then
                            node.state.flow_sm.stateMachine:tick(0)
                        end

                        if node.state.flow_sm:isFinish() then
                            is_done = true
                        end
                    else
                        is_done = true
                    end

                    if is_done then
                        -- finish node, goto next node
                        s:done()

                        -- SyncAction, transfer to next node
                        self.stateMachine:tick(0)
                    end
                end
            end,
            onLeave = function(s)end,
            onTick = function(s, dt)
                -- asynchronous
                local node = s.data
                if node.onTick then
                    node:onTick(s, dt)
                end

                if node.state.flow_sm then
                    if node.state.flow_sm.stateMachine then
                        node.state.flow_sm.stateMachine:tick(dt)
                    end

                    if node.state.flow_sm:isFinish() then
                        s:done()
                    end
                end

                -- s:done()
            end,
            onDone = function(s)
                local node = s.data
                node.state.ret = NodeActRet.GoodJob

                if node.onDone then
                    node:onDone(s)
                end

                if node.state.flow_sm then
                    node.state.ret = node.state.flow_sm.flow.state.ret
                end
            end,
            onPause = function(s)end,
            onResume = function(s)end,
            onInterrupt = function(s)end,
        }
        return StateMachine.createState(state_param)
    end
    function object:_transferState(s, node)
        if s and node then
            for i, edge_id in ipairs(node.out_edge_ids) do
                local edge = self.flow.edgeDict[edge_id]
                if edge then
                    -- print("_transferState", edge.type, node.state.ret, edge.condition)
                    local ret_condition = false

                    if edge.type == EdgeType.AutoNodeRet then
                        -- check node ret
                        if node.state.ret == edge.condition then
                            ret_condition = true
                        end
                    elseif edge.type == EdgeType.Custom then
                        -- check custom
                        if type(edge.checkCondition) == "function" then
                            ret_condition = edge:checkCondition(s, s.preState, node)
                        end
                    end

                    if ret_condition then
                        local next_node = self.flow.nodeDict[edge.out_node_id]
                        if next_node then
                            -- set flow result
                            if next_node.id == self.flow.end_node_id then
                                self.flow.state.ret = node.state.ret
                                dump(self.flow.state.ret, "flow result")
                            end

                            print(string.format("[%s][%s] => [%s][%s] via [%s]", 
                                s.name, node.actType or node.type, 
                                next_node.name, next_node.actType or next_node.type, 
                                edge.name))

                            return next_node.name
                        end
                    end
                end
            end
        end
    end
    function object:start()
        self:clear()

        local start_node = self.flow.nodeDict[self.flow.start_node_id]
        self.stateMachine:transfer(start_node.name)
    end
    function object:isFinish()
        if self.stateMachine.currentState then
            if self.stateMachine.currentState.data then
                if self.stateMachine.currentState.data.id == self.flow.end_node_id then
                    return true
                end
            end
        end
        return false
    end
    function object:clear()
        if self.flow then
            self.flow:clear()
        end

        if self.stateMachine then
            self.stateMachine:clear()
        end
    end

    object:init(flow)
    return object
end

_flow_.FlowStateMachine = FlowStateMachine
------------------------------------------