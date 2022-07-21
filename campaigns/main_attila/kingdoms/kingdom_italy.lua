------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - KINGDOM: ITALY
-- 	By: DETrooper
--
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------

ITALIAN_FACTIONS = {
	"mk_fact_bologna",
	"mk_fact_genoa",
	"mk_fact_milan",
	"mk_fact_naples",
	"mk_fact_pisa",
	"mk_fact_savoy",
	"mk_fact_sicily",
	"mk_fact_venice",
	"mk_fact_verona"
};

ITALIAN_KINGDOM_FACTION = "NIL";
ITALIAN_KINGDOM_REGIONS_OWNED = false;

function Add_Kingdom_Italy_Listeners()
	if ITALIAN_KINGDOM_FACTION == "NIL" then
		cm:add_listener(
			"FactionTurnStart_Italy_Check",
			"FactionTurnStart",
			true,
			function(context) Italy_Check(context) end,
			true
		);
		cm:add_listener(
			"SettlementOccupied_Italian_Regions_Check",
			"SettlementOccupied",
			true,
			function(context) Italian_Regions_Check(context) end,
			true
		);
	end

	if cm:is_multiplayer() == false then
		Register_Decision(
			"form_kingdom_italy", 
			function() 	
				local conditionstring = "Conditions:\n\n([[rgba:8:201:27:150]]Y[[/rgba]]) - Is an Italian faction.\n([[rgba:8:201:27:150]]Y[[/rgba:8:201:27:150]]) - The Kingdom of Italy does not yet exist.\n";
				local faction_name = cm:get_local_faction();

				if mkHRE then
					if faction_name == mkHRE.emperor_key then
						conditionstring = conditionstring.."([[rgba:255:0:0:150]]X[[/rgba]]) - Is not the Holy Roman Emperor.\n";
					else
						conditionstring = conditionstring.."([[rgba:8:201:27:150]]Y[[/rgba]]) - Is not the Holy Roman Emperor.\n";
					end
				end
	
				for i = 1, #REGIONS_ITALY do
					local region = cm:model():world():region_manager():region_by_key(REGIONS_ITALY[i]);
					
					if region:owning_faction():name() == cm:get_local_faction() then
						conditionstring = conditionstring.."([[rgba:8:201:27:150]]Y[[/rgba]]) - Own the region of "..REGIONS_NAMES_LOCALISATION[REGIONS_ITALY[i]]..".\n";
					else
						conditionstring = conditionstring.."([[rgba:255:0:0:150]]X[[/rgba]]) - Own the region of "..REGIONS_NAMES_LOCALISATION[REGIONS_ITALY[i]]..".\n";
					end
				end
				
				conditionstring = conditionstring.."\nEffects:\n\n- Become the [[rgba:255:215:0:215]]Kingdom of Italy[[/rgba]].";
			
				return conditionstring;
			end, 
			REGIONS_ITALY, 
			{map_name = "kingdom_italy_map", x = "500", y = "500", map_pips = REGIONS_ITALY_FACTION_PIPS_LOCATIONS},
			Italian_Kingdom_Formed
		);

		if cm:is_new_game() then
			local faction_name = cm:get_local_faction();
			
			if HasValue(ITALIAN_FACTIONS, faction_name) then
				Add_Decision("form_kingdom_italy", faction_name, false, false, true);
			end
		end
	end
end

function Italy_Check(context)
	local faction_name = context:faction():name();

	if HasValue(ITALIAN_FACTIONS, faction_name) then
		Italian_Regions_Check(context);
	end
end

function Italian_Regions_Check(context)
	local faction_name = context:faction():name();
	local has_regions = Has_Required_Regions(faction_name, REGIONS_ITALY);
	ITALIAN_KINGDOM_REGIONS_OWNED = has_regions;
		
	if has_regions == true then
		if cm:is_multiplayer() == true or context:faction():is_human() == false then
			Italian_Kingdom_Formed(faction_name);
		elseif not mkHRE or faction_name ~= mkHRE.emperor_key then
			Enable_Decision("form_kingdom_italy");
		end
	end
end

function Italian_Kingdom_Formed(faction_name)
	FACTIONS_DFN_LEVEL[faction_name] = 4;
	ITALIAN_KINGDOM_FACTION = faction_name;
	Rename_Faction(faction_name, faction_name.."_lvl"..tostring(FACTIONS_DFN_LEVEL[faction_name]));

	if cm:is_multiplayer() == false then
		Remove_Decision("form_kingdom_italy");
		Add_Decision("found_an_empire", faction_name, false, false);
	end

	cm:show_message_event(
		faction_name, 
		"message_event_text_text_mk_event_Italian_kingdom_formed_title", 
		"message_event_text_text_mk_event_Italian_kingdom_formed_primary",
		"message_event_text_text_mk_event_Italian_kingdom_formed_secondary",
		true, 
		721
	);

	cm:remove_listener("FactionTurnStart_Italy_Check");
	cm:remove_listener("SettlementOccupied_Italian_Regions_Check");
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		cm:save_value("ITALIAN_KINGDOM_FACTION", ITALIAN_KINGDOM_FACTION, context);
		cm:save_value("ITALIAN_KINGDOM_REGIONS_OWNED", ITALIAN_KINGDOM_REGIONS_OWNED, context);
	end
);

cm:register_loading_game_callback(
	function(context)
		ITALIAN_KINGDOM_FACTION = cm:load_value("ITALIAN_KINGDOM_FACTION", "NIL", context);
		ITALIAN_KINGDOM_REGIONS_OWNED = cm:load_value("ITALIAN_KINGDOM_REGIONS_OWNED", false, context);
	end
);
