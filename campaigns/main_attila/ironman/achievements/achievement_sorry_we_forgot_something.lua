-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - IRONMAN: ACHIEVEMENT - SORRY WE FORGOT SOMETHING
-- 	By: DETrooper
--
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

local achievement = {};

achievement.name = "Sorry, We Forgot Something";
achievement.description = "As the Republic of Venice, sack or loot and occupy Constantinople.";
achievement.manual = false; -- Is unlocked during achievement turn start check.
achievement.requiredfactions = {"mk_fact_venice"}; -- The player must be one of these factions.
achievement.sacksettlements = {"att_reg_thracia_constantinopolis"}; -- The player must sack these settlements at least once.
achievement.unlocked = false;
achievement.unlocktime = "";

return achievement;
