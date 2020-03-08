------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - STORY: HOLY ROMAN EMPIRE
-- 	By: DETrooper
--
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
-- Story events for war with Sicily and war with France handled elsewhere for the most part.

HRE_KEY = "mk_fact_hre";

HRE_PEACE_COUNTDOWN = 10;

function Add_HRE_Story_Events_Listeners()
	local hre = cm:model():world():faction_by_key(HRE_KEY);

	cm:add_listener(
		"FactionTurnStart_HRE",
		"FactionTurnStart",
		true,
		function(context) FactionTurnStart_HRE(context) end,
		true
	);

	if cm:is_new_game() then
		-- Make sure the HRE doesn't dissolve immediately by implementing a 10 turn or so realm peace.
		for i = 1, #FACTIONS_HRE_START do
			if FACTIONS_HRE_START[i] ~= "mk_fact_hre" and cm:model():world():faction_by_key(FACTIONS_HRE_START[i]):is_human() == false then
				cm:force_diplomacy(FACTIONS_HRE_START[i], HRE_KEY, "war", false, false);
			end
		end

		-- Notify HRE player of their excommunication.
		if hre:is_human() then
			cm:show_message_event(
				HRE_KEY,
				"message_event_text_text_mk_event_hre_excommunication_title", 
				"message_event_text_text_mk_event_hre_excommunication_primary", 
				"message_event_text_text_mk_event_hre_excommunication_secondary", 
				true,
				707
			);
		end
	end
end

function FactionTurnStart_HRE(context)
	if context:faction():name() == HRE_KEY then
		if HRE_PEACE_COUNTDOWN > 0 then
			HRE_PEACE_COUNTDOWN = HRE_PEACE_COUNTDOWN - 1;
		elseif HRE_PEACE_COUNTDOWN == 0 then
			for i = 1, #FACTIONS_HRE_START do
				if FACTIONS_HRE_START[i] ~= "mk_fact_hre" then
					cm:force_diplomacy(FACTIONS_HRE_START[i], HRE_KEY, "war", true, true);
				end
			end

			HRE_PEACE_COUNTDOWN = -1;
		end
	end
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		cm:save_value("HRE_PEACE_COUNTDOWN", HRE_PEACE_COUNTDOWN, context);
	end
);

cm:register_loading_game_callback(
	function(context)
		HRE_PEACE_COUNTDOWN = cm:load_value("HRE_PEACE_COUNTDOWN", 10, context);
	end
);