
local json = require "lib.lunajson"
local Node = require "Node"
local Edge = require "Edge"
local inState = require "_in_state"
local _in_state = inState._in_state

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
        
        for i, nodeObject in ipairs(object.nodes or {}) do
            local node = Node{
                id = nodeObject[1],
                text = nodeObject[3],
                type = nodeObject[4],
            }

            if nodeObject.state and nodeObject.state.ret ~= nil then
                node.state = nodeObject.state
            end

            nodeDict[node.id] = node
            
            _in_state.next_node_id = math.max(_in_state.next_node_id, node.id + 1)
        end
        
        for i, edgeObject in ipairs(object.edges or {}) do
            local edge = Edge{
                id = edgeObject[1],
                type = edgeObject[2],
                condition = edgeObject[5],
            }

            edge.in_node_id = edgeObject[3]
            edge.out_node_id = edgeObject[4]

            local from_node = nodeDict[edge.in_node_id]
            local to_node = nodeDict[edge.out_node_id]
            flow:connect(from_node, to_node, edge)

            _in_state.next_edge_id = math.max(_in_state.next_edge_id, edge.id + 1)
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
