-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - IRONMAN: ACHIEVEMENTS UI
-- 	By: DETrooper
--
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

function Add_Ironman_Achievement_UI_Listeners()
	Create_Achievements_UI();
end

function Create_Achievements_UI()
	local root = cm:ui_root();
	local rootbX, rootbY = root:Bounds();

	root:CreateComponent("Achievements_Popup", "UI/new/achievement_parchment");

	local achievements_popup_uic = UIComponent(root:Find("Achievements_Popup"));
	local achievements_popup_uicX, achievements_popup_uicY = achievements_popup_uic:Position();

	achievements_popup_uic:SetMoveable(true);
	achievements_popup_uic:MoveTo(achievements_popup_uicX, -300);
	achievements_popup_uic:SetMoveable(false);
	achievements_popup_uic:SetVisible(false);
end

function Display_Achievement_Unlocked_UI(achievement_key)
	if ACHIEVEMENTS[achievement_key] then
		local root = cm:ui_root();
		local achievements_popup_uic = UIComponent(root:Find("Achievements_Popup"));
		local achievements_popup_uicX, achievements_popup_uicY = achievements_popup_uic:Position();
		local dy_achievement_name_uic = UIComponent(achievements_popup_uic:Find("dy_achievement_name"));

		-- Todo: Make it slide out all fancy like.
		achievements_popup_uic:SetMoveable(true);
		achievements_popup_uic:MoveTo(achievements_popup_uicX, 75);
		achievements_popup_uic:SetMoveable(false);
		achievements_popup_uic:SetVisible(true);
		dy_achievement_name_uic:SetStateText(ACHIEVEMENTS[achievement_key].name);
	end
end
