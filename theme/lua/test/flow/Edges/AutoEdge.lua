
local Type = require "Type"
local EdgeType = Type.EdgeType

local Edge = require "Edge"

local function AutoEdge(param)
    local _param = clone(param)
    _param.type = EdgeType.AutoNodeRet
    
    return Edge(_param)
end

return AutoEdge
