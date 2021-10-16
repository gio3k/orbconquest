--- [SERVER]
-- Class definition for a single match
--- OrbConquest, par0-git

--- Provides:
-- Match, class

include("player.lua") -- Provides: MatchPlayer, class
include("../match_status.lua") -- Provides: MatchStatus, class

Match = {
    --- List of MatchPlayers
    players = {},

    --- Status of match
    status = MatchStatus.PREPARING,

    --- Amount of players ready
    ply_ready_count = 0
}

--- Begin the match
function Match:start()
    -- Proceed to Hero Selection
    self.status = MatchStatus.HERO_SELECT

    -- Notify all clients about Hero Selection
    broadcast_request(NetworkDefinitions.SCRequestCode.GAME_PROCEED_HERO_SELECT)
end

--- Create hooks
function Match:hook()
    hook.Add("ObNetRequest", "OB:Match.0", function(request_code, data, ply) 
        -- On request from client
        -- Give request to MatchPlayer that it's about
        if (ply.oc_matchplayer ~= nil) then
            ply.oc_matchplayer:recieve(request_code, data)
        else
            print("Player related to network request is not linked to a MatchPlayer. Updating Match instance...")
            self:update()
        end
    end)
end

--- Increment ply_ready_count and start the game if ready
function Match:incrementReadyCount()
    self.ply_ready_count = self.ply_ready_count + 1

    print("new ready count: "..self.ply_ready_count)
    print("player count: " .. #self.players)
    if (self.ply_ready_count >= #self.players) then
        -- Game should be started
        print("All players have selected a hero, changing status to active...")
        self.status = MatchStatus.ACTIVE

        -- Broadcast new status
        broadcast_request(NetworkDefinitions.SCRequestCode.GAME_PROCEED_ACTIVE)
    end
end

--- Update the Match object
function Match:update()
    -- Make sure that all engine players have a MatchPlayer instance
    for _, ply in ipairs(player.GetAll()) do
        if (ply.oc_matchplayer == nil) then
            -- No instance of MatchPlayer found, create a new one
            ply.oc_matchplayer = MatchPlayer:create(ply, self)

            -- Add instance to Match players table
            table.insert(self.players, ply.oc_matchplayer)

            print("Created MatchPlayer for player "..ply:GetName())
        end
    end
end

--- Create a new Match object
--- @return Match: new object
function Match:create()
    local object = {}
    setmetatable(object, self)
    self.__index = self
    object:hook()
    return object
end
