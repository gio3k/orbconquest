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
                -- Set player hero to that hero
                self:setHero(hero)

                -- Send OK response to client
                send_response_to_client(self.ply, request_code, NetworkDefinitions.ResponseCode.OKGeneric)

                -- Increment ready count
                self.match:incrementReadyCount()
                return
            end
        end

        -- At this point the hero does not exist
        print("Client tried to pick invalid hero")
        print(self.ply)
        send_response_to_client(self.ply, request_code, NetworkDefinitions.ResponseCode.FailGeneric, "INVALID_PICK")
        return
    end
end

--- Set player hero to specified hero
--- If no hero is provided it will use the hero already set
--- @param hero HeroDefinition: Hero to set player to
function MatchPlayer:setHero(hero)
    if (hero == nil and self.hero == nil) then
        print("setHero was provided an invalid HeroDefinition and no fallback")
        return
    end

    if (hero ~= nil) then
        self.hero = hero
    end

    -- Remove weapons from player first
    self.ply:StripWeapons()

    -- Add new hero weapon to player
    self.ply:Give(self.hero.weapon)
end

--- Give player an item
--- @param item InventoryItem: Item to give player
function MatchPlayer:giveItem(item)
    print(item.name .. " new given item " .. item.uid) --- DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG (test printing item uid on give)
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

--- Get item by uid from inventory
--- @param uid string: Item to find by UID
--- @return InventoryItem: found item OR nil if nothing found
function MatchPlayer:getItemByUid(uid)
    for _, item in ipairs(self.inventory) do
        if (item.uid == uid) then
            return item
        end
    end

    return nil
end

--- Link item to ability from ability name and item UID
--- @param ability_name string: Weapon ability name / ID
--- @param item_uid string: Item to find by UID
function MatchPlayer:addItemToAbility(ability_name, item_uid)
    local weapon = self.ply:GetActiveWeapon()
    if (weapon == nil) then
        print("Tried to add item to uninitialized weapon!")
        return
    end

    if (weapon.Base ~= "hero_base") then
        print("Tried to add item to non OrbConquest weapon!")
        return
    end

    local ability = weapon:GetWeaponAbility(ability_name)
    local item = self:getItemByUid(item_uid)

    if (ability == nil) then
        print("Couldn't find ability by name " .. ability_name)
        return
    end

    if (item == nil) then
        print("Couldn't find item by UID " .. item_uid)
        return
    end

    -- Remove item from all abilities
    for _, ability in ipairs(weapon.Abilities) do
        ability:removeItemByUid(item.uid)
    end

    -- Add item to ability
    ability:addItem(item)
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
    object.ply = ply
    object.match = match
    return object
end