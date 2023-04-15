-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - IRONMAN: ACHIEVEMENT - WORLD CONQUEST
-- 	By: DETrooper
--
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

local achievement = {};

achievement.name = "World Conquest";
achievement.description = "Own all regions on the campaign map.";
achievement.manual = false; -- Is unlocked during achievement turn start check.
achievement.requiredregions = {  -- Regions required for this achievement to unlock.
	"mk_reg_aarhus",
	"mk_reg_acre",
	"mk_reg_aden",
	"mk_reg_agadir",
	"mk_reg_ahvaz",
	"mk_reg_aix-en-provence",
	"mk_reg_ajaccio",
	"mk_reg_aleppo",
	"mk_reg_alexandria",
	"mk_reg_algiers",
	"mk_reg_al-mahdiya",
	"mk_reg_al-rahba",
	"mk_reg_al-raqqah",
	"mk_reg_amol",
	"mk_reg_ancona",
	"mk_reg_ancyra",
	"mk_reg_antioch",
	"mk_reg_antwerp",
	"mk_reg_aqaba",
	"mk_reg_ardabil",
	"mk_reg_arta",
	"mk_reg_athens",
	"mk_reg_attaleia",
	"mk_reg_aydhab",
	"mk_reg_badajoz",
	"mk_reg_baghdad",
	"mk_reg_bahla",
	"mk_reg_baku",
	"mk_reg_balkh",
	"mk_reg_barca",
	"mk_reg_barcelona",
	"mk_reg_basra",
	"mk_reg_belgrade",
	"mk_reg_bergen",
	"mk_reg_bern",
	"mk_reg_bilgorod",
	"mk_reg_bilyar",
	"mk_reg_biskra",
	"mk_reg_bologna",
	"mk_reg_bordeaux",
	"mk_reg_braga",
	"mk_reg_brandenburg",
	"mk_reg_braunschweig",
	"mk_reg_bristol",
	"mk_reg_bruges",
	"mk_reg_bukhara",
	"mk_reg_burgos",
	"mk_reg_bushehr",
	"mk_reg_caernarvon",
	"mk_reg_caffa",
	"mk_reg_cagliari",
	"mk_reg_cairo",
	"mk_reg_candia",
	"mk_reg_cardiff",
	"mk_reg_chernigov",
	"mk_reg_colchester",
	"mk_reg_constantinopolis",
	"mk_reg_cordoba",
	"mk_reg_cork",
	"mk_reg_cyzicus",
	"mk_reg_damascus",
	"mk_reg_damietta",
	"mk_reg_daybal",
	"mk_reg_derbent",
	"mk_reg_dijon",
	"mk_reg_diyarbakir",
	"mk_reg_dongola",
	"mk_reg_dorylaion",
	"mk_reg_dublin",
	"mk_reg_dvin",
	"mk_reg_dyrrhachium",
	"mk_reg_edinburgh",
	"mk_reg_erbil",
	"mk_reg_erfut",
	"mk_reg_erzurum",
	"mk_reg_esztergom",
	"mk_reg_evora",
	"mk_reg_famagusta",
	"mk_reg_fez",
	"mk_reg_frankfurt",
	"mk_reg_gardinas",
	"mk_reg_gdansk",
	"mk_reg_genoa",
	"mk_reg_ghazi",
	"mk_reg_farava",
	"mk_reg_granada",
	"mk_reg_graz",
	"mk_reg_groningen",
	"mk_reg_gyulafehervar",
	"mk_reg_halych",
	"mk_reg_hamadan",
	"mk_reg_saraijuq",
	"mk_reg_heidelberg",
	"mk_reg_herat",
	"mk_reg_homs",
	"mk_reg_hormuz",
	"mk_reg_iconion",
	"mk_reg_inverness",
	"mk_reg_isfahan",
	"mk_reg_jerusalem",
	"mk_reg_kalmar",
	"mk_reg_kandahar",
	"mk_reg_kassa",
	"mk_reg_kayseri",
	"mk_reg_kerak",
	"mk_reg_kerman",
	"mk_reg_kiev",
	"mk_reg_koln",
	"mk_reg_konigsberg",
	"mk_reg_konstanz",
	"mk_reg_krakow",
	"mk_reg_kufah",
	"mk_reg_kursk",
	"mk_reg_lalibela",
	"mk_reg_leon",
	"mk_reg_lisbon",
	"mk_reg_lodose",
	"mk_reg_london",
	"mk_reg_lubeck",
	"mk_reg_lyon",
	"mk_reg_maghas",
	"mk_reg_malaga",
	"mk_reg_malatya",
	"mk_reg_maragheh",
	"mk_reg_marib",
	"mk_reg_marrakech",
	"mk_reg_massawa",
	"mk_reg_mecca",
	"mk_reg_mersa_matruh",
	"mk_reg_merv",
	"mk_reg_milan",
	"mk_reg_minsk",
	"mk_reg_minya",
	"mk_reg_misrata",
	"mk_reg_montpellier",
	"mk_reg_mosul",
	"mk_reg_munich",
	"mk_reg_murcia",
	"mk_reg_muscovy",
	"mk_reg_mystras",
	"mk_reg_nancy",
	"mk_reg_nantes",
	"mk_reg_naples",
	"mk_reg_nicaea",
	"mk_reg_nis",
	"mk_reg_nishapur",
	"mk_reg_coventry",
	"mk_reg_novgorod",
	"mk_reg_nuremberg",
	"mk_reg_olomouc",
	"mk_reg_orleans",
	"mk_reg_oslo",
	"mk_reg_pahrah",
	"mk_reg_palermo",
	"mk_reg_palma",
	"mk_reg_pamplona",
	"mk_reg_paris",
	"mk_reg_pecs",
	"mk_reg_pereyaslavl",
	"mk_reg_philippopolis",
	"mk_reg_pisa",
	"mk_reg_plock",
	"mk_reg_poitiers",
	"mk_reg_polotsk",
	"mk_reg_poznan",
	"mk_reg_prague",
	"mk_reg_pskov",
	"mk_reg_qatif",
	"mk_reg_qus",
	"mk_reg_qusantina",
	"mk_reg_ras",
	"mk_reg_ray",
	"mk_reg_reggio",
	"mk_reg_reims",
	"mk_reg_rhodes",
	"mk_reg_riga",
	"mk_reg_rome",
	"mk_reg_roskilde",
	"mk_reg_rouen",
	"mk_reg_ryazan",
	"mk_reg_sale",
	"mk_reg_salzburg",
	"mk_reg_samarkand",
	"mk_reg_santiago",
	"mk_reg_saqsin",
	"mk_reg_sarkel",
	"mk_reg_scopie",
	"mk_reg_seville",
	"mk_reg_sharukan",
	"mk_reg_shiraz",
	"mk_reg_sinope",
	"mk_reg_sis",
	"mk_reg_smolensk",
	"mk_reg_smyrna",
	"mk_reg_split",
	"mk_reg_sredets",
	"mk_reg_stockholm",
	"mk_reg_stralsund",
	"mk_reg_suceava",
	"mk_reg_sukhumi",
	"mk_reg_burtas",
	"mk_reg_syracuse",
	"mk_reg_tabriz",
	"mk_reg_tana",
	"mk_reg_tangier",
	"mk_reg_taranto",
	"mk_reg_targoviste",
	"mk_reg_tarnovo",
	"mk_reg_tbilisi",
	"mk_reg_thessalonica",
	"mk_reg_tlemcen",
	"mk_reg_toledo",
	"mk_reg_toulouse",
	"mk_reg_trebizond",
	"mk_reg_trier",
	"mk_reg_tripoli_levant",
	"mk_reg_tripoli_libya",
	"mk_reg_tunis",
	"mk_reg_turin",
	"mk_reg_tver",
	"mk_reg_urgench",
	"mk_reg_valencia",
	"mk_reg_van",
	"mk_reg_varad",
	"mk_reg_varna",
	"mk_reg_venice",
	"mk_reg_verona",
	"mk_reg_vienna",
	"mk_reg_vienne",
	"mk_reg_vilnius",
	"mk_reg_visby",
	"mk_reg_visoko",
	"mk_reg_vladimir",
	"mk_reg_volodymyr",
	"mk_reg_wittenberg",
	"mk_reg_wroclaw",
	"mk_reg_yaroslavl",
	"mk_reg_yazd",
	"mk_reg_york",
	"mk_reg_zagreb",
	"mk_reg_zaragoza",
	"mk_reg_zaranj",
	"mk_reg_zeila"
};
achievement.unlocked = false;
achievement.unlocktime = "";

return achievement;
