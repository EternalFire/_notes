
local inState = require "_in_state"
local _genEdgeID = inState._genEdgeID

local Type = require "Type"
local EdgeType = Type.EdgeType
local NodeType = Type.NodeType
local NodeActRet = Type.NodeActRet

local function Edge(param)
    if not param then return end

    local object = {}
    function object:init(param)
        local p_id = param.id
        local p_type = param.type
        -- local p_in_node_id = param.in_node_id
        -- local p_out_node_id = param.out_node_id
        local p_checkCondition = param.checkCondition
        local p_condition = param.condition

        self.id = p_id or _genEdgeID()
        self.name = string.format("Edge_%s", self.id)
        self.type = p_type
        self.in_node_id = nil
        self.out_node_id = nil
        self.checkCondition = p_checkCondition
        self.condition = p_condition

        if p_condition == nil then
            self.condition = NodeActRet.GoodJob
        end
    end

    object:init(param)
    return object    
end

return Edge
