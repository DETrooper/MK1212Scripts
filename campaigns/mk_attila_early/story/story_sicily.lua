--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - STORY: SICILY
-- 	By: DETrooper
--
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

SICILY_KEY = "mk_fact_sicily";

SICILY_BECAME_EMPEROR = false;
SICILY_DILEMMA_CHOICE = 0;
SICILY_DILEMMA_ISSUED = false;
SICILY_KING_CQI = 0;

REGIONS_SICILY = {
	"mk_reg_naples",
	"mk_reg_palermo",
	"mk_reg_reggio",
	"mk_reg_syracuse",
	"mk_reg_taranto",
};

function Add_Sicily_Story_Events_Listeners()
	local sicily = cm:model():world():faction_by_key(SICILY_KEY);

	cm:add_listener(
		"FactionTurnStart_Sicily",
		"FactionTurnStart",
		true,
		function(context) FactionTurnStart_Sicily(context) end,
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
			cm:force_diplomacy(mkHRE.emperor_pretender_key, mkHRE.emperor_key, "war", false, false);
			cm:force_diplomacy(mkHRE.emperor_key, mkHRE.emperor_pretender_key, "war", false, false);
		end
	end

	if cm:is_new_game() then
		SICILY_KING_CQI = cm:model():world():faction_by_key(SICILY_KEY):faction_leader():command_queue_index();

		-- For the duration of Sicily's mission, ensure that the HRE's tributaries do not get involved in the war with Sicily.
		for i = 1, #mkHRE.factions_start do
			if mkHRE.factions_start[i] ~= mkHRE.emperor_key then
				cm:force_diplomacy(mkHRE.factions_start[i], SICILY_KEY, "war", false, false);
			end
		end
	end
end

function FactionTurnStart_Sicily(context)
	if mkHRE.emperor_key then
		local sicily = cm:model():world():faction_by_key(SICILY_KEY);
		local hre = cm:model():world():faction_by_key(mkHRE.emperor_key);

		if context:faction():name() == SICILY_KEY then
			if sicily:is_human() then
				if cm:model():turn_number() == 2 then
					-- Re-enable war with the HRE.
					cm:force_diplomacy(SICILY_KEY, mkHRE.emperor_key, "war", true, true);
					cm:force_diplomacy(mkHRE.emperor_key, SICILY_KEY, "war", true, true);
					cm:trigger_dilemma(SICILY_KEY, "mk_dilemma_story_sicily_war_with_hre");
				end
			else
				if hre:is_human() == false then
					if cm:model():turn_number() == 2 and sicily:at_war_with(hre) == false then
						cm:force_diplomacy(SICILY_KEY, mkHRE.emperor_key, "war", true, true);
						cm:force_diplomacy(mkHRE.emperor_key, SICILY_KEY, "war", true, true);
						cm:force_declare_war(mkHRE.emperor_key, SICILY_KEY);
					end
				end

				if SICILY_BECAME_EMPEROR == true and SICILY_DILEMMA_ISSUED == false then
					if CRUSADE_ACTIVE == true then
						Force_Excommunication(SICILY_KEY);
						SICILY_DILEMMA_CHOICE = 2;
						SICILY_DILEMMA_ISSUED = true;
					end
				end
			end

			if SICILY_BECAME_EMPEROR == false and SICILY_KEY == mkHRE.emperor_key then
				for i = 1, #mkHRE.factions_start do
					cm:force_diplomacy(mkHRE.factions_start[i], SICILY_KEY, "war", true, true);
				end

				SICILY_BECAME_EMPEROR = true;
			end

			if SICILY_DILEMMA_ISSUED == false and SICILY_BECAME_EMPEROR == true then
				if CRUSADE_ACTIVE == true then
					if not table.HasValue(CURRENT_CRUSADE_FACTIONS_JOINED, SICILY_KEY) then
						cm:trigger_dilemma(SICILY_KEY, "mk_dilemma_story_sicily_join_crusade");
					end

					SICILY_DILEMMA_ISSUED = true;
				end
			end
		elseif context:faction():name() == mkHRE.emperor_key and context:faction():is_human() then
			if cm:model():turn_number() == 2 and sicily:at_war_with(hre) == false and sicily:is_human() == false then
				cm:force_diplomacy(SICILY_KEY, mkHRE.emperor_key, "war", true, true);
				cm:force_diplomacy(SICILY_KEY, mkHRE.emperor_key, "peace", false, false);
				cm:force_diplomacy(mkHRE.emperor_key, SICILY_KEY, "war", true, true);
				cm:force_diplomacy(mkHRE.emperor_key, SICILY_KEY, "peace", false, false);
				cm:force_declare_war(mkHRE.emperor_key, SICILY_KEY);

				cm:show_message_event(
					mkHRE.emperor_key,
					"message_event_text_text_mk_event_hre_sicilian_invasion_title", 
					"message_event_text_text_mk_event_hre_sicilian_invasion_primary", 
					"message_event_text_text_mk_event_hre_sicilian_invasion_secondary", 
					true,
					712
				);
			end
		end
	end
end

function DilemmaChoiceMadeEvent_Sicily(context)
	if context:dilemma() == "mk_dilemma_story_sicily_war_with_hre" then
		if mkHRE.emperor_key then
			local hre = cm:model():world():faction_by_key(mkHRE.emperor_key);

			if context:choice() == 0 then
				-- Choice made to declare war on HRE!
				cm:force_declare_war(mkHRE.emperor_key, SICILY_KEY);

				cm:trigger_mission(SICILY_KEY, "mk_mission_story_pretender_take_frankfurt");
				SetFactionsHostile(SICILY_KEY, mkHRE.emperor_key);

				if hre:is_human() == true then
					cm:show_message_event(
						mkHRE.emperor_key,
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

				for i = 1, #mkHRE.factions_start do
					cm:force_diplomacy(mkHRE.factions_start[i], SICILY_KEY, "war", true, true);
				end

				mkHRE:HRE_Vanquish_Pretender();
			end
		end
	elseif context:dilemma() == "mk_dilemma_story_sicily_join_crusade" then
		if context:choice() == 0 then
			-- Choice made to join the crusade!
			if not table.HasValue(CURRENT_CRUSADE_FACTIONS_JOINED, SICILY_KEY) then
				table.insert(CURRENT_CRUSADE_FACTIONS_JOINED, SICILY_KEY);
	
				if context:faction():at_war_with(cm:model():world():faction_by_key(CURRENT_CRUSADE_TARGET_OWNER)) == false then
					cm:force_declare_war(SICILY_KEY, CURRENT_CRUSADE_TARGET_OWNER);
				end
	
				cm:force_diplomacy(SICILY_KEY, CURRENT_CRUSADE_TARGET_OWNER, "peace", false, false);
				cm:force_diplomacy(CURRENT_CRUSADE_TARGET_OWNER, SICILY_KEY, "peace", false, false);
	
				cm:trigger_mission(SICILY_KEY, CURRENT_CRUSADE_MISSION_KEY);
	
				cm:show_message_event(
					SICILY_KEY, 
					"message_event_text_text_mk_event_crusade_"..tostring(CURRENT_CRUSADE).."_title", 
					"message_event_text_text_mk_event_crusade_joined_primary", 
					"message_event_text_text_mk_event_crusade_joined_secondary", 
					true,
					706
				);
	
				if FACTION_EXCOMMUNICATED[SICILY_KEY] == true then
					Remove_Excommunication_Manual(SICILY_KEY);
				end
	
				Add_Pope_Favour(SICILY_KEY, 2, "joined_crusade");
			end
		elseif context:choice() == 1 then
			-- Choice made not to join the crusade!
			Subtract_Pope_Favour(SICILY_KEY, 8, "refused_demands");
		end

		Update_Pope_Favour(cm:model():world():faction_by_key(SICILY_KEY));
		SICILY_DILEMMA_CHOICE = context:choice() + 1;
	end
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		cm:save_value("SICILY_BECAME_EMPEROR", SICILY_BECAME_EMPEROR, context);
		cm:save_value("SICILY_DILEMMA_CHOICE", SICILY_DILEMMA_CHOICE, context);
		cm:save_value("SICILY_DILEMMA_ISSUED", SICILY_DILEMMA_ISSUED, context);
		cm:save_value("SICILY_KING_CQI", SICILY_KING_CQI, context);
	end
);

cm:register_loading_game_callback(
	function(context)
		SICILY_BECAME_EMPEROR = cm:load_value("SICILY_BECAME_EMPEROR", false, context);
		SICILY_DILEMMA_CHOICE = cm:load_value("SICILY_DILEMMA_CHOICE", 0, context);
		SICILY_DILEMMA_ISSUED = cm:load_value("SICILY_DILEMMA_ISSUED", false, context);
		SICILY_KING_CQI = cm:load_value("SICILY_KING_CQI", 0, context);
	end
);
