-- Money API
inventory_shops.money = {}

function inventory_shops.money.get_funds(player_name)
    return emeraldbank.get_emeralds(player_name)
end

function inventory_shops.money.transfer_funds(source_player_name, destination_player_name, amount)
    return emeraldbank.transfer_emeralds(source_player_name, destination_player_name, amount)
end