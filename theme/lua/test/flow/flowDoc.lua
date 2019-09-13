
local _doc = [[
    Flow tool:

        - Flow
            - id
            - name
            - Nodes
            - Edges
            - state
                - ret
            - in_out_map
            - nodeDict
            - edgeDict
            - start_node_id
            - end_node_id

        - Node
            - id
            - name
            - text
            - type
            - actType
            - in_edge_ids
            - out_edge_ids
            - state
                - ret
                - data
            - onTick()
            - onEnter()
            - onDone()

        - Edge
            - id
            - name
            - type
            - type: auto / custom
            - input_node_id(node id)
            - output_node_id(node id)
            - condition
            - checkCondition()

        - FlowStateMachine
            - flow
            - stateMachine
            - buildStateMachine()
            - createState()
            - _transferState()
            - start()
            - isFinish()
]]

return _doc
