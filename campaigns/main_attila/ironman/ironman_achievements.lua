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
	"achievement_basileia_rhomaion",
	"achievement_ibadi",
	"achievement_king_of_kings",
	"achievement_renovatio_imperii",
	"achievement_survivor",
	"achievement_the_caliphate_strikes_back",
	"achievement_there_can_only_be_one"
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
end

function FactionTurnStart_Achievement_Check(context)
	if context:faction():is_human() then
		local faction_name = context:faction():name();
		local faction_religion = context:faction():state_religion();
		
		for i = 1, #ACHIEVEMENT_KEY_LIST do
			local achievement_key = ACHIEVEMENT_KEY_LIST[i];

			if ACHIEVEMENTS[achievement_key] then
				-- Some achievements are manually triggered, such as when a decision is made, so we should disqualify them from automatically triggering.
				if ACHIEVEMENTS[achievement_key].manual == false then
					local has_required_regions = true;
					local is_required_faction = true;
					local is_required_religion = true;
					local target_factions_dead = true;

					if ACHIEVEMENTS[achievement_key].requiredfactions then
						if not HasValue(ACHIEVEMENTS[achievement_key].requiredfactions, faction_name) then
							is_required_faction = false;
						end
					end

					if ACHIEVEMENTS[achievement_key].requiredtechnologies then
						if not HasValue(ACHIEVEMENTS[achievement_key].requiredtechnologies, faction_religion) then
							is_required_religion = false;
						end
					end

					if ACHIEVEMENTS[achievement_key].requiredregions then
						if not Has_Required_Regions(faction_name, ACHIEVEMENTS[achievement_key].requiredregions) then
							has_required_regions = false;
						end
					end

					if ACHIEVEMENTS[achievement_key].requireddeadfactions then
						for i = 1, #ACHIEVEMENTS[achievement_key].requireddeadfactions do
							if FactionIsAlive(ACHIEVEMENTS[achievement_key].requireddeadfactions[i]) then
								target_factions_dead = false;
								break;
							end
						end
					end

					if has_required_regions == true and is_required_faction == true and is_required_religion == true and target_factions_dead == true then
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
		Update_Achievement_Menu_UI();
	end
end
