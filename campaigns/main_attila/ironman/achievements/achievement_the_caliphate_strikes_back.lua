-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - IRONMAN: ACHIEVEMENT - THE CALIPHATE STRIKES BACK
-- 	By: DETrooper
--
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

local achievement = {};

achievement.name = "The Caliphate Strikes Back";
achievement.description = "As the Abbasid Caliphate, restore the borders of the Abbasid Caliphate at its height.";
achievement.manual = false; -- Is unlocked during achievement turn start check.
achievement.requiredregions = {}; -- Regions required for this achievement to unlock.
achievement.requiredfactions = {"mk_fact_abbasids"}; -- The player must be one of these factions.
achievement.unlocked = false;
achievement.unlocktime = "";

return achievement;
