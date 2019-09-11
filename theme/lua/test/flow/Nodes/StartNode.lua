
local Type = require "Type"
local NodeType = Type.NodeType

local Node = require "Node"

local function StartNode(param)
    return Node{type = NodeType.Start}
end

return StartNode
