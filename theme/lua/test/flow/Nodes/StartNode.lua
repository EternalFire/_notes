
local Type = require "Type"
local NodeType = Type.NodeType

local function StartNode()
    return Node{type = NodeType.Start}
end

return StartNode
