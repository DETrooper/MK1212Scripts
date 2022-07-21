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

	if cm:is_multiplayer() == false then
		Register_Decision(
			"form_empire_ilkhanate", 
			function() 	
				local conditionstring = "Conditions:\n\n([[rgba:8:201:27:150]]Y[[/rgba]]) - Is the Ulus of Tolui.\n([[rgba:8:201:27:150]]Y[[/rgba:8:201:27:150]]) - The Ilkhanate does not yet exist.\n";
				local faction_name = cm:get_local_faction();

				if mkHRE and HasValue(mkHRE.factions, faction_name) then
					conditionstring = conditionstring.."([[rgba:255:0:0:150]]X[[/rgba]]) - Is not a member of the Holy Roman Empire.\n";
				else
					conditionstring = conditionstring.."([[rgba:8:201:27:150]]Y[[/rgba]]) - Is not a member of the Holy Roman Empire.\n";
				end
	
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
			end, 
			REGIONS_ILKHANATE, 
			{map_name = "kingdom_ilkhanate_map", x = "650", y = "650", map_pips = REGIONS_ILKHANATE_PERSIA_FACTION_PIPS_LOCATIONS},
			Ilkhanate_Formed
		);

		if cm:is_new_game() then
			local faction_name = cm:get_local_faction();
			
			if faction_name == TOLUI_KEY then
				Add_Decision("form_empire_ilkhanate", faction_name, false, true);
			end
		end
	end
end

function Ilkhanate_Check(context)
	local faction_name = context:faction():name();
	
	if faction_name == TOLUI_KEY then
		Ilkhanate_Regions_Check(context);
	end
end

function Ilkhanate_Regions_Check(context)
	local faction_name = context:faction():name();
	local has_regions = Has_Required_Regions(faction_name, REGIONS_ILKHANATE);
	ILKHANATE_REGIONS_OWNED = has_regions;

	if has_regions == true then
		if cm:is_multiplayer() == true or context:faction():is_human() == false then
			Ilkhanate_Formed(faction_name);
		elseif (not mkHRE or (mkHRE and HasValue(mkHRE.factions, faction_name) ~= true)) then
			Enable_Decision("form_empire_ilkhanate");
		end		
	end
end

function Ilkhanate_Formed(faction_name)
	FACTIONS_DFN_LEVEL[faction_name] = 5;
	ILKHANATE_FACTION = faction_name;
	Rename_Faction(faction_name, faction_name.."_lvl"..tostring(FACTIONS_DFN_LEVEL[faction_name]));

	if cm:is_multiplayer() == false then
		Remove_Decision("form_empire_ilkhanate");
	end

	cm:show_message_event(
		faction_name, 
		"message_event_text_text_mk_event_ilkhanate_formed_title", 
		"message_event_text_text_mk_event_ilkhanate_formed_primary",
		"message_event_text_text_mk_event_ilkhanate_formed_secondary",
		true, 
		720
	);

	cm:remove_listener("FactionTurnStart_Ilkhanate_Check");
	cm:remove_listener("SettlementOccupied_Ilkhanate_Regions_Check");
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
