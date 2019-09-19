
local function init_flow_()
    dump(package.path, "package.path")
    
    require "flow.init"
    
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
        local flowSM, sm
        local cnt = 0
        local timer_id

        flowSM = FlowStateMachine(flow)
        flowSM:buildStateMachine()
        flowSM:start()    
        sm = flowSM.stateMachine

        timer_id = setInterval(function(dt)
            if flowSM:isFinish() then
                cnt = cnt + 1

                print("times = ", times, "cnt = ", cnt)
                if times ~= -1 and cnt >= times then
                    clearTimer(timer_id)
                    return
                end

                flowSM:start()
            else
                if sm then
                    sm:tick(dt)
                end
            end
        end, 0.1)
    end

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

        local n_wait_3 = createNode{actType = "WaitForSeconds", data = 1, text="n_wait_3"}
        local n_atk_3 = createNode{actType = "AtkNode", data = { x = 0, y = 0, damage = 100 }}
        local n_atk_4 = createNode{actType = "AtkNode", data = { x = 0, y = 0, damage = 1000 }}

        f:con(n1, n_wait_1)
        f:con(n_wait_1, n_atk_1)
        f:con(n_atk_1, n_atk_2)
        f:con(n_atk_2, n_wait_2)
        -- f:con(n_wait_2, n_input_1)
        -- f:con(n_input_1, n_echo_0, "0")
        -- f:con(n_input_1, n_echo_1, "1")
        -- f:con(n_input_1, n_echo_0, "a")
        -- f:con(n_input_1, n_echo_1, "b")
        -- f:con(n_echo_0, n2, "0000")
        f:con(n_wait_2, n_echo_1)
        f:con(n_echo_1, n_wait_3, "1111")
        f:con(n_wait_3, n_atk_3)
        f:con(n_atk_3, n_atk_4)
        f:con(n_atk_4, n2)

        f:setStart(n1)
        f:setEnd(n2)
        f:printFlow()
        
        runFlowAsync(f, 1)
    end

    case_seq_actions()
end

return init_flow_
