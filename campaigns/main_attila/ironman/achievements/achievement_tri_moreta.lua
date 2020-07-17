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
	"att_reg_dalmatia_domavia",
	"att_reg_dardania_scupi",
	"att_reg_dardania_serdica",
	"att_reg_dardania_viminacium",
	"att_reg_macedonia_dyrrhachium",
	"att_reg_macedonia_thessalonica",
	"att_reg_pannonia_sirmium",
	"att_reg_thracia_marcianopolis",
	"att_reg_thracia_trimontium"
};
achievement.unlocked = false;
achievement.unlocktime = "";

return achievement;
