
local Type = require "Type"
local EdgeType = Type.EdgeType

---
--- if `_param` or `_param.type` is nil, create AutoNodeRet type edge object
--- _param is the same as Edge
---
--- createEdge()
--- createEdge{condition = "okok"}
---
local function createEdge(_param)
    if _flow_ and _flow_.edge_create_map then
        local param = _param

        if not param then
            param = {type = EdgeType.AutoNodeRet}
        elseif param.type == nil then
            param.type = EdgeType.AutoNodeRet
        end

        if param then
            local method_name = _flow_.edge_create_map[param.type]
            if method_name then
                local method = require("Edges."..method_name)
                if type(method) == "function" then
                    return method(param)
                else
                    print("-X- no edge create method. edge type = ", param.type)
                end
            else
                print("-X- no method name. edge type = ", param.type)
            end
        end
    end
end

return createEdge
