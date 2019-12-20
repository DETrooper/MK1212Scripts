----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - STORY: ENGLAND
-- 	By: DETrooper
--
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

ENGLAND_KEY = "mk_fact_england";
ENGLAND_REBEL_KEY = "mk_fact_earldoms";
FRANCE_KEY = "mk_fact_france";
HRE_KEY = "mk_fact_hre";
ENGLAND_WAR_WERE_DECLARED = false;
ENGLISH_MISSION_ACTIVE = false;
ENGLAND_DUE_FOR_DILEMMA = false;
ENGLAND_FIRST_DILEMMA = "NIL";
ENGLAND_SECOND_DILEMMA_CHOICE = "NIL";
ENGLAND_HRE_MESSAGE_SENT = false;

function Add_England_Story_Events_Listeners()
	local england = cm:model():world():faction_by_key(ENGLAND_KEY);
	local france = cm:model():world():faction_by_key(FRANCE_KEY);

	cm:add_listener(
		"FactionTurnStart_England",
		"FactionTurnStart",
		true,
		function(context) FactionTurnStart_England(context) end,
		true
	);

	if england:is_human() == true then
		cm:add_listener(
			"DilemmaChoiceMadeEvent_England",
			"DilemmaChoiceMadeEvent",
			true,
			function(context) DilemmaChoiceMadeEvent_England(context) end,
			true
		);
		cm:add_listener(
			"MissionIssued_England",
			"MissionIssued",
			true,
			function(context) MissionIssued_England(context) end,
			true
		);
		cm:add_listener(
			"MissionFailed_England",
			"MissionFailed",
			true,
			function(context) MissionFailed_England(context) end,
			true
		);
		cm:add_listener(
			"MissionSucceeded_England",
			"MissionSucceeded",
			true,
			function(context) MissionSucceeded_England(context) end,
			true
		);

		if ENGLISH_MISSION_ACTIVE == true then
			cm:add_listener(
				"CharacterEntersGarrison_Normandy",
				"CharacterEntersGarrison",
				true,
				function(context) CharacterEntersGarrison_Normandy(context) end,
				true
			);
		end

		if ENGLAND_SECOND_DILEMMA_CHOICE == "AGREE" then
			cm:add_listener(
				"CharacterBecomesFactionLeader_Magna_Carta",
				"CharacterBecomesFactionLeader",
				true,
				function(context) New_England_Leader(context) end,
				true
			);
		end

		if cm:is_new_game() then
			cm:force_diplomacy(ENGLAND_KEY, FRANCE_KEY, "war", false, false); -- Disable war with France for turn 1.
		end
	end
end

function FactionTurnStart_England(context)
	local england = cm:model():world():faction_by_key(ENGLAND_KEY);
	local france = cm:model():world():faction_by_key(FRANCE_KEY);
	local pretenders = cm:model():world():faction_by_key(ENGLAND_REBEL_KEY);

	if context:faction():name() == ENGLAND_KEY then
		if england:is_human() == true then
			if ENGLAND_DUE_FOR_DILEMMA == true then
				cm:trigger_dilemma(ENGLAND_KEY, "mk_dilemma_story_england_magna_carta_renew");
				ENGLAND_DUE_FOR_DILEMMA = false;
			end
			if cm:model():turn_number() == 2 then
				cm:force_diplomacy(ENGLAND_KEY, FRANCE_KEY, "war", true, true); -- Re-enable war with France.

				-- Issue England a mission telling them to declare war on France, or face the consequences!

				if cm:is_multiplayer() == false then
					cm:trigger_dilemma(ENGLAND_KEY, "mk_dilemma_story_england_war_with_france");
				elseif cm:is_multiplayer() == true and england:allied_with(france) == false then
					-- If game is MP and England isn't allied to France, that means it isn't a co-op campaign, so war can happen!
					cm:trigger_dilemma(ENGLAND_KEY, "mk_dilemma_story_england_war_with_france");
				end
			end
			if ENGLAND_FIRST_DILEMMA == "ISSUE" then
				cm:trigger_dilemma(ENGLAND_KEY, "mk_dilemma_story_england_magna_carta");
				ENGLAND_FIRST_DILEMMA = "NIL";
			end
			if ENGLAND_SECOND_DILEMMA_CHOICE == "REFUSE" then
				ENGLAND_SECOND_DILEMMA_CHOICE = "NIL";
				CreateCivilWarArmy("att_reg_britannia_superior_londinium", "english", ENGLAND_REBEL_KEY, "eng_barons_war_1", 156, 565);
				CreateCivilWarArmy("att_reg_britannia_superior_londinium", "english", ENGLAND_REBEL_KEY, "eng_barons_war_2", 161, 569);

				if cm:model():world():region_manager():region_by_key("att_reg_britannia_superior_londinium"):has_governor() then
					local governor = cm:model():world():region_manager():region_by_key("att_reg_britannia_superior_londinium"):governor():command_queue_index();
					cm:set_character_immortality("character_cqi:"..governor, true);
					cm:transfer_region_to_faction("att_reg_britannia_superior_londinium", ENGLAND_REBEL_KEY);
					cm:set_character_immortality("character_cqi:"..governor, false);
				else
					cm:transfer_region_to_faction("att_reg_britannia_superior_londinium", ENGLAND_REBEL_KEY);
				end

				cm:show_message_event(
					ENGLAND_KEY,
					"message_event_text_text_mk_event_eng_civil_war_title", 
					"message_event_text_text_mk_event_eng_civil_war_primary", 
					"message_event_text_text_mk_event_eng_civil_war_secondary", 
					true,
					703
				);
			end
			if ENGLISH_MISSION_ACTIVE == true then
				local region = cm:model():world():region_manager():region_by_key("att_reg_lugdunensis_rotomagus");
			
				if region:owning_faction():name() == ENGLAND_KEY then
					cm:override_mission_succeeded_status(ENGLAND_KEY, "mk_mission_story_england_take_normandy", true);
					cm:remove_listener("CharacterEntersGarrison_Normandy");
				end
			end
		elseif england:is_human() == false and france:is_human() == false then
			if cm:model():turn_number() == 2 and england:at_war_with(france) == false then
				cm:force_declare_war(ENGLAND_KEY, FRANCE_KEY);
			end
		end
	end

	if france:is_human() == true and context:faction():name() == FRANCE_KEY then
		if cm:model():turn_number() == FRANCE_MISSION_WIN_TURN and FRANCE_MISSION_ACTIVE == true then
			cm:override_mission_succeeded_status(FRANCE_KEY, "mk_mission_story_france_survive_invasion", true);
		end
	end

	if context:faction():name() == ENGLAND_REBEL_KEY then
		if england:at_war_with(pretenders) == false and pretenders:is_null_interface() == false then
			cm:force_declare_war(ENGLAND_KEY, ENGLAND_REBEL_KEY);
		end
	end

	if context:faction():name() == HRE_KEY then
		if cm:model():turn_number() >= 3 and ENGLAND_HRE_MESSAGE_SENT == false and england:at_war_with(france) == true then
			local hre = cm:model():world():faction_by_key(HRE_KEY);

			if hre:is_human() == true and hre:allied_with(england) == true then
				cm:show_message_event(
					HRE_KEY,
					"message_event_text_text_mk_event_hre_english_invasion_title", 
					"message_event_text_text_mk_event_hre_english_invasion_primary", 
					"message_event_text_text_mk_event_hre_english_invasion_secondary", 
					true,
					711
				);

				ENGLAND_HRE_MESSAGE_SENT = true;
			end
		end
	end
end

function DilemmaChoiceMadeEvent_England(context)
	local france = cm:model():world():faction_by_key(FRANCE_KEY);

	if context:dilemma() == "mk_dilemma_story_england_war_with_france" then
		if context:choice() == 0 then
			-- Choice made to war on France!
			ENGLAND_WAR_WERE_DECLARED = true;
			cm:force_declare_war(ENGLAND_KEY, FRANCE_KEY);
			ENGLISH_MISSION_ACTIVE = true;

			cm:add_listener(
				"CharacterEntersGarrison_Normandy",
				"CharacterEntersGarrison",
				true,
				function(context) CharacterEntersGarrison_Normandy(context) end,
				true
			);

			cm:trigger_mission(ENGLAND_KEY, "mk_mission_story_england_take_normandy");
			SetFactionsHostile(ENGLAND_KEY, FRANCE_KEY);

			if france:is_human() == true then
				cm:show_message_event(
					FRANCE_KEY,
					"message_event_text_text_mk_event_fra_english_invasion_title", 
					"message_event_text_text_mk_event_fra_english_invasion_primary", 
					"message_event_text_text_mk_event_fra_english_invasion_secondary", 
					true,
					711
				);
				cm:trigger_mission(FRANCE_KEY, "mk_mission_story_france_survive_invasion");
				FRANCE_MISSION_ACTIVE = true;
			end
		elseif context:choice() == 1 then
			-- Choice made to stay out of war!
			cm:show_message_event(
				ENGLAND_KEY,
				"message_event_text_text_mk_event_eng_magna_carta_title", 
				"message_event_text_text_mk_event_eng_magna_carta_primary", 
				"message_event_text_text_mk_event_eng_magna_carta_peace_secondary", 
				true,
				704
			);
			ENGLAND_FIRST_DILEMMA = "ISSUE";
		end
	end
	if context:dilemma() == "mk_dilemma_story_england_magna_carta" then
		if context:choice() == 0 then
			-- Choice made to sign Magna Carta!
			cm:add_listener(
				"CharacterBecomesFactionLeader_Magna_Carta",
				"CharacterBecomesFactionLeader",
				true,
				function(context) New_England_Leader(context) end,
				true
			);
			ENGLAND_SECOND_DILEMMA_CHOICE = "AGREE";
		elseif context:choice() == 1 then
			-- Choice made to refuse!
			ENGLAND_SECOND_DILEMMA_CHOICE = "REFUSE";
		end
	end
	if context:dilemma() == "mk_dilemma_story_england_magna_carta_renew" then
		if context:choice() == 1 then
			-- Choice made to refuse!
			ENGLAND_SECOND_DILEMMA_CHOICE = "REFUSE";
			cm:remove_effect_bundle("mk_bundle_magna_carta", ENGLAND_KEY);
			cm:remove_listener("CharacterBecomesFactionLeader_Magna_Carta");
		end
	end
end

function CharacterEntersGarrison_Normandy(context)
	if context:character():has_region() and context:character():region():name() == "att_reg_lugdunensis_rotomagus" and context:character():faction():name() == ENGLAND_KEY and ENGLISH_MISSION_ACTIVE == true then
		cm:override_mission_succeeded_status(ENGLAND_KEY, "mk_mission_story_england_take_normandy", true);
		cm:remove_listener("CharacterEntersGarrison_Normandy");
	end
end

function MissionIssued_England(context)
	if context:faction():name() == ENGLAND_KEY then
		local mission_name = context:mission():mission_record_key();
		
		if mission_name == "mk_mission_story_england_take_normandy" then
			local region = cm:model():world():region_manager():region_by_key("att_reg_lugdunensis_rotomagus");
		
			if region:owning_faction():name() == ENGLAND_KEY then
				cm:override_mission_succeeded_status(ENGLAND_KEY, "mk_mission_story_england_take_normandy", true);
				cm:remove_listener("CharacterEntersGarrison_Normandy");
			end
		end
	end
end


function MissionFailed_England(context)
	if context:faction():name() == ENGLAND_KEY then
		local france = cm:model():world():faction_by_key(FRANCE_KEY);
		local mission_name = context:mission():mission_record_key();
		
		if mission_name == "mk_mission_story_england_take_normandy" then
			cm:remove_listener("CharacterEntersGarrison_Normandy");

			cm:show_message_event(
				ENGLAND_KEY,
				"message_event_text_text_mk_event_eng_magna_carta_title", 
				"message_event_text_text_mk_event_eng_magna_carta_primary", 
				"message_event_text_text_mk_event_eng_magna_carta_war_secondary", 
				true,
				704
			);

			ENGLAND_FIRST_DILEMMA = "ISSUE";
			SetFactionsNeutral(ENGLAND_KEY, FRANCE_KEY);
			ENGLISH_MISSION_ACTIVE = false;

			if france:is_human() == true then
				cm:trigger_dilemma(FRANCE_KEY, "mk_dilemma_story_france_pursue_england");
			end
		end
	end
end

function MissionSucceeded_England(context)
	if context:faction():name() == ENGLAND_KEY then
		if mission_name == "mk_mission_story_england_take_normandy" then
			SetFactionsNeutral(ENGLAND_KEY, FRANCE_KEY);
			ENGLISH_MISSION_ACTIVE = false;
			--cm:override_mission_succeeded_status(FRANCE_KEY, "mk_mission_story_france_survive_invasion", false);
		end
	end
end

function New_England_Leader(context)
	if context:character():faction():name() == ENGLAND_KEY then
		ENGLAND_DUE_FOR_DILEMMA = true;
	end
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		cm:save_value("ENGLAND_WAR_WERE_DECLARED", ENGLAND_WAR_WERE_DECLARED, context);
		cm:save_value("ENGLISH_MISSION_ACTIVE", ENGLISH_MISSION_ACTIVE, context);
		--cm:save_value("NORMANDY_CAMPAIGN_END_TURN", NORMANDY_CAMPAIGN_END_TURN, context);
		cm:save_value("ENGLAND_DUE_FOR_DILEMMA", ENGLAND_DUE_FOR_DILEMMA, context);
		cm:save_value("ENGLAND_FIRST_DILEMMA", ENGLAND_FIRST_DILEMMA, context);
		cm:save_value("ENGLAND_SECOND_DILEMMA_CHOICE", ENGLAND_SECOND_DILEMMA_CHOICE, context);
		cm:save_value("ENGLAND_HRE_MESSAGE_SENT", ENGLAND_HRE_MESSAGE_SENT, context);
	end
);

cm:register_loading_game_callback(
	function(context)
		ENGLAND_WAR_WERE_DECLARED = cm:load_value("ENGLAND_WAR_WERE_DECLARED", false, context);
		ENGLISH_MISSION_ACTIVE = cm:load_value("ENGLISH_MISSION_ACTIVE", false, context);
		--NORMANDY_CAMPAIGN_END_TURN = cm:load_value("NORMANDY_CAMPAIGN_END_TURN", 0, context);
		ENGLAND_DUE_FOR_DILEMMA = cm:load_value("ENGLAND_DUE_FOR_DILEMMA", false, context);
		ENGLAND_FIRST_DILEMMA = cm:load_value("ENGLAND_FIRST_DILEMMA", "NIL", context);
		ENGLAND_SECOND_DILEMMA_CHOICE = cm:load_value("ENGLAND_SECOND_DILEMMA_CHOICE", "NIL", context);
		ENGLAND_HRE_MESSAGE_SENT = cm:load_value("ENGLAND_HRE_MESSAGE_SENT", false, context);
	end
);