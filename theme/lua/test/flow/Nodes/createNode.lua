
local Type = require "Type"
local EdgeType = Type.EdgeType
local NodeType = Type.NodeType
local NodeActRet = Type.NodeActRet

local Node = require "Node"
-- local type_create_map = {
--     [NodeType.Start] = "StartNode",
--     [NodeType.End] = "EndNode",
-- }

--- param is Node's param
local function createNode(param)
    if param then
        local type_create_map = _flow_.type_create_map
        local p_type = param.type
        local p_act_type = param.actType
        local method_name = type_create_map[p_type]

        if p_act_type ~= nil then
            local act_method_name = type_create_map[p_act_type]
            if not act_method_name then
                print("-X- act_method_name is null . p_act_type = ", p_act_type)
            else
                method_name = act_method_name
            end
        end

        if method_name then
            local method = require("Nodes."..method_name)

            if type(method) == "function" then
                return method(param)
            else
                print("-X- no create node method. method_name = ", method_name)
                return
            end
        end

        return Node(param)
    end
end

return createNode
