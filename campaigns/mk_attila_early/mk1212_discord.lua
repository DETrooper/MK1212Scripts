---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - DISCORD INVITE BUTTON
-- 	By: DETrooper
--
---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------

function Add_MK1212_Discord_Listeners()
	cm:add_listener(
		"OnComponentLClickUp_Discord",
		"ComponentLClickUp",
		true,
		function(context) OnComponentLClickUp_Discord(context) end,
		true
	);
	cm:add_listener(
		"OnPanelOpenedCampaign_Discord",
		"PanelOpenedCampaign",
		true,
		function(context) OnPanelOpenedCampaign_Discord(context) end,
		true
	);

	CreateDiscordPrompt();
end

function OnComponentLClickUp_Discord(context)
	if context.string == "button_dis_ok" then
		local root = cm:ui_root();
		local discord_prompt_uic = UIComponent(root:Find("discord_prompt"));

		discord_prompt_uic:SetVisible(false);
		discord_prompt_uic:UnLockPriority();
		os.execute("start https://discord.com/invite/WzbeUxR");
	elseif context.string == "button_encyclopedia" then -- Can't rename the button without the game crashing :(
		local root = cm:ui_root();
		local discord_prompt_uic = UIComponent(root:Find("discord_prompt"));

		if discord_prompt_uic:Visible() == true then
			discord_prompt_uic:SetVisible(false);
			discord_prompt_uic:UnLockPriority();
		else
			discord_prompt_uic:SetVisible(true);
			discord_prompt_uic:LockPriority(500);
		end
	elseif context.string == "root" or context.string == "button_dis_cancel" then
		local root = cm:ui_root();
		local discord_prompt_uic = UIComponent(root:Find("discord_prompt"));

		if discord_prompt_uic:Visible() == true then
			discord_prompt_uic:SetVisible(false);
			discord_prompt_uic:UnLockPriority();
		end
	end
end

function OnPanelOpenedCampaign_Discord(context)
	local root = cm:ui_root();
	local discord_prompt_uic = UIComponent(root:Find("discord_prompt"));

	if discord_prompt_uic:Visible() == true then
		discord_prompt_uic:SetVisible(false);
		discord_prompt_uic:UnLockPriority();
	end
end

function CreateDiscordPrompt()
	local root = cm:ui_root();

	root:CreateComponent("discord_prompt", "ui/new/popup_discord_prompt");

	local button_encyclopedia_uic = UIComponent(root:Find("button_encyclopedia"));
	local discord_prompt_uic = UIComponent(root:Find("discord_prompt"));

	button_encyclopedia_uic:SetState("active");
	discord_prompt_uic:SetVisible(false);
end
