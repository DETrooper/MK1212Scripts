-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - KINGDOMS: MAIN
-- 	By: DETrooper
--
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------

require("kingdoms/kingdom_armenia");
require("kingdoms/kingdom_byzantium");
require("kingdoms/kingdom_golden_horde");
require("kingdoms/kingdom_ilkhanate");
require("kingdoms/kingdom_italy");
require("kingdoms/kingdom_poland");
require("kingdoms/kingdom_serbia");
require("kingdoms/kingdom_spain");
require("kingdoms/list_regions");

function Kingdom_Initializer()
	Add_Kingdom_Armenia_Listeners();
	Add_Kingdom_Byzantium_Listeners();
	Add_Kingdom_Golden_Horde_Listeners();
	Add_Kingdom_Ilkhanate_Listeners();
	Add_Kingdom_Italy_Listeners();
	Add_Kingdom_Poland_Listeners();
	Add_Kingdom_Serbia_Listeners();
	Add_Kingdom_Spain_Listeners();
end