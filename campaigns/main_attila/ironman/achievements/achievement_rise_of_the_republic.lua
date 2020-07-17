-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - IRONMAN: ACHIEVEMENT - RISE OF THE REPUBLIC
-- 	By: DETrooper
--
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

local achievement = {};

achievement.name = "Rise of the Republic";
achievement.description = "As a merchant republic (the Republic of Genoa, Pisa, or Venice), ensure that all rival merchant republics are destroyed.";
achievement.manual = false; -- Is unlocked during achievement turn start check.
achievement.requireddeadfactions = {"mk_fact_genoa", "mk_fact_pisa", "mk_fact_venice"}; -- These factions need to be destroyed (not counting if player is one of them).
achievement.requiredfactions = {"mk_fact_genoa", "mk_fact_pisa", "mk_fact_venice"}; -- The player must be one of these factions.
achievement.unlocked = false;
achievement.unlocktime = "";

return achievement;
