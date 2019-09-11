
local Type = require "Type"
local NodeType = Type.NodeType

local Node = require "Node"

local function EndNode(param)
    return Node{type = NodeType.End}
end

return EndNode
