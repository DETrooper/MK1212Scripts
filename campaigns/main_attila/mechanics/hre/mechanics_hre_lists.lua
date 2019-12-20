-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: HOLY ROMAN EMPIRE LISTS
-- 	By: DETrooper
--
-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------

FACTIONS_HRE_START = {
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
	"mk_fact_saxony",
	"mk_fact_bavaria",
	"mk_fact_bohemia",
	"mk_fact_trier",
	"mk_fact_austria",
	"mk_fact_lorraine",
	"mk_fact_schwyz",
	"mk_fact_pisa"
};

FACTIONS_HRE_VOTES_START = {
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

HRE_REGIONS = {
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

HRE_REGIONS_TO_IMAGES = {
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

HRE_REGION_FACTION_PIPS_LOCATIONS = {
	["att_reg_belgica_augusta_treverorum"] = {135, 270},
	["att_reg_belgica_colonia_agrippina"] = {132, 188},
	["att_reg_frisia_angulus"] = {251, 62},
	["att_reg_frisia_flevum"] = {125, 112},
	["att_reg_frisia_tulifurdum"] = {245, 138},
	["att_reg_hercynia_casurgis"] = {409, 247},
	["att_reg_italia_fiorentia"] = {271, 539},
	["att_reg_liguria_genua"] = {192, 484},
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

-- Order: effect_bundle_key, dilemma_key, title localisation, description localisation.
HRE_REFORMS = {
	["hre_reform_kufursten"] = {"mk_effect_bundle_reform_1", "mk_dilemma_hre_reform_1", "Confirm Permanent Prince-Electors (Kurf??rsten)", "The emperor is only elected by a select group of electors."},
	["hre_reform_reichstag"] = {"mk_effect_bundle_reform_2",  "mk_dilemma_hre_reform_2", "Formalize the Imperial Diet (Reichstag)", "The Imperial Diet becomes the formal consultative and legislative body of the empire with representatives from the empire's estates."},
	["hre_reform_reichspfennig"] = {"mk_effect_bundle_reform_3", "mk_dilemma_hre_reform_3", "Institute the Common Penny (Reichspfennig)", "Institute the levy of a widespread poll tax."},
	["hre_reform_reichskreise"] = {"mk_effect_bundle_reform_4", "mk_dilemma_hre_reform_4", "Organize the Imperial Circles (Reichskreise)", "Regroup regions of the empire into administrative territories to better manage the empire."},
	["hre_reform_ewiger_landfriede"] = {"mk_effect_bundle_reform_5", "mk_dilemma_hre_reform_5", "Enact Perpetual Public Peace (Ewiger Landfriede)", "Outlaws feuds and organizes legal structure into a single body, with the Emperor as the ultimate arbiter."},
	["hre_reform_reichskammergericht"] = {"mk_effect_bundle_reform_6", "mk_dilemma_hre_reform_6", "Establish the Imperial Chamber Court (Reichskammergericht)", "Creates the Imperial Chamber Court to hear cases and apply imperial law."},
	["hre_reform_reichsregiment"] = {"mk_effect_bundle_reform_7", "mk_dilemma_hre_reform_7", "Establish the Imperial Government (Reichsregiment)", "Create an executive organ led by the estates, acting as representatives of the emperor."},
	["hre_reform_erbkaisertum"] = {"mk_effect_bundle_reform_8", "mk_dilemma_hre_reform_8", "Adopt Hereditary Succession of the Imperial Throne (Erbkaisertum)", "Abolishes elections and institutes a hereditary monarchy."},
	["hre_reform_renovatio_imperii"] = {"mk_effect_bundle_reform_9", "mk_dilemma_hre_reform_9", "Renovatio Imperii", "Absorb all territories in the empire into your faction."}
};

HRE_EMPERORS_NAMES_NUMBERS = {
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
	["names_name_2147384398"] = 1,
	["names_name_2147380847"] = 1,
	["names_name_2147372482"] = 1
};

HRE_EMPERORS_ROMAN_NUMERALS = {
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