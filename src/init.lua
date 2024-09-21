local modpath = minetest.get_modpath("inventory_shops") .. "/src"

inventory_shops = {}
inventory_shops.modpath = modpath

-- Load modules
dofile(modpath .. "/money_api.lua")
dofile(modpath .. "/utils.lua")
dofile(modpath .. "/shop.lua")
dofile(modpath .. "/formspecs.lua")
dofile(modpath .. "/commands.lua")
dofile(modpath .. "/events.lua")
