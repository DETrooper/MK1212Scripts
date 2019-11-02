-------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - KINGDOM: GOLDEN HORDE
-- 	By: DETrooper
--
-------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------

SERBIA_KEY = "mk_fact_serbia";
SERBIAN_KINGDOM_FACTION = "NIL";

function Add_Kingdom_Serbia_Listeners()
	if SERBIAN_KINGDOM_FACTION == "NIL" then
		cm:add_listener(
			"FactionTurnStart_Serbia_Check",
			"FactionTurnStart",
			true,
			function(context) Serbia_Check(context) end,
			true
		);
	end
end

function Serbia_Check(context)
	local turn_number = cm:model():turn_number();
	local faction_key = context:faction():name();
	local faction = cm:model():world():faction_by_key(faction_key);
	
	if faction_key == SERBIA_KEY then
		if turn_number == 6 then
			if faction:is_human() then
				cm:trigger_incident(SERBIA_KEY, "mk_incident_story_serbia_kingdom");

				if cm:is_multiplayer() == false then
					Add_Decision("found_an_empire", faction_key, false, false);
				end
			end

			Rename_Faction(SERBIA_KEY, "mk_faction_serbian_kingdom");
			FACTIONS_DFN_LEVEL[faction_key] = 2;
			SERBIAN_KINGDOM_FACTION = faction_key;
			cm:remove_listener("FactionTurnStart_Serbia_Check");
		end
	end
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		cm:save_value("SERBIAN_KINGDOM_FACTION", SERBIAN_KINGDOM_FACTION, context);
	end
);

cm:register_loading_game_callback(
	function(context)
		SERBIAN_KINGDOM_FACTION = cm:load_value("SERBIAN_KINGDOM_FACTION", "NIL", context);
	end
);