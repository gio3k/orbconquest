--- [SERVER]
-- Test explosion orb
--- OrbConquest, par0-git

include("../item.lua")
include("../orb.lua")

local orb = OrbDefinition:create()
local item = InventoryItem:create()

orb.hit_effect = true

function orb:onHitEffect(position)
    -- Create explosion
    local effect = EffectData()
    effect:SetOrigin(position)
    
    -- Do explosion effect
    util.Effect("Explosion", effect, true, true)
end

item.display = "Explosion Orb"
item.name = "explode_orb"
item.type = InventoryItemType.STRENGTH_ORB
item.data = orb

function item:getDescription()
    return "test explosion orb :)"
end

table.insert(ItemRegistry, item)