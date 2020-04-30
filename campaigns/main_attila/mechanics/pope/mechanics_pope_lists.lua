JERUSALEM_KEY = "mk_fact_jerusalem";
JERUSALEM_REGION_KEY = "att_reg_palaestinea_aelia_capitolina";
ALEXANDRIA_REGION_KEY = "att_reg_aegyptus_alexandria";

POPE_LIST = {
	{id = "Innocentius III",	name = "names_name_2147380345", turn = -99, age = 37},
	{id = "Honorius III",		name = "names_name_2147380346", turn = 9, 	age = 67},
	{id = "Gregorius IX",		name = "names_name_2147380347", turn = 31, 	age = 69},
	{id = "Coelestinus IV",		name = "names_name_2147380353", turn = 60, 	age = 58},
	{id = "Innocentius IV",		name = "names_name_2147380363", turn = 63, 	age = 48},
	{id = "Alexander IV",		name = "names_name_2147380367", turn = 87, 	age = 55},
	{id = "Urbanus IV",			name = "names_name_2147380369", turn = 101, age = 66},
	{id = "Clemens IV",			name = "names_name_2147380378", turn = 108, age = 62},
	{id = "Gregorius X",		name = "names_name_2147380386", turn = 121, age = 61},
	{id = "Innocentius V",		name = "names_name_2147380394", turn = 130, age = 52},
	{id = "Ioannes XXI",		name = "names_name_2147380401", turn = 131, age = 60},
	{id = "Nicolaus III",		name = "names_name_2147380406", turn = 132, age = 61},
	{id = "Martinus IV",		name = "names_name_2147380412", turn = 140, age = 71},
	{id = "Honorius IV",		name = "names_name_2147380421", turn = 148, age = 75},
	{id = "Nicolaus IV",		name = "names_name_2147380426", turn = 154, age = 60},
	{id = "Coelestinus V",		name = "names_name_2147380428", turn = 166, age = 86},
	{id = "Bonifatius VIII",	name = "names_name_2147380432", turn = 167, age = 62},
	{id = "Benedictus XI",		name = "names_name_2147380442", turn = 184, age = 63},
	{id = "Clemens V",			name = "names_name_2147380449", turn = 188, age = 41},
	{id = "Ioannes XXII",		name = "names_name_2147380458", turn = 211, age = 70},
	{id = "Benedictus XII",		name = "names_name_2147380468", turn = 247, age = 52},
	{id = "Clemens VI",			name = "names_name_2147380477", turn = 262, age = 51},
	{id = "Innocentius VI",		name = "names_name_2147380479", turn = 283, age = 70},
	{id = "Urbanus V",			name = "names_name_2147380481", turn = 303, age = 53},
	{id = "Gregorius XI",		name = "names_name_2147380486", turn = 319, age = 41},
	{id = "Urbanus VI",			name = "names_name_2147380494", turn = 334, age = 60},
	{id = "Bonifatius IX",		name = "names_name_2147380499", turn = 357, age = 34},
	{id = "Innocentius VII",	name = "names_name_2147380503", turn = 387, age = 67},
	{id = "Gregorius XII",		name = "names_name_2147380504", turn = 391, age = 82},
	{id = "Martinus V",			name = "names_name_2147380512", turn = 413, age = 48},
	{id = "Eugenius IV",		name = "names_name_2147380513", turn = 440, age = 47},
	{id = "Nicolaus V",			name = "names_name_2147380516", turn = 472, age = 49},
	{id = "Callistus III",		name = "names_name_2147380517", turn = 488, age = 76},
	{id = "Pius II",			name = "names_name_2147380527", turn = 495, age = 52},
	{id = "Paulus II",			name = "names_name_2147380533", turn = 507, age = 47},
	{id = "Xystus IV",			name = "names_name_2147380540", turn = 521, age = 57},
	{id = "Innocentius VIII",	name = "names_name_2147380542", turn = 547, age = 51},
	{id = "Alexander VI",		name = "names_name_2147380552", turn = 563, age = 61}
};

GENERIC_POPE_NAMES = {
	"names_name_2147353214",
	"names_name_2147373587",
	"names_name_2147365942",
	"names_name_2147358797",
	"names_name_2147352530",
	"names_name_2147353466",
	"names_name_2147366881",
	"names_name_2147358744",
	"names_name_2147353621"
};

SCRIPTED_CRUSADES_LIST = {
	-- Scripted target region, optional message turn, begin turn, crusader mission key, defender mission key, scripted participants.
	["5"] = {"att_reg_aegyptus_oxyrhynchus", 7, 11, "mk_mission_crusades_take_cairo_fifth_crusade", "mk_mission_crusades_defense_cairo", {"mk_fact_france", "mk_fact_hre", "mk_fact_hungary", "mk_fact_jerusalem"}}
}

CRUSADE_TARGET_RELIGIONS = {
	"mk_rel_shia_islam",
	"att_rel_semitic_paganism"
}

CRUSADE_REGIONS = {
	-- Core European territories recieve priority over faraway lands.
	["att_reg_italia_roma"] = 10000, -- Rome
	["att_reg_aquitania_elusa"] = 2500, -- Toulouse
	["att_reg_britannia_superior_londinium"] = 2500, -- London
	["att_reg_germania_uburzis"] = 2500, -- Frankfurt
	["att_reg_carthaginensis_toletum"] = 2500, -- Toledo
	["att_reg_lugdunensis_turonum"] = 2500, -- Paris
	["att_reg_tarraconensis_tarraco"] = 2500, -- Barcelona
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

CRUSADE_REGIONS_IN_MIDDLE_EAST = {
	"att_reg_aegyptus_alexandria",
	"att_reg_aegyptus_oxyrhynchus",
	"att_reg_palaestinea_aelia_capitolina",
	"att_reg_syria_antiochia"
}

CRUSADE_DEFENSE_UNIT_LIST = 	"mk_ayy_t1_jund_spearmen,mk_ayy_t1_jund_spearmen,mk_ayy_t1_jund_spearmen,mk_ayy_t1_jund_spearmen,".. -- Spears
				"mk_ayy_t1_jund_swordsmen,mk_ayy_t1_jund_swordsmen,mk_ayy_t1_jund_swordsmen,mk_ayy_t1_jund_swordsmen,".. -- Swords
				"mk_ayy_t1_crossbowmen,mk_ayy_t1_crossbowmen,mk_ayy_t1_crossbowmen"; -- Ranged
