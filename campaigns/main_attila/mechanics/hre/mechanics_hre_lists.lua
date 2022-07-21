-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: HOLY ROMAN EMPIRE LISTS
-- 	By: DETrooper
--
-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------

-- Order: Attitude title, attitude description.
mkHRE.factions_states = {
	["loyal"] = {"Loyal", "This faction is loyal to the emperor and will always support them."},
	["ambitious"] = {"Ambitious", "This faction is ruthlessly ambitious, serving its own ends at the expense of all others."},
	["malcontent"] = {"Malcontent", "This faction has been extremely offended by the emperor and will always oppose them."},
	["discontent"] = {"Discontent", "This faction is displeased with the actions of the emperor and will oppose them unless it is against their interests."},
	["neutral"] = {"Neutral", "This faction has no significant grievances or commendations towards the emperor, acting in the best interest of the empire at large."},
	["emperor"] = {"Emperor", "This faction currently holds the throne of the Holy Roman Empire."},
	["pretender"] = {"Pretender", "This faction is a pretender to the throne of the Holy Roman Empire."},
	["puppet"] = {"Puppet", "This faction exists only in name, being completely subservient to the whims of the emperor"}
};

mkHRE.event_dilemmas = {
	["mk_dilemma_hre_border_dispute"] = {0, 0, -10},
	["mk_dilemma_hre_imperial_immediacy"] = {15, -15},
	["mk_dilemma_hre_noble_conflict"] = {10, 10, -10},
	["mk_dilemma_hre_imperial_diet"] = {25, 25, 0, 10}
};

mkHRE.factions_start = {
	"mk_fact_hre",
	"mk_fact_bologna",
	"mk_fact_verona",
	"mk_fact_savoy",
	"mk_fact_friesland",
	"mk_fact_brabant",
	"mk_fact_provence",
	"mk_fact_dauphine",
	"mk_fact_milan",
	"mk_fact_genoa",
	"mk_fact_brandenburg",
	"mk_fact_hansa", -- emergent
	"mk_fact_saxony",
	"mk_fact_bavaria",
	"mk_fact_bohemia",
	"mk_fact_trier",
	"mk_fact_austria",
	"mk_fact_lorraine",
	"mk_fact_schwyz",
	"mk_fact_pisa"
};

mkHRE.historical_electors = {
	"mk_fact_bohemia",
	"mk_fact_brandenburg",
	"mk_fact_saxony",
	"mk_fact_trier"
};

mkHRE.factions_to_states_start = {
	["mk_fact_hre"] = "emperor",
	["mk_fact_bologna"] = "discontent",
	["mk_fact_verona"] = "discontent",
	["mk_fact_savoy"] = "discontent",
	["mk_fact_friesland"] = "neutral",
	["mk_fact_brabant"] = "neutral",
	["mk_fact_provence"] = "discontent",
	["mk_fact_dauphine"] = "discontent",
	["mk_fact_milan"] = "discontent",
	["mk_fact_genoa"] = "discontent",
	["mk_fact_brandenburg"] = "loyal",
	["mk_fact_saxony"] = "loyal",
	["mk_fact_bavaria"] = "discontent",
	["mk_fact_bohemia"] = "ambitious",
	["mk_fact_trier"] = "neutral",
	["mk_fact_austria"] = "discontent",
	["mk_fact_lorraine"] = "neutral",
	["mk_fact_schwyz"] = "discontent",
	["mk_fact_pisa"] = "discontent",
	["mk_fact_sicily"] = "pretender"
};

mkHRE.elector_votes_start = {
	["mk_fact_hre"] = "mk_fact_hre",
	["mk_fact_bologna"] = "mk_fact_sicily",
	["mk_fact_verona"] = "mk_fact_sicily",
	["mk_fact_savoy"] = "mk_fact_sicily",
	["mk_fact_friesland"] = "mk_fact_hre",
	["mk_fact_brabant"] = "mk_fact_hre",
	["mk_fact_provence"] = "mk_fact_sicily",
	["mk_fact_dauphine"] = "mk_fact_sicily",
	["mk_fact_milan"] = "mk_fact_sicily",
	["mk_fact_genoa"] = "mk_fact_sicily",
	["mk_fact_brandenburg"] = "mk_fact_hre",
	["mk_fact_saxony"] = "mk_fact_hre",
	["mk_fact_bavaria"] = "mk_fact_sicily",
	["mk_fact_bohemia"] = "mk_fact_bohemia",
	["mk_fact_trier"] = "mk_fact_hre",
	["mk_fact_austria"] = "mk_fact_sicily",
	["mk_fact_lorraine"] = "mk_fact_hre",
	["mk_fact_schwyz"] = "mk_fact_sicily",
	["mk_fact_pisa"] = "mk_fact_sicily"
};

mkHRE.regions = {
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

mkHRE.regions_to_images = {
	["att_reg_belgica_augusta_treverorum"] = "hre_reg_belgica_augusta_treverorum",
	["att_reg_belgica_colonia_agrippina"] = "hre_reg_belgica_colonia_agrippina",
	["att_reg_frisia_angulus"] = "hre_reg_frisia_angulus",
	["att_reg_frisia_flevum"] = "hre_reg_frisia_flevum",
	["att_reg_frisia_tulifurdum"] = "hre_reg_frisia_tulifurdum",
	["att_reg_hercynia_casurgis"] = "hre_reg_hercynia_casurgis",
	["att_reg_italia_fiorentia"] = "hre_reg_italia_fiorentia",
	["att_reg_liguria_genua"] = "hre_reg_liguria_genua",
	["att_reg_liguria_mediolanum"] = "hre_reg_liguria_mediolanum",
	["att_reg_liguria_segusio"] = "hre_reg_liguria_segusio",
	["att_reg_maxima_sequanorum_argentoratum"] = "hre_reg_maxima_sequanorum_argentoratum",
	["att_reg_maxima_sequanorum_octodurus"] = "hre_reg_maxima_sequanorum_octodurus",
	["att_reg_narbonensis_aquae_sextiae"] = "hre_reg_narbonensis_aquae_sextiae",
	["att_reg_narbonensis_vienna"] = "hre_reg_narbonensis_vienna",
	["att_reg_germania_aregelia"] = "hre_reg_germania_aregelia",
	["att_reg_germania_lupfurdum"] = "hre_reg_germania_lupfurdum",
	["att_reg_germania_uburzis"] = "hre_reg_germania_uburzis",
	["att_reg_gothiscandza_rugion"] = "hre_reg_gothiscandza_rugion",
	["att_reg_raetia_et_noricum_augusta_vindelicorum"] = "hre_reg_raetia_et_noricum_augusta_vindelicorum",
	["att_reg_raetia_et_noricum_iuvavum"] = "hre_reg_raetia_et_noricum_iuvavum",
	["att_reg_raetia_et_noricum_virunum"] = "hre_reg_raetia_et_noricum_virunum",
	["att_reg_venetia_ravenna"] = "hre_reg_venetia_ravenna",
	["att_reg_venetia_verona"] = "hre_reg_venetia_verona"
};

mkHRE.region_image_faction_pip_locations = {
	["att_reg_belgica_augusta_treverorum"] = {135, 270},
	["att_reg_belgica_colonia_agrippina"] = {132, 188},
	["att_reg_frisia_angulus"] = {251, 62},
	["att_reg_frisia_flevum"] = {125, 112},
	["att_reg_frisia_tulifurdum"] = {245, 138},
	["att_reg_hercynia_casurgis"] = {409, 247},
	["att_reg_italia_fiorentia"] = {271, 539},
	["att_reg_liguria_genua"] = {222, 490},
	["att_reg_liguria_mediolanum"] = {227, 447},
	["att_reg_liguria_segusio"] = {149, 476},
	["att_reg_maxima_sequanorum_argentoratum"] = {179, 300},
	["att_reg_maxima_sequanorum_octodurus"] = {169, 414},
	["att_reg_narbonensis_aquae_sextiae"] = {95, 545},
	["att_reg_narbonensis_vienna"] = {89, 475},
	["att_reg_germania_aregelia"] = {290, 190},
	["att_reg_germania_lupfurdum"] = {386, 180},
	["att_reg_germania_uburzis"] = {250, 264},
	["att_reg_gothiscandza_rugion"] = {353, 77},
	["att_reg_raetia_et_noricum_augusta_vindelicorum"] = {283, 348},
	["att_reg_raetia_et_noricum_iuvavum"] = {356, 339},
	["att_reg_raetia_et_noricum_virunum"] = {389, 386},
	["att_reg_venetia_ravenna"] = {320, 528},
	["att_reg_venetia_verona"] = {299, 464},
};

mkHRE.emperors_names_numbers = {
	["names_name_2147368276"] = 4,
	["names_name_2147384692"] = 4,
	["names_name_2147364244"] = 3,
	["names_name_2147355707"] = 3,
	["names_name_2147384567"] = 3,
	["names_name_2147387168"] = 3,
	["names_name_2147334109"] = 3,
	["names_name_2147388114"] = 3,
	["names_name_2147364374"] = 3,
	["names_name_2147355705"] = 3,
	["names_name_2147355722"] = 2,
	["names_name_2147364311"] = 1,
	["names_name_2147362839"] = 1,
	["names_name_2147364745"] = 1,
	["names_name_2147368212"] = 1,
	["names_name_2147334121"] = 1,
	["names_name_2147362837"] = 1,
	["names_name_2147384582"] = 1,
	["names_name_2147362732"] = 1,
	["names_name_2147384261"] = 1,
	["names_name_2147333262"] = 1,
	["names_name_2147367153"] = 6,
	["names_name_2147364750"] = 6,
	["names_name_2147333418"] = 2,
	["names_name_2147362735"] = 2,
	["names_name_2147384398"] = 2,
	["names_name_2147380847"] = 2,
	["names_name_2147372482"] = 2,
	["names_name_2147370877"] = 2
};

mkHRE.emperors_roman_numerals = {
	"I",
	"II",
	"III",
	"IV",
	"V",
	"VI",
	"VII",
	"VIII",
	"IX",
	"X",
	"XI",
	"XII",
	"XIII",
	"XIV",
	"XV",
	"XVI",
	"XVII",
	"XVIII",
	"XIX",
	"XX",
};
