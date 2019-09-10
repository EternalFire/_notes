
local Type = require "Type"
local EdgeType = Type.EdgeType
local NodeType = Type.NodeType
local NodeActRet = Type.NodeActRet


local type_create_map = {
    [NodeType.Start] = "StartNode",
    [NodeType.End] = "EndNode",
}

local function createNode(param)
    local p_type = param.type
    local method_name = type_create_map[p_type]
    if method_name then
        local method = require("Nodes."..method_name)
        if type(method) == "function" then
            return method(param)
        end
    end
end

return createNode
