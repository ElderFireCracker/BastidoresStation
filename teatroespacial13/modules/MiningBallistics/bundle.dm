/obj/item/storage/box/shotminer/PopulateContents()
	new /obj/item/ammo_box/advanced/s12gauge/hunter/miner(src)
	new /obj/item/gun/ballistic/shotgun/doublebarrel/miner(src)
	new /obj/item/storage/belt/bandolier(src)

/datum/voucher_set/mining/doublebarrelminer
    name = "Shotgun Miner Kit"
    description = "Clearly made for shooting monsters!"
    icon = 'icons/obj/weapons/guns/ballistic.dmi'
    icon_state = "dshotgun"
    set_items = list(
		/obj/item/storage/box/shotminer
		)

/obj/item/storage/box/smghunter/PopulateContents()
	new /obj/item/ammo_box/magazine/miecz/hunter (src)
	new /obj/item/ammo_box/magazine/miecz/hunter (src)
	new /obj/item/ammo_box/magazine/miecz/hunter (src)
	new /obj/item/gun/ballistic/automatic/xhihao_smg/no_mag/miner (src)

/datum/voucher_set/mining/smghunter
	name = "Smg miner"
	description = "Shooting monsters?..."
	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/xhihao_light_arms/guns32x.dmi'
	icon_state = "bogseo"
	set_items = list(
		/obj/item/storage/box/smghunter
	)
