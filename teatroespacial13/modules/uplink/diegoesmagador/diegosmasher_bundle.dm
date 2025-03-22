/obj/item/storage/backpack/duffelbag/syndie/loadout/diegosmasher/PopulateContents()
    new /obj/item/autosurgeon/muscle(src)
    new /obj/item/autosurgeon/syndicate/nodrop(src)
    new /obj/item/autosurgeon/organ/syndicate/sandy(src)
    new /obj/item/autosurgeon/organ/shield_blade(src)
    new /obj/item/autosurgeon/syndicate/anti_stun(src)

/datum/action/cooldown/diegosmasher
    name = "Arasaka Mercenary"
    desc = "NONE LEAVE THE SLAUGHTERHOUSE, NOT ALIVE."
    button_icon_state = "stagger_group"
    cooldown_time = 45 SECONDS

/datum/action/cooldown/diegosmasher/skyfall
    name = "Skyfall"
    var/charge_time = 3 SECONDS
    var/static/list/impact_sounds = list(
        'sound/effects/explosion1.ogg',
        'sound/effects/explosion2.ogg'
    )

/datum/action/cooldown/diegosmasher/skyfall/Trigger(trigger_flags)
    if(!IsAvailable() || !owner)
        return FALSE

    var/mob/living/carbon/human/user = owner

    if(user.incapacitated())
        to_chat(user, span_warning("Não posso executar agora!"))
        return FALSE

    user.visible_message(
        span_danger("[user] começa a se concentrar..."),
        span_notice("Você inicia a preparação para o Skyfall!")
    )

    if(!do_after(user, charge_time, user, timed_action_flags = IGNORE_USER_LOC_CHANGE))
        abort()
        return FALSE

    execute_jump(user)
    return TRUE

/datum/action/cooldown/diegosmasher/skyfall/proc/execute_jump(mob/living/user)
    // Efeitos iniciais
    user.visible_message(span_danger("[user] salta para o alto!"))
    playsound(user, 'sound/weapons/gun/general/rocket_launch.ogg', 70, TRUE)

    // Estado durante o salto
    user.resistance_flags |= INDESTRUCTIBLE
    user.density = FALSE
    user.pass_flags |= PASSTABLE
    user.plane = GAME_PLANE_UPPER_FOV_HIDDEN

    // Animação de subida
    animate(user,
        time = 1.5 SECONDS,
        pixel_z = 400,
        alpha = 50,
        easing = QUAD_EASING|EASE_IN,
        flags = ANIMATION_PARALLEL
    )

    new /obj/effect/hotspot(get_turf(user))
    new /obj/effect/skyfall_landingzone(get_turf(user), user)

    addtimer(CALLBACK(src, PROC_REF(land), user), 1.5 SECONDS)
    StartCooldown()

/datum/action/cooldown/diegosmasher/skyfall/proc/land(mob/living/user)
    if(QDELETED(user))
        return

    var/turf/landing_spot = get_turf(user)

    // Resetar estado
    animate(user,
        time = 0.5 SECONDS,
        pixel_z = 0,
        alpha = 255,
        easing = BOUNCE_EASING|EASE_OUT,
        flags = ANIMATION_PARALLEL
    )

    user.resistance_flags &= ~INDESTRUCTIBLE
    user.density = initial(user.density)
    user.pass_flags &= ~PASSTABLE
    user.plane = initial(user.plane)

    apply_impact_effects(landing_spot)

/datum/action/cooldown/diegosmasher/skyfall/proc/apply_impact_effects(turf/landing_spot)
    // Efeitos de impacto
    playsound(landing_spot, pick(impact_sounds), 100, TRUE)
    new /obj/effect/temp_visual/impact_effect(landing_spot)

    // Dano ambiental
    for(var/turf/open/floor in spiral_range_turfs(3, landing_spot)) // Alcance reduzido
        if(prob(70))
            floor.break_tile()

    // Dano em mobs
    for(var/mob/living/victim in view(3, landing_spot))
        if(victim == owner)
            continue

        victim.apply_damage(80, BRUTE) // Dano balanceado
        victim.Knockdown(1 SECONDS)
        shake_camera(victim, 3, 2)

        if(victim.stat == CONSCIOUS)
            var/throw_dir = get_dir(landing_spot, victim)
            victim.throw_at(get_edge_target_turf(victim, throw_dir), 3, 2)
        else if(victim.stat == DEAD)
            victim.gib()

/datum/action/cooldown/diegosmasher/skyfall/proc/abort()
    if(!owner)
        return

    owner.visible_message(
        span_warning("A preparação de [owner] é interrompida!"),
        span_danger("Preparação abortada!")
    )
    StartCooldown()

/obj/effect/skyfall_landingzone/smasher
    var/mob/living/carbon/human/linked_user
    var/static/list/animation_easing = list(CIRCULAR_EASING, BOUNCE_EASING)

/obj/effect/skyfall_landingzone/smasher/Initialize(mapload, mob/living/carbon/human/user)
    . = ..()
    if(!user)
        return INITIALIZE_HINT_QDEL

    linked_user = user
    animate(src,
        alpha = 255,
        time = 1 SECONDS,
        easing = pick(animation_easing),
        flags = EASE_OUT
    )
    QDEL_IN(src, 1 SECONDS)
