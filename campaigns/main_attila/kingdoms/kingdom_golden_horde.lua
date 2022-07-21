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

	if cm:is_multiplayer() == false then
		Register_Decision(
			"form_empire_golden_horde", 
			function() 	
				local conditionstring = "Conditions:\n\n([[rgba:8:201:27:150]]Y[[/rgba]]) - Is the Ulus of Jochi.\n([[rgba:8:201:27:150]]Y[[/rgba:8:201:27:150]]) - The Golden Horde does not yet exist.\n";
				local faction_name = cm:get_local_faction();

				if mkHRE and HasValue(mkHRE.factions, faction_name) then
					conditionstring = conditionstring.."([[rgba:255:0:0:150]]X[[/rgba]]) - Is not a member of the Holy Roman Empire.\n";
				else
					conditionstring = conditionstring.."([[rgba:8:201:27:150]]Y[[/rgba]]) - Is not a member of the Holy Roman Empire.\n";
				end
	
				for i = 1, #REGIONS_GOLDEN_HORDE do
					local region = cm:model():world():region_manager():region_by_key(REGIONS_GOLDEN_HORDE[i]);
					
					if region:owning_faction():name() == cm:get_local_faction() then
						conditionstring = conditionstring.."([[rgba:8:201:27:150]]Y[[/rgba]]) - Own the region of "..REGIONS_NAMES_LOCALISATION[REGIONS_GOLDEN_HORDE[i]]..".\n";
					else
						conditionstring = conditionstring.."([[rgba:255:0:0:150]]X[[/rgba]]) - Own the region of "..REGIONS_NAMES_LOCALISATION[REGIONS_GOLDEN_HORDE[i]]..".\n";
					end
				end
			
				conditionstring = conditionstring.."\nEffects:\n\n- Become the [[rgba:255:215:0:215]]Golden Horde[[/rgba]].";
			
				return conditionstring;
			end, 
			REGIONS_GOLDEN_HORDE, 
			{map_name = "kingdom_golden_horde_map", x = "1200", y = "900", map_pips = REGIONS_GOLDEN_HORDE_FACTION_PIPS_LOCATIONS},
			Golden_Horde_Formed
		);

		if cm:is_new_game() then
			local faction_name = cm:get_local_faction();
			
			if faction_name == JOCHI_KEY then
				Add_Decision("form_empire_golden_horde", faction_name, false, true);
			end
		end
	end
end

function Golden_Horde_Check(context)
	local faction_name = context:faction():name();
	
	if faction_name == JOCHI_KEY then
		Golden_Horde_Regions_Check(context);
	end
end

function Golden_Horde_Regions_Check(context)
	local faction_name = context:faction():name();
	local has_regions = Has_Required_Regions(faction_name, REGIONS_GOLDEN_HORDE);
	GOLDEN_HORDE_REGIONS_OWNED = has_regions;
		
	if has_regions == true then
		if cm:is_multiplayer() == true or context:faction():is_human() == false then
			Golden_Horde_Formed(faction_name);
		elseif (not mkHRE or (mkHRE and HasValue(mkHRE.factions, faction_name) ~= true)) then
			Enable_Decision("form_empire_golden_horde");
		end	
	end
end

function Golden_Horde_Formed(faction_name)
	FACTIONS_DFN_LEVEL[faction_name] = 5;
	GOLDEN_HORDE_FACTION = faction_name;
	Rename_Faction(faction_name, faction_name.."_lvl"..tostring(FACTIONS_DFN_LEVEL[faction_name]));

	if cm:is_multiplayer() == false then
		Remove_Decision("form_empire_golden_horde");
	end

	cm:show_message_event(
		faction_name, 
		"message_event_text_text_mk_event_golden_horde_formed_title", 
		"message_event_text_text_mk_event_golden_horde_formed_primary",
		"message_event_text_text_mk_event_golden_horde_formed_secondary",
		true, 
		719
	);

	cm:remove_listener("FactionTurnStart_Golden_Horde_Check");
	cm:remove_listener("SettlementOccupied_Golden_Horde_Regions_Check");
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
