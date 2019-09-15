
local inState = require "_in_state"
local _genNodeID = inState._genNodeID

local Type = require "Type"
local EdgeType = Type.EdgeType
local NodeType = Type.NodeType
local NodeActRet = Type.NodeActRet

local function Node(param)
    if not param then return end

    local object = {}
    function object:init(param)
        local p_id = param.id
        local p_type = param.type
        local p_act_type = param.actType
        local p_name = param.name
        local p_text = param.text
        local p_data = param.data
        local p_onTick = param.onTick
        local p_onEnter = param.onEnter
        local p_onDone = param.onDone
        local p_flow_sm = param.flow_sm
        local p_flow_id = param.flow_id

        self.id = p_id or _genNodeID()
        self.name = p_name or string.format("Node_%s", self.id)
        self.text = p_text or ""
        self.type = p_type
        self.actType = p_act_type
        self.in_edge_ids = {}
        self.out_edge_ids = {}
        self.state = {
            ret = NodeActRet.Failure,
            data = p_data,
            flow_sm = p_flow_sm,
            flow_id = p_flow_id,
        }
        self.onTick = p_onTick
        self.onEnter = p_onEnter
        self.onDone = p_onDone

        local state_bak = {
            ret = clone(self.state.ret),
            data = clone(self.state.data),
            flow_id = nil,
        }

        if p_flow_sm then
            if p_flow_sm.flow then
                state_bak.flow_id = p_flow_sm.flow.id
            end
        else
            if p_flow_id then
                state_bak.flow_id = p_flow_id
            end
        end

        self.nodeObject = {
            self.id,         -- 1
            self.name or "", -- 2
            self.text or "", -- 3
            self.type,       -- 4
            self.actType,    -- 5
            state_bak,       -- 6
        }
    end
    function object:addEdge(isIn, edge_id)
        if isIn then
            uniqueInsert(self.in_edge_ids, edge_id)
        else
            uniqueInsert(self.out_edge_ids, edge_id)
        end
    end
    function object:clear()
        -- print(self.name, "call clear")
        self.ret = NodeActRet.Failure
        self.data = self.nodeObject[6].data
    end

    object:init(param)
    return object
end

return Node
