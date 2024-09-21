-- inventory_shops/src/shop.lua

-- Initialize the shop inventory
local function initialize_shop_inventory()
    local inv = minetest.create_detached_inventory("inventory_shops:shop", {
        -- Prevent players from moving items within the shop inventory
        allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
            return 0
        end,
        -- Prevent players from putting items into the shop inventory
        allow_put = function(inv, listname, index, stack, player)
            return 0
        end,
        -- Prevent taking items directly from the shop inventory
        allow_take = function(inv, listname, index, stack, player)
            return 0
        end,
    })
    inv:set_size("items", 0)
    return inv
end

inventory_shops.shop_inventory = minetest.get_inventory({ type = "detached", name = "inventory_shops:shop" }) or initialize_shop_inventory()

-- Get player's number of slots used
function inventory_shops.get_player_slot_count(player_name)
    local count = 0
    local inv = inventory_shops.shop_inventory
    local size = inv:get_size("items")
    for i = 1, size do
        local stack = inv:get_stack("items", i)
        if not stack:is_empty() then
            local meta = stack:get_meta()
            if meta:get_string("invshops_owner") == player_name then
                count = count + 1
            end
        end
    end
    return count
end

-- Max slots per player from settings
inventory_shops.max_player_slots = tonumber(minetest.settings:get("inventory_shops.max_player_slots")) or 8

-- Add item to shop
function inventory_shops.add_item_to_shop(player_name, itemstack, price)
    local inv = inventory_shops.shop_inventory

    -- Check if player can add more items
    if not inventory_shops.is_admin(player_name) then
        local slots_used = inventory_shops.get_player_slot_count(player_name)
        if slots_used >= inventory_shops.max_player_slots then
            return false, "You have reached the maximum number of shop slots."
        end
    end

    -- Prepare item metadata
    local meta = itemstack:get_meta()
    meta:set_string("invshops_owner", player_name)
    meta:set_int("invshops_price", price)
    itemstack:set_meta(meta)

    -- Add item to shop
    inv:add_item("items", itemstack)
    inventory_shops.log_action(player_name .. " added item to shop: " .. itemstack:get_name() .. " x" .. itemstack:get_count() .. " for price " .. price)
    return true, "Item added to shop."
end

-- Remove item from shop
function inventory_shops.remove_item_from_shop(player_name, item_name, amount)
    local inv = inventory_shops.shop_inventory
    local size = inv:get_size("items")
    local removed = 0

    for i = 1, size do
        local stack = inv:get_stack("items", i)
        if not stack:is_empty() then
            local meta = stack:get_meta()
            if meta:get_string("invshops_owner") == player_name and stack:get_name() == item_name then
                local to_remove = math.min(amount - removed, stack:get_count())
                local stack_removed = stack:take_item(to_remove)
                inv:set_stack("items", i, stack)

                -- Add to player's inventory
                local player_inv = minetest.get_inventory({ type = "player", name = player_name })
                local leftover = player_inv:add_item("main", stack_removed)
                if not leftover:is_empty() then
                    -- If player's inventory is full, return the item to the shop
                    inv:add_item("items", leftover)
                    minetest.chat_send_player(player_name, "Your inventory is full. Could not remove all items.")
                    break
                end
                removed = removed + stack_removed:get_count()

                -- Break if done
                if removed >= amount then
                    break
                end
            end
        end
    end

    if removed > 0 then
        inventory_shops.log_action(player_name .. " removed item from shop: " .. item_name .. " x" .. removed)
        return true, "Removed " .. removed .. " items from shop."
    else
        return false, "No items found to remove."
    end
end

-- Change price of an item in the shop
function inventory_shops.change_item_price(player_name, item_name, new_price)
    local inv = inventory_shops.shop_inventory
    local size = inv:get_size("items")
    local changed = false

    for i = 1, size do
        local stack = inv:get_stack("items", i)
        if not stack:is_empty() then
            local meta = stack:get_meta()
            if meta:get_string("invshops_owner") == player_name and stack:get_name() == item_name then
                meta:set_int("invshops_price", new_price)
                stack:set_meta(meta)
                inv:set_stack("items", i, stack)
                changed = true
            end
        end
    end

    if changed then
        inventory_shops.log_action(player_name .. " changed price of item " .. item_name .. " to " .. new_price)
        return true, "Price changed successfully."
    else
        return false, "No items found to change price."
    end
end
