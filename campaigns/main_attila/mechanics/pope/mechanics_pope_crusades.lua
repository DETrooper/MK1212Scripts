 ------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: POPE CRUSADES
-- 	By: DETrooper
--
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
-- System for crusades. Deus Vult!

require("mechanics/pope/mechanics_pope_crusades_cutscenes");
CRUSADE_CUTSCENES_ENABLED = true; -- default to true

CRUSADE_JOINED = {};

CURRENT_CRUSADE_TARGET = "nil";
CURRENT_CRUSADE_TARGET_OWNER = "nil";
CRUSADE_DEFENSIVE_FORCES = {};
CRUSADE_DEFENSE_UNIT_LIST = 	"mk_ayy_t1_jund_spearmen,mk_ayy_t1_jund_spearmen,mk_ayy_t1_jund_spearmen,mk_ayy_t1_jund_spearmen,".. -- Spears
				"mk_ayy_t1_jund_swordsmen,mk_ayy_t1_jund_swordsmen,mk_ayy_t1_jund_swordsmen,mk_ayy_t1_jund_swordsmen,".. -- Swords
				"mk_ayy_t1_crossbowmen,mk_ayy_t1_crossbowmen,mk_ayy_t1_crossbowmen"; -- Ranged

MISSION_TAKE_JERUSALEM_ACTIVE = false;
JERUSALEM_REGION_KEY = "att_reg_palaestinea_aelia_capitolina";
ALEXANDRIA_REGION_KEY = "att_reg_aegyptus_alexandria";

FIFTH_CRUSADE_TRIGGERED = false;
FIFTH_CRUSADE_TARGET = "att_reg_aegyptus_oxyrhynchus";
FIFTH_CRUSADE_CUTSCENE_PLAYED = false;
FIFTH_CRUSADE_MESSAGE_TURN = 4;
FIFTH_CRUSADE_START_TURN = 6;
FIFTH_CRUSADE_END_TURN = 17;
FIFTH_CRUSADE_ENDED = false;

SEVENTH_CRUSADE_TRIGGERED = false;
SEVENTH_CRUSADE_MIN_START_TURN = 35;
SEVENTH_CRUSADE_MAX_START_TURN = 40;
SEVENTH_CRUSADE_ENDED = false;

EIGHTH_CRUSADE_TRIGGERED = false;
EIGHTH_CRUSADE_MIN_START_TURN = 55;
EIGHTH_CRUSADE_MAX_START_TURN = 60;
EIGHTH_CRUSADE_ENDED = false;

FRANCE_KEY = "mk_fact_france";
HRE_KEY = "mk_fact_hre";
HUNGARY_KEY = "mk_fact_hungary";
JERUSALEM_KEY = "mk_fact_jerusalem";


FIFTH_CRUSADE_REGIONS = {
	"att_reg_aegyptus_alexandria",
	"att_reg_aegyptus_oxyrhynchus",
	"att_reg_aegyptus_berenice",
	"att_reg_arabia_magna_dumatha",
	"att_reg_arabia_magna_yathrib",
	"att_reg_libya_augila",
	"att_reg_libya_paraetonium",
	"att_reg_libya_ptolemais",
	"att_reg_palaestinea_aelia_capitolina",
	"att_reg_palaestinea_aila",
	"att_reg_palaestinea_nova_trajana_bostra",
	"att_reg_syria_emesa"
};

local scripting = require "lua_scripts.episodicscripting";
local dev = require("lua_scripts.dev");
local util = require "lua_scripts.util";

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

	GetCutsceneOptions();

	if cm:is_new_game() then	
		local faction_list = cm:model():world():faction_list();

		for i = 0, faction_list:num_items() - 1 do
			local current_faction = faction_list:item_at(i);
			CRUSADE_JOINED[current_faction:name()] = "not joined";
		end
	end
end

function GetCutsceneOptions()
	if util.fileExists("MK1212_config.txt") == true then
		if tonumber(dev.settings["cutscenesEnabled"]) == 0 then
			CRUSADE_CUTSCENES_ENABLED = false;
		else
			CRUSADE_CUTSCENES_ENABLED = true;
		end
	else
		writeSettings("MK1212_config.txt");
	end
end

function FactionTurnStart_Pope_Crusades(context)
	if cm:model():turn_number() == FIFTH_CRUSADE_MESSAGE_TURN and FIFTH_CRUSADE_TRIGGERED == false then
		local owner = cm:model():world():region_manager():region_by_key(FIFTH_CRUSADE_TARGET):owning_faction();
		if owner:state_religion() == "mk_rel_shia_islam" or owner:state_religion() == "att_rel_semitic_paganism" then
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

	if cm:model():turn_number() == FIFTH_CRUSADE_START_TURN then
		if FIFTH_CRUSADE_TRIGGERED == false then
			local owner = cm:model():world():region_manager():region_by_key(FIFTH_CRUSADE_TARGET):owning_faction();

			if owner:state_religion() == "mk_rel_shia_islam" or owner:state_religion() == "att_rel_semitic_paganism" then
				FIFTH_CRUSADE_TRIGGERED = true;
				CURRENT_CRUSADE_TARGET_OWNER = owner:name();
				CURRENT_CRUSADE_TARGET = FIFTH_CRUSADE_TARGET;

				if cm:is_multiplayer() == false then
					cm:make_region_seen_in_shroud(context:faction():name(), FIFTH_CRUSADE_TARGET);
				end
			else
				local faction_name = (cm:model():faction_for_command_queue_index(human_factions[1])):name();
				cm:show_message_event(
					faction_name,
					"message_event_text_text_mk_event_crusade_fifth_crusade_title", 
					"message_event_text_text_mk_event_crusade_fifth_crusade_aborted_primary", 
					"message_event_text_text_mk_event_crusade_fifth_crusade_aborted_secondary", 
					true,
					706
				);

				if human_factions[2] ~= nil then 
					local faction_name = (cm:model():faction_for_command_queue_index(human_factions[2])):name();
					cm:show_message_event(
						faction_name,
						"message_event_text_text_mk_event_crusade_fifth_crusade_title", 
						"message_event_text_text_mk_event_crusade_fifth_crusade_aborted_primary", 
						"message_event_text_text_mk_event_crusade_fifth_crusade_aborted_secondary", 
						true,
						706
					);
				end
			end

			if FIFTH_CRUSADE_TRIGGERED == true then
				if FIFTH_CRUSADE_CUTSCENE_PLAYED == false and CRUSADE_CUTSCENES_ENABLED == true then
					ui_state.events_rollout:set_allowed(false, true);
					ui_state.events_panel:set_allowed(false, true);
					Cutscene_Fifth_Crusade_Play();
					FIFTH_CRUSADE_CUTSCENE_PLAYED = true;
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

					if cm:model():world():region_manager():region_by_key(FIFTH_CRUSADE_TARGET):owning_faction() == owner then
						CreateDefensiveArmy_Crusades(FIFTH_CRUSADE_TARGET, force);
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
		elseif context:faction():is_human() == false and FIFTH_CRUSADE_TRIGGERED == true then
			local owner = cm:model():world():region_manager():region_by_key(FIFTH_CRUSADE_TARGET):owning_faction();

			if context:faction():name() == FRANCE_KEY or context:faction():name() == HRE_KEY or context:faction():name() == HUNGARY_KEY or context:faction():name() == JERUSALEM_KEY then
				if context:faction():at_war_with(owner) == false then
					cm:force_declare_war(context:faction():name(), owner:name());
				end

				cm:force_diplomacy(context:faction():name(), CURRENT_CRUSADE_TARGET_OWNER, "peace", false, false);
				cm:force_diplomacy(CURRENT_CRUSADE_TARGET_OWNER, context:faction():name(), "peace", false, false);
			end
		end
	end

	if cm:model():turn_number() == FIFTH_CRUSADE_END_TURN and FIFTH_CRUSADE_TRIGGERED == true and FIFTH_CRUSADE_ENDED == false then
		Defeat_Crusade();
		cm:override_mission_succeeded_status(context:faction():name(), "mk_mission_crusades_take_cairo", false);
	end
end

function DilemmaChoiceMadeEvent_Crusades(context)
	if context:dilemma() == "mk_dilemma_crusades_join_fifth_crusade" then
		local faction_name = context:faction():name();
		local owner = cm:model():world():region_manager():region_by_key(CURRENT_CRUSADE_TARGET):owning_faction();
		if context:choice() == 0 then
			-- Choice made to join the crusade!
			cm:force_declare_war(faction_name, CURRENT_CRUSADE_TARGET_OWNER);
			--SetFactionsHostile(faction_name, CURRENT_CRUSADE_TARGET_OWNER);
			cm:force_diplomacy(faction_name, CURRENT_CRUSADE_TARGET_OWNER, "peace", false, false);
			cm:force_diplomacy(CURRENT_CRUSADE_TARGET_OWNER, faction_name, "peace", false, false);
			cm:trigger_mission(faction_name, "mk_mission_crusades_take_cairo");

			cm:show_message_event(
				faction_name, 
				"message_event_text_text_mk_event_crusade_fifth_crusade_title", 
				"message_event_text_text_mk_event_crusade_fifth_crusade_joined_primary", 
				"message_event_text_text_mk_event_crusade_fifth_crusade_joined_secondary", 
				true,
				706
			);

			if PLAYER_EXCOMMUNICATED[faction_name] == true then
				Remove_Excommunication_Manual(faction_name);
			end

			Add_Pope_Favour(faction_name, 2, "joined_crusade");
			Update_Pope_Favour(context:faction());
		elseif context:choice() == 1 then
			-- Choice made to stay out of the crusades!
			cm:show_message_event(
				faction_name, 
				"message_event_text_text_mk_event_crusade_fifth_crusade_title", 
				"message_event_text_text_mk_event_crusade_fifth_crusade_abstain_primary", 
				"message_event_text_text_mk_event_crusade_fifth_crusade_abstain_secondary", 
				true,
				706
			);

			Subtract_Pope_Favour(faction_name, 2, "abstained_crusade");
			Update_Pope_Favour(context:faction());
		end
	elseif context:dilemma() == "mk_dilemma_crusades_end_fifth_crusade" then
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

			for i = 1, #FIFTH_CRUSADE_REGIONS do
				local region = cm:model():world():region_manager():region_by_key(FIFTH_CRUSADE_REGIONS[i]);
		
				if region:owning_faction():name() == faction_name then
					cm:transfer_region_to_faction(FIFTH_CRUSADE_REGIONS[i], JERUSALEM_KEY);
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
			cm:transfer_region_to_faction(FIFTH_CRUSADE_TARGET, JERUSALEM_KEY);

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
	if FIFTH_CRUSADE_TRIGGERED == true and FIFTH_CRUSADE_ENDED == false then
		if context:character():has_region() and context:character():region():name() == CURRENT_CRUSADE_TARGET then
			if context:character():faction():state_religion() == "att_rel_chr_catholic" then
				cm:override_mission_succeeded_status(context:character():faction():name(), "mk_mission_crusades_take_cairo", true);
				Victory_Crusade();
			end
		elseif context:character():faction():state_religion() == "att_rel_chr_orthodox" or context:character():faction():state_religion() == "att_rel_church_east" then
			cm:cancel_custom_mission(context:character():faction():name(), "mk_mission_crusades_take_cairo");
			Abort_Crusade();
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
		Defeat_Crusade();
	end
end

function Abort_Crusade()
	FIFTH_CRUSADE_ENDED = true;

	if CURRENT_CRUSADE_TARGET_OWNER == "mk_fact_ayyubids" then
		cm:override_mission_succeeded_status(CURRENT_CRUSADE_TARGET_OWNER, "mk_mission_story_ayyubids_crusade_defense", false);
	end

	if cm:model():world():faction_by_key(CURRENT_CRUSADE_TARGET_OWNER):is_human() == false then
		Purge_Crusade_Defensive_Armies();
	end

	Remove_Crusade_Effects();
	cm:remove_listener("CharacterEntersGarrison_Crusade");

	local faction_list = cm:model():world():faction_list();

	for i = 0, faction_list:num_items() - 1 do
		local possible_christian_faction = faction_list:item_at(j);

		cm:show_message_event(
			possible_christian_faction:name(),
			"message_event_text_text_mk_event_crusade_fifth_crusade_title", 
			"message_event_text_text_mk_event_crusade_fifth_crusade_aborted_primary", 
			"message_event_text_text_mk_event_crusade_fifth_crusade_aborted_secondary", 
			true,
			706
		);
			
		if possible_christian_faction:state_religion() == "att_rel_chr_catholic" and possible_christian_faction:at_war_with(cm:model():world():faction_by_key(CURRENT_CRUSADE_TARGET_OWNER)) then
			cm:force_diplomacy(possible_christian_faction:name(), CURRENT_CRUSADE_TARGET_OWNER, "peace", true, true);
			cm:force_diplomacy(CURRENT_CRUSADE_TARGET_OWNER, possible_christian_faction:name(), "peace", true, true);
			cm:force_make_peace(CURRENT_CRUSADE_TARGET_OWNER, possible_christian_faction:name());

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
end

function Defeat_Crusade()
	FIFTH_CRUSADE_ENDED = true;

	if CURRENT_CRUSADE_TARGET_OWNER == "mk_fact_ayyubids" then
		cm:override_mission_succeeded_status(CURRENT_CRUSADE_TARGET_OWNER, "mk_mission_story_ayyubids_crusade_defense", true);
	end

	if cm:model():world():faction_by_key(CURRENT_CRUSADE_TARGET_OWNER):is_human() == false then
		Purge_Crusade_Defensive_Armies();
	end

	Remove_Crusade_Effects();
	cm:remove_listener("CharacterEntersGarrison_Crusade");

	local faction_list = cm:model():world():faction_list();

	for i = 0, faction_list:num_items() - 1 do
		local possible_christian_faction = faction_list:item_at(i);

		cm:show_message_event(
			possible_christian_faction:name(),
			"message_event_text_text_mk_event_crusade_fifth_crusade_title", 
			"message_event_text_text_mk_event_crusade_fifth_crusade_lost_primary", 
			"message_event_text_text_mk_event_crusade_fifth_crusade_lost_secondary", 
			true,
			706
		);
			
		if possible_christian_faction:state_religion() == "att_rel_chr_catholic" and possible_christian_faction:at_war_with(cm:model():world():faction_by_key(CURRENT_CRUSADE_TARGET_OWNER)) then
			cm:force_diplomacy(possible_christian_faction:name(), CURRENT_CRUSADE_TARGET_OWNER, "peace", true, true);
			cm:force_diplomacy(CURRENT_CRUSADE_TARGET_OWNER, possible_christian_faction:name(), "peace", true, true);
			cm:force_make_peace(CURRENT_CRUSADE_TARGET_OWNER, possible_christian_faction:name());
			cm:apply_effect_bundle("mk_bundle_crusade_failure", possible_christian_faction:name(), 10);

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
end

function Victory_Crusade()
	FIFTH_CRUSADE_ENDED = true;

	if CURRENT_CRUSADE_TARGET_OWNER == "mk_fact_ayyubids" then
		cm:override_mission_succeeded_status(CURRENT_CRUSADE_TARGET_OWNER, "mk_mission_story_ayyubids_crusade_defense", false);
	end

	if cm:model():world():faction_by_key(CURRENT_CRUSADE_TARGET_OWNER):is_human() == false then
		Purge_Crusade_Defensive_Armies();
	end

	Remove_Crusade_Effects();
	cm:remove_listener("CharacterEntersGarrison_Crusade");

	local faction_list = cm:model():world():faction_list();
	local owner = cm:model():world():region_manager():region_by_key(FIFTH_CRUSADE_TARGET):owning_faction();

	for i = 1, #FIFTH_CRUSADE_REGIONS do
		local region = cm:model():world():region_manager():region_by_key(FIFTH_CRUSADE_REGIONS[i]);
		
		if region:owning_faction():state_religion() == "att_rel_chr_catholic" and region:owning_faction():is_human() == false then
			cm:transfer_region_to_faction(FIFTH_CRUSADE_REGIONS[i], JERUSALEM_KEY);
		end
	end

	for i = 0, faction_list:num_items() - 1 do
		local possible_christian_faction = faction_list:item_at(i);
		
		cm:show_message_event(
			possible_christian_faction:name(),
			"message_event_text_text_mk_event_crusade_fifth_crusade_title", 
			"message_event_text_text_mk_event_crusade_fifth_crusade_won_primary", 
			"message_event_text_text_mk_event_crusade_fifth_crusade_won_secondary", 
			true,
			706
		);
			
		if possible_christian_faction:state_religion() == "att_rel_chr_catholic" and possible_christian_faction:at_war_with(cm:model():world():faction_by_key(CURRENT_CRUSADE_TARGET_OWNER)) then
			cm:force_diplomacy(possible_christian_faction:name(), CURRENT_CRUSADE_TARGET_OWNER, "peace", true, true);
			cm:force_diplomacy(CURRENT_CRUSADE_TARGET_OWNER, possible_christian_faction:name(), "peace", true, true);
			cm:apply_effect_bundle("mk_bundle_crusade_victory", possible_christian_faction:name(), 10);
			Add_Pope_Favour(possible_christian_faction:name(), 10, "crusade_victory");

			if possible_christian_faction:is_human() == false or (possible_christian_faction:is_human() == true and possible_christian_faction:name() == JERUSALEM_KEY) or (possible_christian_faction:is_human() == true and possible_christian_faction ~= owner) then
				cm:force_make_peace(CURRENT_CRUSADE_TARGET_OWNER, possible_christian_faction:name());

				for j = 0, faction_list:num_items() - 1 do
					local possible_ally = faction_list:item_at(j);
					
					if possible_christian_faction:allied_with(possible_ally) == true and possible_ally:at_war_with(cm:model():world():faction_by_key(CURRENT_CRUSADE_TARGET_OWNER)) and possible_ally:is_human() == false then
						cm:force_make_peace(CURRENT_CRUSADE_TARGET_OWNER, possible_ally:name());
					end
				end
			elseif possible_christian_faction:is_human() == true and possible_christian_faction:name() == owner:name() then
				cm:trigger_dilemma(possible_christian_faction:name(), "mk_dilemma_crusades_end_fifth_crusade");
			else		
				cm:force_make_peace(CURRENT_CRUSADE_TARGET_OWNER, possible_christian_faction:name());
			end
		end
	end

	CURRENT_CRUSADE_TARGET = "nil";
	CURRENT_CRUSADE_TARGET_OWNER = "nil";
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
		cm:save_value("CURRENT_CRUSADE_TARGET", CURRENT_CRUSADE_TARGET, context);
		cm:save_value("CURRENT_CRUSADE_TARGET_OWNER", CURRENT_CRUSADE_TARGET_OWNER, context);
		cm:save_value("MISSION_TAKE_JERUSALEM_ACTIVE", MISSION_TAKE_JERUSALEM_ACTIVE, context);
		cm:save_value("FIFTH_CRUSADE_TRIGGERED", FIFTH_CRUSADE_TRIGGERED, context);
		cm:save_value("FIFTH_CRUSADE_CUTSCENE_PLAYED", FIFTH_CRUSADE_CUTSCENE_PLAYED, context);
		cm:save_value("SEVENTH_CRUSADE_TRIGGERED", SEVENTH_CRUSADE_TRIGGERED, context);
		cm:save_value("EIGHTH_CRUSADE_TRIGGERED", EIGHTH_CRUSADE_TRIGGERED, context);
		cm:save_value("FIFTH_CRUSADE_ENDED", FIFTH_CRUSADE_ENDED, context);
		cm:save_value("SEVENTH_CRUSADE_ENDED", SEVENTH_CRUSADE_ENDED, context);
		cm:save_value("EIGHTH_CRUSADE_ENDED", EIGHTH_CRUSADE_ENDED, context);
		SaveTable(context, CRUSADE_DEFENSIVE_FORCES, "CRUSADE_DEFENSIVE_FORCES");
		SaveKeyPairTable(context, CRUSADE_JOINED, "CRUSADE_JOINED");
	end
);

cm:register_loading_game_callback(
	function(context)
		CURRENT_CRUSADE_TARGET = cm:load_value("CURRENT_CRUSADE_TARGET", "nil", context);
		CURRENT_CRUSADE_TARGET_OWNER = cm:load_value("CURRENT_CRUSADE_TARGET_OWNER", "nil", context);
		MISSION_TAKE_JERUSALEM_ACTIVE = cm:load_value("MISSION_TAKE_JERUSALEM_ACTIVE", false, context);
		FIFTH_CRUSADE_TRIGGERED = cm:load_value("FIFTH_CRUSADE_TRIGGERED", false, context);
		FIFTH_CRUSADE_CUTSCENE_PLAYED = cm:load_value("FIFTH_CRUSADE_CUTSCENE_PLAYED", false, context);
		SEVENTH_CRUSADE_TRIGGERED = cm:load_value("SEVENTH_CRUSADE_TRIGGERED", false, context);
		EIGHTH_CRUSADE_TRIGGERED = cm:load_value("EIGHTH_CRUSADE_TRIGGERED", false, context);
		FIFTH_CRUSADE_ENDED = cm:load_value("FIFTH_CRUSADE_ENDED", false, context);
		SEVENTH_CRUSADE_ENDED = cm:load_value("SEVENTH_CRUSADE_ENDED", false, context);
		EIGHTH_CRUSADE_ENDED = cm:load_value("EIGHTH_CRUSADE_ENDED", false, context);
		CRUSADE_DEFENSIVE_FORCES = LoadTableNumbers(context, "CRUSADE_DEFENSIVE_FORCES");
		CRUSADE_JOINED = LoadKeyPairTable(context, "CRUSADE_JOINED");
	end
);