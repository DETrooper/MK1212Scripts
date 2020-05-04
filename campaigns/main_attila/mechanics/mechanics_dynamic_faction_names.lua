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

			if FACTIONS_DFN_LEVEL[faction_name] == nil then
				FACTIONS_DFN_LEVEL[faction_name] = 1;
			end

			if faction:is_human() then
				if FACTIONS_DFN_LEVEL[faction_name] < 2 then
					Add_Decision("found_a_kingdom", faction_name, false, false);
				end

				if FACTIONS_DFN_LEVEL[faction_name] < 3 then
					Add_Decision("found_an_empire", faction_name, false, false);
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

		if FACTIONS_DFN_LEVEL[faction_name] == nil then
			FACTIONS_DFN_LEVEL[faction_name] = 1;
		end

		if FACTIONS_DFN_LEVEL[faction_name] == 1 then
			if faction:region_list():num_items() >= NUM_REQUIRED_REGIONS_LVL2 and faction:region_list():num_items() < NUM_REQUIRED_REGIONS_LVL3 and faction_name ~= HRE_EMPEROR_KEY then
				if faction:is_human() == false or cm:is_multiplayer() == true then
					DFN_Set_Faction_Rank(faction_name, 2);
				else
					Enable_Decision("found_a_kingdom");
				end
			end
		elseif FACTIONS_DFN_LEVEL[faction_name] == 2 then
			if faction:region_list():num_items() >= NUM_REQUIRED_REGIONS_LVL3 and HasValue(HRE_FACTIONS, faction_name) ~= true then
				if faction:is_human() == false or cm:is_multiplayer() == true then
					DFN_Set_Faction_Rank(faction_name, 3);
				else
					Enable_Decision("found_an_empire");
				end
			else
				if faction:is_human() == true or cm:is_multiplayer() == false then
					Disable_Decision("found_an_empire");
				end
			end
		-- For Kingdom events.
		elseif FACTIONS_DFN_LEVEL[faction_name] == 4 then
			if faction:region_list():num_items() >= NUM_REQUIRED_REGIONS_LVL3 and HasValue(HRE_FACTIONS, faction_name) ~= true then
				if faction:is_human() == false or cm:is_multiplayer() == true then
					DFN_Set_Faction_Rank(faction_name, 5);
				else
					Enable_Decision("found_an_empire");
				end
			else
				if faction:is_human() == true or cm:is_multiplayer() == false then
					Disable_Decision("found_an_empire");
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
	local faction_string = FACTIONS_NAMES_LOCALISATION[faction_name];

	if FACTIONS_DFN_LEVEL[faction_name] ~= nil and FACTIONS_DFN_LEVEL[faction_name] > 1 then
		local dfn_string = faction_name.."_lvl"..tostring(FACTIONS_DFN_LEVEL[faction_name]);
		faction_string = DFN_NAMES_LOCALISATION[dfn_string];
	else
		faction_string = FACTIONS_NAMES_LOCALISATION[faction_name];
	end

	if faction_name == HRE_EMPEROR_KEY then
		faction_string = FACTIONS_NAMES_LOCALISATION["mk_fact_hre"];
	elseif faction_name == "mk_fact_hre" then
		faction_string = "Kingdom of Germany";
	end

	return faction_string;
end

function DFN_Set_Faction_Rank(faction_name, rank)
	if rank == 3 and FACTIONS_DFN_LEVEL[faction_name] == 4 then
		rank = 5;
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

		if FACTIONS_DFN_LEVEL[faction_name] == nil then
			FACTIONS_DFN_LEVEL[faction_name] = 1;
		end

		if faction:is_human() then
			if FACTIONS_DFN_LEVEL[faction_name] < 2 then
				Add_Decision("found_a_kingdom", faction_name, false, false);
			end

			if FACTIONS_DFN_LEVEL[faction_name] < 3 then
				Add_Decision("found_an_empire", faction_name, false, false);
			end
		end
	end
end

function DFN_Refresh_Faction_Name(faction_name)
	local rank = FACTIONS_DFN_LEVEL[faction_name];
	local newname = faction_name.."_lvl"..tostring(rank);

	if faction_name == HRE_EMPEROR_KEY then
		newname = "mk_fact_hre_lvl3";
	else
		if faction_name == "mk_fact_hre" then
			newname = "mk_fact_hre_non_emperor";
		end
	end

	Rename_Faction(faction_name, newname);
end

function GetConditionsString_DFN_Kingdom()
	local faction_name = cm:get_local_faction();
	local num_regions = cm:model():world():faction_by_key(faction_name):region_list():num_items();
	local conditionstring = "Conditions:\n\n";

	if faction_name == HRE_EMPEROR_KEY then
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
end

function GetConditionsString_DFN_Empire()
	local faction_name = cm:get_local_faction();
	local num_regions = cm:model():world():faction_by_key(faction_name):region_list():num_items();
	local conditionstring = "Conditions:\n\n";

	if HasValue(HRE_FACTIONS, faction_name) then
		conditionstring = conditionstring.."([[rgba:255:0:0:150]]X[[/rgba]]) - Is not a member of the Holy Roman Empire.\n";
	else
		conditionstring = conditionstring.."([[rgba:8:201:27:150]]Y[[/rgba]]) - Is not a member of the Holy Roman Empire.\n";
	end
	
	if num_regions >= NUM_REQUIRED_REGIONS_LVL3 then
		conditionstring = conditionstring.."([[rgba:8:201:27:150]]Y[[/rgba]]) - Control "..tostring(NUM_REQUIRED_REGIONS_LVL3).." regions\n.";
	else
		conditionstring = conditionstring.."([[rgba:255:0:0:150]]X[[/rgba]]) - Control "..tostring(NUM_REQUIRED_REGIONS_LVL3).." regions.\n";
	end

	conditionstring = conditionstring.."(Current total: "..tostring(num_regions)..")";
	conditionstring = conditionstring.."\n\nEffects:\n\n- Become the [[rgba:255:215:0:215]]"..DFN_NAMES_LOCALISATION[faction_name.."_lvl3"].."[[\rgba]].";

	if FACTIONS_DFN_LEVEL[faction_name] == 4 then
		conditionstring = conditionstring.."\n\nEffects:\n\n- Become the [[rgba:255:215:0:215]]"..DFN_NAMES_LOCALISATION[faction_name.."_lvl5"].."[[\rgba]].";
	end

	return conditionstring;	
end

function TimeTrigger_DFN_UI(context)
	if context.string == "Faction_Panel_DFN" then
		local root = cm:ui_root();
		local faction_name = cm:get_local_faction();
		local tab_records_uic = UIComponent(root:Find("Records"));
		local tx_provinces_owned_uic = UIComponent(tab_records_uic:Find("tx_provinces_owned"));
		local tx_regions_owned_uic = UIComponent(tab_records_uic:Find("tx_regions_owned"));
		local dy_regions_owned_uic = UIComponent(tx_regions_owned_uic:Find("dy_regions_owned"));

		tx_provinces_owned_uic:SetStateText("Regions owned:");
		tx_regions_owned_uic:SetStateText("Faction rank:");

		if FACTIONS_DFN_LEVEL[faction_name] ~= nil then
			if FACTIONS_DFN_LEVEL[faction_name] == 1 then
				dy_regions_owned_uic:SetStateText("County/Duchy");
			elseif FACTIONS_DFN_LEVEL[faction_name] == 2 then
				dy_regions_owned_uic:SetStateText("Kingdom");
			elseif FACTIONS_DFN_LEVEL[faction_name] >= 3 then
				dy_regions_owned_uic:SetStateText("Empire");
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
