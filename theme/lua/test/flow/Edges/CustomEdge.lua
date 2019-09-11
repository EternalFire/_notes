
local Type = require "Type"
local EdgeType = Type.EdgeType

local Edge = require "Edge"

---
--- example:
--- local edge_2 = createEdge{
---     type = EdgeType.Custom, 
---     checkCondition = function(edge, state, preState, node)
---         if node.state.ret == "okok" then
---             print("call edge_2 checkCondition ")
---             return true
---         end
---     end
--- }
local function CustomEdge(param)
    local _param = clone(param)
    _param.type = EdgeType.Custom

    return Edge(_param)
end

return CustomEdge
