-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - IRONMAN: ACHIEVEMENT - NORTH SEA EMPIRE
-- 	By: DETrooper
--
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

local achievement = {};

achievement.name = "North Sea Empire";
achievement.description = "As the Kingdom of Denmark, restore the borders of King Cnut the Great's domain by conquering all of Denmark, England, and Norway";
achievement.manual = false; -- Is unlocked during achievement turn start check.
achievement.requiredfactions = {"mk_fact_denmark"}; -- The player must be one of these factions.
achievement.requiredregions = {  -- Regions required for this achievement to unlock.
	"mk_reg_aarhus",
	"mk_reg_bergen",
	"mk_reg_bristol",
	"mk_reg_colchester",
	"mk_reg_coventry",
	"mk_reg_london",
	"mk_reg_oslo",
	"mk_reg_roskilde",
	"mk_reg_york",
};
achievement.unlocked = false;
achievement.unlocktime = "";

return achievement;
