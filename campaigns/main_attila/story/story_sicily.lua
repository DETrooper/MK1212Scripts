--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - STORY: SICILY
-- 	By: DETrooper
--
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

SICILY_KEY = "mk_fact_sicily";
SICILY_KING_CQI = 0;

HRE_KEY = "mk_fact_hre";
HRE_EMPEROR_CQI = 0;
HRE_MISSION_WIN_TURN = 12;

HRE_WAR_WERE_DECLARED = false;
SICILIAN_MISSION_ACTIVE = false;
HRE_MISSION_ACTIVE = false;

function Add_Sicily_Story_Events_Listeners()
	local sicily = cm:model():world():faction_by_key(SICILY_KEY);
	local hre = cm:model():world():faction_by_key(HRE_KEY);

	cm:add_listener(
		"FactionTurnStart_Sicily",
		"FactionTurnStart",
		true,
		function(context) FactionTurnStart_Sicily(context) end,
		true
	);

	cm:add_listener(
		"CharacterEntersGarrison_Frankfurt",
		"CharacterEntersGarrison",
		true,
		function(context) CharacterEntersGarrison_Frankfurt(context) end,
		true
	);

	if sicily:is_human() == true then
		cm:add_listener(
			"DilemmaChoiceMadeEvent_Sicily",
			"DilemmaChoiceMadeEvent",
			true,
			function(context) DilemmaChoiceMadeEvent_Sicily(context) end,
			true
		);
		cm:add_listener(
			"MissionFailed_Sicily",
			"MissionFailed",
			true,
			function(context) MissionFailed_Sicily(context) end,
			true
		);
		cm:add_listener(
			"MissionIssued_Sicily",
			"MissionIssued",
			true,
			function(context) MissionIssued_Sicily(context) end,
			true
		);

		if cm:model():turn_number() == 1 then
			-- Disable war with HRE for turn 1.
			cm:force_diplomacy(SICILY_KEY, HRE_KEY, "war", false, false);
			cm:force_diplomacy(HRE_KEY, SICILY_KEY, "war", false, false);
		end
	end

	if cm:is_new_game() then
		SICILY_KING_CQI = cm:model():world():faction_by_key(SICILY_KEY):faction_leader():command_queue_index();
		HRE_EMPEROR_CQI = cm:model():world():faction_by_key(HRE_KEY):faction_leader():command_queue_index();

		-- For the duration of Sicily's mission, ensure that the HRE's tributaries do not get involved in the war with Sicily.
		for i = 1, #FACTIONS_HRE_START do
			if FACTIONS_HRE_START[i] ~= "mk_fact_hre" then
				cm:force_diplomacy(FACTIONS_HRE_START[i], SICILY_KEY, "war", false, false);
			end
		end
	end
end

function FactionTurnStart_Sicily(context)
	local sicily = cm:model():world():faction_by_key(SICILY_KEY);
	local hre = cm:model():world():faction_by_key(HRE_KEY);

	if context:faction():name() == SICILY_KEY then
		if sicily:is_human() then
			if cm:model():turn_number() == 2 then
				-- Re-enable war with the HRE.
				cm:force_diplomacy(SICILY_KEY, HRE_KEY, "war", true, true);
				cm:force_diplomacy(HRE_KEY, SICILY_KEY, "war", true, true);

				if cm:is_multiplayer() == false then
					cm:trigger_dilemma(SICILY_KEY, "mk_dilemma_story_sicily_war_with_hre");
				elseif cm:is_multiplayer() == true and england:allied_with(france) == false then
					-- If game is MP and Sicily isn't allied to the HRE, that means it isn't a co-op campaign, so war can happen!
					cm:trigger_dilemma(SICILY_KEY, "mk_dilemma_story_sicily_war_with_hre");
				end
			end

			if SICILY_MISSION_ACTIVE == true then
				local region = cm:model():world():region_manager():region_by_key("att_reg_germania_uburzis");
			
				if region:owning_faction():name() == SICILY_KEY or cm:model():world():faction_by_key(HRE_KEY):faction_leader():command_queue_index() ~= HRE_EMPEROR_CQI then
					Sicily_Story_End_Mission(true);
					cm:override_mission_succeeded_status(SICILY_KEY, "mk_mission_story_sicily_take_frankfurt", true);
				end

				if cm:model():world():faction_by_key(SICILY_KEY):faction_leader():command_queue_index() ~= SICILY_KING_CQI then
					Sicily_Story_End_Mission(false, "death");
					cm:override_mission_succeeded_status(SICILY_KEY, "mk_mission_story_sicily_take_frankfurt", false);
				end
			end
		elseif sicily:is_human() == false and hre:is_human() == false then
			if cm:model():turn_number() == 2 and sicily:at_war_with(hre) == false then
				cm:force_diplomacy(SICILY_KEY, HRE_KEY, "war", true, true);
				cm:force_declare_war(HRE_KEY, SICILY_KEY);
			end

			if cm:model():turn_number() == 12 then
				for i = 1, #FACTIONS_HRE_START do
					if FACTIONS_HRE_START[i] ~= "mk_fact_hre" then
						cm:force_diplomacy(FACTIONS_HRE_START[i], SICILY_KEY, "war", true, true);
					end
				end
			end	
		end
	elseif context:faction():name() == HRE_KEY and hre:is_human() then
		if cm:model():turn_number() == 2 and sicily:at_war_with(hre) == false and sicily:is_human() == false then
			cm:force_diplomacy(SICILY_KEY, HRE_KEY, "war", true, true);
			cm:force_diplomacy(HRE_KEY, SICILY_KEY, "war", true, true);
			cm:force_declare_war(HRE_KEY, SICILY_KEY);

			cm:show_message_event(
				HRE_KEY,
				"message_event_text_text_mk_event_hre_sicilian_invasion_title", 
				"message_event_text_text_mk_event_hre_sicilian_invasion_primary", 
				"message_event_text_text_mk_event_hre_sicilian_invasion_secondary", 
				true,
				712
			);
		elseif cm:model():turn_number() == 3 and sicily:at_war_with(hre) == true and sicily:is_human() == false then
			cm:trigger_mission(HRE_KEY, "mk_mission_story_hre_survive_invasion");
			HRE_MISSION_ACTIVE = true;
		elseif HRE_MISSION_ACTIVE == true then
			if cm:model():turn_number() == HRE_MISSION_WIN_TURN then
				cm:override_mission_succeeded_status(HRE_KEY, "mk_mission_story_hre_survive_invasion", true);
			end

			if cm:model():world():faction_by_key(HRE_KEY):faction_leader():command_queue_index() ~= HRE_EMPEROR_CQI then
				cm:override_mission_succeeded_status(HRE_KEY, "mk_mission_story_hre_survive_invasion", false);
			end
		end
	end
end

function DilemmaChoiceMadeEvent_Sicily(context)
	local hre = cm:model():world():faction_by_key(HRE_KEY);

	if context:dilemma() == "mk_dilemma_story_sicily_war_with_hre" then
		if context:choice() == 0 then
			-- Choice made to war on HRE!
			cm:force_declare_war(HRE_KEY, SICILY_KEY);
			HRE_WAR_WERE_DECLARED = true;
			SICILIAN_MISSION_ACTIVE = true;

			cm:trigger_mission(SICILY_KEY, "mk_mission_story_sicily_take_frankfurt");
			SetFactionsHostile(SICILY_KEY, HRE_KEY);

			if hre:is_human() == true then
				cm:show_message_event(
					HRE_KEY,
					"message_event_text_text_mk_event_hre_sicilian_invasion_title", 
					"message_event_text_text_mk_event_hre_sicilian_invasion_primary", 
					"message_event_text_text_mk_event_hre_sicilian_invasion_secondary", 
					true,
					712
				);

				--cm:trigger_mission(HRE_KEY, "mk_mission_story_hre_survive_invasion");
				HRE_MISSION_ACTIVE = true;
			end
		elseif context:choice() == 1 then
			-- Choice made to stay out of war!
			cm:show_message_event(
				SICILY_KEY,
				"message_event_text_text_mk_event_sic_no_war_hre_title", 
				"message_event_text_text_mk_event_sic_no_war_hre_primary", 
				"message_event_text_text_mk_event_sic_no_war_hre_secondary", 
				true,
				704
			);

			for i = 1, #FACTIONS_HRE_START do
				if FACTIONS_HRE_START[i] ~= "mk_fact_hre" then
					cm:force_diplomacy(FACTIONS_HRE_START[i], SICILY_KEY, "war", true, true);
				end
			end
		end
	end
end

function CharacterEntersGarrison_Frankfurt(context)
	if context:character():has_region() and context:character():region():name() == "att_reg_germania_uburzis" and context:character():faction():name() == SICILY_KEY and SICILIAN_MISSION_ACTIVE == true then
		cm:override_mission_succeeded_status(SICILY_KEY, "mk_mission_story_sicily_take_frankfurt", true);
		cm:remove_listener("CharacterEntersGarrison_Frankfurt");

		HRE_Replace_Emperor(SICILY_KEY);

		if cm:is_multiplayer() == false then
			Remove_Decision("found_an_empire");
		end

		SICILIAN_MISSION_ACTIVE = false;
		HRE_MISSION_ACTIVE = false;

		for i = 1, #FACTIONS_HRE_START do
			if FACTIONS_HRE_START[i] ~= "mk_fact_hre" then
				cm:force_diplomacy(FACTIONS_HRE_START[i], SICILY_KEY, "war", true, true);
			end
		end
	end
end

function MissionIssued_Sicily(context)
	if context:faction():name() == SICILY_KEY and cm:is_multiplayer() == false then
		local mission_name = context:mission():mission_record_key();
		
		if mission_name == "mk_mission_story_sicily_take_frankfurt" then
			cm:make_region_seen_in_shroud(context:faction():name(), "att_reg_germania_uburzis");
		end
	end
end

function MissionFailed_Sicily(context)
	if context:faction():name() == SICILY_KEY then
		local mission_name = context:mission():mission_record_key();
		
		if mission_name == "mk_mission_story_sicily_take_frankfurt" then
			Sicily_Story_End_Mission(false, "time");
		end
	end
end

function Sicily_Story_End_Mission(success, reason)
	cm:remove_listener("CharacterEntersGarrison_Frankfurt");
	SICILIAN_MISSION_ACTIVE = false;

	for i = 1, #FACTIONS_HRE_START do
		if FACTIONS_HRE_START[i] ~= "mk_fact_hre" then
			cm:force_diplomacy(FACTIONS_HRE_START[i], SICILY_KEY, "war", true, true);
		end
	end

	if success == false then
		if reason == "death" then
			cm:show_message_event(
				SICILY_KEY,
				"message_event_text_text_mk_event_sic_lost_claim_title", 
				"message_event_text_text_mk_event_sic_lost_claim_primary", 
				"message_event_text_text_mk_event_sic_lost_claim_secondary_death", 
				true,
				713
			);
		else
			cm:show_message_event(
				SICILY_KEY,
				"message_event_text_text_mk_event_sic_lost_claim_title", 
				"message_event_text_text_mk_event_sic_lost_claim_primary", 
				"message_event_text_text_mk_event_sic_lost_claim_secondary", 
				true,
				713
			);
		end

		SetFactionsNeutral(SICILY_KEY, HRE_KEY);
	end
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		cm:save_value("HRE_WAR_WERE_DECLARED", HRE_WAR_WERE_DECLARED, context);
		cm:save_value("SICILIAN_MISSION_ACTIVE", SICILIAN_MISSION_ACTIVE, context);
		cm:save_value("HRE_MISSION_ACTIVE", HRE_MISSION_ACTIVE, context);
		cm:save_value("HRE_EMPEROR_CQI", HRE_EMPEROR_CQI, context);
	end
);

cm:register_loading_game_callback(
	function(context)
		HRE_WAR_WERE_DECLARED = cm:load_value("HRE_WAR_WERE_DECLARED", false, context);
		SICILIAN_MISSION_ACTIVE = cm:load_value("SICILIAN_MISSION_ACTIVE", false, context);
		HRE_MISSION_ACTIVE = cm:load_value("HRE_MISSION_ACTIVE", false, context);
		HRE_EMPEROR_CQI = cm:load_value("HRE_EMPEROR_CQI", 0, context);
	end
);