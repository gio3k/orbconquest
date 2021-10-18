--- [SERVER]
-- Slasher, test hero
--- OrbConquest, par0-git

include("../hero.lua")

local hero = HeroDefinition:create()

hero.display = "Slasher"
hero.name = "slasher"
hero.weapon = "weapon_hero_slasher"

table.insert(HeroRegistry, hero)