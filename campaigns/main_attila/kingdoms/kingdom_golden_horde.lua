-------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - KINGDOM: GOLDEN HORDE
-- 	By: DETrooper
--
-------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------

JOCHI_KEY = "mk_fact_goldenhorde";
GOLDEN_HORDE_FACTION = "NIL";
GOLDEN_HORDE_REGIONS_OWNED = false;

function Add_Kingdom_Golden_Horde_Listeners()
	if GOLDEN_HORDE_FACTION == "NIL" then
		cm:add_listener(
			"FactionTurnStart_Golden_Horde_Check",
			"FactionTurnStart",
			true,
			function(context) Golden_Horde_Check(context) end,
			true
		);
		cm:add_listener(
			"SettlementOccupied_Golden_Horde_Regions_Check",
			"SettlementOccupied",
			true,
			function(context) Golden_Horde_Regions_Check(context) end,
			true
		);
	end

	if cm:is_new_game() and cm:is_multiplayer() == false then
		local faction_name = cm:get_local_faction();
		
		if faction_name == JOCHI_KEY then
			Add_Decision("form_empire_golden_horde", faction_name, false, true);
		end
	end
end

function Golden_Horde_Check(context)
	local give_mission_turn = 2;
	local turn_number = cm:model():turn_number();
	local turn_faction = context:faction():name();
	
	if turn_faction == JOCHI_KEY then
		if turn_number == give_mission_turn and cm:model():world():faction_by_key(turn_faction):is_human() and cm:is_multiplayer() == true then
			cm:trigger_mission(turn_faction, "mk_mission_kingdom_goldenhorde");
		elseif turn_number > give_mission_turn then
			Golden_Horde_Regions_Check(context);
		end
	end
end

function Golden_Horde_Regions_Check(context)
	local faction_key = context:faction():name();
	local has_regions = Has_Required_Regions(faction_key, REGIONS_GOLDEN_HORDE);
	GOLDEN_HORDE_REGIONS_OWNED = has_regions;
		
	if has_regions == true then
		if cm:is_multiplayer() == true or cm:model():world():faction_by_key(faction_key):is_human() == false then
			Golden_Horde_Formed(faction_key);
		else
			Enable_Decision("form_empire_golden_horde");
		end	
	end
end

function Golden_Horde_Formed(faction_key)
	Rename_Faction(faction_key, "mk_faction_goldenhorde");
	FACTIONS_DFN_LEVEL[faction_key] = 4;
	GOLDEN_HORDE_FACTION = faction_key;

	if cm:is_multiplayer() == false then
		Remove_Decision("form_empire_golden_horde");
	else
		cm:override_mission_succeeded_status(faction_key, "mk_mission_kingdom_goldenhorde", true);
	end

	cm:show_message_event(
		faction_key, 
		"message_event_text_text_mk_event_golden_horde_formed_title", 
		"message_event_text_text_mk_event_golden_horde_formed_primary",
		"message_event_text_text_mk_event_golden_horde_formed_secondary",
		true, 
		719
	);

	cm:remove_listener("FactionTurnStart_Golden_Horde_Check");
	cm:remove_listener("SettlementOccupied_Golden_Horde_Regions_Check");
end

function GetConditionsString_Golden_Horde()
	local conditionstring = "Conditions:\n\n([[rgba:8:201:27:150]]Y[[/rgba]]) - Is the Ulus of Jochi.\n([[rgba:8:201:27:150]]Y[[/rgba:8:201:27:150]]) - The Golden Horde does not yet exist.\n";
	
	if GOLDEN_HORDE_REGIONS_OWNED == true then
		conditionstring = conditionstring.."([[rgba:8:201:27:150]]Y[[/rgba]]) - Own the entirety of the provinces of: Itil and Sarmatia, and the regions of: Derbent, Kursk, Ryazan, and Tana.";
	else
		conditionstring = conditionstring.."([[rgba:255:0:0:150]]X[[/rgba]]) - Own the entirety of the provinces of: Itil and Sarmatia, and the regions of: Derbent, Kursk, Ryazan, and Tana.";		
	end

	conditionstring = conditionstring.."\n\nEffects:\n\n- Become the [[rgba:255:215:0:215]]Golden Horde[[/rgba]].";

	return conditionstring;
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		cm:save_value("GOLDEN_HORDE_FACTION", GOLDEN_HORDE_FACTION, context);
		cm:save_value("GOLDEN_HORDE_REGIONS_OWNED", GOLDEN_HORDE_REGIONS_OWNED, context);
	end
);

cm:register_loading_game_callback(
	function(context)
		GOLDEN_HORDE_FACTION = cm:load_value("GOLDEN_HORDE_FACTION", "NIL", context);
		GOLDEN_HORDE_REGIONS_OWNED = cm:load_value("GOLDEN_HORDE_REGIONS_OWNED", false, context);
	end
);