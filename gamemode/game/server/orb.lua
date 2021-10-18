--- [SERVER]
-- Class definition for an orb definition
--- OrbConquest, par0-git

--- Provides:
-- OrbDefinition, class

OrbDefinition = {
    --- Whether or not the orb controls damage
    damage = false,

    --- Whether or not the orb controls cooldowns
    cooldown = false,

    --- Whether or not the orb has a function activated by attacks
    hit_effect = false,

    --- Whether or not the orb has an active
    active = false,

    --- Update base weapon damage
    --- Should be overridden by orbs requiring it
    --- @param damage number: provided weapon damage
    --- @return number: new weapon damage
    updateDamage = function(ply, damage) return damage end,

    --- Update base weapon cooldown
    --- Should be overridden by orbs requiring it
    --- @param time number: provided weapon cooldown
    --- @return number: new weapon cooldown
    updateCooldown = function(ply, time) return time end,

    --- Activate on hit effect
    --- Should be overridden by orbs requiring it
    --- @param position Vector: position of hit effect
    onHitEffect = function(position) end,

    --- Action when first using orb
    --- Should be overridden by orbs requiring it
    onStart = function(ply) return end,

    --- Action when last using orb
    --- Should be overridden by orbs requiring it
    onEnd = function(ply) end,

    --- Active ability usable on orbs
    --- Used if .active == true
    --- Should be overridden by orbs requiring it
    onActive = function(ply) end,
}

--- Create a new OrbDefinition object
--- @param player Player: reference to Player controlling this orb
--- @return OrbDefinition: new object
function OrbDefinition:create()
    local object = {}
    setmetatable(object, self)
    self.__index = self
    return object
end