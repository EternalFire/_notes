
------------------------------------------
package.path = table.concat({
    package.path,
    "flow/sample/Nodes/?.lua",
    "flow/sample/?.lua",
}, ";")

local Type = require "Type"
local EdgeType = Type.EdgeType
local NodeType = Type.NodeType
local NodeActRet = Type.NodeActRet

local Node = require "Node"
local Edge = require "Edge"
local Flow = require "FlowStruct"
local createNode = require "createNode"
local createEdge = require "createEdge"
local FlowStateMachine = _flow_.FlowStateMachine

------------------------------------------
-- add new types
local SampleAction = require "SampleAction"

for key, types in pairs(SampleAction) do
    _flow_:addActType(key, types.actType)
end

------------------------------------------

local function createFlow()
    local flow = Flow()

    -- create node A
    -- create node B
    -- create edge E
    -- connect A and B with E
    -- add A, B, E to flow
    -- set start node
    -- set end node
    local nodeA = createNode{type = NodeType.Start}
    local nodeB = createNode{type = NodeType.End}
    local nodeC = createNode{actType = "WaitForSeconds", data = 2, text="wait 2 sec"}
    -- local nodeD = Node{
    --     text = "node D",
    --     type = NodeType.SyncAction,
    --     onEnter = function(node, s, pre_s)
    --         node.state.data = "okok"
    --         print(node.text, "pre.data.state.ret =", pre_s.data.state.ret)
    --     end,
    --     onDone = function(node, s)
    --         node.state.ret = node.state.data
    --     end
    -- }
    local nodeD = createNode{actType = "EchoNode", data = "okok"}
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

    local edgeE = createEdge() -- Edge{type = EdgeType.AutoNodeRet}
    local edgeE_1 = createEdge() -- Edge{type = EdgeType.AutoNodeRet}
    local edgeE_2 = createEdge() -- Edge{type = EdgeType.AutoNodeRet}
    local edgeE_3 = createEdge() -- Edge{type = EdgeType.AutoNodeRet}
    local edge_1 = Edge{type = EdgeType.AutoNodeRet, condition = 100}
    local edge_2 = createEdge{condition = "okok"} --Edge{type = EdgeType.AutoNodeRet, condition = "okok"}
    -- local edge_2 = createEdge{
    --     type = EdgeType.Custom,
    --     checkCondition = function(edge, state, preState, node)
    --         if node.state.ret == "okok" then
    --             print("call edge_2 checkCondition ")
    --             return true
    --         end
    --     end
    -- }
    local edge_3 = Edge{type = EdgeType.AutoNodeRet, condition = 200}

    flow:connect(nodeA, nodeC, edgeE)
    flow:connect(nodeC, nodeD, edgeE_3)
    -- flow:connect(nodeC, nodeE, edge_3)
    flow:connect(nodeC, nodeE, edge_1)
    flow:connect(nodeE, nodeB, edgeE_1)
    flow:connect(nodeD, nodeB, edge_2)
    flow:setStart(nodeA)
    flow:setEnd(nodeB)

    -- dump(flow, "flow", 4)
    return flow
end

local function createFlow_1()
    local flow = Flow()
    local nodeA = createNode{type = NodeType.Start}
    local nodeB = createNode{type = NodeType.End}
    local nodeC = createNode{type = NodeType.ASyncAction, flow_sm = FlowStateMachine(createFlow())}
    local e1 = createEdge()
    local e2 = createEdge({condition = "okok"})
    flow:connect(nodeA, nodeC, e1)
    flow:connect(nodeC, nodeB, e2)
    flow:setStart(nodeA)
    flow:setEnd(nodeB)
    return flow
end

local function test_flow_sync()
    local f = Flow()
    local n1 = createNode{type = NodeType.Start}
    local n2 = createNode{type = NodeType.End}
    local n_echo = createNode{actType = "EchoNode", data = "test sync flow"}
    local e1 = createEdge()
    local e2 = createEdge{condition = "test sync flow"}
    f:connect(n1, n_echo, e1)
    f:connect(n_echo, n2, e2)
    f:setStart(n1)
    f:setEnd(n2)
    return f
end

local function runFlow(flow)
    local flowSM
    flowSM = FlowStateMachine(flow)
    flowSM:buildStateMachine()
    flowSM:start()

    -- simple engine
    local sm = flowSM.stateMachine
    local t1 = os.clock()
    local dt = 0
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
                print("\n--------------==========--------------\n")
                -- flowSM:start()
                -- saveFlow(flow, "tmp_finish.json")
                break
            end
        else
            dt = os.clock() - t1
        end
    end
end

local function runFlowSync(flow)
    local flowSM
    flowSM = FlowStateMachine(flow)
    flowSM:buildStateMachine()
    flowSM:start()

    if flowSM:isFinish() then
        print("runFlowSync finished!")
    end

    return flowSM
end

local function runFlowSM_sync(flow_statemachine)
    local fsm = flow_statemachine
    if fsm then
        fsm:buildStateMachine()
        fsm:start()

        if fsm:isFinish() then
            print("runFlowSM_sync finished!")
        end
    end
    return fsm
end

local function runFlowAsync(flow, times)
    local flowSM
    flowSM = FlowStateMachine(flow)
    flowSM:buildStateMachine()
    flowSM:start()

    local sm = flowSM.stateMachine
    local t1 = os.clock()
    local dt = 0
    local delta = 0.1
    local cnt = 0

    while 1 do
        if dt >= delta then
            if sm then
                sm:tick(dt)
            end

            t1 = os.clock()
            dt = 0            

            if flowSM:isFinish() then
                cnt = cnt + 1

                if times ~= -1 and cnt == times then
                    break
                end

                flowSM:start()
            end
        else
            dt = os.clock() - t1
        end
    end    
end

---------------------------------------
--- node contain flow
local function case_flow_in_node()
    local flow = createFlow_1()
    runFlow(flow)
end

--- run three times
local function case_run_flow_sync_3_times()
    local f = test_flow_sync()
    local f_sm = runFlowSync(f)
    print()
    runFlowSM_sync(f_sm)
    print()
    runFlowSM_sync(f_sm)
end

--- wait 1 s, atk 1, atk 10, wait 3 s
local function case_seq_actions()
    local f = Flow()
    local n1 = createNode{type = NodeType.Start}
    local n2 = createNode{type = NodeType.End}
    local n_wait_1 = createNode{actType = "WaitForSeconds", data = 1, text="n_wait_1"}
    local n_atk_1 = createNode{actType = "AtkNode", data = { x = 30, y = 20, damage = 1 }}
    local n_atk_2 = createNode{actType = "AtkNode", data = { x = 40, y = 60, damage = 10 }}
    local n_wait_2 = createNode{actType = "WaitForSeconds", data = 3, text="n_wait_2"}
    local n_input_1 = createNode{actType = "InputNode"}
    local n_echo_0 = createNode{actType = "EchoNode", data = "0000"}
    local n_echo_1 = createNode{actType = "EchoNode", data = "1111"}

    -- local e1 = createEdge()
    -- local e2 = createEdge()
    -- local e3 = createEdge()
    -- local e4 = createEdge()
    -- local e5 = createEdge()
    -- local e6 = createEdge{condition = "0"}
    -- local e7 = createEdge{condition = "1"}
    -- local e7_1 = createEdge{condition = "a"}
    -- local e7_2 = createEdge{condition = "b"}
    -- local e8 = createEdge{condition = "0000"}
    -- local e9 = createEdge{condition = "1111"}

    -- f:connect(n1, n_wait_1, e1)
    -- f:connect(n_wait_1, n_atk_1, e2)
    -- f:connect(n_atk_1, n_atk_2, e3)
    -- f:connect(n_atk_2, n_wait_2, e4)
    -- f:connect(n_wait_2, n_input_1, e5)
    -- f:connect(n_input_1, n_echo_0, e6)
    -- f:connect(n_input_1, n_echo_1, e7)
    -- f:connect(n_input_1, n_echo_0, e7_1)
    -- f:connect(n_input_1, n_echo_1, e7_2)
    -- f:connect(n_echo_0, n2, e8)
    -- f:connect(n_echo_1, n2, e9)

    f:con(n1, n_wait_1)
    f:con(n_wait_1, n_atk_1)
    f:con(n_atk_1, n_atk_2)
    f:con(n_atk_2, n_wait_2)
    f:con(n_wait_2, n_input_1)
    f:con(n_input_1, n_echo_0, "0")
    f:con(n_input_1, n_echo_1, "1")
    f:con(n_input_1, n_echo_0, "a")
    f:con(n_input_1, n_echo_1, "b")
    f:con(n_echo_0, n2, "0000")
    f:con(n_echo_1, n2, "1111")

    f:setStart(n1)
    f:setEnd(n2)

    -- runFlowAsync(f, 1)
    f:printFlow()
end

local function main()
    -- print(_doc)
    -- dump(_doc)
    -- local flow = createFlow()
    -- saveFlow(flow, "tmp.json")

    -- local flow = Flow()
    -- loadFlow(flow, "tmp.json")
    -- saveFlow(flow, "tmp_new.json")
    -- loadFlow(flow, "tmp_new.json")
    -- runFlow(flow)

    ---------------------------------------    
    -- case_flow_in_node()
    -- case_run_flow_sync_3_times()
    case_seq_actions()

    ---------------------------------------    
    -- print("/////////")
    -- local chain_str = "_flow_.type_create_map"
    -- local object = chain(chain_str)
    -- dump(object, chain_str)
    -- print("........")
end

main()