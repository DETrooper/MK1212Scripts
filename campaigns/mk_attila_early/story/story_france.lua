------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - STORY: FRANCE
-- 	By: DETrooper
--
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------

FRANCE_KEY = "mk_fact_france";
ENGLAND_KEY = "mk_fact_england";
ENGLAND_REBEL_KEY = "mk_fact_earldoms";
TOULOUSE_KEY = "mk_fact_toulouse";
CATHAR_REVOLT_CRUSHED = false;
CATHAR_REVOLT_TRIGGERED = false;
CATHAR_REVOLT_TURN = 0;
ENGLISH_INVASION_TURN = 2;
FRANCE_MISSION_ACTIVE = false;
FRANCE_MISSION_WIN_TURN = 6;
FRANCE_MADE_PEACE = false;
FRANCE_SECOND_DILEMMA_ISSUED = false;

function Add_France_Story_Events_Listeners()
	local england = cm:model():world():faction_by_key(ENGLAND_KEY);
	local france = cm:model():world():faction_by_key(FRANCE_KEY);

	if france:is_human() == true then
		cm:add_listener(
			"FactionTurnStart_France",
			"FactionTurnStart",
			true,
			function(context) FactionTurnStart_France(context) end,
			true
		);
		cm:add_listener(
			"CharacterEntersGarrison_Toulouse",
			"CharacterEntersGarrison",
			true,
			function(context) CharacterEntersGarrison_Toulouse(context) end,
			true
		);
		cm:add_listener(
			"DilemmaChoiceMadeEvent_France",
			"DilemmaChoiceMadeEvent",
			true,
			function(context) DilemmaChoiceMadeEvent_France(context) end,
			true
		);
		cm:add_listener(
			"MissionSucceeded_France",
			"MissionSucceeded",
			true,
			function(context) MissionSucceeded_France(context) end,
			true
		);
		cm:add_listener(
			"MissionFailed_France",
			"MissionFailed",
			true,
			function(context) MissionFailed_France(context) end,
			true
		);

		if FRANCE_MISSION_ACTIVE == true then
 			cm:add_listener(
				"CharacterEntersGarrison_Normandy_France",
				"CharacterEntersGarrison",
				true,
				function(context) CharacterEntersGarrison_Normandy_France(context) end,
				true
			);
		end
	end
end

function FactionTurnStart_France(context)
	local france = cm:model():world():faction_by_key(FRANCE_KEY);
	local england = cm:model():world():faction_by_key(ENGLAND_KEY);
	local pretenders = cm:model():world():faction_by_key(ENGLAND_REBEL_KEY);
	local toulouse = cm:model():world():faction_by_key(TOULOUSE_KEY);

	if context:faction():name() == FRANCE_KEY then
		if cm:model():turn_number() == CATHAR_REVOLT_TURN then
			--cm:set_public_order_of_province_for_region("mk_reg_toulouse", -200);
			--cm:force_rebellion_in_region("mk_reg_toulouse", 0, cathar_force, 164, 411, true);
			--cm:force_rebellion_in_region("mk_reg_toulouse", 0, cathar_force, 159, 412, true);
			
			local difficulty = cm:model():difficulty_level();
			local unit_list = "";
			
			if difficulty >= 1 then
				unit_list = "mk_eng_t1_spear_militia,mk_eng_t1_spear_militia,mk_eng_t1_spear_militia,mk_eng_t1_serjeants,mk_eng_t1_serjeants,mk_eng_t1_longbowmen,mk_eng_t1_longbowmen,mk_eng_t1_longbowmen,mk_eng_t1_mounted_serjeants";
			elseif difficulty >= -1 then
				unit_list = "mk_eng_t1_spear_militia,mk_eng_t1_spear_militia,mk_eng_t1_spear_militia,mk_eng_t1_spear_militia,mk_eng_t1_serjeants,mk_eng_t1_serjeants,mk_eng_t1_serjeants,mk_eng_t1_longbowmen,mk_eng_t1_longbowmen,mk_eng_t1_longbowmen,mk_eng_t1_mounted_serjeants,mk_eng_t1_mounted_serjeants";
			else
				unit_list = "mk_eng_t1_spear_militia,mk_eng_t1_spear_militia,mk_eng_t1_spear_militia,mk_eng_t1_spear_militia,mk_eng_t1_serjeants,mk_eng_t1_serjeants,mk_eng_t1_serjeants,mk_eng_t1_serjeants,mk_eng_t1_axe_sergeant,mk_eng_t1_longbowmen,mk_eng_t1_longbowmen,mk_eng_t1_longbowmen,mk_eng_t1_mounted_serjeants,mk_eng_t1_mounted_serjeants";
			end

			cm:create_force(
				TOULOUSE_KEY,
				unit_list,
				"mk_reg_toulouse",
				164,
				411,
				"fra_cathar_revolt_1",
				true,
				function(cqi)
					cm:apply_effect_bundle_to_characters_force("mk_bundle_army_cathar_rebellion", cqi, -1, true);
				end
			);
			
			cm:create_force(
				TOULOUSE_KEY,
				unit_list,
				"mk_reg_toulouse",
				159,
				412,
				"fra_cathar_revolt_2",
				true,
				function(cqi)
					cm:apply_effect_bundle_to_characters_force("mk_bundle_army_cathar_rebellion", cqi, -1, true);
				end
			);

			cm:show_message_event(
				context:faction():name(),
				"message_event_text_text_mk_event_albigensian_crusade_title", 
				"message_event_text_text_mk_event_fra_cathar_revolt_primary", 
				"message_event_text_text_mk_event_fra_cathar_revolt_secondary", 
				true,
				702
			);
		end

		if france:at_war_with(toulouse) == false and cm:model():turn_number() == CATHAR_REVOLT_TURN + 1 then
			cm:force_declare_war(TOULOUSE_KEY, FRANCE_KEY);
		end

		if CATHAR_REVOLT_TRIGGERED == true and CATHAR_REVOLT_CRUSHED == false then
			if toulouse:is_null_interface() == true then
				CATHAR_REVOLT_CRUSHED = true;
				cm:show_message_event(
					FRANCE_KEY,
					"message_event_text_text_mk_event_albigensian_crusade_title", 
					"message_event_text_text_mk_event_fra_cathars_crushed_primary", 
					"message_event_text_text_mk_event_fra_cathars_crushed_secondary", 
					true,
					702
				);				
			end
		end

		if england:is_human() == false and cm:model():turn_number() == ENGLISH_INVASION_TURN then
			local region = cm:model():world():region_manager():region_by_key("mk_reg_rouen");

			if region:owning_faction():name() == ENGLAND_KEY then
				-- England somehow got Rouen on turn 1, maybe through region trading?
			else
				cm:force_declare_war(ENGLAND_KEY, FRANCE_KEY);

				cm:show_message_event(
					FRANCE_KEY,
					"message_event_text_text_mk_event_fra_english_invasion_title", 
					"message_event_text_text_mk_event_fra_english_invasion_primary", 
					"message_event_text_text_mk_event_fra_english_invasion_secondary", 
					true,
					711
				);

				cm:add_listener(
					"CharacterEntersGarrison_Normandy_France",
					"CharacterEntersGarrison",
					true,
					function(context) CharacterEntersGarrison_Normandy_France(context) end,
					true
				);

				cm:trigger_mission(FRANCE_KEY, "mk_mission_story_france_survive_invasion");
				FRANCE_MISSION_ACTIVE = true;
				SetFactionsHostile(ENGLAND_KEY, FRANCE_KEY);
			end
		end

		if cm:model():turn_number() == FRANCE_MISSION_WIN_TURN and FRANCE_MISSION_ACTIVE == true then
			local region = cm:model():world():region_manager():region_by_key("mk_reg_rouen");
		
			if region:owning_faction():name() == FRANCE_KEY then
				cm:override_mission_succeeded_status(FRANCE_KEY, "mk_mission_story_france_survive_invasion", true);
			else
				cm:override_mission_succeeded_status(FRANCE_KEY, "mk_mission_story_france_survive_invasion", false);
			end
		end

		if FRANCE_SECOND_DILEMMA_ISSUED == false and FRANCE_MADE_PEACE == false and pretenders:is_null_interface() == false and pretenders:at_war_with(england) == true and pretenders:allied_with(france) == false then
			cm:trigger_dilemma(FRANCE_KEY, "mk_dilemma_story_france_english_rebels_alliance");
			FRANCE_SECOND_DILEMMA_ISSUED = true;
		end
	elseif context:faction():name() == TOULOUSE_KEY then
		if france:at_war_with(toulouse) == false and cm:model():turn_number() == CATHAR_REVOLT_TURN and toulouse:is_null_interface() == false then
			cm:force_declare_war(TOULOUSE_KEY, FRANCE_KEY);
		end
	end
end

function DilemmaChoiceMadeEvent_France(context)
	local france = cm:model():world():faction_by_key(FRANCE_KEY);

	if context:dilemma() == "mk_dilemma_story_france_pursue_england" then
		if context:choice() == 0 then
			-- Choice made to push on to England!
		elseif context:choice() == 1 then
			-- Choice made to stay out of war!
			FRANCE_MADE_PEACE = true;

			cm:show_message_event(
				FRANCE_KEY,
				"message_event_text_text_mk_event_fra_english_invasion_title", 
				"message_event_text_text_mk_event_fra_english_invasion_victory_primary", 
				"message_event_text_text_mk_event_fra_english_invasion_victory_secondary", 
				true,
				704
			);

			cm:force_make_peace(FRANCE_KEY, ENGLAND_KEY);

			for i = 0, faction_list:num_items() - 1 do
				local possible_ally = faction_list:item_at(i);
				local possible_ally_name = possible_ally:name();
				
				if england:allied_with(possible_ally) == true and possible_ally:at_war_with(france) then
					cm:force_make_peace(FRANCE_KEY, possible_ally_name);
				end
			end
		end
	end

	if context:dilemma() == "mk_dilemma_story_france_english_rebels_alliance" then
		if context:choice() == 0 then
			-- Choice made to ally rebels!
			cm:force_make_vassal(FRANCE_KEY, ENGLAND_REBEL_KEY);
		elseif context:choice() == 1 then
			-- Choice made to fight rebels!
			cm:force_declare_war(FRANCE_KEY, ENGLAND_REBEL_KEY);
		end
	end
end


function CharacterEntersGarrison_Toulouse(context)
	if context:character():has_region() and context:character():region():name() == "mk_reg_toulouse" and context:character():faction():name() == FRANCE_KEY and CATHAR_REVOLT_TRIGGERED == false then
		CATHAR_REVOLT_TURN = cm:model():turn_number() + 1;
		CATHAR_REVOLT_TRIGGERED = true;
		cm:remove_listener("CharacterEntersGarrison_Toulouse");
	end
end

function CharacterEntersGarrison_Normandy_France(context)	
	if context:character():has_region() and context:character():region():name() == "mk_reg_rouen" and context:character():faction():name() ~= FRANCE_KEY and FRANCE_MISSION_ACTIVE == true then
		if context:character():region():name() == "mk_reg_rouen" then
			cm:override_mission_succeeded_status(FRANCE_KEY, "mk_mission_story_france_survive_invasion", false);
			cm:remove_listener("CharacterEntersGarrison_Normandy_France");
		end
	end
end

function MissionSucceeded_France(context)
	local france = cm:model():world():faction_by_key(FRANCE_KEY);
	local england = cm:model():world():faction_by_key(ENGLAND_KEY);
	local mission_name = context:mission():mission_record_key();	
	local faction_list = cm:model():world():faction_list();

	if context:faction():name() == FRANCE_KEY then		
		if mission_name == "mk_mission_story_france_survive_invasion" then
			FRANCE_MISSION_ACTIVE = false;
			cm:remove_listener("CharacterEntersGarrison_Normandy_France");
			SetFactionsNeutral(ENGLAND_KEY, FRANCE_KEY);

			if england:is_human() == false then
				local unit_list = "";
				
				if difficulty >= 1 then
					unit_list = "mk_eng_t1_spear_militia,mk_eng_t1_spear_militia,mk_eng_t1_spear_militia,mk_eng_t1_serjeants,mk_eng_t1_serjeants,mk_eng_t1_longbowmen,mk_eng_t1_longbowmen,mk_eng_t1_longbowmen,mk_eng_t1_mounted_serjeants";
				elseif difficulty >= -1 then
					unit_list = "mk_eng_t1_spear_militia,mk_eng_t1_spear_militia,mk_eng_t1_spear_militia,mk_eng_t1_spear_militia,mk_eng_t1_serjeants,mk_eng_t1_serjeants,mk_eng_t1_serjeants,mk_eng_t1_longbowmen,mk_eng_t1_longbowmen,mk_eng_t1_longbowmen,mk_eng_t1_mounted_serjeants,mk_eng_t1_mounted_serjeants";
				else
					unit_list = "mk_eng_t1_spear_militia,mk_eng_t1_spear_militia,mk_eng_t1_spear_militia,mk_eng_t1_spear_militia,mk_eng_t1_serjeants,mk_eng_t1_serjeants,mk_eng_t1_serjeants,mk_eng_t1_serjeants,mk_eng_t1_axe_sergeant,mk_eng_t1_longbowmen,mk_eng_t1_longbowmen,mk_eng_t1_longbowmen,mk_eng_t1_mounted_serjeants,mk_eng_t1_mounted_serjeants";
				end

				cm:create_force(
					ENGLAND_REBEL_KEY,
					unit_list,
					"mk_reg_london",
					156,
					565,
					"eng_barons_war_1",
					true,
					function(cqi)
						cm:apply_effect_bundle_to_characters_force("mk_bundle_army_english_rebellion", cqi, -1, true);
					end
				);
				
				cm:create_force(
					ENGLAND_REBEL_KEY,
					unit_list,
					"mk_reg_london",
					161,
					569,
					"eng_barons_war_2",
					true,
					function(cqi)
						cm:apply_effect_bundle_to_characters_force("mk_bundle_army_english_rebellion", cqi, -1, true);
					end
				);
				
				Transfer_Region_To_Faction("mk_reg_london", ENGLAND_REBEL_KEY);
				cm:trigger_dilemma(FRANCE_KEY, "mk_dilemma_story_france_pursue_england");
				cm:force_declare_war(ENGLAND_REBEL_KEY, ENGLAND_KEY);		
			end
		end
	end
end

function MissionFailed_France(context)
	if context:faction():name() == FRANCE_KEY then
		local mission_name = context:mission():mission_record_key();	
		
		if mission_name == "mk_mission_story_france_survive_invasion" then
			SetFactionsNeutral(ENGLAND_KEY, FRANCE_KEY);
			FRANCE_MISSION_ACTIVE = false;
		end
	end
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		cm:save_value("CATHAR_REVOLT_CRUSHED", CATHAR_REVOLT_CRUSHED, context);
		cm:save_value("CATHAR_REVOLT_TRIGGERED", CATHAR_REVOLT_TRIGGERED, context);
		cm:save_value("CATHAR_REVOLT_TURN", CATHAR_REVOLT_TURN, context);
		cm:save_value("FRANCE_MISSION_ACTIVE", FRANCE_MISSION_ACTIVE, context);
		cm:save_value("FRANCE_MADE_PEACE", FRANCE_MADE_PEACE, context);
		cm:save_value("FRANCE_SECOND_DILEMMA_ISSUED", FRANCE_SECOND_DILEMMA_ISSUED, context);
	end
);

cm:register_loading_game_callback(
	function(context)
		CATHAR_REVOLT_CRUSHED = cm:load_value("CATHAR_REVOLT_CRUSHED", false, context);
		CATHAR_REVOLT_TRIGGERED = cm:load_value("CATHAR_REVOLT_TRIGGERED", false, context);
		CATHAR_REVOLT_TURN = cm:load_value("CATHAR_REVOLT_TURN", 0, context);
		FRANCE_MISSION_ACTIVE = cm:load_value("FRANCE_MISSION_ACTIVE", false, context);
		FRANCE_MADE_PEACE = cm:load_value("FRANCE_MADE_PEACE", false, context);
		FRANCE_SECOND_DILEMMA_ISSUED = cm:load_value("FRANCE_SECOND_DILEMMA_ISSUED", false, context);
	end
);
