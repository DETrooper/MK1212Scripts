---------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: HOLY ROMAN EMPIRE FACTIONS
-- 	By: DETrooper
--
---------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
-- Keeps track of which factions are in the HRE, and which faction is the emperor.

HRE_EMPEROR_KEY = "mk_fact_hre"; -- Starting emperor.
HRE_EMPEROR_CQI = 0;
HRE_EMPEROR_MISSION_AUTHORITY_REWARD = 25; -- The amount of Imperial Authority rewarded for beating a pretender.
HRE_EMPEROR_MISSION_WIN_TURN = 0;
HRE_EMPEROR_MISSION_ACTIVE = false;
HRE_EMPEROR_PRETENDER_KEY = "mk_fact_sicily"; -- Starting pretender, isn't in the HRE proper though.
HRE_EMPEROR_PRETENDER_COOLDOWN = 0; -- Every time a pretender is vanquished there will be a cooldown before the Pope can make a new one.
HRE_EMPEROR_PRETENDER_CQI = 0;
HRE_IMPERIAL_AUTHORITY_START = 40; -- Starting Imperial Authority. New emperors should also start with this amount.
HRE_IMPERIAL_AUTHORITY = 40; -- Imperial Authority (Can be spent on decrees, reforms, or in events).
HRE_IMPERIAL_AUTHORITY_GAIN_RATE = 1; -- Base Imperial Authority gain per turn.
HRE_IMPERIAL_AUTHORITY_GAIN_PER_REGION = 0.1; -- Imperial Authority gain per region in the HRE.
HRE_IMPERIAL_AUTHORITY_MIN = 0; -- Minimum Imperial Authority.
HRE_IMPERIAL_AUTHORITY_MAX = 100; -- Maximum Imperial Authority.
HRE_FACTION_STATE_CHANGE_COOLDOWN = 10; -- How many turns before a faction's state can change after it has been changed?

HRE_FRANKFURT_KEY = "att_reg_germania_uburzis";
HRE_FRANKFURT_STATUS = "capital";

FACTIONS_HRE = {};
FACTIONS_HRE_STATES = {};
FACTIONS_HRE_STATE_CHANGE_COOLDOWNS = {};

function Add_HRE_Faction_Listeners()
	cm:add_listener(
		"FactionTurnStart_HRE_Factions",
		"FactionTurnStart",
		true,
		function(context) FactionTurnStart_HRE_Factions(context) end,
		true
	);
	cm:add_listener(
		"CharacterBecomesFactionLeader_HRE_Factions",
		"CharacterBecomesFactionLeader",
		true,
		function(context) CharacterBecomesFactionLeader_HRE_Factions(context) end,
		true
	);
	cm:add_listener(
		"DilemmaChoiceMadeEvent_HRE_Pretender",
		"DilemmaChoiceMadeEvent",
		true,
		function(context) DilemmaChoiceMadeEvent_HRE_Pretender(context) end,
		true
	);
	cm:add_listener(
		"GarrisonOccupiedEvent_HRE_Frankfurt",
		"GarrisonOccupiedEvent",
		true,
		function(context) GarrisonOccupiedEvent_HRE_Frankfurt(context) end,
		true
	);
	cm:add_listener(
		"MissionIssued_HRE_Factions",
		"MissionIssued",
		true,
		function(context) MissionIssued_HRE_Factions(context) end,
		true
	);

	if cm:is_new_game() then
		FACTIONS_HRE = DeepCopy(FACTIONS_HRE_START);
		FACTIONS_HRE_STATES = DeepCopy(FACTIONS_HRE_STATES_START);
		HRE_EMPEROR_CQI = cm:model():world():faction_by_key(HRE_EMPEROR_KEY):faction_leader():command_queue_index();
		HRE_EMPEROR_PRETENDER_CQI = cm:model():world():faction_by_key(HRE_EMPEROR_PRETENDER_KEY):faction_leader():command_queue_index();

		for i = 1, #FACTIONS_HRE do
			FACTIONS_HRE_STATE_CHANGE_COOLDOWNS[FACTIONS_HRE[i]] = HRE_FACTION_STATE_CHANGE_COOLDOWN;
		end
	end

	HRE_Regions_Setup();
end

function FactionTurnStart_HRE_Factions(context)
	local faction_name = context:faction():name();

	if context:faction():name() == HRE_EMPEROR_KEY and CURRENT_HRE_REFORM < 9 then
		local faction_list = cm:model():world():faction_list();

		for i = 0, faction_list:num_items() - 1 do
			local current_faction = faction_list:item_at(i);

			if HasValue(FACTIONS_HRE, current_faction:name()) and current_faction:name() ~= HRE_EMPEROR_KEY then
				HRE_State_Check(current_faction:name());
			elseif current_faction:name() == HRE_EMPEROR_KEY then
				FACTIONS_HRE_STATES[current_faction:name()] = "emperor";
			elseif current_faction:name() == HRE_EMPEROR_PRETENDER_KEY then
				FACTIONS_HRE_STATES[current_faction:name()] = "pretender";
			else
				FACTIONS_HRE_STATES[current_faction:name()] = nil;
			end
		end

		HRE_IMPERIAL_AUTHORITY = HRE_Calculate_Imperial_Authority();

		if HRE_EMPEROR_PRETENDER_KEY == nil and PLAYER_EXCOMMUNICATED[HRE_EMPEROR_KEY] == true and HRE_EMPEROR_PRETENDER_COOLDOWN == 0 then
			HRE_Assign_New_Pretender(false);
		elseif HRE_EMPEROR_PRETENDER_KEY ~= nil then
			if cm:model():world():faction_by_key(HRE_EMPEROR_PRETENDER_KEY):has_home_region() == false then
				HRE_Vanquish_Pretender();
			end
		end

		if HRE_EMPEROR_PRETENDER_COOLDOWN > 0 then
			HRE_EMPEROR_PRETENDER_COOLDOWN = HRE_EMPEROR_PRETENDER_COOLDOWN - 1;
		end

		for k, v in pairs(FACTIONS_HRE_STATE_CHANGE_COOLDOWNS) do
			if FACTIONS_HRE_STATE_CHANGE_COOLDOWNS[k] > 0 then
				FACTIONS_HRE_STATE_CHANGE_COOLDOWNS[k] = FACTIONS_HRE_STATE_CHANGE_COOLDOWNS[k] - 1;
			end
		end

		if HRE_EMPEROR_MISSION_ACTIVE == false then
			if HRE_EMPEROR_PRETENDER_KEY ~= nil then
				cm:trigger_mission(HRE_EMPEROR_KEY, "mk_mission_story_hre_survive_pretender");
				HRE_EMPEROR_MISSION_ACTIVE = true;
			end
		else
			if cm:model():turn_number() == HRE_EMPEROR_MISSION_WIN_TURN then
				cm:override_mission_succeeded_status(HRE_EMPEROR_KEY, "mk_mission_story_hre_survive_pretender", true);
				cm:override_mission_succeeded_status(HRE_EMPEROR_PRETENDER_KEY, "mk_mission_story_pretender_take_frankfurt", false);

				HRE_Pretender_End_Mission(false, "time");
			elseif cm:model():world():faction_by_key(HRE_EMPEROR_PRETENDER_KEY):faction_leader():command_queue_index() ~= HRE_EMPEROR_PRETENDER_CQI then
				cm:override_mission_succeeded_status(HRE_EMPEROR_KEY, "mk_mission_story_hre_survive_pretender", true);
				cm:override_mission_succeeded_status(HRE_EMPEROR_PRETENDER_KEY, "mk_mission_story_pretender_take_frankfurt", false);

				HRE_Pretender_End_Mission(false, "death");
			elseif cm:model():world():faction_by_key(HRE_EMPEROR_KEY):faction_leader():command_queue_index() ~= HRE_EMPEROR_CQI then
				cm:override_mission_succeeded_status(HRE_EMPEROR_KEY, "mk_mission_story_hre_survive_pretender", false);
				cm:override_mission_succeeded_status(HRE_EMPEROR_PRETENDER_KEY, "mk_mission_story_pretender_take_frankfurt", true);

				HRE_Replace_Emperor(HRE_EMPEROR_PRETENDER_KEY);
			end
		end

		for i = 1, #FACTIONS_HRE do
			local faction_name = FACTIONS_HRE[i];
		
			if not FactionIsAlive(faction_name) then
				HRE_Remove_From_Empire(faction_name);
			end
		end

		for i = 1, #FACTIONS_HRE_START do
			local faction_name = FACTIONS_HRE_START[i];
		
			if FactionIsAlive(faction_name) and HasValue(FACTIONS_HRE, faction_name) == false then
				HRE_Add_To_Empire(faction_name);
			end	
		end
	end

	HRE_Button_Check(); -- Check every turn if the HRE panel should be hidden or not.
end

function CharacterBecomesFactionLeader_HRE_Factions(context)
	local faction_name = context:character():faction():name();
	local faction_state = HRE_Get_Faction_State(faction_name);

	-- When faction leaders of HRE member states die, set their attitude to neutral if not a puppet, then check to see if their state should be something else.
	if HasValue(FACTIONS_HRE, faction_name) and faction_name ~= HRE_EMPEROR_KEY then
		if faction_state ~= "puppet" then
			HRE_Set_Faction_State(faction_name, "neutral", true);
			HRE_State_Check(faction_name);
			Check_Faction_Votes_HRE_Elections(faction_name);
		end
	end

	if HRE_EMPEROR_PRETENDER_KEY ~= nil then
		if cm:model():world():faction_by_key(HRE_EMPEROR_PRETENDER_KEY):faction_leader():command_queue_index() ~= HRE_EMPEROR_PRETENDER_CQI then
			cm:override_mission_succeeded_status(HRE_EMPEROR_KEY, "mk_mission_story_hre_survive_pretender", true);
			cm:override_mission_succeeded_status(HRE_EMPEROR_PRETENDER_KEY, "mk_mission_story_pretender_take_frankfurt", false);

			HRE_Pretender_End_Mission(false, "death");
		elseif cm:model():world():faction_by_key(HRE_EMPEROR_KEY):faction_leader():command_queue_index() ~= HRE_EMPEROR_CQI then
			cm:override_mission_succeeded_status(HRE_EMPEROR_KEY, "mk_mission_story_hre_survive_pretender", false);
			cm:override_mission_succeeded_status(HRE_EMPEROR_PRETENDER_KEY, "mk_mission_story_pretender_take_frankfurt", true);

			HRE_Replace_Emperor(HRE_EMPEROR_PRETENDER_KEY);
		end
	elseif CURRENT_HRE_REFORM < 8 then
		if faction_name == HRE_EMPEROR_KEY then
			-- Emperor died and there was no pretender, so elect a new emperor!
			Process_Election_Result_HRE_Elections();
		end
	end
end

function DilemmaChoiceMadeEvent_HRE_Pretender(context)
	if context:dilemma() == "mk_dilemma_hre_pretender_nomination" then
		if context:choice() == 0 then
			-- Choice made to become a pretender!
			local pretender = cm:get_local_faction();

			HRE_EMPEROR_PRETENDER_KEY = pretender;
			local faction_string = "factions_screen_name_"..pretender;

			if FACTIONS_DFN_LEVEL[pretender] ~= nil then
				if FACTIONS_DFN_LEVEL[pretender] > 1 then
					faction_string = "campaign_localised_strings_string_"..pretender.."_lvl"..tostring(FACTIONS_DFN_LEVEL[pretender]);
				end
			end

			cm:show_message_event(
				cm:get_local_faction(),
				"message_event_text_text_mk_event_hre_pretender_nominated_title",
				faction_string,
				"message_event_text_text_mk_event_hre_pretender_nominated_secondary",
				true, 
				712
			);

			cm:force_declare_war(HRE_EMPEROR_KEY, pretender);
			SetFactionsHostile(pretender, HRE_EMPEROR_KEY);
			Refresh_HRE_Elections();
		elseif context:choice() == 1 then
			-- Choice made to reject the Pope's offer!
			HRE_Assign_New_Pretender(true);
		end

		HRE_Button_Check();
	end
end

function GarrisonOccupiedEvent_HRE_Frankfurt(context)
	local frankfurt_owner_name = cm:model():world():region_manager():region_by_key(HRE_FRANKFURT_KEY):owning_faction():name();

	if frankfurt_owner_name ~= nil then
		if HasValue(FACTIONS_HRE, frankfurt_owner_name) then
			if frankfurt_owner_name == HRE_EMPEROR_KEY then
				HRE_FRANKFURT_STATUS = "capital";
			else
				HRE_FRANKFURT_STATUS = "inside_hre";
			end
		else
			if frankfurt_owner_name == HRE_EMPEROR_PRETENDER_KEY then
				cm:override_mission_succeeded_status(HRE_EMPEROR_KEY, "mk_mission_story_hre_survive_pretender", false);
				cm:override_mission_succeeded_status(HRE_EMPEROR_PRETENDER_KEY, "mk_mission_story_pretender_take_frankfurt", true);

				HRE_Replace_Emperor(HRE_EMPEROR_PRETENDER_KEY);
			else
				HRE_FRANKFURT_STATUS = "outside_hre";
			end
		end
	else
		-- It's been razed.
		HRE_FRANKFURT_STATUS = "desolate";
	end

	HRE_Check_Regions_In_Empire();
end

function MissionIssued_HRE_Factions(context)
	local mission_name = context:mission():mission_record_key();

	if context:faction():name() == HRE_EMPEROR_PRETENDER_KEY then
		if mission_name == "mk_mission_story_pretender_take_frankfurt" then
			if HRE_FRANKFURT_STATUS == "capital" then
				cm:make_region_seen_in_shroud(context:faction():name(), HRE_FRANKFURT_KEY);
			end

			HRE_EMPEROR_MISSION_WIN_TURN = cm:model():turn_number() + 9;
		end
	elseif context:faction():name() == HRE_EMPEROR_KEY then
		if mission_name == "mk_mission_story_hre_survive_pretender" then
			HRE_EMPEROR_MISSION_WIN_TURN = cm:model():turn_number() + 9;
		end
	end
end

function HRE_State_Check(faction_name)
	-- Find which attitude an HRE member state should have towards the emperor.
	local faction_list = cm:model():world():faction_list();
	local faction = cm:model():world():faction_by_key(faction_name);
	local faction_state = HRE_Get_Faction_State(faction_name);
	local emperor_faction = cm:model():world():faction_by_key(HRE_EMPEROR_KEY);

	-- If the HRE member state is not malcontent but is at war with the emperor, make them malcontent.
	if faction_state ~= "malcontent" then
		if faction:at_war_with(emperor_faction) then
			HRE_Set_Faction_State(faction_name, "malcontent", true);
			return;
		end
	end

	if faction_state ~= "puppet" then
		if emperor_faction:is_human() then
			if HasValue(FACTIONS_VASSALIZED, faction_name) then
				HRE_Set_Faction_State(faction_name, "puppet", true);
				return;
			end
		end

		-- If the HRE member state is not a puppet and has an ally that is at war with the HRE, make them discontent.
		for i = 0, faction_list:num_items() - 1 do
			local possible_ally = faction_list:item_at(i);

			if faction:allied_with(possible_ally) == true and HasValue(FACTIONS_HRE, possible_ally:name()) then
				if possible_ally:at_war_with(emperor_faction) then
					HRE_Set_Faction_State(possible_ally:name(), "discontent", false);
					return;
				end
			end
		end
	end
end

function HRE_Calculate_Imperial_Authority()
	local authority = HRE_IMPERIAL_AUTHORITY;
	local gain = HRE_IMPERIAL_AUTHORITY_GAIN_RATE + (HRE_IMPERIAL_AUTHORITY_GAIN_PER_REGION * #HRE_REGIONS_IN_EMPIRE);

	if CURRENT_HRE_REFORM < 5 then
		authority = authority + gain;
	elseif CURRENT_HRE_REFORM >= 5 then
		authority = authority + (gain * 1.25);
	elseif CURRENT_HRE_REFORM >= 7 then
		authority = authority + (gain * 1.5);
	end

	if authority > HRE_IMPERIAL_AUTHORITY_MAX then
		authority = 100;
	elseif authority < HRE_IMPERIAL_AUTHORITY_MIN then
		authority = 0;
	end

	return authority;
end

function HRE_Check_Regions_In_Empire()
	local regions_in_empire = 0;

	for i = 1, #HRE_REGIONS do
		if HasValue(FACTIONS_HRE, cm:model():world():region_manager():region_by_key(HRE_REGIONS[i]):owning_faction():name()) then
			regions_in_empire = regions_in_empire + 1;
		end
	end

	HRE_REGIONS_IN_EMPIRE = regions_in_empire;
end

function HRE_Replace_Emperor(faction_name)
	local new_emperor_faction = cm:model():world():faction_by_key(faction_name);
	local old_emperor = HRE_EMPEROR_KEY;
	local old_emperor_faction = cm:model():world():faction_by_key(old_emperor);

	cm:set_faction_name_override(faction_name, "campaign_localised_strings_string_mk_faction_holy_roman_empire");

	if HRE_FRANKFURT_STATUS == "capital" and cm:model():world():region_manager():region_by_key(HRE_FRANKFURT_KEY):owning_faction():name() ~= faction_name then
		cm:transfer_region_to_faction(HRE_FRANKFURT_KEY, faction_name);
	end

	for i = 1, #FACTIONS_HRE do
		if FACTIONS_HRE[i] == old_emperor then
			if not HasValue(FACTIONS_HRE_START, old_emperor) then
				table.remove(FACTIONS_HRE, i);
				break;
			end
		end
	end

	if not HasValue(FACTIONS_HRE, faction_name) then
		table.insert(FACTIONS_HRE, faction_name);
	end

	-- Sicily has the option to divest its lands, so it should re-inherit them after losing the emperorship.
	if old_emperor == "mk_fact_sicily" and SICILY_DILEMMA_CHOICE == 1 then
		local turn_number = cm:model():turn_number();

		cm:grant_faction_handover(old_emperor, SICILY_SEPARATIST_KEY, turn_number-1, turn_number-1, context);
	end

	if CURRENT_HRE_REFORM > 0 then
		for i = 1, CURRENT_HRE_REFORM - 1 do
			cm:remove_effect_bundle("mk_effect_bundle_reform_"..tostring(i), old_emperor);
		end

		cm:apply_effect_bundle("mk_effect_bundle_reform_"..tostring(CURRENT_HRE_REFORM), faction_name, 0);
	end

	if HRE_ACTIVE_DECREE ~= "nil" then
		Deactivate_Decree(HRE_ACTIVE_DECREE);
	end

	if new_emperor_faction:is_human() then	
		Add_HRE_Event_Listeners();
	end

	if old_emperor_faction:is_human() then
		Remove_HRE_Event_Listeners();
	end

	HRE_Vanquish_Pretender();

	HRE_EMPEROR_KEY = faction_name;
	HRE_EMPEROR_CQI = cm:model():world():faction_by_key(faction_name):faction_leader():command_queue_index();
	HRE_IMPERIAL_AUTHORITY = HRE_IMPERIAL_AUTHORITY_START;

	HRE_Set_Faction_State(old_emperor, "neutral", true);
	HRE_Button_Check();

	DFN_Disable_Forming_Kingdoms(faction_name);
	DFN_Enable_Forming_Kingdoms(old_emperor);
	DFN_Refresh_Faction_Name(old_emperor); -- Make sure the old emperor isn't still named 'Holy Roman Empire'.
end

function HRE_Assign_New_Pretender(player_rejected)
	local faction_list = cm:model():world():faction_list();
	local emperor_faction = cm:model():world():faction_by_key(HRE_EMPEROR_KEY);
	local pretender = nil;
	local pretender_weight = 0;

	for i = 0, faction_list:num_items() - 1 do
		local current_faction = faction_list:item_at(i);
		local current_faction_name = current_faction:name();

		if HasValue(FACTIONS_HRE, current_faction_name) ~= true and current_faction:state_religion() == "att_rel_chr_catholic" then
			if current_faction:allied_with(emperor_faction) ~= true and PLAYER_EXCOMMUNICATED[current_faction_name] ~= true then
				local forces = current_faction:military_force_list();
				local num_regions = current_faction:region_list():num_items();
				local num_units = 0;

				for j = 0, forces:num_items() - 1 do
					local force = forces:item_at(j);
					local unit_list = forces:item_at(i):unit_list();

					num_units = num_units + unit_list:num_items();
				end

				local weight = num_units + (num_regions * 10);

				if weight > pretender_weight then
					if current_faction:is_human() then
						if player_rejected == false then
							pretender = current_faction_name;
							pretender_weight = weight;
						end
					else
						pretender = current_faction_name;
						pretender_weight = weight;
					end
				end
			end
		end
	end

	if pretender ~= nil then
		if cm:model():world():faction_by_key(pretender):is_human() then
			cm:trigger_dilemma(faction_name, "mk_dilemma_hre_pretender_nomination");
		else
			HRE_EMPEROR_PRETENDER_KEY = pretender;
			HRE_EMPEROR_PRETENDER_CQI = cm:model():world():faction_by_key(pretender):faction_leader():command_queue_index();
			local faction_string = "factions_screen_name_"..pretender;

			if FACTIONS_DFN_LEVEL[pretender] ~= nil then
				if FACTIONS_DFN_LEVEL[pretender] > 1 then
					faction_string = "campaign_localised_strings_string_"..pretender.."_lvl"..tostring(FACTIONS_DFN_LEVEL[pretender]);
				end
			end

			cm:show_message_event(
				cm:get_local_faction(),
				"message_event_text_text_mk_event_hre_pretender_nominated_title",
				faction_string,
				"message_event_text_text_mk_event_hre_pretender_nominated_secondary",
				true, 
				712
			);

			cm:force_declare_war(HRE_EMPEROR_KEY, pretender);
			SetFactionsHostile(pretender, HRE_EMPEROR_KEY);
		end
	else
		-- Something went horribly wrong and there's no viable pretender.
		HRE_Vanquish_Pretender(); -- Reset cooldown.
	end

	Refresh_HRE_Elections();
	HRE_Button_Check();
end

function HRE_Vanquish_Pretender()
	local emperor_faction = cm:model():world():faction_by_key(HRE_EMPEROR_KEY);
	local pretender_faction = cm:model():world():faction_by_key(HRE_EMPEROR_PRETENDER_KEY);

	if pretender_faction:at_war_with(emperor_faction) then
		cm:force_make_peace(HRE_EMPEROR_KEY, HRE_EMPEROR_PRETENDER_KEY);
	end

	SetFactionsNeutral(HRE_EMPEROR_KEY, HRE_EMPEROR_PRETENDER_KEY);

	HRE_EMPEROR_PRETENDER_COOLDOWN = 10;
	HRE_EMPEROR_PRETENDER_KEY = nil;

	Refresh_HRE_Elections();
	HRE_Button_Check();
end

function HRE_Pretender_End_Mission(success, reason)
	HRE_EMPEROR_MISSION_ACTIVE = false;
	HRE_EMPEROR_MISSION_WIN_TURN = 0;

	for i = 1, #FACTIONS_HRE do
		if FACTIONS_HRE[i] ~= HRE_EMPEROR_KEY then
			-- Re-enable war in case it's still disabled.
			cm:force_diplomacy(FACTIONS_HRE[i], HRE_EMPEROR_KEY, "war", true, true);
		end
	end

	if success == false then
		HRE_Change_Imperial_Authority(HRE_EMPEROR_MISSION_AUTHORITY_REWARD);

		if reason == "death" then
			cm:show_message_event(
				HRE_EMPEROR_PRETENDER_KEY,
				"message_event_text_text_mk_event_sic_lost_claim_title", 
				"message_event_text_text_mk_event_sic_lost_claim_primary", 
				"message_event_text_text_mk_event_sic_lost_claim_secondary_death", 
				true,
				713
			);
		else
			cm:show_message_event(
				HRE_EMPEROR_PRETENDER_KEY,
				"message_event_text_text_mk_event_sic_lost_claim_title", 
				"message_event_text_text_mk_event_sic_lost_claim_primary", 
				"message_event_text_text_mk_event_sic_lost_claim_secondary", 
				true,
				713
			);
		end

		HRE_Vanquish_Pretender();
	end
end

function HRE_Set_Faction_State(faction_name, state, ignore_cooldown)
	if ignore_cooldown == true or FACTIONS_HRE_STATE_CHANGE_COOLDOWNS[faction_name] == 0 then
		FACTIONS_HRE_STATES[faction_name] = state;
		FACTIONS_HRE_STATE_CHANGE_COOLDOWNS[faction_name] = HRE_FACTION_STATE_CHANGE_COOLDOWN;
		Refresh_HRE_Elections();
	end
end

function HRE_Get_Faction_State(faction_name)
	if FACTIONS_HRE_STATES[faction_name] == nil then
		FACTIONS_HRE_STATES[faction_name] = "neutral";
	end

	return FACTIONS_HRE_STATES[faction_name];
end

function HRE_Add_To_Empire(faction_name)
	if not HasValue(FACTIONS_HRE, faction_name) then
		table.insert(FACTIONS_HRE, faction_name);
	end
	
	HRE_State_Check(faction_name);
end

function HRE_Remove_From_Empire(faction_name)
	for i = 1, #FACTIONS_HRE do
		if FACTIONS_HRE[i] == faction_name then
			FACTIONS_HRE_STATES[faction_name] = nil;
			FACTIONS_HRE_STATE_CHANGE_COOLDOWNS[faction_name] = 0;
			table.remove(FACTIONS_HRE, i);
		end	
	end

	Refresh_HRE_Elections();
end

function HRE_Change_Imperial_Authority(amount)
	local authority = HRE_IMPERIAL_AUTHORITY + amount;

	if authority > HRE_IMPERIAL_AUTHORITY_MAX then
		authority = 100;
	elseif authority < HRE_IMPERIAL_AUTHORITY_MIN then
		authority = 0;
	end

	HRE_IMPERIAL_AUTHORITY = authority;
end

function Get_Authority_Tooltip()
	local num_regions = #HRE_REGIONS_IN_EMPIRE;

	local authoritystring = "Current Imperial Authority: "..Round_Number_Text(HRE_IMPERIAL_AUTHORITY);
	authoritystring = authoritystring.."\n\nEmperorship Held: [[rgba:8:201:27:150]]+"..Round_Number_Text(HRE_IMPERIAL_AUTHORITY_GAIN_RATE).."[[/rgba]]";
	authoritystring = authoritystring.."\nRegions in the HRE: [[rgba:8:201:27:150]]+"..Round_Number_Text(HRE_IMPERIAL_AUTHORITY_GAIN_PER_REGION * num_regions).."[[/rgba]]";

	if CURRENT_HRE_REFORM >= 5 then
		authoritystring = authoritystring.."\nReforms: [[rgba:8:201:27:150]]+25%[[/rgba]]";
	elseif CURRENT_HRE_REFORM >= 7 then
		authoritystring = authoritystring.."\nReforms: [[rgba:8:201:27:150]]+50%[[/rgba]]";
	end

	if HRE_IMPERIAL_AUTHORITY == HRE_IMPERIAL_AUTHORITY_MAX then
		authoritystring = authoritystring.."\n\nProjected Growth: [[rgba:255:0:0:150]]None[[/rgba]]";
		authoritystring = authoritystring.."\nProjected Imperial Authority: [[rgba:8:201:27:150]]100[[/rgba]]";
	elseif HRE_Calculate_Imperial_Authority() > HRE_IMPERIAL_AUTHORITY_MAX then
		authoritystring = authoritystring.."\n\nProjected Growth: [[rgba:255:255:0:150]]+"..Round_Number_Text(HRE_Calculate_Imperial_Authority() - HRE_IMPERIAL_AUTHORITY_MAX).."[[/rgba]]";
		authoritystring = authoritystring.."\nProjected Imperial Authority: [[rgba:8:201:27:150]]100[/rgba]]";
	else
		authoritystring = authoritystring.."\n\nProjected Growth: [[rgba:8:201:27:150]]+"..Round_Number_Text(HRE_Calculate_Imperial_Authority() - HRE_IMPERIAL_AUTHORITY).."[[/rgba]]";
		authoritystring = authoritystring.."\nProjected Imperial Authority: [[rgba:8:201:27:150]]"..Round_Number_Text(HRE_Calculate_Imperial_Authority()).."[[/rgba]]";
	end

	return authoritystring;
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		SaveTable(context, FACTIONS_HRE, "FACTIONS_HRE");
		SaveKeyPairTable(context, FACTIONS_HRE_STATES, "FACTIONS_HRE_STATES");
		SaveKeyPairTable(context, FACTIONS_HRE_STATE_CHANGE_COOLDOWNS, "FACTIONS_HRE_STATE_CHANGE_COOLDOWNS");
		cm:save_value("HRE_EMPEROR_KEY", HRE_EMPEROR_KEY, context);
		cm:save_value("HRE_EMPEROR_CQI", HRE_EMPEROR_CQI, context);
		cm:save_value("HRE_EMPEROR_MISSION_ACTIVE", HRE_EMPEROR_MISSION_ACTIVE, context);
		cm:save_value("HRE_EMPEROR_MISSION_WIN_TURN", HRE_EMPEROR_MISSION_WIN_TURN, context);
		cm:save_value("HRE_EMPEROR_PRETENDER_KEY", HRE_EMPEROR_PRETENDER_KEY, context);
		cm:save_value("HRE_EMPEROR_PRETENDER_CQI", HRE_EMPEROR_PRETENDER_CQI, context);
		cm:save_value("HRE_EMPEROR_PRETENDER_COOLDOWN", HRE_EMPEROR_PRETENDER_COOLDOWN, context);
		cm:save_value("HRE_IMPERIAL_AUTHORITY", HRE_IMPERIAL_AUTHORITY, context);
		cm:save_value("HRE_FRANKFURT_STATUS", HRE_FRANKFURT_STATUS, context);
		cm:save_value("HRE_REGIONS_IN_EMPIRE", HRE_REGIONS_IN_EMPIRE, context);
	end
);

cm:register_loading_game_callback(
	function(context)
		FACTIONS_HRE = LoadTable(context, "FACTIONS_HRE");
		FACTIONS_HRE_STATES = LoadKeyPairTable(context, "FACTIONS_HRE_STATES");
		FACTIONS_HRE_STATE_CHANGE_COOLDOWNS = LoadKeyPairTableNumbers(context, "FACTIONS_HRE_STATE_CHANGE_COOLDOWNS");
		HRE_EMPEROR_KEY = cm:load_value("HRE_EMPEROR_KEY", "mk_fact_hre", context);
		HRE_EMPEROR_CQI = cm:load_value("HRE_EMPEROR_CQI", 0, context);
		HRE_EMPEROR_MISSION_ACTIVE = cm:load_value("HRE_EMPEROR_MISSION_ACTIVE", false, context);
		HRE_EMPEROR_MISSION_WIN_TURN = cm:load_value("HRE_EMPEROR_MISSION_WIN_TURN", 0, context);
		HRE_EMPEROR_PRETENDER_KEY = cm:load_value("HRE_EMPEROR_PRETENDER_KEY", "mk_fact_sicily", context);
		HRE_EMPEROR_PRETENDER_CQI = cm:load_value("HRE_EMPEROR_PRETENDER_CQI", 0, context);
		HRE_EMPEROR_PRETENDER_COOLDOWN = cm:load_value("HRE_EMPEROR_PRETENDER_COOLDOWN", 0, context);
		HRE_IMPERIAL_AUTHORITY = cm:load_value("HRE_IMPERIAL_AUTHORITY", 40, context);
		HRE_FRANKFURT_STATUS = cm:load_value("HRE_FRANKFURT_STATUS", "capital", context);
		HRE_REGIONS_IN_EMPIRE = cm:load_value("HRE_REGIONS_IN_EMPIRE", 21, context);
	end
);