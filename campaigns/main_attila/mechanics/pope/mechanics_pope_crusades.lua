 ------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: POPE CRUSADES
-- 	By: DETrooper
--
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
-- System for crusades. Deus Vult!

--require("mechanics/pope/mechanics_pope_crusades_cutscenes");

-- Constants
CRUSADE_DURATION = 20;
TURNS_BETWEEN_CRUSADES_MAX = 50;
TURNS_BETWEEN_CRUSADES_MIN = 20;

-- Variables
CRUSADE_ACTIVE = false;
CRUSADE_INTRO_CUTSCENE_PLAYED = false;
CURRENT_CRUSADE = 4;
CURRENT_CRUSADE_TARGET = "nil";
CURRENT_CRUSADE_TARGET_OWNER = "nil";
CURRENT_CRUSADE_TARGET_OWNED_REGIONS = {};
CURRENT_CRUSADE_FACTIONS_JOINED = {};
CRUSADE_DEFENSIVE_FORCES = {};
MISSION_TAKE_JERUSALEM_ACTIVE = false;
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
		"DilemmaChoiceMadeEvent_Crusades",
		"DilemmaChoiceMadeEvent",
		true,
		function(context) DilemmaChoiceMadeEvent_Crusades(context) end,
		true
	);
	cm:add_listener(
		"MissionFailed_Crusades",
		"MissionFailed",
		true,
		function(context) MissionFailed_Crusades(context) end,
		true
	);
	cm:add_listener(
		"CharacterEntersGarrison_Crusade",
		"CharacterEntersGarrison",
		true,
		function(context) CharacterEntersGarrison_Crusade(context) end,
		true
	);
	cm:add_listener(
		"CharacterEntersGarrison_Jerusalem",
		"CharacterEntersGarrison",
		true,
		function(context) CharacterEntersGarrison_Jerusalem(context) end,
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
		local faction_list = cm:model():world():faction_list();

		for i = 0, faction_list:num_items() - 1 do
			local current_faction = faction_list:item_at(i);
			CURRENT_CRUSADE_FACTIONS_JOINED[current_faction:name()] = "not joined";
		end

		NEXT_CRUSADE_START_TURN = SCRIPTED_CRUSADES_LIST[CURRENT_CRUSADE + 1][3];
	end
end

function FactionTurnStart_Pope_Crusades(context)
	if PAPAL_FAVOUR_SYSTEM_ACTIVE == true then
		if cm:model():turn_number() == SCRIPTED_CRUSADES_LIST[CURRENT_CRUSADE + 1][2] then
			local owner = cm:model():world():region_manager():region_by_key(SCRIPTED_CRUSADES_LIST[CURRENT_CRUSADE + 1][1]):owning_faction();
			local owner_religion = owner:state_religion();

			if HasValue(CRUSADE_TARGET_RELIGIONS, owner_religion) then
				cm:show_message_event(
					context:faction():name(),
					"message_event_text_text_mk_event_crusade_fifth_crusade_title", 
					"message_event_text_text_mk_event_crusade_fifth_crusade_primary", 
					"message_event_text_text_mk_event_crusade_fifth_crusade_secondary", 
					true,
					706
				);
			end
		end

		if cm:model():turn_number() == NEXT_CRUSADE_START_TURN then
			if CRUSADE_ACTIVE == false then
				local target = JERUSALEM_REGION_KEY;

				if SCRIPTED_CRUSADES_LIST[CURRENT_CRUSADE + 1] ~= nil then
					if SCRIPTED_CRUSADES_LIST[CURRENT_CRUSADE + 1][1] ~= nil then
						target = SCRIPTED_CRUSADES_LIST[CURRENT_CRUSADE + 1][1];
					end
				else
					target = GetCrusadeTarget_Crusades();
				end

				local owner = cm:model():world():region_manager():region_by_key(target):owning_faction();
				local owner_religion = owner:state_religion();

				if HasValue(CRUSADE_TARGET_RELIGIONS, owner_religion) then
					CRUSADE_ACTIVE = true;
					CURRENT_CRUSADE = CURRENT_CRUSADE + 1;
					CURRENT_CRUSADE_TARGET = target;
					CURRENT_CRUSADE_TARGET_OWNER = owner:name();

					local region_list = owner:region_list();

					for i = 1, region_list:num_items() - 1 do
						local region = region_list:item_at(i);
						
						table.insert(CURRENT_CRUSADE_TARGET_OWNED_REGIONS, region:name());
					end

					if cm:is_multiplayer() == false then
						cm:make_region_seen_in_shroud(context:faction():name(), CURRENT_CRUSADE_TARGET);
					end
				else
					cm:show_message_event(
						cm:get_local_faction(),
						"message_event_text_text_mk_event_crusade_fifth_crusade_title", 
						"message_event_text_text_mk_event_crusade_fifth_crusade_aborted_primary", 
						"message_event_text_text_mk_event_crusade_fifth_crusade_aborted_secondary", 
						true,
						706
					);

					NEXT_CRUSADE_START_TURN = cm:model():turn_number() + cm:random_number(TURNS_BETWEEN_CRUSADES_MAX, TURNS_BETWEEN_CRUSADES_MIN);
				end

				if CRUSADE_ACTIVE == true then
					if CRUSADE_INTRO_CUTSCENE_PLAYED == false then
						--ui_state.events_rollout:set_allowed(false, true);
						--ui_state.events_panel:set_allowed(false, true);
						--Cutscene_Fifth_Crusade_Play();
						Cutscene_Play("mk1212_crusades_intro");

						CRUSADE_INTRO_CUTSCENE_PLAYED = true;
					end

					cm:apply_effect_bundle("mk_bundle_crusade_target", CURRENT_CRUSADE_TARGET_OWNER, 0);

					cm:add_listener(
						"CharacterEntersGarrison_Crusade",
						"CharacterEntersGarrison",
						true,
						function(context) CharacterEntersGarrison_Crusade(context) end,
						true
					);

					if owner:is_human() == false then
						local force = CRUSADE_DEFENSE_UNIT_LIST;

						if cm:model():world():region_manager():region_by_key(JERUSALEM_REGION_KEY):owning_faction() == owner then
							CreateDefensiveArmy_Crusades(JERUSALEM_REGION_KEY, force);
						end

						if cm:model():world():region_manager():region_by_key(CURRENT_CRUSADE_TARGET):owning_faction() == owner then
							CreateDefensiveArmy_Crusades(CURRENT_CRUSADE_TARGET, force);
						end

						if cm:model():world():region_manager():region_by_key(ALEXANDRIA_REGION_KEY):owning_faction() == owner then
							CreateDefensiveArmy_Crusades(ALEXANDRIA_REGION_KEY, force);
						end
					end

					cm:show_message_event(
						context:faction():name(),
						"message_event_text_text_mk_event_crusade_fifth_crusade_title", 
						"message_event_text_text_mk_event_crusade_fifth_crusade_go_primary", 
						"message_event_text_text_mk_event_crusade_fifth_crusade_go_secondary", 
						true,
						706
					);
				end
			elseif context:faction():is_human() == false and CRUSADE_ACTIVE == true then
				local owner = cm:model():world():region_manager():region_by_key(CURRENT_CRUSADE_TARGET):owning_faction();

				if context:faction():name() == FRANCE_KEY or context:faction():name() == HRE_KEY or context:faction():name() == HUNGARY_KEY or context:faction():name() == JERUSALEM_KEY then
					if context:faction():at_war_with(owner) == false then
						cm:force_declare_war(context:faction():name(), owner:name());
					end

					cm:force_diplomacy(context:faction():name(), CURRENT_CRUSADE_TARGET_OWNER, "peace", false, false);
					cm:force_diplomacy(CURRENT_CRUSADE_TARGET_OWNER, context:faction():name(), "peace", false, false);
				end
			end
		end

		if cm:model():turn_number() == SCRIPTED_CRUSADES_LIST[CURRENT_CRUSADE][2] + CRUSADE_DURATION and CRUSADE_ACTIVE == true then
			End_Crusade("lost");
			cm:override_mission_succeeded_status(context:faction():name(), "mk_mission_crusades_take_cairo", false);
		end
	end
end

function DilemmaChoiceMadeEvent_Crusades(context)
	if context:dilemma() == "mk_dilemma_crusades_end_fifth_crusade" then
		local faction_name = context:faction():name();

		if context:choice() == 0 then
			-- Choice made to abdicate titles!
			cm:force_make_peace(CURRENT_CRUSADE_TARGET_OWNER, faction_name);

			for i = 0, faction_list:num_items() - 1 do
				local possible_ally = faction_list:item_at(i);
					
				if context:faction():allied_with(possible_ally) == true and possible_ally:at_war_with(cm:model():world():faction_by_key(CURRENT_CRUSADE_TARGET_OWNER)) then
					cm:force_make_peace(CURRENT_CRUSADE_TARGET_OWNER, possible_ally:name());
				end
			end

			for i = 1, #CURRENT_CRUSADE_TARGET_OWNED_REGIONS do
				local region = cm:model():world():region_manager():region_by_key(CURRENT_CRUSADE_TARGET_OWNED_REGIONS[i]);
		
				if region:owning_faction():name() == faction_name then
					cm:transfer_region_to_faction(CURRENT_CRUSADE_TARGET_OWNED_REGIONS[i], JERUSALEM_KEY);
				end
			end
		elseif context:choice() == 1 then
			-- Choice made to refuse Pope's demands!
			cm:force_make_peace(CURRENT_CRUSADE_TARGET_OWNER, faction_name);

			for i = 0, faction_list:num_items() - 1 do
				local possible_ally = faction_list:item_at(i);
					
				if context:faction():allied_with(possible_ally) == true and possible_ally:at_war_with(cm:model():world():faction_by_key(CURRENT_CRUSADE_TARGET_OWNER)) then
					cm:force_make_peace(CURRENT_CRUSADE_TARGET_OWNER, possible_ally:name());
				end
			end

			Subtract_Pope_Favour(faction_name, 8, "refused_demands");
			Update_Pope_Favour(context:faction());
		elseif context:choice() == 2 then
			-- Choice made to push on to Jerusalem!
			cm:trigger_mission(faction_name, "mk_mission_crusades_take_jerusalem");
			MISSION_TAKE_JERUSALEM_ACTIVE = true;
		elseif context:choice() == 3 then
			-- Choice made to give only Cairo!
			cm:force_make_peace(CURRENT_CRUSADE_TARGET_OWNER, faction_name);
			cm:transfer_region_to_faction(CURRENT_CRUSADE_TARGET, JERUSALEM_KEY);

			for i = 0, faction_list:num_items() - 1 do
				local possible_ally = faction_list:item_at(i);
					
				if context:faction():allied_with(possible_ally) == true and possible_ally:at_war_with(cm:model():world():faction_by_key(CURRENT_CRUSADE_TARGET_OWNER)) then
					cm:force_make_peace(CURRENT_CRUSADE_TARGET_OWNER, possible_ally:name());
				end
			end

			Subtract_Pope_Favour(faction_name, 3, "refused_but_gave_cairo");
			Update_Pope_Favour(context:faction());
		end
	end
end

function CharacterEntersGarrison_Crusade(context)
	if CRUSADE_ACTIVE == true then
		if context:character():has_region() and context:character():region():name() == CURRENT_CRUSADE_TARGET then
			if context:character():faction():state_religion() == "att_rel_chr_catholic" then
				cm:override_mission_succeeded_status(context:character():faction():name(), "mk_mission_crusades_take_cairo", true);
				End_Crusade("won");
			end
		elseif context:character():faction():state_religion() == "att_rel_chr_orthodox" or context:character():faction():state_religion() == "att_rel_church_east" then
			cm:cancel_custom_mission(context:character():faction():name(), "mk_mission_crusades_take_cairo");
			End_Crusade("aborted");
		end
	end
end

function CharacterEntersGarrison_Jerusalem(context)
	if MISSION_TAKE_JERUSALEM_ACTIVE == true then
		if context:character():has_region() and context:character():region():name() == JERUSALEM_REGION_KEY then
			if context:character():faction():state_religion() == "att_rel_chr_catholic" then
				MISSION_TAKE_JERUSALEM_ACTIVE = false;
				cm:override_mission_succeeded_status(context:character():faction():name(), "mk_mission_crusades_take_jerusalem", true);
				cm:add_time_trigger("Transfer_Jerusalem_Crusades", 0.5);
				cm:remove_listener("CharacterEntersGarrison_Jerusalem");
			end
		end
	end
end

function MissionFailed_Crusades(context)
	local mission_name = context:mission():mission_record_key();

	if mission_name == "mk_mission_crusades_take_cairo" then
		End_Crusade("lost");
	end
end

function End_Crusade(reason)
	if cm:model():world():faction_by_key(CURRENT_CRUSADE_TARGET_OWNER):is_human() == false then
		Purge_Crusade_Defensive_Armies();
	else
		if reason == "lost" then
			cm:override_mission_succeeded_status(CURRENT_CRUSADE_TARGET_OWNER, "mk_mission_story_ayyubids_crusade_defense", true);
		else
			cm:override_mission_succeeded_status(CURRENT_CRUSADE_TARGET_OWNER, "mk_mission_story_ayyubids_crusade_defense", false);
		end
	end

	cm:remove_listener("CharacterEntersGarrison_Crusade");
	Remove_Crusade_Effects();

	local faction_list = cm:model():world():faction_list();
	local owner = cm:model():world():region_manager():region_by_key(CURRENT_CRUSADE_TARGET):owning_faction();

	-- All non-human Catholic factions will give their conquered regions to the Kingdom of Jerusalem if the target of the crusade was in the Levant.
	for i = 1, #CURRENT_CRUSADE_TARGET_OWNED_REGIONS do
		local region = cm:model():world():region_manager():region_by_key(CURRENT_CRUSADE_TARGET_OWNED_REGIONS[i]);
		
		if region:owning_faction():state_religion() == "att_rel_chr_catholic" and region:owning_faction():is_human() == false then
			cm:transfer_region_to_faction(CURRENT_CRUSADE_TARGET_OWNED_REGIONS[i], JERUSALEM_KEY);
		end
	end

	for i = 0, faction_list:num_items() - 1 do
		local possible_christian_faction = faction_list:item_at(j);

		cm:show_message_event(
			possible_christian_faction:name(),
			"message_event_text_text_mk_event_crusade_fifth_crusade_title", 
			"message_event_text_text_mk_event_crusade_fifth_crusade_"..reason.."_primary", 
			"message_event_text_text_mk_event_crusade_fifth_crusade_"..reason.."_secondary", 
			true,
			706
		);
			
		if possible_christian_faction:state_religion() == "att_rel_chr_catholic" and possible_christian_faction:at_war_with(cm:model():world():faction_by_key(CURRENT_CRUSADE_TARGET_OWNER)) then
			cm:force_diplomacy(possible_christian_faction:name(), CURRENT_CRUSADE_TARGET_OWNER, "peace", true, true);
			cm:force_diplomacy(CURRENT_CRUSADE_TARGET_OWNER, possible_christian_faction:name(), "peace", true, true);

			if reason == "lost" then
				cm:apply_effect_bundle("mk_bundle_crusade_failure", possible_christian_faction:name(), 10);
				cm:force_make_peace(CURRENT_CRUSADE_TARGET_OWNER, possible_christian_faction:name());
			elseif reason == "aborted" then
				cm:force_make_peace(CURRENT_CRUSADE_TARGET_OWNER, possible_christian_faction:name());
			elseif reason == "won" then
				cm:apply_effect_bundle("mk_bundle_crusade_victory", possible_christian_faction:name(), 10);
				Add_Pope_Favour(possible_christian_faction:name(), 10, "crusade_victory");

				if possible_christian_faction:is_human() == false or (possible_christian_faction:is_human() == true and possible_christian_faction:name() == JERUSALEM_KEY) or (possible_christian_faction:is_human() == true and possible_christian_faction ~= owner) then
					cm:force_make_peace(CURRENT_CRUSADE_TARGET_OWNER, possible_christian_faction:name());
				elseif possible_christian_faction:is_human() == true and possible_christian_faction:name() == owner:name() then
					cm:trigger_dilemma(possible_christian_faction:name(), "mk_dilemma_crusades_end_fifth_crusade");
				else		
					cm:force_make_peace(CURRENT_CRUSADE_TARGET_OWNER, possible_christian_faction:name());
				end
			end

			for j = 0, faction_list:num_items() - 1 do
				local possible_ally = faction_list:item_at(j);
					
				if possible_christian_faction:allied_with(possible_ally) == true and possible_ally:at_war_with(cm:model():world():faction_by_key(CURRENT_CRUSADE_TARGET_OWNER)) then
					cm:force_make_peace(CURRENT_CRUSADE_TARGET_OWNER, possible_ally:name());
				end
			end
		end
	end

	CURRENT_CRUSADE_TARGET = "nil";
	CURRENT_CRUSADE_TARGET_OWNER = "nil";
	CURRENT_CRUSADE_TARGET_OWNED_REGIONS = {};
	NEXT_CRUSADE_START_TURN = cm:model():turn_number() + cm:random_number(TURNS_BETWEEN_CRUSADES_MAX, TURNS_BETWEEN_CRUSADES_MIN);
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
	local valid_targets = {};

	for k, v in pairs(CRUSADE_REGIONS) do
		local owner = cm:model():world():region_manager():region_by_key(k):owning_faction();
		local owner_religion = owner:state_religion();

		if HasValue(CRUSADE_TARGET_RELIGIONS, owner_religion) then

		end
	end
end

function CreateDefensiveArmy_Crusades(region_name, force)
	local owner = cm:model():world():region_manager():region_by_key(CURRENT_CRUSADE_TARGET):owning_faction();
	local region = cm:model():world():region_manager():region_by_key(region_name);
	local region_x = region:settlement():logical_position_x();
	local region_y = region:settlement():logical_position_y();
		
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
		if CRUSADE_DEFENSIVE_FORCES[i] ~= nil then
			cm:set_character_immortality("character_cqi:"..CRUSADE_DEFENSIVE_FORCES[i], false);
			cm:kill_character("character_cqi:"..CRUSADE_DEFENSIVE_FORCES[i], true, false);
			CRUSADE_DEFENSIVE_FORCES[i] = nil;
		end
	end
end

function TimeTrigger_Crusades(context)
	if context.string == "Transfer_Jerusalem_Crusades" then
		cm:transfer_region_to_faction(JERUSALEM_REGION_KEY, JERUSALEM_KEY);
	end
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		cm:save_value("CRUSADE_ACTIVE", CRUSADE_ACTIVE, context);
		cm:save_value("CURRENT_CRUSADE", CURRENT_CRUSADE, context);
		cm:save_value("CURRENT_CRUSADE_TARGET", CURRENT_CRUSADE_TARGET, context);
		cm:save_value("CURRENT_CRUSADE_TARGET_OWNER", CURRENT_CRUSADE_TARGET_OWNER, context);
		cm:save_value("CRUSADE_INTRO_CUTSCENE_PLAYED", CRUSADE_INTRO_CUTSCENE_PLAYED, context);
		cm:save_value("MISSION_TAKE_JERUSALEM_ACTIVE", MISSION_TAKE_JERUSALEM_ACTIVE, context);
		SaveTable(context, CURRENT_CRUSADE_TARGET_OWNED_REGIONS, "CURRENT_CRUSADE_TARGET_OWNED_REGIONS");
		SaveTable(context, CRUSADE_DEFENSIVE_FORCES, "CRUSADE_DEFENSIVE_FORCES");
		SaveKeyPairTable(context, CURRENT_CRUSADE_FACTIONS_JOINED, "CURRENT_CRUSADE_FACTIONS_JOINED");
	end
);

cm:register_loading_game_callback(
	function(context)
		CRUSADE_ACTIVE = cm:load_value("CRUSADE_ACTIVE", false, context);
		CURRENT_CRUSADE = cm:load_value("CURRENT_CRUSADE", 4, context);
		CURRENT_CRUSADE_TARGET = cm:load_value("CURRENT_CRUSADE_TARGET", "nil", context);
		CURRENT_CRUSADE_TARGET_OWNER = cm:load_value("CURRENT_CRUSADE_TARGET_OWNER", "nil", context);
		CRUSADE_INTRO_CUTSCENE_PLAYED = cm:load_value("CRUSADE_INTRO_CUTSCENE_PLAYED", false, context);
		MISSION_TAKE_JERUSALEM_ACTIVE = cm:load_value("MISSION_TAKE_JERUSALEM_ACTIVE", false, context);
		CURRENT_CRUSADE_TARGET_OWNED_REGIONS = LoadTable(context, "CURRENT_CRUSADE_TARGET_OWNED_REGIONS");
		CRUSADE_DEFENSIVE_FORCES = LoadTableNumbers(context, "CRUSADE_DEFENSIVE_FORCES");
		CURRENT_CRUSADE_FACTIONS_JOINED = LoadKeyPairTable(context, "CURRENT_CRUSADE_FACTIONS_JOINED");
	end
);
