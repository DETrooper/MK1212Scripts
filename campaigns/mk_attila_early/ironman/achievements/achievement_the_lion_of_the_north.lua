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
	"mk_reg_aix-en-provence",
	"mk_reg_antwerp",
	"mk_reg_bern",
	"mk_reg_bologna",
	"mk_reg_brandenburg",
	"mk_reg_braunschweig",
	"mk_reg_erfut",
	"mk_reg_frankfurt",
	"mk_reg_genoa",
	"mk_reg_graz",
	"mk_reg_groningen",
	"mk_reg_heidelberg",
	"mk_reg_koln",
	"mk_reg_konstanz",
	"mk_reg_lubeck",
	"mk_reg_milan",
	"mk_reg_munich",
	"mk_reg_nancy",
	"mk_reg_nuremberg",
	"mk_reg_pisa",
	"mk_reg_prague",
	"mk_reg_stralsund",
	"mk_reg_trier",
	"mk_reg_turin",
	"mk_reg_verona",
	"mk_reg_vienna",
	"mk_reg_vienne",
	"mk_reg_wittenberg"
};
achievement.unlocked = false;
achievement.unlocktime = "";

return achievement;
