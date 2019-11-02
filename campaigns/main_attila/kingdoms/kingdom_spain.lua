-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - KINGDOM: SPAIN
-- 	By: DETrooper
--
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------

ARAGON_KEY = "mk_fact_aragon";
CASTILE_KEY = "mk_fact_castile";
NAVARRE_KEY = "mk_fact_navarre";
SPANISH_KINGDOM_MISSION_TURN = 4;

SPANISH_KINGDOM_FACTION = "NIL";
SPANISH_KINGDOM_REGIONS_OWNED = false;

function Add_Kingdom_Spain_Listeners()
	if SPANISH_KINGDOM_FACTION == "NIL" then
		cm:add_listener(
			"FactionTurnStart_Spain_Check",
			"FactionTurnStart",
			true,
			function(context) Spain_Check(context) end,
			true
		);
		cm:add_listener(
			"SettlementOccupied_Spanish_Regions_Check",
			"SettlementOccupied",
			true,
			function(context) Spanish_Regions_Check(context) end,
			true
		);
	end

	if cm:is_new_game() and cm:is_multiplayer() == false then
		local faction_name = cm:get_local_faction();
		
		if faction_name == ARAGON_KEY or faction_name == CASTILE_KEY or faction_name == NAVARRE_KEY then
			Add_Decision("form_kingdom_spain", faction_name, false, true);
		end
	end
end

function Spain_Check(context)
	local turn_number = cm:model():turn_number();
	local turn_faction = context:faction():name();
	
	if turn_faction == ARAGON_KEY or turn_faction == CASTILE_KEY or turn_faction == NAVARRE_KEY then
		if turn_number == SPANISH_KINGDOM_MISSION_TURN and cm:model():world():faction_by_key(turn_faction):is_human() and cm:is_multiplayer() == true then
			cm:trigger_mission(turn_faction, "mk_mission_kingdom_spain");
		elseif turn_number > 1 then
			Spanish_Regions_Check(context);
		end
	end
end

function Spanish_Regions_Check(context)
	local faction_key = context:faction():name();
	local has_regions = Has_Required_Regions(faction_key, REGIONS_SPAIN_NO_PORTUGAL);
	SPANISH_KINGDOM_REGIONS_OWNED = has_regions;
		
	if has_regions == true then
		if cm:is_multiplayer() == true or cm:model():world():faction_by_key(faction_key):is_human() == false then
			Spanish_Kingdom_Formed(faction_key);
		else
			Enable_Decision("form_kingdom_spain");
		end
	end
end

function Spanish_Kingdom_Formed(faction_key)
	Rename_Faction(faction_key, "mk_faction_spanish_kingdom");
	FACTIONS_DFN_LEVEL[faction_key] = 4;
	SPANISH_KINGDOM_FACTION = faction_key;

	if cm:is_multiplayer() == false then
		Remove_Decision("form_kingdom_spain");
		Add_Decision("found_an_empire", faction_key, false, false);
	else
		cm:override_mission_succeeded_status(faction_key, "mk_mission_kingdom_spain", true);
	end

	cm:show_message_event(
		faction_key, 
		"message_event_text_text_mk_event_spanish_kingdom_formed_title", 
		"message_event_text_text_mk_event_spanish_kingdom_formed_primary",
		"message_event_text_text_mk_event_spanish_kingdom_formed_secondary_"..faction_key,
		true, 
		722
	);


	cm:remove_listener("FactionTurnStart_Spain_Check");
	cm:remove_listener("SettlementOccupied_Spanish_Regions_Check");
end

function GetConditionsString_Spain()
	local conditionstring = "Conditions:\n\n([[rgba:8:201:27:150]]Y[[/rgba]]) - Is Crown of Aragon, Kingdom of Castile, or Kingdom of Navarre.\n([[rgba:8:201:27:150]]Y[[/rgba:8:201:27:150]]) - The Kingdom of Spain does not yet exist.\n";
	
	if SPANISH_KINGDOM_REGIONS_OWNED == true then
		conditionstring = conditionstring.."([[rgba:8:201:27:150]]Y[[/rgba]]) - Own the entirety of the provinces of: Andalusia, Castella et Aragonia, and Castella Nova, and the regions of: Badajoz, Leon, and Santiago.";
	else
		conditionstring = conditionstring.."([[rgba:255:0:0:150]]X[[/rgba]]) - Own the entirety of the provinces of: Andalusia, Castella et Aragonia, and Castella Nova, and the regions of: Badajoz, Leon, and Santiago.";	
	end

	conditionstring = conditionstring.."\n\nEffects:\n\n- Become the [[rgba:255:215:0:215]]Kingdom of Spain[[/rgba]].";

	return conditionstring;
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		cm:save_value("SPANISH_KINGDOM_FACTION", SPANISH_KINGDOM_FACTION, context);
		cm:save_value("SPANISH_KINGDOM_REGIONS_OWNED", SPANISH_KINGDOM_REGIONS_OWNED, context);
	end
);

cm:register_loading_game_callback(
	function(context)
		SPANISH_KINGDOM_FACTION = cm:load_value("SPANISH_KINGDOM_FACTION", "NIL", context);
		SPANISH_KINGDOM_REGIONS_OWNED = cm:load_value("SPANISH_KINGDOM_REGIONS_OWNED", false, context);
	end
);