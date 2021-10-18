--- [CLIENT]
-- Damage indicators
--- OrbConquest, par0-git

HudDamageIndicators = {}
HudDamageIndicators = {
    current = {},
    initialIndicatorOpacity = 255 * 2,
    indicatorOpacityRemovalAmount = 1,
    indicatorRiseSpeed = 0.03,
    font = "DermaDefault",
    ready = false
}

function HudDamageIndicators:draw()
    if (self.ready ~= true) then
        return
    end

    self:updateIndicators()

    -- Iterate backwards
    for index = #self.current, 1, -1 do
        local indicator = self.current[index]
        local screen_point = indicator.location:ToScreen()

        draw.SimpleText(indicator.damage, self.font, screen_point.x, screen_point.y, Color(255, 255, 255, indicator.opacity))
    end
end

function HudDamageIndicators:updateIndicators()
    -- Iterate backwards
    for index = #self.current, 1, -1 do
        local indicator = self.current[index]

        -- Check if indicator should be removed
        if (indicator.opacity <= 0) then
            -- Should be removed
            table.remove(self.current, index)
            goto updateIndicators_continue -- Skip updating indicator
        end

        -- Decrease indicator opacity
        indicator.opacity = indicator.opacity - self.indicatorOpacityRemovalAmount

        -- Rise upwards (z)
        indicator.location[3] = indicator.location[3] + self.indicatorRiseSpeed
        
        ::updateIndicators_continue::
    end
end

function HudDamageIndicators:addIndicator(damage, x, y, z, type)
    local indicator = {}
    indicator.damage = damage
    indicator.location = Vector(x, y, z)
    indicator.type = type
    indicator.opacity = self.initialIndicatorOpacity
    table.insert(self.current, indicator)
end

function HudDamageIndicators:create()
    hook.Add("ObNetRequest", "OB:HudDamageIndicators.1", function(request_code, data) 
        -- On request from server
        if (request_code == NetworkDefinitions.SCRequestCode.DAMAGE_INDICATOR) then
            -- Server has sent damage indicator request
            local data_split = string.Split(data, ";") -- [damage amount (number); x (number); y (number); z (number); damage type (number)]
			local damage = tonumber(data_split[1])
			local x = tonumber(data_split[2])
            local y = tonumber(data_split[3])
            local z = tonumber(data_split[4])
            local type = tonumber(data_split[5])

            self:addIndicator(damage, x, y, z, type)
        end
    end)

    self.ready = true
end