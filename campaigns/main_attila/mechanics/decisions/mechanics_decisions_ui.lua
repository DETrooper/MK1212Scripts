------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: DECISIONS UI
-- 	By: DETrooper
--
------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------

DECISION_PANEL_OPEN = false;

function Add_Decisions_UI_Listeners()
	cm:add_listener(
		"FactionTurnStart_Decisions_UI",
		"FactionTurnStart",
		true,
		function(context) FactionTurnStart_Decisions_UI(context) end,
		true
	);
	cm:add_listener(
		"FactionTurnEnd_Decisions_UI",
		"FactionTurnEnd",
		true,
		function(context) FactionTurnEnd_Decisions_UI(context) end,
		true
	);
	cm:add_listener(
		"OnComponentMouseOn_Decisions_UI",
		"ComponentMouseOn",
		true,
		function(context) OnComponentMouseOn_Decisions_UI(context) end,
		true
	);
	cm:add_listener(
		"OnComponentLClickUp_Decisions_UI",
		"ComponentLClickUp",
		true,
		function(context) OnComponentLClickUp_Decisions_UI(context) end,
		true
	);
	cm:add_listener(
		"OnPanelOpenedCampaign_Decisions_UI",
		"PanelOpenedCampaign",
		true,
		function(context) OnPanelOpenedCampaign_Decisions_UI(context) end,
		true
	);
	cm:add_listener(
		"OnPanelClosedCampaign_Decisions_UI",
		"PanelClosedCampaign",
		true,
		function(context) OnPanelClosedCampaign_Decisions_UI(context) end,
		true
	);
	cm:add_listener(
		"TimeTrigger_Decisions_UI",
		"TimeTrigger",
		true,
		function(context) TimeTrigger_Decisions_UI(context) end,
		true
	);

	CreateDecisionsButton();
	CreateDecisionsPanel();

	cm:add_time_trigger("Decisions_Button_Check", 0.5);
end

function CreateDecisionsButton()
	local root = cm:ui_root();
	local hud_center_uic = UIComponent(root:Find("hud_center"));
	local button_group_management_uic = UIComponent(hud_center_uic:Find("button_group_management"));
	local mission = UIComponent(root:Find("button_missions"));
	local missionX, missionY = mission:Position();

	root:CreateComponent("Decisions_Button", "UI/new/basic_toggle_decisions");
	local btnDecisions = UIComponent(root:Find("Decisions_Button"));
	btnDecisions:SetMoveable(true);
	btnDecisions:MoveTo(missionX - 60, missionY);
	btnDecisions:SetMoveable(false);
	btnDecisions:PropagatePriority(1);
	--button_group_management_uic:Adopt(btnDecisions:Address());
end

function CreateDecisionsPanel()
	local root = cm:ui_root();
	local faction_name = cm:get_local_faction();

	root:CreateComponent("Decisions_Panel", "UI/new/objectives_screen");
	root:CreateComponent("Decisions_Panel_View", "UI/campaign ui/script_dummy");
	local panDecisions = UIComponent(root:Find("Decisions_Panel"));
	local panDecisionsView = UIComponent(root:Find("Decisions_Panel_View"));
	local tabgroup_uic = UIComponent(panDecisions:Find("TabGroup"));
	local txt_title_uic = UIComponent(panDecisions:Find("tx_title"));

	panDecisions:Adopt(txt_title_uic:Address());
	panDecisions:Adopt(panDecisionsView:Address());
	tabgroup_uic:SetVisible(false);
	UIComponent(panDecisions:Find("button_info")):SetVisible(false);
	UIComponent(panDecisions:Find("button_info_holder")):SetVisible(false);
	UIComponent(panDecisions:Find("progress_bar")):SetVisible(false);
	UIComponent(panDecisions:Find("tx_objectives")):SetStateText("Decisions");
	txt_title_uic:SetStateText(Get_DFN_Localisation(faction_name));
	local curX, curY = txt_title_uic:Position();
	txt_title_uic:SetMoveable(true);
	txt_title_uic:MoveTo(curX, curY + 70);
	txt_title_uic:SetMoveable(false);

	local curX, curY = panDecisions:Position();
	local rootbX, rootbY = root:Bounds();
	--panDecisions:Resize(736, 700);
	panDecisions:SetMoveable(true);
	panDecisions:MoveTo(curX, rootbY/2.5);
	panDecisions:SetMoveable(false);
	panDecisions:SetVisible(false);
end

function OnComponentMouseOn_Decisions_UI(context)
	if context.string == "Decisions_Button" then
		local root = cm:ui_root();
		local btnDecisions = UIComponent(root:Find("Decisions_Button"));
		btnDecisions:SetTooltipText("Decisions");
	elseif string.find(context.string, "_Decision_Button") then
		local root = cm:ui_root();
		local btnDecision = UIComponent(root:Find(context.string));
		local decision = string.gsub(context.string, "_Decision_Button", "");

		btnDecision:SetTooltipText("Enact Decision");
	elseif string.find(context.string, "_Decision_Tooltip") then
		local root = cm:ui_root();
		local tltipDecisions = UIComponent(root:Find(context.string));
		local decision = string.gsub(context.string, "_Decision_Tooltip", "");

		tltipDecisions:SetTooltipText(Get_Decision_Tooltip(decision));
	end
end

function OnComponentLClickUp_Decisions_UI(context)
	if context.string == "Decisions_Button" then
		local root = cm:ui_root();
		local panDecisions = UIComponent(root:Find("Decisions_Panel"));

		if DECISION_PANEL_OPEN == false then
			panDecisions:SetVisible(true);
			RefreshDecisionsPanel();
			DECISION_PANEL_OPEN = true;
		else
			CloseDecisionsPanel();
		end

		Unhighlight_Decisions_Button();
	elseif DECISION_PANEL_OPEN == true then
		if context.string == "root" then
			CloseDecisionsPanel();
		elseif string.find(context.string, "_Decision_Button") then
			local root = cm:ui_root();
			UIComponent(root:Find(context.string)):SetState("inactive");

			local decision = string.gsub(context.string, "_Decision_Button", "");
			Decision_Button_Pressed(decision);
		end
	end
end

function FactionTurnStart_Decisions_UI(context)
	if context:faction():is_human() then
		cm:add_time_trigger("Decisions_Button_Visible", 1);
	end
end

function FactionTurnEnd_Decisions_UI(context)
	if context:faction():is_human() then
		CloseDecisionsPanel();
		cm:add_time_trigger("Decisions_Button_Invisible", 0.5);
	end
end

function OnPanelOpenedCampaign_Decisions_UI(context)
	CloseDecisionsPanel();
	
	if context.string == "campaign_tactical_map" or context.string == "clan" or context.string == "diplomacy_dropdown" or context.string == "popup_pre_battle" or context.string == "settlement_captured" or context.string == "technology_panel" or context.string == "popup_battle_results" then
		cm:add_time_trigger("Decisions_Button_Invisible", 0.1);
	end
end

function OnPanelClosedCampaign_Decisions_UI(context)
	if context.string == "campaign_tactical_map" or context.string == "clan" or context.string == "popup_pre_battle" or context.string == "settlement_captured" or context.string == "technology_panel" or context.string == "popup_battle_results" then
		cm:add_time_trigger("Decisions_Button_Visible", 0.1);
	elseif context.string == "diplomacy_dropdown" then
		if cm:get_local_faction() == FACTION_TURN then
			-- Otherwise this may fire during post-turn diplomacy, and we don't want a button appearing in the middle of nowhere!
			cm:add_time_trigger("Decisions_Button_Visible", 0.5);
		end
	end
end

function TimeTrigger_Decisions_UI(context)
	if context.string == "Decisions_Button_Visible" then
		if FACTION_TURN == cm:get_local_faction() then
			local root = cm:ui_root();
			local btnDecisions = UIComponent(root:Find("Decisions_Button"));
			local btnMissions = UIComponent(root:Find("button_missions"));

			if btnMissions:Visible() == true then
				btnDecisions:SetState("active");
				btnDecisions:SetVisible(true);
			end
		end
	elseif context.string == "Decisions_Button_Invisible" then
		local root = cm:ui_root();
		local btnDecisions = UIComponent(root:Find("Decisions_Button"));
		btnDecisions:SetVisible(false);
	elseif context.string == "Decisions_Button_Check" then
		local root = cm:ui_root();

		if UIComponent(root:Find("popup_pre_battle")):Visible() == true then
			local btnDecisions = UIComponent(root:Find("Decisions_Button"));
			btnDecisions:SetVisible(false);
		end
	elseif context.string == "Refresh_Delay" then
		RefreshDecisionsPanel();
	end
end

function CloseDecisionsPanel()
	local root = cm:ui_root();
	local panDecisions = UIComponent(root:Find("Decisions_Panel"));
	local btnDecisions = UIComponent(root:Find("Decisions_Button"));
	panDecisions:SetVisible(false);
	btnDecisions:SetState("active");
	DECISION_PANEL_OPEN = false;
end

function RefreshDecisionsPanel()
	local root = cm:ui_root();
	local panDecisions = UIComponent(root:Find("Decisions_Panel"));
	local panDecisionsView = UIComponent(root:Find("Decisions_Panel_View"));
	local txt_title_uic = UIComponent(panDecisions:Find("tx_title"));
	txt_title_uic:SetStateText(Get_DFN_Localisation(cm:get_local_faction()));
	panDecisionsView:DestroyChildren();
 
	if #PRIORITY_DECISIONS > 0 then
		for i = 1, #PRIORITY_DECISIONS do
			root:CreateComponent(PRIORITY_DECISIONS[i][1].."_Decision_Button", "UI/new/button_small_accept");
			root:CreateComponent(PRIORITY_DECISIONS[i][1].."_Decision_Tooltip", "UI/new/decision_question");
			root:CreateComponent(PRIORITY_DECISIONS[i][1].."_Text", "UI/campaign ui/city_info_bar_horde");

			local btnDecisions = UIComponent(root:Find(PRIORITY_DECISIONS[i][1].."_Decision_Button"));
			local tltipDecisions = UIComponent(root:Find(PRIORITY_DECISIONS[i][1].."_Decision_Tooltip"));
			local textDecisions = UIComponent(root:Find(PRIORITY_DECISIONS[i][1].."_Text"));
			local curX, curY = panDecisions:Position();

			panDecisionsView:Adopt(btnDecisions:Address());
			panDecisionsView:Adopt(tltipDecisions:Address());
			panDecisionsView:Adopt(textDecisions:Address());

			local mon_frame = UIComponent(textDecisions:Find("mon_frame"));
			local mon_24 = UIComponent(textDecisions:Find("mon_24"));
			local dy_name = UIComponent(textDecisions:Find("dy_name"));
			local diplomatic_relations_fill = UIComponent(textDecisions:Find("diplomatic_relations_fill"));

			btnDecisions:Resize(24, 24);
			btnDecisions:SetMoveable(true);
			btnDecisions:MoveTo(curX + 610, curY + 103 + ((i - 1) * 32));
			btnDecisions:SetMoveable(false);

			if PRIORITY_DECISIONS[i][3] == false then
				btnDecisions:SetState("inactive");
			end

			tltipDecisions:SetMoveable(true);
			tltipDecisions:MoveTo(curX + 575, curY + 104 + ((i - 1) * 32));
			tltipDecisions:SetMoveable(false);
			--tltipDecisions:SetInteractive(false);

			textDecisions:SetMoveable(true);
			textDecisions:MoveTo(curX + 175, curY + 104 + ((i - 1) * 32));
			textDecisions:SetMoveable(false);
			textDecisions:SetInteractive(false);

			dy_name:SetStateText(DECISIONS_STRINGS[PRIORITY_DECISIONS[i][1]]);
			mon_frame:SetVisible(false);
			mon_24:SetVisible(false);
			diplomatic_relations_fill:SetVisible(false);

			textDecisions:Resize(200, 24);
		end
	end

	if #AVAILABLE_DECISIONS > 0 then
		for i = 1, #AVAILABLE_DECISIONS do
			root:CreateComponent(AVAILABLE_DECISIONS[i][1].."_Decision_Button", "UI/new/button_small_accept");
			root:CreateComponent(AVAILABLE_DECISIONS[i][1].."_Decision_Tooltip", "UI/new/decision_question");
			root:CreateComponent(AVAILABLE_DECISIONS[i][1].."_Text", "UI/campaign ui/city_info_bar_horde");

			local btnDecisions = UIComponent(root:Find(AVAILABLE_DECISIONS[i][1].."_Decision_Button"));
			local tltipDecisions = UIComponent(root:Find(AVAILABLE_DECISIONS[i][1].."_Decision_Tooltip"));
			local textDecisions = UIComponent(root:Find(AVAILABLE_DECISIONS[i][1].."_Text"));
			local curX, curY = panDecisions:Position();

			panDecisionsView:Adopt(btnDecisions:Address());
			panDecisionsView:Adopt(tltipDecisions:Address());
			panDecisionsView:Adopt(textDecisions:Address());

			local mon_frame = UIComponent(textDecisions:Find("mon_frame"));
			local mon_24 = UIComponent(textDecisions:Find("mon_24"));
			local dy_name = UIComponent(textDecisions:Find("dy_name"));
			local diplomatic_relations_fill = UIComponent(textDecisions:Find("diplomatic_relations_fill"));

			btnDecisions:Resize(24, 24);
			btnDecisions:SetMoveable(true);
			btnDecisions:MoveTo(curX + 610, curY + 103 + ((i - 1 + #PRIORITY_DECISIONS) * 32));
			btnDecisions:SetMoveable(false);

			if AVAILABLE_DECISIONS[i][3] == false then
				btnDecisions:SetState("inactive");
			end

			tltipDecisions:SetMoveable(true);
			tltipDecisions:MoveTo(curX + 575, curY + 104 + ((i - 1 + #PRIORITY_DECISIONS) * 32));
			tltipDecisions:SetMoveable(false);
			--tltipDecisions:SetInteractive(false);

			textDecisions:SetMoveable(true);
			textDecisions:MoveTo(curX + 175, curY + 104 + ((i - 1 + #PRIORITY_DECISIONS) * 32));
			textDecisions:SetMoveable(false);
			textDecisions:SetInteractive(false);

			dy_name:SetStateText(DECISIONS_STRINGS[AVAILABLE_DECISIONS[i][1]]);
			mon_frame:SetVisible(false);
			mon_24:SetVisible(false);
			diplomatic_relations_fill:SetVisible(false);

			textDecisions:Resize(200, 24);
		end
	end
end

function Highlight_Decisions_Button()
	highlight_component("Decisions_Button", true, false);
end

function Unhighlight_Decisions_Button()
	highlight_component("Decisions_Button", false, false);
end

-------------------------------------------------
-- DECISION SPECIFIC STUFF
-------------------------------------------------

function Get_Decision_Tooltip(decision)
	if decision == "restore_byzantine_empire" then
		return GetConditionsString_Byzantium();
	elseif decision == "restore_roman_empire" then
		return GetConditionsString_Roman_Empire();
	elseif decision == "form_kingdom_poland" then
		return GetConditionsString_Poland();
	elseif decision == "form_kingdom_spain" then
		return GetConditionsString_Spain();
	elseif decision == "form_empire_golden_horde" then
		return GetConditionsString_Golden_Horde();
	elseif decision == "form_empire_ilkhanate" then
		return GetConditionsString_Ilkhanate();
	elseif decision == "found_a_kingdom" then
		return GetConditionsString_DFN_Kingdom();
	elseif decision == "found_an_empire" then
		return GetConditionsString_DFN_Empire();
	elseif decision == "ask_pope_for_money" then
		return GetConditionsString_Pope_Money(cm:get_local_faction());
	end
end

function Decision_Button_Pressed(decision)
	if decision == "restore_byzantine_empire" then
		Byzantine_Empire_Restored(cm:get_local_faction());
	elseif decision == "restore_roman_empire" then
		Roman_Empire_Restored(cm:get_local_faction());
	elseif decision == "form_kingdom_poland" then
		Polish_Kingdom_Formed(cm:get_local_faction());
	elseif decision == "form_kingdom_spain" then
		Spanish_Kingdom_Formed(cm:get_local_faction());
	elseif decision == "form_empire_golden_horde" then
		Golden_Horde_Formed(cm:get_local_faction());
	elseif decision == "form_empire_ilkhanate" then
		Ilkhanate_Formed(cm:get_local_faction());
	elseif decision == "found_a_kingdom" then
		DFN_Set_Faction_Rank(cm:get_local_faction(), 2);
		Remove_Decision("found_a_kingdom");
	elseif decision == "found_an_empire" then
		DFN_Set_Faction_Rank(cm:get_local_faction(), 3);
		Remove_Decision("found_an_empire");
	elseif decision == "ask_pope_for_money" then
		Decision_Pope_Money(cm:get_local_faction());
	end

	RefreshDecisionsPanel();
	--cm:add_time_trigger("Refresh_Delay", 1);
end