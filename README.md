# Inventory Shops
Adds Inventory Based Shops

## Commands

### `/shop`

A formspec where you can select to go to the playershop or servershop.

### `/playershop`, shorthand `/ps`

Allows players to purchase items in the global player shop where players have put items in.

### `/servershop`, shorthand `/ss`
Allows players to purchase items from the global server shop, where the server admin defines items and their prices.

### `/sell [amount_of_item] [price]`
Allows players to sell the current item in their hand for a price.

### Shop features:

- Each item displays in colour, the text "left click to take 1", "shift-click to take up to [max_item_stack_for_item]"

- Displays the Player name that is selling the item in the item description.

- Left click automatically puts the item in the inventory is there is space, right click does the same.

- Players can search for items in the searchbar.

- Items from different players won't stack.

- Items are added left to right.

- The shop inventory is infinite, so new inventory pages are added when it gets full. You have "<" and ">" arrows with the page number in between those buttons.

- The shop inventory is stored globally as a detached inventory. and its metadata is kept in modstorage.
- Each item has added metadata to it, like "invshops_owner" and "invshops_price" (which is the price for a single one of those items).

- An item from a single player stacks greater than the max stack limit. but different players with the same item sold are in different slots.
