----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - KINGDOM: POLAND
-- 	By: DETrooper
--
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

POLAND_KEY = "mk_fact_lesserpoland";
POLISH_KINGDOM_FACTION = "NIL";
POLISH_KINGDOM_REGIONS_OWNED = false;

function Add_Kingdom_Poland_Listeners()
	if POLISH_KINGDOM_FACTION == "NIL" then
		cm:add_listener(
			"FactionTurnStart_Poland_Check",
			"FactionTurnStart",
			true,
			function(context) Poland_Check(context) end,
			true
		);
		cm:add_listener(
			"SettlementOccupied_Polish_Regions_Check",
			"SettlementOccupied",
			true,
			function(context) Polish_Regions_Check(context) end,
			true
		);
	end

	if cm:is_new_game() and cm:is_multiplayer() == false then
		local faction_name = cm:get_local_faction();
		
		if faction_name == POLAND_KEY then
			Add_Decision("form_kingdom_poland", faction_name, false, false, true);
		end
	end
end

function Poland_Check(context)
	local give_mission_turn = 2;
	local turn_number = cm:model():turn_number();
	local turn_faction = context:faction():name();
	
	if turn_faction == POLAND_KEY then
		if turn_number == give_mission_turn and cm:model():world():faction_by_key(turn_faction):is_human() and cm:is_multiplayer() == true then
			cm:trigger_mission(turn_faction, "mk_mission_kingdom_poland");
		elseif turn_number > give_mission_turn then
			Polish_Regions_Check(context);
		end
	end
end

function Polish_Regions_Check(context)
	local faction_key = context:faction():name();
	local has_regions = Has_Required_Regions(faction_key, REGIONS_POLAND);
	POLISH_KINGDOM_REGIONS_OWNED = has_regions;
		
	if has_regions == true then
		if cm:is_multiplayer() == true or cm:model():world():faction_by_key(faction_key):is_human() == false then
			Polish_Kingdom_Formed(faction_key);
		else
			Enable_Decision("form_kingdom_poland");
		end
	end
end

function Polish_Kingdom_Formed(faction_key)
	Rename_Faction(faction_key, "mk_faction_polish_kingdom");
	FACTIONS_DFN_LEVEL[faction_key] = 2;
	POLISH_KINGDOM_FACTION = faction_key; 

	if cm:is_multiplayer() == false then
		Remove_Decision("form_kingdom_poland");
		Add_Decision("found_an_empire", faction_key, false, false);
	else
		cm:override_mission_succeeded_status(faction_key, "mk_mission_kingdom_poland", true);
	end

	cm:show_message_event(
		faction_key, 
		"message_event_text_text_mk_event_polish_kingdom_formed_title", 
		"message_event_text_text_mk_event_polish_kingdom_formed_primary",
		"message_event_text_text_mk_event_polish_kingdom_formed_secondary",
		true, 
		721
	);

	cm:remove_listener("FactionTurnStart_Poland_Check");
	cm:remove_listener("SettlementOccupied_Polish_Regions_Check");
end

function GetConditionsString_Poland()
	local conditionstring = "Conditions:\n\n([[rgba:8:201:27:150]]Y[[/rgba]]) - Is the Duchy of Lesser Poland.\n([[rgba:8:201:27:150]]Y[[/rgba:8:201:27:150]]) - The Kingdom of Poland does not yet exist.\n";
	
	if POLISH_KINGDOM_REGIONS_OWNED == true then
		conditionstring = conditionstring.."([[rgba:8:201:27:150]]Y[[/rgba]]) - Own the the regions of: Gdansk, Krakow, Poznan, and Wroclaw";
	else
		conditionstring = conditionstring.."([[rgba:255:0:0:150]]X[[/rgba]]) - Own the the regions of: Gdansk, Krakow, Poznan, and Wroclaw";	
	end

	conditionstring = conditionstring.."\n\nEffects:\n\n- Become the [[rgba:255:215:0:215]]Kingdom of Poland[[/rgba]].";

	return conditionstring;
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		cm:save_value("POLISH_KINGDOM_FACTION", POLISH_KINGDOM_FACTION, context);
		cm:save_value("POLISH_KINGDOM_REGIONS_OWNED", POLISH_KINGDOM_REGIONS_OWNED, context);
	end
);

cm:register_loading_game_callback(
	function(context)
		POLISH_KINGDOM_FACTION = cm:load_value("POLISH_KINGDOM_FACTION", "NIL", context);
		POLISH_KINGDOM_REGIONS_OWNED = cm:load_value("POLISH_KINGDOM_REGIONS_OWNED", false, context);
	end
);