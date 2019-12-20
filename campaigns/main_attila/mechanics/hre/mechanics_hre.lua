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
	--Add_HRE_Faction_Listeners();
	--Add_HRE_Election_Listeners();
	--Add_HRE_Reform_Listeners();
	--Add_HRE_UI_Listeners();

	HRE_Button_Check();
end

function HRE_Button_Check()
	local faction_name = cm:get_local_faction();

	if not HasValue(FACTIONS_HRE, faction_name) then
		local root = cm:ui_root();
		local btnHRE = UIComponent(root:Find("button_hre"));

		btnHRE:SetVisible(false);
	end
end