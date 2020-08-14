------------------------------------------------------------------------------
------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - SLOTS
-- 	By: DETrooper
--
------------------------------------------------------------------------------
------------------------------------------------------------------------------

local dev = require("lua_scripts/dev");
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
		"OnPanelOpenedCampaign_Slots_UI",
		"PanelOpenedCampaign",
		true,
		function(context) OnPanelOpenedCampaign_Slots_UI(context) end,
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

function OnPanelOpenedCampaign_Slots_UI(context)
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
end
