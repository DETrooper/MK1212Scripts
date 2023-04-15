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
	"mk_reg_badajoz",
	"mk_reg_barcelona",
	"mk_reg_braga",
	"mk_reg_burgos",
	"mk_reg_cordoba",
	"mk_reg_evora",
	"mk_reg_granada",
	"mk_reg_leon",
	"mk_reg_lisbon",
	"mk_reg_malaga",
	"mk_reg_murcia",
	"mk_reg_pamplona",
	"mk_reg_santiago",
	"mk_reg_seville",
	"mk_reg_toledo",
	"mk_reg_valencia",
	"mk_reg_zaragoza"
};
achievement.requiredreligions = {"mk_rel_ibadi_islam", "att_rel_semitic_paganism", "mk_rel_shia_islam"}; -- The player must be one of these religions.
achievement.unlocked = false;
achievement.unlocktime = "";

return achievement;
