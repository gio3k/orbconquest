--- [SERVER]
-- Test strength orb
--- OrbConquest, par0-git

include("../item.lua")
include("../orb.lua")

local orb = OrbDefinition:create()
local item = InventoryItem:create()

orb.damage = true
function orb:updateDamage(ply, damage)
    --local multiplier = ply:GetVelocity():Length() / ply:GetWalkSpeed()
    local multiplier = ply:GetVelocity():LengthSqr() / 40000
    return damage * multiplier
end

item.display = "Testing Orb"
item.name = "test_orb"
item.type = InventoryItemType.STRENGTH_ORB
item.data = orb

function item:getDescription()
    return "Damage dealt by user is multiplied by velocity multiplier."
end

table.insert(ItemRegistry, item)