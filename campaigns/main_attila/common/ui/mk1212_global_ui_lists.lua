-- These tables are to avoid crashing from trying to create non-existent UI components.

FACTIONS_WITH_IMAGES = {
	"mk_fact_abbasids",
	"mk_fact_achaea",
	"mk_fact_alania",
	"mk_fact_almohads",
	"mk_fact_antioch",
	"mk_fact_aq_qoyunlu",
	"mk_fact_aragon",
	"mk_fact_armenia",
	"mk_fact_austria",
	"mk_fact_ayyubids",
	"mk_fact_bavandids",
	"mk_fact_bavaria",
	"mk_fact_bohemia",
	"mk_fact_bologna",
	"mk_fact_bosnia",
	"mk_fact_brabant",
	"mk_fact_brandenburg",
	"mk_fact_bulgaria",
	"mk_fact_burgundy",
	"mk_fact_candar",
	"mk_fact_castile",
	"mk_fact_chernigov",
	"mk_fact_crimea",
	"mk_fact_croatia",
	"mk_fact_cumans",
	"mk_fact_dauphine",
	"mk_fact_denmark",
	"mk_fact_earldoms",
	"mk_fact_england",
	"mk_fact_epirus",
	"mk_fact_flanders",
	"mk_fact_florence",
	"mk_fact_france",
	"mk_fact_friesland",
	"mk_fact_genoa",
	"mk_fact_georgia",
	"mk_fact_germiyan",
	"mk_fact_ghurids",
	"mk_fact_goldenhorde",
	"mk_fact_granada",
	"mk_fact_greaterpoland",
	"mk_fact_hafsids",
	"mk_fact_halych",
	"mk_fact_hansa",
	"mk_fact_hazaraspids",
	"mk_fact_hospitaller",
	"mk_fact_hre",
	"mk_fact_hungary",
	"mk_fact_ildegizids",
	"mk_fact_ilkhanate",
	"mk_fact_ireland",
	"mk_fact_jerusalem",
	"mk_fact_karaman",
	"mk_fact_kartids",
	"mk_fact_kazan",
	"mk_fact_khwarazm",
	"mk_fact_kiev",
	"mk_fact_latinempire",
	"mk_fact_leon",
	"mk_fact_lesserpoland",
	"mk_fact_lithuania",
	"mk_fact_lorraine",
	"mk_fact_makuria",
	"mk_fact_mamluks",
	"mk_fact_marinids",
	"mk_fact_mecca",
	"mk_fact_mentese",
	"mk_fact_mihrabanids",
	"mk_fact_milan",
	"mk_fact_muzaffarids",
	"mk_fact_naples",
	"mk_fact_navarre",
	"mk_fact_nicaea",
	"mk_fact_nogai",
	"mk_fact_norway",
	"mk_fact_oman",
	"mk_fact_ottoman",
	"mk_fact_papacy",
	"mk_fact_pisa",
	"mk_fact_pomerania",
	"mk_fact_portugal",
	"mk_fact_provence",
	"mk_fact_prussians",
	"mk_fact_qara_qoyunlu",
	"mk_fact_rasulids",
	"mk_fact_rebels_african",
	"mk_fact_rebels_arabic",
	"mk_fact_rebels_baltic",
	"mk_fact_rebels_berber",
	"mk_fact_rebels_bulgar",
	"mk_fact_rebels_caucasian",
	"mk_fact_rebels_dutch",
	"mk_fact_rebels_english",
	"mk_fact_rebels_french",
	"mk_fact_rebels_gaelic",
	"mk_fact_rebels_german",
	"mk_fact_rebels_greek",
	"mk_fact_rebels_hungarian",
	"mk_fact_rebels_iranian",
	"mk_fact_rebels_italians",
	"mk_fact_rebels_levantine",
	"mk_fact_rebels_moorish",
	"mk_fact_rebels_nordic",
	"mk_fact_rebels_north_italians",
	"mk_fact_rebels_occitan",
	"mk_fact_rebels_rus",
	"mk_fact_rebels_south_slavic",
	"mk_fact_rebels_spanish",
	"mk_fact_rebels_steppe",
	"mk_fact_rebels_turk",
	"mk_fact_rebels_vlach",
	"mk_fact_rebels_west_slavic",
	"mk_fact_ryazan",
	"mk_fact_salghurids",
	"mk_fact_savoy",
	"mk_fact_saxony",
	"mk_fact_schwyz",
	"mk_fact_scotland",
	"mk_fact_seljuks",
	"mk_fact_separatists_abbasid",
	"mk_fact_separatists_alania",
	"mk_fact_separatists_almohads",
	"mk_fact_separatists_andalusian",
	"mk_fact_separatists_antioch",
	"mk_fact_separatists_aragon",
	"mk_fact_separatists_armenia",
	"mk_fact_separatists_austria",
	"mk_fact_separatists_ayyubids",
	"mk_fact_separatists_bohemia",
	"mk_fact_separatists_bologna",
	"mk_fact_separatists_brabant",
	"mk_fact_separatists_britons",
	"mk_fact_separatists_bulgaria",
	"mk_fact_separatists_burgundy",
	"mk_fact_separatists_castile",
	"mk_fact_separatists_croatia",
	"mk_fact_separatists_cumans",
	"mk_fact_separatists_denmark",
	"mk_fact_separatists_epirus",
	"mk_fact_separatists_flanders",
	"mk_fact_separatists_france",
	"mk_fact_separatists_frankish",
	"mk_fact_separatists_french",
	"mk_fact_separatists_genoa",
	"mk_fact_separatists_georgia",
	"mk_fact_separatists_german",
	"mk_fact_separatists_ghurid",
	"mk_fact_separatists_goldenhorde",
	"mk_fact_separatists_hafsids",
	"mk_fact_separatists_hre",
	"mk_fact_separatists_hungary",
	"mk_fact_separatists_iberian",
	"mk_fact_separatists_ildegizids",
	"mk_fact_separatists_ilkhanate",
	"mk_fact_separatists_iran",
	"mk_fact_separatists_ireland",
	"mk_fact_separatists_jerusalem",
	"mk_fact_separatists_khwarazm",
	"mk_fact_separatists_kiev",
	"mk_fact_separatists_latinempire",
	"mk_fact_separatists_lesserpoland",
	"mk_fact_separatists_lithuania",
	"mk_fact_separatists_lombards",
	"mk_fact_separatists_lorraine",
	"mk_fact_separatists_makuria",
	"mk_fact_separatists_marinids",
	"mk_fact_separatists_mecca",
	"mk_fact_separatists_milan",
	"mk_fact_separatists_navarre",
	"mk_fact_separatists_nicaea",
	"mk_fact_separatists_norway",
	"mk_fact_separatists_oman",
	"mk_fact_separatists_papacy",
	"mk_fact_separatists_pisa",
	"mk_fact_separatists_portugal",
	"mk_fact_separatists_prussian",
	"mk_fact_separatists_rus",
	"mk_fact_separatists_schwyz",
	"mk_fact_separatists_scotland",
	"mk_fact_separatists_seljuks",
	"mk_fact_separatists_serbia",
	"mk_fact_separatists_sicily",
	"mk_fact_separatists_sweden",
	"mk_fact_separatists_tatars",
	"mk_fact_separatists_teutonic",
	"mk_fact_separatists_toulouse",
	"mk_fact_separatists_trebizond",
	"mk_fact_separatists_trier",
	"mk_fact_separatists_turks",
	"mk_fact_separatists_venice",
	"mk_fact_separatists_volga",
	"mk_fact_separatists_wallachia",
	"mk_fact_separatists_wendish",
	"mk_fact_separatists_zagwe",
	"mk_fact_separatists_zengid",
	"mk_fact_serbia",
	"mk_fact_shirvan",
	"mk_fact_sicily",
	"mk_fact_silesia",
	"mk_fact_sweden",
	"mk_fact_teutonicorder",
	"mk_fact_thessalonica",
	"mk_fact_timurids",
	"mk_fact_tlemcen",
	"mk_fact_toulouse",
	"mk_fact_trebizond",
	"mk_fact_trier",
	"mk_fact_venice",
	"mk_fact_verona",
	"mk_fact_vladimir",
	"mk_fact_volga",
	"mk_fact_wales",
	"mk_fact_wallachia",
	"mk_fact_yotvingians",
	"mk_fact_zagwe",
	"mk_fact_zengids"
};

FACTIONS_WITH_LEADER_IMAGES = {
	"mk_fact_aragon",
	"mk_fact_austria",
	"mk_fact_bavaria",
	"mk_fact_bohemia",
	"mk_fact_bologna",
	"mk_fact_brabant",
	"mk_fact_brandenburg",
	"mk_fact_castile",
	"mk_fact_dauphine",
	"mk_fact_denmark",
	"mk_fact_england",
	"mk_fact_france",
	"mk_fact_friesland",
	"mk_fact_genoa",
	"mk_fact_hansa",
	"mk_fact_hre",
	"mk_fact_hungary",
	"mk_fact_latinempire",
	"mk_fact_lorraine",
	"mk_fact_milan",
	"mk_fact_navarre",
	"mk_fact_pisa",
	"mk_fact_portugal",
	"mk_fact_provence",
	"mk_fact_savoy",
	"mk_fact_saxony",
	"mk_fact_schwyz",
	"mk_fact_sicily",
	"mk_fact_toulouse",
	"mk_fact_trier",
	"mk_fact_verona",
};
