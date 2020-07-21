--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: MAIN
-- 	By: DETrooper
--
--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

require("mechanics/mechanics_lists");

require("mechanics/mechanics_annex_vassals");
require("mechanics/mechanics_buffer_states");
require("mechanics/mechanics_dynamic_faction_names");
require("mechanics/mechanics_plague");
require("mechanics/mechanics_settle_upkeep");
require("mechanics/mechanics_silk_road");
require("mechanics/mechanics_war_weariness");

require("mechanics/pope/mechanics_pope");
require("mechanics/decisions/mechanics_decisions");
require("mechanics/hre/mechanics_hre");
require("mechanics/population/mechanics_population");

function Mechanic_Initializer()
	if cm:is_multiplayer() == false then
		Add_Annex_Vassals_Listeners();
		Add_Buffer_States_Listeners();
		Add_Decisions_Listeners();
		Add_Dynamic_Faction_Names_Listeners();
		Add_HRE_Listeners();
		Add_Plague_Listeners();
		Add_Pope_Listeners();
		Add_Population_Listeners();
		Add_Settle_Upkeep_Listeners();
		Add_Silk_Road_Listeners();
		Add_War_Weariness_Listeners();
	else
		Add_Dynamic_Faction_Names_Listeners();
		Add_Plague_Listeners();
		Add_Pope_Listeners();
		Add_Settle_Upkeep_Listeners();
		Add_Silk_Road_Listeners();
		Add_War_Weariness_Listeners();

		-- Ensure annex vassal button is disabled in multiplayer, haven't figured out how to default it to disabled via hex-editing yet.
		cm:add_listener(
			"OnPanelOpenedCampaign_Multiplayer_UI",
			"PanelOpenedCampaign",
			true,
			function(context) OnPanelOpenedCampaign_Multiplayer_UI(context) end,
			true
		);
	end
end

function OnPanelOpenedCampaign_Multiplayer_UI(context)
	if context.string == "diplomacy_dropdown" then
		local root = cm:ui_root();
		local diplomacy_dropdown_uic = UIComponent(root:Find("diplomacy_dropdown"));
		local btnAnnex = UIComponent(diplomacy_dropdown_uic:Find("button_annex_vassal"));

		btnAnnex:SetStateText("");
		btnAnnex:SetState("inactive");
	end
end
