----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: SETTLE UPKEEP
-- 	By: DETrooper
--
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
-- When hordes settle, give reduced upkeep for 5 turns.

FACTIONS_SETTLED = {};

function Add_Settle_Upkeep_Listeners()
	cm:add_listener(
		"FactionHordeStatusChange_Settle_Upkeep",
		"FactionHordeStatusChange",
		true,
		function(context) FactionHordeStatusChange_Settle_Upkeep(context) end,
		true
	);
end

function FactionHordeStatusChange_Settle_Upkeep(context)
	if not table.HasValue(FACTIONS_SETTLED, context:faction():name()) then
		if context:faction():is_human() then
			cm:apply_effect_bundle("mk_bundle_horde_settle_reduced_upkeep", context:faction():name(), 5);
		else
			cm:apply_effect_bundle("mk_bundle_horde_settle_reduced_upkeep_ai", context:faction():name(), 5);
		end

		table.insert(FACTIONS_SETTLED, context:faction():name());
	end
end

------------------------------------------------
---------------- Saving/Loading ----------------
------------------------------------------------
cm:register_loading_game_callback(
	function(context)
		FACTIONS_SETTLED = LoadTable(context, "FACTIONS_SETTLED");
	end
);

cm:register_saving_game_callback(
	function(context)
		SaveTable(context, FACTIONS_SETTLED, "FACTIONS_SETTLED");
	end
);