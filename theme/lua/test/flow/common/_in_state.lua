
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

return {
    _in_state = _in_state,
    _genFlowID = _genFlowID,
    _genNodeID = _genNodeID,
    _genEdgeID = _genEdgeID,
}
