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
	"att_reg_aquitania_avaricum",
	"att_reg_aquitania_burdigala",
	"att_reg_aquitania_elusa",
	"att_reg_lugdunensis_lugdunum",
	"att_reg_lugdunensis_rotomagus",
	"att_reg_lugdunensis_turonum",
	"att_reg_maxima_sequanorum_argentoratum",
	"att_reg_maxima_sequanorum_octodurus",
	"att_reg_maxima_sequanorum_vesontio"
};
achievement.requiredreligions = {"mk_rel_chr_cathar"}; -- The player must be one of these religions.
achievement.unlocked = false;
achievement.unlocktime = "";

return achievement;
