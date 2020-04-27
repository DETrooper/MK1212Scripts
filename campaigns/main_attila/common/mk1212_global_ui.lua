-----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - GLOBAL USER INTERFACE CHANGES
-- 	By: DETrooper
--
-----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------

local convert_panel_open = false;
local settlement_panel_open = false;

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
	elseif context.string == "button_convert" then
		convert_panel_open = true;
	elseif convert_panel_open == true then
		if context.string == "button_tick" or context.string == "button_cancel" or context.string == "clan" then
			cm:add_time_trigger("religion_possibly_changed", 0.0);
			convert_panel_open = false;
		end
	end
end
function OnPanelOpenedCampaign_Global_UI(context)
	if context.string == "settlement_panel" then
		settlement_panel_open = true;
	end
end

function OnPanelClosedCampaign_Global_UI(context)
	if context.string == "settlement_panel" then
		settlement_panel_open = false;
	end
end

function OnTimeTrigger_Global_UI(context)
	if context.string == "disable_navy_recruitment" then
		Disable_Naval_Recruitment();
	elseif context.string == "religion_possibly_changed" then
		Religion_Possibly_Changed(cm:get_local_faction());
	end
end

function Disable_Naval_Recruitment()
	local root = cm:ui_root();
	local button_raise_fleet_uic = UIComponent(root:Find("button_raise_fleet"));
	button_raise_fleet_uic:SetState("inactive");
end

function Religion_Possibly_Changed(faction_name)
	local faction = cm:model():world():faction_by_key(faction_name);

	if PAPAL_FAVOUR_SYSTEM_ACTIVE == true then
		if faction:state_religion() == "att_rel_chr_catholic" then
			if faction_name == CURRENT_CRUSADE_TARGET then
				End_Crusade("aborted");
			end

			Update_Pope_Favour(faction);
		elseif PLAYER_POPE_FAVOUR[faction_name] ~= nil then
			PLAYER_POPE_FAVOUR[faction_name] = nil;

			for i = 0, 10 do
				cm:remove_effect_bundle("mk_bundle_pope_favour_"..i, faction_name);
			end
	
			Remove_Excommunication_Manual(faction_name);
	
			if faction:is_human() and cm:is_multiplayer() == false then
				Remove_Decision("ask_pope_for_money");
			end

			if HasValue(CURRENT_CRUSADE_FACTIONS_JOINED, faction_name) then
				Remove_Faction_From_Crusade(faction_name);
			end
		end
	end
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
			if string.len(number) >= i + 2 then
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
				break;
			end
		end
	end

	return number;
end
