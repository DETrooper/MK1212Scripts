-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - IRONMAN: ACHIEVEMENT - THE RE-RECONQUISTA
-- 	By: DETrooper
--
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

local achievement = {};

achievement.name = "The Re-Reconquista";
achievement.description = "As the Almohad Caliphate or Marinid Sultanate, conquer the entire Iberian peninsula while remaining Islamic.";
achievement.manual = false; -- Is unlocked during achievement turn start check.
achievement.requiredfactions = {"mk_fact_almohads", "mk_fact_marinids"}; -- The player must be one of these factions.
achievement.requiredregions = {  -- Regions required for this achievement to unlock.
	"att_reg_baetica_corduba",
	"att_reg_baetica_hispalis",
	"att_reg_baetica_malaca",
	"att_reg_carthaginensis_carthago_nova",
	"att_reg_carthaginensis_segobriga",
	"att_reg_carthaginensis_toletum",
	"att_reg_gallaecia_asturica",
	"att_reg_gallaecia_bracara",
	"att_reg_gallaecia_brigantium",
	"att_reg_lusitania_emerita_augusta",
	"att_reg_lusitania_pax_augusta",
	"att_reg_lusitania_olisipo",
	"att_reg_tarraconensis_caesaraugusta",
	"att_reg_tarraconensis_pompaelo",
	"att_reg_tarraconensis_tarraco"
};
achievement.requiredreligions = {"mk_rel_ibadi_islam", "att_rel_semitic_paganism", "mk_rel_shia_islam"}; -- The player must be one of these religions.
achievement.unlocked = false;
achievement.unlocktime = "";

return achievement;
