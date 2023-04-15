-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - IRONMAN: ACHIEVEMENT - IBADI
-- 	By: DETrooper
--
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

local achievement = {};

achievement.name = "iBadi";
achievement.description = "Research all technologies while being of the Ibadi Islam religion.";
achievement.manual = false; -- Is unlocked during achievement turn start check.
achievement.requiredreligions = {"mk_rel_ibadi_islam"}; -- The player must be one of these religions.
achievement.requiredtechnologies = "all";
achievement.unlocked = false;
achievement.unlocktime = "";

return achievement;
