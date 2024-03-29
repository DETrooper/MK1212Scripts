----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: POPULATION
-- 	By: DETrooper
--
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------

require("mechanics/population/mechanics_population_economy");
require("mechanics/population/mechanics_population_lists");
require("mechanics/population/mechanics_population_ui");
require("mechanics/population/mechanics_population_unit_lists");

POPULATION_MANPOWER_PERCENTAGE = 0.25; -- How much of a population should be eligible for military service?
POPULATION_MANPOWER_SOFT_CAP = 1.25; -- How much should manpower be allowed to exceed its ratio by before its growth is stymied? 1.25 = 25% above its ratio.
POPULATION_MANPOWER_REGENERATION_RATE = 0.75; -- If manpower is lower than the above percentage of a population (1/4th of population), how much should it regenerate by in addition to growth?
POPULATION_MANPOWER_DEGENERATION_RATE = 0.2; -- If manpower is growing too fast, how much should growth be reduced by?
POPULATION_SOFT_CAP_PERCENTAGE = 0.5; -- How much to scale growth by when a region's population soft cap is exceeded?
POPULATION_HARD_CAP_PERCENTAGE = 0.1; -- How much to scale growth by when a region's population soft cap is exceeded?
POPULATION_CAPITAL_BONUS = 0.02; -- How much should a capital region's population be boosted?
POPULATION_IMPERIAL_DECREE_BONUS = 0.005; -- How much should be added to a region that has a growth-boosting imperial decree (HRE)?
POPULATION_SIEGE_POPULATION_LOSS = 0.05; -- How much percentage of population should be lost every turn that a settlement is under siege?
POPULATION_FOOD_SHORTAGE_POPULATION_LOSS = 0.05; -- How much percentage of population should be lost every turn that a settlement has a food shortage?
POPULATION_RAIDING_POPULATION_LOSS = 0.05; -- How much percentage of population should be lost every turn that a region is being raided?
POPULATION_PLAGUE_POPULATION_LOSS = 0.125; -- How much percentage of population should be lost when a rebellion fires?
POPULATION_REBELLION_POPULATION_LOSS = 0.05; -- How much percentage of population should be lost when a rebellion fires?

POPULATION_REGIONS_POPULATIONS = {};
POPULATION_REGIONS_MANPOWER = {};
POPULATION_REGIONS_CHARACTERS_RAIDING = {};
POPULATION_REGIONS_GROWTH_RATES = {};
POPULATION_REGIONS_GROWTH_FACTORS = {};
POPULATION_FACTION_TECH_BONUSES = {};
POPULATION_FACTION_TECH_RESEARCHED = {};
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
	--[[cm:add_listener(
		"CharacterPerformsOccupationDecisionResettle_Population",
		"CharacterPerformsOccupationDecisionResettle",
		true,
		function(context) CharacterPerformsOccupationDecisionResettle_Population(context) end,
		true
	);]]--
	cm:add_listener(
		"ForceAdoptsStance_Population",
		"ForceAdoptsStance",
		true,
		function(context) ForceAdoptsStance_Population(context) end,
		true
	);
	cm:add_listener(
		"RegionRebels_Population",
		"RegionRebels",
		true,
		function(context) RegionRebels_Population(context) end,
		true
	);
	cm:add_listener(
		"RegionResettled_Population",
		"RegionResettled",
		true,
		function(context) RegionResettled_Population(context) end,
		true
	);
	cm:add_listener(
		"ResearchCompleted_Population",
		"ResearchCompleted",
		true,
		function(context) ResearchCompleted_Population(context) end,
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

		local region_list = cm:model():world():region_manager():region_list();

		for i = 0, region_list:num_items() - 1 do
			local region = region_list:item_at(i);
			local region_name = region:name();

			for j = 1, 5 do
				POPULATION_REGIONS_MANPOWER[region_name][j] = math.floor(POPULATION_REGIONS_MANPOWER[region_name][j] * POPULATION_MANPOWER_PERCENTAGE);
			end
		end

		for i = 0, faction_list:num_items() - 1 do
			local current_faction = faction_list:item_at(i);
			local current_faction_name = current_faction:name();

			POPULATION_FACTION_TECH_BONUSES[current_faction_name] = {0, 0, 0, 0, 0};
			POPULATION_FACTION_TECH_RESEARCHED[current_faction_name] = {};

			Check_Technologies_Population(current_faction_name);

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
	--dev.log("\nFactionTurnStart_Population for faction "..context:faction():name());
	
	if cm:model():turn_number() ~= 1 then
		if not context:faction():is_horde() then
			if context:faction():region_list():num_items() > 0 then
				Apply_Region_Growth_Factionwide(context:faction());
			end
		end
	end

	if context:faction():is_human() then
		for k, v in pairs(POPULATION_REGIONS_CHARACTERS_RAIDING) do
			if cm:model():character_for_command_queue_index(tonumber(k)) == nil or cm:model():character_for_command_queue_index(tonumber(k)):is_null_interface() then
				POPULATION_REGIONS_CHARACTERS_RAIDING[k] = nil;
			else
				if cm:model():character_for_command_queue_index(tonumber(k)):has_region() then
					if cm:model():character_for_command_queue_index(tonumber(k)):region():name() ~= v then
						POPULATION_REGIONS_CHARACTERS_RAIDING[k] = nil;
					end
				else
					POPULATION_REGIONS_CHARACTERS_RAIDING[k] = nil;
				end
			end

			-- Update growth of the region now that raiding has been processed.
			POPULATION_REGIONS_GROWTH_RATES[v] = Compute_Region_Growth(cm:model():world():region_manager():region_by_key(v));
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

		if cm:pending_battle_cache_get_attacker(2)  then
			attacker2_cqi, attacker_force2_cqi, attacker2_name = cm:pending_battle_cache_get_attacker(2);
			POPULATION_UNITS_IN_RECRUITMENT[tostring(attacker2_cqi)] = nil;
		end

		if cm:pending_battle_cache_get_attacker(3)  then
			attacker3_cqi, attacker_force3_cqi, attacker3_name = cm:pending_battle_cache_get_attacker(3);
			POPULATION_UNITS_IN_RECRUITMENT[tostring(attacker3_cqi)] = nil;
		end

		if cm:pending_battle_cache_get_attacker(4)  then
			attacker4_cqi, attacker_force4_cqi, attacker4_name = cm:pending_battle_cache_get_attacker(4);
			POPULATION_UNITS_IN_RECRUITMENT[tostring(attacker4_cqi)] = nil;
		end
	end

	if defender_result == "valiant_defeat" or defender_result == "close_defeat" or defender_result == "decisive_defeat" or defender_result == "crushing_defeat" then
		POPULATION_UNITS_IN_RECRUITMENT[tostring(defender_cqi)] = nil;

		if cm:pending_battle_cache_get_defender(2)  then
			defender2_cqi, defender_force2_cqi, defender2_name = cm:pending_battle_cache_get_defender(2);
			POPULATION_UNITS_IN_RECRUITMENT[tostring(defender2_cqi)] = nil;
		end

		if cm:pending_battle_cache_get_defender(3)  then
			defender3_cqi, defender_force3_cqi, defender3_name = cm:pending_battle_cache_get_defender(3);
			POPULATION_UNITS_IN_RECRUITMENT[tostring(defender3_cqi)] = nil;
		end

		if cm:pending_battle_cache_get_defender(4)  then
			defender4_cqi, defender_force4_cqi, defender4_name = cm:pending_battle_cache_get_defender(4);
			POPULATION_UNITS_IN_RECRUITMENT[tostring(defender4_cqi)] = nil;
		end
	end

	if cm:model():pending_battle():has_contested_garrison() then
		local region = cm:model():pending_battle():contested_garrison():region();

		POPULATION_REGIONS_GROWTH_RATES[region:name()] = Compute_Region_Growth(region);
	end
end

function CharacterTurnStart_Population(context)
	CheckArmyReplenishment(context:character());

	if context:character():region():owning_faction() ~= context:character():faction() then
		POPULATION_UNITS_IN_RECRUITMENT[tostring(context:character():cqi())] = nil;
	end

	if POPULATION_REGIONS_CHARACTERS_RAIDING[tostring(context:character():cqi())]  then
		if POPULATION_REGIONS_CHARACTERS_RAIDING[tostring(context:character():cqi())] ~= context:character():region():name() or context:character():has_military_force() == false then
			POPULATION_REGIONS_CHARACTERS_RAIDING[tostring(context:character():cqi())] = nil;
		end
	end
end

function CharacterTurnEnd_Population(context)
	CheckArmyReplenishment(context:character());

	if context:character():region():owning_faction() ~= context:character():faction() then
		POPULATION_UNITS_IN_RECRUITMENT[tostring(context:character():cqi())] = nil;
	end

	if POPULATION_REGIONS_CHARACTERS_RAIDING[tostring(context:character():cqi())]  then
		if not context:character():region():name() == POPULATION_REGIONS_CHARACTERS_RAIDING[tostring(context:character():cqi())] then
			POPULATION_REGIONS_CHARACTERS_RAIDING[tostring(context:character():cqi())] = nil;
		end
	end
end

function CheckArmyReplenishment(character)
	local region = nil;

	if character:has_military_force() and not character:character_type("colonel") then
		local force = character:military_force():unit_list();
		local force_unit_strengths = {};
		local replenishment_costs = {0, 0, 0, 0, 0};

		cm:remove_effect_bundle_from_characters_force("mk_bundle_population_no_replenishment", character:cqi());
		cm:remove_effect_bundle_from_characters_force("mk_bundle_population_no_replenishment_sea", character:cqi());

		if force:num_items() > 1 then -- General units do not use population.
			if character:has_region() then
				region = character:region();
			else
				if character:military_force():is_navy() then
					local x = character:logical_position_x();
					local y = character:logical_position_y();

					region = FindClosestPort(x, y, character:faction());
					--dev.log("Character port region for replenishment: "..region:name());
				else
					--dev.log("No replenishment for armies in the water");
					cm:apply_effect_bundle_to_characters_force("mk_bundle_population_no_replenishment_sea", character:cqi(), 0, true);
					return;
				end
			end

			for i = 1, force:num_items() - 1 do
				table.insert(force_unit_strengths, force:item_at(i):percentage_proportion_of_full_strength());
			end

			if region:owning_faction() == character:faction() then
				for i = 1, force:num_items() - 1 do
					local unit = force:item_at(i);
					local unit_name = unit:unit_key();
					local unit_population_table = POPULATION_UNITS_TO_POPULATION[unit_name];

					if unit_population_table then
						local unit_cost = unit_population_table[1];
						local unit_strength = math.floor((unit_cost * (force_unit_strengths[i] / 100)) + 0.5);
						local unit_class = unit_population_table[2];

						replenishment_costs[unit_class] = unit_cost - unit_strength;
					end
				end

				for i = 1, 5 do
					if replenishment_costs[i] > POPULATION_REGIONS_MANPOWER[region:name()][i] then
						--dev.log("Not enough class "..i.." population in "..REGIONS_NAMES_LOCALISATION[region_name]);
						cm:apply_effect_bundle_to_characters_force("mk_bundle_population_no_replenishment", character:cqi(), 0, true);
						return;
					end
				end
			end
		end
	end
end

function CharacterBesiegesSettlement_Population(context)
	POPULATION_REGIONS_GROWTH_RATES[context:region():name()] = Compute_Region_Growth(context:region());
end

function CharacterEntersGarrison_Population(context)
	CheckArmyReplenishment(context:character());

	if context:character():has_region() then
		local region = context:character():region();
		--dev.log("Entered Garrison "..region:name().."!");
		POPULATION_REGIONS_GROWTH_RATES[region:name()] = Compute_Region_Growth(region);
		Update_Faction_Total_Population(context:character():faction());
	end
end

function CharacterPerformsOccupationDecisionOccupy_Population(context)
	local region = FindClosestRegion(context:character():logical_position_x(), context:character():logical_position_y(), "none"); -- Taking the character's region may be inaccurate if they're at sea or across a strait.

	if region then
		--dev.log("Occupied "..region:name().."!");

		for i = 1, 5 do
			POPULATION_REGIONS_POPULATIONS[region:name()][i] = math.floor(POPULATION_REGIONS_POPULATIONS[region:name()][i] * 0.95);
			POPULATION_REGIONS_MANPOWER[region:name()][i] = math.floor(POPULATION_REGIONS_MANPOWER[region:name()][i] * 0.95);
		end

		POPULATION_REGIONS_GROWTH_RATES[region:name()] = Compute_Region_Growth(region);
	end
	
	Update_Faction_Total_Population(context:character():faction());
end

function CharacterPerformsOccupationDecisionLootSack_Population(context)
	local region = FindClosestRegion(context:character():logical_position_x(), context:character():logical_position_y(), "none"); -- Taking the character's region may be inaccurate if they're at sea or across a strait.

	if region then
		--dev.log("Looted & Occupied or Sacked "..region:name().."!");

		if SackExploitCheck_Population(context:character():region():name()) == true then
			for i = 1, 5 do
				POPULATION_REGIONS_POPULATIONS[region:name()][i] = math.floor(POPULATION_REGIONS_POPULATIONS[region:name()][i] * 0.80);
				POPULATION_REGIONS_MANPOWER[region:name()][i] = math.floor(POPULATION_REGIONS_MANPOWER[region:name()][i] * 0.80);
			end
		end

		POPULATION_REGIONS_GROWTH_RATES[region:name()] = Compute_Region_Growth(region);
	end
	
	Update_Faction_Total_Population(context:character():faction());
end

function CharacterPerformsOccupationDecisionRaze_Population(context)
	local region = FindClosestRegion(context:character():logical_position_x(), context:character():logical_position_y(), "none"); -- Taking the character's region may be inaccurate if they're at sea or across a strait.

	if region then
		--dev.log("Razed "..region:name().."!");

		for i = 1, 5 do
			POPULATION_REGIONS_POPULATIONS[region:name()][i] = 0;
			POPULATION_REGIONS_MANPOWER[region:name()][i] = 0;
		end

		POPULATION_REGIONS_GROWTH_RATES[region:name()] = Compute_Region_Growth(region);
	end
end

--[[function CharacterPerformsOccupationDecisionResettle_Population(context)
	local region = FindClosestRegion(context:character():logical_position_x(), context:character():logical_position_y(), "none"); -- Taking the character's region may be inaccurate if they're at sea or across a strait.

	if region then
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
end]]--

function ForceAdoptsStance_Population(context)
	local force = context:military_force();
	local general = force:general_character();
	local region = general:region();
	local region_name = region:name();
	local stance = context:stance_adopted();

	if stance == 3 then
		POPULATION_REGIONS_CHARACTERS_RAIDING[tostring(general:cqi())] = region_name;
	else
		if POPULATION_REGIONS_CHARACTERS_RAIDING[tostring(general:cqi())]  then
			POPULATION_REGIONS_CHARACTERS_RAIDING[tostring(general:cqi())] = nil;
		end
	end

	POPULATION_REGIONS_GROWTH_RATES[region_name] = Compute_Region_Growth(region);
end

function RegionRebels_Population(context)
	local region_name = context:region():name();

	for i = 1, 5 do
		local population = POPULATION_REGIONS_POPULATIONS[region_name][i];
		local manpower = POPULATION_REGIONS_MANPOWER[region_name][i];
	
		POPULATION_REGIONS_POPULATIONS[region_name][i] = toupper(population - (population * POPULATION_REBELLION_POPULATION_LOSS));
		POPULATION_REGIONS_MANPOWER[region_name][i] = toupper(manpower - (manpower * POPULATION_REBELLION_POPULATION_LOSS));
	end
end

function RegionResettled_Population(context)
	local region = context:region();

	--dev.log("Resettled "..region:name().."!");

	POPULATION_REGIONS_POPULATIONS[region:name()][1] = 100;
	POPULATION_REGIONS_POPULATIONS[region:name()][2] = 400;
	POPULATION_REGIONS_POPULATIONS[region:name()][3] = 1000;
	POPULATION_REGIONS_MANPOWER[region:name()][1] = 25;
	POPULATION_REGIONS_MANPOWER[region:name()][2] = 100;
	POPULATION_REGIONS_MANPOWER[region:name()][3] = 200;

	POPULATION_REGIONS_GROWTH_RATES[region:name()] = Compute_Region_Growth(region);
	Update_Faction_Total_Population(region:owning_faction());
end

function ResearchCompleted_Population(context)
	Check_Technologies_Population(context:faction():name());
end

function UnitTrained_Population(context)
	local unit = context:unit();

	if unit:faction():is_human() then
		local cqi = tostring(unit:force_commander():cqi());
		
		if POPULATION_UNITS_IN_RECRUITMENT[cqi]  then
			for i = 1, #POPULATION_UNITS_IN_RECRUITMENT[cqi] do
				if POPULATION_UNITS_IN_RECRUITMENT[cqi][i] == unit:unit_key() then
					--dev.log("Removing "..unit:unit_key().." from queue.");
					table.remove(POPULATION_UNITS_IN_RECRUITMENT[cqi], i);
					break;
				end
			end
		end
	end
end

function Compute_Region_Growth(region)
	--dev.log("Computing growth for: "..region:name());
	local growth = {0, 0, 0, 0, 0};
	local growth_modifier = 1;
	local region_population = 0;
	local soft_cap = 0;
	local hard_cap = 0;

	if region:owning_faction():name() == "rebels" then
		--dev.log("Region is razed!");
		return growth;
	end

	local region_name = region:name();
	local region_owning_faction = region:owning_faction();
	local region_owning_faction_name = region_owning_faction:name();
	local owning_faction_capital = region_owning_faction:home_region():name();
	local buildings_list = region:garrison_residence():buildings();
	local under_siege = region:garrison_residence():is_under_siege();
	local food_shortage = region_owning_faction:has_food_shortage();
	local black_death;

	if PLAGUE_PHASE and PLAGUE_PHASE ~= "DORMANT" and PLAGUE_PHASE ~= "ENDED" then
		if RegionHasPlague(region_name) then
			black_death = true;
		end
	end

	--dev.log("Owning faction name: "..region_owning_faction_name);
	--dev.log("Is under siege: "..tostring(under_siege));
	--dev.log("Has food shortage: "..tostring(food_shortage));

	POPULATION_REGIONS_GROWTH_FACTORS[region_name]= "";

	for i = 1, 5 do
		region_population = region_population + POPULATION_REGIONS_POPULATIONS[region_name][i];
	end

	--dev.log("Total population: "..tostring(region_population));

	for i = 0, buildings_list:num_items() - 1 do
		if POPULATION_BUILDINGS_TO_GROWTH[buildings_list:item_at(i):name()]  then
			for j = 1, 5 do
				growth[j] = growth[j] + POPULATION_BUILDINGS_TO_GROWTH[buildings_list:item_at(i):name()][j];
				--dev.log("Growth from buildings for class "..tostring(j)..": "..tostring(POPULATION_BUILDINGS_TO_GROWTH[buildings_list:item_at(i):name()][j]));
			end

			soft_cap = soft_cap + POPULATION_BUILDINGS_TO_GROWTH[buildings_list:item_at(i):name()][6];
			hard_cap = hard_cap + POPULATION_BUILDINGS_TO_GROWTH[buildings_list:item_at(i):name()][7];
		end
	end

	for i = 1, 5 do
		POPULATION_REGIONS_GROWTH_FACTORS[region_name] = POPULATION_REGIONS_GROWTH_FACTORS[region_name].."buildings_"..tostring(i).."#"..tostring(growth[i] * 100).."#@";
	end

	if POPULATION_FACTION_TRAITS_TO_GROWTH[region_owning_faction_name]  then
		for i = 1, 5 do
			if POPULATION_FACTION_TRAITS_TO_GROWTH[region_owning_faction_name][i] ~= 0 then
				growth[i] = growth[i] + POPULATION_FACTION_TRAITS_TO_GROWTH[region_owning_faction_name][i];
				POPULATION_REGIONS_GROWTH_FACTORS[region_name] = POPULATION_REGIONS_GROWTH_FACTORS[region_name].."faction_trait_"..tostring(i).."#"..tostring(POPULATION_FACTION_TRAITS_TO_GROWTH[region_owning_faction_name][i] * 100).."#@";
				--dev.log("Growth from faction trait for class "..tostring(i)..": "..tostring(POPULATION_FACTION_TRAITS_TO_GROWTH[region_owning_faction_name][i]));
			end
		end
	end

	if POPULATION_FACTION_TECH_BONUSES[region_owning_faction_name]  then
		for i = 1, 5 do
			if POPULATION_FACTION_TECH_BONUSES[region_owning_faction_name][i] ~= 0 then
				growth[i] = growth[i] + POPULATION_FACTION_TECH_BONUSES[region_owning_faction_name][i];
				POPULATION_REGIONS_GROWTH_FACTORS[region_name] = POPULATION_REGIONS_GROWTH_FACTORS[region_name].."technologies_"..tostring(i).."#"..tostring(POPULATION_FACTION_TECH_BONUSES[region_owning_faction_name][i] * 100).."#@";
				--dev.log("Growth from technologies for class "..tostring(i)..": "..tostring(POPULATION_FACTION_TECH_BONUSES[region_owning_faction_name][i]));
			end
		end
	end

	--dev.log("Soft Cap: "..tostring(soft_cap));
	--dev.log("Hard Cap: "..tostring(hard_cap));

	if region_population > hard_cap then
		growth_modifier = POPULATION_HARD_CAP_PERCENTAGE;
		--dev.log("Growth modifier from exceeding hard cap: "..tostring(growth_modifier));
		POPULATION_REGIONS_GROWTH_FACTORS[region_name] = POPULATION_REGIONS_GROWTH_FACTORS[region_name].."hard_cap_exceeded#"..tostring(100 - (100 * growth_modifier)).."#@";
	elseif region_population > soft_cap then 
		growth_modifier = POPULATION_SOFT_CAP_PERCENTAGE;
		--dev.log("Growth modifier from exceeding soft cap: "..tostring(growth_modifier));
		POPULATION_REGIONS_GROWTH_FACTORS[region_name] = POPULATION_REGIONS_GROWTH_FACTORS[region_name].."soft_cap_exceeded#"..tostring(100 - (100 * growth_modifier)).."#@";
	end
	
	local hre_decree = (mkHRE and mkHRE.active_decree == "hre_decree_lessen_tax_burdens");

	for i = 1, 5 do
		if owning_faction_capital == region_name then
			-- Exclude peasants and tribesmen.

			if i ~= 3 and i ~= 4 then
				--dev.log("Growth from region being capital for class "..tostring(i)..": "..tostring(POPULATION_CAPITAL_BONUS));
				growth[i] = growth[i] + POPULATION_CAPITAL_BONUS;
				POPULATION_REGIONS_GROWTH_FACTORS[region_name] = POPULATION_REGIONS_GROWTH_FACTORS[region_name].."capital_bonus_"..tostring(i).."#"..tostring(POPULATION_CAPITAL_BONUS * 100).."#@";
			end		
		end

		if hre_decree then
			if HasValue(mkHRE.factions, region_owning_faction_name) then
				if i == 2 or i == 3 then
					--dev.log("Growth from imperial decree for class "..tostring(i)..": "..tostring(POPULATION_IMPERIAL_DECREE_BONUS));
					growth[i] = growth[i] + POPULATION_IMPERIAL_DECREE_BONUS;
					POPULATION_REGIONS_GROWTH_FACTORS[region_name] = POPULATION_REGIONS_GROWTH_FACTORS[region_name].."imperial_decree_"..tostring(i).."#"..tostring(POPULATION_IMPERIAL_DECREE_BONUS * 100).."#@";
				end
			end
		end

		-- Apply soft/hard cap to positive growth.
		growth[i] = growth[i] * growth_modifier;

		-- Calculate growth penalties.

		if black_death then
			growth[i] = growth[i] - POPULATION_PLAGUE_POPULATION_LOSS;
		end

		if under_siege == true then
			growth[i] = growth[i] - POPULATION_SIEGE_POPULATION_LOSS;
		end

		if food_shortage == true then
			growth[i] = growth[i] - POPULATION_FOOD_SHORTAGE_POPULATION_LOSS;
		end
	end

	--dev.log("Checking for additional modifiers such as siege, food shortage, and raiding.");

	if black_death then
		POPULATION_REGIONS_GROWTH_FACTORS[region_name] = POPULATION_REGIONS_GROWTH_FACTORS[region_name].."black_death#"..tostring(POPULATION_PLAGUE_POPULATION_LOSS * 100).."#@";
	end

	if under_siege == true then
		POPULATION_REGIONS_GROWTH_FACTORS[region_name] = POPULATION_REGIONS_GROWTH_FACTORS[region_name].."under_siege#"..tostring(POPULATION_SIEGE_POPULATION_LOSS * 100).."#@";
	end

	if food_shortage == true then
		POPULATION_REGIONS_GROWTH_FACTORS[region_name] = POPULATION_REGIONS_GROWTH_FACTORS[region_name].."food_shortage#"..tostring(POPULATION_FOOD_SHORTAGE_POPULATION_LOSS * 100).."#@";
	end

	for k, v in pairs(POPULATION_REGIONS_CHARACTERS_RAIDING) do
		if v == region_name then
			--dev.log("Region being raided!");

			for j = 1, 5 do
				--dev.log("Negative growth from raiding for class "..tostring(i)..": "..tostring(-POPULATION_RAIDING_POPULATION_LOSS));
				growth[j] = growth[j] - POPULATION_RAIDING_POPULATION_LOSS;
			end

			POPULATION_REGIONS_GROWTH_FACTORS[region_name] = POPULATION_REGIONS_GROWTH_FACTORS[region_name].."region_raided#"..tostring(POPULATION_RAIDING_POPULATION_LOSS * 100).."#@";
		end
	end

	cm:apply_effect_bundle_to_region("mk_bundle_population_bundle_region", region:name(), 0); -- Re-apply this effect bundle in case it gets removed somehow (i.e. through occupation).

	--dev.log("Growth calculation complete.");

	return growth;
end

function Apply_Region_Growth_Factionwide(faction)
	local regions = faction:region_list();

	for i = 0, regions:num_items() - 1 do
		local region = regions:item_at(i);
		local region_name = region:name();
		local region_population = POPULATION_REGIONS_POPULATIONS[region_name];
		local region_manpower = POPULATION_REGIONS_MANPOWER[region_name];
		local region_growth_rates = Compute_Region_Growth(region);

		for j = 1, 5 do
			-- Population

			if region_population[j] == 0 then
				if region_growth_rates[j] > 0 then
					POPULATION_REGIONS_POPULATIONS[region_name][j] = 1;
				end
			else
				POPULATION_REGIONS_POPULATIONS[region_name][j] = region_population[j] + math.ceil(region_population[j] * region_growth_rates[j]);
			end

			if region_population[j] < 0 then
				POPULATION_REGIONS_POPULATIONS[region_name][j] = 0;
			end

			-- Manpower

			if  region_manpower[j] == 0 then
				if region_growth_rates[j] > 0 then
					POPULATION_REGIONS_MANPOWER[region_name][j] = 1;
				end
			else
				if region_manpower[j] < math.ceil(POPULATION_REGIONS_POPULATIONS[region_name][j] * POPULATION_MANPOWER_PERCENTAGE) then
					-- Manpower is lower than the ratio of population to manpower is supposed to be, so boost its growth!
					local manpower_growth = region_manpower[j] + math.ceil(region_manpower[j] * region_growth_rates[j]);
					POPULATION_REGIONS_MANPOWER[region_name][j] = manpower_growth + math.ceil(region_manpower[j] * POPULATION_MANPOWER_REGENERATION_RATE);

					-- Check to see if we accidentally went over the ratio.
					if POPULATION_REGIONS_MANPOWER[region_name][j] > math.ceil(POPULATION_REGIONS_POPULATIONS[region_name][j] * POPULATION_MANPOWER_PERCENTAGE) then
						-- If so, set it to the exact ratio.
						POPULATION_REGIONS_MANPOWER[region_name][j] = math.ceil(POPULATION_REGIONS_POPULATIONS[region_name][j] * POPULATION_MANPOWER_PERCENTAGE);
					end
				elseif region_manpower[j] > math.ceil((POPULATION_REGIONS_POPULATIONS[region_name][j] * POPULATION_MANPOWER_PERCENTAGE) * POPULATION_MANPOWER_SOFT_CAP) then
					-- Manpower somehow exceeds the ratio of population to manpower and its soft cap, so it's time to slow down manpower growth to equalize the ratio somewhat.
					local manpower_growth = region_manpower[j] + math.ceil(region_manpower[j] * region_growth_rates[j]);
					POPULATION_REGIONS_MANPOWER[region_name][j] = manpower_growth - math.ceil(region_manpower[j] * POPULATION_MANPOWER_DEGENERATION_RATE);
				else
					POPULATION_REGIONS_MANPOWER[region_name][j] = region_manpower[j] + math.floor(region_manpower[j] * region_growth_rates[j]);
				end
			end

			if POPULATION_REGIONS_MANPOWER[region_name][j] > POPULATION_REGIONS_POPULATIONS[region_name][j] then
				POPULATION_REGIONS_MANPOWER[region_name][j] = POPULATION_REGIONS_POPULATIONS[region_name][j];
			end

			if POPULATION_REGIONS_MANPOWER[region_name][j] < 0 then
				POPULATION_REGIONS_MANPOWER[region_name][j] = 0;
			end
		end

		POPULATION_REGIONS_GROWTH_RATES[region_name] = region_growth_rates;
	end

	Update_Faction_Total_Population(faction);
end

function Update_Faction_Total_Population(faction)
	local total = 0;

	if not faction:is_horde() then
		local regions = faction:region_list();

		if regions:num_items() > 0 then
			for i = 0, regions:num_items() - 1 do
				local region = regions:item_at(i);
				local region_population = 0;

				for i = 1, 5 do
					region_population = region_population + POPULATION_REGIONS_POPULATIONS[region:name()][i];
				end

				if IRONMAN_ENABLED then
					if region_population > 1000000 then
						Unlock_Achievement("achievement_megalopolis");
					end
				end

				total = total + region_population;
			end
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

	if POPULATION_REGIONS_POPULATIONS[region_name][class] < 0 then
		POPULATION_REGIONS_POPULATIONS[region_name][class] = 0;
	end
end

function Change_Manpower_Region(region_name, class, amount)
	POPULATION_REGIONS_MANPOWER[region_name][class] = POPULATION_REGIONS_MANPOWER[region_name][class] + amount;

	if POPULATION_REGIONS_MANPOWER[region_name][class] < 0 then
		POPULATION_REGIONS_MANPOWER[region_name][class] = 0;
	end

	Change_Population_Region(region_name, class, amount);
end

function Check_Technologies_Population(faction_name)
	local faction = cm:model():world():faction_by_key(faction_name);

	if POPULATION_FACTION_TECH_BONUSES[faction_name] == nil then
		POPULATION_FACTION_TECH_BONUSES[faction_name] = {};
	end

	if POPULATION_FACTION_TECH_RESEARCHED[faction_name] == nil then
		POPULATION_FACTION_TECH_RESEARCHED[faction_name] = {};
	end

	for k, v in pairs(POPULATION_TECHNOLOGIES_TO_GROWTH) do
		if not HasValue(POPULATION_FACTION_TECH_RESEARCHED[faction_name], k) then
			if faction:has_technology(k) then
				for i = 1, 5 do
					POPULATION_FACTION_TECH_BONUSES[faction_name][i] = POPULATION_FACTION_TECH_BONUSES[faction_name][i] + v[i];
				end

				table.insert(POPULATION_FACTION_TECH_RESEARCHED[faction_name], k);

				Refresh_Region_Growths_Population(false);
			end
		end
	end
end

function Refresh_Region_Growths_Population(global)
	if global == true then
		local faction_list = cm:model():world():faction_list();

		for i = 0, faction_list:num_items() - 1 do
			local current_faction = faction_list:item_at(i);

			if current_faction:region_list():num_items() > 0 then
				local regions = current_faction:region_list();

				for j = 0, regions:num_items() - 1 do
					local region = regions:item_at(j);

					POPULATION_REGIONS_GROWTH_RATES[region:name()] = Compute_Region_Growth(region);
				end
			end
		end
	else
		local faction = cm:model():world():faction_by_key(FACTION_TURN);

		if faction:region_list():num_items() > 0 then
			local regions = faction:region_list();

			for j = 0, regions:num_items() - 1 do
				local region = regions:item_at(j);

				POPULATION_REGIONS_GROWTH_RATES[region:name()] = Compute_Region_Growth(region);
			end
		end
	end
end

------------------------------------------------
---------------- Saving/Loading ----------------
------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		SavePopulationNumbersTable(context, POPULATION_REGIONS_POPULATIONS, "POPULATION_REGIONS_POPULATIONS");
		SavePopulationNumbersTable(context, POPULATION_REGIONS_MANPOWER, "POPULATION_REGIONS_MANPOWER");
		SavePopulationNumbersTable(context, POPULATION_REGIONS_GROWTH_RATES, "POPULATION_REGIONS_GROWTH_RATES");
		SavePopulationNumbersTable(context, POPULATION_FACTION_TECH_BONUSES, "POPULATION_FACTION_TECH_BONUSES");
		SaveFactionPopulationNumbersTable(context, POPULATION_FACTION_TOTAL_POPULATIONS, "POPULATION_FACTION_TOTAL_POPULATIONS");
		SaveKeyPairTable(context, POPULATION_REGIONS_GROWTH_FACTORS, "POPULATION_REGIONS_GROWTH_FACTORS");
		SaveKeyPairTable(context, POPULATION_REGIONS_CHARACTERS_RAIDING, "POPULATION_REGIONS_CHARACTERS_RAIDING");
		SaveKeyPairTables(context, POPULATION_FACTION_TECH_RESEARCHED, "POPULATION_FACTION_TECH_RESEARCHED");
		SaveKeyPairTables(context, POPULATION_UNITS_IN_RECRUITMENT, "POPULATION_UNITS_IN_RECRUITMENT");
	end
);

cm:register_loading_game_callback(
	function(context)
		POPULATION_REGIONS_POPULATIONS = LoadPopulationNumbersTable(context, "POPULATION_REGIONS_POPULATIONS");
		POPULATION_REGIONS_MANPOWER = LoadPopulationNumbersTable(context, "POPULATION_REGIONS_MANPOWER");
		POPULATION_REGIONS_GROWTH_RATES = LoadPopulationNumbersTable(context, "POPULATION_REGIONS_GROWTH_RATES");
		POPULATION_FACTION_TECH_BONUSES = LoadPopulationNumbersTable(context, "POPULATION_FACTION_TECH_BONUSES");
		POPULATION_FACTION_TOTAL_POPULATIONS = LoadFactionPopulationNumbersTable(context, "POPULATION_FACTION_TOTAL_POPULATIONS");
		POPULATION_REGIONS_GROWTH_FACTORS = LoadKeyPairTable(context, "POPULATION_REGIONS_GROWTH_FACTORS");
		POPULATION_REGIONS_CHARACTERS_RAIDING = LoadKeyPairTable(context, "POPULATION_REGIONS_CHARACTERS_RAIDING");
		POPULATION_FACTION_TECH_RESEARCHED = LoadKeyPairTables(context, "POPULATION_FACTION_TECH_RESEARCHED");
		POPULATION_UNITS_IN_RECRUITMENT = LoadKeyPairTables(context, "POPULATION_UNITS_IN_RECRUITMENT");
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
