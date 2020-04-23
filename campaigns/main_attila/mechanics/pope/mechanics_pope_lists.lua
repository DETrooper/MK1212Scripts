JERUSALEM_REGION_KEY = "att_reg_palaestinea_aelia_capitolina";
ALEXANDRIA_REGION_KEY = "att_reg_aegyptus_alexandria";
FRANCE_KEY = "mk_fact_france";
HRE_KEY = "mk_fact_hre";
HUNGARY_KEY = "mk_fact_hungary";
JERUSALEM_KEY = "mk_fact_jerusalem";

SCRIPTED_CRUSADES_LIST = {
	-- Scripted target region, optional message turn, begin turn.
	[1] = {},
	[2] = {},
	[3] = {},
	[4] = {},
	[5] = {"att_reg_aegyptus_oxyrhynchus", 7, 11}
}

CRUSADE_TARGET_RELIGIONS = {
	"mk_rel_shia_islam",
	"att_rel_semitic_paganism"
}

CRUSADE_REGIONS = {
	-- Core European territories recieve priority over faraway lands.
	["att_reg_italia_roma"] = 5000, -- Rome
	["att_reg_aquitania_elusa"] = 2500, -- Toulouse
	["att_reg_britannia_superior_londinium"] = 2500, -- London
	["att_reg_germania_uburzis"] = 2500, -- Frankfurt
	["att_reg_carthaginensis_toletum"] = 2500,
	["att_reg_lugdunensis_turonum"] = 2500,
	["att_reg_tarraconensis_tarraco"] = 2500,
	-- Orthodox territories to be reconquered if lost to non-Christians.
	["att_reg_thracia_constantinopolis"] = 2000, -- Constantinople
	["att_reg_macedonia_thessalonica"] = 1500, -- Thessalonica
	-- Important Middle East territories.
	["att_reg_palaestinea_aelia_capitolina"] = 1000, -- Jerusalem
	["att_reg_aegyptus_oxyrhynchus"] = 500, -- Cairo
	["att_reg_baetica_corduba"] = 500, -- Cordoba
	["att_reg_syria_antiochia"] = 500, -- Antioch
	["att_reg_africa_carthago"] = 250, -- Tunis
	["att_reg_aegyptus_alexandria"] = 250 -- Alexandria
}

CRUSADE_DEFENSE_UNIT_LIST = 	"mk_ayy_t1_jund_spearmen,mk_ayy_t1_jund_spearmen,mk_ayy_t1_jund_spearmen,mk_ayy_t1_jund_spearmen,".. -- Spears
				"mk_ayy_t1_jund_swordsmen,mk_ayy_t1_jund_swordsmen,mk_ayy_t1_jund_swordsmen,mk_ayy_t1_jund_swordsmen,".. -- Swords
				"mk_ayy_t1_crossbowmen,mk_ayy_t1_crossbowmen,mk_ayy_t1_crossbowmen"; -- Ranged
