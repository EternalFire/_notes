
local function createCmd()
    local Cmd = {
        Type = nil,
        histroy = nil,
        typeExecMap = {},
        typeUndoMap = {},
        typeParamFuncMap = {},
    }

    --- Command Type
    local Type = {}

    --[[
        < undo   redo >
                cur
        c1, c2, c3, c4, c5
    ]]
    local CommandHistory = {
        list = {},
        cur = 0,
        maxLen = 10,
    }

    Cmd.Type = Type
    Cmd.histroy = CommandHistory

    function Cmd:create(typeDef)
        local p = {}
        local createParamFunc = self.typeParamFuncMap[typeDef]
        if type(createParamFunc) == "function" then
            p = createParamFunc()
        end

        return {
            id = tostring(os.clock()):sub(1, 5),
            type = typeDef,
            param = p,
        }
    end


    function Cmd:check(command)
        if command and type(command) == "table" then
            return true
        end
        return false
    end

    function Cmd:checkUndo()
        return self.histroy.cur >= 1 and self.histroy.cur <= #self.histroy.list
    end

    function Cmd:checkRedo()
        return self.histroy.cur >= 0 and self.histroy.cur < #self.histroy.list
    end

    function Cmd:indexOfHistroy(command)
        if self:check(command) then
            local object
            for i = #self.histroy.list, 1, -1 do
                object = self.histroy.list[i]
                if object.id == command.id then
                    return i
                end
            end
        end
        return -1
    end

    function Cmd:addHistroy(command)
        if self:check(command) then
            if self.histroy.cur >= self.histroy.maxLen and self.histroy.maxLen > 0 then
                local firstCommand = self:getCommandByIndex(1)
                self:removeHistroy(firstCommand)
            end

            while self.histroy.cur < #self.histroy.list do
                print("remove index in histroy :", #self.histroy.list)
                table.remove(self.histroy.list, #self.histroy.list)
            end

            table.insert(self.histroy.list, command)
            self.histroy.cur = #self.histroy.list
        end
    end

    function Cmd:removeHistroy(command)
        if self:check(command) then
            local index = self:indexOfHistroy(command)
            if index ~= -1 then
                table.remove(self.histroy.list, index)
                self.histroy.cur = #self.histroy.list
            end
        end
    end

    function Cmd:clearHistroy()
        while #self.histroy.list > 0 do
            table.remove(self.histroy.list, 1)
        end
        self.histroy.cur = 0
    end

    function Cmd:getCurCommand()
        return self.histroy.list[self.histroy.cur]
    end

    function Cmd:getCommandByIndex(index)
        return self.histroy.list[index]
    end


    function Cmd:redo()
        local index = self.histroy.cur + 1
        local command = self:getCommandByIndex(index)
        return self:exec(command, false)
    end

    --- command is created by Cmd:create(cmdType)
    --- isRecord, add to histroy list
    ---@return boolean true: executed
    function Cmd:exec(command, isRecord)
        local executed = false
        if self:check(command) then
            if command.type ~= nil then
                -- do exec
                local func = self.typeExecMap[command.type]
                if func and type(func) == "function" then
                    executed = func(command)
                end
            end

            if executed then
                if isRecord then
                    self:addHistroy(command)
                else
                    self.histroy.cur = self.histroy.cur + 1
                end
            end
        end
        return executed
    end


    function Cmd:undo()
        local executed = false
        local command = self:getCurCommand()
        if self:check(command) then
            if command.type ~= nil then
                -- undo exec
                local func = self.typeUndoMap[command.type]
                if func and type(func) == "function" then
                    executed = func(command)
                end
            end

            if executed then
                self.histroy.cur = self.histroy.cur - 1
            end
        end
        return executed
    end

    function Cmd:addType(typeDef, execFunc, undoFunc, paramFunc)
        if typeDef and execFunc and undoFunc then
            if not self.Type[typeDef] then
                self.Type[typeDef] = true
                self.typeExecMap[typeDef] = execFunc
                self.typeUndoMap[typeDef] = undoFunc
                self.typeParamFuncMap[typeDef] = paramFunc
            end
        end
    end

    function Cmd:execute(typeDef, param)
        local command = self:create(typeDef)
        command.param = param
        return self:exec(command, true)
    end

    function Cmd:printBriefHistroy()
        print("cmd histroy len =", #self.histroy.list, "cur =", self.histroy.cur)
    end

    return Cmd
end



local function test()
    local cmd = createCmd()
    local CmdType_Add = "CmdType_Add"
    local CmdType_Mul = "CmdType_Mul"
    local CmdType_Add_ = "CmdType_Add_"

    local function CmdFunc_exec_Add(command)
        -- param.target.value = param.target.value + param.value
        local executed = false
        if command and command.param and command.param.target and command.param.value then
            local param = command.param
            local target = param.target
            local value = param.value
            param.target.value = param.target.value + param.value
            executed = true
        end
        return executed
    end

    local function CmdFunc_undo_Add(command)
        -- param.target.value = param.target.value - param.value
        local executed = false
        if command and command.param and command.param.target and command.param.value then
            local param = command.param
            local target = param.target
            local value = param.value
            param.target.value = param.target.value - param.value
            executed = true
        end
        return executed
    end

    local function CmdFunc_exec_Mul(command)
        local executed = false
        if command and command.param and command.param.getValue and command.param.setValue and command.param.value then
            local param = command.param
            local origin = param.getValue()
            param.setValue(origin * param.value)
            executed = true
        end
        return executed
    end
    local function CmdFunc_undo_Mul(command)
        local executed = false
        if command and command.param and command.param.getValue and command.param.setValue and command.param.value then
            local param = command.param
            local origin = param.getValue()
            param.setValue(origin / param.value)
            executed = true
        end
        return executed
    end

    local function CmdFunc_exec_Add_2(command)
        local executed = false
        if command and command.param and command.param.getValue and command.param.setValue and command.param.value then
            local param = command.param
            local origin = param.getValue()
            param.setValue(origin + param.value)
            executed = true
        end
        return executed
    end
    local function CmdFunc_undo_Add_2(command)
        local executed = false
        if command and command.param and command.param.getValue and command.param.setValue and command.param.value then
            local param = command.param
            local origin = param.getValue()
            param.setValue(origin - param.value)
            executed = true
        end
        return executed
    end


    cmd:addType(CmdType_Add, CmdFunc_exec_Add, CmdFunc_undo_Add)
    cmd:addType(CmdType_Mul, CmdFunc_exec_Mul, CmdFunc_undo_Mul)
    cmd:addType(CmdType_Add_, CmdFunc_exec_Add_2, CmdFunc_undo_Add_2)


    local state = { data = 0 }

    local param_Add = {
        target = { value = state.data },
        value = 100,
    }
    local param_Mul = {
        getValue = function() return state.data end,
        setValue = function(val) state.data = val end,
        value = 2,
    }
    local param_Add_ = {
        getValue = function() return state.data end,
        setValue = function(val) state.data = val end,
        value = 1,
    }

    ---------------------------------------------------------------
    print('1. before CmdType_Add execute')
    local ret = cmd:execute(CmdType_Add, param_Add)
    print("1. after CmdType_Add execute, return =", ret)
    if ret then
        print("param_Add.target.value =", param_Add.target.value)

        state.data = param_Add.target.value
    end
    print("state.data =", state.data)
    cmd:printBriefHistroy()

    ---------------------------------------------------------------
    print('2. before CmdType_Add undo(1)')
    ret = cmd:undo()
    print('2. after CmdType_Add undo(1), return =', ret)
    if ret then
        print('param_Add.target.value =', param_Add.target.value)
        state.data = param_Add.target.value
    end
    print('state.data =', state.data)
    cmd:printBriefHistroy()

    ---------------------------------------------------------------
    print("3. before CmdType_Add undo(2)")
    ret = cmd:undo()
    print('3. after CmdType_Add undo(2), return =', ret)
    cmd:printBriefHistroy()

    ---------------------------------------------------------------
    print('4. before CmdType_Add exec')
    param_Add.target.value = state.data
    param_Add.value = 1000
    ret = cmd:execute(CmdType_Add, param_Add)
    print('4. after CmdType_Add exec, return =', ret)
    if ret then
        state.data = param_Add.target.value
    end
    print('state.data =', state.data)
    cmd:printBriefHistroy()

    ---------------------------------------------------------------
    print('5. before CmdType_Mul exec')
    ret = cmd:execute(CmdType_Mul, param_Mul)
    print("5. after CmdType_Mul exec, return =", ret)
    print('state.data =', state.data)
    cmd:printBriefHistroy()

    ---------------------------------------------------------------
    print("6. undo")
    cmd:undo()
    print('state.data =', state.data)
    cmd:printBriefHistroy()

    ---------------------------------------------------------------
    print("7. loop add")
    for i = 1, 10 do
        print("  loop at", i)
        param_Add.target.value = state.data
        param_Add.value = 10
        ret = cmd:execute(CmdType_Add, param_Add)
        print(string.format('  after CmdType_Add exec[%d], return =', i), ret)
        if ret then
            state.data = param_Add.target.value
        end
        print("  state.data =", state.data)
        cmd:printBriefHistroy()
    end

    ---------------------------------------------------------------
    print("8. loop undo")
    param_Add.target.value = state.data
    for i = 1, #cmd.histroy.list * 2 do
        ret = cmd:undo()
        if ret then
            state.data = param_Add.target.value
            print("", i, 'param_Add.target.value =', param_Add.target.value, "state.data =", state.data)
            param_Add.target.value = state.data
        end
        cmd:printBriefHistroy()
    end
    print('8. after loop undo, state.data =', state.data)

    ---------------------------------------------------------------

    print("9. loop redo")
    param_Add.target.value = state.data
    for i = 1, #cmd.histroy.list do
        ret = cmd:redo()
        if ret then
            state.data = param_Add.target.value
            print('', i, 'param_Add.target.value =', param_Add.target.value, 'state.data =', state.data)
            param_Add.target.value = state.data
        end
        cmd:printBriefHistroy()
    end
    print('9. after loop redo, state.data =', state.data)

    ---------------------------------------------------------------
    print("10. two commands undo")

    param_Add_.value = 10000 - state.data
    ret = cmd:execute(CmdType_Add_, param_Add_)
    print("  after add, state.data = ", state.data)

    param_Mul.value = 3
    cmd:execute(CmdType_Mul, param_Mul)
    print('  after mul, state.data = ', state.data)

    for i = 1, 2 do
        ret = cmd:undo()
        print("", i, " undo result =", ret, "state.data =", state.data)
    end
    print("10. after two commands undo, state.data =", state.data)

    ---------------------------------------------------------------

    print("11. two commands redo")
    for i = 1, 2 do
        ret = cmd:redo()
        print("", i, " redo result =", ret, "state.data =", state.data)
    end
    print("11. after two commands redo, state.data =", state.data)

end

local _cmd_ = {
    createCmd = createCmd,
    test = test,
}

_cmd_.test()

return _cmd_
