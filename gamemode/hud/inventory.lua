--- [CLIENT]
-- Inventory HUD elements
--- OrbConquest, par0-git

include("helpers.lua") -- Provides: HudHelpers, table
local drawShadow = HudHelpers.drawShadow
local drawStyledRectangle = HudHelpers.drawStyledRectangle

HudInventory = {}
HudInventory = {
    --- Used to fade in
    background_color = Color(255, 255, 255, 180),

    --- Used to enable GUI elements
    frame = nil
}

function HudInventory:createWindow(w, h, s)
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
        drawStyledRectangle(
            w / 2, h / 2, -- Position
            w - 20, h - 20, -- Size
            1, -- Scale
            1, 1, -- Half step alignment (1 == middle)
            self_0.background_color
        )
    end

    -- Test below
    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:Dock(FILL)

end

function HudInventory:requestUpdate()
    -- Request inventory update from the server
    send_request_to_server(NetworkDefinitions.CSRequestCode.INVENTORY_GET)
end

function HudInventory:create(scale)
    if (ClientMatch.status ~= MatchStatus.ACTIVE) then
        print("Attempted to open inventory while game is not active")
        return
    end

    if (self.frame == nil) then
        self:requestUpdate()
        gui.EnableScreenClicker(true)
        self:createWindow(1600, 900, scale)
    else
        -- If inventory already existed, remove it
        gui.EnableScreenClicker(false)
        self.frame:Close()
        self.frame = nil
        return
    end
end