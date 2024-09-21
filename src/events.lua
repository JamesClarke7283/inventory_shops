-- inventory_shops/src/events.lua

-- Example: Log when a player joins
minetest.register_on_joinplayer(function(player)
    local player_name = player:get_player_name()
    inventory_shops.log_action(player_name .. " has joined the game.")
end)

