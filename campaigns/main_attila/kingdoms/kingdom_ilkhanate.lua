----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - KINGDOM: ILKHANATE
-- 	By: DETrooper
--
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------

TOLUI_KEY = "mk_fact_ilkhanate";
ILKHANATE_FACTION = "NIL";
ILKHANATE_REGIONS_OWNED = false;

function Add_Kingdom_Ilkhanate_Listeners()
	if ILKHANATE_FACTION == "NIL" then
		cm:add_listener(
			"FactionTurnStart_Ilkhanate_Check",
			"FactionTurnStart",
			true,
			function(context) Ilkhanate_Check(context) end,
			true
		);
		cm:add_listener(
			"SettlementOccupied_Ilkhanate_Regions_Check",
			"SettlementOccupied",
			true,
			function(context) Ilkhanate_Regions_Check(context) end,
			true
		);
	end

	if cm:is_new_game() and cm:is_multiplayer() == false then
		local faction_name = cm:get_local_faction();
		
		if faction_name == TOLUI_KEY then
			Add_Decision("form_empire_ilkhanate", faction_name, false, true);
		end
	end
end

function Ilkhanate_Check(context)
	local give_mission_turn = 2;
	local turn_number = cm:model():turn_number();
	local turn_faction = context:faction():name();
	
	if turn_faction == TOLUI_KEY then
		if turn_number == give_mission_turn and cm:model():world():faction_by_key(turn_faction):is_human() and cm:is_multiplayer() == true then
			cm:trigger_mission(turn_faction, "mk_mission_kingdom_ilkhanate");
		elseif turn_number > give_mission_turn then
			Ilkhanate_Regions_Check(context);
		end
	end
end

function Ilkhanate_Regions_Check(context)
	local faction_key = context:faction():name();
	local has_regions = Has_Required_Regions(faction_key, REGIONS_ILKHANATE);
	ILKHANATE_REGIONS_OWNED = has_regions;

	if has_regions == true then
		if cm:is_multiplayer() == true or cm:model():world():faction_by_key(faction_key):is_human() == false then
			Ilkhanate_Formed(faction_key);
		else
			Enable_Decision("form_empire_ilkhanate");
		end		
	end
end

function Ilkhanate_Formed(faction_key)
	Rename_Faction(faction_key, "mk_faction_ilkhanate");
	FACTIONS_DFN_LEVEL[faction_key] = 4;
	ILKHANATE_FACTION = faction_key;

	if cm:is_multiplayer() == false then
		Remove_Decision("form_empire_ilkhanate");
	else
		cm:override_mission_succeeded_status(faction_key, "mk_mission_kingdom_ilkhanate", true);
	end

	cm:show_message_event(
		faction_key, 
		"message_event_text_text_mk_event_ilkhanate_formed_title", 
		"message_event_text_text_mk_event_ilkhanate_formed_primary",
		"message_event_text_text_mk_event_ilkhanate_formed_secondary",
		true, 
		720
	);

	cm:remove_listener("FactionTurnStart_Ilkhanate_Check");
	cm:remove_listener("SettlementOccupied_Ilkhanate_Regions_Check");
end

function GetConditionsString_Ilkhanate()
	local conditionstring = "Conditions:\n\n([[rgba:8:201:27:150]]Y[[/rgba]]) - Is the Ulus of Tolui.\n([[rgba:8:201:27:150]]Y[[/rgba:8:201:27:150]]) - The Ilkhanate does not yet exist.\n";
	
	for i = 1, #REGIONS_ILKHANATE do
		local region = cm:model():world():region_manager():region_by_key(REGIONS_ILKHANATE[i]);
		
		if region:owning_faction():name() == cm:get_local_faction() then
			conditionstring = conditionstring.."([[rgba:8:201:27:150]]Y[[/rgba]]) - Own the region of "..REGIONS_NAMES_LOCALISATION[REGIONS_ILKHANATE[i]]..".\n";
		else
			conditionstring = conditionstring.."([[rgba:255:0:0:150]]X[[/rgba]]) - Own the region of "..REGIONS_NAMES_LOCALISATION[REGIONS_ILKHANATE[i]]..".\n";
		end
	end

	conditionstring = conditionstring.."\nEffects:\n\n- Become the [[rgba:255:215:0:215]]Ilkhanate[[/rgba]].";

	return conditionstring;
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		cm:save_value("ILKHANATE_FACTION", ILKHANATE_FACTION, context);
		cm:save_value("ILKHANATE_REGIONS_OWNED", ILKHANATE_REGIONS_OWNED, context);
	end
);

cm:register_loading_game_callback(
	function(context)
		ILKHANATE_FACTION = cm:load_value("ILKHANATE_FACTION", "NIL", context);
		ILKHANATE_REGIONS_OWNED = cm:load_value("ILKHANATE_REGIONS_OWNED", false, context);
	end
);