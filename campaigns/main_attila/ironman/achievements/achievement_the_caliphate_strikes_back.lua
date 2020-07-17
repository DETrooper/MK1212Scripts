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
	"att_reg_aegyptus_alexandria",
	"att_reg_aegyptus_oxyrhynchus",
	"att_reg_aegyptus_berenice",
	"att_reg_africa_carthago",
	"att_reg_africa_constantina",
	"att_reg_africa_hadrumentum",
	"att_reg_arabia_felix_eudaemon",
	"att_reg_arabia_felix_omana",
	"att_reg_arabia_felix_zafar",
	"att_reg_arabia_magna_dumatha",
	"att_reg_arabia_magna_hira",
	"att_reg_arabia_magna_yathrib",
	"att_reg_armenia_duin",
	"att_reg_armenia_payttakaran",
	"att_reg_armenia_tosp",
	"att_reg_asorstan_arbela",
	"att_reg_asorstan_ctesiphon",
	"att_reg_asorstan_meshan",
	"att_reg_cappadocia_melitene",
	"att_reg_caucasia_gabala",
	"att_reg_cilicia_tarsus",
	"att_reg_khwarasan_abarshahr",
	"att_reg_khwarasan_harey",
	"att_reg_khwarasan_merv",
	"att_reg_libya_augila",
	"att_reg_libya_paraetonium",
	"att_reg_libya_ptolemais",
	"att_reg_makran_harmosia",
	"att_reg_makran_phra",
	"att_reg_makran_pura",
	"att_reg_media_atropatene_ecbatana",
	"att_reg_media_atropatene_ganzaga",
	"att_reg_media_atropatene_rhaga",
	"att_reg_osroene_amida",
	"att_reg_osroene_edessa",
	"att_reg_osroene_nisibis",
	"att_reg_palaestinea_aila",
	"att_reg_palaestinea_aelia_capitolina",
	"att_reg_palaestinea_nova_trajana_bostra",
	"att_reg_persis_behdeshir",
	"att_reg_persis_siraf",
	"att_reg_persis_stakhr",
	"att_reg_phazania_cydamus",
	"att_reg_phazania_garama",
	"att_reg_spahan_issatis",
	"att_reg_spahan_spahan",
	"att_reg_spahan_susa",
	"att_reg_syria_antiochia",
	"att_reg_syria_emesa",
	"att_reg_syria_tyrus",
	"att_reg_transcaspia_dahistan",
	"att_reg_transcaspia_kath",
	"att_reg_tripolitana_leptis_magna",
	"att_reg_tripolitana_macomades",
	"att_reg_tripolitana_sabrata"
};
achievement.unlocked = false;
achievement.unlocktime = "";

return achievement;
