# AuctionHelper

This AddOn helps you transfer items through the neutral auction house.

Enter a player name in the GUI and click "Start".
This AddOn will automatically buy all auctions that were posted by this player.


## Preview

![Preview](/preview.jpg?raw=true "Preview")

## Misc Info

The character that is listing the items can use this macro to auction
all items in the main bag for 1 copper each:

	/run for i=1,16 do PickupContainerItem(0, i) ClickAuctionSellItemButton() StartAuction(1,1,120) end


Servers using the Nostalrius core have an anti-action sniping feature:
Actions are not visible by other players for 5 minutes.
Only players with the same IP address as the owner can see the action during these 5 minutes.
That's why it is safe to use this addon, even if it takes a longer time to find and buy auctions.
You will never get sniped.
