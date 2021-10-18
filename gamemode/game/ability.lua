--- [SHARED]
-- Class definition for a cooldown
--- OrbConquest, par0-git

--- Provides:
-- AbilityController, class; AbilityPosition, enum; AbilityRegistry, table

AbilityPosition = {
    PRIMARY = 1,
    SECONDARY = 2,
    PASSIVE = 3,
    ULTIMATE = 4
}

AbilityController = {
    --- Display name of the ability
    display = "",

    --- Identifier name of the ability
    name = "",

    --- Reference to player with this ability
    ply = nil,

    --- Linked items [OrbDefinition]
    items = {},

    --- Cooldown of ability before orb multipliers
    base_cooldown = 0,

    --- Damage of ability before orb multipliers
    base_damage = 0,

    --- Hidden variables
    --- Time cooldown was last reset
    __cooldown_timer_set = 0,
    --- Time ability will be off cooldown (CLIENT)
    __cooldown_ready_time = 0,
    --- Current cooldown of ability including modifiers (CLIENT)
    __cooldown_full_length = 0
}

--- [SERVER]
--- Add item to ability
--- @param item InventoryItem: item to add to ability
function AbilityController:addItem(item)
    table.insert(self.items, item)
end

--- [SERVER]
--- Remove item from ability using UID
--- @param uid number / string: Item UID
function AbilityController:removeItemByUid(uid)
    for index, item in pairs(self.items) do
        if (item.uid == uid) then
            -- Remove item
            table.remove(self.items, index)
            print("Removed item from AbilityController")
            return
        end
    end

    return nil
end

--- [SERVER]
--- Calculate and return ability cooldown length
--- @return number: ability cooldown length in seconds
function AbilityController:getCooldownLength()
    if (CLIENT) then
        print("getCooldownLength can't be used client-side!")
        return 0
    end

    local cooldown = self.base_cooldown
    for _, item in ipairs(self.items) do
        local orb = item.data
        -- Check if item controls cooldowns
        if (orb.cooldown) then
            cooldown = orb:updateCooldown(self.ply, cooldown)
        end
    end
    return cooldown
end

--- [SERVER]
--- Activate orb on-hit effects
--- @param position Vector: position of hit effect
function AbilityController:activateOnHit(position)
    for _, item in ipairs(self.items) do
        local orb = item.data
        -- Check if orb has on-hit effect
        if (orb.hit_effect) then
            orb:onHitEffect(position)
        end
    end
end

--- Calculate and return ability damage
--- @return number: ability damage
function AbilityController:getDamage()
    -- Will just return base damage on client side
    local damage = self.base_damage

    if (CLIENT) then
        return damage    
    end

    for _, item in ipairs(self.items) do
        local orb = item.data
        -- Check if item controls damage
        if (orb.damage) then
            damage = orb:updateDamage(self.ply, damage)
        end
    end
    print(damage)
    return damage
end

--- Calculate and return ability cooldown progress
--- @return number: ability cooldown progress in seconds
function AbilityController:getCooldownProgress()
    if (SERVER) then
        return CurTime() - self.__cooldown_timer_set
    else
        -- Client-side cooldown
        return self.__cooldown_full_length - (self.__cooldown_ready_time - CurTime())
    end
end

--- Check if ability is on cooldown
--- @return boolean: whether or not the ability is on cooldown
--- @return number: ability cooldown progress in seconds
function AbilityController:getCooldownStatus()
    local progress = self:getCooldownProgress()
    if (SERVER) then
        return progress < self:getCooldownLength(), progress
    else
        -- Client-side cooldown
        return CurTime() < self.__cooldown_ready_time, progress
    end
end

--- Calculate and return ability cooldown progress
--- @return number: ability cooldown progress in seconds 
function AbilityController:resetCooldownProgress()
    -- The client uses Cooldown Ready Time (the time the cooldown will be ready)
    -- The server uses the time the ability was reset
    if (SERVER) then
        self.__cooldown_timer_set = CurTime()
    else
        -- Set predicted cooldown timer
        self:setClientReadyTime(CurTime() + self.base_cooldown)
        
        -- Request real timer from server
        send_request_to_server(NetworkDefinitions.CSRequestCode.HERO_ABILITY_CD_GET, self.name)
    end
end

--- [CLIENT]
--- Set __cooldown_ready_time
--- @param time number: New client ready time
function AbilityController:setClientReadyTime(time)
    -- I'd rather have a function set __cooldown_ready_time when used from outside this class so this exists
    self.__cooldown_ready_time = time
end

--- Create a new AbilityController object
--- @return AbilityController: new object
function AbilityController:create(ply)
    local object = {}
    setmetatable(object, self)
    self.__index = self
    object.ply = ply
    return object
end