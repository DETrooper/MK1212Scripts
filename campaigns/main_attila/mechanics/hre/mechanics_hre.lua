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
require("mechanics/hre/mechanics_hre_decrees");
require("mechanics/hre/mechanics_hre_elections");
require("mechanics/hre/mechanics_hre_events");
require("mechanics/hre/mechanics_hre_reforms");
require("mechanics/hre/mechanics_hre_regions");
require("mechanics/hre/mechanics_hre_ui");

function Add_HRE_Listeners()
	if CURRENT_HRE_REFORM < 9 then
		Add_HRE_Faction_Listeners();
		Add_HRE_Decrees_Listeners();
		Add_HRE_Election_Listeners();
		Add_HRE_Event_Listeners();
		Add_HRE_Reforms_Listeners();
		Add_HRE_Region_Listeners();
		Add_HRE_UI_Listeners();
	end

	HRE_Button_Check();
end

function HRE_Button_Check()
	local root = cm:ui_root();
	local btnHRE = UIComponent(root:Find("button_hre"));
	local faction_name = cm:get_local_faction();

	if (HasValue(HRE_FACTIONS, faction_name) or faction_name == HRE_EMPEROR_PRETENDER_KEY) and CURRENT_HRE_REFORM ~= 9 then
		btnHRE:SetVisible(true);
	else
		btnHRE:SetVisible(false);
	end
end
