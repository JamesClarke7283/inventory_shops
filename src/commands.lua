-- inventory_shops/src/commands.lua

-- /shop command
minetest.register_chatcommand("shop", {
    description = "Open the inventory shop.",
    func = function(player_name)
        local player = minetest.get_player_by_name(player_name)
        if player then
            inventory_shops.show_shop(player)
            inventory_shops.log_action(player_name .. " opened the shop.")
            return true
        else
            return false, "Player not found."
        end
    end,
})

-- /sell command
minetest.register_chatcommand("sell", {
    params = "<amount_of_item> <price>",
    description = "Sell the item in your hand for a price.",
    func = function(player_name, param)
        local amount_str, price_str = param:match("^(%d+)%s+(%d+)$")
        local amount = tonumber(amount_str)
        local price = tonumber(price_str)
        if not amount or not price then
            return false, "Invalid usage. Correct usage: /sell <amount_of_item> <price>"
        end

        local player = minetest.get_player_by_name(player_name)
        local itemstack = player:get_wielded_item()
        if itemstack:is_empty() then
            return false, "You must hold an item to sell."
        end

        if itemstack:get_count() < amount then
            return false, "You don't have enough items to sell."
        end

        local sell_stack = itemstack:take_item(amount)
        player:set_wielded_item(itemstack)
        local success, msg = inventory_shops.add_item_to_shop(player_name, sell_stack, price)
        if success then
            return true, msg
        else
            player:get_inventory():add_item("main", sell_stack) -- Return items
            return false, msg
        end
    end,
})

-- /unsell command
minetest.register_chatcommand("unsell", {
    params = "<modname:itemname> [amount]",
    description = "Remove items from your shop slots.",
    func = function(player_name, param)
        local item_name, amount_str = param:match("^(%S+)%s*(%d*)$")
        local amount = tonumber(amount_str) or math.huge

        if not item_name then
            return false, "Invalid usage. Correct usage: /unsell <modname:itemname> [amount]"
        end

        local success, msg = inventory_shops.remove_item_from_shop(player_name, item_name, amount)
        if success then
            return true, msg
        else
            return false, msg
        end
    end,
})

-- /change_price command
minetest.register_chatcommand("change_price", {
    params = "<modname:itemname> <new_price_per_single>",
    description = "Change the price of an item in your shop.",
    func = function(player_name, param)
        local item_name, new_price_str = param:match("^(%S+)%s+(%d+)$")
        local new_price = tonumber(new_price_str)

        if not item_name or not new_price then
            return false, "Invalid usage. Correct usage: /change_price <modname:itemname> <new_price_per_single>"
        end

        local success, msg = inventory_shops.change_item_price(player_name, item_name, new_price)
        if success then
            return true, msg
        else
            return false, msg
        end
    end,
})
