
------------------------------------------
-- environment

require "game.__cc"
local StateMachine = require("flow.StateMachine")

local function uniqueInsert(t, v)
    if not table.indexof(t, v) then
        table.insert(t, v)
    end
end

local _in_state = {
    next_flow_id = 1,
    next_node_id = 1,
    next_edge_id = 1,
}

local function _genFlowID()
    local id = _in_state.next_flow_id
    _in_state.next_flow_id = id + 1
    return id
end

local function _genNodeID()
    local id = _in_state.next_node_id
    _in_state.next_node_id = id + 1
    return id
end

local function _genEdgeID()
    local id = _in_state.next_edge_id
    _in_state.next_edge_id = id + 1
    return id
end

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

local EdgeType = {
    AutoNodeRet = 1,
    Custom = 10,
}

local NodeType = {
    Start = 1,
    End = 2, 
    SyncAction = 3,
    ASyncAction = 4,
}

local NodeActRet = {
    GoodJob = true,
    Failure = false,    
}

local function Flow(param)
    -- if not param then return end

    local object = {}
    function object:init()
        self.id = self.id or _genFlowID()
        self.name = string.format("Flow_%s", self.id)
        self.nodes = {}
        self.edges = {}
        self.state = {}
        self.in_out_map = {}  -- self.in_out_map[InNodeID][OutNodeID] = {EdgeID, ...}
        self.nodeDict = {}
        self.edgeDict = {}
        self.start_node_id = nil
        self.end_node_id = nil

    end
    function object:setStart(start_node)
        if start_node then
            self.start_node_id = start_node.id
        end
    end
    function object:setEnd(end_node)
        if end_node then
            self.end_node_id = end_node.id
        end
    end
    function object:connect(from_node, to_node, edge)
        if from_node and to_node and edge then
            -- from
            if not self.nodeDict[from_node.id] then
                table.insert(self.nodes, from_node)
                self.nodeDict[from_node.id] = from_node
            end

            -- to
            if not self.nodeDict[to_node.id] then
                table.insert(self.nodes, to_node)
                self.nodeDict[to_node.id] = to_node
            end

            -- edge
            if not self.edgeDict[edge.id] then
                table.insert(self.edges, edge)
                self.edgeDict[edge.id] = edge
            end

            edge.in_node_id = from_node.id
            edge.out_node_id = to_node.id
            
            from_node:addEdge(false, edge.id)
            to_node:addEdge(true, edge.id)
            
            self.in_out_map[from_node.id] = self.in_out_map[from_node.id] or {}
            self.in_out_map[from_node.id][to_node.id] = self.in_out_map[from_node.id][to_node.id] or {}
            uniqueInsert(self.in_out_map[from_node.id][to_node.id], edge.id)
        end
    end
    function object:connectByID(from_node_id, to_node_id, edge_id)
        local from_node = self.nodeDict[from_node_id]
        local to_node = self.nodeDict[to_node_id]
        local edge = self.edgeDict[edge_id]
        self:connect(from_node, to_node, edge)
    end
    function object:delEdge(edge_id)

    end
    function object:delNode(node_id)
        
    end
    
    object:init()
    return object
end

local function Node(param)
    if not param then return end

    local object = {}
    function object:init(param)
        local p_type = param.type
        local p_onTick = param.p_onTick

        self.id = _genNodeID()
        self.name = string.format("Node_%s", self.id)
        self.type = p_type
        self.in_edge_ids = {}
        self.out_edge_ids = {}
        self.state = { 
            ret = NodeActRet.Failure
        }
        self.onTick = p_onTick
    end
    function object:addEdge(isIn, edge_id)
        if isIn then            
            uniqueInsert(self.in_edge_ids, edge_id)
        else
            uniqueInsert(self.out_edge_ids, edge_id)
        end
    end

    object:init(param)
    return object
end

local function Edge(param)
    if not param then return end

    local object = {}
    function object:init(param)
        local p_type = param.type
        -- local p_in_node_id = param.in_node_id
        -- local p_out_node_id = param.out_node_id
        local p_transfer = param.transfer
        local p_condition = param.condition

        self.id = _genEdgeID()
        self.name = string.format("Edge_%s", self.id)
        self.type = p_type
        self.in_node_id = nil
        self.out_node_id = nil
        self.transfer = p_transfer
        self.condition = p_condition or NodeActRet.GoodJob
    end

    object:init(param)
    return object    
end

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
            onEnter = function(s)
                -- synchronous
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
                    print("_transferState", edge.type, node.state.ret)

                    if edge.type == EdgeType.AutoNodeRet then
                        -- check node ret
                        if node.state.ret == edge.condition then
                            local next_node = self.flow.nodeDict[edge.out_node_id]
                            if next_node then
                                return next_node.name
                            end
                        end
                    elseif edge.type == EdgeType.Custom then
                        -- check custom

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

-- --- run by start node
-- --- execute node
-- --- when node done, execute next node
-- --- if node is end, end flow
-- local function execFlow(flow)
--     if flow then
--         local start_node = flow.nodeDict[flow.start_node_id]
--         local end_node = flow.nodeDict[flow.end_node_id]
        
--     end
-- end

local function runFlow()
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
    local edgeE = Edge{type = EdgeType.AutoNodeRet}

    -- dump(nodeA)
    -- dump(nodeB)
    -- dump(edgeE)
    flow:connect(nodeA, nodeB, edgeE)
    flow:setStart(nodeA)
    flow:setEnd(nodeB)

    dump(flow, "flow", 4)
    -- execFlow(flow)    

    -- if 1 then return end

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

            if cnt == 3 then
                break
            end
            
            if flowSM:isFinish() then
                cnt = cnt + 1
                print("\n--------------==========------\n")
                flowSM:start()
            end
        else
            dt = os.clock() - t1
        end
    end
end

local function main()
    -- print(_doc)
    -- dump(_doc)
    runFlow()
end

main()
