
local Type = require "Type"
local NodeType = Type.NodeType

local ActType = {
    -- xxx = {type = NodeType.SyncAction, actType = "xxx"}, 
    -- yyy = {type = NodeType.ASyncAction, actType = "yyy"}, 

    WaitForSeconds = {type = NodeType.ASyncAction, actType = "WaitForSeconds"}, 
}

return ActType
