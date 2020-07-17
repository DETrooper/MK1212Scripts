-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - IRONMAN: ACHIEVEMENT - THE LION OF THE NORTH
-- 	By: DETrooper
--
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

local achievement = {};

achievement.name = "The Lion of the North";
achievement.description = "As the Kingdom of Sweden, become the Holy Roman Emperor or own all of the Holy Roman Empire's territory.";
achievement.manual = false; -- Is unlocked during achievement turn start check (although this achievement is also unlocked manually).
achievement.requiredfactions = {"mk_fact_sweden"}; -- The player must be one of these factions.
achievement.requiredregions = {  -- Regions required for this achievement to unlock.
	"att_reg_belgica_augusta_treverorum",
	"att_reg_belgica_colonia_agrippina",
	"att_reg_frisia_angulus",
	"att_reg_frisia_flevum",
	"att_reg_frisia_tulifurdum",
	"att_reg_germania_aregelia",
	"att_reg_germania_lupfurdum",
	"att_reg_germania_uburzis",
	"att_reg_gothiscandza_rugion",
	"att_reg_hercynia_casurgis",
	"att_reg_italia_fiorentia",
	"att_reg_liguria_genua",
	"att_reg_liguria_mediolanum",
	"att_reg_liguria_segusio",
	"att_reg_maxima_sequanorum_argentoratum",
	"att_reg_maxima_sequanorum_octodurus",
	"att_reg_narbonensis_aquae_sextiae",
	"att_reg_narbonensis_vienna",
	"att_reg_raetia_et_noricum_augusta_vindelicorum",
	"att_reg_raetia_et_noricum_iuvavum",
	"att_reg_raetia_et_noricum_virunum",
	"att_reg_venetia_ravenna",
	"att_reg_venetia_verona"
};
achievement.unlocked = false;
achievement.unlocktime = "";

return achievement;
