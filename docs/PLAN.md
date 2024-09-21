# Inventory Shops
Adds Inventory Based Shops to minetest/mineclonia

## Commands

### `/shop`

A formspec, that allows players to purchase items in the global player shop where players have put items in.

### `/sell <amount_of_item> <price>`
Allows players to sell the current item in their hand for a price.

### `/unsell <modname:itemname> [amount]`
Returns the items in the shop of that name, to your inventory, if fits. Otherwise, just put the maximum number that will fit in your inventory.

### `/change_price <modname:name_of_item> <new_price_per_single>`
Enables you to change the price of an item in your shop.

### Shop features:

- Each item displays in colour, the text "left click to take 1", "shift-click to take up to [max_item_stack_for_item]"

- Displays the Player name that is selling the item in the item description.

- Left click automatically puts the item in the inventory is there is space, right click does the same.

- Players can search for items in the searchbar in the shop, you can also search by player name.

- Items from different players won't stack.

- Items are added left to right.

- The shop inventory is infinite, so new inventory pages are added when it gets full. You have "<" and ">" arrows with the page number in between those buttons. Buttons are grayed out unless "<" has previous page, ">" has next page.

- The shop inventory is stored globally as a detached inventory. and its global metadata is kept in modstorage.
- Each item has added metadata to it, like "invshops_owner" and "invshops_price" (which is the price for a single one of those items).

- An item from a single player stacks greater than the max stack limit. but different players with the same item sold are in different slots.

## Technicals
Emerald Bank API:

`emeraldbank.get_emeralds(player_name)` - Get amount of emeralds a named player has
`emeraldbank.transfer_emeralds(player1_name, player2_name, num)` - Transfers emeralds between players

Internal "Money" API(Makes it easy to make compatible with other mods later):

`inventory_shops.get_funds(player_name)`
`inventory_shops.transfer_funds(source_player_name, destination_player_name, amount)`

## Limits
Using settingstypes.txt, we define the max amount of slots in the store, a player can have, this defaults to 8 slots, but can be changed.
Players with the `inventory_shop_admin` priviledge, can populate as many slots as they want.

## Project structure
```
.
├── docs
│   └── PLAN.md
├── init.lua - entrypoint, runs the src/init.lua
├── LICENSE
├── mod.conf
├── README.md
└── src
    └── init.lua - entrypoint to the mod
```

# Extra

1. Make sure to break the relevent parts of the mod into seperate .lua files in `src`.
2. Log events as "ACTION" even verbose ones for now, as we are testing.