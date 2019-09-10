
local Type = require "Type"
local NodeType = Type.NodeType

local function EndNode()
    return Node{type = NodeType.End}
end

return EndNode
