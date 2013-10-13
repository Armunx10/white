/obj/item/device/flash
	name = "flash"
	icon_state = "flash"
	var/l_time = 1.0
	var/shots = 5.0
	throwforce = 5
	w_class = 1
	throw_speed = 4
	throw_range = 10
	flags = FPRINT | TABLEPASS | CONDUCT
	item_state = "electronic"
	var/status = 1
	origin_tech = "magnets=2;combat=1"

/obj/item/device/flash/light
	name = "flashlight"
	desc = "A hand-held emergency light."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "flashlight"
	item_state = "flashlight"
	flags = FPRINT | TABLEPASS | CONDUCT | ONBELT


/obj/item/device/flash/attack(mob/living/carbon/M as mob, mob/user as mob)
	if ((usr.mutations & CLUMSY) && prob(50))
		usr << "\red The flash slips out of your hand."
		usr.drop_item()
		return
	if (src.shots > 0)
		var/safety = null
		if (istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			if (istype(H.glasses, /obj/item/clothing/glasses/sunglasses) || (istype(H.head, /obj/item/clothing/head/helmet/welding) && !H.head:up))
				safety = 1
		if(isrobot(user))
			spawn(0)
				var/atom/movable/overlay/animation = new(user.loc)
				animation.layer = user.layer + 1
				animation.icon_state = "blank"
				animation.icon = 'mob.dmi'
				animation.master = user
				flick("blspell", animation)
				sleep(5)
				del(animation)
		if (!( safety ))
			if (M.client)
				if (status == 0)
					user << "\red The bulb has been burnt out!"
					return
				if (!( safety ) && status == 1)
					playsound(src.loc, 'flash.ogg', 100, 1)
					if(!(M.mutations & HULK))  M.weakened = 10
					if (prob(10))
						status = 0
						user << "\red The bulb has burnt out!"
						return
					if ((M.eye_stat > 15 && prob(M.eye_stat + 50)))
						flick("e_flash", M.flash)
						M.eye_stat += rand(1, 2)
					else
						flick("flash", M.flash)
						M.eye_stat += rand(0, 2)
					if (M.eye_stat >= 20)
						M << "\red You eyes start to burn badly!"
						M.disabilities |= 1
						if (prob(M.eye_stat - 20 + 1))
							M << "\red You go blind!"
							M.sdisabilities |= 1
					if(ticker.mode.name == "revolution")
						if(user.mind in ticker.mode:head_revolutionaries)
							ticker.mode:add_revolutionary(M.mind)

		for(var/mob/O in viewers(user, null))
			if(status == 1)
				O.show_message(text("\red [] blinds [] with the flash!", user, M))
	src.attack_self(user, 1)
	return

/obj/item/device/flash/attack_self(mob/living/carbon/user as mob, flag)
	if ((usr.mutations & CLUMSY) && prob(50))
		usr << "\red The flash slips out of your hand."
		usr.drop_item()
		return
	if ( (world.time + 600) > src.l_time)
		src.shots = 5
	if (src.shots < 1)
		user.show_message("\red *click* *click*", 2)
		return
	if (!(istype(usr, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		usr << "\red You don't have the dexterity to do this!"
		return
	src.l_time = world.time
	add_fingerprint(user)
	src.shots--
	playsound(src.loc, 'flash.ogg', 100, 1)
	flick("[icon_state]2", src)
	if(isrobot(user))
		spawn(0)
			var/atom/movable/overlay/animation = new(user.loc)
			animation.layer = user.layer + 1
			animation.icon_state = "blank"
			animation.icon = 'mob.dmi'
			animation.master = user
			flick("blspell", animation)
			sleep(5)
			del(animation)
	if (!( flag ))
		for(var/mob/living/carbon/M in oviewers(3, null))
			if (prob(50))
				if (locate(/obj/item/device/cloak, M))
					for(var/obj/item/device/cloak/S in M)
						S.active = 0
						S.icon_state = "shield0"
			if (M.client)
				var/safety = null
				if (istype(M, /mob/living/carbon/human))
					var/mob/living/carbon/human/H = M
					if (istype(H.glasses, /obj/item/clothing/glasses/sunglasses) || (istype(H.head, /obj/item/clothing/head/helmet/welding) && !H.head:up ))
						safety = 1
				if (!( safety ))
					flick("flash", M.flash)