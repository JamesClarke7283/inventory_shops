-- inventory_shops/src/formspecs.lua

-- Build shop formspec
function inventory_shops.get_shop_formspec(player_name, page, search_query)
    local inv = inventory_shops.shop_inventory
    local total_items = inv:get_size("items")

    local items_per_row = 9  -- Increased from 8 to 9
    local rows = 6  -- Number of rows to display
    local items_per_page = items_per_row * rows
    local total_pages = math.max(1, math.ceil(total_items / items_per_page))
    page = math.max(1, math.min(page, total_pages))

    local start_index = (page - 1) * items_per_page

    -- Build the item list, applying search filters
    local formspec_item_list = ""
    local display_index = 0
    local shown_items = 0
    for i = 1, total_items do
        local stack = inv:get_stack("items", i)
        if not stack:is_empty() then
            local meta = stack:get_meta()
            local owner = meta:get_string("invshops_owner") or "Unknown"
            local price = meta:get_int("invshops_price") or 0
            local item_name = stack:get_name()
            local def = minetest.registered_items[item_name]
            local display_name = def and def.description or item_name

            -- Apply search filter
            if search_query == "" or display_name:lower():find(search_query:lower(), 1, true) or owner:lower():find(search_query:lower(), 1, true) then
                if display_index >= start_index and shown_items < items_per_page then
                    -- Add item slot to formspec (positions calculated for a 9x6 grid)
                    local col = shown_items % items_per_row
                    local row = math.floor(shown_items / items_per_row)
                    local tooltip_text = minetest.formspec_escape(display_name .. "\nSold by: " .. owner .. "\nPrice: " .. price .. " per item\nLeft-click to buy one\nShift+Left-click to buy up to stack")
                    formspec_item_list = formspec_item_list .. "item_image_button[" .. col .. "," .. (1 + row) .. ";1,1;" .. item_name .. ";" .. "item_" .. i .. ";" .. "]" ..
                                         "tooltip[item_" .. i .. ";" .. tooltip_text .. "]"
                    shown_items = shown_items + 1
                end
                display_index = display_index + 1
            end
        end
    end

    local formspec_height = 1 + rows + 1  -- Header + item rows + navigation buttons
    local formspec = "formspec_version[3]" ..
                     "size[" .. items_per_row .. "," .. formspec_height .. "]" ..
                     "label[0,0;Inventory Shop]" ..
                     "field[0.3,0.6;" .. (items_per_row - 2.3) .. ",1;search;;" .. minetest.formspec_escape(search_query or "") .. "]" ..
                     "button[" .. (items_per_row - 2) .. ",0.25;2,1;search_button;Search]" ..
                     "button_exit[" .. (items_per_row - 0.7) .. ",0.25;0.7,1;exit_button;X]" ..
                     formspec_item_list ..
                     "button[0," .. (formspec_height - 1) .. ";1,1;prev_page;<]" ..
                     "label[1," .. (formspec_height - 0.8) .. ";Page " .. page .. " of " .. total_pages .. "]" ..
                     "button[2," .. (formspec_height - 1) .. ";1,1;next_page;>]"
                     -- Removed player inventory lists

    return formspec
end

-- Show shop formspec
function inventory_shops.show_shop(player, page, search_query)
    local player_name = player:get_player_name()
    page = page or 1
    search_query = search_query or ""
    local formspec = inventory_shops.get_shop_formspec(player_name, page, search_query)
    minetest.show_formspec(player_name, "inventory_shops:shop", formspec)
end

-- Handle formspec input
minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "inventory_shops:shop" then return end
    local player_name = player:get_player_name()
    local page = tonumber(fields.page) or 1
    local search_query = fields.search or ""

    if fields.search_button then
        page = 1
        -- Update formspec with search query
        inventory_shops.show_shop(player, page, search_query)
        return
    elseif fields.prev_page then
        page = math.max(1, page - 1)
    elseif fields.next_page then
        page = page + 1
    elseif fields.quit then
        -- Player closed the formspec
        return
    end

    -- Check for item buttons
    for field_name, _ in pairs(fields) do
        if field_name:sub(1, 5) == "item_" then
            local index = tonumber(field_name:sub(6))
            if index then
                local inv = inventory_shops.shop_inventory
                local stack = inv:get_stack("items", index)
                if not stack:is_empty() then
                    local meta = stack:get_meta()
                    local owner = meta:get_string("invshops_owner") or "Unknown"
                    local price = meta:get_int("invshops_price") or 0
                    local item_name = stack:get_name()

                    local purchase_count = 1  -- Default to buying one item

                    -- Detect if Shift key is pressed
                    local shift_pressed = fields.key_pressed and fields.key_pressed:find("KEY_SHIFT")
                    if shift_pressed then
                        purchase_count = stack:get_count()
                    end

                    local total_price = price * purchase_count
                    local player_funds = inventory_shops.money.get_funds(player_name)

                    if player_funds >= total_price then
                        if owner == player_name then
                            minetest.chat_send_player(player_name, "You cannot purchase your own items.")
                        else
                            local success, msg = inventory_shops.money.transfer_funds(player_name, owner, total_price)
                            if success ~= false then
                                -- Prepare the purchased stack
                                local purchase_stack = ItemStack(item_name)
                                purchase_stack:set_count(purchase_count)

                                -- Remove items from shop inventory
                                local shop_stack = stack:take_item(purchase_count)
                                inv:set_stack("items", index, stack)

                                -- Add item to player's inventory
                                local leftover = player:get_inventory():add_item("main", purchase_stack)
                                if not leftover:is_empty() then
                                    -- If player's inventory is full, return the item to the shop
                                    stack:add_item(leftover)
                                    inv:set_stack("items", index, stack)
                                    minetest.chat_send_player(player_name, "Your inventory is full. Purchase partially failed.")
                                end

                                -- Messaging
                                minetest.chat_send_player(player_name, "You purchased " .. item_name .. " x" .. purchase_count .. " for " .. total_price .. ".")
                                inventory_shops.log_action(player_name .. " purchased " .. item_name .. " x" .. purchase_count .. " from " .. owner .. " for " .. total_price)

                                -- Notify the seller if online
                                local seller = minetest.get_player_by_name(owner)
                                if seller then
                                    minetest.chat_send_player(owner, player_name .. " purchased " .. item_name .. " x" .. purchase_count .. " from you for " .. total_price .. ".")
                                end
                            else
                                minetest.chat_send_player(player_name, "Transaction failed: " .. msg)
                            end
                        end
                    else
                        minetest.chat_send_player(player_name, "You do not have enough funds to purchase this item.")
                    end
                else
                    minetest.chat_send_player(player_name, "The item is no longer available.")
                end
            end
            break
        end
    end

    -- Update formspec
    inventory_shops.show_shop(player, page, search_query)
end)