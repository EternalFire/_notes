
local Type = require "Type"
local NodeType = Type.NodeType

local Node = require "Node"

--- param.data is flow result
local function EndNode(param)
    return Node{type = NodeType.End}
end

return EndNode
