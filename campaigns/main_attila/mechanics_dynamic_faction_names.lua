----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: DYNAMIC FACTION NAMES
-- 	By: DETrooper
--
----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------
NUM_REQUIRED_REGIONS_LVL2 = 4;
NUM_REQUIRED_REGIONS_LVL3 = 18;

FACTIONS_DFN_LEVEL = {};

function Add_Dynamic_Faction_Names_Listeners()
	cm:add_listener(
		"FactionTurnStart_DFN_Checks",
		"FactionTurnStart",
		true,
		function(context) FactionTurnStart_DFN_Checks(context) end,
		true
	);
	cm:add_listener(
		"OnComponentLClickUp_DFN_UI",
		"ComponentLClickUp",
		true,
		function(context) OnComponentLClickUp_DFN_UI(context) end,
		true
	);
	cm:add_listener(
		"OnPanelOpenedCampaign_DFN_UI",
		"PanelOpenedCampaign",
		true,
		function(context) OnPanelOpenedCampaign_DFN_UI(context) end,
		true
	);
	cm:add_listener(
		"TimeTrigger_DFN_UI",
		"TimeTrigger",
		true,
		function(context) TimeTrigger_DFN_UI(context) end,
		true
	);

	if cm:is_multiplayer() == false then
		Register_Decision(
			"found_a_kingdom", 
			function() 	
				local faction_name = cm:get_local_faction();
				local num_regions = cm:model():world():faction_by_key(faction_name):region_list():num_items();
				local conditionstring = "Conditions:\n\n";
			
				if mkHRE and faction_name == mkHRE.emperor_key then
					conditionstring = conditionstring.."([[rgba:255:0:0:150]]X[[/rgba]]) - Is not the Holy Roman Emperor.\n";
				else
					conditionstring = conditionstring.."([[rgba:8:201:27:150]]Y[[/rgba]]) - Is not the Holy Roman Emperor.\n";
				end
			
				if num_regions >= NUM_REQUIRED_REGIONS_LVL2 then
					conditionstring = conditionstring.."([[rgba:8:201:27:150]]Y[[/rgba]]) - Control "..tostring(NUM_REQUIRED_REGIONS_LVL2).." regions.\n";
				else
					conditionstring = conditionstring.."([[rgba:255:0:0:150]]X[[/rgba]]) - Control "..tostring(NUM_REQUIRED_REGIONS_LVL2).." regions.\n";
				end
			
				conditionstring = conditionstring.."(Current total: "..tostring(num_regions)..")";
				conditionstring = conditionstring.."\n\nEffects:\n\n- Become the [[rgba:255:215:0:215]]"..DFN_NAMES_LOCALISATION[faction_name.."_lvl2"].."[[\rgba]].";
			
				return conditionstring;	
			end, 
			nil, 
			nil, 
			DFN_Set_Faction_Rank
		);

		Register_Decision(
			"found_an_empire", 
			function() 	
				local faction_name = cm:get_local_faction();
				local num_regions = cm:model():world():faction_by_key(faction_name):region_list():num_items();
				local conditionstring = "Conditions:\n\n";
			
				if mkHRE and HasValue(mkHRE.factions, faction_name) then
					conditionstring = conditionstring.."([[rgba:255:0:0:150]]X[[/rgba]]) - Is not a member of the Holy Roman Empire.\n";
				else
					conditionstring = conditionstring.."([[rgba:8:201:27:150]]Y[[/rgba]]) - Is not a member of the Holy Roman Empire.\n";
				end
				
				if num_regions >= NUM_REQUIRED_REGIONS_LVL3 then
					conditionstring = conditionstring.."([[rgba:8:201:27:150]]Y[[/rgba]]) - Control "..tostring(NUM_REQUIRED_REGIONS_LVL3).." regions.\n";
				else
					conditionstring = conditionstring.."([[rgba:255:0:0:150]]X[[/rgba]]) - Control "..tostring(NUM_REQUIRED_REGIONS_LVL3).." regions.\n";
				end
			
				conditionstring = conditionstring.."(Current total: "..tostring(num_regions)..")";
			
				if FACTIONS_DFN_LEVEL[faction_name] == 4 then
					conditionstring = conditionstring.."\n\nEffects:\n\n- Become the [[rgba:255:215:0:215]]"..DFN_NAMES_LOCALISATION[faction_name.."_lvl5"].."[[\rgba]].";
				else
					conditionstring = conditionstring.."\n\nEffects:\n\n- Become the [[rgba:255:215:0:215]]"..DFN_NAMES_LOCALISATION[faction_name.."_lvl3"].."[[\rgba]].";
				end
			
				return conditionstring;	
			end, 
			nil, 
			nil, 
			DFN_Set_Faction_Rank
		);
	end

	if cm:is_new_game() then
		for i = 1, #FACTIONS_DFN_EMPIRES do
			FACTIONS_DFN_LEVEL[FACTIONS_DFN_EMPIRES[i]] = 3;
		end

		for i = 1, #FACTIONS_DFN_KINGDOMS do
			FACTIONS_DFN_LEVEL[FACTIONS_DFN_KINGDOMS[i]] = 2;
		end

		for i = 1, #DYNAMIC_FACTION_NAMES_FACTIONS do
			local faction_name = DYNAMIC_FACTION_NAMES_FACTIONS[i];
			local faction = cm:model():world():faction_by_key(faction_name);

			if faction:is_null_interface() == false then
				if FACTIONS_DFN_LEVEL[faction_name] == nil then
					FACTIONS_DFN_LEVEL[faction_name] = 1;
				end

				if cm:is_multiplayer() == false and faction:is_human() then
					if not HasValue(FACTIONS_DFN_KINGDOMS_EVENTS, faction_name) and FACTIONS_DFN_LEVEL[faction_name] < 2 then
						Add_Decision("found_a_kingdom", faction_name, false, false);
					end

					if not HasValue(FACTIONS_DFN_EMPIRES_EVENTS, faction_name) and FACTIONS_DFN_LEVEL[faction_name] < 3 then
						Add_Decision("found_an_empire", faction_name, false, false);
					end
				end
			end
		end
	end

	Global_DFN_Check();
end

function FactionTurnStart_DFN_Checks(context)
	local faction_name = context:faction():name();

	if context:faction():is_human() then
		Global_DFN_Check();
	end
end

function Global_DFN_Check()
	for i = 1, #DYNAMIC_FACTION_NAMES_FACTIONS do
		local faction_name = DYNAMIC_FACTION_NAMES_FACTIONS[i];
		local faction = cm:model():world():faction_by_key(faction_name);

		if not faction:is_null_interface() then
			if not FACTIONS_DFN_LEVEL[faction_name] then
				FACTIONS_DFN_LEVEL[faction_name] = 1;
			end

			if FactionIsAlive(faction_name) then
				if FACTIONS_DFN_LEVEL[faction_name] == 1 then
					if not HasValue(FACTIONS_DFN_KINGDOMS_EVENTS, faction_name) then
						if faction:region_list():num_items() >= NUM_REQUIRED_REGIONS_LVL2 and (not mkHRE or faction_name ~= mkHRE.emperor_key) then
							if faction:is_human() == false or cm:is_multiplayer() == true then
								DFN_Set_Faction_Rank(faction_name, 2);
							else
								Enable_Decision("found_a_kingdom");
							end
						else
							if faction:is_human() == true and cm:is_multiplayer() == false then
								Disable_Decision("found_a_kingdom");
							end
						end
					end
				elseif FACTIONS_DFN_LEVEL[faction_name] == 2 then
					if not HasValue(FACTIONS_DFN_EMPIRES_EVENTS, faction_name) then
						if faction:region_list():num_items() >= NUM_REQUIRED_REGIONS_LVL3 and (not mkHRE or (mkHRE and not HasValue(mkHRE.factions, faction_name))) then
							if faction:is_human() == false or cm:is_multiplayer() == true then
								DFN_Set_Faction_Rank(faction_name, 3);
							else
								Enable_Decision("found_an_empire");
							end
						else
							if faction:is_human() == true and cm:is_multiplayer() == false then
								Disable_Decision("found_an_empire");
							end
						end
					end
				elseif FACTIONS_DFN_LEVEL[faction_name] == 4 then -- For Kingdom events.
					if faction:region_list():num_items() >= NUM_REQUIRED_REGIONS_LVL3 and (not mkHRE or (mkHRE and not HasValue(mkHRE.factions, faction_name))) then
						if faction:is_human() == false or cm:is_multiplayer() == true then
							DFN_Set_Faction_Rank(faction_name, 5);
						else
							Enable_Decision("found_an_empire");
						end
					else
						if faction:is_human() == true and cm:is_multiplayer() == false then
							Disable_Decision("found_an_empire");
						end
					end
				end
			end
		end
	end
end

function OnComponentLClickUp_DFN_UI(context)
	if context.string == "Summary" or context.string == "Records" then
		cm:add_time_trigger("Faction_Panel_DFN", 0.0);
	end
end

function OnPanelOpenedCampaign_DFN_UI(context)
	if context.string == "clan" then
		cm:add_time_trigger("Faction_Panel_DFN", 0.0);
	end
end

function Get_DFN_Localisation(faction_name)
	local faction_string = FACTIONS_NAMES_LOCALISATION[faction_name] or "Unknown";

	if FACTIONS_DFN_LEVEL[faction_name] and FACTIONS_DFN_LEVEL[faction_name] > 1 then
		local dfn_string = faction_name.."_lvl"..tostring(FACTIONS_DFN_LEVEL[faction_name]);
		
		faction_string = DFN_NAMES_LOCALISATION[dfn_string];
	end

	if mkHRE then
		if faction_name == mkHRE.emperor_key then
			faction_string = FACTIONS_NAMES_LOCALISATION["mk_fact_hre"];
		elseif faction_name == "mk_fact_hre" then
			faction_string = DFN_NAMES_LOCALISATION["mk_fact_hre_non_emperor"];
		end
	end

	return faction_string;
end

function DFN_Set_Faction_Rank(faction_name, set_rank)
	local rank = set_rank;

	if not rank then
		if FACTIONS_DFN_LEVEL[faction_name] then
			rank = FACTIONS_DFN_LEVEL[faction_name] + 1;
		else
			rank = 2;
		end
	end

	if rank == 3 and FACTIONS_DFN_LEVEL[faction_name] == 4 then
		rank = 5;
	end

	if cm:is_multiplayer() == false then
		if rank == 2 or rank == 4 then
			Remove_Decision("found_a_kingdom");
		elseif rank == 3 or rank == 5 then
			Remove_Decision("found_an_empire");
		end
	end

	local newname = faction_name.."_lvl"..tostring(rank);
	Rename_Faction(faction_name, newname);
	FACTIONS_DFN_LEVEL[faction_name] = rank;

	if cm:model():world():faction_by_key(faction_name):is_human() == true then
		cm:show_message_event(
			faction_name, 
			"message_event_text_text_mk_event_faction_rank_title_"..tostring(rank),
			"campaign_localised_strings_string_"..faction_name.."_lvl"..tostring(rank),
			"message_event_text_text_mk_event_faction_rank_secondary_"..tostring(rank),
			true, 
			704
		);
	end
end

function DFN_Disable_Forming_Kingdoms(faction_name)
	if cm:is_multiplayer() == false then
		local faction = cm:model():world():faction_by_key(faction_name);

		if faction:is_human() then
			Remove_Decision("found_a_kingdom");
			Remove_Decision("found_an_empire");
		end
	end
end

function DFN_Enable_Forming_Kingdoms(faction_name)
	if cm:is_multiplayer() == false then
		local faction = cm:model():world():faction_by_key(faction_name);

		if not FACTIONS_DFN_LEVEL[faction_name] then
			FACTIONS_DFN_LEVEL[faction_name] = 1;
		end

		if HasValue(DYNAMIC_FACTION_NAMES_FACTIONS, faction_name) then
			if faction:is_human() then
				if not HasValue(FACTIONS_DFN_KINGDOMS_EVENTS, faction_name) and FACTIONS_DFN_LEVEL[faction_name] < 2 then
					Add_Decision("found_a_kingdom", faction_name, false, false);
				end

				if not HasValue(FACTIONS_DFN_EMPIRES_EVENTS, faction_name) and FACTIONS_DFN_LEVEL[faction_name] < 3 then
					Add_Decision("found_an_empire", faction_name, false, false);
				end
			end
		end
	end
end

function DFN_Refresh_Faction_Name(faction_name)
	local rank = FACTIONS_DFN_LEVEL[faction_name];
	local newname = faction_name.."_lvl"..tostring(rank);

	if mkHRE then
		if faction_name == mkHRE.emperor_key then
			newname = "mk_fact_hre_lvl3";
		else
			if faction_name == "mk_fact_hre" then
				newname = "mk_fact_hre_non_emperor";
			end
		end
	end

	Rename_Faction(faction_name, newname);
end

function TimeTrigger_DFN_UI(context)
	if context.string == "Faction_Panel_DFN" then
		local root = cm:ui_root();
		local faction_name = cm:get_local_faction();
		local tab_records_uic = UIComponent(root:Find("Records"));
		local tab_summary_uic = UIComponent(root:Find("Summary"));
		local tx_prosperity_uic = UIComponent(tab_records_uic:Find("tx_prosperity"));
		local dy_prosperity_uic = UIComponent(tx_prosperity_uic:Find("dy_prosperity"));
		local tx_provinces_owned_uic = UIComponent(tab_summary_uic:Find("tx_provinces_owned"));
		local dy_provinces_owned_uic = UIComponent(tx_provinces_owned_uic:Find("dy_provinces_owned"));

		tx_provinces_owned_uic:SetStateText(UI_LOCALISATION["dfn_faction_rank"]);
		tx_prosperity_uic:SetStateText(UI_LOCALISATION["dfn_faction_rank"]);

		if FACTIONS_DFN_LEVEL[faction_name]  then
			if FACTIONS_DFN_LEVEL[faction_name] == 1 then
				dy_prosperity_uic:SetStateText(UI_LOCALISATION["dfn_county"]);
				dy_provinces_owned_uic:SetStateText(UI_LOCALISATION["dfn_county"]);
			elseif FACTIONS_DFN_LEVEL[faction_name] == 2 then
				dy_prosperity_uic:SetStateText(UI_LOCALISATION["dfn_kingdom"]);
				dy_provinces_owned_uic:SetStateText(UI_LOCALISATION["dfn_kingdom"]);
			elseif FACTIONS_DFN_LEVEL[faction_name] >= 3 then
				dy_prosperity_uic:SetStateText(UI_LOCALISATION["dfn_empire"]);
				dy_provinces_owned_uic:SetStateText(UI_LOCALISATION["dfn_empire"]);
			end
		end
	end
end

------------------------------------------------
---------------- Saving/Loading ----------------
------------------------------------------------
cm:register_loading_game_callback(
	function(context)
		if not cm:is_new_game() then
			FACTIONS_DFN_LEVEL = LoadKeyPairTableNumbers(context, "FACTIONS_DFN_LEVEL");
		end
	end
);

cm:register_saving_game_callback(
	function(context)
		SaveKeyPairTable(context, FACTIONS_DFN_LEVEL, "FACTIONS_DFN_LEVEL");
	end
);