
local function init_flow_()
    dump(package.path, "package.path")
    
    require "flow.init"

    dump(_flow_)
end

return init_flow_
