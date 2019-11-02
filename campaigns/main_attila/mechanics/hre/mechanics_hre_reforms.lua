--------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: HOLY ROMAN EMPIRE REFORMS
-- 	By: DETrooper
--
--------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------
-- System for the HRE to reform its centralization and eventually become unified.

CURRENT_HRE_REFORM= 0;
HRE_IMPERIAL_AUTHORITY = 40; -- Starting authority

function Add_HRE_Reform_Listeners()
	cm:add_listener(
		"FactionTurnStart_HRE_Reform",
		"FactionTurnStart",
		true,
		function(context) FactionTurnStart_HRE_Reform(context) end,
		true
	);
end

function FactionTurnStart_HRE_Reform(context)
	local faction_list = cm:model():world():faction_list();
	local turn_number = cm:model():turn_number();

	if CURRENT_HRE_REFORM == 6 then
		CURRENT_HRE_REFORM = -1;

		for i = 0, faction_list:num_items() - 1 do
			local current_faction = faction_list:item_at(i);

			if current_faction:name() ~= HRE_EMPEROR_KEY and FACTIONS_HRE[current_faction:name()] == true then
				cm:grant_faction_handover(HRE_EMPEROR_KEY, current_faction:name(), turn_number-1, turn_number-1, context);
			end
		end
	end
end


--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		cm:save_value("CURRENT_HRE_REFORM", CURRENT_HRE_REFORM, context);
		cm:save_value("HRE_IMPERIAL_AUTHORITY", HRE_IMPERIAL_AUTHORITY, context);
	end
);

cm:register_loading_game_callback(
	function(context)
		CURRENT_HRE_REFORM = cm:load_value("CURRENT_HRE_REFORM", 0, context);
		HRE_IMPERIAL_AUTHORITY = cm:load_value("HRE_IMPERIAL_AUTHORITY", 40, context);
	end
);