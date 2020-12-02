---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - COMMON UI: GLOBAL USER INTERFACE
-- 	By: DETrooper
--
---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------

require("common/ui/mk1212_global_ui_lists");

local convert_panel_open = false;

DIPLOMACY_SELECTED_FACTION = nil;
DIPLOMACY_PANEL_OPEN = false;
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

	Disable_Abandoning_Settlements();
	Disable_Naval_Recruitment();
	
	local root = cm:ui_root();
	root:CreateComponent("garbage", "UI/campaign ui/script_dummy");
end

function OnComponentLClickUp_Global_UI(context)
	if context.string == "button_convert" then
		convert_panel_open = true;
	elseif context.string == "Summary" then
		cm:add_time_trigger("Faction_Panel_Convert_Check", 0.0); -- Some regions shouldn't be convertable to, like Catholic Heresies.
	elseif convert_panel_open == true then
		if cm:is_multiplayer() == false then
			if context.string == "button_tick" or context.string == "button_cancel" or context.string == "clan" then
				cm:add_time_trigger("religion_possibly_changed", 0.0);
				convert_panel_open = false;
			end
		end
	elseif DIPLOMACY_PANEL_OPEN == true then
		if context.string == "map" or context.string == "button_icon" or context.string == "flag" then
			cm:add_time_trigger("diplo_hud_check", 0.0);
		elseif string.find(context.string, "faction_row_entry_") then
			local faction_name = string.gsub(context.string, "faction_row_entry_", "");

			DIPLOMACY_SELECTED_FACTION = faction_name;
		end
	end
end

function OnPanelOpenedCampaign_Global_UI(context)
	if context.string == "settlement_panel" then
		SETTLEMENT_PANEL_OPEN = true;
	elseif context.string == "diplomacy_dropdown" then
		DIPLOMACY_PANEL_OPEN = true;

		cm:add_time_trigger("diplo_hud_check", 0.0);
	elseif context.string == "clan" then
		cm:add_time_trigger("Faction_Panel_Convert_Check", 0.0);
	end
end

function OnPanelClosedCampaign_Global_UI(context)
	if context.string == "settlement_panel" then
		SETTLEMENT_PANEL_OPEN = false;
	elseif context.string == "diplomacy_dropdown" then
		DIPLOMACY_PANEL_OPEN = false;
		DIPLOMACY_SELECTED_FACTION = nil;
	end
end

function OnTimeTrigger_Global_UI(context)
	if context.string == "religion_possibly_changed" then
		Religion_Check(cm:model():world():faction_by_key(cm:get_local_faction()));
	elseif context.string == "diplo_hud_check" then
		local root = cm:ui_root();
		local diplomacy_dropdown_uic = UIComponent(root:Find("diplomacy_dropdown"));

		Diplomacy_Hud_Check(diplomacy_dropdown_uic);
	elseif context.string == "Faction_Panel_Convert_Check" then
		local root = cm:ui_root();
		local tab_summary_uic = UIComponent(root:Find("Summary"));
		local details_uic = UIComponent(tab_summary_uic:Find("details"));
		local religion_list_uic = UIComponent(details_uic:Find("religion_list"));
		
		for i = 0, religion_list_uic:ChildCount() - 1 do
			local child = UIComponent(religion_list_uic:Find(i));

			if child:Id() == "att_rel_other" then
				local button_convert_uic = UIComponent(child:Find("button_convert"));

				button_convert_uic:SetVisible(false);
			end
		end
	end
end

function Disable_Abandoning_Settlements()
	--ui_state.migration:set_allowed(false);
	ui_state.abandon_settlements:set_allowed(false);	
end

function Disable_Naval_Recruitment()
	ui_state.enlist_navy:set_allowed(false);
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
