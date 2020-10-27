----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - COMMON: MAIN
-- 	By: DETrooper
--
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

require("common/mk1212_common");
require("common/mk1212_common_lists");

require("common/mk1212_campaign_cutscenes");
require("common/mk1212_localisation_lists");
require("common/mk1212_update_region_loc");
require("common/mk1212_vassal_tracking");

require("common/ui/mk1212_global_ui");
require("common/ui/mk1212_occupation_decisions");
require("common/ui/mk1212_unit_information");

function Common_Initializer()
	Add_MK1212_Common_Listeners();

	Add_MK1212_Campaign_Cutscene_Listeners();
	Add_MK1212_Global_UI_Listeners();
	Add_MK1212_Update_Region_Name_Listeners();
	Add_MK1212_Occupation_Decision_Listeners();
	Add_MK1212_Unit_Information_Listeners();
	Add_MK1212_Vassal_Tracking_Listeners();
end
