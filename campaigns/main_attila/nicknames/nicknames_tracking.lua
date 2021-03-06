-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - NICKNAMES: TRACKING
-- 	By: DETrooper
--
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------

CHARACTERS_TO_NICKNAMES = {};
CHARACTERS_TO_NICKNAME_STATS = {};

function Add_Nicknames_Tracking_Listeners()
	cm:add_listener(
		"FactionTurnStart_Nicknames",
		"FactionTurnStart",
		true,
		function(context) FactionTurnStart_Nicknames(context) end,
		true
	);
	cm:add_listener(
		"BattleCompleted_Nicknames",
		"BattleCompleted",
		true,
		function(context) BattleCompleted_Nicknames(context) end,
		true
	);
	cm:add_listener(
		"CharacterPerformsOccupationDecisionLoot_Nicknames",
		"CharacterPerformsOccupationDecisionLoot",
		true,
		function(context) CharacterPerformsOccupationDecision_Nicknames(context) end,
		true
	);
	cm:add_listener(
		"CharacterPerformsOccupationDecisionOccupy_Nicknames",
		"CharacterPerformsOccupationDecisionOccupy",
		true,
		function(context) CharacterPerformsOccupationDecision_Nicknames(context) end,
		true
	);
	cm:add_listener(
		"CharacterPostBattleSlaughter_Nicknames",
		"CharacterPostBattleSlaughter",
		true,
		function(context) CharacterPostBattle_Nicknames(context, "SLAUGHTER") end,
		true
	);
	cm:add_listener(
		"FactionReligionConverted_Nicknames",
		"FactionReligionConverted",
		true,
		function(context) FactionReligionConverted_Nicknames(context) end,
		true
	);
	cm:add_listener(
		"RegionRebels_Nicknames",
		"RegionRebels",
		true,
		function(context) RegionRebels_Nicknames(context) end,
		true
	);

	if cm:is_new_game() then
		for k, v in pairs(HISTORICAL_CHARACTERS_TO_NICKNAMES) do
			if string.find(k, "mk_fact_") then
				local faction = cm:model():world():faction_by_key(faction_name);

				if not faction:is_null_interface() then
					local cqi = faction:faction_leader():cqi();

					Add_Character_Nickname(cqi, v, true);
				end
			elseif tonumber(k) then
				Add_Character_Nickname(tonumber(k), v, true);
			end
		end

		local faction_list = cm:model():world():faction_list();

		for i = 0, faction_list:num_items() - 1 do
			local faction = faction_list:item_at(i);
			local character_list = faction:character_list();
	
			for j = 0, character_list:num_items() - 1 do
				local character = character_list:item_at(j);
		
				Check_Character_Nickname(character);
			end
		end
	end
end

function FactionTurnStart_Nicknames(context)
	local faction = context:faction();
	local character_list = faction:character_list();
	
	for i = 0, character_list:num_items() - 1 do
		local character = character_list:item_at(i);

		Check_Character_Nickname(character);
	end
end

function BattleCompleted_Nicknames(context)
	local attacker_result = cm:model():pending_battle():attacker_battle_result();
	local defender_result = cm:model():pending_battle():defender_battle_result();
	
	if attacker_result == "close_defeat" and defender_result == "close_defeat" then
		-- They've both had a close defeat, must have been a retreat not a battle!
		return;
	elseif attacker_result == nil or defender_result == nil then
		return;
	end

	local attacker_cqi, attacker_force_cqi, attacker_name = cm:pending_battle_cache_get_attacker(1);
	local defender_cqi, defender_force_cqi, defender_name = cm:pending_battle_cache_get_defender(1);
	local attacker = cm:model():world():faction_by_key(attacker_name);
	local defender = cm:model():world():faction_by_key(defender_name);
	
	if attacker:is_null_interface() == false then
		if attacker_result == "heroic_victory" then
			Increase_Character_Nickname_Stat(attacker_cqi, "heroic_victories", 1);
		end
	end
	
	if defender:is_null_interface() == false then
		if defender_result == "heroic_victory" then
			Increase_Character_Nickname_Stat(defender_cqi, "heroic_victories", 1);
		end
	end
end

function CharacterPerformsOccupationDecision_Nicknames(context)
	Increase_Character_Nickname_Stat(context:character():cqi(), "regions_taken", 1);
end

function CharacterPostBattle_Nicknames(context, type)
	if type == "SLAUGHTER" then
		Increase_Character_Nickname_Stat(context:character():cqi(), "captives_killed", 1);
	end
end

function FactionReligionConverted_Nicknames(context)
	local faction_leader = context:faction():faction_leader();

	if faction_leader then
		local state_religion = context:faction():state_religion();

		Add_Character_Nickname(faction_leader:cqi(), RELIGIONS_TO_NICKNAMES[state_religion], false);
	end
end

function RegionRebels_Nicknames(context)
	local region_owning_faction_leader = context:region():owning_faction():faction_leader();

	if region_owning_faction_leader then
		Set_Character_Nickname_Stat(region_owning_faction_leader:cqi(), "turns_without_revolt", 0);
	end
end

function Check_Character_Nickname(character)
	-- For now only generals will have nicknames, since most nicknames only really concern them.
	if character:character_type("general") then
		--dev.log("Checking character "..tostring(character:cqi()).." for faction "..character:faction():name());
		local age = character:age();
		local cqi = character:cqi();
		local cqi_str = tostring(cqi);

		if age >= 90 then
			Add_Character_Nickname(cqi, "the_undying", false);
		elseif age >= 65 then
			Add_Character_Nickname(cqi, "the_old", false);
		end

		for trait, nickname in pairs(TRAITS_TO_NICKNAMES) do
			if character:has_trait(trait) then
				-- Make sure the character actually has the trait and it isn't just invisible.
				if character:trait_points(trait) >= 4 then
					-- 100% chance past this threshold (4 points is generally level 2 trait).
					Add_Character_Nickname(cqi, nickname, false);
				elseif character:trait_points(trait) >= 2 then
					if cm:random_number(10, 1) == 1 then
						Add_Character_Nickname(cqi, nickname, false);
					end
				end
			end
		end

		Validate_Characker_Nickname_Stats(cqi_str);

		if character:is_faction_leader() then
			local faction_region_list = character:faction():region_list();

			if faction_region_list:num_items() > 4 then
				CHARACTERS_TO_NICKNAME_STATS[cqi_str].turns_without_revolt = CHARACTERS_TO_NICKNAME_STATS[cqi_str].turns_without_revolt + 1;
			end
		end

		if CHARACTERS_TO_NICKNAME_STATS[cqi_str].regions_taken >= 25 then
			Add_Character_Nickname(cqi, "the_great", false);
		elseif CHARACTERS_TO_NICKNAME_STATS[cqi_str].regions_taken >= 10 then
			Add_Character_Nickname(cqi, "the_conqueror", false);
		end

		if CHARACTERS_TO_NICKNAME_STATS[cqi_str].captives_killed >= 15 then
			Add_Character_Nickname(cqi, "the_merciless", false);
		elseif CHARACTERS_TO_NICKNAME_STATS[cqi_str].captives_killed >= 5 then
			Add_Character_Nickname(cqi, "the_cruel", false);
		end

		if CHARACTERS_TO_NICKNAME_STATS[cqi_str].times_excommunicated >= 2 then
			Add_Character_Nickname(cqi, "the_wicked", false);
		end

		if CHARACTERS_TO_NICKNAME_STATS[cqi_str].turns_without_revolt >= 40 then
			Add_Character_Nickname(cqi, "the_fair", false);
		end

		if CHARACTERS_TO_NICKNAME_STATS[cqi_str].heroic_victories >= 5 then
			Add_Character_Nickname(cqi, "the_hero", false);
		end

		if character:offensive_ambush_battles_won() >= 5 then
			Add_Character_Nickname(cqi, "the_bold", false);
		end

		if character:battles_won() >= 25 then
			if character:battles_won() == character:battles_fought() then
				Add_Character_Nickname(cqi, "the_undefeated", true);
			else
				Add_Character_Nickname(cqi, "the_victorious", false);
			end
		end
	end
end

function Decrease_Character_Nickname_Stat(cqi, stat, amount)
	local cqi_str = tostring(cqi);
	--dev.log("Decreasing char nickname stat "..stat.." for "..cqi_str.." for faction "..character:faction():name());

	Validate_Characker_Nickname_Stats(cqi_str);

	CHARACTERS_TO_NICKNAME_STATS[cqi_str][stat] = CHARACTERS_TO_NICKNAME_STATS[cqi_str][stat] - amount;

	if CHARACTERS_TO_NICKNAME_STATS[cqi_str][stat] < 0 then
		CHARACTERS_TO_NICKNAME_STATS[cqi_str][stat] = 0;
	end
end

function Increase_Character_Nickname_Stat(cqi, stat, amount)
	local cqi_str = tostring(cqi);
	--dev.log("Increasing char nickname stat "..stat.." for "..cqi_str.." for faction "..character:faction():name());

	Validate_Characker_Nickname_Stats(cqi_str);

	CHARACTERS_TO_NICKNAME_STATS[cqi_str][stat] = CHARACTERS_TO_NICKNAME_STATS[cqi_str][stat] + amount;
end

function Set_Character_Nickname_Stat(cqi, stat, value)
	local cqi_str = tostring(cqi);
	--dev.log("Increasing char nickname stat "..stat.." for "..cqi_str.." for faction "..character:faction():name());

	Validate_Characker_Nickname_Stats(cqi_str);

	CHARACTERS_TO_NICKNAME_STATS[cqi_str][stat] = value;
end

function Validate_Characker_Nickname_Stats(cqi_str)
	if not CHARACTERS_TO_NICKNAME_STATS[cqi_str] then
		CHARACTERS_TO_NICKNAME_STATS[cqi_str] = {
			["regions_taken"] = 0,
			["captives_killed"] = 0,
			["times_excommunicated"] = 0,
			["turns_without_revolt"] = 0,
			["heroic_victories"] = 0,
		};
	end
end

------------------------------------------------
---------------- Saving/Loading ----------------
------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		SaveKeyPairTable(context, CHARACTERS_TO_NICKNAMES, "CHARACTERS_TO_NICKNAMES");
		SaveNicknamesStatsTable(context, CHARACTERS_TO_NICKNAME_STATS, "CHARACTERS_TO_NICKNAME_STATS");
	end
);

cm:register_loading_game_callback(
	function(context)
		CHARACTERS_TO_NICKNAMES = LoadKeyPairTable(context, "CHARACTERS_TO_NICKNAMES");
		CHARACTERS_TO_NICKNAME_STATS = LoadNicknamesStatsTable(context, "CHARACTERS_TO_NICKNAME_STATS");
	end
);

function SaveNicknamesStatsTable(context, tab, savename)
	local savestring = "";
	
	for cqi, tab2 in pairs(tab) do
		savestring = savestring..cqi..","..tostring(tab2["regions_taken"])..","..tostring(tab2["captives_killed"])..","..tostring(tab2["times_excommunicated"])..","..tostring(tab2["turns_without_revolt"])..","..tostring(tab2["heroic_victories"])..",;";
	end

	cm:save_value(savename, savestring, context);
end


function LoadNicknamesStatsTable(context, savename)
	local savestring = cm:load_value(savename, "", context);
	local tab = {};
	
	if savestring ~= "" then
		local first_split = SplitString(savestring, ";");

		for i = 1, #first_split do
			local second_split = SplitString(first_split[i], ",");

			local nickname_stats_table = {["regions_taken"] = tonumber(second_split[2]), ["captives_killed"] = tonumber(second_split[3]), ["times_excommunicated"] = tonumber(second_split[4]), ["turns_without_revolt"] = tonumber(second_split[5]), ["heroic_victories"] = tonumber(second_split[6])};
			tab[second_split[1]] = nickname_stats_table;
		end
	end

	return tab;
end
