-----------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: HOLY ROMAN EMPIRE EVENTS
-- 	By: DETrooper
--
-----------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------
-- Events which can occur for the emperor and members of the HRE.

HRE_EVENTS_MIN_TURN = 4; -- First turn that an HRE event can occur.
HRE_EVENTS_TURNS_BETWEEN_DILEMMAS_MAX = 12;
HRE_EVENTS_TURNS_BETWEEN_DILEMMAS_MIN = 4;
HRE_EVENTS_TIMER = 0;

function Add_HRE_Event_Listeners()
	cm:add_listener(
		"FactionTurnStart_HRE_Events",
		"FactionTurnStart",
		true,
		function(context) FactionTurnStart_HRE_Events(context) end,
		true
	);
end

function FactionTurnStart_HRE_Events(context)
	if context:faction():is_human() then
		local faction_name = context:faction():name();

		if HasValue(FACTIONS_HRE, faction_name) then
			local turn_number = cm:model():turn_number();

			if turn_number >= HRE_EVENTS_MIN_TURN then
				if HRE_EVENTS_TIMER > 0 then
					HRE_EVENTS_TIMER = HRE_EVENTS_TIMER - 1;
				elseif HRE_EVENTS_TIMER <= 0 then
					HRE_EVENTS_TIMER = cm:random_number(HRE_EVENTS_TURNS_BETWEEN_DILEMMAS_MAX, HRE_EVENTS_TURNS_BETWEEN_DILEMMAS_MIN);

					--cm:trigger_dilemma(faction_name, HRE_RANDOM_DILEMMAS[cm:random_number(1, #HRE_RANDOM_DILEMMAS)]);
				end
			end
		end
	end
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		cm:save_value("HRE_EVENTS_TIMER", HRE_EVENTS_TIMER, context);
	end
);

cm:register_loading_game_callback(
	function(context)
		HRE_EVENTS_TIMER = cm:load_value("HRE_EVENTS_TIMER", 0, context);
	end
);