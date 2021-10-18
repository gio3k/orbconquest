--- Client & server post-initialization
--- OrbConquest, par0-git
GM.Name = "OrbConquest"
GM.Author = "par0-git"
GM.Website = "https://github.com/par0-git"

-- Load libraries
include("external/dynmat/dyn.lua")

-- Load networking 
include("net/connection.lua")

-- Load items
include("game/ability.lua") -- Provides: AbilityController, class

-- Load heroes
include("game/heroes/test_hero.lua")
include("game/heroes/slasher.lua")

function GM:Initialize()
    print("OrbConquest, par0-git@"..self.Website)

    DynamicMaterials.setLocation("gamemodes/orbconquest/content/materials/")

    if (SERVER) then
        DynamicMaterials.initServer()
    end
end