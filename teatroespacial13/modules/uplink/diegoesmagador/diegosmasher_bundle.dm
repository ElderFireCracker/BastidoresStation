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

    // Fase de preparação
    playsound(user, 'sound/effects/gravhit.ogg', 50, TRUE)
    user.Shake(3, 3, charge_time)

    if(!do_after(user, charge_time, user, timed_action_flags = IGNORE_USER_LOC_CHANGE))
        abort()
        return

    execute_jump(user)

/datum/action/cooldown/diegosmasher/skyfall/proc/execute_jump(mob/living/user)
    // Efeitos iniciais
    user.visible_message(span_danger("[user] salta para o alto!"))
    playsound(user, 'sound/weapons/gun/general/rocket_launch.ogg', 70, TRUE)

    // Estado durante o salto
    user.resistance_flags |= INDESTRUCTIBLE
    user.density = FALSE
    user.pass_flags |= PASSTABLE
    SET_PLANE(user, GAME_PLANE_UPPER_FOV_HIDDEN, user.loc)

    // Animação de subida
    animate(
        user,
        time = 1.5 SECONDS,
        easing = QUAD_EASING|EASE_IN,
        pixel_z = 400,
        alpha = 50,
        flags = ANIMATION_PARALLEL
    )

    addtimer(CALLBACK(src, PROC_REF(land), user), 1.5 SECONDS)
    StartCooldown()

/datum/action/cooldown/diegosmasher/skyfall/proc/land(mob/living/user)
    if(QDELETED(user))
        return

    var/turf/landing_spot = get_turf(user)

    // Resetar estado
    animate(user, alpha = 255, time = 8, easing = QUAD_EASING|EASE_IN, flags = ANIMATION_PARALLEL)
    animate(user, pixel_z = 0, time = 0.5 SECONDS, easing = QUAD_EASING|EASE_IN, flags = ANIMATION_PARALLEL)
    user.resistance_flags &= ~INDESTRUCTIBLE
    user.density = initial(user.density)
    user.pass_flags &= ~PASSTABLE

    // Efeitos de impacto
    playsound(landing_spot, 'sound/effects/explosion1.ogg', 100, TRUE)
    new /obj/effect/temp_visual/impact_effect(landing_spot)

    // Dano no ambiente
    for(var/turf/open/floor in spiral_range_turfs(5, landing_spot))
        if(prob(50))
            floor.break_tile()

    // Dano em mobs
    for(var/mob/living/victim in range(5, landing_spot))
        if(victim == user)
            continue

        victim.apply_damage(150, BRUTE, spread_damage = TRUE)
        victim.Knockdown(2 SECONDS)
        shake_camera(victim, 5, 5)

        if(victim.stat == CONSCIOUS)
            victim.visible_message(
                span_danger("[victim] é lançado longe pelo impacto!"),
                span_userdanger("O impacto me lança para longe!")
            )
            var/throw_dir = get_dir(user, victim)
            victim.throw_at(get_edge_target_turf(victim, throw_dir), 5, 3)
        else if(victim.stat != CONSCIOUS)
            victim.investigate_log("foi desintegrado pelo Skyfall de [user]", INVESTIGATE_DEATHS)
            victim.gib(FALSE, FALSE, FALSE)

        victim.adjustBruteLoss(80)

/datum/action/cooldown/diegosmasher/skyfall/proc/abort()
    owner.visible_message(
        span_warning("A preparação de [owner] é interrompida!"),
        span_danger("Preparação abortada!")
    )
    StartCooldown()
