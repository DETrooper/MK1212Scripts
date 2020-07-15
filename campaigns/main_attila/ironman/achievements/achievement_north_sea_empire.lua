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
achievement.description = "As the Kingdom of Denmark restore the borders of King Cnut the Great's domain by conquering all of Scandinavia and England.";
achievement.manual = false; -- Is unlocked during achievement turn start check.
achievement.requiredregions = {  -- Regions required for this achievement to unlock.
	"att_reg_britannia_inferior_eboracum",
	"att_reg_britannia_inferior_lindum",
	"att_reg_britannia_superior_camulodunon",
	"att_reg_britannia_superior_corinium",
	"att_reg_britannia_superior_londinium",
	"att_reg_scandza_alabu",
	"att_reg_scandza_hafn",
	"att_reg_scandza_hrefnesholt"
};
achievement.requiredfactions = {"mk_fact_denmark"}; -- The player must be one of these factions.
achievement.unlocked = false;
achievement.unlocktime = "";

return achievement;
