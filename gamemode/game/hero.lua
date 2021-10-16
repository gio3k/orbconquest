--- [SHARED]
-- Class definition for a hero definition
--- OrbConquest, par0-git

--- Provides:
-- HeroDefinition, class; HeroRegistry, table

--- HeroRegistry
--- All hero definitions are stored here
HeroRegistry = {}

HeroDefinition = {
    --- Display name of hero
    display = "",

    --- Identifier name of hero
    name = "",

    --- Hero abilities [AbilityController]
    abilities = {}
}

--- Create a new HeroDefinition object
--- @return HeroDefinition: new object
function HeroDefinition:create()
    local object = {}
    setmetatable(object, self)
    self.__index = self
    return object
end