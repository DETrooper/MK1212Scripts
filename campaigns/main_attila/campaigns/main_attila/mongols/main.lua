-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MONGOLS: MAIN
-- 	By: DETrooper
--
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

-- faction arrays 53 and 54

require("mongols/mongol_invasion");
require("mongols/mongol_lists");
--require("mongols/mongol_ui");

function Mongol_Initializer()
	Add_Mongol_Invasion_Listeners();
	--Add_Mongol_UI_Listeners();
end