---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - COMMON UI: GLOBAL USER INTERFACE
-- 	By: DETrooper
--
---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------

local convert_panel_open = false;
local settlement_panel_open = false;

DIPLOMACY_SELECTED_FACTION = nil;
DIPLOMACY_PANEL_OPEN = false;

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
	elseif DIPLOMACY_PANEL_OPEN == true then
		if context.string == "map" or context.string == "button_icon" then
			cm:add_time_trigger("diplo_hud_check", 0.0);
		elseif string.find(context.string, "faction_row_entry_") then
			local faction_name = string.gsub(context.string, "faction_row_entry_", "");

			DIPLOMACY_SELECTED_FACTION = faction_name;
		end
	end
end

function OnPanelOpenedCampaign_Global_UI(context)
	if context.string == "settlement_panel" then
		settlement_panel_open = true;
	elseif context.string == "diplomacy_dropdown" then
		DIPLOMACY_PANEL_OPEN = true;

		cm:add_time_trigger("diplo_hud_check", 0.0);
	end
end

function OnPanelClosedCampaign_Global_UI(context)
	if context.string == "settlement_panel" then
		settlement_panel_open = false;
	elseif context.string == "diplomacy_dropdown" then
		DIPLOMACY_PANEL_OPEN = false;
	end
end

function OnTimeTrigger_Global_UI(context)
	if context.string == "disable_navy_recruitment" then
		Disable_Naval_Recruitment();
	elseif context.string == "religion_possibly_changed" then
		Religion_Possibly_Changed(cm:get_local_faction());
	elseif context.string == "diplo_hud_check" then
		local root = cm:ui_root();
		local diplomacy_dropdown_uic = UIComponent(root:Find("diplomacy_dropdown"));

		Diplomacy_Hud_Check(diplomacy_dropdown_uic);
	end
end

function Disable_Naval_Recruitment()
	local root = cm:ui_root();
	local button_raise_fleet_uic = UIComponent(root:Find("button_raise_fleet"));
	button_raise_fleet_uic:SetState("inactive");
end

function Diplomacy_Hud_Check(diplomacy_dropdown_uic)
	local faction_name = nil;
	local faction_panel_uic = UIComponent(diplomacy_dropdown_uic:Find("faction_panel"));
	local sortable_list_factions_uic = UIComponent(faction_panel_uic:Find("sortable_list_factions"));
	local list_box_uic = UIComponent(sortable_list_factions_uic:Find("list_box"));

	for i = 0, list_box_uic:ChildCount() - 1 do
		local child = UIComponent(list_box_uic:Find(i));

		if child:CurrentState() == "selected" or child:CurrentState() == "selected_hover" then
			faction_name = string.gsub(child:Id(), "faction_row_entry_", "");

			DIPLOMACY_SELECTED_FACTION = faction_name;
			return;
		end
	end

	if faction_name == nil then
		-- Something went wrong or there's only one faction left (the player's).
		if list_box_uic:ChildCount() > 0 then
			local child = UIComponent(list_box_uic:Find(0));
			faction_name = string.gsub(child:Id(), "faction_row_entry_", "");

			DIPLOMACY_SELECTED_FACTION = faction_name;
		else
			DIPLOMACY_SELECTED_FACTION = cm:get_local_faction();
		end
	end
end

function Religion_Possibly_Changed(faction_name)
	local faction = cm:model():world():faction_by_key(faction_name);

	if PAPAL_FAVOUR_SYSTEM_ACTIVE == true then
		if faction:state_religion() == "att_rel_chr_catholic" then
			if faction_name == CURRENT_CRUSADE_TARGET_OWNER then
				End_Crusade("aborted");
			end

			Update_Pope_Favour(faction);
		elseif FACTION_POPE_FAVOUR[faction_name] ~= nil then
			FACTION_POPE_FAVOUR[faction_name] = nil;

			for i = 0, 10 do
				cm:remove_effect_bundle("mk_bundle_pope_favour_"..i, faction_name);
			end
	
			Remove_Excommunication_Manual(faction_name);
	
			if faction:is_human() then 
				if cm:is_multiplayer() == false then
					Remove_Decision("ask_pope_for_money");
				end

				if MISSION_TAKE_JERUSALEM_ACTIVE == true then
					MISSION_TAKE_JERUSALEM_ACTIVE = false;
					cm:remove_listener("CharacterEntersGarrison_Jerusalem");
					cm:cancel_custom_mission(faction_name, "mk_mission_crusades_take_jerusalem_dilemma");
					Make_Peace_Crusades(faction_name);
				end
			end

			if HasValue(CURRENT_CRUSADE_FACTIONS_JOINED, faction_name) then
				Remove_Faction_From_Crusade(faction_name);
			end
		end
	end
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

				if hundredth < 4 then
					if tenth == 0 then
						if hundredth == 0 then
							return string.sub(number, 0, i - 1);
						else
							return string.sub(number, 0, i + 2);
						end
					else
						return string.sub(number, 0, i + 1);
					end
				elseif hundredth > 6 then
					number = string.sub(number, 0, i - 1);
					
					if tenth == 9 then
						local new_num = tonumber(number) + 1;

						return tostring(new_num);
					else
						tenth = tenth + 1;

						return number.."."..tostring(tenth);
					end
				else
					return string.sub(number, 0, i + 1).."5";
				end
			end
		end
	end

	return number;
end