
local json = require "lunajson"
local Node = require "Node"
local Edge = require "Edge"
local inState = require "_in_state"
local _in_state = inState._in_state

local createNode = require "createNode"
local createEdge = require "createEdge"

local function buildFlowInstance(flow, object)
    if object and flow then
        local nodeDict = {}

        flow.id = object.id
        flow.name = object.name
        flow.start_node_id = object.start_node_id
        flow.end_node_id = object.end_node_id

        _in_state.next_flow_id = math.max(_in_state.next_flow_id, flow.id + 1)

        if object.state and object.state.ret ~= nil then
            flow.state = object.state
        end

        object.nodes = object.nodes or {}
        object.edges = object.edges or {}
        table.sort(object.nodes, function(a, b)
            return a[1] < b[1]
        end)
        table.sort(object.edges, function(a, b)
            return a[1] < b[1]
        end)
        
        for i, nodeObject in ipairs(object.nodes) do
            local state = nodeObject[6]
            local param = {
                id = nodeObject[1],
                name = nodeObject[2],
                text = nodeObject[3],
                type = nodeObject[4],
                actType = nodeObject[5],
            }

            if state and state.data then
                param.data = state.data
            end

            local node
            node = createNode(param)

            if node then
                nodeDict[node.id] = node
                
                _in_state.next_node_id = math.max(_in_state.next_node_id, node.id + 1)
            end
        end
        
        for i, edgeObject in ipairs(object.edges) do
            local param = {
                id = edgeObject[1],
                type = edgeObject[2],
                condition = edgeObject[5],
            }

            local edge = createEdge(param)

            if edge then
                edge.in_node_id = edgeObject[3]
                edge.out_node_id = edgeObject[4]

                local from_node = nodeDict[edge.in_node_id]
                local to_node = nodeDict[edge.out_node_id]
                flow:connect(from_node, to_node, edge)

                _in_state.next_edge_id = math.max(_in_state.next_edge_id, edge.id + 1)
            end
        end
    end
end

local function loadFlow(flow, filepath)
    local content = io.readfile(filepath)
    if content then
        local object = json.decode(content)
        buildFlowInstance(flow, object)
    end
end

return loadFlow
