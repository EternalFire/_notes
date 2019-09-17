
local Type = require "Type"
local NodeType = Type.NodeType

local ActType = {
    -- xxx = {type = NodeType.SyncAction, actType = "xxx"},
    -- yyy = {type = NodeType.ASyncAction, actType = "yyy"},

    AtkNode = {type = NodeType.ASyncAction, actType = "AtkNode"},
    InputNode = {type = NodeType.ASyncAction, actType = "InputNode"},

}

return ActType
