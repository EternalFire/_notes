
local EdgeType = {
    AutoNodeRet = 1,  -- 根据返回值判断条件是否通过
    Custom = 10,
}

local NodeType = {
    Start = 1,
    End = 2, 
    SyncAction = 3,
    ASyncAction = 4,
}

--- Node执行后的返回值
local NodeActRet = {
    GoodJob = true,
    Failure = false,    
}

return {
    EdgeType = EdgeType, 
    NodeType = NodeType, 
    NodeActRet = NodeActRet
}
