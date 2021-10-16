--- [SERVER]
-- Slasher, test hero
--- OrbConquest, par0-git

include("../hero.lua")

local hero = HeroDefinition:create()

hero.display = "Slasher"
hero.name = "test_hero"

table.insert(HeroRegistry, hero)