-- Check if player has admin privilege
function inventory_shops.is_admin(player_name)
    return minetest.check_player_privs(player_name, { inventory_shop_admin = true })
end

-- Log action events
function inventory_shops.log_action(message)
    minetest.log("action", "[InventoryShops] " .. message)
end

