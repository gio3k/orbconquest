--- [SERVER]
-- Class definition for a single player in a match
--- OrbConquest, par0-git

--- Provides:
-- MatchPlayer, class

MatchPlayer = {
    --- Reference to actual Player object
    ply = nil,

    --- Reference to Match containing this object
    match = nil,

    --- Reference to HeroDefinition
    hero = nil,

    --- Table of item definitions
    inventory = {}
}

--- Function called on recieval of data from client regarding player
--- @param request_code number: Request code recieved
--- @param data string: Data recieved
function MatchPlayer:recieve(request_code, data)
    if (request_code == NetworkDefinitions.CSRequestCode.INVENTORY_GET) then
        -- Client requested their inventory
        if (self.match.status == MatchStatus.PREPARING) then
            -- Can't send inventory while preparing match
            send_response_to_client(self.ply, request_code, NetworkDefinitions.ResponseCode.FailGeneric, "MATCH_PREPARING")
            return
        else
            -- Create a table to send to client
            local packet = {}
            
            for _, item in ipairs(self.inventory) do
                table.insert(packet, {
                    display = item.display,
                    name = item.name,
                    type = item.type,
                    description = item.getDescription()
                })
            end

            -- Send table to client
            send_response_to_client(self.ply, request_code, NetworkDefinitions.ResponseCode.OKGeneric, util.TableToJSON(packet))
        end
    end

    if (request_code == NetworkDefinitions.CSRequestCode.HERO_SELECT_PICK) then
        -- Client picked a hero
        if (self.match.status ~= MatchStatus.HERO_SELECT) then
            -- Not currently hero selection
            send_response_to_client(self.ply, request_code, NetworkDefinitions.ResponseCode.FailGeneric, "NOT_HERO_SELECT")
            return
        end

        -- Make sure selected hero exists
        for _, hero in ipairs(HeroRegistry) do
            if (hero.name == data) then
                -- Exists!
                -- Set player hero to that hero and then send OK response back
                self.hero = hero
                send_response_to_client(self.ply, request_code, NetworkDefinitions.ResponseCode.OKGeneric)
                self.match:incrementReadyCount()
                return
            end
        end

        -- At this point the hero does not exist
        print("Client tried to pick invalid hero")
        send_response_to_client(self.ply, request_code, NetworkDefinitions.ResponseCode.FailGeneric, "INVALID_PICK")
        return
    end
end

--- Give player an item
--- @param item InventoryItem: Item to give player
function MatchPlayer:giveItem(item)
    table.insert(self.inventory, item)
end

--- Give player an item using item identifier name
--- @param name string: Item name to find
function MatchPlayer:giveItemByName(name)
    for _, item in ipairs(ItemRegistry) do
        if (item.name == name) then
            self:giveItem(item)
            return -- Stop searching after item found
        end
    end
    print("Could not find item with name "..name)
end

--- Create a new MatchPlayer object
--- @param ply Player: reference to actual Player
--- @param match Match: reference to container match
--- @return MatchPlayer: new object
function MatchPlayer:create(ply, match)
    if ply == nil then 
        print("MatchPlayer constructor error: Provided ply == nil")
        return nil
    end

    if match == nil then
        print("MatchPlayer constructor error: Provided match == nil")
        return nil
    end

    local object = {}
    setmetatable(object, self)
    self.__index = self
    self.ply = ply
    self.match = match
    return object
end