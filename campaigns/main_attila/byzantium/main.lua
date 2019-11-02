--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - BYZANTIUM: MAIN
-- 	By: DETrooper
--
--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

require("byzantium/byzantium_greek_fire");
require("byzantium/byzantium_reconquest");
require("byzantium/byzantium_regions");

EPIRUS_KEY = "mk_fact_epirus";
NICAEA_KEY = "mk_fact_nicaea";
TREBIZOND_KEY = "mk_fact_trebizond";
LATIN_EMPIRE_KEY = "mk_fact_latinempire";

function Byzantium_Initializer()
	Add_Byzantium_Greek_Fire_Listeners();

	if BYZANTINE_EMPIRE_FACTION ~= "NIL" then
		Add_Byzantium_Reconquest_Listeners();
	end
end