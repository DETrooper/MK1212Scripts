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
	local discord_prompt_uic = UIComponent(m_root:Find("discord_prompt"));

	if discord_prompt_uic:Visible() == true then
		discord_prompt_uic:SetVisible(false);
		discord_prompt_uic:UnLockPriority();
	end
end;

function OnComponentLClickUp_Discord(context)
	if context.string == "button_dis_ok" then
		local discord_prompt_uic = UIComponent(m_root:Find("discord_prompt"));

		os.execute("start https://discord.com/invite/WzbeUxR");

		discord_prompt_uic:SetVisible(false);
		discord_prompt_uic:UnLockPriority();
	elseif context.string == "button_discord" then
		local discord_prompt_uic = UIComponent(m_root:Find("discord_prompt"));

		if discord_prompt_uic:Visible() == true then
			discord_prompt_uic:SetVisible(false);
			discord_prompt_uic:UnLockPriority();
		else
			discord_prompt_uic:SetVisible(true);
			discord_prompt_uic:LockPriority(500);
		end
	elseif context.string == "button_home" or context.string == "button_quit" or context.string == "button_dis_cancel" then
		local discord_prompt_uic = UIComponent(m_root:Find("discord_prompt"));

		if discord_prompt_uic:Visible() == true then
			discord_prompt_uic:SetVisible(false);
			discord_prompt_uic:UnLockPriority();
		end
	end
end;

function CreateDiscordPrompt()
	m_root:CreateComponent("discord_prompt", "ui/new/popup_discord_prompt");

	local discord_prompt_uic = UIComponent(m_root:Find("discord_prompt"));

	discord_prompt_uic:SetVisible(false);
end
