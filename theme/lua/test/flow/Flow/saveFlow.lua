
local json = require "lunajson"

local function buildFlowObject(flow)
    local object = {}

    if flow then
        object.id = flow.id
        object.name = flow.name
        object.nodes = {}
        object.edges = {}
        object.state = flow.state
        object.start_node_id = flow.start_node_id
        object.end_node_id = flow.end_node_id

        for i, node in ipairs(flow.nodes) do
            -- local state = node.state or { ret = false }
            -- local nodeObject = {
            --     node.id,         -- 1
            --     node.name or "", -- 2
            --     node.text or "", -- 3
            --     node.type,       -- 4
            --     node.actType,    -- 5
            --     state,           -- 6
            -- }
            
            -- nodeObject.id = node.id
            -- nodeObject.name = node.name
            -- nodeObject.text = node.text
            -- nodeObject.type = node.type
            -- -- nodeObject.in_edge_ids = node.in_edge_ids
            -- -- nodeObject.out_edge_ids = node.out_edge_ids
            -- nodeObject.state = node.state

            local nodeObject = node.nodeObject
            table.insert(object.nodes, nodeObject)
        end

        for i, edge in ipairs(flow.edges) do
            local condition = edge.condition
            if condition == nil then
                condition = true
            end
        
            local in_node_id = edge.in_node_id
            if in_node_id == nil then
                in_node_id = -1
            end

            local out_node_id = edge.out_node_id
            if out_node_id == nil then
                out_node_id = -1
            end

            local edgeObject = {
                edge.id,
                edge.type,
                in_node_id,
                out_node_id,
                condition,
            }
            -- edgeObject.id = edge.id
            -- edgeObject.type = edge.type
            -- edgeObject.in_node_id = edge.in_node_id
            -- edgeObject.out_node_id = edge.out_node_id
            -- edgeObject.condition = edge.condition
            table.insert(object.edges, edgeObject)
        end
    end

    return object
end

local function saveFlow(flow, filepath)
    if flow then
        local object = buildFlowObject(flow)
        local str = json.encode(object)
        io.writefile(filepath, str)
    end
end

return saveFlow
