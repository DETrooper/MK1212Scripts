-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - IRONMAN: ACHIEVEMENT - ALL THE WORLD'S A STAGE
-- 	By: DETrooper
--
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

local achievement = {};

achievement.name = "All the World's a Stage";
achievement.description = "As the Kingdom of England, construct a Grand Theater in Alexandria, Constantinople, London, Paris, Rome, Venice, and Vienna.";
achievement.manual = false; -- Is unlocked during achievement turn start check.
achievement.requiredbuildings = {"mk_bld_weskingdoms_civic_major_theater_3"};
achievement.requiredregionsforbuildings = {
	"att_reg_aegyptus_alexandria",
	"att_reg_thracia_constantinopolis",
	"att_reg_britannia_superior_londinium",
	"att_reg_lugdunensis_turonum",
	"att_reg_italia_roma",
	"att_reg_venetia_aquileia",
	"att_reg_raetia_et_noricum_virunum"
};
achievement.unlocked = false;
achievement.unlocktime = "";

return achievement;
