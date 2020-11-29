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
SERBIAN_KINGDOM_TURN = 10;

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
	local faction_name = context:faction():name();
	local faction = context:faction();
	
	if faction_name == SERBIA_KEY then
		if turn_number == SERBIAN_KINGDOM_TURN then
			if faction:is_human() then
				cm:trigger_incident(SERBIA_KEY, "mk_incident_story_serbia_kingdom");

				if cm:is_multiplayer() == false then
					Add_Decision("found_an_empire", faction_name, false, false);
				end
			end

			if NICKNAMES then
				Add_Character_Nickname(faction:faction_leader():cqi(), "the_first_crowned", false);
			end

			FACTIONS_DFN_LEVEL[faction_name] = 2;
			SERBIAN_KINGDOM_FACTION = faction_name;
			Rename_Faction(faction_name, faction_name.."_lvl"..tostring(FACTIONS_DFN_LEVEL[faction_name]));
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
