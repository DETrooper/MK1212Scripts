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
	if context.string == "button_create_army" then
		cm:add_time_trigger("disable_navy_recruitment", 0.0);
	end
end

function OnPanelOpenedCampaign_Global_UI(context)
	if context.string == "settlement_panel" then
		SETTLEMENT_PANEL_OPEN = true;
	end
end

function OnPanelClosedCampaign_Global_UI(context)
	if context.string == "settlement_panel" then
		SETTLEMENT_PANEL_OPEN = false;
	end
end

function OnTimeTrigger_Global_UI(context)
	if context.string == "disable_navy_recruitment" then
		Disable_Naval_Recruitment();
	end
end

function Disable_Naval_Recruitment()
	local root = cm:ui_root();
	local button_raise_fleet_uic = UIComponent(root:Find("button_raise_fleet"));
	button_raise_fleet_uic:SetState("inactive");
end

function Create_Image(component, name)
	local root = cm:ui_root();
	local garbage = UIComponent(root:Find("garbage"));

	garbage:CreateComponent(name.."_throwaway", "UI/new/images/"..name);
	local uic = UIComponent(garbage:Find(name));
	component:Adopt(uic:Address());
	garbage:DestroyChildren();
end

function Round_Number_Text(number)
	-- Attila really doesn't like floats, so this does some rounding for the purposes of displaying floating point numbers as text.
	local number = tostring(number);

	for i = 1, string.len(number) do
		local char = string.sub(number, i, i);

		if char == "." then
			local tenth = string.sub(number, i + 1, i + 1);
			local hundredth = string.sub(number, i + 2, i + 2);
			
			tenth = tonumber(tenth);
			hundredth = tonumber(hundredth);
			
			if hundredth < 5 then
				if tenth == 0 then
					number = string.sub(number, 0, i - 1);
					return number;
				end
			elseif hundredth >= 5 then
				if tenth ~= 9 then
					tenth = tenth + 1;
				else
					number = string.sub(number, 0, i - 1);
					
					local new_num = tonumber(number) + 1;
					return tostring(new_num);
				end
			else
				number = string.sub(number, 0, i - 1);
				return number;
			end
			
			number = string.sub(number, 0, i)..tostring(tenth);
			return number;
		end
	end

	return number;
end
