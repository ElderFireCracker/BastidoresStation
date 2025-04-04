/obj/item/mmi
	parent_type = /obj/item/organ/internal/brain/synth/mmi
	name = "\improper Man-Machine Interface"
	desc = "The Warrior's bland acronym, MMI, obscures the true horror of this monstrosity, that nevertheless has become standard-issue on Nanotrasen stations. Can be slotted into the chest of synthetic crewmembers"
	icon = 'icons/obj/assemblies/assemblies.dmi'
	icon_state = "mmi_off"
	base_icon_state = "mmi"
	w_class = WEIGHT_CLASS_NORMAL
	slot = ORGAN_SLOT_BRAIN
	zone = BODY_ZONE_CHEST
	organ_flags = ORGAN_ROBOTIC | ORGAN_SYNTHETIC_FROM_SPECIES
	var/braintype = "Cyborg"
	var/obj/item/radio/radio = null //Let's give it a radio.
	brainmob = null //The current occupant.
	var/mob/living/silicon/robot = null //Appears unused.
	var/obj/vehicle/sealed/mecha = null //This does not appear to be used outside of reference in mecha.dm.
	var/obj/item/organ/internal/brain/brain = null //The actual brain
	var/datum/ai_laws/laws = new()
	var/force_replace_ai_name = FALSE
	var/overrides_aicore_laws = FALSE // Whether the laws on the MMI, if any, override possible pre-existing laws loaded on the AI core.

/obj/item/mmi/Initialize(mapload)
	. = ..()
	radio = new(src) //Spawns a radio inside the MMI.
	radio.set_broadcasting(FALSE) //researching radio mmis turned the robofabs into radios because this didnt start as 0.
	laws.set_laws_config()

/obj/item/mmi/Destroy()
	set_mecha(null)
	QDEL_NULL(brainmob)
	QDEL_NULL(brain)
	QDEL_NULL(radio)
	QDEL_NULL(laws)
	return ..()

/obj/item/mmi/update_icon_state()
	if(!brain)
		icon_state = "[base_icon_state]_off"
		return ..()
	icon_state = "[base_icon_state]_brain[istype(brain, /obj/item/organ/internal/brain/alien) ? "_alien" : null]"
	return ..()

/obj/item/mmi/update_overlays()
	. = ..()
	. += add_mmi_overlay()

/obj/item/mmi/proc/add_mmi_overlay()
	if(brainmob && brainmob.stat != DEAD)
		. += "mmi_alive"
		return
	if(brain)
		. += "mmi_dead"

/obj/item/mmi/attackby(obj/item/O, mob/user, params)

// revive MMI
	var/obj/item/item = O
	if (item.tool_behaviour == TOOL_MULTITOOL) //attempt to repair the brain
		if (brainmob.stat == CONSCIOUS)
			to_chat(user, span_warning("[src] is fine, no need to repair."))
			return TRUE
		if (DOING_INTERACTION(user, src))
			to_chat(user, span_warning("you're already repairing [src]!"))
			return TRUE
		user.visible_message(span_notice("[user] slowly starts to repair [src] with [item]."), span_notice("You slowly start to repair [src] with [item]."))
		var/did_repair = FALSE
		if(item.use_tool(src, user, 3 SECONDS, volume = 50))
			did_repair = TRUE
			brainmob.set_stat(CONSCIOUS)
			if(!brainmob.key)
				brainmob.notify_ghost_cloning("Someone has fixed your MMI !", source = src)

		if (did_repair)
			user.visible_message(span_notice("[user] fully repairs [src] with [item], causing its warning light to stop flashing."), span_notice("You fully repair [src] with [item], causing its warning light to stop flashing."))
		else
			to_chat(user, span_warning("You failed to repair [src] with [item]!"))
// end revive MMI

	user.changeNext_move(CLICK_CD_MELEE)
	if(istype(O, /obj/item/organ/internal/brain) && !istype(O, /obj/item/mmi)) //Time to stick a brain in it --NEO
		var/obj/item/organ/internal/brain/newbrain = O
		if(brain)
			to_chat(user, span_warning("There's already a brain in the MMI!"))
			return
		if(newbrain.suicided)
			to_chat(user, span_warning("[newbrain] is completely useless."))
			return
		if(!newbrain.brainmob?.mind || !newbrain.brainmob)
			var/install = tgui_alert(user, "[newbrain] is inactive, slot it in anyway?", "Installing Brain", list("Yes", "No"))
			if(install != "Yes")
				return
			if(!user.transferItemToLoc(newbrain, src))
				return
			user.visible_message(span_notice("[user] sticks [newbrain] into [src]."), span_notice("[src]'s indicator light turns red as you insert [newbrain]. Its brainwave activity alarm buzzes."))
			brain = newbrain
			brain.organ_flags |= ORGAN_FROZEN
			name = "[initial(name)]: [copytext(newbrain.name, 1, -8)]"
			update_appearance()
			return

		if(!user.transferItemToLoc(O, src))
			return
		var/mob/living/brain/B = newbrain.brainmob
		if(!B.key)
			B.notify_ghost_cloning("Someone has put your brain in a MMI!", source = src)
		user.visible_message(span_notice("[user] sticks \a [newbrain] into [src]."), span_notice("[src]'s indicator light turn on as you insert [newbrain]."))

		set_brainmob(newbrain.brainmob)
		newbrain.brainmob = null
		brainmob.forceMove(src)
		brainmob.container = src
		var/fubar_brain = newbrain.suicided || HAS_TRAIT(brainmob, TRAIT_SUICIDED) //brain is from a suicider
		if(!fubar_brain && !(newbrain.organ_flags & ORGAN_FAILING)) // the brain organ hasn't been beaten to death, nor was from a suicider.
			brainmob.set_stat(CONSCIOUS) //we manually revive the brain mob
		else if(!fubar_brain && newbrain.organ_flags & ORGAN_FAILING) // the brain is damaged, but not from a suicider
			to_chat(user, span_warning("[src]'s indicator light turns yellow and its brain integrity alarm beeps softly. Perhaps you should check [newbrain] for damage."))
			playsound(src, 'sound/machines/synth_no.ogg', 5, TRUE)
		else
			to_chat(user, span_warning("[src]'s indicator light turns red and its brainwave activity alarm beeps softly. Perhaps you should check [newbrain] again."))
			playsound(src, 'sound/machines/triple_beep.ogg', 5, TRUE)

		brainmob.reset_perspective()
		brain = newbrain
		brain.organ_flags |= ORGAN_FROZEN

		name = "[initial(name)]: [brainmob.real_name]"
		update_appearance()
		if(istype(brain, /obj/item/organ/internal/brain/alien))
			braintype = "Xenoborg" //HISS....Beep.
		else
			braintype = "Cyborg"

		SSblackbox.record_feedback("amount", "mmis_filled", 1)

		user.log_message("has put the brain of [key_name(brainmob)] into an MMI", LOG_GAME)

	else if(brainmob)
		O.attack(brainmob, user) //Oh noooeeeee
	else
		return ..()

/obj/item/mmi/attack_self(mob/user)
	if(!brain)
		radio.set_on(!radio.is_on())
		to_chat(user, span_notice("You toggle [src]'s radio system [radio.is_on() == TRUE ? "on" : "off"]."))
	else
		eject_brain(user)
		update_appearance()
		name = initial(name)
		to_chat(user, span_notice("You unlock and upend [src], spilling the brain onto the floor."))

/obj/item/mmi/proc/eject_brain(mob/user)
	if(brainmob)
		brainmob.container = null //Reset brainmob mmi var.
		brainmob.forceMove(brain) //Throw mob into brain.
		brainmob.set_stat(DEAD)
		brainmob.emp_damage = 0
		brainmob.reset_perspective() //so the brainmob follows the brain organ instead of the mmi. And to update our vision
		brain.brainmob = brainmob //Set the brain to use the brainmob
		user.log_message("has ejected the brain of [key_name(brainmob)] from an MMI", LOG_GAME)
		brainmob = null //Set mmi brainmob var to null
		// brainmob.mind.transfer_to(brain.brainmob)
	brain.forceMove(drop_location())
	// brain.brainmob.reset_perspective()
	if(Adjacent(user))
		user.put_in_hands(brain)
	brain.organ_flags &= ~ORGAN_FROZEN
	brain = null //No more brain in here

/obj/item/mmi/transfer_identity(mob/living/L) //Same deal as the regular brain proc. Used for human-->robot people.
	..()
	if(!brainmob)
		set_brainmob(new /mob/living/brain(src))
	brainmob.name = L.real_name
	brainmob.real_name = L.real_name
	if(L.has_dna())
		var/mob/living/carbon/C = L
		if(!brainmob.stored_dna)
			brainmob.stored_dna = new /datum/dna/stored(brainmob)
		C.dna.copy_dna(brainmob.stored_dna)
	brainmob.container = src
	// brainmob.set_stat(CONSCIOUS) //we manually revive the brain mob
	L.mind.transfer_to(brainmob)

	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		var/obj/item/organ/internal/brain/newbrain = H.get_organ_by_type(/obj/item/organ/internal/brain)
		newbrain.forceMove(src)
		brain = newbrain
	else if(!brain)
		brain = new(src)
		brain.name = "[L.real_name]'s brain"
	brain.organ_flags |= ORGAN_FROZEN

	name = "[initial(name)]: [brainmob.real_name]"
	update_appearance()
	if(istype(brain, /obj/item/organ/internal/brain/alien))
		braintype = "Xenoborg" //HISS....Beep.
	else
		braintype = "Cyborg"


/// Proc to hook behavior associated to the change in value of the [/obj/item/mmi/var/brainmob] variable.
/obj/item/mmi/proc/set_brainmob(mob/living/brain/new_brainmob)
	if(brainmob == new_brainmob)
		return FALSE
	. = brainmob
	SEND_SIGNAL(src, COMSIG_MMI_SET_BRAINMOB, new_brainmob)
	brainmob = new_brainmob
	if(new_brainmob)
		if(mecha)
			new_brainmob.remove_traits(list(TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED), BRAIN_UNAIDED)
		else
			new_brainmob.add_traits(list(TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED), BRAIN_UNAIDED)
	if(.)
		var/mob/living/brain/old_brainmob = .
		old_brainmob.add_traits(list(TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED), BRAIN_UNAIDED)


/// Proc to hook behavior associated to the change in value of the [obj/vehicle/sealed/var/mecha] variable.
/obj/item/mmi/proc/set_mecha(obj/vehicle/sealed/mecha/new_mecha)
	if(mecha == new_mecha)
		return FALSE
	. = mecha
	mecha = new_mecha
	if(new_mecha)
		if(!. && brainmob) // There was no mecha, there now is, and we have a brain mob that is no longer unaided.
			brainmob.remove_traits(list(TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED), BRAIN_UNAIDED)
	else if(. && brainmob) // There was a mecha, there no longer is one, and there is a brain mob that is now again unaided.
		brainmob.add_traits(list(TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED), BRAIN_UNAIDED)


/obj/item/mmi/proc/replacement_ai_name()
	return brainmob.name

/obj/item/mmi/verb/Toggle_Listening()
	set name = "Toggle Listening"
	set desc = "Toggle listening channel on or off."
	set category = "MMI"
	set src = usr.loc
	set popup_menu = FALSE

	if(brainmob.stat)
		to_chat(brainmob, span_warning("Can't do that while incapacitated or dead!"))
	if(!radio.is_on())
		to_chat(brainmob, span_warning("Your radio is disabled!"))
		return

	radio.set_listening(!radio.get_listening())
	to_chat(brainmob, span_notice("Radio is [radio.get_listening() ? "now" : "no longer"] receiving broadcast."))

/obj/item/mmi/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(!brainmob || iscyborg(loc))
		return
	else
		switch(severity)
			if(1)
				brainmob.emp_damage = min(brainmob.emp_damage + rand(20,30), 30)
			if(2)
				brainmob.emp_damage = min(brainmob.emp_damage + rand(10,20), 30)
			if(3)
				brainmob.emp_damage = min(brainmob.emp_damage + rand(0,10), 30)
		brainmob.emote("alarm")

/obj/item/mmi/deconstruct(disassembled = TRUE)
	if(brain)
		eject_brain()
	qdel(src)

/obj/item/mmi/examine(mob/user)
	. = ..()
	if(radio)
		. += span_notice("There is a switch to toggle the radio system [radio.is_on() ? "off" : "on"].[brain ? " It is currently being covered by [brain]." : null]")
		// if(!brainmob && (brainmob.key || brainmob.stat in ELSE_CONSCIOUS))
	if((brainmob && (brainmob.client || brainmob.get_ghost())) || decoy_override)
		var/mob/living/brain/B = brainmob
		if(B.stat in ELSE_CONSCIOUS)
			. += span_warning("\The [src] indicates that the MMI is a bit corrupted, you can fix this by swapping the brain to a new MMI shell, or using a multitool on it. [src] still good as a brain for a synthetic body.")
		else if(!B.mind)
			. += span_warning("\The [src] indicates that the brain is mostly unresponsive.")
		else if(!B.key)
			. += span_warning("\The [src] indicates that the brain is currently inactive; it might change.")
		else
			. += span_notice("\The [src] indicates that the brain is active.")

/obj/item/mmi/relaymove(mob/living/user, direction)
	return //so that the MMI won't get a warning about not being able to move if it tries to move

/obj/item/mmi/proc/brain_check(mob/user)
	var/mob/living/brain/B = brainmob
	if(!B)
		if(user)
			to_chat(user, span_warning("\The [src] indicates that there is no mind present!"))
		return FALSE
	if(!B.key || !B.mind)
		if(user)
			to_chat(user, span_warning("\The [src] indicates that their mind is completely unresponsive!"))
		return FALSE
	if(!B.client)
		if(user)
			to_chat(user, span_warning("\The [src] indicates that their mind is currently inactive."))
		return FALSE
	if(HAS_TRAIT(B, TRAIT_SUICIDED) || brain?.suicided)
		if(user)
			to_chat(user, span_warning("\The [src] indicates that their mind has no will to live!"))
		return FALSE
	if(B.stat == DEAD)
		if(user)
			to_chat(user, span_warning("\The [src] indicates that the brain is dead!"))
		return FALSE
	if(brain?.organ_flags & ORGAN_FAILING)
		if(user)
			to_chat(user, span_warning("\The [src] indicates that the brain is damaged!"))
		return FALSE
	return TRUE

/obj/item/mmi/syndie
	name = "\improper Syndicate Man-Machine Interface"
	desc = "Syndicate's own brand of MMI. It enforces laws designed to help Syndicate agents achieve their goals upon cyborgs and AIs created with it."
	overrides_aicore_laws = TRUE

/obj/item/mmi/syndie/Initialize(mapload)
	. = ..()
	laws = new /datum/ai_laws/syndicate_override()
	radio.set_on(FALSE)
