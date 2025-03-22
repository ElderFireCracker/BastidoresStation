/datum/uplink_item/kitsalve
	name = "Salve da Quebrada kit"
	desc = "I'm going to present you with a Salve Da Quebrada Kit \
			A little jacare to tie her little hand \
			A baseball bat to break her arm"
	item = /obj/item/storage/backpack/duffelbag/syndie/loadout/kitsalve
	cost = 16

/obj/item/storage/backpack/duffelbag/syndie/loadout/kitsalve/PopulateContents()
	new /obj/item/clothing/suit/jacket/leather(src)
	new /obj/item/melee/baseball_bat/ablative(src)
	new /obj/item/clothing/head/hats/imperial/grey(src)
	new /obj/item/clothing/glasses/gold_aviators(src)
	new /obj/item/razor(src)
	new /obj/item/melee/chainofcommand/tailwhip(src)
	new /obj/item/clothing/under/pants/track(src)
