
------------------------------------------
-- environment

package.path = table.concat({
    package.path, 
    "lib/?.lua",
    "flow/?.lua",
}, ";")

require "game.__cc"
require "helper"

local json = require "lib.lunajson"
local StateMachine = require "flow.StateMachine"
local saveFlow = require "flow.saveFlow"
local loadFlow = require "flow.loadFlow"

local inState = require "_in_state"
local _in_state = inState._in_state
local _genFlowID = inState._genFlowID
local _genNodeID = inState._genNodeID
local _genEdgeID = inState._genEdgeID

local Type = require "Type"
local EdgeType = Type.EdgeType
local NodeType = Type.NodeType
local NodeActRet = Type.NodeActRet

local Node = require "Node"
local Edge = require "Edge"
local Flow = require "FlowStruct"

------------------------------------------

local _doc = [[
Flow tool:

- Flow
    - Nodes
    - Edges
    - state

- Node
    - id
    - inputs(edge id)
    - outputs(edge id)
    - type

- Edge
    - id
    - input_node_id(node id)
    - output_node_id(node id)
    - type: auto / custom
    - transfer()
    - auto_transfer(by action node ret, by node state, by flow state, by global state...)

]]

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
                    print(string.format("create state [%s]", _state.name))
                    table.insert(states, _state)
                end
            end

            local sm = StateMachine.create{ states = states }
            self.stateMachine = sm
        else
            -- ...
        end
    end
    function object:createState(node)
        if not node then return end

        local flow = self.flow
        local state_param = {
            name = node.name,
            data = node,
            transfer = function(s)
                -- return "next_node_name"
                local node = s.data                
                local next_node_name = self:_transferState(s, node)
                print("transfer:", s.name, s.isEntered, s.isDone, next_node_name)
                return next_node_name
            end,
            onEnter = function(s, pre_s)
                -- synchronous
                local node = s.data
                if node.onEnter then
                    node:onEnter(s, pre_s)
                end

                local node = s.data
                if node.type == NodeType.Start or node.type == NodeType.End or node.type == NodeType.SyncAction then
                    s:done()
                end
            end,
            onLeave = function(s)end,
            onTick = function(s, dt)
                -- asynchronous
                local node = s.data
                if node.onTick then
                    node:onTick(s, dt)
                end
                -- s:done()
            end,
            onDone = function(s)
                local node = s.data
                node.state.ret = NodeActRet.GoodJob

                if node.onDone then
                    node:onDone(s)
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
                    print("_transferState", edge.type, node.state.ret, edge.condition)
                    local ret_condition = false

                    if edge.type == EdgeType.AutoNodeRet then
                        -- check node ret
                        if node.state.ret == edge.condition then
                            ret_condition = true
                        end
                    elseif edge.type == EdgeType.Custom then
                        -- check custom
                        if type(edge.checkCondition) == "function" then
                            ret_condition = edge:checkCondition()
                        end
                    end

                    if ret_condition then
                        local next_node = self.flow.nodeDict[edge.out_node_id]
                        if next_node then
                            return next_node.name
                        end
                    end
                end
            end
        end
    end
    function object:start()
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

    object:init(flow)
    return object
end


local function createFlow()
    local flow = Flow()

    -- create node A
    -- create node B
    -- create edge E
    -- connect A and B with E
    -- add A, B, E to flow
    -- set start node
    -- set end node
    local nodeA = Node{type = NodeType.Start}
    local nodeB = Node{type = NodeType.End}    
    local nodeC = Node{
        text = "node C",
        -- type = NodeType.SyncAction,
        type = NodeType.ASyncAction,
        onEnter = function(node, s, pre_s)
            node.state.data = 100
            -- node.state.data = 200
            print("nodeC ..... ")
        end,
        onDone = function(node, s)
            node.state.ret = node.state.data
        end,
        onTick = function(node, s, dt)
            -- print(node.text, "tick time =", s.tickedTime)
            if s.tickedTime >= 2 then
                s:done()
            end
        end,
    }
    local nodeD = Node{
        text = "node D",
        type = NodeType.SyncAction,
        onEnter = function(node, s, pre_s)
            node.state.data = "okok"
            print(node.text, "pre.data.state.ret =", pre_s.data.state.ret)
        end,
        onDone = function(node, s)
            node.state.ret = node.state.data
        end
    }
    local nodeE = Node{
        text = "node E",
        type = NodeType.SyncAction,
        onEnter = function(node, s, pre_s)
            print(node.text, "pre.data.state.ret =", pre_s.data.state.ret)
        end,
        onDone = function(node, s)
            -- node.state.ret = node.state.data
        end
    }

    local edgeE = Edge{type = EdgeType.AutoNodeRet}
    local edgeE_1 = Edge{type = EdgeType.AutoNodeRet}
    local edgeE_2 = Edge{type = EdgeType.AutoNodeRet}
    local edge_1 = Edge{type = EdgeType.AutoNodeRet, condition = 100}
    local edge_2 = Edge{type = EdgeType.AutoNodeRet, condition = "okok"}
    local edge_3 = Edge{type = EdgeType.AutoNodeRet, condition = 200}

    -- dump(nodeA)
    -- dump(nodeB)
    -- dump(edgeE)
    flow:connect(nodeA, nodeC, edgeE)
    flow:connect(nodeC, nodeD, edge_1)
    flow:connect(nodeC, nodeE, edge_3)
    flow:connect(nodeE, nodeB, edgeE_1)
    flow:connect(nodeD, nodeB, edge_2)
    flow:setStart(nodeA)
    flow:setEnd(nodeB)

    dump(flow, "flow", 4)
    return flow
end

local function runFlow(flow)
    local flowSM
    flowSM = FlowStateMachine(flow)
    flowSM:buildStateMachine()
    flowSM:start()

    -- simple engine
    local sm = flowSM.stateMachine
    local t1 = os.clock()
    local dt = 1
    local delta = 0.1

    local cnt = 1

    while 1 do
        if dt >= delta then
            -- print(dt, os.clock())

            if sm and type(sm.tick) == "function" then
                sm:tick(dt)
            end

            t1 = os.clock()
            dt = 0

            if cnt == 2 then
                break
            end
            
            if flowSM:isFinish() then
                cnt = cnt + 1
                print("\n--------------==========------\n")
                -- flowSM:start()
                break
            end
        else
            dt = os.clock() - t1
        end
    end
end

local function main()
    -- print(_doc)
    -- dump(_doc)
    local flow = createFlow()
    -- saveFlow(flow, "tmp.json")

    -- local flow = Flow()
    -- loadFlow(flow, "tmp.json")
    -- saveFlow(flow, "tmp_new.json")
    -- loadFlow(flow, "tmp_new.json")
    runFlow(flow)
end

main()
