--- [CLIENT]
-- Class definition for a single match on the client
-- Also contains player data for the client
--- OrbConquest, par0-git

--- Provides:
-- ClientMatchInfo, class

include("../match_status.lua") -- Provides: MatchStatus, class

ClientMatchInfo = {
    --- Status of match
    status = MatchStatus.PREPARING,

    --- Client inventory
    inventory = {}
}

function ClientMatchInfo:hook()
    hook.Add("ObNetRequest", "OB:ClientMatchInfo.0", function(request_code, data) 
        -- On request from server
        if (request_code == NetworkDefinitions.SCRequestCode.GAME_PROCEED_HERO_SELECT) then
            -- Server has started game!
            self.status = MatchStatus.HERO_SELECT
            print("Server has started hero select.")
        elseif (request_code == NetworkDefinitions.SCRequestCode.GAME_PROCEED_ACTIVE) then
            self.status = MatchStatus.ACTIVE
            print("Server has started game.")
        end
    end)

    hook.Add("ObNetResponse", "OB:ClientMatchInfo.1", function(request_code, response_code, data) 
        -- On response from server
        if (request_code == NetworkDefinitions.CSRequestCode.INVENTORY_GET) then
            if (response_code ~= NetworkDefinitions.ResponseCode.OKGeneric) then
                print("Server rejected INVENTORY_GET request. "..data)
                return
            end

            -- Successful response
            self.inventory = util.JSONToTable(data)
            PrintTable(self.inventory)
        end
    end)
end

--- Create a new ClientMatchInfo object
--- @return ClientMatchInfo: new object
function ClientMatchInfo:create()
    local object = {}
    setmetatable(object, self)
    self.__index = self
    object:hook()
    return object
end
