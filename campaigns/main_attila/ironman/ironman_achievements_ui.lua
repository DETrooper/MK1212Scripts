-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - IRONMAN: ACHIEVEMENTS UI
-- 	By: DETrooper
--
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

ANIMATION_PLAYING = false;
PROGRESS_BAR_MAX_SIZE = 506;
TOTAL_ACHIEVEMENTS_UNLOCKED = 0;

function Add_Ironman_Achievement_UI_Listeners()
	cm:add_listener(
		"OnComponentLClickUp_Achievement_UI",
		"ComponentLClickUp",
		true,
		function(context) OnComponentLClickUp_Achievement_UI(context) end,
		true
	);
	cm:add_listener(
		"TimeTrigger_Achievement_UI",
		"TimeTrigger",
		true,
		function(context) TimeTrigger_Achievement_UI(context) end,
		true
	);

	Create_Achievements_UI();
end

function Create_Achievements_UI()
	local root = cm:ui_root();

	root:CreateComponent("Achievements_Layer", "UI/new/script_dummy_top");
	root:CreateComponent("Achievements_Panel", "UI/new/achievement_panel");

	local achievement_panel_uic = UIComponent(root:Find("Achievements_Panel"));
	local dy_ironman_uic = UIComponent(achievement_panel_uic:Find("dy_ironman"));
	local progress_bar_parent_uic = UIComponent(achievement_panel_uic:Find("progress_bar_parent"));
	local progress_bar_uic = UIComponent(progress_bar_parent_uic:Find("progress_bar"));
	local progress_label_uic = UIComponent(progress_bar_parent_uic:Find("progress_label"));
	local list_clip_uic = UIComponent(achievement_panel_uic:Find("list_clip"));
	local vslider_uic = UIComponent(achievement_panel_uic:Find("vslider"));
	local vslider_handle_uic = UIComponent(vslider_uic:Find("handle"));

	for i = 1, #ACHIEVEMENT_KEY_LIST do
		local achievement_key = ACHIEVEMENT_KEY_LIST[i];

		if ACHIEVEMENTS[achievement_key] then
			list_clip_uic:CreateComponent(achievement_key, "UI/new/achievement_template");

			local achievement_template_uic = UIComponent(list_clip_uic:Find(achievement_key));
			local achievement_template_uicX, achievement_template_uicY = achievement_template_uic:Position();
			local icon_holder_uic = UIComponent(achievement_template_uic:Find("icon_holder"));
			local dy_achievement_name_uic = UIComponent(achievement_template_uic:Find("dy_achievement_name"));
			local dy_achievement_description_uic = UIComponent(achievement_template_uic:Find("dy_achievement_description"));

			achievement_template_uic:SetMoveable(true);
			achievement_template_uic:MoveTo(achievement_template_uicX, achievement_template_uicY + (105 * (i - 1)));
			achievement_template_uic:SetMoveable(false);
			icon_holder_uic:CreateComponent("achievement_icon", "UI/new/achievement_icons/"..achievement_key);
			dy_achievement_name_uic:SetStateText(ACHIEVEMENTS[achievement_key].name);
			dy_achievement_description_uic:SetStateText(ACHIEVEMENTS[achievement_key].description);
		end
	end

	Update_Achievement_Menu_UI();

	vslider_uic:SetVisible(true);
	vslider_handle_uic:SetVisible(true);
	achievement_panel_uic:SetVisible(false);
end

function OnComponentLClickUp_Achievement_UI(context)
	if context.string == "button_achievements" then
		OpenAchievementPanel();
	elseif context.string == "button_ok" then
		if UIComponent(UIComponent(context.component):Parent()):Id() == "Achievements_Panel" then
			CloseAchievementPanel();
		end
	end
end

function TimeTrigger_Achievement_UI(context)
	if context.string == "Scroll_Collapsed" then
		local root = cm:ui_root();
		local achievements_layer_uic = UIComponent(root:Find("Achievements_Layer"));
		local achievements_popup_uic = UIComponent(achievements_layer_uic:Find("Achievements_Popup"));
		--local icon_holder_uic = UIComponent(achievements_popup_uic:Find("icon_holder"));
		--local dy_achievement_name_uic = UIComponent(achievements_popup_uic:Find("dy_achievement_name"));

		achievements_popup_uic:DestroyChildren();
	elseif context.string == "Achievement_Timer" then
		ANIMATION_PLAYING = false;
	end
end

function Display_Achievement_Unlocked_UI(achievement_key)
	if ACHIEVEMENTS[achievement_key] and ANIMATION_PLAYING == false then
		local root = cm:ui_root();
		local achievements_layer_uic = UIComponent(root:Find("Achievements_Layer"));

		achievements_layer_uic:DestroyChildren();
		achievements_layer_uic:CreateComponent("Achievements_Popup", "UI/new/achievement_parchment");

		local achievements_popup_uic = UIComponent(achievements_layer_uic:Find("Achievements_Popup"));
		local achievements_popup_uicX, achievements_popup_uicY = achievements_popup_uic:Position();
		local icon_holder_uic = UIComponent(achievements_popup_uic:Find("icon_holder"));
		local dy_achievement_name_uic = UIComponent(achievements_popup_uic:Find("dy_achievement_name"));

		icon_holder_uic:CreateComponent("achievement_icon", "UI/new/achievement_icons/"..achievement_key);
		dy_achievement_name_uic:SetStateText(ACHIEVEMENTS[achievement_key].name);
		achievements_popup_uic:SetVisible(true);
		achievements_popup_uic:TriggerAnimation("show");
		cm:add_time_trigger("Scroll_Collapsed", 5.3);
		cm:add_time_trigger("Achievement_Timer", 7);

		ANIMATION_PLAYING = true;
	end
end

function Update_Achievement_Menu_UI()
	local root = cm:ui_root();
	local achievement_panel_uic = UIComponent(root:Find("Achievements_Panel"));
	local dy_ironman_uic = UIComponent(achievement_panel_uic:Find("dy_ironman"));
	local progress_bar_parent_uic = UIComponent(achievement_panel_uic:Find("progress_bar_parent"));
	local progress_bar_uic = UIComponent(progress_bar_parent_uic:Find("progress_bar"));
	local progress_label_uic = UIComponent(progress_bar_parent_uic:Find("progress_label"));
	local list_clip_uic = UIComponent(achievement_panel_uic:Find("list_clip"));
	local num_achievements = #ACHIEVEMENT_KEY_LIST;

	TOTAL_ACHIEVEMENTS_UNLOCKED = 0;

	for i = 1, #ACHIEVEMENT_KEY_LIST do
		local achievement_key = ACHIEVEMENT_KEY_LIST[i];

		if ACHIEVEMENTS[achievement_key] then
			local achievement_template_uic = UIComponent(list_clip_uic:Find(achievement_key));
			local icon_holder_uic = UIComponent(achievement_template_uic:Find("icon_holder"));
			local dy_unlock_date_uic = UIComponent(achievement_template_uic:Find("dy_unlock_date"));

			if ACHIEVEMENTS[achievement_key].unlocked then
				if ACHIEVEMENTS[achievement_key].unlocktime and ACHIEVEMENTS[achievement_key].unlocktime ~= "n.d." then
					dy_unlock_date_uic:SetStateText("Unlocked: "..ACHIEVEMENTS[achievement_key].unlocktime);
				else
					dy_unlock_date_uic:SetStateText("Unlocked: Date not found!");
				end

				achievement_icon_uic:ShaderVarsSet(0, 0, 0, 0, true);

				TOTAL_ACHIEVEMENTS_UNLOCKED = TOTAL_ACHIEVEMENTS_UNLOCKED + 1;
			else
				local achievement_icon_uic = UIComponent(icon_holder_uic:Find("achievement_icon"));

				achievement_icon_uic:ShaderTechniqueSet("set_greyscale_t0", true);
				achievement_icon_uic:ShaderVarsSet(0.9, 0.9, 0, 0, true);
				dy_unlock_date_uic:SetStateText("Achievement not yet unlocked!");
			end
		end
	end

	if IRONMAN_ENABLED then
		dy_ironman_uic:SetStateText("Ironman: [[rgba:8:201:27:150]]Enabled[[/rgba]]");
	else
		dy_ironman_uic:SetStateText("Ironman: [[rgba:255:0:0:150]]Disabled[[/rgba]]");
	end

	if TOTAL_ACHIEVEMENTS_UNLOCKED == 0 then
		progress_bar_uic:Resize(1, 40);
		progress_label_uic:SetStateText("Achievements Unlocked: 0/0 (0%)");
	else
		progress_bar_uic:Resize(PROGRESS_BAR_MAX_SIZE * (TOTAL_ACHIEVEMENTS_UNLOCKED / num_achievements), 40);
		progress_label_uic:SetStateText("Achievements Unlocked: "..tostring(TOTAL_ACHIEVEMENTS_UNLOCKED).."/"..tostring(num_achievements).." ("..tostring(math.ceil((100 * TOTAL_ACHIEVEMENTS_UNLOCKED) / num_achievements)).."%)");
	end
end

function OpenAchievementPanel()
	local root = cm:ui_root();
	local achievement_panel_uic = UIComponent(root:Find("Achievements_Panel"));

	achievement_panel_uic:SetVisible(true);
end

function CloseAchievementPanel()
	local root = cm:ui_root();
	local achievement_panel_uic = UIComponent(root:Find("Achievements_Panel"));

	achievement_panel_uic:SetVisible(false);
end
