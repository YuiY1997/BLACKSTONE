/obj/item/melee/touch_attack
	name = "\improper outstretched hand"
	desc = ""
	var/catchphrase = "High Five!"
	var/on_use_sound = null
	var/obj/effect/proc_holder/spell/targeted/touch/attached_spell
	icon = 'icons/obj/balloons.dmi'
	lefthand_file = 'icons/mob/inhands/misc/touchspell_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/touchspell_righthand.dmi'
	icon_state = "syndballoon"
	item_state = null
	item_flags = NEEDS_PERMIT | ABSTRACT | DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	force = 0
	throwforce = 0
	throw_range = 0
	throw_speed = 0
	var/charges = 1

/obj/item/melee/touch_attack/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)

/obj/item/melee/touch_attack/attack(mob/target, mob/living/carbon/user)
	if(!iscarbon(user)) //Look ma, no hands
		return
	if(!(user.mobility_flags & MOBILITY_USE))
		to_chat(user, "<span class='warning'>I can't reach out!</span>")
		return
	..()

/obj/item/melee/touch_attack/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	user.say(catchphrase, forced = "spell")
	playsound(get_turf(user), on_use_sound,50,TRUE)
	charges--
	if(charges <= 0)
		qdel(src)

/obj/item/melee/touch_attack/Destroy()
	if(attached_spell)
		attached_spell.on_hand_destroy(src)
	return ..()

/obj/item/melee/touch_attack/disintegrate
	name = "\improper smiting touch"
	desc = ""
	catchphrase = "EI NATH!!"
	on_use_sound = 'sound/blank.ogg'
	icon_state = "disintegrate"
	item_state = "disintegrate"

/obj/item/melee/touch_attack/disintegrate/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!proximity || target == user || !ismob(target) || !iscarbon(user) || !(user.mobility_flags & MOBILITY_USE)) //exploding after touching myself would be bad
		return
	if(!user.can_speak_vocal())
		to_chat(user, "<span class='warning'>I can't get the words out!</span>")
		return
	var/mob/M = target
	do_sparks(4, FALSE, M.loc)
	for(var/mob/living/L in view(src, 7))
		if(L != user)
			L.flash_act(affect_silicon = FALSE)
	var/atom/A = M.anti_magic_check()
	if(A)
		if(isitem(A))
			target.visible_message("<span class='warning'>[target]'s [A] glows brightly as it wards off the spell!</span>")
		user.visible_message("<span class='warning'>The feedback blows [user]'s arm off!</span>","<span class='danger'>The spell bounces from [M]'s skin back into your arm!</span>")
		user.flash_act()
		var/obj/item/bodypart/part = user.get_holding_bodypart_of_item(src)
		if(part)
			part.dismember()
		return ..()
	var/obj/item/clothing/suit/hooded/bloated_human/suit = M.get_item_by_slot(SLOT_ARMOR)
	if(istype(suit))
		M.visible_message("<span class='danger'>[M]'s [suit] explodes off of them into a puddle of gore!</span>")
		M.dropItemToGround(suit)
		qdel(suit)
		new /obj/effect/gibspawner(M.loc)
		return ..()
	M.gib()
	return ..()

/obj/item/melee/touch_attack/fleshtostone
	name = "\improper petrifying touch"
	desc = ""
	catchphrase = "STAUN EI!!"
	on_use_sound = 'sound/blank.ogg'
	icon_state = "fleshtostone"
	item_state = "fleshtostone"

/obj/item/melee/touch_attack/fleshtostone/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!proximity || target == user || !isliving(target) || !iscarbon(user)) //getting hard after touching myself would also be bad
		return
	if(!(user.mobility_flags & MOBILITY_USE))
		to_chat(user, "<span class='warning'>I can't reach out!</span>")
		return
	if(!user.can_speak_vocal())
		to_chat(user, "<span class='warning'>I can't get the words out!</span>")
		return
	var/mob/living/M = target
	if(M.anti_magic_check())
		to_chat(user, "<span class='warning'>The spell can't seem to affect [M]!</span>")
		to_chat(M, "<span class='warning'>I feel your flesh turn to stone for a moment, then revert back!</span>")
		..()
		return
	M.Stun(40)
	M.petrify()
	return ..()


/obj/item/melee/touch_attack/necrotic
	name = "necrotic touch"
	desc = ""
	catchphrase = "Dreadmaiden take you!"
	on_use_sound = 'sound/combat/riposte.ogg'
	icon_state = "necrotic"
	item_state = "necrotic"
	lefthand_file = 'icons/mob/inhands/misc/touchspell_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/touchspell_righthand.dmi'
	damtype = "brute"
	force = 25

/obj/item/melee/touch_attack/inflictwounds/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!proximity || target == user || !isliving(target) || !iscarbon(user))
		return
	if(!(user.mobility_flags & MOBILITY_USE))
		to_chat(user, "<span class='warning'>I can't reach out!</span>")
		return
	if(!user.can_speak_vocal())
		to_chat(user, "<span class='warning'>I can't get the words out!</span>")
		return
	var/mob/living/M = target
	if(M.anti_magic_check())
		to_chat(user, "<span class='warning'>The spell can't seem to affect [M]!</span>")
		to_chat(M, "<span class='warning'>You feel a cold, otherworldly grasp on your skin that quickly fades!</span>")
		..()
		return
	M.Jitter(40)
	M.adjust_bodytemperature(-15 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	M.adjustToxLoss(15)
	return ..()
