
local Type = require "Type"
local NodeType = Type.NodeType

local ActType = {
    -- xxx = {type = NodeType.SyncAction, actType = "xxx"},
    -- yyy = {type = NodeType.ASyncAction, actType = "yyy"},

    EchoNode = {type = NodeType.SyncAction, actType = "EchoNode"},

    WaitForSeconds = {type = NodeType.ASyncAction, actType = "WaitForSeconds"},
}

-- todo
-- wait for signal
-- parallel and
-- parallel or
-- sequence

return ActType
