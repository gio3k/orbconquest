NetworkDefinitions = {}
NetworkDefinitions = {
    -- Client to server requests start with CS, and 
    -- Server to client requests start with SC

    -- Client -> server
    CSRequestCode = {
        UNKNOWN = 0,
        INVENTORY_GET = 4, -- Client asks server for client's current inventory
        INVENTORY_ITEM_DESCRIPTION_GET = 5, -- Client asks server for orb description [IN: orb name / identifier (string), OUT: orb description (string)]
        HERO_SELECT_PICK = 6, -- Client selects a hero [IN: hero name / identifier (string)]
        HERO_ABILITY_RCD_GET = 7 -- Client asks for cooldown of ability [IN: ability name / identifier (string), OUT: time cooldown is ready next, 0 for already ready (number)]
    },
    -- Server -> client
    SCRequestCode = {
        UNKNOWN = 0,
        GAME_PROCEED_HERO_SELECT = 1, -- Server notifying client that game is in hero selection
        GAME_PROCEED_ACTIVE = 2, -- Server notifying client that game is ready
        GAME_PROCEED_END = 3, -- Server notifying client that game is over
        HERO_ABILITY_CD_READY = 8 -- Server notifying client that cooldown is ready [IN: ability name / identifier (string)]
    },

    -- Response code
    ResponseCode = {
        UNKNOWN_RANGE = 0,
            UNKNOWN = 0,

        OK_RANGE = 50,
            OKGeneric = 50,

        FAIL_RANGE = 100,
            FailGeneric = 100
    }
}