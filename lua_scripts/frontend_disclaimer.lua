---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - SLOT INCREASER DISCLAIMER (FRONTEND)
-- 	By: DETrooper
--
---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------

local dev = require("lua_scripts/dev");
local util = require("lua_scripts/util");

eh:add_listener(
	"OnUICreated_Disclaimer",
	"UICreated",
	true,
	function(context) OnUICreated_Disclaimer(context) end,
	true
);
eh:add_listener(
	"OnFrontendScreenTransition_Disclaimer",
	"FrontendScreenTransition",
	true,
	function(context) OnFrontendScreenTransition_Disclaimer(context) end,
	true
);
eh:add_listener(
	"OnComponentLClickUp_Disclaimer",
	"ComponentLClickUp",
	true,
	function(context) OnComponentLClickUp_Disclaimer(context) end,
	true
);

function OnUICreated_Disclaimer(context)
	CreateDisclaimerPrompt();

	if not svr:LoadBool("SBOOL_Prompt_Already_Shown") then
		if util.fileExists("MK1212_config.txt") == true then
			if dev.settings["disclaimerAccepted"] then
				if tonumber(dev.settings["disclaimerAccepted"]) == 0 then
					ShowDisclaimerPrompt();
				else
					ModifyHardcodedLimits();
				end
			else
				dev.changeSetting("MK1212_config.txt", "disclaimerAccepted", 0);
				ShowDisclaimerPrompt();
			end
		else
			dev.writeSettings("MK1212_config.txt");
			ShowDisclaimerPrompt();
		end
	end
end;

function OnFrontendScreenTransition_Disclaimer(context)
	local disclaimer_prompt_uic = UIComponent(m_root:Find("disclaimer_prompt"));

	if disclaimer_prompt_uic:Visible() == true then
		disclaimer_prompt_uic:SetVisible(false);
		disclaimer_prompt_uic:UnLockPriority();
	end
end;

function OnComponentLClickUp_Disclaimer(context)
	if context.string == "button_exe_ok" then
		local button_discord_uic = UIComponent(m_root:Find("button_discord"));
		local disclaimer_prompt_uic = UIComponent(m_root:Find("disclaimer_prompt"));

		ModifyHardcodedLimits();
		dev.changeSetting("MK1212_config.txt", "disclaimerAccepted", 1);

		button_discord_uic:SetState("active");
		disclaimer_prompt_uic:SetVisible(false);
		disclaimer_prompt_uic:UnLockPriority();
	elseif context.string == "button_home" or context.string == "button_quit" then
		local disclaimer_prompt_uic = UIComponent(m_root:Find("disclaimer_prompt"));

		if disclaimer_prompt_uic:Visible() == true then
			disclaimer_prompt_uic:SetVisible(false);
			disclaimer_prompt_uic:UnLockPriority();

			svr:SaveBool("SBOOL_Prompt_Already_Shown", true);
		end
	elseif context.string == "button_exe_cancel" then
		local button_discord_uic = UIComponent(m_root:Find("button_discord"));
		local disclaimer_prompt_uic = UIComponent(m_root:Find("disclaimer_prompt"));

		button_discord_uic:SetState("active");

		if disclaimer_prompt_uic:Visible() == true then
			disclaimer_prompt_uic:SetVisible(false);
			disclaimer_prompt_uic:UnLockPriority();
		end

		svr:SaveBool("SBOOL_Prompt_Already_Shown", true);
	end
end;

function CreateDisclaimerPrompt()
	m_root:CreateComponent("disclaimer_prompt", "ui/new/popup_disclaimer_prompt");

	local disclaimer_prompt_uic = UIComponent(m_root:Find("disclaimer_prompt"));

	disclaimer_prompt_uic:SetVisible(false);
end

function ModifyHardcodedLimits()
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

	svr:SaveBool("SBOOL_Prompt_Already_Shown", true);
	svr:SaveBool("SBOOL_Hardcoded_Limits_Modified", true);

	local command = "MK1212_10slots.exe";

	os.execute(command);
end

function ShowDisclaimerPrompt()
	local button_discord_uic = UIComponent(m_root:Find("button_discord"));
	local disclaimer_prompt_uic = UIComponent(m_root:Find("disclaimer_prompt"));

	button_discord_uic:SetState("inactive");
	disclaimer_prompt_uic:SetVisible(true);
	disclaimer_prompt_uic:LockPriority(500);
end
