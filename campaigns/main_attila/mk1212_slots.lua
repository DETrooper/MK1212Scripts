------------------------------------------------------------------------------
------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - SLOTS
-- 	By: DETrooper
--
------------------------------------------------------------------------------
------------------------------------------------------------------------------

local dev = require("lua_scripts/dev");
local svr = ScriptedValueRegistry:new();
local util = require("lua_scripts/util");

DISCLAIMER_ACCEPTED = false;

function Add_MK1212_Slots_Listeners()
	cm:add_listener(
		"OnComponentLClickUp_Slots_UI",
		"ComponentLClickUp",
		true,
		function(context) OnComponentLClickUp_Slots_UI(context) end,
		true
	);
	cm:add_listener(
		"OnSettlementSelected_Slots_UI",
		"SettlementSelected",
		true,
		function(context) OnSettlementSelected_Slots_UI(context) end,
		true
	);
	cm:add_listener(
		"OnPanelOpenedCampaign_Slots_UI",
		"PanelOpenedCampaign",
		true,
		function(context) OnPanelOpenedCampaign_Slots_UI(context) end,
		true
	);
	cm:add_listener(
		"TimeTrigger_Slots_UI",
		"TimeTrigger",
		true,
		function(context) TimeTrigger_Slots_UI(context) end,
		true
	);

	if util.fileExists("MK1212_config.txt") == true then
		if dev.settings["disclaimerAccepted"] then
			if tonumber(dev.settings["disclaimerAccepted"]) == 1 then
				DISCLAIMER_ACCEPTED = true;
			end
		end
	end

	CreateDisclaimerPrompt();
end

function OnComponentLClickUp_Slots_UI(context)
	if SETTLEMENT_PANEL_OPEN == true then
		local root = cm:ui_root();

		if context.string == "button_exe_ok" then
			local button_disclaimer_uic = UIComponent(root:Find("button_disclaimer"));
			local button_discord_uic = UIComponent(root:Find("button_discord"));
			local disclaimer_prompt_uic = UIComponent(root:Find("disclaimer_prompt"));

			ModifyHardcodedLimits();
			RefreshProvinceSelection();
			dev.changeSetting("MK1212_config.txt", "disclaimerAccepted", 1);

			button_disclaimer_uic:SetVisible(false);
			button_discord_uic:SetState("active");
			disclaimer_prompt_uic:SetVisible(false);
		elseif context.string == "button_disclaimer" then
			local disclaimer_prompt_uic = UIComponent(root:Find("disclaimer_prompt"));

			if disclaimer_prompt_uic:Visible() == true then
				disclaimer_prompt_uic:SetVisible(false);
			else
				disclaimer_prompt_uic:SetVisible(true);
			end
		elseif context.string == "root" or context.string == "button_exe_cancel" then
			local disclaimer_prompt_uic = UIComponent(root:Find("disclaimer_prompt"));

			if disclaimer_prompt_uic:Visible() == true then
				disclaimer_prompt_uic:SetVisible(false);
			end
		end
	end
end

function OnSettlementSelected_Slots_UI(context)
	if SETTLEMENT_PANEL_OPEN == true then
		local region_owning_faction = context:garrison_residence():region():owning_faction();

		if region_owning_faction:name() == cm:get_local_faction() then
			cm:add_time_trigger("Show_Slots_Button", 0);
		end
	end
end

function OnPanelOpenedCampaign_Slots_UI(context)
	if REGION_SELECTED ~= "" then
		local region = cm:model():world():region_manager():region_by_key(REGION_SELECTED);

		if region:owning_faction():name() == cm:get_local_faction() then
			local root = cm:ui_root();
			local disclaimer_prompt_uic = UIComponent(root:Find("disclaimer_prompt"));

			if disclaimer_prompt_uic:Visible() == true then
				disclaimer_prompt_uic:SetVisible(false);
			end

			if context.string == "settlement_panel" then
				if DISCLAIMER_ACCEPTED == false then
					local main_settlement_panel_uic = UIComponent(root:Find("main_settlement_panel"));
					local button_disclaimer_uic = UIComponent(main_settlement_panel_uic:Find("button_disclaimer"));

					if util.fileExists("MK1212_config.txt") == true then
						if dev.settings["disclaimerAccepted"] then
							if tonumber(dev.settings["disclaimerAccepted"]) == 0 then
								button_disclaimer_uic:SetVisible(true);
							end
						else
							dev.changeSetting("MK1212_config.txt", "disclaimerAccepted", 0);
							button_disclaimer_uic:SetVisible(true);
						end
					else
						dev.writeSettings("MK1212_config.txt");
						button_disclaimer_uic:SetVisible(true);
					end
				end
			end
		end
	end
end

function TimeTrigger_Slots_UI(context)
	if context.string == "Refresh_Province_Selection" then
		local root = cm:ui_root();
		local layout_uic = UIComponent(root:Find("layout"));
		local bar_small_top_uic = UIComponent(layout_uic:Find("bar_small_top"));
		local tab_regions_uic = UIComponent(bar_small_top_uic:Find("tab_regions"));
		local regions_dropdown_uic = UIComponent(root:Find("regions_dropdown"));
		local region_province = REGIONS_TO_PROVINCES_LIST[REGION_SELECTED];
		local player_provinces_uic = UIComponent(regions_dropdown_uic:Find("player_provinces"));
		local list_box_uic = UIComponent(player_provinces_uic:Find("list_box"));

		for i = 0, list_box_uic:ChildCount() - 1 do
			local child = UIComponent(list_box_uic:Find(i));

			if child:Id() == "row_entry_"..region_province then
				child:SimulateClick();
			end
		end

		tab_regions_uic:SimulateClick();
	elseif context.string == "Refresh_Province_Selection_No_Close" then
		local root = cm:ui_root();
		local regions_dropdown_uic = UIComponent(root:Find("regions_dropdown"));
		local region_province = REGIONS_TO_PROVINCES_LIST[REGION_SELECTED];
		local player_provinces_uic = UIComponent(regions_dropdown_uic:Find("player_provinces"));
		local list_box_uic = UIComponent(player_provinces_uic:Find("list_box"));

		for i = 0, list_box_uic:ChildCount() - 1 do
			local child = UIComponent(list_box_uic:Find(i));

			if child:Id() == "row_entry_"..region_province then
				child:SimulateClick();
			end
		end
	elseif context.string == "Show_Slots_Button" then
		local root = cm:ui_root();
		local disclaimer_prompt_uic = UIComponent(root:Find("disclaimer_prompt"));

		if disclaimer_prompt_uic:Visible() == true then
			disclaimer_prompt_uic:SetVisible(false);
		end

		if DISCLAIMER_ACCEPTED == false then
			local main_settlement_panel_uic = UIComponent(root:Find("main_settlement_panel"));
			local button_disclaimer_uic = UIComponent(main_settlement_panel_uic:Find("button_disclaimer"));

			if util.fileExists("MK1212_config.txt") == true then
				if dev.settings["disclaimerAccepted"] then
					if tonumber(dev.settings["disclaimerAccepted"]) == 0 then
						button_disclaimer_uic:SetVisible(true);
					end
				else
					dev.changeSetting("MK1212_config.txt", "disclaimerAccepted", 0);
					button_disclaimer_uic:SetVisible(true);
				end
			else
				dev.writeSettings("MK1212_config.txt");
				button_disclaimer_uic:SetVisible(true);
			end
		end
	end
end

function CreateDisclaimerPrompt()
	local root = cm:ui_root();

	root:CreateComponent("disclaimer_prompt", "ui/new/popup_disclaimer_prompt");

	local disclaimer_prompt_uic = UIComponent(root:Find("disclaimer_prompt"));

	disclaimer_prompt_uic:SetVisible(false);
end

function ModifyHardcodedLimits()
	DISCLAIMER_ACCEPTED = true;

	if not util.fileExists("MK1212_10slots.exe") then
		require("lua_scripts/slots_binaries");

		local slotsFile = io.open("MK1212_10slots.exe", "wb");
		local binary = "";
			
		for i = 1, #slots_binaries do
			local number = tonumber("0x"..slots_binaries[i]);
			local char = string.char(number);

			binary = binary..char;
		end

		slotsFile:write(binary);
		slotsFile:close();
	end

	local command = "MK1212_10slots.exe";

	os.execute(command);

	svr:SaveBool("SBOOL_Prompt_Already_Shown", true);
end

function RefreshProvinceSelection()
	if SETTLEMENT_PANEL_OPEN == true and REGION_SELECTED ~= "" then
		local root = cm:ui_root();
		local layout_uic = UIComponent(root:Find("layout"));
		local bar_small_top_uic = UIComponent(layout_uic:Find("bar_small_top"));
		local tab_regions_uic = UIComponent(bar_small_top_uic:Find("tab_regions"));
		local regions_dropdown_uic = UIComponent(root:Find("regions_dropdown"));

		if tab_regions_uic:CurrentState() == "selected" then
			-- Region dropdown panel already open.
			cm:add_time_trigger("Refresh_Province_Selection_No_Close", 0.5);
		else
			tab_regions_uic:SimulateClick();
			cm:add_time_trigger("Refresh_Province_Selection", 0.5);
		end
	end
end
