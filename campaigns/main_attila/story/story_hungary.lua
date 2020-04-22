--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - STORY: HUNGARY
-- 	By: DETrooper
--
--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

HUNGARY_KEY = "mk_fact_hungary";
GOLDEN_HORDE_KEY = "mk_fact_goldenhorde";
ILKHANATE_KEY = "mk_fact_ilkhanate";
HUNGARY_GOLDEN_BULL_TURN = 20;

HUNGARY_GOLDEN_BULL_DILEMMA_STATUS = "NOT TRIGGERED";
HUNGARY_REFUGEE_DILEMMA_STATUS = "NOT TRIGGERED";

HUNGARY_CUMAN_UNITS = {
	"mk_cuman_t1_light_HA",
	"mk_cuman_t1_light_lancers"
}

function Add_Hungary_Story_Events_Listeners()
	local hungary = cm:model():world():faction_by_key(HUNGARY_KEY);

	if hungary:is_human() == true then
		cm:add_listener(
			"FactionTurnStart_Hungary",
			"FactionTurnStart",
			true,
			function(context) FactionTurnStart_Hungary(context) end,
			true
		);
		cm:add_listener(
			"FactionEncountersOtherFaction_Hungary",
			"FactionEncountersOtherFaction",
			true,
			function(context) FactionEncountersOtherFaction_Hungary(context) end,
			true
		);
		cm:add_listener(
			"DilemmaChoiceMadeEvent_Hungary",
			"DilemmaChoiceMadeEvent",
			true,
			function(context) DilemmaChoiceMadeEvent_Hungary(context) end,
			true
		);

		if cm:is_new_game() then
			for i = 1, #HUNGARY_CUMAN_UNITS do
				local cumans = HUNGARY_CUMAN_UNITS[i];
				cm:add_event_restricted_unit_record_for_faction(cumans, HUNGARY_KEY);
			end
		end
	end
end

function FactionTurnStart_Hungary(context)
	if cm:model():turn_number() == HUNGARY_GOLDEN_BULL_TURN and HUNGARY_GOLDEN_BULL_DILEMMA_STATUS == "NOT TRIGGERED" then
		cm:trigger_dilemma(HUNGARY_KEY, "mk_dilemma_story_hungary_golden_bull_1222");
		HUNGARY_GOLDEN_BULL_DILEMMA_STATUS = "TRIGGERED";
	elseif HUNGARY_REFUGEE_DILEMMA_STATUS == "SHOULD TRIGGER" then
		cm:trigger_dilemma(HUNGARY_KEY, "mk_dilemma_story_hungary_cumans_fleeing_mongols");
		HUNGARY_REFUGEE_DILEMMA_STATUS = "TRIGGERED";
	end
end

function FactionEncountersOtherFaction_Hungary(context)
	if HUNGARY_REFUGEE_DILEMMA_STATUS == "NOT TRIGGERED" then
		if context:faction():name() == HUNGARY_KEY and context:other_faction():name() == GOLDEN_HORDE_KEY then
			HUNGARY_REFUGEE_DILEMMA_STATUS = "SHOULD TRIGGER";
		elseif context:faction():name() == HUNGARY_KEY and context:other_faction():name() == ILKHANATE_KEY then
			HUNGARY_REFUGEE_DILEMMA_STATUS = "SHOULD TRIGGER";
		elseif context:faction():name() == GOLDEN_HORDE_KEY and context:other_faction():name() == HUNGARY_KEY then
			HUNGARY_REFUGEE_DILEMMA_STATUS = "SHOULD TRIGGER";
		elseif context:faction():name() == ILKHANATE_KEY and context:other_faction():name() == HUNGARY_KEY then
			HUNGARY_REFUGEE_DILEMMA_STATUS = "SHOULD TRIGGER";
		end
	end
end

function DilemmaChoiceMadeEvent_Hungary(context)
	if context:dilemma() == "mk_dilemma_story_hungary_cumans_fleeing_mongols" then
		if context:choice() == 0 then
			-- Choice made to take in Cumans!	
			cm:show_message_event(
				HUNGARY_KEY,
				"message_event_text_text_mk_event_cumans_situation_title", 
				"message_event_text_text_mk_event_cumans_settled_primary", 
				"message_event_text_text_mk_event_cumans_settled_secondary", 
				true,
				710
			);

			for i = 1, #HUNGARY_CUMAN_UNITS do
				local cumans = HUNGARY_CUMAN_UNITS[i];
				cm:remove_event_restricted_unit_record_for_faction(cumans, HUNGARY_KEY);
			end

			cm:apply_effect_bundle("mk_bundle_story_hungary_cumans", HUNGARY_KEY, 0);
			cm:apply_effect_bundle("mk_bundle_story_hungary_noble_disaffection", HUNGARY_KEY, 10);

			SetFactionsHostile(HUNGARY_KEY, GOLDEN_HORDE_KEY);
			SetFactionsHostile(HUNGARY_KEY, ILKHANATE_KEY);
		elseif context:choice() == 1 then
			-- Choice made to reject Cumans!
			cm:show_message_event(
				HUNGARY_KEY,
				"message_event_text_text_mk_event_cumans_situation_title", 
				"message_event_text_text_mk_event_cumans_rejected_primary", 
				"message_event_text_text_mk_event_cumans_rejected_secondary", 
				true,
				710
			);

			cm:cai_strategic_stance_manager_promote_specified_stance_towards_target_faction(GOLDEN_HORDE_KEY, HUNGARY_KEY, "CAI_STRATEGIC_STANCE_BEST_FRIENDS");
			cm:cai_strategic_stance_manager_promote_specified_stance_towards_target_faction(ILKHANATE_KEY, HUNGARY_KEY, "CAI_STRATEGIC_STANCE_BEST_FRIENDS");
		end
	elseif context:dilemma() == "mk_dilemma_story_hungary_golden_bull_1222" then
		if context:choice() == 0 then
			-- Choice made to sign the Golden Bull of 1222.	
			cm:show_message_event(
				HUNGARY_KEY,
				"message_event_text_text_mk_event_golden_bull_1222_title", 
				"message_event_text_text_mk_event_golden_bull_1222_signed_primary", 
				"message_event_text_text_mk_event_golden_bull_1222_signed_secondary", 
				true,
				710
			);
		elseif context:choice() == 1 then
			-- Choice made to refuse the Golden Bull of 1222.	
			cm:show_message_event(
				HUNGARY_KEY,
				"message_event_text_text_mk_event_golden_bull_1222_title", 
				"message_event_text_text_mk_event_golden_bull_1222_refused_primary", 
				"message_event_text_text_mk_event_golden_bull_1222_refused_secondary", 
				true,
				710
			);
		end
	end
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		cm:save_value("HUNGARY_REFUGEE_DILEMMA_STATUS", HUNGARY_REFUGEE_DILEMMA_STATUS, context);
		cm:save_value("HUNGARY_GOLDEN_BULL_DILEMMA_STATUS", HUNGARY_GOLDEN_BULL_DILEMMA_STATUS, context);
	end
);

cm:register_loading_game_callback(
	function(context)
		HUNGARY_REFUGEE_DILEMMA_STATUS = cm:load_value("HUNGARY_REFUGEE_DILEMMA_STATUS", "NOT TRIGGERED", context);
		HUNGARY_GOLDEN_BULL_DILEMMA_STATUS = cm:load_value("HUNGARY_GOLDEN_BULL_DILEMMA_STATUS", "NOT TRIGGERED", context);
	end
);