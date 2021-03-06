/datum/round_event_control/borer
	name = "Borer"
	typepath = /datum/round_event/borer
	weight = 15
	max_occurrences = 1

	earliest_start = 12000 // 20 Minutes

/datum/round_event/borer
	announceWhen = 3000 //Borers get 5 minutes till the crew tries to murder them.
	var/spawned = 0

/datum/round_event/borer/announce()
	if(spawned)
		priority_announce("Unidentified lifesigns detected coming aboard [station_name()]. Secure any exterior access, including ducting and ventilation.", "Lifesign Alert", 'sound/AI/aliens.ogg') //Borers seem like normal xenomorphs.


/datum/round_event/borer/start()

	var/list/vents = list()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/temp_vent in world)
		if(temp_vent.loc.z == ZLEVEL_STATION && !temp_vent.welded)
			var/datum/pipeline/temp_vent_parent = temp_vent.parents["p1"]
			if(temp_vent_parent.other_atmosmch.len > 20)
				vents += temp_vent

	if(!vents.len)
		return kill()

	var/total_humans = 0
	for(var/mob/living/carbon/human/H in mob_list)
		if(H.stat != DEAD)
			total_humans++

	total_borer_hosts_needed = round(6 + total_humans/7)

	for(var/borers = 0, borers < 3, borers++)
		var/obj/vent = pick_n_take(vents)
		var/list/candidates = get_candidates(BE_ALIEN, ALIEN_AFK_BRACKET)
		for(var/client/C in candidates)
			if(jobban_check_mob(C.mob, "borer") || !(C.prefs.toggles & MIDROUND_ANTAG))
				candidates -= C
		if(!candidates.len)
			return kill()
		var/client/C = pick(candidates)
		if(!C)
			return kill()

		var/mob/living/simple_animal/borer/borer = new(vent.loc)
		borer.transfer_personality(C)
		spawned = 1
		log_game("[borer]/([borer.ckey]) was spawned as a cortical borer.")