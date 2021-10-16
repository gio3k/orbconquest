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

    --- Item modifiers [ItemDefinition]
    modifiers = {},

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

--- Calculate and return ability cooldown length
--- @return number: ability cooldown length in seconds
function AbilityController:getCooldownLength()
    if (CLIENT) then
        print("getCooldownLength can't be used client-side!")
        return 0
    end

    local cooldown = self.base_cooldown
    for _, item in ipairs(self.modifiers) do
        -- Check if item controls cooldowns
        if (item.cooldown) then
            cooldown = item.data.updateCooldown(self.ply, cooldown)
        end
    end
    return cooldown
end

--- Calculate and return ability damage
--- @return number: ability damage
function AbilityController:getDamage()
    local damage = self.base_damage
    for _, item in ipairs(self.modifiers) do
        -- Check if item controls damage
        if (item.damage) then
            damage = item.data.updateDamage(self.ply, damage)
        end
    end
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
        self.__cooldown_ready_time = CurTime() + self.base_cooldown 
    end
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