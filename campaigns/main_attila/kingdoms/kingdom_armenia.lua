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


	if cm:is_multiplayer() == false then
		Register_Decision(
			"form_kingdom_armenia", 
			function() 	
				local conditionstring = "Conditions:\n\n([[rgba:8:201:27:150]]Y[[/rgba]]) - Is the Kingdom of Cilicia.\n([[rgba:8:201:27:150]]Y[[/rgba:8:201:27:150]]) - The Kingdom of Armenia does not yet exist.\n";
				local faction_name = cm:get_local_faction();

				if mkHRE then
					if faction_name == mkHRE.emperor_key then
						conditionstring = conditionstring.."([[rgba:255:0:0:150]]X[[/rgba]]) - Is not the Holy Roman Emperor.\n";
					else
						conditionstring = conditionstring.."([[rgba:8:201:27:150]]Y[[/rgba]]) - Is not the Holy Roman Emperor.\n";
					end
				end
	
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
			end, 
			REGIONS_ARMENIA, 
			{map_name = "kingdom_armenia_map", x = "500", y = "500", map_pips = REGIONS_ARMENIA_FACTION_PIPS_LOCATIONS},
			Armenian_Kingdom_Formed
		);

		if cm:is_new_game() then
			local faction_name = cm:get_local_faction();
			
			if faction_name == ARMENIA_KEY then
				Add_Decision("form_kingdom_armenia", faction_name, false, false, true);
			end
		end
	end
end

function Armenia_Check(context)
	local faction_name = context:faction():name();
	
	if faction_name == ARMENIA_KEY then
		Armenian_Regions_Check(context);
	end
end

function Armenian_Regions_Check(context)
	local faction_name = context:faction():name();
	local has_regions = Has_Required_Regions(faction_name, REGIONS_ARMENIA);
	ARMENIAN_KINGDOM_REGIONS_OWNED = has_regions;
		
	if has_regions == true then
		if cm:is_multiplayer() == true or context:faction():is_human() == false then
			Armenian_Kingdom_Formed(faction_name);
		elseif not mkHRE or faction_name ~= mkHRE.emperor_key then
			Enable_Decision("form_kingdom_armenia");
		end
	end
end

function Armenian_Kingdom_Formed(faction_name)
	FACTIONS_DFN_LEVEL[faction_name] = 4;
	ARMENIAN_KINGDOM_FACTION = faction_name;
	Rename_Faction(faction_name, faction_name.."_lvl"..tostring(FACTIONS_DFN_LEVEL[faction_name]));

	if cm:is_multiplayer() == false then
		Remove_Decision("form_kingdom_armenia");
		Add_Decision("found_an_empire", faction_name, false, false);
	end

	cm:show_message_event(
		faction_name, 
		"message_event_text_text_mk_event_armenian_kingdom_formed_title", 
		"message_event_text_text_mk_event_armenian_kingdom_formed_primary",
		"message_event_text_text_mk_event_armenian_kingdom_formed_secondary",
		true, 
		721
	);

	cm:remove_listener("FactionTurnStart_Armenia_Check");
	cm:remove_listener("SettlementOccupied_Armenian_Regions_Check");
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
