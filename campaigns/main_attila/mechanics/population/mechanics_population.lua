----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: POPULATION
-- 	By: DETrooper
--
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
local dev = require("lua_scripts.dev");

require("mechanics/population/mechanics_population_economy");
require("mechanics/population/mechanics_population_lists");
require("mechanics/population/mechanics_population_ui");
require("mechanics/population/mechanics_population_unit_lists");

POPULATION_MANPOWER_PERCENTAGE = 0.25; -- How much of a population should be eligible for military service?
POPULATION_SOFT_CAP_PERCENTAGE = 0.5; -- How much to scale growth by when a region's population soft cap is exceeded?
POPULATION_HARD_CAP_PERCENTAGE = 0.1; -- How much to scale growth by when a region's population soft cap is exceeded?
POPULATION_SIEGE_POPULATION_LOSS = 0.05; -- How much percentage of population should be lost every turn that a settlement is under siege?
POPULATION_FOOD_SHORTAGE_POPULATION_LOSS = 0.05; -- How much percentage of population should be lost every turn that a settlement has a food shortage?
POPULATION_LOW_PUBLIC_ORDER_POPULATION_LOSS = 0.00001; -- How much percentage of population should be lost every turn due to low public order (scales with public order);
POPULATION_RAIDING_POPULATION_LOSS = 0.05; -- How much percentage of population should be lost every turn that a region is being raided?

POPULATION_REGIONS_POPULATIONS = {};
POPULATION_REGIONS_MANPOWER = {};
POPULATION_REGIONS_CHARACTERS_RAIDING = {};
POPULATION_REGIONS_GROWTH_RATES = {};
POPULATION_REGIONS_GROWTH_FACTORS = {};
POPULATION_FACTION_TOTAL_POPULATIONS = {};
POPULATION_UNITS_IN_RECRUITMENT = {};

function Add_Population_Listeners()
	cm:add_listener(
		"FactionTurnStart_Population",
		"FactionTurnStart",
		true,
		function(context) FactionTurnStart_Population(context) end,
		true
	);
	cm:add_listener(
		"BattleCompleted_Population",
		"BattleCompleted",
		true,
		function(context) BattleCompleted_Population(context) end,
		true
	);
	cm:add_listener(
		"CharacterTurnStart_Population",
		"CharacterTurnStart",
		true,
		function(context) CharacterTurnStart_Population(context) end,
		true
	);
	cm:add_listener(
		"CharacterTurnEnd_Population",
		"CharacterTurnEnd",
		true,
		function(context) CharacterTurnEnd_Population(context) end,
		true
	);
	cm:add_listener(
		"CharacterBesiegesSettlement_Population",
		"CharacterBesiegesSettlement",
		true,
		function(context) CharacterBesiegesSettlement_Population(context) end,
		true
	);
	cm:add_listener(
		"CharacterEntersGarrison_Population",
		"CharacterEntersGarrison",
		true,
		function(context) CharacterEntersGarrison_Population(context) end,
		true
	);
	cm:add_listener(
		"CharacterPerformsOccupationDecisionOccupy_Population",
		"CharacterPerformsOccupationDecisionOccupy",
		true,
		function(context) CharacterPerformsOccupationDecisionOccupy_Population(context) end,
		true
	);
	cm:add_listener(
		"CharacterPerformsOccupationDecisionLoot_Population",
		"CharacterPerformsOccupationDecisionLoot",
		true,
		function(context) CharacterPerformsOccupationDecisionLootSack_Population(context) end,
		true
	);
	cm:add_listener(
		"CharacterPerformsOccupationDecisionSack_Population",
		"CharacterPerformsOccupationDecisionSack",
		true,
		function(context) CharacterPerformsOccupationDecisionLootSack_Population(context) end,
		true
	);
	cm:add_listener(
		"CharacterPerformsOccupationDecisionRaze_Population",
		"CharacterPerformsOccupationDecisionRaze",
		true,
		function(context) CharacterPerformsOccupationDecisionRaze_Population(context) end,
		true
	);
	cm:add_listener(
		"CharacterPerformsOccupationDecisionResettle_Population",
		"CharacterPerformsOccupationDecisionResettle",
		true,
		function(context) CharacterPerformsOccupationDecisionResettle_Population(context) end,
		true
	);
	cm:add_listener(
		"ForceAdoptsStance_Population",
		"ForceAdoptsStance",
		true,
		function(context) ForceAdoptsStance_Population(context) end,
		true
	);
	cm:add_listener(
		"UnitTrained_Population",
		"UnitTrained",
		true,
		function(context) UnitTrained_Population(context) end,
		true
	);

	local faction_list = cm:model():world():faction_list();

	if cm:is_new_game() then
		POPULATION_REGIONS_POPULATIONS = DeepCopy(POPULATION_REGIONS_STARTING_POPULATIONS);
		POPULATION_REGIONS_MANPOWER = DeepCopy(POPULATION_REGIONS_STARTING_POPULATIONS);

		for i = 1, #REGIONS_LIST do
			local region_name = REGIONS_LIST[i];

			for j = 1, 5 do
				POPULATION_REGIONS_MANPOWER[region_name][j] = math.floor(POPULATION_REGIONS_MANPOWER[region_name][j] * POPULATION_MANPOWER_PERCENTAGE);
			end
		end

		for i = 0, faction_list:num_items() - 1 do
			local current_faction = faction_list:item_at(i);

			if current_faction:is_horde() == false and current_faction:region_list():num_items() > 0 then
				local regions = current_faction:region_list();

				for j = 0, regions:num_items() - 1 do
					local region = regions:item_at(j);

					POPULATION_REGIONS_GROWTH_RATES[region:name()] = Compute_Region_Growth(region);
					cm:apply_effect_bundle_to_region("mk_bundle_population_bundle_region", region:name(), 0);
				end
			end
		end
	end

	for i = 0, faction_list:num_items() - 1 do
		local current_faction = faction_list:item_at(i);
		Update_Faction_Total_Population(current_faction);
	end

	Add_Population_Economy_Listeners();
	Add_Population_UI_Listeners();
end

function FactionTurnStart_Population(context)
	if cm:model():turn_number() ~= 1 then
		if not context:faction():is_horde() then
			if context:faction():region_list():num_items() > 0 then
				Apply_Region_Growth_Factionwide(context:faction());
			end
		end
	end
end

function BattleCompleted_Population(context)
	local attacker_cqi, attacker_force_cqi, attacker_name = cm:pending_battle_cache_get_attacker(1);
	local attacker2_cqi, attacker_force2_cqi, attacker2_name = nil;
	local attacker3_cqi, attacker_force3_cqi, attacker3_name = nil;
	local attacker4_cqi, attacker_force4_cqi, attacker4_name = nil;
	local attacker_result = cm:model():pending_battle():attacker_battle_result();

	local defender_cqi, defender_force_cqi, defender_name = cm:pending_battle_cache_get_defender(1);
	local defender2_cqi, defender2_force_cqi, defender2_name = nil;
	local defender3_cqi, defender3_force_cqi, defender3_name = nil;
	local defender4_cqi, defender4_force_cqi, defender4_name = nil;
	local defender_result = cm:model():pending_battle():defender_battle_result();

	if attacker_result == "valiant_defeat" or attacker_result == "close_defeat" or attacker_result == "decisive_defeat" or attacker_result == "crushing_defeat" then
		POPULATION_UNITS_IN_RECRUITMENT[tostring(attacker_cqi)] = nil;

		if cm:pending_battle_cache_get_attacker(2) ~= nil then
			attacker2_cqi, attacker_force2_cqi, attacker2_name = cm:pending_battle_cache_get_attacker(2);
			POPULATION_UNITS_IN_RECRUITMENT[tostring(attacker2_cqi)] = nil;
		end

		if cm:pending_battle_cache_get_attacker(3) ~= nil then
			attacker3_cqi, attacker_force3_cqi, attacker3_name = cm:pending_battle_cache_get_attacker(3);
			POPULATION_UNITS_IN_RECRUITMENT[tostring(attacker3_cqi)] = nil;
		end

		if cm:pending_battle_cache_get_attacker(4) ~= nil then
			attacker4_cqi, attacker_force4_cqi, attacker4_name = cm:pending_battle_cache_get_attacker(4);
			POPULATION_UNITS_IN_RECRUITMENT[tostring(attacker4_cqi)] = nil;
		end
	end

	if defender_result == "valiant_defeat" or defender_result == "close_defeat" or defender_result == "decisive_defeat" or defender_result == "crushing_defeat" then
		POPULATION_UNITS_IN_RECRUITMENT[tostring(defender_cqi)] = nil;

		if cm:pending_battle_cache_get_defender(2) ~= nil then
			defender2_cqi, defender_force2_cqi, defender2_name = cm:pending_battle_cache_get_defender(2);
			POPULATION_UNITS_IN_RECRUITMENT[tostring(defender2_cqi)] = nil;
		end

		if cm:pending_battle_cache_get_defender(3) ~= nil then
			defender3_cqi, defender_force3_cqi, defender3_name = cm:pending_battle_cache_get_defender(3);
			POPULATION_UNITS_IN_RECRUITMENT[tostring(defender3_cqi)] = nil;
		end

		if cm:pending_battle_cache_get_defender(4) ~= nil then
			defender4_cqi, defender_force4_cqi, defender4_name = cm:pending_battle_cache_get_defender(4);
			POPULATION_UNITS_IN_RECRUITMENT[tostring(defender4_cqi)] = nil;
		end
	end

	dev.log(cm:model():pending_battle():has_contested_garrison());
	if cm:model():pending_battle():has_contested_garrison() then
		local region = cm:model():pending_battle():contested_garrison():region();

		POPULATION_REGIONS_GROWTH_RATES[region:name()] = Compute_Region_Growth(region);
	end
end

function CharacterTurnStart_Population(context)
	CheckArmyReplenishment(context:character());

	if context:character():region():owning_faction() ~= context:character():faction() then
		POPULATION_UNITS_IN_RECRUITMENT[tostring(context:character():cqi())] = {};
	end
end

function CharacterTurnEnd_Population(context)
	CheckArmyReplenishment(context:character());

	if context:character():region():owning_faction() ~= context:character():faction() then
		POPULATION_UNITS_IN_RECRUITMENT[tostring(context:character():cqi())] = {};
	end

	if POPULATION_REGIONS_CHARACTERS_RAIDING[tostring(context:character():cqi())] ~= nil then
		if not context:character():region():name() == POPULATION_REGIONS_CHARACTERS_RAIDING[tostring(context:character():cqi())] then
			POPULATION_REGIONS_CHARACTERS_RAIDING[tostring(context:character():cqi())] = nil;
		end
	end
end

function CheckArmyReplenishment(character)
	local region = nil;

	if character:has_military_force() then
		local force = character:military_force():unit_list();
		local replenishment_costs = {0, 0, 0, 0, 0};

		cm:remove_effect_bundle_from_characters_force("mk_bundle_population_no_replenishment", character:cqi());
		cm:remove_effect_bundle_from_characters_force("mk_bundle_population_no_replenishment_sea", character:cqi());

		if character:has_region() then
			region = character:region();
		else
			if character:military_force():is_navy() then
				local x = character:logical_position_x();
				local y = character:logical_position_y();

				region = FindClosestPort(x, y, character:faction());
				dev.log("Character port region for replenishment: "..region:name());
			else
				dev.log("No replenishment for armies in the water");
				cm:apply_effect_bundle_to_characters_force("mk_bundle_population_no_replenishment_sea", character:cqi(), 0, true);
				return;
			end
		end

		if region:owning_faction() == character:faction() then
			for i = 0, force:num_items() - 1 do
				local unit = force:item_at(i);
 				local unit_name = unit:unit_key();
				local unit_cost = POPULATION_UNITS_TO_POPULATION[unit_name][1];
				local unit_strength = math.floor((unit_cost * (ARMY_SELECTED_STRENGTHS_TABLE[i] / 100)) + 0.5);
				local unit_class = POPULATION_UNITS_TO_POPULATION[unit_name][2];

				replenishment_costs[unit_class] = unit_cost - unit_strength;
			end

			for i = 1, 5 do
				if replenishment_costs[i] > POPULATION_REGIONS_MANPOWER[region:name()][i] then
					dev.log("Not enough class "..i.." population in "..REGIONS_NAMES_LOCALISATION[region_name]);
					cm:apply_effect_bundle_to_characters_force("mk_bundle_population_no_replenishment", character:cqi(), 0, true);
					return;
				end
			end
		end
	end
end

function CharacterBesiegesSettlement_Population(context)
	POPULATION_REGIONS_GROWTH_RATES[context:region():name()] = Compute_Region_Growth(context:region());
end

function CharacterEntersGarrison_Population(context)
	if context:character():has_region() then
		local region = context:character():region();
		dev.log("Entered Garrison "..region:name().."!");
		POPULATION_REGIONS_GROWTH_RATES[region:name()] = Compute_Region_Growth(region);
	end
end

function CharacterPerformsOccupationDecisionOccupy_Population(context)
	local region = FindClosestRegion(context:character():logical_position_x(), context:character():logical_position_y(), "none"); -- Taking the character's region may be inaccurate if they're at sea or across a strait.

	dev.log("Occupied "..region:name().."!");

	for i = 1, 5 do
		POPULATION_REGIONS_POPULATIONS[region:name()][i] = math.floor(POPULATION_REGIONS_POPULATIONS[region:name()][i] * 0.95);
		POPULATION_REGIONS_MANPOWER[region:name()][i] = math.floor(POPULATION_REGIONS_MANPOWER[region:name()][i] * 0.95);
	end

	POPULATION_REGIONS_GROWTH_RATES[region:name()] = Compute_Region_Growth(region);
	Update_Faction_Total_Population(context:character():faction());
end

function CharacterPerformsOccupationDecisionLootSack_Population(context)
	local region = FindClosestRegion(context:character():logical_position_x(), context:character():logical_position_y(), "none"); -- Taking the character's region may be inaccurate if they're at sea or across a strait.

	dev.log("Looted & Occupied or Sacked "..region:name().."!");

	if SackExploitCheck_Population(context:character():region():name()) == true then
		for i = 1, 5 do
			POPULATION_REGIONS_POPULATIONS[region:name()][i] = math.floor(POPULATION_REGIONS_POPULATIONS[region:name()][i] * 0.80);
			POPULATION_REGIONS_MANPOWER[region:name()][i] = math.floor(POPULATION_REGIONS_MANPOWER[region:name()][i] * 0.80);
		end
	end

	POPULATION_REGIONS_GROWTH_RATES[region:name()] = Compute_Region_Growth(region);
	Update_Faction_Total_Population(context:character():faction());
end

function CharacterPerformsOccupationDecisionRaze_Population(context)
	local region = FindClosestRegion(context:character():logical_position_x(), context:character():logical_position_y(), "none"); -- Taking the character's region may be inaccurate if they're at sea or across a strait.

	dev.log("Razed "..region:name().."!");

	for i = 1, 5 do
		POPULATION_REGIONS_POPULATIONS[region:name()][i] = 0;
		POPULATION_REGIONS_MANPOWER[region:name()][i] = 0;
	end

	POPULATION_REGIONS_GROWTH_RATES[region:name()] = Compute_Region_Growth(region);
end

function CharacterPerformsOccupationDecisionResettle_Population(context)
	local region = FindClosestRegion(context:character():logical_position_x(), context:character():logical_position_y(), "none"); -- Taking the character's region may be inaccurate if they're at sea or across a strait.

	dev.log("Resettled "..region:name().."!");

	POPULATION_REGIONS_POPULATIONS[region:name()][1] = 100;
	POPULATION_REGIONS_POPULATIONS[region:name()][2] = 400;
	POPULATION_REGIONS_POPULATIONS[region:name()][3] = 1000;
	POPULATION_REGIONS_MANPOWER[region:name()][1] = 25;
	POPULATION_REGIONS_MANPOWER[region:name()][2] = 100;
	POPULATION_REGIONS_MANPOWER[region:name()][3] = 200;

	POPULATION_REGIONS_GROWTH_RATES[region:name()] = Compute_Region_Growth(region);
	Update_Faction_Total_Population(context:character():faction());
end

function ForceAdoptsStance_Population(context)
	local force = context:military_force();
	local general = force:general_character();
	local region = general:region();
	local region_name = region:name();
	local stance = context:stance_adopted();

	if stance == 3 then
		POPULATION_REGIONS_CHARACTERS_RAIDING[tostring(general:cqi())] = region_name;
	else
		if POPULATION_REGIONS_CHARACTERS_RAIDING[tostring(general:cqi())] ~= nil then
			POPULATION_REGIONS_CHARACTERS_RAIDING[tostring(general:cqi())] = nil;
		end
	end

	POPULATION_REGIONS_GROWTH_RATES[region_name] = Compute_Region_Growth(region);
end

function UnitTrained_Population(context)
	local unit = context:unit();

	if unit:faction():is_human() then
		for i = 1, #POPULATION_UNITS_IN_RECRUITMENT[tostring(unit:force_commander():cqi())] do
			if POPULATION_UNITS_IN_RECRUITMENT[tostring(unit:force_commander():cqi())][i] == unit:unit_key() then
				dev.log("Removing "..unit:unit_key().." from queue.");
				table.remove(POPULATION_UNITS_IN_RECRUITMENT[tostring(LAST_CHARACTER_SELECTED:cqi())], i);
				break;
			end
		end
	end
end

function Compute_Region_Growth(region)
	local growth = {0, 0, 0, 0, 0};
	local growth_modifier = 1;
	local region_population = 0;
	local soft_cap = 0;
	local hard_cap = 0;

	local region_name = region:name();
	local buildings_list = region:garrison_residence():buildings();
	local under_siege = region:garrison_residence():is_under_siege();
	local food_shortage = region:owning_faction():has_food_shortage();
	local public_order = region:public_order();

	POPULATION_REGIONS_GROWTH_FACTORS[region_name]= "";

	for i = 1, 5 do
		region_population = region_population + POPULATION_REGIONS_POPULATIONS[region_name][i];
	end

	for i = 0, buildings_list:num_items() - 1 do
		if POPULATION_BUILDINGS_TO_GROWTH[buildings_list:item_at(i):name()] ~= nil then
			for j = 1, 5 do
				growth[j] = growth[j] + POPULATION_BUILDINGS_TO_GROWTH[buildings_list:item_at(i):name()][j];
			end

			soft_cap = soft_cap + POPULATION_BUILDINGS_TO_GROWTH[buildings_list:item_at(i):name()][6];
			hard_cap = hard_cap + POPULATION_BUILDINGS_TO_GROWTH[buildings_list:item_at(i):name()][7];
		end
	end

	for i = 1, 5 do
		POPULATION_REGIONS_GROWTH_FACTORS[region_name] = POPULATION_REGIONS_GROWTH_FACTORS[region_name].."buildings_"..tostring(i).."#"..tostring(growth[i] * 100).."#@";
	end

	if region_population > hard_cap then 
		growth_modifier = POPULATION_HARD_CAP_PERCENTAGE;
		POPULATION_REGIONS_GROWTH_FACTORS[region_name] = POPULATION_REGIONS_GROWTH_FACTORS[region_name].."hard_cap_exceeded#"..tostring(100 - (100 * growth_modifier)).."#@";
	elseif region_population > soft_cap then 
		growth_modifier = POPULATION_SOFT_CAP_PERCENTAGE;
		POPULATION_REGIONS_GROWTH_FACTORS[region_name] = POPULATION_REGIONS_GROWTH_FACTORS[region_name].."soft_cap_exceeded#"..tostring(100 - (100 * growth_modifier)).."#@";
	end

	for i = 1, 5 do
		growth[i] = growth[i] * growth_modifier;

		if under_siege == true then
			growth[i] = growth[i] - POPULATION_SIEGE_POPULATION_LOSS;
			POPULATION_REGIONS_GROWTH_FACTORS[region_name] = POPULATION_REGIONS_GROWTH_FACTORS[region_name].."under_siege#"..tostring(POPULATION_SIEGE_POPULATION_LOSS * 100).."#@";
		end

		if food_shortage == true then
			growth[i] = growth[i] - POPULATION_FOOD_SHORTAGE_POPULATION_LOSS;
			POPULATION_REGIONS_GROWTH_FACTORS[region_name] = POPULATION_REGIONS_GROWTH_FACTORS[region_name].."food_shortage#"..tostring(POPULATION_FOOD_SHORTAGE_POPULATION_LOSS * 100).."#@";
		end

		if public_order < 0 then
			local population_loss = -1 * (public_order * POPULATION_LOW_PUBLIC_ORDER_POPULATION_LOSS);
			growth[i] = growth[i] - population_loss;
			POPULATION_REGIONS_GROWTH_FACTORS[region_name] = POPULATION_REGIONS_GROWTH_FACTORS[region_name].."public_order#"..tostring(population_loss * 100).."#@";
		end
	end

	for k, v in pairs(POPULATION_REGIONS_CHARACTERS_RAIDING) do
		if v == region_name then
			for j = 1, 5 do
				growth[j] = growth[j] - POPULATION_RAIDING_POPULATION_LOSS;
				POPULATION_REGIONS_GROWTH_FACTORS[region_name] = POPULATION_REGIONS_GROWTH_FACTORS[region_name].."region_raided#"..tostring(POPULATION_RAIDING_POPULATION_LOSS * 100).."#@";
			end
		end
	end

	cm:apply_effect_bundle_to_region("mk_bundle_population_bundle_region", region:name(), 0); -- Re-apply this effect bundle in case it gets removed somehow (i.e. through occupation).

	return growth;
end

function Apply_Region_Growth_Factionwide(faction)
	local regions = faction:region_list();

	for i = 0, regions:num_items() - 1 do
		local region = regions:item_at(i);
		local region_name = region:name();

		POPULATION_REGIONS_GROWTH_RATES[region_name] = Compute_Region_Growth(region);

		for j = 1, 5 do
			if POPULATION_REGIONS_POPULATIONS[region_name][j] == 0 then
				if POPULATION_REGIONS_GROWTH_RATES[region_name][j] > 0 then
					POPULATION_REGIONS_POPULATIONS[region_name][j] = 1;
				end
			else
				POPULATION_REGIONS_POPULATIONS[region_name][j] = POPULATION_REGIONS_POPULATIONS[region_name][j] + math.ceil(POPULATION_REGIONS_POPULATIONS[region_name][j] * POPULATION_REGIONS_GROWTH_RATES[region_name][j]);
			end
		end

		-- Manpower
		for j = 1, 5 do
			if POPULATION_REGIONS_MANPOWER[region_name][j] == 0 then
				if POPULATION_REGIONS_GROWTH_RATES[region_name][j] > 0 then
					POPULATION_REGIONS_MANPOWER[region_name][j] = 1;
				end
			else
				POPULATION_REGIONS_MANPOWER[region_name][j] = POPULATION_REGIONS_MANPOWER[region_name][j] + math.ceil(POPULATION_REGIONS_MANPOWER[region_name][j] * (POPULATION_REGIONS_GROWTH_RATES[region_name][j] * POPULATION_MANPOWER_PERCENTAGE));
			end
		end
	end

	Update_Faction_Total_Population(faction);
end

function Update_Faction_Total_Population(faction)
	local total = 0;

	if not faction:is_horde() then
		local regions = faction:region_list();

		for i = 0, regions:num_items() - 1 do
			local region = regions:item_at(i);

			total = total + POPULATION_REGIONS_POPULATIONS[region:name()][1] + POPULATION_REGIONS_POPULATIONS[region:name()][2] + POPULATION_REGIONS_POPULATIONS[region:name()][3] + POPULATION_REGIONS_POPULATIONS[region:name()][4] + POPULATION_REGIONS_POPULATIONS[region:name()][5];
		end
	end

	POPULATION_FACTION_TOTAL_POPULATIONS[faction:name()] = total;
end

function Get_Total_Population_Region(region_name)
	local total = POPULATION_REGIONS_POPULATIONS[region_name][1] + POPULATION_REGIONS_POPULATIONS[region_name][2] + POPULATION_REGIONS_POPULATIONS[region_name][3] + POPULATION_REGIONS_POPULATIONS[region_name][4] + POPULATION_REGIONS_POPULATIONS[region_name][5];

	return total;
end

function Change_Population_Region(region_name, class, amount)
	POPULATION_REGIONS_POPULATIONS[region_name][class] = POPULATION_REGIONS_POPULATIONS[region_name][class] + amount;
end

function Change_Manpower_Region(region_name, class, amount)
	POPULATION_REGIONS_MANPOWER[region_name][class] = POPULATION_REGIONS_MANPOWER[region_name][class] + amount;

	Change_Population_Region(region_name, class, amount);
end

------------------------------------------------
---------------- Saving/Loading ----------------
------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		SavePopulationNumbersTable(context, POPULATION_REGIONS_POPULATIONS, "POPULATION_REGIONS_POPULATIONS");
		SavePopulationNumbersTable(context, POPULATION_REGIONS_MANPOWER, "POPULATION_REGIONS_MANPOWER");
		SavePopulationNumbersTable(context, POPULATION_REGIONS_GROWTH_RATES, "POPULATION_REGIONS_GROWTH_RATES");
		SaveFactionPopulationNumbersTable(context, POPULATION_FACTION_TOTAL_POPULATIONS, "POPULATION_FACTION_TOTAL_POPULATIONS");
		SaveKeyPairTable(context, POPULATION_REGIONS_GROWTH_FACTORS, "POPULATION_REGIONS_GROWTH_FACTORS");
		SaveKeyPairTable(context, POPULATION_REGIONS_CHARACTERS_RAIDING, "POPULATION_REGIONS_CHARACTERS_RAIDING");
	end
);

cm:register_loading_game_callback(
	function(context)
		POPULATION_REGIONS_POPULATIONS = LoadPopulationNumbersTable(context, "POPULATION_REGIONS_POPULATIONS");
		POPULATION_REGIONS_MANPOWER = LoadPopulationNumbersTable(context, "POPULATION_REGIONS_MANPOWER");
		POPULATION_REGIONS_GROWTH_RATES = LoadPopulationNumbersTable(context, "POPULATION_REGIONS_GROWTH_RATES");
		POPULATION_FACTION_TOTAL_POPULATIONS = LoadFactionPopulationNumbersTable(context, "POPULATION_FACTION_TOTAL_POPULATIONS");
		POPULATION_REGIONS_GROWTH_FACTORS = LoadKeyPairTable(context, "POPULATION_REGIONS_GROWTH_FACTORS");
		POPULATION_REGIONS_CHARACTERS_RAIDING = LoadKeyPairTable(context, "POPULATION_REGIONS_CHARACTERS_RAIDING");
	end
);

function SavePopulationNumbersTable(context, tab, savename)
	local savestring = "";
	
	for key, tab2 in pairs(tab) do
		savestring = savestring..key..","..tostring(tab[key][1])..","..tostring(tab[key][2])..","..tostring(tab[key][3])..","..tostring(tab[key][4])..","..tostring(tab[key][5])..",;";
	end

	cm:save_value(savename, savestring, context);
end

function SaveFactionPopulationNumbersTable(context, tab, savename)
	local savestring = "";

	for key, tab2 in pairs(tab) do
		savestring = savestring..key..","..tostring(tab[key])..",;";
	end

	cm:save_value(savename, savestring, context);
end

function LoadPopulationNumbersTable(context, savename)
	local savestring = cm:load_value(savename, "", context);
	local tab = {};
	
	if savestring ~= "" then
		local first_split = SplitString(savestring, ";");

		for i = 1, #first_split do
			local second_split = SplitString(first_split[i], ",");

			local population_table = {tonumber(second_split[2]), tonumber(second_split[3]), tonumber(second_split[4]), tonumber(second_split[5]), tonumber(second_split[6])};
			tab[second_split[1]] = population_table;
		end
	end

	return tab;
end

function LoadFactionPopulationNumbersTable(context, savename)
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