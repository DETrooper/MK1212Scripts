-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - IRONMAN: ACHIEVEMENTS
-- 	By: DETrooper
--
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

require("ironman/ironman_achievements_ui");

local dev = require("lua_scripts.dev");
local util = require("lua_scripts.util");

ACHIEVEMENTS = {};
ACHIEVEMENT_KEY_LIST = {
	"achievement_all_the_worlds_a_stage",
	"achievement_an_early_union",
	"achievement_basileia_rhomaion",
	"achievement_crusader_king",
	"achievement_dont_mind_if_i_do",
	"achievement_ibadi",
	"achievement_its_only_human_to_sin",
	"achievement_king_of_kings",
	"achievement_kingdom_of_david",
	"achievement_north_sea_empire",
	"achievement_pays_cathare",
	"achievement_prester_john",
	"achievement_renovatio_imperii",
	"achievement_rise_of_the_republic",
	"achievement_sorry_we_forgot_something",
	"achievement_survivor",
	"achievement_the_caliphate_strikes_back",
	"achievement_the_lion_of_the_north",
	"achievement_the_price_revolution",
	"achievement_the_re-reconquista",
	"achievement_the_spice_must_flow",
	"achievement_there_can_only_be_one",
	"achievement_tri_moreta",
	"achievement_world_conquest"
};

function Add_Ironman_Achievement_Listeners()
	if IRONMAN_ENABLED then
		cm:add_listener(
			"FactionTurnStart_Achievement_Check",
			"FactionTurnStart",
			true,
			function(context) FactionTurnStart_Achievement_Check(context) end,
			true
		);
	end

	if util.fileExists("MK1212_achievements.txt") ~= true then
		dev.writeAchievements("MK1212_achievements.txt", ACHIEVEMENT_KEY_LIST);
	end

	local achievement_list = dev.readAchievements("MK1212_achievements.txt");

	for i = 1, #ACHIEVEMENT_KEY_LIST do
		local achievement_key = ACHIEVEMENT_KEY_LIST[i];

		ACHIEVEMENTS[achievement_key] = require("ironman/achievements/"..achievement_key);

		if achievement_list[achievement_key] then
			if achievement_list[achievement_key][1] == "1" then
				ACHIEVEMENTS[achievement_key].unlocked = true;
			else
				ACHIEVEMENTS[achievement_key].unlocked = false;
			end
	
			ACHIEVEMENTS[achievement_key].unlocktime = string.sub(achievement_list[achievement_key][2], 1, 8).." "..string.sub(achievement_list[achievement_key][2], 9, 16); -- Create a space between the date and time.
		else
			-- Achievement not found in file!
			dev.changeAchievement("MK1212_achievements.txt", achievement_key, "0", "n.d.");
		end
	end

	Add_Ironman_Achievement_UI_Listeners();
end

function FactionTurnStart_Achievement_Check(context)
	if context:faction():is_human() then
		local faction = context:faction();
		local faction_name = faction:name();
		local faction_region_list = faction:region_list();
		local faction_religion = faction:state_religion();
		
		for i = 1, #ACHIEVEMENT_KEY_LIST do
			local achievement_key = ACHIEVEMENT_KEY_LIST[i];

			if ACHIEVEMENTS[achievement_key] then
				local achievement = ACHIEVEMENTS[achievement_key];

				-- Some achievements are manually triggered, such as when a decision is made, so we should disqualify them from automatically triggering.
				if achievement.unlocked == false and achievement.manual == false then
					local has_required_buildings = true;
					local has_required_buildings_in_regions = true;
					local has_required_regions = true;
					local has_required_technologies = true;
					local has_required_vassals = true;
					local is_required_faction = true;
					local is_required_religion = true;
					local sacked_settlements = true;
					local target_factions_dead = true;

					if achievement.requiredbuildings then
						if achievement.requirednumbuildings then
							local num_buildings = 0;

							for i = 0, faction_region_list:num_items() - 1 do
								local region = faction_region_list:item_at(i);
								local buildings_list = region:garrison_residence():buildings();
								
								for j = 0, buildings_list:num_items() - 1 do
									if HasValue(achievement.requiredbuildings, buildings_list:item_at(j):name()) then
										num_buildings = num_buildings + 1;
									end
								end
							end

							if num_buildings < achievement.requirednumbuildings then
								has_required_buildings = false;
							end
						elseif achievement.requiredregionsforbuildings then
							for i = 1, #achievement.requiredregionsforbuildings do
								local region = cm:model():world():region_manager():region_by_key(achievement.requiredregionsforbuildings[i]);
								local buildings_list = region:garrison_residence():buildings();
								
								for j = 0, buildings_list:num_items() - 1 do
									if not HasValue(achievement.requiredbuildings, buildings_list:item_at(j):name()) then
										has_required_buildings_in_regions = false;
										break;
									end
								end
							end
						end
					end

					if achievement.requiredfactions then
						if not HasValue(achievement.requiredfactions, faction_name) then
							is_required_faction = false;
						end
					end

					if achievement.requiredtechnologies then
						if achievement.requiredtechnologies == "all" then
							local has_all_techs = false;

							for i = 1, #MAX_TECHS do
								for j = 1, #MAX_TECHS[i] do
									if faction:has_technology(MAX_TECHS[i][j]) == true then
										has_all_techs = true;
									elseif faction:has_technology(MAX_TECHS[i][j]) == false and has_all_techs == true then
										has_all_techs = false;
										break;
									end
								end
							end

							has_required_technologies = has_all_techs;
						else
							for i = 1, #achievement.requiredtechnologies do
								if faction:has_technology(achievement.requiredtechnologies[i]) == false then
									has_required_technologies = false;
									break;
								end
							end
						end
					end

					if achievement.requiredregions then
						if not Has_Required_Regions(faction_name, achievement.requiredregions) then
							has_required_regions = false;
						end
					end

					if achievement.requiredreligions then
						local has_required_religion = false;

						for i = 1, #achievement.requiredreligions do
							if faction_religion == achievement.requiredreligions[i] then
								has_required_religion = true;
								break;
							end
						end

						is_required_religion = has_required_religion;
					end

					if achievement.sacksettlements then
						for i = 1, #achievement.sacksettlements do
							if not HasValue(SACKED_SETTLEMENTS_TOTAL[faction_name], achievement.sacksettlements[i]) then
								sacked_settlements = false;
								break;
							end
						end
					end

					if achievement.requireddeadfactions then
						for i = 1, #achievement.requireddeadfactions do
							if FactionIsAlive(achievement.requireddeadfactions[i]) then
								target_factions_dead = false;
								break;
							end
						end
					end

					if achievement.requiredvassals then
						if FACTIONS_TO_FACTIONS_VASSALIZED[faction_name] then
							for i = 1, #achievement.requiredvassals do
								if not HasValue(FACTIONS_TO_FACTIONS_VASSALIZED[faction_name], achievement.requiredvassals[i]) then
									has_required_vassals = false;
									break;
								end
							end
						else
							has_required_vassals = false;
						end
					end

					if has_required_buildings == true and has_required_buildings_in_regions == true and has_required_regions == true 
					and has_required_technologies == true and is_required_faction == true and is_required_religion == true 
					and sacked_settlements == true and target_factions_dead == true and has_required_vassals == true then
						Unlock_Achievement(achievement_key);
					end
				end
			end
		end
	end
end

function Check_Achievement_Unlocked(achievement_key)
	return ACHIEVEMENTS[achievement_key].unlocked;
end

function Unlock_Achievement(achievement_key)
	if ACHIEVEMENTS[achievement_key].unlocked ~= true then
		local unlock_time = os.date("%c");

		if not util.fileExists("MK1212_achievements.txt") then
			dev.writeAchievements("MK1212_achievements.txt", ACHIEVEMENT_KEY_LIST);
		end

		dev.changeAchievement("MK1212_achievements.txt", achievement_key, 1, unlock_time);

		ACHIEVEMENTS[achievement_key].unlocked = true;
		ACHIEVEMENTS[achievement_key].unlocktime = unlock_time;

		Display_Achievement_Unlocked_UI(achievement_key);
	end
end
