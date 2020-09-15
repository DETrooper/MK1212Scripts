---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - CHALLENGES (FRONTEND)
-- 	By: DETrooper
--
---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------

CHALLENGES = {
	"judgement_day",
	"no_retreat",
	"this_is_total_war"
};

CHALLENGE_STRINGS = {
	["judgement_day"] = {"Judgement Day", "Difficulty: Hard"},
	["no_retreat"] = {"Not One Step Back!", "Difficulty: Easy"},
	["this_is_total_war"] = {"This is Total War!", "Difficulty: Hard"}
};

CHALLENGE_BULLETINS = {
	["judgement_day"] = {"All AI factions will become extremely aggressive, attacking you with little regard for defending their own regions.", "AI factions will also focus heavily on military spending and building armies."},
	["no_retreat"] = {"When attacking or being attacked by an enemy force, you will not be able to retreat your force.", "Withdrawing units in battles is disabled."},
	["this_is_total_war"] = {"At the start of the campaign you will automatically declare war against every faction.", "Any new factions encountered will automatically be declared war upon.", "All diplomatic options for the player are disabled, and the AI will never make peace offers.", "Story events (excluding world events) are disabled.", "The 'Subjugate' and 'Liberate' occupation decisions are disabled.", "The Papal Favour system is disabled and War Weariness penalties are decreased."}
};

CHALLENGES_ENABLED = {
	["judgement_day"] = false,
	["no_retreat"] = false,
	["this_is_total_war"] = false
};

CHALLENGE_SELECTED = CHALLENGES[1];

eh:add_listener(
	"OnFrontendScreenTransition_Challenge_Menu",
	"FrontendScreenTransition",
	true,
	function(context) OnFrontendScreenTransition_Challenge_Menu(context) end,
	true
);
eh:add_listener(
	"OnComponentLClickUp_Challenge_Menu",
	"ComponentLClickUp",
	true,
	function(context) OnComponentLClickUp_Challenge_Menu(context) end,
	true
);

function OnFrontendScreenTransition_Challenge_Menu(context)
	for k, v in pairs(CHALLENGES_ENABLED) do
		CHALLENGES_ENABLED[k] = false;
	end

	UpdateChallenges();

	if context.string == "sp_grand_campaign" then
		tm:callback(
			function()
				PopulateChallengeMenu();
			end, 
			0.1
		);
	end
end

function OnComponentLClickUp_Challenge_Menu(context)
	if string.find(context.string, "row_") then
		local challenge = string.gsub(context.string, "row_", "");
		local list_clip_uic = UIComponent(UIComponent(context.component):Parent());
		
		if CHALLENGE_BULLETINS[challenge]  then
			CHALLENGE_SELECTED = challenge;
			ChallengeMenuSetup(challenge);
			UIComponent(context.component):SetState("selected_hover");

			for i = 0, list_clip_uic:ChildCount() - 1 do
				if UIComponent(list_clip_uic:Find(i)):Id() ~= UIComponent(context.component):Id() then
					UIComponent(list_clip_uic:Find(i)):SetState("unselected");
				end
			end
		end

		local sp_grand_campaign_uic = UIComponent(m_root:Find("sp_grand_campaign"));
		local sp_challenge_menu_uic = UIComponent(sp_grand_campaign_uic:Find("sp_challenge_menu"));
		local button_select_challenge_uic = UIComponent(sp_challenge_menu_uic:Find("button_select_challenge"));

		if CHALLENGES_ENABLED[challenge] == true then
			UIComponent(button_select_challenge_uic:Find("button_txt")):SetStateText("Disable Challenge");
		elseif CHALLENGES_ENABLED[challenge] == false then
			UIComponent(button_select_challenge_uic:Find("button_txt")):SetStateText("Enable Challenge");
		end

		UIComponent(sp_challenge_menu_uic:Find("challenge_image")):SetState(challenge);
	elseif context.string == "button_select_challenge" then
		if CHALLENGES_ENABLED[CHALLENGE_SELECTED] == true then
			CHALLENGES_ENABLED[CHALLENGE_SELECTED] = false;
			UIComponent(UIComponent(context.component):Find("button_txt")):SetStateText("Enable Challenge");
		elseif CHALLENGES_ENABLED[CHALLENGE_SELECTED] == false then
			CHALLENGES_ENABLED[CHALLENGE_SELECTED] = true;
			UIComponent(UIComponent(context.component):Find("button_txt")):SetStateText("Disable Challenge");
		end

		UpdateChallenges();
	elseif context.string == "button_challenges" then
		local sp_grand_campaign_uic = UIComponent(m_root:Find("sp_grand_campaign"));
		local sp_challenge_menu_uic = UIComponent(sp_grand_campaign_uic:Find("sp_challenge_menu"));
		local button_select_challenge_uic = UIComponent(sp_challenge_menu_uic:Find("button_select_challenge"));
		local checkbox_ironman_uic = UIComponent(m_root:Find("checkbox_ironman"));
		local text_ironman_uic = UIComponent(m_root:Find("text_ironman"));

		if sp_challenge_menu_uic:Visible() == true then
			sp_challenge_menu_uic:SetVisible(false);
			sp_challenge_menu_uic:UnLockPriority();
			checkbox_ironman_uic:SetVisible(true);
			text_ironman_uic:SetStateText("[[rgba:255:255:242:150]]Enable Ironman[[/rgba:255:255:242:150]]");
			text_ironman_uic:SetVisible(true);
		else
			sp_challenge_menu_uic:SetVisible(true);
			sp_challenge_menu_uic:LockPriority(100);
			checkbox_ironman_uic:SetVisible(false);
			text_ironman_uic:SetStateText("");
			text_ironman_uic:SetVisible(false);

			button_select_challenge_uic:SetState("active");
		end
	elseif context.string == "button_victory" or context.string == "button_options" then
		local sp_grand_campaign_uic = UIComponent(m_root:Find("sp_grand_campaign"));
		local sp_challenge_menu_uic = UIComponent(sp_grand_campaign_uic:Find("sp_challenge_menu"));

		if sp_challenge_menu_uic:Visible() == true then
			sp_challenge_menu_uic:SetVisible(false);
			sp_challenge_menu_uic:UnLockPriority();
		end		
	end
end

function PopulateChallengeMenu()
	local sp_grand_campaign_uic = UIComponent(m_root:Find("sp_grand_campaign"));
	local sp_challenge_menu_uic = UIComponent(sp_grand_campaign_uic:Find("sp_challenge_menu"));
	local sp_challenge_menu_uicX, sp_challenge_menu_uicY = sp_challenge_menu_uic:Position();
	local list_panel_uic = UIComponent(sp_challenge_menu_uic:Find("list_panel"));

	for i = 1, 6 do
		sp_challenge_menu_uic:CreateComponent("template_bullet_point"..tostring(i), "UI/new/template_bullet_point");

		local template_bullet_point_uic = UIComponent(sp_challenge_menu_uic:Find("template_bullet_point"..tostring(i)));

		template_bullet_point_uic:SetMoveable(true);
		template_bullet_point_uic:MoveTo(sp_challenge_menu_uicX + 45, sp_challenge_menu_uicY + 305 + (50 * (i - 1)));
		template_bullet_point_uic:SetMoveable(false);
	end

	for i = 1, #CHALLENGES do
		local challenge = CHALLENGES[i];
		local row_challenge_uic = UIComponent(list_panel_uic:Find("row_"..challenge));
		local row_name_uic = UIComponent(row_challenge_uic:Find("name"));
		local row_difficulty_uic = UIComponent(row_challenge_uic:Find("tx_difficulty"));

		row_name_uic:SetStateText(CHALLENGE_STRINGS[challenge][1]);
		row_difficulty_uic:SetStateText(CHALLENGE_STRINGS[challenge][2]);

		if challenge == CHALLENGE_SELECTED then
			row_challenge_uic:SetState("selected");
		else
			row_challenge_uic:SetState("unselected");
		end
	end

	ChallengeMenuSetup(CHALLENGE_SELECTED);
	sp_challenge_menu_uic:SetVisible(false);
end

function ChallengeMenuSetup(challenge)
	local sp_grand_campaign_uic = UIComponent(m_root:Find("sp_grand_campaign"));
	local sp_challenge_menu_uic = UIComponent(sp_grand_campaign_uic:Find("sp_challenge_menu"));
	local dy_challenge_name_uic = UIComponent(sp_challenge_menu_uic:Find("dy_challenge_name"));
	local tx_difficulty_uic = UIComponent(sp_challenge_menu_uic:Find("tx_difficulty"));

	dy_challenge_name_uic:SetStateText(CHALLENGE_STRINGS[challenge][1]);
	tx_difficulty_uic:SetStateText(CHALLENGE_STRINGS[challenge][2]);

	for i = 1, 6 do
		local template_bullet_point_uic = UIComponent(sp_challenge_menu_uic:Find("template_bullet_point"..tostring(i)));

		template_bullet_point_uic:SetVisible(false);
	end

	for i = 1, #CHALLENGE_BULLETINS[challenge] do
		local template_bullet_point_uic = UIComponent(sp_challenge_menu_uic:Find("template_bullet_point"..tostring(i)));

		template_bullet_point_uic:SetStateText(CHALLENGE_BULLETINS[challenge][i]);
		template_bullet_point_uic:SetVisible(true);
	end

	UIComponent(sp_challenge_menu_uic:Find("challenge_image")):SetState(challenge);
end

function UpdateChallenges()
	for k, v in pairs(CHALLENGES_ENABLED) do
		svr:SaveBool("SBOOL_challenge_"..k, v);
	end
end
