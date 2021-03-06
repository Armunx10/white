/*CONTENTS
General Computer
Security Computer
Comm Computer
ID Computer
Pod/Blast Doors computer
*/

/obj/machinery/Topic(href, href_list)
	..()
	if(stat & (NOPOWER|BROKEN))
		return 1
	if(usr.restrained() || usr.lying || usr.stat)
		return 1
	if (!(istype(usr, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		if (!istype(usr, /mob/living/silicon))
			usr << "\red You don't have the dexterity to do this!"
			return 1
	if ((!in_range(src, usr) || !istype(src.loc, /turf)) && !istype(usr, /mob/living/silicon))
		return 1
	src.add_fingerprint(usr)


	usr.log_m("Used topic [src.name], [dd_list2text(href_list," ")]")
	if(href_list["function"])
		var/datum/function/F = new
		F.name = href_list["function"]
		F.arg1 = href_list["arg1"]
		F.arg2 = href_list["arg2"]
		src.call_function(F)
	return 0

/obj/machinery/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/attack_hand(mob/user as mob)
	if(stat & (NOPOWER|BROKEN))
		return 1
	if(user.lying || user.stat)
		return 1
	if (!(istype(usr, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		if (!istype(user, /mob/living/silicon))
			usr << "\red You don't have the dexterity to do this!"
			return 1
	if ((!(in_range(src, user)) || !istype(src.loc, /turf)) && !istype(user, /mob/living/silicon))
		return 1
	if (ishuman(user))
		if(user.brainloss >= 60)
			for(var/mob/M in viewers(src, null))
				M << "\red [user] stares cluelessly at [src] and drools."
			return 1
		else if(prob(user.brainloss))
			user << "\red You momentarily forget how to use [src]."
			return 1

	src.add_fingerprint(user)


	user.log_m("Used [src.name]")

	return 0

/obj/machinery/computer/meteorhit(var/obj/O as obj)
	for(var/x in src.verbs)
		src.verbs -= x
	set_broken()
	var/datum/effect/system/harmless_smoke_spread/smoke = new /datum/effect/system/harmless_smoke_spread()
	smoke.set_up(5, 0, src)
	smoke.start()
	return

/obj/machinery/computer/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
			return
		if(2.0)
			if (prob(50))
				for(var/x in src.verbs)
					src.verbs -= x
				set_broken()
		if(3.0)
			if (prob(25))
				for(var/x in src.verbs)
					src.verbs -= x
				set_broken()
		else
	return

/obj/machinery/computer/blob_act()
	if (prob(50))
		for(var/x in src.verbs)
			src.verbs -= x
		set_broken()
		src.density = 0

/obj/machinery/computer
	var/broken_icon = ""
	var/off_icon = ""

/obj/machinery/computer/power_change()
	if(!istype(src,/obj/machinery/computer/security/telescreen))
		if(stat & BROKEN)
			icon_state = initial(icon_state)
			src.icon_state += "b"
			ul_SetLuminosity(0,0,2)

		else if(powered())
			icon_state = initial(icon_state)
			stat &= ~NOPOWER
			ul_SetLuminosity(brightnessred,brightnessgreen,brightnessblue)
		else
			spawn(rand(0, 15))
				//src.icon_state = "c_unpowered"
				icon_state = initial(icon_state)
				src.icon_state += "0"
				stat |= NOPOWER
				ul_SetLuminosity(0,0,0)

/obj/machinery/computer/process()
	if(stat & (NOPOWER|BROKEN))
		return 1
	use_power(250)

/obj/machinery/computer/proc/set_broken()
	icon_state = initial(icon_state)
	icon_state += "b"
	stat |= BROKEN

/obj/machinery/computer/attackby(I as obj, user as mob)
	if(istype(I, /obj/item/weapon/screwdriver) && circuit)
		playsound(src.loc, 'Screwdriver.ogg', 50, 1)
		if(do_after(user, 20))
			var/obj/structure/frame/computer/A = new /obj/structure/frame/computer( src.loc )
			var/obj/item/weapon/circuitboard/computer/M = new circuit( A )
			A.circuit = M
			A.anchored = 1
			for (var/obj/C in src)
				C.loc = src.loc
			if (src.stat & BROKEN)
				user << "\blue The broken glass falls out."
				new /obj/item/weapon/shard( src.loc )
				A.state = 3
				A.icon_state = "3"
			else
				user << "\blue You disconnect the monitor."
				A.state = 4
				A.icon_state = "4"
			del(src)
	else
		src.attack_hand(user)
	return


/obj/machinery/computer/card/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/card/attack_paw(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/card/attack_hand(var/mob/user as mob)
	if(..())
		return

	user.machine = src
	var/dat
	if (!( ticker ))
		return
	if (src.mode) // accessing crew manifest
		var/crew = ""
		for(var/datum/data/record/t in data_core.general)
			crew += "[t.fields["name"]] - [t.fields["rank"]]<br>"
		dat = "<tt><b>Crew Manifest:</b><br>Please use security record computer to modify entries.<br>[crew]<a href='?src=\ref[src];print=1'>Print</a><br><br><a href='?src=\ref[src];mode=0'>Access ID modification console.</a><br></tt>"
	else
		var/header = "<b>Identification Card Modifier</b><br><i>Please insert the cards into the slots</i><br>"

		var/target_name
		var/target_owner
		var/target_rank

		if(src.modify)
			target_name = src.modify.name
		else
			target_name = "--------"

		if(src.modify && src.modify.registered)
			target_owner = src.modify.registered
		else
			target_owner = "--------"

		if(src.modify && src.modify.assignment)
			target_rank = src.modify.assignment
		else
			target_rank = "Unassigned"

		header += "Target: <a href='?src=\ref[src];modify=1'>[target_name]</a><br>"

		var/scan_name
		if(src.scan)
			scan_name = src.scan.name
		else
			scan_name = "--------"

		header += "Confirm Identity: <a href='?src=\ref[src];scan=1'>[scan_name]</a><br>"
		header += "<hr>"

		var/body

		if (src.authenticated && src.modify)

			var/carddesc = "Registered: <a href='?src=\ref[src];reg=1'>[target_owner]</a><br>Assignment: [target_rank]"

			var/list/alljobs = get_all_jobs() + "Custom"
			var/jobs = ""
			for(var/job in alljobs)
				jobs += "<a href='?src=\ref[src];assign=[job]'>[dd_replacetext(job, " ", "&nbsp")]</a> " //make sure there isn't a line break in the middle of a job

			var/accesses = ""
			for(var/A in get_all_accesses())
				if(A in src.modify.access)
					accesses += "<a href='?src=\ref[src];access=[A];allowed=0'><font color=\"red\">[dd_replacetext(get_access_desc(A), " ", "&nbsp")]</font></a> "
				else
					accesses += "<a href='?src=\ref[src];access=[A];allowed=1'>[dd_replacetext(get_access_desc(A), " ", "&nbsp")]</a> "

			body = "[carddesc]<br>[jobs]<br><br>[accesses]"

		else
			body = "<a href='?src=\ref[src];auth=1'>{Log in}</a>"

		dat = "<tt>[header][body]<hr><a href='?src=\ref[src];mode=1'>Access Crew Manifest</a><br></tt>"

	user << browse(dat, "window=id_com;size=700x375")
	onclose(user, "id_com")
	return
/obj/machinery/computer/card/call_function(datum/function/F)
	..()
	if(uppertext(F.arg1) != net_pass)
		var/datum/function/R = new()
		R.name = "response"
		R.source_id = address
		R.destination_id = F.source_id
		R.arg1 += "Incorrect Access token"
		send_packet(src,F.source_id,R)
	if (F.name == "modify")
		if (src.modify)
			src.modify.name = text("[]'s ID Card ([])", src.modify.registered, src.modify.assignment)
			src.modify.loc = src.loc
			src.modify = null
	if(F.name == "access")
		var/access_type = text2num(F.arg1)
		if(access_type in get_all_accesses())
			src.modify.access -= access_type
			src.modify.access += access_type
	if (F.name == "assign")
		if (src.authenticated)
			var/t1 = F.arg2
			if(!t1)
				return
			if(t1 in get_all_jobs())
				src.modify.access = get_access(t1)
			else
				src.modify.assignment = t1
	if (F.name == "reg")
		var/t1 = F.arg2
		if(!t1)
			return
		src.modify.registered = t1
	if (F.name == "print")
		if (!( src.printing ))
			src.printing = 1
			sleep(50)
			var/obj/item/weapon/paper/P = new /obj/item/weapon/paper( src.loc )
			var/t1 = "<B>Crew Manifest:</B><BR>"
			for(var/datum/data/record/t in data_core.general)
				t1 += "<B>[t.fields["name"]]</B> - [t.fields["rank"]]<BR>"
			P.info = t1
			P.name = "paper- 'Crew Manifest'"
			src.printing = null
	if (src.modify)
		src.modify.name = text("[]'s ID Card ([])", src.modify.registered, src.modify.assignment)
/obj/machinery/computer/card/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	if (href_list["modify"])
		if (src.modify)
			src.modify.name = text("[]'s ID Card ([])", src.modify.registered, src.modify.assignment)
			src.modify.loc = src.loc
			src.modify = null
		else
			var/obj/item/I = usr.equipped()
			if (istype(I, /obj/item/weapon/card/id))
				usr.drop_item()
				I.loc = src
				src.modify = I
		src.authenticated = 0
	if (href_list["scan"])
		if (src.scan)
			src.scan.loc = src.loc
			src.scan = null
		else
			var/obj/item/I = usr.equipped()
			if (istype(I, /obj/item/weapon/card/id))
				usr.drop_item()
				I.loc = src
				src.scan = I
		src.authenticated = 0
	if (href_list["auth"])
		if ((!( src.authenticated ) && (src.scan || (istype(usr, /mob/living/silicon))) && (src.modify || src.mode)))
			if (src.check_access(src.scan))
				src.authenticated = 1
		else if ((!( src.authenticated ) && (istype(usr, /mob/living/silicon))) && (!src.modify))
			usr << "You can't modify an ID without an ID inserted to modify. Once one is in the modify slot on the computer, you can log in."
	if(href_list["access"] && href_list["allowed"])
		if(src.authenticated)
			var/access_type = text2num(href_list["access"])
			var/access_allowed = text2num(href_list["allowed"])
			if(access_type in get_all_accesses())
				src.modify.access -= access_type
				if(access_allowed == 1)
					src.modify.access += access_type
	if (href_list["assign"])
		if (src.authenticated)
			var/t1 = href_list["assign"]
			if(t1 == "Custom")
				t1 = input("Enter a custom job assignment.","Assignment")
			else
				src.modify.access = get_access(t1)
			src.modify.assignment = t1
	if (href_list["reg"])
		if (src.authenticated)
			var/t2 = src.modify
			var/t1 = input(usr, "What name?", "ID computer", null)  as text
			if ((src.authenticated && src.modify == t2 && (in_range(src, usr) || (istype(usr, /mob/living/silicon))) && istype(src.loc, /turf)))
				src.modify.registered = t1
	if (href_list["mode"])
		src.mode = text2num(href_list["mode"])
	if (href_list["print"])
		if (!( src.printing ))
			src.printing = 1
			sleep(50)
			var/obj/item/weapon/paper/P = new /obj/item/weapon/paper( src.loc )
			var/t1 = "<B>Crew Manifest:</B><BR>"
			for(var/datum/data/record/t in data_core.general)
				t1 += "<B>[t.fields["name"]]</B> - [t.fields["rank"]]<BR>"
			P.info = t1
			P.name = "paper- 'Crew Manifest'"
			src.printing = null
	if (href_list["mode"])
		src.authenticated = 0
		src.mode = text2num(href_list["mode"])
	if (src.modify)
		src.modify.name = text("[]'s ID Card ([])", src.modify.registered, src.modify.assignment)
	src.updateUsrDialog()
	return

/obj/datacore/proc/manifest()
	for(var/mob/living/carbon/human/H in world)
		if (!isnull(H.mind) && (H.mind.assigned_role != "MODE"))
			var/datum/data/record/G = new /datum/data/record(  )
			var/datum/data/record/M = new /datum/data/record(  )
			var/datum/data/record/S = new /datum/data/record(  )
			var/obj/item/weapon/card/id/C = H.wear_id
			if (C)
				if(!H.mind.title)
					G.fields["rank"] = C.assignment
				else
					G.fields["rank"] = H.mind.title
			else
				G.fields["rank"] = "Unassigned"
			G.fields["name"] = H.real_name
			G.fields["id"] = text("[]", add_zero(num2hex(rand(1, 1.6777215E7)), 6))
			M.fields["name"] = G.fields["name"]
			M.fields["id"] = G.fields["id"]
			S.fields["name"] = G.fields["name"]
			S.fields["id"] = G.fields["id"]
			if (H.gender == FEMALE)
				G.fields["sex"] = "Female"
			else
				G.fields["sex"] = "Male"
			G.fields["age"] = text("[]", H.age)
			G.fields["fingerprint"] = text("[]", md5(H.dna.uni_identity))
			G.fields["p_stat"] = "Active"
			G.fields["m_stat"] = "Stable"
			M.fields["b_type"] = text("[]", H.b_type)
			M.fields["bloodsample"] = text("[]", H.dna.unique_enzymes)
			M.fields["mi_dis"] = "None"
			M.fields["mi_dis_d"] = "No minor disabilities have been declared."
			M.fields["ma_dis"] = "None"
			M.fields["ma_dis_d"] = "No major disabilities have been diagnosed."
			M.fields["alg"] = "None"
			M.fields["alg_d"] = "No allergies have been detected in this patient."
			M.fields["cdi"] = "None"
			M.fields["cdi_d"] = "No diseases have been diagnosed at the moment."
			M.fields["notes"] = "No notes."
			S.fields["criminal"] = "None"
			S.fields["mi_crim"] = "None"
			S.fields["mi_crim_d"] = "No minor crime convictions."
			S.fields["ma_crim"] = "None"
			S.fields["ma_crim_d"] = "No major crime convictions."
			S.fields["notes"] = "No notes."
			src.general += G
			src.medical += M
			src.security += S
		//Foreach goto(15)
	return

/obj/machinery/computer/pod/proc/alarm()
	if(stat & (NOPOWER|BROKEN))
		return

	if (!( src.connected ))
		viewers(null, null) << "Cannot locate mass driver connector. Cancelling firing sequence!"
		return
	for(var/obj/machinery/door/poddoor/M in machines)
		if (M.id == src.id)
			spawn( 0 )
				M.open()
				return
	sleep(20)

	//src.connected.drive()		*****RM from 40.93.3S
	for(var/obj/machinery/mass_driver/M in machines)
		if(M.id == src.id)
			M.power = src.connected.power
			M.drive()

	sleep(50)
	for(var/obj/machinery/door/poddoor/M in machines)
		if (M.id == src.id)
			spawn( 0 )
				M.close()
				return
	return

/obj/machinery/computer/pod/New()
	..()
	spawn( 5 )
		for(var/obj/machinery/mass_driver/M in machines)
			if (M.id == src.id)
				src.connected = M
			else
		return
	return

/obj/machinery/computer/pod/attackby(I as obj, user as mob)
	if(istype(I, /obj/item/weapon/screwdriver))
		playsound(src.loc, 'Screwdriver.ogg', 50, 1)
		if(do_after(user, 20))
			if (src.stat & BROKEN)
				user << "\blue The broken glass falls out."
				var/obj/structure/frame/computer/A = new /obj/structure/frame/computer( src.loc )
				new /obj/item/weapon/shard( src.loc )

				//generate appropriate circuitboard. Accounts for /pod/old computer types
				var/obj/item/weapon/circuitboard/computer/pod/M = null
				if(istype(src, /obj/machinery/computer/pod/old))
					M = new /obj/item/weapon/circuitboard/computer/olddoor( A )
					if(istype(src, /obj/machinery/computer/pod/old/syndicate))
						M = new /obj/item/weapon/circuitboard/computer/syndicatedoor( A )
					if(istype(src, /obj/machinery/computer/pod/old/swf))
						M = new /obj/item/weapon/circuitboard/computer/swfdoor( A )
				else //it's not an old computer. Generate standard pod circuitboard.
					M = new /obj/item/weapon/circuitboard/computer/pod( A )

				for (var/obj/C in src)
					C.loc = src.loc
				M.id = src.id
				A.circuit = M
				A.state = 3
				A.icon_state = "3"
				A.anchored = 1
				del(src)
			else
				user << "\blue You disconnect the monitor."
				var/obj/structure/frame/computer/A = new /obj/structure/frame/computer( src.loc )

				//generate appropriate circuitboard. Accounts for /pod/old computer types
				var/obj/item/weapon/circuitboard/computer/pod/M = null
				if(istype(src, /obj/machinery/computer/pod/old))
					M = new /obj/item/weapon/circuitboard/computer/olddoor( A )
					if(istype(src, /obj/machinery/computer/pod/old/syndicate))
						M = new /obj/item/weapon/circuitboard/computer/syndicatedoor( A )
					if(istype(src, /obj/machinery/computer/pod/old/swf))
						M = new /obj/item/weapon/circuitboard/computer/swfdoor( A )
				else //it's not an old computer. Generate standard pod circuitboard.
					M = new /obj/item/weapon/circuitboard/computer/pod( A )

				for (var/obj/C in src)
					C.loc = src.loc
				M.id = src.id
				A.circuit = M
				A.state = 4
				A.icon_state = "4"
				A.anchored = 1
				del(src)
	else
		src.attack_hand(user)
	return

/obj/machinery/computer/pod/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/pod/attack_paw(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/pod/attack_hand(var/mob/user as mob)
	if(..())
		return

	var/dat = "<HTML><BODY><TT><B>Mass Driver Controls</B>"
	user.machine = src
	var/d2
	if (src.timing)
		d2 = text("<A href='?src=\ref[];time=0'>Stop Time Launch</A>", src)
	else
		d2 = text("<A href='?src=\ref[];time=1'>Initiate Time Launch</A>", src)
	var/second = src.time % 60
	var/minute = (src.time - second) / 60
	dat += text("<HR>\nTimer System: []\nTime Left: [][] <A href='?src=\ref[];tp=-30'>-</A> <A href='?src=\ref[];tp=-1'>-</A> <A href='?src=\ref[];tp=1'>+</A> <A href='?src=\ref[];tp=30'>+</A>", d2, (minute ? text("[]:", minute) : null), second, src, src, src, src)
	if (src.connected)
		var/temp = ""
		var/list/L = list( 0.25, 0.5, 1, 2, 4, 8, 16 )
		for(var/t in L)
			if (t == src.connected.power)
				temp += text("[] ", t)
			else
				temp += text("<A href = '?src=\ref[];power=[]'>[]</A> ", src, t, t)
			//Foreach goto(172)
		dat += text("<HR>\nPower Level: []<BR>\n<A href = '?src=\ref[];alarm=1'>Firing Sequence</A><BR>\n<A href = '?src=\ref[];drive=1'>Test Fire Driver</A><BR>\n<A href = '?src=\ref[];door=1'>Toggle Outer Door</A><BR>", temp, src, src, src)
	//*****RM from 40.93.3S
	else
		dat += text("<BR>\n<A href = '?src=\ref[];door=1'>Toggle Outer Door</A><BR>", src)
	//*****
	dat += text("<BR><BR><A href='?src=\ref[];mach_close=computer'>Close</A></TT></BODY></HTML>", user)
	user << browse(dat, "window=computer;size=400x500")
	onclose(user, "computer")
	return

/obj/machinery/computer/pod/process()
	..()
	if (src.timing)
		if (src.time > 0)
			src.time = round(src.time) - 1
		else
			alarm()
			src.time = 0
			src.timing = 0
		src.updateDialog()
	return

/obj/machinery/computer/pod/Topic(href, href_list)
	if(..())
		return
	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.machine = src
		if (href_list["power"])
			var/t = text2num(href_list["power"])
			t = min(max(0.25, t), 16)
			if (src.connected)
				src.connected.power = t
		else
			if (href_list["alarm"])
				src.alarm()
			else
				if (href_list["time"])
					src.timing = text2num(href_list["time"])
				else
					if (href_list["tp"])
						var/tp = text2num(href_list["tp"])
						src.time += tp
						src.time = min(max(round(src.time), 0), 120)
					else
						if (href_list["door"])
							for(var/obj/machinery/door/poddoor/M in machines)
								if (M.id == src.id)
									if (M.density)
										spawn( 0 )
											M.open()
											return
									else
										spawn( 0 )
											M.close()
											return
								//Foreach goto(298)
		src.add_fingerprint(usr)
		src.updateUsrDialog()

	return

/obj/machinery/mass_driver/proc/drive(amount)
	if(stat & (BROKEN|NOPOWER))
		return
	use_power(500)
	var/O_limit
	var/atom/target = get_edge_target_turf(src, src.dir)
	for(var/atom/movable/O in src.loc)
		if(!O.anchored)
			O_limit++
			if(O_limit >= 20)
				for(var/mob/M in hearers(src, null))
					M << "\blue The mass driver lets out a screech, it mustn't be able to handle any more items."
				break
			use_power(500)
			spawn( 0 )
				O.throw_at(target, drive_range * src.power, src.power)
	flick("mass_driver1", src)
	return



