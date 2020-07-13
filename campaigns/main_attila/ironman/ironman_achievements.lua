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
	"achievement_king_of_kings",
	"achievement_renovatio_imperii",
	"achievement_survivor",
	"achievement_the_caliphate_strikes_back",
	"achievement_there_can_only_be_one"
};

function Add_Ironman_Achievement_Listeners()
	if IRONMAN_ENABLED then
		for i = 1, #ACHIEVEMENT_KEY_LIST do
			local achievement_key = ACHIEVEMENT_KEY_LIST[i];
			ACHIEVEMENTS[achievement_key] = require("ironman/achievements/"..achievement_key);
		end

		if util.fileExists("MK1212_achievements.txt") ~= true then
			dev.writeAchievements("MK1212_achievements.txt", ACHIEVEMENT_KEY_LIST);
		end

		local achievement_list = dev.readAchievements("MK1212_achievements.txt");

		for k, v in pairs(achievement_list) do
			if v[1] == "1" then
				ACHIEVEMENTS[k].unlocked = true;
			else
				ACHIEVEMENTS[k].unlocked = false;
			end

			ACHIEVEMENTS[k].unlocktime = string.sub(v[2], 1, 8).." "..string.sub(v[2], 9, 16); -- Create a space between the date and time.
		end

		Add_Ironman_Achievement_UI_Listeners();
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
