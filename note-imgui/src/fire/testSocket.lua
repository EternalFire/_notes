
local _socket

local function testSocket(_input)
    local socket = require("socket")
    print(socket._VERSION)
    local sock = _socket

    if not _socket then
        local host = "127.0.0.1"
        local port = 12345
        sock = assert(socket.connect(host, port))
        sock:settimeout(0)
        _socket = sock
    end
      
    print("Press enter after input something:")
     
    local input, recvt, sendt, status
    -- while true do
        -- input = io.read()
        input = _input or "client start!!!"
        if #input > 0 then
            assert(sock:send(input .. "\n"))
        end
         
        recvt, sendt, status = socket.select({sock}, nil, 1)
        while #recvt > 0 do
            local response, receive_status = sock:receive()
            if receive_status ~= "closed" then
                if response then
                    print(response)
                    -- sock:close()
                    break
                    -- recvt, sendt, status = socket.select({sock}, nil, 1)
                end
            else
                break
            end
        end
    --   end
end

local function breakConnect()
    if _socket then
        _socket:close()
        _socket = nil
    end
end

return {testSocket, breakConnect}
