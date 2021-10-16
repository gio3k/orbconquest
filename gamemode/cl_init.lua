--- Client initialization
--- OrbConquest, par0-git

-- Load shared file
include("shared.lua")

-- Set up screenspace effects
include("visual/screenspace.lua")

-- Load HUD
include("hud/hud.lua")
resource.AddFile("resource/fonts/Righteous-Regular.ttf")

-- Create client convars
CreateClientConVar("ob_key_inventory", "19", true, false)

-- Set up HUD hooks
function GM:HUDPaint()
    GameHud:draw()
end

function GM:HUDShouldDraw(name)
    if (name == "CHudHealth" or name == "CHudBattery" or name == "CHudDeathNotice" or name == "CHudWeaponSelection") then
		return false
	end
    return true 
end

-- Load hook
function GM:InitPostEntity()
	DynamicMaterials.handleAll()
end

-- Load client-side game logic
include("game/client/match.lua") -- Provides: ClientMatchInfo, class

-- Create match information container
ClientMatch = ClientMatchInfo:create()

