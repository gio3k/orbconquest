--- [SHARED]
-- Connection between client & server
--- OrbConquest, par0-git
--- All these functions are snake_case because they are global

include("definitions.lua") -- Provides: NetworkDefinitions, table

-- Generic Packet: (in bits)
-- [bool, 1]                    Request / Response (0 == request, 1 == response) 
-- [bool, 1]                    Data Inclusion (does the packet contain data?) 
-- [uint, 6]                    Request Code (if request this is the request code, if response this is the request code used to request this response)
-- [uint, 8] [response only]    Response Code
-- [...    ]                    Data (type, length & size are based on Request Code & Response Code)

-- Request Hook
-- 1: Request Code
-- 2: Data
-- 3: [SERVER] Player 

-- Response Hook
-- 1: Request Code
-- 2: Response Code
-- 3: Data
-- 4: [SERVER] Player

local generic_net_string = "ob_net_0" -- For generic requests
local generic_net_string_hook_r0 = "ObNetRequest"
local generic_net_string_hook_r1 = "ObNetResponse"

if (SERVER) then
    -- Precache network string
    util.AddNetworkString(generic_net_string)
end

--- Write required initial bits for a generic response packet
--- @param request_code number: Request asked to gain this response
--- @param response_code number: Response to send the server / client
--- @param data string: Data to send the server / client
function create_response(request_code, response_code, data)
    net.WriteBit(true) -- Request / Response == 1 == response
    net.WriteBit(data ~= nil)
    net.WriteUInt(request_code, 6) -- Request Code, 6 bit UInt
    net.WriteUInt(response_code, 8) -- Response Code, 8 bit UInt
    if (data ~= nil) then
        net.WriteString(data)
    end
end

--- Write required initial bits for a generic request packet
--- @param request_code number: Request to ask the server / client
--- @param data string: Data to send the server / client
function create_request(request_code, data)
    net.WriteBit(false) -- Request / Response == 0 == request
    net.WriteBit(data ~= nil)
    net.WriteUInt(request_code, 6) -- Request Code, 6 bit UInt
    if (data ~= nil) then
        net.WriteString(data)
    end
end

-- QoL functions: client
if (CLIENT) then
    --- Send a response to the server
    --- @param request_code number: Request asked to gain this response
    --- @param response_code number: Response to send the server / client
    --- @param data string: Data to send the server / client
    function send_response_to_server(request_code, response_code, data)
        net.Start(generic_net_string)
        create_response(request_code, response_code, data)
        net.SendToServer()
    end

    --- Send a request to the server
    --- @param request_code number: Request to ask the server / client
    --- @param data string: Data to send the server / client
    function send_request_to_server(request_code, data)
        net.Start(generic_net_string)
        create_request(request_code, data)
        net.SendToServer()
    end
else
-- QoL functions: server
    --- Send a response to all clients
    --- @param request_code number: Request asked to gain this response
    --- @param response_code number: Response to send the client
    --- @param data string: Data to send the client
    function broadcast_response(request_code, response_code, data)
        net.Start(generic_net_string)
        create_response(request_code, response_code, data)
        net.Broadcast()
    end

    --- Send a response to a specific client
    --- @param player Player: Client to send response to
    --- @param request_code number: Request asked to gain this response
    --- @param response_code number: Response to send the client
    --- @param data string: Data to send the client
    function send_response_to_client(player, request_code, response_code, data)
        net.Start(generic_net_string)
        create_response(request_code, response_code, data)
        net.Send(player)
    end

    --- Send a request to all clients
    --- @param request_code number: Request to ask the client
    --- @param data string: Data to send the client
    function broadcast_request(request_code, data)
        net.Start(generic_net_string)
        create_request(request_code, data)
        net.Broadcast()
    end

    --- Send a request to a specific client
    --- @param player Player: Client to send response to
    --- @param request_code number: Request to ask the client
    --- @param data string: Data to send the client
    function send_request_to_client(player, request_code, data)
        net.Start(generic_net_string)
        create_request(request_code, data)
        net.Send(player)
    end

    --- Send a request to the server (self)
    --- @param from_player Player: Player who "created" this request
    --- @param request_code number: Request to ask the server
    --- @param data string: Data to send the server
    function client_request_to_self(from_player, request_code, data)
        hook.Run(generic_net_string_hook_r0, request_code, data, from_player)
    end
end

-- Start handling connections
-- Generic network connections
net.Receive(generic_net_string, function(len, ply)
    local rr = net.ReadBit() -- Request / Response (0 == request, 1 == response) 
    local di = net.ReadBit() -- Data Inclusion
    local request_code = net.ReadUInt(6) -- Request Code

    print(string.format("recieved! rr %d, di %d, rqc %d", rr, di, request_code))

    if (SERVER) then
        -- Recieved from client
        -- The 2nd argument (ply) can be used here
        if (rr == 0) then
            -- On request from client
            local data = net.ReadString()
            
            -- Run hooks
            hook.Run(generic_net_string_hook_r0, request_code, data, ply)
        else
            -- On response from client    
            local response_code = net.ReadUInt(8)
            local data = net.ReadString()
            
            -- Run hooks
            hook.Run(generic_net_string_hook_r1, request_code, response_code, data, ply)
        end

        hook.Run()
    else
        -- Recieved from server
        if (rr == 0) then
            -- On request from server
            local data = net.ReadString()
            
            -- Run hooks
            hook.Run(generic_net_string_hook_r0, request_code, data)
        else
            -- On response from server    
            local response_code = net.ReadUInt(8)
            local data = net.ReadString()
            
            -- Run hooks
            hook.Run(generic_net_string_hook_r1, request_code, response_code, data)
        end
    end
end)