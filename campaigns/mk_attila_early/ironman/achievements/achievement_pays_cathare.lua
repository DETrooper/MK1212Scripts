-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - IRONMAN: ACHIEVEMENT - PAYS CATHARE
-- 	By: DETrooper
--
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

local achievement = {};

achievement.name = "Pays Cathare";
achievement.description = "As the County of Tolouse, convert to Cathar Christianity and own all of France.";
achievement.manual = false; -- Is unlocked during achievement turn start check.
achievement.requiredfactions = {"mk_fact_toulouse"}; -- The player must be one of these factions.
achievement.requiredregions = {  -- Regions required for this achievement to unlock.
	"mk_reg_bordeaux",
	"mk_reg_lyon",
	"mk_reg_montpellier",
	"mk_reg_nantes",
	"mk_reg_orleans",
	"mk_reg_paris",
	"mk_reg_poitiers",
	"mk_reg_reims",
	"mk_reg_rouen",
	"mk_reg_tolouse"
};
achievement.requiredreligions = {"mk_rel_chr_cathar"}; -- The player must be one of these religions.
achievement.unlocked = false;
achievement.unlocktime = "";

return achievement;
