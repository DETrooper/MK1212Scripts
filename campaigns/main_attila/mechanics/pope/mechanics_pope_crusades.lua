 ------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: POPE CRUSADES
-- 	By: DETrooper
--
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
-- System for crusades. Deus Vult!

-- Constants
CRUSADE_ANCILLARY_CHANCE_PER_TURN = 2;
CRUSADE_CANDIDATE_MIN_REGIONS = 4;
CRUSADE_DURATION = 20;
MAX_NUM_OF_CRUSADES = 9;
TURNS_BETWEEN_CRUSADES_MAX = 50;
TURNS_BETWEEN_CRUSADES_MIN = 20;

-- Variables
CRUSADE_ACTIVE = false;
CRUSADE_END_EVENT_OPEN = false;
CRUSADE_INTRO_CUTSCENE_PLAYED = false;
CURRENT_CRUSADE = 4;
CURRENT_CRUSADE_MISSION_KEY = "nil";
CURRENT_CRUSADE_TARGET = "nil";
CURRENT_CRUSADE_TARGET_OWNER = "nil";
CURRENT_CRUSADE_TARGET_OWNED_REGIONS = {};
CURRENT_CRUSADE_TARGET_PREEXISTING_ENEMIES = {};
CURRENT_CRUSADE_FACTIONS_JOINED = {};
CURRENT_CRUSADE_RECRUITABLE_UNITS = {};
CURRENT_CRUSADE_RECRUITABLE_UNITS_CAPS = {};
CRUSADE_DEFENSIVE_FORCES = {};
MISSION_TAKE_JERUSALEM_ACTIVE = false;
NEXT_CRUSADE_MESSAGE_TURN = -1;
NEXT_CRUSADE_START_TURN = -1;

function Add_Crusade_Event_Listeners()
	cm:add_listener(
		"FactionTurnStart_Pope_Crusades",
		"FactionTurnStart",
		true,
		function(context) FactionTurnStart_Pope_Crusades(context) end,
		true
	);
	cm:add_listener(
		"DillemaOrIncidentStarted_Crusades",
		"DillemaOrIncidentStarted",
		true,
		function(context) DillemaOrIncidentStarted_Crusades(context) end,
		true
	);
	cm:add_listener(
		"DilemmaChoiceMadeEvent_Crusades",
		"DilemmaChoiceMadeEvent",
		true,
		function(context) DilemmaChoiceMadeEvent_Crusades(context) end,
		true
	);
	cm:add_listener(
		"TimeTrigger_Crusades",
		"TimeTrigger",
		true,
		function(context) TimeTrigger_Crusades(context) end,
		true
	);

	if cm:is_new_game() then
		if SCRIPTED_CRUSADES_LIST[tostring(CURRENT_CRUSADE + 1)] then
			NEXT_CRUSADE_MESSAGE_TURN = SCRIPTED_CRUSADES_LIST[tostring(CURRENT_CRUSADE + 1)][2];
			NEXT_CRUSADE_START_TURN = SCRIPTED_CRUSADES_LIST[tostring(CURRENT_CRUSADE + 1)][3];
		else
			NEXT_CRUSADE_START_TURN = cm:model():turn_number() + cm:random_number(TURNS_BETWEEN_CRUSADES_MAX, TURNS_BETWEEN_CRUSADES_MIN);
		end
	elseif CRUSADE_ACTIVE == true then
		cm:add_listener(
			"CharacterCompletedBattle_Crusades",
			"CharacterCompletedBattle",
			true,
			function(context) CharacterCompletedBattle_Crusades(context) end,
			true
		);
		cm:add_listener(
			"CharacterParticipatedAsSecondaryGeneralInBattle_Crusades",
			"CharacterParticipatedAsSecondaryGeneralInBattle",
			true,
			function(context) CharacterCompletedBattle_Crusades(context) end,
			true
		);
		cm:add_listener(
			"CharacterEntersGarrison_Crusades",
			"CharacterEntersGarrison",
			true,
			function(context) CharacterEntersGarrison_Crusades(context) end,
			true
		);
		cm:add_listener(
			"CharacterTurnStart_Crusades",
			"CharacterTurnStart",
			true,
			function(context) CharacterTurnStart_Crusades(context) end,
			true
		);
		cm:add_listener(
			"MissionFailed_Crusades",
			"MissionFailed",
			true,
			function(context) MissionFailed_Crusades(context) end,
			true
		);
	elseif MISSION_TAKE_JERUSALEM_ACTIVE == true then
		cm:add_listener(
			"CharacterEntersGarrison_Jerusalem",
			"CharacterEntersGarrison",
			true,
			function(context) CharacterEntersGarrison_Jerusalem(context) end,
			true
		);
	end
end

function FactionTurnStart_Pope_Crusades(context)
	if PAPAL_FAVOUR_SYSTEM_ACTIVE == true and (CURRENT_CRUSADE < MAX_NUM_OF_CRUSADES or CRUSADE_ACTIVE == true) then
		if cm:model():turn_number() == NEXT_CRUSADE_MESSAGE_TURN then
			local owner = cm:model():world():region_manager():region_by_key(SCRIPTED_CRUSADES_LIST[tostring(CURRENT_CRUSADE + 1)][1]):owning_faction();
			local owner_religion = owner:state_religion();

			if HasValue(CRUSADE_TARGET_RELIGIONS, owner_religion) then
				cm:show_message_event(
					context:faction():name(),
					"message_event_text_text_mk_event_crusade_"..tostring(CURRENT_CRUSADE + 1).."_title",  
					"message_event_text_text_mk_event_crusade_preliminary_"..tostring(CURRENT_CRUSADE + 1).."_primary", 
					"message_event_text_text_mk_event_crusade_preliminary_"..tostring(CURRENT_CRUSADE + 1).."_secondary", 
					true,
					706
				);
			end
		elseif cm:model():turn_number() == NEXT_CRUSADE_START_TURN and CRUSADE_ACTIVE == false then
			local target = nil;

			if SCRIPTED_CRUSADES_LIST[tostring(CURRENT_CRUSADE + 1)]  then
				if SCRIPTED_CRUSADES_LIST[tostring(CURRENT_CRUSADE + 1)]  then
					target = SCRIPTED_CRUSADES_LIST[tostring(CURRENT_CRUSADE + 1)][1];	
				end
			else
				target = GetCrusadeTarget_Crusades();

				if target == nil then
					NEXT_CRUSADE_START_TURN = cm:model():turn_number() + 1;
					return;
				end
			end

			CURRENT_CRUSADE = CURRENT_CRUSADE + 1;

			local owner = cm:model():world():region_manager():region_by_key(target):owning_faction();
			local owner_religion = owner:state_religion();

			if HasValue(CRUSADE_TARGET_RELIGIONS, owner_religion) then
				Begin_Crusade(target, owner);
			else
				cm:show_message_event(
					cm:get_local_faction(),
					"message_event_text_text_mk_event_crusade_"..tostring(CURRENT_CRUSADE).."_title", 
					"message_event_text_text_mk_event_crusade_aborted_primary", 
					"message_event_text_text_mk_event_crusade_aborted_secondary", 
					true,
					706
				);

				if SCRIPTED_CRUSADES_LIST[tostring(CURRENT_CRUSADE + 1)]  then
					NEXT_CRUSADE_START_TURN = SCRIPTED_CRUSADES_LIST[tostring(CURRENT_CRUSADE + 1)][3];
				elseif CURRENT_CRUSADE < MAX_NUM_OF_CRUSADES then
					NEXT_CRUSADE_START_TURN = cm:model():turn_number() + cm:random_number(TURNS_BETWEEN_CRUSADES_MAX, TURNS_BETWEEN_CRUSADES_MIN);
				else
					NEXT_CRUSADE_START_TURN = -1; -- End crusades system.
				end
			end
		end

		if CRUSADE_ACTIVE == true then
			local owner = cm:model():world():faction_by_key(CURRENT_CRUSADE_TARGET_OWNER);
			local true_owner = cm:model():world():region_manager():region_by_key(CURRENT_CRUSADE_TARGET):owning_faction();

			if context:faction():is_human() then
				if true_owner:state_religion() == "att_rel_chr_catholic" then
					cm:override_mission_succeeded_status(context:faction():name(), CURRENT_CRUSADE_MISSION_KEY, true);
					End_Crusade("won");
				elseif true_owner:state_religion() == "att_rel_chr_orthodox" or true_owner:state_religion() == "att_rel_church_east" then
					End_Crusade("aborted");
				end

				if cm:model():turn_number() == NEXT_CRUSADE_START_TURN + CRUSADE_DURATION then
					local target_faction = cm:model():world():faction_by_key(CURRENT_CRUSADE_TARGET_OWNER);
		
					End_Crusade("lost");
		
					if target_faction:is_human() == false then
						cm:override_mission_succeeded_status(context:faction():name(), CURRENT_CRUSADE_MISSION_KEY, false);
					end
				end
			else
				if HasValue(CURRENT_CRUSADE_FACTIONS_JOINED, context:faction():name()) and context:faction():state_religion() ~= "att_rel_chr_catholic" then
					Remove_Faction_From_Crusade(context:faction():name());
				elseif context:faction():name() == CURRENT_CRUSADE_TARGET and context:faction():state_religion() == "att_rel_chr_catholic" then
					End_Crusade("aborted");
				end

				if SCRIPTED_CRUSADES_LIST[tostring(CURRENT_CRUSADE)]  then
					if HasValue(SCRIPTED_CRUSADES_LIST[tostring(CURRENT_CRUSADE)][6], context:faction():name()) then
						if context:faction():state_religion() == "att_rel_chr_catholic" and context:faction():at_war_with(owner) == false and HasValue(FACTION_EXCOMMUNICATED, context:faction():name()) ~= true then
							cm:force_declare_war(context:faction():name(), owner:name());
						end

						cm:force_diplomacy(context:faction():name(), CURRENT_CRUSADE_TARGET_OWNER, "peace", false, false);
						cm:force_diplomacy(CURRENT_CRUSADE_TARGET_OWNER, context:faction():name(), "peace", false, false);

						table.insert(CURRENT_CRUSADE_FACTIONS_JOINED, context:faction():name());
					end
				else
					if context:faction():state_religion() == "att_rel_chr_catholic" and HasValue(FACTION_EXCOMMUNICATED, context:faction():name()) ~= true then
						if context:faction():name() == JERUSALEM_KEY or context:faction():region_list():num_items() >= CRUSADE_CANDIDATE_MIN_REGIONS then
							if context:faction():at_war_with(owner) == false then
								cm:force_declare_war(context:faction():name(), owner:name());
							end
		
							cm:force_diplomacy(context:faction():name(), CURRENT_CRUSADE_TARGET_OWNER, "peace", false, false);
							cm:force_diplomacy(CURRENT_CRUSADE_TARGET_OWNER, context:faction():name(), "peace", false, false);

							table.insert(CURRENT_CRUSADE_FACTIONS_JOINED, context:faction():name());
						end
					end
				end
			end
		end
	end
end

function DillemaOrIncidentStarted_Crusades(context)
	if context.string == "mk_dilemma_crusades_owned_target" then
		CRUSADE_END_EVENT_OPEN = true;
	end
end

function DilemmaChoiceMadeEvent_Crusades(context)
	if context:dilemma() == "mk_dilemma_crusades_owned_target" then
		local faction_list = cm:model():world():faction_list();
		local faction_name = context:faction():name();

		if context:choice() == 0 then
			-- Choice made to abdicate titles!
			Make_Peace_Crusades(faction_name);

			for i = 0, faction_list:num_items() - 1 do
				local possible_ally = faction_list:item_at(i);
					
				if context:faction():allied_with(possible_ally) == true and possible_ally:at_war_with(cm:model():world():faction_by_key(CURRENT_CRUSADE_TARGET_OWNER)) then
					Make_Peace_Crusades(possible_ally:name());
				end
			end

			for i = 1, #CURRENT_CRUSADE_TARGET_OWNED_REGIONS do
				local region = cm:model():world():region_manager():region_by_key(CURRENT_CRUSADE_TARGET_OWNED_REGIONS[i]);
		
				if region:owning_faction():name() == faction_name then
					Transfer_Region_To_Faction(CURRENT_CRUSADE_TARGET_OWNED_REGIONS[i], JERUSALEM_KEY);
				end
			end
		elseif context:choice() == 1 then
			-- Choice made to refuse Pope's demands!
			Make_Peace_Crusades(faction_name);

			for i = 0, faction_list:num_items() - 1 do
				local possible_ally = faction_list:item_at(i);
					
				if context:faction():allied_with(possible_ally) == true and possible_ally:at_war_with(cm:model():world():faction_by_key(CURRENT_CRUSADE_TARGET_OWNER)) then
					Make_Peace_Crusades(possible_ally:name());
				end
			end

			Subtract_Pope_Favour(faction_name, 8, "refused_demands");
			Update_Pope_Favour(context:faction());
		elseif context:choice() == 2 then
			-- Choice made to push on to Jerusalem!
			cm:trigger_mission(faction_name, "mk_mission_crusades_take_jerusalem_dilemma");

			cm:add_listener(
				"CharacterEntersGarrison_Jerusalem",
				"CharacterEntersGarrison",
				true,
				function(context) CharacterEntersGarrison_Jerusalem(context) end,
				true
			);

			MISSION_TAKE_JERUSALEM_ACTIVE = true;
		elseif context:choice() == 3 then
			-- Choice made to give only the crusade target.
			Make_Peace_Crusades(faction_name);
			Transfer_Region_To_Faction(CURRENT_CRUSADE_TARGET, JERUSALEM_KEY);

			for i = 0, faction_list:num_items() - 1 do
				local possible_ally = faction_list:item_at(i);
					
				if context:faction():allied_with(possible_ally) == true and possible_ally:at_war_with(cm:model():world():faction_by_key(CURRENT_CRUSADE_TARGET_OWNER)) then
					Make_Peace_Crusades(possible_ally:name());
				end
			end

			Subtract_Pope_Favour(faction_name, 3, "refused_but_gave_target");
			Update_Pope_Favour(context:faction());
		end
	end
end

function CharacterCompletedBattle_Crusades(context)
	local character = context:character();
	local character_faction_name = context:character():faction():name();
	local character_force_cqi = -1;
			
	if character:has_military_force() then
		character_force_cqi = character:military_force():command_queue_index();
	end
		
	if character_force_cqi == -1 then
		return;
	end
		
	local pending_battle = cm:model():pending_battle();
	local attacker_result = nil;
	local defender_result = nil;
		
	if pending_battle:has_attacker() then
		attacker_result = pending_battle:attacker_battle_result();
	else
		return;
	end

	if pending_battle:has_defender() then
		defender_result = pending_battle:defender_battle_result();
	else
		return;
	end

	if HasValue(CURRENT_CRUSADE_FACTIONS_JOINED, character_faction_name) then
		if pending_battle:attacker():faction():name() == character_faction_name then
			if pending_battle:defender():faction():name() ~= CURRENT_CRUSADE_TARGET_OWNER and pending_battle:defender():faction():allied_with(cm:model():world():faction_by_key(CURRENT_CRUSADE_TARGET_OWNER)) ~= true then
				return;
			end
		elseif pending_battle:defender():faction():name() == character_faction_name then
			if pending_battle:attacker():faction():name() ~= CURRENT_CRUSADE_TARGET_OWNER and pending_battle:attacker():faction():allied_with(cm:model():world():faction_by_key(CURRENT_CRUSADE_TARGET_OWNER)) ~= true then
				return;
			end
		end
	elseif character_faction_name == CURRENT_CRUSADE_TARGET_OWNER or character:allied_with(cm:model():world():faction_by_key(CURRENT_CRUSADE_TARGET_OWNER)) then
		if pending_battle:attacker():faction():name() == character_faction_name then
			if not HasValue(CURRENT_CRUSADE_FACTIONS_JOINED, pending_battle:defender():faction():name()) then
				return;
			end
		elseif pending_battle:defender():faction():name() == character_faction_name then
			if not HasValue(CURRENT_CRUSADE_FACTIONS_JOINED, pending_battle:attacker():faction():name()) then
				return;
			end
		end
	end

	if attacker_result == "close_defeat" and defender_result == "close_defeat" then
		-- They've both had a close defeat, probably a retreat!
		return;
	elseif pending_battle:attacker():won_battle() then
		if character:faction():name() == pending_battle:attacker():faction():name() then
			Check_Trait_Crusade_Battle_Victory(character);
		end
	elseif pending_battle:defender():won_battle() then
		if character:faction():name() == pending_battle:defender():faction():name() then
			Check_Trait_Crusade_Battle_Victory(character);
		end
	end
end

function Check_Trait_Crusade_Battle_Victory(character)
	local character_cqi = character:cqi();
	local character_faction_name = character:faction():name();

	if HasValue(CURRENT_CRUSADE_FACTIONS_JOINED, character_faction_name) then
		if character:is_faction_leader() and character:trait_level("mk_trait_crusades_crusader_king") < 3 then
			cm:force_add_trait("character_cqi:"..character_cqi, "mk_trait_crusades_crusader_king", true);

			if IRONMAN_ENABLED then
				if character:faction():is_human() then
					Unlock_Achievement("crusader_king");
				end
			end
		elseif character:is_faction_leader() == false and character:trait_level("mk_trait_crusades_crusader") < 3 then
			cm:force_add_trait("character_cqi:"..character_cqi, "mk_trait_crusades_crusader", true);
		end
	else
		if character:trait_level("mk_trait_crusades_mujahid") < 3 then
			cm:force_add_trait("character_cqi:"..character_cqi, "mk_trait_crusades_mujahid", true);
		end
	end
end

function CharacterTurnStart_Crusades(context)
	if context:character():has_region() then
		if HasValue(CURRENT_CRUSADE_TARGET_OWNED_REGIONS, context:character():region():name()) then
			if HasValue(CURRENT_CRUSADE_FACTIONS_JOINED, context:character():faction():name()) then
				if cm:random_number(100) <= CRUSADE_ANCILLARY_CHANCE_PER_TURN then
					local ancillary = CRUSADE_ANCILLARIES[cm:random_number(#CRUSADE_ANCILLARIES)];

					if context:character():has_ancillary(ancillary) == false then
						cm:force_add_ancillary("character_cqi:"..context:character():cqi(), ancillary);
					end
				end
			end
		end
	end
end

function CharacterEntersGarrison_Crusades(context)
	if context:character():has_region() and context:character():region():name() == CURRENT_CRUSADE_TARGET then
		if context:character():faction():state_religion() == "att_rel_chr_catholic" then
			cm:override_mission_succeeded_status(context:character():faction():name(), CURRENT_CRUSADE_MISSION_KEY, true);
			End_Crusade("won");
		elseif context:character():faction():state_religion() == "att_rel_chr_orthodox" or context:character():faction():state_religion() == "att_rel_church_east" then
			End_Crusade("aborted");
		end
	end
end

function CharacterEntersGarrison_Jerusalem(context)
	if context:character():has_region() and context:character():region():name() == JERUSALEM_REGION_KEY then
		if context:character():faction():state_religion() == "att_rel_chr_catholic" then
			MISSION_TAKE_JERUSALEM_ACTIVE = false;
			Make_Peace_Crusades(context:character():faction():name());
			cm:override_mission_succeeded_status(context:character():faction():name(), "mk_mission_crusades_take_jerusalem_dilemma", true);
			cm:add_time_trigger("Transfer_Jerusalem_Crusades", 0.5);
			cm:remove_listener("CharacterEntersGarrison_Jerusalem");
		end
	end
end

function MissionFailed_Crusades(context)
	local faction_name = context:faction():name();
	local mission_name = context:mission():mission_record_key();

	if mission_name == CURRENT_CRUSADE_MISSION_KEY and CRUSADE_ACTIVE == true then
		End_Crusade("lost");
	elseif mission_name == "mk_mission_crusades_take_jerusalem_dilemma" then
		MISSION_TAKE_JERUSALEM_ACTIVE = false;
		cm:remove_listener("CharacterEntersGarrison_Jerusalem");
		Make_Peace_Crusades(faction_name);
		Subtract_Pope_Favour(faction_name, 8, "mission_fail_take_jerusalem_dilemma");
	end
end

function Begin_Crusade(target, owner)
	CRUSADE_ACTIVE = true;
	CURRENT_CRUSADE_FACTIONS_JOINED = {};
	CURRENT_CRUSADE_TARGET = target;
	CURRENT_CRUSADE_TARGET_OWNER = owner:name();
	CURRENT_CRUSADE_TARGET_OWNED_REGIONS = {};
	CURRENT_CRUSADE_TARGET_PREEXISTING_ENEMIES = {};
	CURRENT_CRUSADE_RECRUITABLE_UNITS = {};
	CURRENT_CRUSADE_RECRUITABLE_UNITS_CAPS = {};

	local faction_list = cm:model():world():faction_list();
	local region_list = owner:region_list();
	local era = "early";
	local target_short = string.gsub(target, "att_reg_", "");

	-- Save a list of factions who are at war with the crusade target for when the crusade ends so that automatic peace isn't inadvertently made.
	for i = 0, faction_list:num_items() - 1 do
		local faction = faction_list:item_at(i);

		if faction:at_war_with(owner) then
			table.insert(CURRENT_CRUSADE_TARGET_PREEXISTING_ENEMIES, faction:name());
		end
	end

	for i = 1, region_list:num_items() - 1 do
		local region = region_list:item_at(i);
			
		table.insert(CURRENT_CRUSADE_TARGET_OWNED_REGIONS, region:name());
	end

	for i = 1, #CRUSADE_RECRUITABLE_UNITS[era] do
		local unit_name = CRUSADE_RECRUITABLE_UNITS[era][i];

		table.insert(CURRENT_CRUSADE_RECRUITABLE_UNITS, unit_name);
		CURRENT_CRUSADE_RECRUITABLE_UNITS_CAPS[unit_name] = CRUSADE_RECRUITABLE_UNITS_CAPS[era][unit_name];
	end

	PopulateCrusaderRecruitmentPanel();

	cm:apply_effect_bundle("mk_bundle_crusade_target", CURRENT_CRUSADE_TARGET_OWNER, 0);
	cm:make_region_seen_in_shroud(cm:get_local_faction(), CURRENT_CRUSADE_TARGET);

	cm:add_listener(
		"CharacterCompletedBattle_Crusades",
		"CharacterCompletedBattle",
		true,
		function(context) CharacterCompletedBattle_Crusades(context) end,
		true
	);
	cm:add_listener(
		"CharacterParticipatedAsSecondaryGeneralInBattle_Crusades",
		"CharacterParticipatedAsSecondaryGeneralInBattle",
		true,
		function(context) CharacterCompletedBattle_Crusades(context) end,
		true
	);
	cm:add_listener(
		"CharacterEntersGarrison_Crusades",
		"CharacterEntersGarrison",
		true,
		function(context) CharacterEntersGarrison_Crusades(context) end,
		true
	);
	cm:add_listener(
		"CharacterTurnStart_Crusades",
		"CharacterTurnStart",
		true,
		function(context) CharacterTurnStart_Crusades(context) end,
		true
	);
	cm:add_listener(
		"MissionFailed_Crusades",
		"MissionFailed",
		true,
		function(context) MissionFailed_Crusades(context) end,
		true
	);

	if owner:is_human() == false then
		local force = CRUSADE_DEFENSE_UNIT_LIST;

		if SpawnValidSettlement(target) == true then
			CreateDefensiveArmy_Crusades(target, force);
		end

		for i = 1, #CRUSADE_REGIONS_IN_MIDDLE_EAST do
			local region_name = CRUSADE_REGIONS_IN_MIDDLE_EAST[i];

			if region_name ~= CURRENT_CRUSADE_TARGET then
				if cm:model():world():region_manager():region_by_key(region_name):owning_faction() == owner then
					if SpawnValidSettlement(region_name) == true then
						CreateDefensiveArmy_Crusades(region_name, force);
					end
				end
			end
		end
	end

	if CRUSADE_INTRO_CUTSCENE_PLAYED == false then
		Cutscene_Play("mk1212_crusades_intro");

		CRUSADE_INTRO_CUTSCENE_PLAYED = true;
	end

	if SCRIPTED_CRUSADES_LIST[tostring(CURRENT_CRUSADE)]  then
		cm:show_message_event(
			cm:get_local_faction(),
			"message_event_text_text_mk_event_crusade_"..tostring(CURRENT_CRUSADE).."_title", 
			"message_event_text_text_mk_event_crusade_go_crusade_"..tostring(CURRENT_CRUSADE).."_primary", 
			"message_event_text_text_mk_event_crusade_go_crusade_"..tostring(CURRENT_CRUSADE).."_secondary", 
			true,
			706
		);
	else
		cm:show_message_event(
			cm:get_local_faction(),
			"message_event_text_text_mk_event_crusade_"..tostring(CURRENT_CRUSADE).."_title", 
			"message_event_text_text_mk_event_crusade_go_"..target_short.."_primary", 
			"message_event_text_text_mk_event_crusade_go_"..target_short.."_secondary", 
			true,
			706
		);
	end

	if CURRENT_CRUSADE_TARGET_OWNER == cm:get_local_faction() then
		if SCRIPTED_CRUSADES_LIST[tostring(CURRENT_CRUSADE)]  then
			CURRENT_CRUSADE_MISSION_KEY = SCRIPTED_CRUSADES_LIST[tostring(CURRENT_CRUSADE)][5];
		else
			CURRENT_CRUSADE_MISSION_KEY = "mk_mission_crusades_defense_"..target_short;
		end

		cm:trigger_mission(CURRENT_CRUSADE_TARGET_OWNER, CURRENT_CRUSADE_MISSION_KEY);
	else
		if SCRIPTED_CRUSADES_LIST[tostring(CURRENT_CRUSADE)]  then
			CURRENT_CRUSADE_MISSION_KEY = SCRIPTED_CRUSADES_LIST[tostring(CURRENT_CRUSADE)][4];
		else
			CURRENT_CRUSADE_MISSION_KEY = "mk_mission_crusades_take_"..target_short;
		end
	end
end

function End_Crusade(reason)
	local target_short = string.gsub(CURRENT_CRUSADE_TARGET, "att_reg_", "");

	if reason == "won" and cm:model():world():region_manager():region_by_key(JERUSALEM_REGION_KEY):owning_faction():state_religion() == "att_rel_chr_catholic" then
		if CURRENT_CRUSADE_TARGET == JERUSALEM_REGION_KEY then
			-- Jerusalem was the target of the crusade and was taken.
			cm:show_message_event(
				cm:get_local_faction(),
				"message_event_text_text_mk_event_crusade_"..tostring(CURRENT_CRUSADE).."_title", 
				"message_event_text_text_mk_event_crusade_won_primary", 
				"message_event_text_text_mk_event_crusade_won_jerusalem_target_secondary", 
				true,
				706
			);
		elseif HasValue(CURRENT_CRUSADE_TARGET_OWNED_REGIONS, JERUSALEM_REGION_KEY) then
			-- Jerusalem was taken during the crusade despite not being a target.
			cm:show_message_event(
				cm:get_local_faction(),
				"message_event_text_text_mk_event_crusade_"..tostring(CURRENT_CRUSADE).."_title", 
				"message_event_text_text_mk_event_crusade_won_primary", 
				"message_event_text_text_mk_event_crusade_won_jerusalem_taken_secondary", 
				true,
				706
			);
		else
			-- Jerusalem is owned already or was taken outside of the crusade. 
			cm:show_message_event(
				cm:get_local_faction(),
				"message_event_text_text_mk_event_crusade_"..tostring(CURRENT_CRUSADE).."_title", 
				"message_event_text_text_mk_event_crusade_won_primary", 
				"message_event_text_text_mk_event_crusade_won_jerusalem_secondary", 
				true,
				706
			);
		end
	else
		cm:show_message_event(
			cm:get_local_faction(),
			"message_event_text_text_mk_event_crusade_"..tostring(CURRENT_CRUSADE).."_title", 
			"message_event_text_text_mk_event_crusade_"..reason.."_primary", 
			"message_event_text_text_mk_event_crusade_"..reason.."_secondary", 
			true,
			706
		);
	end

	if cm:model():world():faction_by_key(CURRENT_CRUSADE_TARGET_OWNER):is_human() == false then
		Purge_Crusade_Defensive_Armies();
	else
		if reason == "lost" then
			cm:override_mission_succeeded_status(CURRENT_CRUSADE_TARGET_OWNER, "mk_mission_crusades_defense_"..target_short, true);
		else
			cm:override_mission_succeeded_status(CURRENT_CRUSADE_TARGET_OWNER, "mk_mission_crusades_defense_"..target_short, false);
		end
	end
 
	cm:remove_listener("CharacterCompletedBattle_Crusades");
	cm:remove_listener("CharacterParticipatedAsSecondaryGeneralInBattle_Crusades");
	cm:remove_listener("CharacterEntersGarrison_Crusades");
	cm:remove_listener("CharacterTurnStart_Crusades");
	cm:remove_listener("MissionFailed_Crusades");
	Remove_Crusade_Effects();

	local faction_list = cm:model():world():faction_list();
	local owner = cm:model():world():region_manager():region_by_key(CURRENT_CRUSADE_TARGET):owning_faction();

	-- All non-human Catholic factions will give their conquered regions to the Kingdom of Jerusalem if the target of the crusade was in the Levant.
	if HasValue(CRUSADE_REGIONS_IN_MIDDLE_EAST, CURRENT_CRUSADE_TARGET) then
		for i = 1, #CURRENT_CRUSADE_TARGET_OWNED_REGIONS do
			local region = cm:model():world():region_manager():region_by_key(CURRENT_CRUSADE_TARGET_OWNED_REGIONS[i]);
			
			if region:owning_faction():state_religion() == "att_rel_chr_catholic" and region:owning_faction():is_human() == false then
				if region:owning_faction():name() ~= JERUSALEM_KEY then
					Transfer_Region_To_Faction(CURRENT_CRUSADE_TARGET_OWNED_REGIONS[i], JERUSALEM_KEY);
				end
			end
		end
	end

	for i = 0, faction_list:num_items() - 1 do
		local possible_christian_faction = faction_list:item_at(i);
		local possible_christian_faction_name = possible_christian_faction:name();
			
		if HasValue(CURRENT_CRUSADE_FACTIONS_JOINED, possible_christian_faction_name) then
			if reason == "lost" then
				cm:apply_effect_bundle("mk_bundle_crusade_failure", possible_christian_faction_name, 10);
				Make_Peace_Crusades(possible_christian_faction_name);
			elseif reason == "aborted" then
				if possible_christian_faction:is_human() then
					cm:cancel_custom_mission(possible_christian_faction_name, CURRENT_CRUSADE_MISSION_KEY);
				end

				Make_Peace_Crusades(possible_christian_faction_name);
			elseif reason == "won" then
				cm:apply_effect_bundle("mk_bundle_crusade_victory", possible_christian_faction_name, 10);
				Add_Pope_Favour(possible_christian_faction_name, 10, "crusade_victory");

				if possible_christian_faction:is_human() == false or (possible_christian_faction:is_human() and possible_christian_faction_name == JERUSALEM_KEY) or (possible_christian_faction:is_human() == true and possible_christian_faction ~= owner) then
					Make_Peace_Crusades(possible_christian_faction_name);
				elseif HasValue(CRUSADE_REGIONS_IN_MIDDLE_EAST, CURRENT_CRUSADE_TARGET) and possible_christian_faction:is_human() == true and possible_christian_faction_name == owner:name() and possible_christian_faction_name ~= JERUSALEM_KEY then
					cm:trigger_dilemma(possible_christian_faction_name, "mk_dilemma_crusades_owned_target");
				else		
					Make_Peace_Crusades(possible_christian_faction_name);
				end
			end

			for j = 0, faction_list:num_items() - 1 do
				local possible_ally = faction_list:item_at(j);
				local possible_ally_name = possible_ally:name();
					
				if possible_christian_faction:allied_with(possible_ally) == true then
					if HasValue(CURRENT_CRUSADE_FACTIONS_JOINED, possible_ally_name) ~= true and possible_ally ~= owner and possible_ally:at_war_with(cm:model():world():faction_by_key(CURRENT_CRUSADE_TARGET_OWNER)) then
						Make_Peace_Crusades(possible_ally_name);
					end
				end
			end
		end
	end

	if SCRIPTED_CRUSADES_LIST[tostring(CURRENT_CRUSADE + 1)]  then
		NEXT_CRUSADE_START_TURN = SCRIPTED_CRUSADES_LIST[tostring(CURRENT_CRUSADE + 1)][3];
	elseif CURRENT_CRUSADE < MAX_NUM_OF_CRUSADES then
		NEXT_CRUSADE_START_TURN = cm:model():turn_number() + cm:random_number(TURNS_BETWEEN_CRUSADES_MAX, TURNS_BETWEEN_CRUSADES_MIN);
	else
		NEXT_CRUSADE_START_TURN = -1; -- End crusades system.
	end

	if SCRIPTED_CRUSADES_LIST[tostring(CURRENT_CRUSADE + 1)]  then
		NEXT_CRUSADE_MESSAGE_TURN = SCRIPTED_CRUSADES_LIST[tostring(CURRENT_CRUSADE + 1)][2];
	else
		NEXT_CRUSADE_MESSAGE_TURN = -1;
	end

	CRUSADE_ACTIVE = false;
end

function Remove_Crusade_Effects()
	cm:remove_effect_bundle("mk_bundle_crusade_target", CURRENT_CRUSADE_TARGET_OWNER);

	local faction_list = cm:model():world():faction_list();

	for i = 0, faction_list:num_items() - 1 do
		local faction = faction_list:item_at(i);
		local force_list = faction:military_force_list();

		for j = 0, force_list:num_items() - 1 do
			local force = force_list:item_at(j);
			cm:remove_effect_bundle_from_force("mk_bundle_army_crusade", force:command_queue_index());
		end
	end
end

function GetCrusadeTarget_Crusades()
	local valid_targets = nil;

	for k, v in pairs(CRUSADE_REGIONS) do
		local owner = cm:model():world():region_manager():region_by_key(k):owning_faction();
		local owner_religion = owner:state_religion();

		if HasValue(CRUSADE_TARGET_RELIGIONS, owner_religion) then
			if valid_targets == nil then
				valid_targets = {};
			end

			valid_targets[k] = v;
		end
	end

	if valid_targets  then
		local amount_stepped = 0;
		local total_weight = 0;

		for k, v in pairs(valid_targets) do
			total_weight = total_weight + v;
		end

		for k, v in pairs(valid_targets) do
			amount_stepped = amount_stepped + v;

			local chance = (amount_stepped / total_weight) * 100;
			chance = math.floor(chance + 0.5);

			if cm:model():random_percent(chance) then
				return k;
			end
		end

		-- Still haven't found a target so pick the one with the highest weight.
		local max_weight = 0;
		local max_weight_region = nil;

		for k, v in pairs(valid_targets) do
			if v > max_weight then
				max_weight = v;
				max_weight_region = k;
			end
		end

		return max_weight_region;
	else
		-- No valid target for the next crusade.
		return;
	end
end

function Make_Peace_Crusades(faction_name)
	if cm:model():world():faction_by_key(faction_name):at_war_with(cm:model():world():faction_by_key(CURRENT_CRUSADE_TARGET_OWNER)) then
		cm:force_diplomacy(faction_name, CURRENT_CRUSADE_TARGET_OWNER, "peace", true, true);
		cm:force_diplomacy(CURRENT_CRUSADE_TARGET_OWNER, faction_name, "peace", true, true);

		if not HasValue(CURRENT_CRUSADE_TARGET_PREEXISTING_ENEMIES, faction_name) then
			cm:force_make_peace(CURRENT_CRUSADE_TARGET_OWNER, faction_name);
		end
	end
end

function Remove_Faction_From_Crusade(faction_name)
	local faction = cm:model():world():faction_by_key(faction_name);
	local faction_list = cm:model():world():faction_list();

	if faction:state_religion() == "att_rel_chr_catholic" and faction:at_war_with(cm:model():world():faction_by_key(CURRENT_CRUSADE_TARGET_OWNER)) then
		cm:force_diplomacy(faction_name, CURRENT_CRUSADE_TARGET_OWNER, "peace", true, true);
		cm:force_diplomacy(CURRENT_CRUSADE_TARGET_OWNER, faction_name, "peace", true, true);
		Make_Peace_Crusades(faction_name);

		for i = 0, faction_list:num_items() - 1 do
			local possible_ally = faction_list:item_at(i);
					
			if faction:allied_with(possible_ally) == true and possible_ally:at_war_with(cm:model():world():faction_by_key(CURRENT_CRUSADE_TARGET_OWNER)) then
				Make_Peace_Crusades(possible_ally:name());
			end
		end
	end

	for i = 1, #CURRENT_CRUSADE_FACTIONS_JOINED do
		if CURRENT_CRUSADE_FACTIONS_JOINED[i] == faction_name then
			table.remove(CURRENT_CRUSADE_FACTIONS_JOINED, i);
			break;
		end
	end
end

function CreateDefensiveArmy_Crusades(region_name, force)
	local region = cm:model():world():region_manager():region_by_key(region_name);
	local region_x = region:settlement():logical_position_x();
	local region_y = region:settlement():logical_position_y();
	local owner = region:owning_faction();
		
	cm:create_force(
		owner:name(),
		force,
		region_name,
		region_x,
		region_y,
		"CrusadeDefensiveArmy_"..region_name,
		true,
		function(cqi)
			Crusade_Defense_Force(cqi);		
		end
	);
end

function Crusade_Defense_Force(cqi)
	cm:apply_effect_bundle_to_characters_force("mk_bundle_army_crusade_defense", cqi, -1, true);
	cm:disable_movement_for_character("character_cqi:"..cqi);
	cm:set_character_immortality("character_cqi:"..cqi, true);
	
	local difficulty = cm:model():difficulty_level();
	local xp_lvl = 1;

	if difficulty == 0 then -- Normal
		xp_lvl = xp_lvl + 1;
	elseif difficulty == -1 then -- Hard
		xp_lvl = xp_lvl + 2;
	elseif difficulty == -2 then -- Very Hard
		xp_lvl = xp_lvl + 3;
	elseif difficulty == -3 then -- Legendary
		xp_lvl = xp_lvl + 4;
	end
	
	cm:award_experience_level("character_cqi:"..cqi, xp_lvl);
	table.insert(CRUSADE_DEFENSIVE_FORCES, cqi);
end

function Purge_Crusade_Defensive_Armies()
	for i = 1, #CRUSADE_DEFENSIVE_FORCES do
		if CRUSADE_DEFENSIVE_FORCES[i]  then
			cm:set_character_immortality("character_cqi:"..CRUSADE_DEFENSIVE_FORCES[i], false);
			cm:kill_character("character_cqi:"..CRUSADE_DEFENSIVE_FORCES[i], true, false);
			CRUSADE_DEFENSIVE_FORCES[i] = nil;
		end
	end
end

function TimeTrigger_Crusades(context)
	if context.string == "Transfer_Jerusalem_Crusades" then
		Transfer_Region_To_Faction(JERUSALEM_REGION_KEY, JERUSALEM_KEY);
	end
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		cm:save_value("CRUSADE_ACTIVE", CRUSADE_ACTIVE, context);
		cm:save_value("CRUSADE_END_EVENT_OPEN", CRUSADE_END_EVENT_OPEN, context);
		cm:save_value("CRUSADE_INTRO_CUTSCENE_PLAYED", CRUSADE_INTRO_CUTSCENE_PLAYED, context);
		cm:save_value("CURRENT_CRUSADE", CURRENT_CRUSADE, context);
		cm:save_value("CURRENT_CRUSADE_MISSION_KEY", CURRENT_CRUSADE_MISSION_KEY, context);
		cm:save_value("CURRENT_CRUSADE_TARGET", CURRENT_CRUSADE_TARGET, context);
		cm:save_value("CURRENT_CRUSADE_TARGET_OWNER", CURRENT_CRUSADE_TARGET_OWNER, context);
		cm:save_value("MISSION_TAKE_JERUSALEM_ACTIVE", MISSION_TAKE_JERUSALEM_ACTIVE, context);
		cm:save_value("NEXT_CRUSADE_MESSAGE_TURN", NEXT_CRUSADE_MESSAGE_TURN, context);
		cm:save_value("NEXT_CRUSADE_START_TURN", NEXT_CRUSADE_START_TURN, context);
		SaveTable(context, CRUSADE_DEFENSIVE_FORCES, "CRUSADE_DEFENSIVE_FORCES");
		SaveTable(context, CURRENT_CRUSADE_FACTIONS_JOINED, "CURRENT_CRUSADE_FACTIONS_JOINED");
		SaveTable(context, CURRENT_CRUSADE_TARGET_OWNED_REGIONS, "CURRENT_CRUSADE_TARGET_OWNED_REGIONS");
		SaveTable(context, CURRENT_CRUSADE_TARGET_PREEXISTING_ENEMIES, "CURRENT_CRUSADE_TARGET_PREEXISTING_ENEMIES");
		SaveTable(context, CURRENT_CRUSADE_RECRUITABLE_UNITS, "CURRENT_CRUSADE_RECRUITABLE_UNITS");
		SaveKeyPairTable(context, CURRENT_CRUSADE_RECRUITABLE_UNITS_CAPS, "CURRENT_CRUSADE_RECRUITABLE_UNITS_CAPS");
	end
);

cm:register_loading_game_callback(
	function(context)
		CRUSADE_ACTIVE = cm:load_value("CRUSADE_ACTIVE", false, context);
		CRUSADE_END_EVENT_OPEN = cm:load_value("CRUSADE_END_EVENT_OPEN", false, context);
		CRUSADE_INTRO_CUTSCENE_PLAYED = cm:load_value("CRUSADE_INTRO_CUTSCENE_PLAYED", false, context);
		CURRENT_CRUSADE = cm:load_value("CURRENT_CRUSADE", 4, context);
		CURRENT_CRUSADE_MISSION_KEY = cm:load_value("CURRENT_CRUSADE_MISSION_KEY", "nil", context);
		CURRENT_CRUSADE_TARGET = cm:load_value("CURRENT_CRUSADE_TARGET", "nil", context);
		CURRENT_CRUSADE_TARGET_OWNER = cm:load_value("CURRENT_CRUSADE_TARGET_OWNER", "nil", context);
		MISSION_TAKE_JERUSALEM_ACTIVE = cm:load_value("MISSION_TAKE_JERUSALEM_ACTIVE", false, context);
		NEXT_CRUSADE_MESSAGE_TURN = cm:load_value("NEXT_CRUSADE_MESSAGE_TURN", -1, context);
		NEXT_CRUSADE_START_TURN = cm:load_value("NEXT_CRUSADE_START_TURN", -1, context);
		CRUSADE_DEFENSIVE_FORCES = LoadTableNumbers(context, "CRUSADE_DEFENSIVE_FORCES");
		CURRENT_CRUSADE_FACTIONS_JOINED = LoadTable(context, "CURRENT_CRUSADE_FACTIONS_JOINED");
		CURRENT_CRUSADE_TARGET_OWNED_REGIONS = LoadTable(context, "CURRENT_CRUSADE_TARGET_OWNED_REGIONS");
		CURRENT_CRUSADE_TARGET_PREEXISTING_ENEMIES = LoadTable(context, "CURRENT_CRUSADE_TARGET_PREEXISTING_ENEMIES");
		CURRENT_CRUSADE_RECRUITABLE_UNITS = LoadTable(context, "CURRENT_CRUSADE_RECRUITABLE_UNITS");
		CURRENT_CRUSADE_RECRUITABLE_UNITS_CAPS = LoadKeyPairTableNumbers(context, "CURRENT_CRUSADE_RECRUITABLE_UNITS_CAPS");
	end
);
