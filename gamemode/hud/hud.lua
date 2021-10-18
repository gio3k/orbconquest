--- [CLIENT]
-- HUD controller & drawing
--- OrbConquest, par0-git

include("helpers.lua") -- Provides: HudHelpers, table
include("heroselect.lua") -- Provides: HudHeroSelect, table
include("inventory.lua") -- Provides: HudInventory, table
include("indicators.lua") -- Provides: HudDamageIndicators, table
local drawStyledRectangle = HudHelpers.drawStyledRectangle

GameHud = {}
GameHudMaterials = {}

GameHudMaterials = {
    ICON_CURRENCY = Material("coins.png", "noclamp smooth"),
    FONT_GENERIC = surface.CreateFont("HUDGeneric", {
        font = "Righteous",
        extended = false,
        size = 25,
        blursize = 0,
        scanlines = 0,
        antialias = true
     })
}

--- Draw wait bar
--- @param x number: X location of middle of bar
--- @param y number: Y location of bottom of bar
--- @param scale number: Scale multiplier of bar (default 1.0x)
drawWaitingBar = function(x, y, scale)
    local rx, ry, width, height = drawStyledRectangle(
        x, y, -- Position
        350, 60, -- Size
        scale, -- Scale
        1, 1 -- Half step alignment (1 == middle, 2 == end)
    )

    -- Draw text
    draw.SimpleText(
        "Waiting for game to start", "HUDGeneric", 
        rx + (width / 2), 
        ry + (height / 2), 
        Color(120, 120, 120),
        TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
    )
end

GameHud = {
    --- Screen scaling
    scale = 1,
    ready = false
}

function GameHud:draw()
    -- Debug weapon hud
    local weapon = LocalPlayer():GetActiveWeapon()
    if (weapon ~= nil and weapon.Abilities ~= nil) then
        local y = 50
        for key, value in pairs(weapon.Abilities) do
            local status, cdr = value:getCooldownStatus()
            local color = Color(10, 255, 10)

            if (status) then
                color = Color(255, 0, 0)
            end

            draw.SimpleText(value.display .. " [" .. math.floor(cdr) .. " / " .. value.__cooldown_full_length .. "]", "TargetID", 50, y, color)
            y = y + 20
        end  
    end
    
    -- Make sure ClientMatch is ready
    if (ClientMatch == nil) then
        return
    end

    if (self.ready == false) then
        self.ready = true 
        self:create()
    end

    -- Draw damage indicators
    HudDamageIndicators:draw()

    -- Calculate screen scaling
    local padding = 50 * self.scale

    -- Draw a waiting for match bar if required
    if (ClientMatch.status == MatchStatus.PREPARING) then
        drawWaitingBar(ScrW() / 2, padding * 2, self.scale)
        return
    end

    if (ClientMatch.status == MatchStatus.ACTIVE) then
        return
    end
end

function GameHud:create()
    self.scale = ScrW() / 1920 -- TODO: make this better!
    
    -- Set up damage indicators
    HudDamageIndicators:create()
    
    -- Create hooks for opening menus, etc ...
    hook.Add("PlayerButtonDown", "OB:GameHud.0", function(ply, button)
        if SERVER then
            return -- Don't bother with server-side player button logic
        end

        if (!IsFirstTimePredicted()) then
            return
        end

        -- TODO: optimize this
        if (button == GetConVar("ob_key_inventory"):GetInt()) then
            -- Open inventory
            HudInventory:create(self.scale)
        end
    end)

    -- Hook for Hero Select start
    hook.Add("ObNetRequest", "OB:GameHud.1", function(request_code, data) 
        -- On request from server
        if (request_code == NetworkDefinitions.SCRequestCode.GAME_PROCEED_HERO_SELECT) then
            -- Server has opened hero selection
            HudHeroSelect:create(self.scale)
        end
    end)
end