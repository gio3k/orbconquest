--- [SHARED]
-- Definitions for item classes
--- OrbConquest, par0-git

--- Provides:
-- InventoryItemType, enum; ItemRegistry, table

--- ItemRegistry
--- All item definitions are stored here on the server
--- On the client, items are only stored here after being fetched from the server for the first time
ItemRegistry = {}

InventoryItemType = {
    UNKNOWN = 0,
    GENERIC_ORB = 1,
    STRENGTH_ORB = 2,
    SUPPORT_ORB = 3,
    UTILITY_ORB = 4
}