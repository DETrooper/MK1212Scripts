-----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - GLOBAL USER INTERFACE CHANGES
-- 	By: DETrooper
--
-----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------

local dev = require("lua_scripts.dev");

SETTLEMENT_PANEL_OPEN = false;

function Add_MK1212_Global_UI_Listeners()
	cm:add_listener(
		"OnComponentLClickUp_Global_UI",
		"ComponentLClickUp",
		true,
		function(context) OnComponentLClickUp_Global_UI(context) end,
		true
	);
	cm:add_listener(
		"OnPanelOpenedCampaign_Global_UI",
		"PanelOpenedCampaign",
		true,
		function(context) OnPanelOpenedCampaign_Global_UI(context) end,
		true
	);
	cm:add_listener(
		"OnPanelClosedCampaign_Global_UI",
		"PanelClosedCampaign",
		true,
		function(context) OnPanelClosedCampaign_Global_UI(context) end,
		true
	);
	cm:add_listener(
		"OnTimeTrigger_Global_UI",
		"TimeTrigger",
		true,
		function(context) OnTimeTrigger_Global_UI(context) end,
		true
	);

	local root = cm:ui_root();
	root:CreateComponent("garbage", "UI/campaign ui/script_dummy");
end

function OnComponentLClickUp_Global_UI(context)

end

function OnPanelOpenedCampaign_Global_UI(context)
	if context.string == "army_details_panel" then
		--cm:add_time_trigger("Resize_Character_Menu", 0.1);
	elseif context.string == "settlement_panel" then
		SETTLEMENT_PANEL_OPEN = true;
	end
end

function OnPanelClosedCampaign_Global_UI(context)
	if context.string == "settlement_panel" then
		SETTLEMENT_PANEL_OPEN = false;
	end
end

function OnTimeTrigger_Global_UI(context)
	if context.string == "Resize_Character_Menu" then
		Resize_Character_Menu();
	end
end

function Resize_Character_Menu()
	local root = cm:ui_root();
	local army_details_panel_uic = UIComponent(root:Find("army_details_panel"));
	army_details_panel_uic:Resize(1440, 900);
end

function Create_Image(component, name)
	local root = cm:ui_root();
	local garbage = UIComponent(root:Find("garbage"));

	garbage:CreateComponent(name.."_throwaway", "UI/new/images/"..name);
	local uic = UIComponent(garbage:Find(name));
	component:Adopt(uic:Address());
	garbage:DestroyChildren();
end
