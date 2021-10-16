--- [SHARED]
-- Enum for current match status
--- OrbConquest, par0-git

--- Provides:
-- MatchStatus, enum

MatchStatus = {
    PREPARING = 1, -- Match has not started yet
    HERO_SELECT = 2, -- Players are picking hero
    ACTIVE = 3 -- Match now active
}