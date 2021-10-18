--- [CLIENT]
-- Hero selection HUD elements
--- OrbConquest, par0-git

include("helpers.lua") -- Provides: HudHelpers, table
local drawShadow = HudHelpers.drawShadow
local drawStyledRectangle = HudHelpers.drawStyledRectangle

HudHeroSelect = {}
HudHeroSelect = {
    --- Used to fade in
    background_color = Color(255, 255, 255, 0),
    background_color_end_alpha = 180,

    --- Used to enable GUI elements
    frame = nil,

    --- Hook check
    hooked = false
}

function HudHeroSelect:createWindow(w, h, s)
    self.frame = vgui.Create("DFrame")
    self.frame:SetVisible(true)
    self.frame:SetDraggable(true)
    self.frame:SetTitle("") 
    self.frame:SetSize(w * s, h * s)
    self.frame:ShowCloseButton(true)
    self.frame:Center()

    local self_0 = self

    -- Override drawing original Derma window
    function self.frame:Paint(w, h)
        if (self_0.background_color.a < self_0.background_color_end_alpha) then self_0.background_color.a = self_0.background_color.a + 1 end

        drawStyledRectangle(
            w / 2, h / 2, -- Position
            w - 20, h - 20, -- Size
            1, -- Scale
            1, 1, -- Half step alignment (1 == middle)
            self_0.background_color
        )
    end

    -- Create buttons for selecting hero
    local Button = vgui.Create("DButton", self.frame)
    Button:SetText( "select correct hero (test_hero)" )
    Button:SetTextColor( Color(0,0,0) )
    Button:SetPos( 100, 100 )
    Button:SetSize( 200, 30 )
    Button.DoClick = function()
        send_request_to_server(NetworkDefinitions.CSRequestCode.HERO_SELECT_PICK, "test_hero")
    end

    local Button2 = vgui.Create("DButton", self.frame)
    Button2:SetText( "select invalid hero" )
    Button2:SetTextColor( Color(0,0,0) )
    Button2:SetPos( 100, 300 )
    Button2:SetSize( 200, 30 )
    Button2.DoClick = function()
        send_request_to_server(NetworkDefinitions.CSRequestCode.HERO_SELECT_PICK, "invalid!!!!!!")
    end

    -- Create buttons for selecting hero
    local Button3 = vgui.Create("DButton", self.frame)
    Button3:SetText( "select slasher" )
    Button3:SetTextColor( Color(0,0,0) )
    Button3:SetPos( 100, 500 )
    Button3:SetSize( 200, 30 )
    Button3.DoClick = function()
        send_request_to_server(NetworkDefinitions.CSRequestCode.HERO_SELECT_PICK, "slasher")
    end
end

function HudHeroSelect:create(scale)
    if (self.hooked == false) then
        self.hooked = true 
        HudHeroSelect:hook()
    end

    if (self.frame == nil) then
        gui.EnableScreenClicker(true)
        self:createWindow(1800, 1000, scale)
        self.frame:SetDeleteOnClose(true)
    else
        -- If hero select already existed, remove it
        gui.EnableScreenClicker(false)
        self.frame:Close()
        self.frame = nil
        return
    end
end

function HudHeroSelect:hook()
    -- Hook for Hero Select response
    hook.Add("ObNetResponse", "OB:HudHeroSelect.1", function(request_code, response_code, data) 
        -- On response from server
        if (request_code == NetworkDefinitions.CSRequestCode.HERO_SELECT_PICK) then
            print("rc!!: "..response_code)
            if (response_code ~= NetworkDefinitions.ResponseCode.OKGeneric) then
                Derma_Message("Failed to pick that hero", data, "OK")
                return
            end

            -- Remove window on OK pick
            if (self.frame ~= nil) then
                -- Calling .create while the window is open closes it and cleans
                HudHeroSelect:create(0)
            end
        end
    end)
end