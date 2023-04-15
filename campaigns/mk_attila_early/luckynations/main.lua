-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - LUCKY NATIONS: MAIN
-- 	By: DETrooper
--
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------

require("luckynations/lucky_nations");

LUCKY_NATIONS = {
	"mk_fact_austria",
	"mk_fact_castile",
	"mk_fact_england",
	"mk_fact_france",
	"mk_fact_goldenhorde",
	"mk_fact_ilkhanate",
	"mk_fact_lesserpoland",
	"mk_fact_lithuania",
	"mk_fact_mamluks",
	"mk_fact_ottoman",
	"mk_fact_teutonicorder",
	"mk_fact_timurids",
	"mk_fact_venice",
	"mk_fact_vladimir"
};

function Lucky_Nations_Initializer()
	Add_Lucky_Nations_Listeners();
end
