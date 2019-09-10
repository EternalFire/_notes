
local EdgeType = {
    AutoNodeRet = 1,
    Custom = 10,
}

local NodeType = {
    Start = 1,
    End = 2, 
    SyncAction = 3,
    ASyncAction = 4,
}

local NodeActRet = {
    GoodJob = true,
    Failure = false,    
}

return {
    EdgeType = EdgeType, 
    NodeType = NodeType, 
    NodeActRet = NodeActRet
}
