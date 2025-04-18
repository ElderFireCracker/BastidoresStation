/datum/action/changeling/panacea
	name = "Anatomic Panacea"
	desc = "Expels impurifications from our form; curing diseases, removing parasites, sobering us, purging chemicals and radiation, curing traumas and brain damage, and resetting our genetic code completely. Costs 20 chemicals." // monkestation edit
	helptext = "Lasts for a minute. Can be used while unconscious. Will purge helpful things as well. Maximum stack duration of 2 minutes." // monkestation edit
	button_icon_state = "panacea"
	chemical_cost = 20
	dna_cost = 1
	req_stat = HARD_CRIT

//Heals the things that the other regenerative abilities don't.
/datum/action/changeling/panacea/sting_action(mob/living/user) // monkestation edit
	//to_chat(user, span_notice("We cleanse impurities from our form."))
	..()
	user.apply_status_effect(/datum/status_effect/changeling_panacea) // monkestation addition
	/* MONKESTATION REMOVAL START
	var/list/bad_organs = list(
		user.get_organ_by_type(/obj/item/organ/internal/body_egg),
		user.get_organ_by_type(/obj/item/organ/internal/legion_tumour),
		user.get_organ_by_type(/obj/item/organ/internal/zombie_infection),
		user.get_organ_by_type(/obj/item/organ/internal/empowered_borer_egg), // MONKESTATION ADDITION -- CORTICAL_BORERS
	)

	for(var/o in bad_organs)
		var/obj/item/organ/O = o
		if(!istype(O))
			continue

		O.Remove(user)
		if(iscarbon(user))
			var/mob/living/carbon/C = user
			C.vomit(0)
		O.forceMove(get_turf(user))

	// MONKESTATION ADDITION START -- CORTICAL_BORERS
	var/mob/living/basic/cortical_borer/brain_pest = user.has_borer()
	if(brain_pest)
		brain_pest.leave_host()
	// MONKESTATION ADDITION END
	user.reagents.add_reagent(/datum/reagent/medicine/mutadone, 10)
	user.reagents.add_reagent(/datum/reagent/medicine/pen_acid, 20)
	user.reagents.add_reagent(/datum/reagent/medicine/antihol, 10)
	user.reagents.add_reagent(/datum/reagent/medicine/mannitol, 25)
	user.reagents.add_reagent(/datum/reagent/medicine/antipathogenic/changeling, 5) //MONKESTATION ADDITION

	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.cure_all_traumas(TRAUMA_RESILIENCE_LOBOTOMY)

	/*if(isliving(user)) //MONKESTATION REMOVAL: Virology rework
		var/mob/living/L = user
		for(var/thing in L.diseases)
			var/datum/disease/D = thing
			if(D.severity == DISEASE_SEVERITY_POSITIVE)
				continue
			D.cure()
	*/
	MONKESTATION REMOVAL END */
	return TRUE
