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
ACHIEVEMENT_KEY_LIST = {"achievement_basileia_rhomaion", "achievement_renovatio_imperii"};

function Add_Ironman_Achievement_Listeners()
	if IRONMAN_ENABLED == true then
		for i = 1, #ACHIEVEMENT_KEY_LIST do
			local achievement_key = ACHIEVEMENT_KEY_LIST[i];
			ACHIEVEMENTS[achievement_key] = require("ironman/achievements/"..achievement_key);
		end

		if util.fileExists("MK1212_achievements.txt") ~= true then
			dev.writeAchievements("MK1212_achievements.txt", ACHIEVEMENT_KEY_LIST);
		end

		local achievement_list = dev.readSettings("MK1212_achievements.txt");

		for k, v in pairs(achievement_list) do
			if v == 1 then
				ACHIEVEMENTS[k].unlocked = true;
			else
				ACHIEVEMENTS[k].unlocked = false;
			end
		end

		Add_Ironman_Achievement_UI_Listeners();
	end
end

function Check_Achievement_Unlocked(achievement_key)
	return ACHIEVEMENTS[achievement_key].unlocked;
end

function Unlock_Achievement(achievement_key)
	if ACHIEVEMENTS[achievement_key].unlocked == false then
		if util.fileExists("MK1212_achievements.txt") == true then
			local achievement_list = dev.readSettings("MK1212_achievements.txt");

			if tonumber(achievement_list[achievement_key]) == 0 then
				dev.changeAchievement("MK1212_achievements.txt", achievement_key, 1);
			end
		else
			dev.writeAchievements("MK1212_achievements.txt", ACHIEVEMENT_KEY_LIST);
			dev.changeAchievement("MK1212_achievements.txt", achievement_key, 1);
		end

		ACHIEVEMENTS[achievement_key].unlocked = true;

		Display_Achievement_Unlocked_UI(achievement_key);
	end
end
