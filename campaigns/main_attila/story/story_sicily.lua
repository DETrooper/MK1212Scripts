--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - STORY: SICILY
-- 	By: DETrooper
--
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

SICILY_BECAME_EMPEROR = false;
SICILY_KING_CQI = 0;
SICILY_KEY = "mk_fact_sicily";

function Add_Sicily_Story_Events_Listeners()
	local sicily = cm:model():world():faction_by_key(SICILY_KEY);

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

		if cm:model():turn_number() == 1 then
			-- Disable war with HRE for turn 1.
			cm:force_diplomacy(HRE_EMPEROR_PRETENDER_KEY, HRE_EMPEROR_KEY, "war", false, false);
			cm:force_diplomacy(HRE_EMPEROR_KEY, HRE_EMPEROR_PRETENDER_KEY, "war", false, false);
		end
	end

	if cm:is_new_game() then
		SICILY_KING_CQI = cm:model():world():faction_by_key(SICILY_KEY):faction_leader():command_queue_index();

		-- For the duration of Sicily's mission, ensure that the HRE's tributaries do not get involved in the war with Sicily.
		for i = 1, #FACTIONS_HRE_START do
			if FACTIONS_HRE_START[i] ~= HRE_EMPEROR_KEY then
				cm:force_diplomacy(FACTIONS_HRE_START[i], SICILY_KEY, "war", false, false);
			end
		end
	end
end

function FactionTurnStart_Sicily(context)
	local sicily = cm:model():world():faction_by_key(SICILY_KEY);
	local hre = cm:model():world():faction_by_key(HRE_EMPEROR_KEY);

	if context:faction():name() == SICILY_KEY then
		if sicily:is_human() then
			if cm:model():turn_number() == 2 then
				-- Re-enable war with the HRE.
				cm:force_diplomacy(SICILY_KEY, HRE_EMPEROR_KEY, "war", true, true);
				cm:force_diplomacy(HRE_EMPEROR_KEY, SICILY_KEY, "war", true, true);
				cm:trigger_dilemma(SICILY_KEY, "mk_dilemma_story_sicily_war_with_hre");
			end
		elseif sicily:is_human() == false and hre:is_human() == false then
			if cm:model():turn_number() == 2 and sicily:at_war_with(hre) == false then
				cm:force_diplomacy(SICILY_KEY, HRE_EMPEROR_KEY, "war", true, true);
				cm:force_diplomacy(HRE_EMPEROR_KEY, SICILY_KEY, "war", true, true);
				cm:force_declare_war(HRE_EMPEROR_KEY, SICILY_KEY);
			end
		end

		if SICILY_BECAME_EMPEROR == false and SICILY_KEY == HRE_EMPEROR_PRETENDER_KEY then
			for i = 1, #FACTIONS_HRE_START do
				cm:force_diplomacy(FACTIONS_HRE_START[i], SICILY_KEY, "war", true, true);
			end

			SICILY_BECAME_EMPEROR = true;
		end
	elseif context:faction():name() == HRE_EMPEROR_KEY and hre:is_human() then
		if cm:model():turn_number() == 2 and sicily:at_war_with(hre) == false and sicily:is_human() == false then
			cm:force_diplomacy(SICILY_KEY, HRE_EMPEROR_KEY, "war", true, true);
			cm:force_diplomacy(HRE_EMPEROR_KEY, SICILY_KEY, "war", true, true);
			cm:force_declare_war(HRE_EMPEROR_KEY, SICILY_KEY);

			cm:show_message_event(
				HRE_EMPEROR_KEY,
				"message_event_text_text_mk_event_hre_sicilian_invasion_title", 
				"message_event_text_text_mk_event_hre_sicilian_invasion_primary", 
				"message_event_text_text_mk_event_hre_sicilian_invasion_secondary", 
				true,
				712
			);
		end
	end
end

function DilemmaChoiceMadeEvent_Sicily(context)
	local hre = cm:model():world():faction_by_key(HRE_EMPEROR_KEY);

	if context:dilemma() == "mk_dilemma_story_sicily_war_with_hre" then
		if context:choice() == 0 then
			-- Choice made to declare war on HRE!
			cm:force_declare_war(HRE_EMPEROR_KEY, SICILY_KEY);

			cm:trigger_mission(SICILY_KEY, "mk_mission_story_pretender_take_frankfurt");
			SetFactionsHostile(SICILY_KEY, HRE_EMPEROR_KEY);

			if hre:is_human() == true then
				cm:show_message_event(
					HRE_EMPEROR_KEY,
					"message_event_text_text_mk_event_hre_sicilian_invasion_title", 
					"message_event_text_text_mk_event_hre_sicilian_invasion_primary", 
					"message_event_text_text_mk_event_hre_sicilian_invasion_secondary", 
					true,
					712
				);

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
				cm:force_diplomacy(FACTIONS_HRE_START[i], SICILY_KEY, "war", true, true);
			end

			HRE_Vanquish_Pretender();
		end
	end
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		cm:save_value("SICILY_BECAME_EMPEROR", SICILY_BECAME_EMPEROR, context);
		cm:save_value("SICILY_KING_CQI", SICILY_KING_CQI, context);
	end
);

cm:register_loading_game_callback(
	function(context)
		SICILY_BECAME_EMPEROR = cm:load_value("SICILY_BECAME_EMPEROR", false, context);
		SICILY_KING_CQI = cm:load_value("SICILY_KING_CQI", 0, context);
	end
);