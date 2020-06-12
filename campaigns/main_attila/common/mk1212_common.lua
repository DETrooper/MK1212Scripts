-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - COMMON FUNCTIONS & STUFF
-- 	By: DETrooper
--
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------

local dev = require("lua_scripts.dev");

FACTION_TURN = "nil";
SACKED_SETTLEMENTS = {};
SACKED_SETTLEMENTS2 = {};
HUMAN_FACTIONS = {};
ARMY_SELECTED = false;
ARMY_SELECTED_REGION = nil;
ARMY_SELECTED_TABLE = {};
ARMY_SELECTED_STRENGTHS_TABLE = {};
REGION_SELECTED = "";
LAST_CHARACTER_SELECTED = nil;
LAST_CHARACTER_SELECTED_FACTION = nil;
LAST_SACKED_SETTLEMENT = "";

function Add_MK1212_Common_Listeners()
	cm:add_listener(
		"FactionTurnStart_Global",
		"FactionTurnStart",
		true,
		function(context) FactionTurnStart_Global(context) end,
		true
	);
	cm:add_listener(
		"CharacterSelected_Global",
		"CharacterSelected",
		true,
		function(context) CharacterSelected_Global(context) end,
		true
	);
	cm:add_listener(
		"SettlementSelected_Global",
		"SettlementSelected",
		true,
		function(context) OnSettlementSelected_Global(context) end,
		true
	);

	if cm:is_new_game() then
		FACTION_TURN = cm:model():world():faction_list():item_at(0):name();
	end

	local faction_list = cm:model():world():faction_list();

	for i = 0, faction_list:num_items() - 1 do
		if faction_list:item_at(i):is_human() then
			table.insert(HUMAN_FACTIONS, faction_list:item_at(i):command_queue_index()); 
		end
	end
end

function FactionTurnStart_Global(context)
	FACTION_TURN = context:faction():name();
	SACKED_SETTLEMENTS = {} -- Array is reset every faction turn.
end

function CharacterSelected_Global(context)
	LAST_CHARACTER_SELECTED = context:character();
	LAST_CHARACTER_SELECTED_FACTION = context:character():faction();

	Check_Last_Character_Force();
end

function OnSettlementSelected_Global(context)
	local region_name = context:garrison_residence():region():name();
	REGION_SELECTED = region_name;
end

function Check_Last_Character_Force()
	ARMY_SELECTED_TABLE = {};
	ARMY_SELECTED_STRENGTHS_TABLE = {};

	if LAST_CHARACTER_SELECTED:has_region() then
		ARMY_SELECTED_REGION = LAST_CHARACTER_SELECTED:region():name();
	else
		local region = FindClosestRegion(LAST_CHARACTER_SELECTED:logical_position_x(), LAST_CHARACTER_SELECTED:logical_position_y(), "none");
		ARMY_SELECTED_REGION = region:name();
	end

	if LAST_CHARACTER_SELECTED:has_military_force() then
		for i = 0, LAST_CHARACTER_SELECTED:military_force():unit_list():num_items() - 1 do
			table.insert(ARMY_SELECTED_TABLE, LAST_CHARACTER_SELECTED:military_force():unit_list():item_at(i):unit_key());
			table.insert(ARMY_SELECTED_STRENGTHS_TABLE, LAST_CHARACTER_SELECTED:military_force():unit_list():item_at(i):percentage_proportion_of_full_strength());
		end
	end
end

function FactionIsAlive(faction_name)
	local faction = cm:model():world():faction_by_key(faction_name);

	if faction:has_home_region() or faction:military_force_list():num_items() > 0 then
		return true;
	end

	return false;
end

function FindClosestRegion(x, y, faction)
	local region_name = "";
	local distance = 10000; 

	if faction == "none" then
		local region_list = cm:model():world():region_manager():region_list();

		for i = 0, region_list:num_items() - 1 do
			local region = region_list:item_at(i);
			local regionX = region:settlement():logical_position_x();
			local regionY = region:settlement():logical_position_y();
			local newDistance = ((x - regionX) ^ 2 + (y - regionY) ^ 2) ^ 0.5;

			if newDistance ~= 0 and newDistance < distance then
				distance = newDistance;
				region_name = region:name();
			end
		end
	else
		for i = 0, faction:region_list():num_items() - 1 do
			local region = faction:region_list():item_at(i);
			local regionX = region:settlement():logical_position_x();
			local regionY = region:settlement():logical_position_y();
			local newDistance = ((x - regionX) ^ 2 + (y - regionY) ^ 2) ^ 0.5;

			if newDistance ~= 0 and newDistance < distance then
				distance = newDistance;
				region_name = region:name();
			end
		end
	end

	if region_name == "" then 
		region_name = faction:home_region():name();
	end

	local region = cm:model():world():region_manager():region_by_key(region_name);
	return region;
end

function FindClosestPort(x, y, faction)
	local region_name = "";
	local distance = 10000;
 
	if faction == "none" then
		local region_list = cm:model():world():region_manager():region_list();

		for i = 0, region_list:num_items() - 1 do
			local region = region_list:item_at(i);

			if region:slot_type_exists("port") then
				local portX = region:settlement():logical_position_x();
				local portY = region:settlement():logical_position_y();
				local newDistance = ((x - portX) ^ 2 + (y - portY) ^ 2) ^ 0.5;

				if newDistance ~= 0 and newDistance < distance then
					distance = newDistance;
					region_name = region:name();
				end
			end
		end
	else
		for i = 0, faction:region_list():num_items() - 1 do
			local region = faction:region_list():item_at(i);

			if region:slot_type_exists("port") then
				local portX = region:settlement():logical_position_x();
				local portY = region:settlement():logical_position_y();
				local newDistance = ((x - portX) ^ 2 + (y - portY) ^ 2) ^ 0.5;

				if newDistance ~= 0 and newDistance < distance then
					distance = newDistance;
					region_name = region:name();
				end
			end
		end
	end

	if region_name == "" then 
		region_name = faction:home_region():name();
	end

	local region = cm:model():world():region_manager():region_by_key(region_name);
	return region;
end

function SpawnValidSettlement(region_name)
	local region = cm:model():world():region_manager():region_by_key(region_name);
	local owner = region:owning_faction();
	local military_force_list = owner:military_force_list();

	for i = 0, military_force_list:num_items() - 1 do
		local current_military_force = military_force_list:item_at(i);
		
		if current_military_force:upkeep() > 0 and current_military_force:has_garrison_residence() and current_military_force:garrison_residence():region():name() == region_name then
			return false;
		end
	end

	return true;
end

function GetTurnFromYear(year)
	-- 2TPY, so turn 2 of the year should have .5 added to it.
	local turn_number = (year - 1212) * 2 + 1;

	return turn_number;
end

function Transfer_Region_To_Faction(region_name, faction_name)
	-- If a region has a governor then they will die when a region is transferred, so we need to temporarily give them immortality.

	if cm:model():world():region_manager():region_by_key(region_name):has_governor() then
		local governor = cm:model():world():region_manager():region_by_key(region_name):governor():command_queue_index();
		cm:set_character_immortality("character_cqi:"..governor, true);
		cm:transfer_region_to_faction(region_name, faction_name);
		cm:set_character_immortality("character_cqi:"..governor, false);
	else
		cm:transfer_region_to_faction(region_name, faction_name);
	end
end

-- From AoC Kingdoms.

function Rename_Faction(faction_name, rename_key)
	cm:set_faction_name_override(faction_name, "campaign_localised_strings_string_"..rename_key);
end

function Has_Required_Regions(faction_name, region_list)
	for i = 1, #region_list do
		local region = cm:model():world():region_manager():region_by_key(region_list[i]);
		
		if region:owning_faction():name() ~= faction_name then
			return false;
		end
	end
	
	return true;
end

-- From War Weariness.

function Does_Faction_Border_Faction(faction_name, query_faction_name)
	local faction = cm:model():world():faction_by_key(faction_name);	
	local regions = faction:region_list();
	
	for i = 0, regions:num_items() - 1 do
		local region = regions:item_at(i);
		local border_regions = region:adjacent_region_list();
		
		for j = 0, border_regions:num_items() - 1 do
			local border_region = border_regions:item_at(j);
			
			if border_region:owning_faction():is_null_interface() == false then
				if border_region:owning_faction():name() == query_faction_name then
					return true;
				end
			end
		end
	end
	return false;
end

-- Some cool functions from Thrones of Britannia.

----------------------
-- SackExploitCheck --
----------------------

-- Checks to see if a player is sacking the same settlement over and over.

function SackExploitCheck_Pope(region_key)
	if SACKED_SETTLEMENTS[region_key] == "sacked" then
		return false
	else
		LAST_SACKED_SETTLEMENT = region_key;
		SACKED_SETTLEMENTS[LAST_SACKED_SETTLEMENT] = "sacked";
		LAST_SACKED_SETTLEMENT = "";
		return true
	end
end

function SackExploitCheck_Population(region_key)
	if SACKED_SETTLEMENTS2[region_key] == "sacked" then
		return false
	else
		LAST_SACKED_SETTLEMENT = region_key;
		SACKED_SETTLEMENTS2[LAST_SACKED_SETTLEMENT] = "sacked";
		LAST_SACKED_SETTLEMENT = "";
		return true
	end
end


------------------------
-- SetFactionsHostile --
------------------------

-- Sets the CAI strategic stances between two factions to be hostile. Also clears previous promoted/blocked stances.

function SetFactionsHostile(faction1, faction2)
	cm:cai_strategic_stance_manager_clear_all_promotions_between_factions(faction1, faction2);
	cm:cai_strategic_stance_manager_clear_all_blocking_between_factions(faction1, faction2);
	cm:cai_strategic_stance_manager_clear_all_promotions_between_factions(faction2, faction1);
	cm:cai_strategic_stance_manager_clear_all_blocking_between_factions(faction2, faction1);
	cm:cai_strategic_stance_manager_promote_specified_stance_towards_target_faction(faction1, faction2, "CAI_STRATEGIC_STANCE_BITTER_ENEMIES");
	cm:cai_strategic_stance_manager_block_all_stances_but_that_specified_towards_target_faction(faction1, faction2, "CAI_STRATEGIC_STANCE_BITTER_ENEMIES"); 
	cm:cai_strategic_stance_manager_promote_specified_stance_towards_target_faction(faction2, faction1, "CAI_STRATEGIC_STANCE_BITTER_ENEMIES");
	cm:cai_strategic_stance_manager_block_all_stances_but_that_specified_towards_target_faction(faction2, faction1, "CAI_STRATEGIC_STANCE_BITTER_ENEMIES"); 
end

------------------------
-- SetFactionsNeutral --
------------------------

-- Clears any CAI strategic stance settings between the two specified factions

function SetFactionsNeutral(faction1, faction2)
	cm:cai_strategic_stance_manager_clear_all_promotions_between_factions(faction1, faction2);
	cm:cai_strategic_stance_manager_clear_all_blocking_between_factions(faction1, faction2);
	cm:cai_strategic_stance_manager_clear_all_promotions_between_factions(faction2, faction1);
	cm:cai_strategic_stance_manager_clear_all_blocking_between_factions(faction2, faction1);
end

-------------------------
-- SetFactionsFriendly --
-------------------------

-- Sets the CAI strategic stances between two factions to be friendly. Also clears previous promoted/blocked stances.

function SetFactionsFriendly(faction1, faction2)
	cm:cai_strategic_stance_manager_clear_all_promotions_between_factions(faction1, faction2);
	cm:cai_strategic_stance_manager_clear_all_blocking_between_factions(faction1, faction2);
	cm:cai_strategic_stance_manager_clear_all_promotions_between_factions(faction2, faction1);
	cm:cai_strategic_stance_manager_clear_all_blocking_between_factions(faction2, faction1);
	cm:cai_strategic_stance_manager_promote_specified_stance_towards_target_faction(faction1, faction2, "CAI_STRATEGIC_STANCE_BEST_FRIENDS");
	cm:cai_strategic_stance_manager_block_all_stances_but_that_specified_towards_target_faction(faction1, faction2, "CAI_STRATEGIC_STANCE_BEST_FRIENDS"); 
	cm:cai_strategic_stance_manager_promote_specified_stance_towards_target_faction(faction2, faction1, "CAI_STRATEGIC_STANCE_BEST_FRIENDS");
	cm:cai_strategic_stance_manager_block_all_stances_but_that_specified_towards_target_faction(faction2, faction1, "CAI_STRATEGIC_STANCE_BEST_FRIENDS");
end

------------------------------------------------
---------------- Saving/Loading ----------------
------------------------------------------------

cm:register_loading_game_callback(
	function(context)
		FACTION_TURN = cm:load_value("FACTION_TURN", "nil", context);
		SACKED_SETTLEMENTS = LoadTable(context, "SACKED_SETTLEMENTS");
		SACKED_SETTLEMENTS2 = LoadTable(context, "SACKED_SETTLEMENTS2");
	end
);

cm:register_saving_game_callback(
	function(context)
		cm:save_value("FACTION_TURN", FACTION_TURN, context);
		SaveTable(context, SACKED_SETTLEMENTS, "SACKED_SETTLEMENTS");
		SaveTable(context, SACKED_SETTLEMENTS2, "SACKED_SETTLEMENTS2");

	end
);

------------------------------------------------
---------------- Table Stuff ----------------
------------------------------------------------

function SaveTable(context, tab, savename)
	local savestring = "";
	
	for i = 1, #tab do
		savestring = savestring..tab[i]..",";
	end
		
	cm:save_value(savename, savestring, context);
end

function LoadTable(context, savename)
	local savestring = cm:load_value(savename, "", context);
	local tab = {};
	
	if savestring ~= "" then
		local first_split = SplitString(savestring, ",");
		for i = 1, #first_split do
			table.insert(tab, first_split[i]);
		end
	end

	return tab;
end

function LoadTableNumbers(context, savename)
	local savestring = cm:load_value(savename, "", context);
	local tab = {};
	
	if savestring ~= "" then
		local first_split = SplitString(savestring, ",");
		for i = 1, #first_split do
			table.insert(tab, tonumber(first_split[i]));
		end
	end

	return tab;
end

function SaveKeyPairTable(context, tab, savename)
	local savestring = "";
	
	for key,value in pairs(tab) do
		savestring = savestring..key..","..value..",;";
	end

	cm:save_value(savename, savestring, context);
end

function SaveBooleanPairTable(context, tab, savename)
	local savestring = "";
	
	for key,value in pairs(tab) do
		savestring = savestring..key..","..tostring(value)..",;";
	end

	cm:save_value(savename, savestring, context);
end

function SaveKeyPairTables(context, tab, savename)
	local savestring = "";
	
	for key, value in pairs(tab) do
		savestring = savestring..key..",";

		for i = 1, #value do
			savestring = savestring..value[i]..",";
		end

		savestring = savestring..";";
	end

	cm:save_value(savename, savestring, context);
end

function LoadKeyPairTable(context, savename)
	local savestring = cm:load_value(savename, "", context);
	local tab = {};
	
	if savestring ~= "" then
		local first_split = SplitString(savestring, ";");
		
		for i = 1, #first_split do
			local second_split = SplitString(first_split[i], ",");

			tab[second_split[1]] = second_split[2];
		end
	end

	return tab;
end

function LoadKeyPairTableNumbers(context, savename)
	local savestring = cm:load_value(savename, "", context);
	local tab = {};
	
	if savestring ~= "" then
		local first_split = SplitString(savestring, ";");

		for i = 1, #first_split do
			local second_split = SplitString(first_split[i], ",");

			tab[second_split[1]] = tonumber(second_split[2]);
		end
	end

	return tab;
end

function LoadBooleanPairTable(context, savename)
	local savestring = cm:load_value(savename, "", context);
	local tab = {};
	
	if savestring ~= "" then
		local first_split = SplitString(savestring, ";");
		
		for i = 1, #first_split do
			local second_split = SplitString(first_split[i], ",");

			if second_split[2] == "true" then
				tab[second_split[1]] = true;
			else
				tab[second_split[1]] = false;				
			end
		end
	end

	return tab;
end

function LoadKeyPairTables(context, savename)
	local savestring = cm:load_value(savename, "", context);
	local tab = {};
	
	if savestring ~= "" then
		local first_split = SplitString(savestring, ";");

		for i = 1, #first_split do
			local tab2 = {};
			local second_split = SplitString(first_split[i], ",");

			if #second_split > 1 then
				for j = 2, #second_split do
					table.insert(tab2, second_split[j]);
				end
			end

			if #tab2 > 0 then
				tab[second_split[1]] = DeepCopy(tab2);
			end
		end
	end

	return tab;
end

function SplitString(str, delim)
	local res = { };
	local pattern = string.format("([^%s]+)%s()", delim, delim);

	while (true) do
		line, pos = str:match(pattern, pos);
		if line == nil then break end;
		table.insert(res, line);
	end

	return res;
end

function HasValue(tab, val)
	for index, value in ipairs(tab) do
		if value == val then
			return true;
		end
	end

	return false;
end

function DeepCopy(tab)
	local tab_type = type(tab);
	local copy;

	if tab_type == 'table' then
		copy = {};

		for tab_key, tab_value in next, tab, nil do
			copy[DeepCopy(tab_key)] = DeepCopy(tab_value);
		end

		setmetatable(copy, DeepCopy(getmetatable(tab)));
	else
		copy = tab;
	end

	return copy;
end
