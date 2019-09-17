
local inState = require "_in_state"
local _genFlowID = inState._genFlowID

local Type = require "Type"
local EdgeType = Type.EdgeType
local NodeType = Type.NodeType
local NodeActRet = Type.NodeActRet

local createEdge = require "createEdge"

local function Flow(param)
    -- if not param then return end

    local object = {}
    function object:init(param)
        local p_id = _genFlowID()

        if param and param.id then
            p_id = param.id
        end

        self.id = p_id
        self.name = string.format("Flow_%s", self.id)
        self.nodes = {}
        self.edges = {}
        self.state = {
            ret = NodeActRet.Failure
        }
        self.in_out_map = {}  -- self.in_out_map[InNodeID][OutNodeID] = {EdgeID, ...}
        self.nodeDict = {}
        self.edgeDict = {}
        self.start_node_id = nil
        self.end_node_id = nil
    end
    function object:setStart(start_node)
        if start_node then
            self.start_node_id = start_node.id
        end
    end
    function object:setEnd(end_node)
        if end_node then
            self.end_node_id = end_node.id
        end
    end
    function object:connect(from_node, to_node, edge)
        if from_node and to_node and edge then
            -- from
            if not self.nodeDict[from_node.id] then
                table.insert(self.nodes, from_node)
                self.nodeDict[from_node.id] = from_node
            end

            -- to
            if not self.nodeDict[to_node.id] then
                table.insert(self.nodes, to_node)
                self.nodeDict[to_node.id] = to_node
            end

            -- edge
            if not self.edgeDict[edge.id] then
                table.insert(self.edges, edge)
                self.edgeDict[edge.id] = edge
            end

            edge.in_node_id = from_node.id
            edge.out_node_id = to_node.id

            from_node:addEdge(false, edge.id)
            to_node:addEdge(true, edge.id)

            self.in_out_map[from_node.id] = self.in_out_map[from_node.id] or {}
            self.in_out_map[from_node.id][to_node.id] = self.in_out_map[from_node.id][to_node.id] or {}
            uniqueInsert(self.in_out_map[from_node.id][to_node.id], edge.id)
        end
    end
    function object:connectByID(from_node_id, to_node_id, edge_id)
        local from_node = self.nodeDict[from_node_id]
        local to_node = self.nodeDict[to_node_id]
        local edge = self.edgeDict[edge_id]
        self:connect(from_node, to_node, edge)
    end
    --- fast connect
    function object:con(from_node, to_node, condition)
        if from_node and to_node then
            local e = createEdge{condition = condition}
            self:connect(from_node, to_node, e)
        end
    end
    function object:delEdge(edge_id)
        -- todo
    end
    function object:delNode(node_id)
        -- todo
    end
    function object:clear()
        self.state.ret = NodeActRet.Failure

        for i, node in ipairs(self.nodes) do
            node:clear()
        end
    end
    function object:getFlowStr()
        -- dump(self.in_out_map, "in_out_map")
        local start_node = self.nodeDict[self.start_node_id]
        local end_node = self.nodeDict[self.end_node_id]
        local bufs = {}

        if start_node and end_node then        
            local visited = {}

            local function visit(node_id)
                local next_ids = {}
                local space_num = 0

                table.walk(visited, function(v, k)
                    if v then
                        space_num = space_num + 1
                    end
                end)

                if not visited[node_id] then
                    local from_node = self.nodeDict[node_id]
                    visited[node_id] = true

                    for to_node_id, edges in pairs(self.in_out_map[node_id] or {}) do
                        local to_node = self.nodeDict[to_node_id]
                        next_ids[#next_ids + 1] = to_node_id

                        for _, edge_id in pairs(edges or {}) do
                            local edge = self.edgeDict[edge_id]
                            local s = string.format("%s[%s]>[%s] via [%s]", 
                                string.rep(" ", space_num), 
                                from_node.name,
                                to_node.name,
                                edge.name
                            )
                            table.insert(bufs, s)
                        end
                    end
                end

                return next_ids
            end

            local next_ids = visit(self.start_node_id)
            
            while #next_ids ~= 0 do
                local next_id = next_ids[1]
                table.remove(next_ids, 1)
                table.insertto(next_ids, visit(next_id))
            end
        end

        return bufs
    end
    function object:printFlow()
        local bufs = self:getFlowStr()
        print(table.concat(bufs, "\n"))
    end

    object:init(param)
    return object
end

return Flow
