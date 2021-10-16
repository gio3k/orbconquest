--- [SERVER]
-- Test hero
--- OrbConquest, par0-git

include("../hero.lua")

local hero = HeroDefinition:create()

hero.display = "Testing Hero"
hero.name = "test_hero"

table.insert(HeroRegistry, hero)