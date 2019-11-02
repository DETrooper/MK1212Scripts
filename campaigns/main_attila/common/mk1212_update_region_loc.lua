---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - UPDATE REGION LOCALISATION
-- 	By: DETrooper
--
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
-- This file's sole purpose is to update the REGIONS_NAMES_LOCALISATION list when players rename their cities.

function Add_MK1212_Update_Region_Name_Listeners()
	cm:add_listener(
		"OnComponentLClickUp_Update_Region_Name_UI",
		"ComponentLClickUp",
		true,
		function(context) OnComponentLClickUp_Update_Region_Name_UI(context) end,
		true
	);
	cm:add_listener(
		"OnPanelClosedCampaign_Update_Region_Name_UI",
		"PanelClosedCampaign",
		true,
		function(context) OnPanelClosedCampaign_Update_Region_Name_UI(context) end,
		true
	);
end

function OnComponentLClickUp_Update_Region_Name_UI(context)
	if context.string == "button_ok" then
		if UIComponent(UIComponent(context.component):Parent()):Id() == "province_details_panel" then
			Update_Region_Localisation();
		end
	end
end

function OnPanelClosedCampaign_Update_Region_Name_UI(context)
	if context.string == "province_details_panel" then
		Update_Region_Localisation();
	end
end

function Update_Region_Localisation()
	local root = cm:ui_root();
	local province_details_panel_uic = UIComponent(root:Find("province_details_panel"));
	local region_list_uic = UIComponent(province_details_panel_uic:Find("region_list"));

	local region_1_key = UIComponent(region_list_uic:Find(0)):Id();
	local region_1_name = UIComponent(UIComponent(region_list_uic:Find(0)):Find("name")):GetStateText();

	-- This code is not needed anymore since there is only 1 region per province now.
	--[[local region_2_key = UIComponent(region_list_uic:Find(1)):Id();
	local region_2_name = UIComponent(UIComponent(region_list_uic:Find(1)):Find("name")):GetStateText();
	local region_3_key = UIComponent(region_list_uic:Find(2)):Id();
	local region_3_name = UIComponent(UIComponent(region_list_uic:Find(2)):Find("name")):GetStateText();]]--

	REGIONS_NAMES_LOCALISATION[region_1_key] = region_1_name;
	--[[REGIONS_NAMES_LOCALISATION[region_2_key] = region_2_name;
	REGIONS_NAMES_LOCALISATION[region_3_key] = region_3_name;]]--
end

------------------------------------------------
---------------- Saving/Loading ----------------
------------------------------------------------
cm:register_loading_game_callback(
	function(context)
		if not cm:is_new_game() then
			REGIONS_NAMES_LOCALISATION = LoadKeyPairTable(context, "REGIONS_NAMES_LOCALISATION");
		end
	end
);

cm:register_saving_game_callback(
	function(context)
		SaveKeyPairTable(context, REGIONS_NAMES_LOCALISATION, "REGIONS_NAMES_LOCALISATION");
	end
);