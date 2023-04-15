-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - IRONMAN: ACHIEVEMENT - THE CALIPHATE STRIKES BACK
-- 	By: DETrooper
--
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

local achievement = {};

achievement.name = "The Caliphate Strikes Back";
achievement.description = "As the Abbasid Caliphate, restore the borders of the Abbasid Caliphate at its height.";
achievement.manual = false; -- Is unlocked during achievement turn start check.
achievement.requiredfactions = {"mk_fact_abbasids"}; -- The player must be one of these factions.
achievement.requiredregions = {  -- Regions required for this achievement to unlock.
	"mk_reg_acre",
	"mk_reg_aden",
	"mk_reg_ahvaz",
	"mk_reg_al-mahdiya",
	"mk_reg_al-rahba",
	"mk_reg_al-raqqah",
	"mk_reg_aleppo",
	"mk_reg_alexandria",
	"mk_reg_amol",
	"mk_reg_antioch",
	"mk_reg_aqaba",
	"mk_reg_ardabil",
	"mk_reg_aydhab",
	"mk_reg_baghdad",
	"mk_reg_bahla",
	"mk_reg_baku",
	"mk_reg_balkh",
	"mk_reg_barca",
	"mk_reg_basra",
	"mk_reg_bushehr",
	"mk_reg_cairo",
	"mk_reg_damascus",
	"mk_reg_damietta",
	"mk_reg_daybal",
	"mk_reg_derbent",
	"mk_reg_diyarbakir",
	"mk_reg_dvin",
	"mk_reg_erbil",
	"mk_reg_erzurum",
	"mk_reg_ghazi",
	"mk_reg_farava",
	"mk_reg_hamadan",
	"mk_reg_herat",
	"mk_reg_homs",
	"mk_reg_hormuz",
	"mk_reg_isfahan",
	"mk_reg_jerusalem",
	"mk_reg_kandahar",
	"mk_reg_kerak",
	"mk_reg_kerman",
	"mk_reg_kufah",
	"mk_reg_malatya",
	"mk_reg_maragheh",
	"mk_reg_marib",
	"mk_reg_mecca",
	"mk_reg_mersa_matruh",
	"mk_reg_merv",
	"mk_reg_minya",
	"mk_reg_misrata",
	"mk_reg_mosul",
	"mk_reg_nishapur",
	"mk_reg_pahrah",
	"mk_reg_qatif",
	"mk_reg_qus",
	"mk_reg_qusantina",
	"mk_reg_ray",
	"mk_reg_shiraz",
	"mk_reg_sis",
	"mk_reg_tabriz",
	"mk_reg_tripoli_levant",
	"mk_reg_tripoli_libya",
	"mk_reg_tunis",
	"mk_reg_urgench",
	"mk_reg_van",
	"mk_reg_yazd",
	"mk_reg_zaranj"
};
achievement.unlocked = false;
achievement.unlocktime = "";

return achievement;
