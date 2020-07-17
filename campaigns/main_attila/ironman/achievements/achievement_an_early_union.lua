-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - IRONMAN: ACHIEVEMENT - AN EARLY UNION
-- 	By: DETrooper
--
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

local achievement = {};

achievement.name = "An Early Union";
achievement.description = "As the Kingdom of Poland, have the Grand Duchy of Lithuania as a vassal.";
achievement.manual = false; -- Is unlocked during achievement turn start check.
achievement.requiredfactions = {"mk_fact_lesserpoland"}; -- The player must be one of these factions.
achievement.requiredvassals = {"mk_fact_lithuania"}; -- The player must have these factions as vassals.
achievement.unlocked = false;
achievement.unlocktime = "";

return achievement;
