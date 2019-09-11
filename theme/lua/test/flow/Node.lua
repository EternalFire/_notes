
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
        }
        self.onTick = p_onTick
        self.onEnter = p_onEnter
        self.onDone = p_onDone

        self.nodeObject = {
            self.id,         -- 1
            self.name or "", -- 2
            self.text or "", -- 3
            self.type,       -- 4
            self.actType,    -- 5
            clone(self.state),-- 6
        }
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

return Node
