--- [SERVER]
-- Slasher, test hero
--- OrbConquest, par0-git

include("../hero.lua")

local hero = HeroDefinition:create()

hero.display = "Slasher"
hero.name = "test_hero"
hero.weapon = "weapon_hero_slasher"

table.insert(HeroRegistry, hero)