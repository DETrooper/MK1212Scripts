--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: HOLY ROMAN EMPIRE
-- 	By: DETrooper
--
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

require("mechanics/hre/mechanics_hre_factions");
require("mechanics/hre/mechanics_hre_lists");

require("mechanics/hre/mechanics_hre_elections");
require("mechanics/hre/mechanics_hre_reforms");
require("mechanics/hre/mechanics_hre_ui");

function Add_HRE_Listeners()
	Add_HRE_Faction_Listeners();

	Add_HRE_Election_Listeners();
	Add_HRE_Reform_Listeners();
	Add_HRE_UI_Listeners();
end