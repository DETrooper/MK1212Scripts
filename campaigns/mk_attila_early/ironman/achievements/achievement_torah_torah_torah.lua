-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - IRONMAN: ACHIEVEMENT - TORAH! TORAH! TORAH!
-- 	By: DETrooper
--
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

local achievement = {};

achievement.name = "Torah! Torah! Torah!";
achievement.description = "As a Jewish faction, sack or loot and occupy Rome.";
achievement.manual = false; -- Is unlocked during achievement turn start check.
achievement.requiredreligions = {"att_rel_judaism"}; -- The player must be one of these religions.
achievement.sacksettlements = {"mk_reg_rome"}; -- The player must sack these settlements at least once.
achievement.unlocked = false;
achievement.unlocktime = "";

return achievement;
