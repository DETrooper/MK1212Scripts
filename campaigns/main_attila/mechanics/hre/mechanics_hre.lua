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

HRE_DESTROYED = false;

function Add_HRE_Listeners()
	if not HRE_DESTROYED then
		if CURRENT_HRE_REFORM < 9 then
			Add_HRE_Faction_Listeners();
			Add_HRE_Decrees_Listeners();
			Add_HRE_Election_Listeners();
			Add_HRE_Event_Listeners();
			Add_HRE_Reforms_Listeners();
			Add_HRE_Region_Listeners();
			Add_HRE_UI_Listeners();
		end
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

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		cm:save_value("HRE_DESTROYED", HRE_DESTROYED, context);
	end
);

cm:register_loading_game_callback(
	function(context)
		HRE_DESTROYED = cm:load_value("HRE_DESTROYED", false, context);
	end
);
