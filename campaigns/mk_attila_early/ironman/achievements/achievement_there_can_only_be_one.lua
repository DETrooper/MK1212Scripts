-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - IRONMAN: ACHIEVEMENT - THERE CAN ONLY BE ONE
-- 	By: DETrooper
--
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

local achievement = {};

achievement.name = "There Can Only Be One";
achievement.description = "As the Byzantine Empire (the Empire of Epirus, Nicaea, and Trebizond), Latin Empire, or Holy Roman Empire, ensure that all rival claimants to the title of Roman Emperor are destroyed.";
achievement.manual = false; -- Is unlocked during achievement turn start check.
achievement.requireddeadfactions = {"mk_fact_epirus", "mk_fact_hre", "mk_fact_latinempire", "mk_fact_nicaea", "mk_fact_trebizond"}; -- These factions need to be destroyed (not counting if player is one of them).
achievement.requiredfactions = {"mk_fact_epirus", "mk_fact_hre", "mk_fact_latinempire", "mk_fact_nicaea", "mk_fact_trebizond"}; -- The player must be one of these factions.
achievement.unlocked = false;
achievement.unlocktime = "";

return achievement;
