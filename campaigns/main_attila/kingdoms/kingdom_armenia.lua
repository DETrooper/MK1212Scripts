----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - KINGDOM: ARMENIA
-- 	By: DETrooper
--
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

ARMENIA_KEY = "mk_fact_armenia";
ARMENIAN_KINGDOM_FACTION = "NIL";
ARMENIAN_KINGDOM_REGIONS_OWNED = false;

function Add_Kingdom_Armenia_Listeners()
	if ARMENIAN_KINGDOM_FACTION == "NIL" then
		cm:add_listener(
			"FactionTurnStart_Armenia_Check",
			"FactionTurnStart",
			true,
			function(context) Armenia_Check(context) end,
			true
		);
		cm:add_listener(
			"SettlementOccupied_Armenian_Regions_Check",
			"SettlementOccupied",
			true,
			function(context) Armenian_Regions_Check(context) end,
			true
		);
	end

	if cm:is_new_game() and cm:is_multiplayer() == false then
		local faction_name = cm:get_local_faction();
		
		if faction_name == ARMENIA_KEY then
			Add_Decision("form_kingdom_armenia", faction_name, false, false, true);
		end
	end
end

function Armenia_Check(context)
	local give_mission_turn = 2;
	local turn_number = cm:model():turn_number();
	local turn_faction = context:faction():name();
	
	if turn_faction == ARMENIA_KEY then
		if turn_number == give_mission_turn and cm:model():world():faction_by_key(turn_faction):is_human() and cm:is_multiplayer() == true then
			cm:trigger_mission(turn_faction, "mk_mission_kingdom_armenia");
		elseif turn_number > give_mission_turn then
			Armenian_Regions_Check(context);
		end
	end
end

function Armenian_Regions_Check(context)
	local faction_key = context:faction():name();
	local has_regions = Has_Required_Regions(faction_key, REGIONS_ARMENIA);
	ARMENIAN_KINGDOM_REGIONS_OWNED = has_regions;
		
	if has_regions == true then
		if cm:is_multiplayer() == true or cm:model():world():faction_by_key(faction_key):is_human() == false then
			Armenian_Kingdom_Formed(faction_key);
		else
			Enable_Decision("form_kingdom_armenia");
		end
	end
end

function Armenian_Kingdom_Formed(faction_key)
	Rename_Faction(faction_key, "mk_faction_armenian_kingdom");
	FACTIONS_DFN_LEVEL[faction_key] = 4;
	ARMENIAN_KINGDOM_FACTION = faction_key; 

	if cm:is_multiplayer() == false then
		Remove_Decision("form_kingdom_armenia");
		Add_Decision("found_an_empire", faction_key, false, false);
	else
		cm:override_mission_succeeded_status(faction_key, "mk_mission_kingdom_armenia", true);
	end

	cm:show_message_event(
		faction_key, 
		"message_event_text_text_mk_event_armenian_kingdom_formed_title", 
		"message_event_text_text_mk_event_armenian_kingdom_formed_primary",
		"message_event_text_text_mk_event_armenian_kingdom_formed_secondary",
		true, 
		721
	);

	cm:remove_listener("FactionTurnStart_Armenia_Check");
	cm:remove_listener("SettlementOccupied_Armenian_Regions_Check");
end

function GetConditionsString_Armenia()
	local conditionstring = "Conditions:\n\n([[rgba:8:201:27:150]]Y[[/rgba]]) - Is the Kingdom of Cilicia.\n([[rgba:8:201:27:150]]Y[[/rgba:8:201:27:150]]) - The Kingdom of Armenia does not yet exist.\n";
	
	for i = 1, #REGIONS_ARMENIA do
		local region = cm:model():world():region_manager():region_by_key(REGIONS_ARMENIA[i]);
		
		if region:owning_faction():name() == cm:get_local_faction() then
			conditionstring = conditionstring.."([[rgba:8:201:27:150]]Y[[/rgba]]) - Own the region of "..REGIONS_NAMES_LOCALISATION[REGIONS_ARMENIA[i]]..".\n";
		else
			conditionstring = conditionstring.."([[rgba:255:0:0:150]]X[[/rgba]]) - Own the region of "..REGIONS_NAMES_LOCALISATION[REGIONS_ARMENIA[i]]..".\n";
		end
	end
	conditionstring = conditionstring.."\nEffects:\n\n- Become the [[rgba:255:215:0:215]]Kingdom of Armenia[[/rgba]].";

	return conditionstring;
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		cm:save_value("ARMENIAN_KINGDOM_FACTION", ARMENIAN_KINGDOM_FACTION, context);
		cm:save_value("ARMENIAN_KINGDOM_REGIONS_OWNED", ARMENIAN_KINGDOM_REGIONS_OWNED, context);
	end
);

cm:register_loading_game_callback(
	function(context)
		ARMENIAN_KINGDOM_FACTION = cm:load_value("ARMENIAN_KINGDOM_FACTION", "NIL", context);
		ARMENIAN_KINGDOM_REGIONS_OWNED = cm:load_value("ARMENIAN_KINGDOM_REGIONS_OWNED", false, context);
	end
);