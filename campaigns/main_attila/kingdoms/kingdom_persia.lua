----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - KINGDOM: PERSIAN EMPIRE
-- 	By: DETrooper
--
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------

GHURIDS_KEY = "mk_fact_ghurids";
HAZARASPIDS_KEY = "mk_fact_hazaraspids";
ILDEGIZIDS_KEY = "mk_fact_ildegizids";
SALGHURIDS_KEY = "mk_fact_salghurids";
PERSIAN_EMPIRE_FACTION = "NIL";
PERSIAN_EMPIRE_REGIONS_OWNED = false;

function Add_Kingdom_Persia_Listeners()
	if PERSIAN_EMPIRE_FACTION == "NIL" then
		cm:add_listener(
			"FactionTurnStart_Persian_Empire_Check",
			"FactionTurnStart",
			true,
			function(context) Persian_Empire_Check(context) end,
			true
		);
		cm:add_listener(
			"SettlementOccupied_Persian_Empire_Regions_Check",
			"SettlementOccupied",
			true,
			function(context) Persian_Empire_Regions_Check(context) end,
			true
		);
	end

	if cm:is_multiplayer() == false then
		Register_Decision(
			"form_empire_persia", 
			function() 	
				local conditionstring = "Conditions:\n\n([[rgba:8:201:27:150]]Y[[/rgba]]) - Is the Ghurid Sultanate, Hazaraspid Atabegate, Ildegizid Atabegate, or Salghurid Atabegate.\n([[rgba:8:201:27:150]]Y[[/rgba:8:201:27:150]]) - The Persian Empire does not yet exist.\n";
				local faction_name = cm:get_local_faction();

				if mkHRE and HasValue(mkHRE.factions, faction_name) then
					conditionstring = conditionstring.."([[rgba:255:0:0:150]]X[[/rgba]]) - Is not a member of the Holy Roman Empire.\n";
				else
					conditionstring = conditionstring.."([[rgba:8:201:27:150]]Y[[/rgba]]) - Is not a member of the Holy Roman Empire.\n";
				end
	
				for i = 1, #REGIONS_PERSIA do
					local region = cm:model():world():region_manager():region_by_key(REGIONS_PERSIA[i]);
					
					if region:owning_faction():name() == cm:get_local_faction() then
						conditionstring = conditionstring.."([[rgba:8:201:27:150]]Y[[/rgba]]) - Own the region of "..REGIONS_NAMES_LOCALISATION[REGIONS_PERSIA[i]]..".\n";
					else
						conditionstring = conditionstring.."([[rgba:255:0:0:150]]X[[/rgba]]) - Own the region of "..REGIONS_NAMES_LOCALISATION[REGIONS_PERSIA[i]]..".\n";
					end
				end
			
				conditionstring = conditionstring.."\nEffects:\n\n- Become the [[rgba:255:215:0:215]]Persian Empire[[/rgba]].";
			
				return conditionstring;
			end, 
			REGIONS_PERSIA, 
			{map_name = "kingdom_persia_map", x = "650", y = "650", map_pips = REGIONS_ILKHANATE_PERSIA_FACTION_PIPS_LOCATIONS},
			Persian_Empire_Formed
		);

		if cm:is_new_game() then
			local faction_name = cm:get_local_faction();
			
			if faction_name == GHURIDS_KEY or faction_name == HAZARASPIDS_KEY or faction_name == ILDEGIZIDS_KEY or faction_name == SALGHURIDS_KEY then
				Add_Decision("form_empire_persia", faction_name, false, true);
			end
		end
	end
end

function Persian_Empire_Check(context)
	local faction_name = context:faction():name();
	
	if faction_name == GHURIDS_KEY or faction_name == HAZARASPIDS_KEY or faction_name == ILDEGIZIDS_KEY or faction_name == SALGHURIDS_KEY then
		Persian_Empire_Regions_Check(context);
	end
end

function Persian_Empire_Regions_Check(context)
	local faction_name = context:faction():name();
	local has_regions = Has_Required_Regions(faction_name, REGIONS_PERSIA);
	PERSIAN_EMPIRE_REGIONS_OWNED = has_regions;

	if has_regions == true then
		if cm:is_multiplayer() == true or context:faction():is_human() == false then
			Persian_Empire_Formed(faction_name);
		elseif (not mkHRE or (mkHRE and HasValue(mkHRE.factions, faction_name) ~= true)) then
			Enable_Decision("form_empire_persia");
		end		
	end
end

function Persian_Empire_Formed(faction_name)
	FACTIONS_DFN_LEVEL[faction_name] = 4;
	PERSIAN_EMPIRE_FACTION = faction_name;
	Rename_Faction(faction_name, faction_name.."_lvl"..tostring(FACTIONS_DFN_LEVEL[faction_name]));

	if cm:is_multiplayer() == false then
		Remove_Decision("form_empire_persia");

		if IRONMAN_ENABLED then
			Unlock_Achievement("achievement_king_of_kings");
		end
	end

	cm:show_message_event(
		faction_name, 
		"message_event_text_text_mk_event_persian_empire_formed_title", 
		"message_event_text_text_mk_event_persian_empire_formed_primary",
		"message_event_text_text_mk_event_persian_empire_formed_secondary",
		true, 
		720
	);

	if NICKNAMES then
		Add_Character_Nickname(cm:model():world():faction_by_key(faction_name):faction_leader():cqi(), "the_glorious", false);
	end

	cm:remove_listener("FactionTurnStart_Persian_Empire_Check");
	cm:remove_listener("SettlementOccupied_Persian_Empire_Regions_Check");
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		cm:save_value("PERSIAN_EMPIRE_FACTION", PERSIAN_EMPIRE_FACTION, context);
		cm:save_value("PERSIAN_EMPIRE_REGIONS_OWNED", PERSIAN_EMPIRE_REGIONS_OWNED, context);
	end
);

cm:register_loading_game_callback(
	function(context)
		PERSIAN_EMPIRE_FACTION = cm:load_value("PERSIAN_EMPIRE_FACTION", "NIL", context);
		PERSIAN_EMPIRE_REGIONS_OWNED = cm:load_value("PERSIAN_EMPIRE_REGIONS_OWNED", false, context);
	end
);
