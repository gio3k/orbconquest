--- Server initialization
--- OrbConquest, par0-git

-- Send required files to client
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("hud/helpers.lua")
AddCSLuaFile("hud/hud.lua")
AddCSLuaFile("hud/heroselect.lua")
AddCSLuaFile("hud/inventory.lua")
AddCSLuaFile("hud/indicators.lua")
AddCSLuaFile("game/match_status.lua")
AddCSLuaFile("game/item_types.lua")
AddCSLuaFile("game/hero.lua")
AddCSLuaFile("game/ability.lua")
AddCSLuaFile("game/client/match.lua")
AddCSLuaFile("net/definitions.lua")
AddCSLuaFile("net/connection.lua")
AddCSLuaFile("visual/screenspace.lua")

-- Send required library files to client
AddCSLuaFile("external/dynmat/dyn.lua")
AddCSLuaFile("external/dynmat/vmt.lua")

-- Load shared file
include("shared.lua")

-- Load server-side game logic
include("game/server/match.lua") -- Provides: Match, class
include("game/server/item.lua") -- Provides: InventoryItem, class

-- Load items
include("game/server/items/test_orb.lua")
include("game/server/items/explosion.lua")

-- Create match
ServerMatch = Match:create()

function GM:PlayerInitialSpawn(ply)
    -- Hook might need to be changed to InitPostEntity.
	print("Player joined: "..ply:GetName())

    -- Update match
    ServerMatch:update()

    -- Start match
    
end
