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
	"mk_reg_aix-en-provence",
	"mk_reg_antwerp",
	"mk_reg_bern",
	"mk_reg_bologna",
	"mk_reg_brandenburg",
	"mk_reg_braunschweig",
	--"mk_reg_bruges",
	"mk_reg_erfut",
	"mk_reg_frankfurt",
	"mk_reg_genoa",
	"mk_reg_graz",
	"mk_reg_groningen",
	--"mk_reg_hamburg",
	"mk_reg_heidelberg",
	"mk_reg_koln",
	"mk_reg_konstanz",
	"mk_reg_lubeck",
	"mk_reg_milan",
	"mk_reg_munich",
	"mk_reg_nancy",
	"mk_reg_nuremberg",
	"mk_reg_olomouc",
	"mk_reg_pisa",
	"mk_reg_prague",
	"mk_reg_salzburg",
	"mk_reg_stralsund",
	"mk_reg_trier",
	"mk_reg_turin",
	"mk_reg_verona",
	"mk_reg_vienna",
	"mk_reg_vienne",
	"mk_reg_wittenberg"
};

mkHRE.region_image_faction_pip_locations = {
	["mk_reg_aix-en-provence"] = {95, 545},
	["mk_reg_antwerp"] = {92, 184},
	["mk_reg_bern"] = {169, 414},
	["mk_reg_bologna"] = {310, 510},
	["mk_reg_brandenburg"] = {334, 136},
	["mk_reg_braunschweig"] = {245, 138},
	--["mk_reg_bruges"] = {0, 0},
	["mk_reg_erfut"] = {289, 190},
	["mk_reg_frankfurt"] = {232, 240},
	["mk_reg_genoa"] = {222, 490},
	["mk_reg_graz"] = {389, 386},
	["mk_reg_groningen"] = {125, 112},
	--["mk_reg_hamburg"] = {244, 69},
	["mk_reg_heidelberg"] = {224, 277},
	["mk_reg_koln"] = {156, 212},
	["mk_reg_konstanz"] = {238, 356},
	["mk_reg_lubeck"] = {278, 68},
	["mk_reg_milan"] = {227, 447},
	["mk_reg_munich"] = {283, 348},
	["mk_reg_nancy"] = {171, 315},
	["mk_reg_nuremberg"] = {282, 294},
	["mk_reg_olomouc"] = {488, 275},
	["mk_reg_pisa"] = {271, 539},
	["mk_reg_prague"] = {409, 247},
	["mk_reg_salzburg"] = {356, 339},
	["mk_reg_stralsund"] = {353, 77},
	["mk_reg_trier"] = {161, 257},
	["mk_reg_turin"] = {149, 476},
	["mk_reg_verona"] = {297, 457},
	["mk_reg_vienna"] = {445, 328},
	["mk_reg_vienne"] = {89, 475},
	["mk_reg_wittenberg"] = {335, 178}
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
