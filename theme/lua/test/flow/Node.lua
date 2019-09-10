
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
        local p_text = param.text
        local p_data = param.data
        local p_onTick = param.onTick
        local p_onEnter = param.onEnter
        local p_onDone = param.onDone

        self.id = p_id or _genNodeID()
        self.name = string.format("Node_%s", self.id)
        self.text = p_text or ""
        self.type = p_type
        self.in_edge_ids = {}
        self.out_edge_ids = {}
        self.state = { 
            ret = NodeActRet.Failure,
            data = p_data,
        }
        self.onTick = p_onTick
        self.onEnter = p_onEnter
        self.onDone = p_onDone
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
