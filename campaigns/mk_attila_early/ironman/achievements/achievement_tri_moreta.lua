-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - IRONMAN: ACHIEVEMENT - TRI MORETA
-- 	By: DETrooper
--
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

local achievement = {};

achievement.name = "Tri Moreta";
achievement.description = "As the Tsardom of Bulgaria, reconquer the old borders of the First Bulgarian Empire.";
achievement.manual = false; -- Is unlocked during achievement turn start check.
achievement.requiredfactions = {"mk_fact_bulgaria"}; -- The player must be one of these factions.
achievement.requiredregions = {  -- Regions required for this achievement to unlock.
	"mk_reg_arta",
	"mk_reg_belgrade",
	"mk_reg_nis",
	"mk_reg_philippopolis",
	"mk_reg_ras",
	"mk_reg_scopie",
	"mk_reg_sredets",
	"mk_reg_tarnovo",
	"mk_reg_thessalonica",
	"mk_reg_varna"
};
achievement.unlocked = false;
achievement.unlocktime = "";

return achievement;
