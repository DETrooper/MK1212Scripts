---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - DISCORD INVITE BUTTON (FRONTEND)
-- 	By: DETrooper
--
---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------

eh:add_listener(
	"OnUICreated_Discord",
	"UICreated",
	true,
	function(context) OnUICreated_Discord(context) end,
	true
);
eh:add_listener(
	"OnFrontendScreenTransition_Discord",
	"FrontendScreenTransition",
	true,
	function(context) OnFrontendScreenTransition_Discord(context) end,
	true
);
eh:add_listener(
	"OnComponentLClickUp_Discord",
	"ComponentLClickUp",
	true,
	function(context) OnComponentLClickUp_Discord(context) end,
	true
);

function OnUICreated_Discord(context)
	CreateDiscordPrompt();
end;

function OnFrontendScreenTransition_Discord(context)
	local discord_prompt_uic = UIComponent(scripting.m_root:Find("discord_prompt"));

	if discord_prompt_uic:Visible() == true then
		discord_prompt_uic:SetVisible(false);
	end

	if context.string == "main" then
		discord_prompt_uic:SetState("active");
	else
		discord_prompt_uic:SetState("inactive");
 	end
end;

function OnComponentLClickUp_Discord(context)
	if context.string == "button_dis_ok" then
		local discord_prompt_uic = UIComponent(scripting.m_root:Find("discord_prompt"));

		discord_prompt_uic:SetVisible(false);
		os.execute("start https://discord.com/invite/WzbeUxR");
	elseif context.string == "button_discord" then
		local discord_prompt_uic = UIComponent(scripting.m_root:Find("discord_prompt"));

		if discord_prompt_uic:Visible() == true then
			discord_prompt_uic:SetVisible(false);
		else
			discord_prompt_uic:SetVisible(true);
		end
	elseif context.string == "button_home" or context.string == "button_quit" or context.string == "button_dis_cancel" then
		local discord_prompt_uic = UIComponent(scripting.m_root:Find("discord_prompt"));

		if discord_prompt_uic:Visible() == true then
			discord_prompt_uic:SetVisible(false);
		end
	end
end;

function CreateDiscordPrompt()
	scripting.m_root:CreateComponent("discord_prompt", "ui/new/popup_discord_prompt");

	local discord_prompt_uic = UIComponent(scripting.m_root:Find("discord_prompt"));

	discord_prompt_uic:SetVisible(false);
end
