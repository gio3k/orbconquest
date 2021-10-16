--- [CLIENT]
-- Helper functions for HUD drawing
--- OrbConquest, par0-git

HudHelpers = {
    --- Draw shadow as border
    --- @param x int: X location of first iteration of shadow
    --- @param y int: Y location of first iteration of shadow
    --- @param w int: Width of shadow
    --- @param h int: Height of shadow
    --- @param spread int: Spread of shadow
    --- @param start int: Initial iterator for shadow spread
    --- @param base Color: Base color of shadow
    --- @param fade Color: Color loss every iteration of spread
    --- @param scale number: Scale multiplier of health bar (default 1.0x)
    --- @param rounding int: Rounding amount of shadow. Not affected by scale.
    drawShadow = function(x, y, w, h, spread, start, base, fade, scale, rounding)
        local shadow_spread = spread or 15 -- Spread of shadow
        shadow_spread = shadow_spread * scale
        local shadow_start = start or 0 -- Initial iterator for shadow spread
        local shadow_base = base or Color(20, 20, 20, 60) -- Base color of shadow
        local shadow_fade = fade or Color(0, 0, 0, 5) -- Color loss every iteration of spread
        
        if rounding == 0 then
            -- Handle unrounded shadow
            local shadow_current_r, shadow_current_g, shadow_current_b, shadow_current_a = shadow_base:Unpack() -- Optimization

            for shadow_i = shadow_start, shadow_spread do
                surface.SetDrawColor(shadow_current_r, shadow_current_g, shadow_current_b, shadow_current_a)

                surface.DrawOutlinedRect(
                    x - shadow_i,
                    y - shadow_i,
                    w + shadow_i * 2,
                    h + shadow_i * 2,
                    1 -- Thickness
                )

                shadow_current_r = shadow_current_r - shadow_fade.r
                shadow_current_g = shadow_current_g - shadow_fade.g
                shadow_current_b = shadow_current_b - shadow_fade.b
                shadow_current_a = shadow_current_a - shadow_fade.a
            end
        else
            -- Handle rounded shadow
            local shadow_current = shadow_base
            for shadow_i = shadow_start, shadow_spread do
                -- Draw shadow
                draw.RoundedBox(
                    rounding,
                    x - shadow_i,
                    y - shadow_i,
                    w + shadow_i * 2,
                    h + shadow_i * 2,
                    shadow_current -- Color
                )

                -- Update color
                shadow_current.r = shadow_current.r - shadow_fade.r
                shadow_current.g = shadow_current.g - shadow_fade.g
                shadow_current.b = shadow_current.b - shadow_fade.b
                shadow_current.a = shadow_current.a - shadow_fade.a
            end
        end

        return (shadow_spread - shadow_start) * 2
    end,

    --- Draw a generic styled rectangle
    --- @param x int: X location of rectangle
    --- @param y int: Y location of rectangle
    --- @param w int: Width of rectangle
    --- @param h int: Height of rectangle
    --- @param scale number: Scale multiplier of health bar (default 1.0x)
    --- @param x_half_step number: 0 = start align, 1 = middle align, 2 = end align
    --- @param y_half_step number: 0 = start align, 1 = middle align, 2 = end align
    --- @param spread int: Spread of shadow
    --- @param start int: Initial iterator for shadow spread
    --- @return x, y, width, height
    drawStyledRectangle = function(x, y, w, h, scale, x_half_step, y_half_step, color, spread, start)
        scale = scale or 1.0 -- Default for scale
        x_half_step = x_half_step or 0
        y_half_step = y_half_step or 0
        color = color or Color(255, 255, 255, 190)
        spread = spread or 10
        start = start or 0

        local rounding = 15 * scale
        local width = w * scale
        local height = h * scale -- Height of utility bar
        local rect_x = x - ((width / 2) * x_half_step)
        local rect_y = y - ((height / 2) * y_half_step)

        -- Draw shadow
        HudHelpers.drawShadow(
            rect_x, rect_y, width, height, 
            spread, -- Spread
            start, -- Start
            Color(20, 20, 20, 60), -- Base 
            Color(0, 0, 0, 12), -- Fade
            scale, rounding
        )

        -- Draw main rectangle
        draw.RoundedBox(rounding, rect_x, rect_y, width, height, color)

        -- Return position & size
        return rect_x, rect_y, width, height
    end
}