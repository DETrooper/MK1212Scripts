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

	CreateDecisionsPanel();
end

function CreateDecisionsPanel()
	local root = cm:ui_root();
	local faction_name = cm:get_local_faction();

	root:CreateComponent("Decisions_Panel", "UI/new/objectives_screen");
	local panDecisions = UIComponent(root:Find("Decisions_Panel"));
	local tabgroup_uic = UIComponent(panDecisions:Find("TabGroup"));
	local txt_title_uic = UIComponent(panDecisions:Find("tx_title"));

	panDecisions:CreateComponent("Decisions_Panel_View", "UI/campaign ui/script_dummy");
	local panDecisionsView = UIComponent(panDecisions:Find("Decisions_Panel_View"));

	panDecisions:Adopt(txt_title_uic:Address());
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
	panDecisions:MoveTo(curX, rootbY / 3);
	panDecisions:SetMoveable(false);
	panDecisions:SetVisible(false);
end

function Create_Decisions_Map(decision)
	local root = cm:ui_root();
	local rootbX, rootbY = root:Bounds();
	local panDecisions = UIComponent(root:Find("Decisions_Panel"));
	local panDecisionsView = UIComponent(panDecisions:Find("Decisions_Panel_View"));
	local sizeX, sizeY = tonumber(MAP_DECISIONS_MAP_NAMES[decision][2]), tonumber(MAP_DECISIONS_MAP_NAMES[decision][3]);

	panDecisions:CreateComponent("Decisions_Panel_Map_View", "UI/campaign ui/script_dummy");
	local panDecisionsMapView = UIComponent(panDecisions:Find("Decisions_Panel_Map_View"));

	panDecisionsMapView:CreateComponent(decision.."_Map_Parchment", "UI/new/map_parchment_"..tostring(sizeX));
	local mapParchment = UIComponent(panDecisionsMapView:Find(decision.."_Map_Parchment"));
	local mapParchmentPanel = UIComponent(mapParchment:Find("panel"));
	local mapParchmentPanelClip = UIComponent(mapParchment:Find("panel_clip"));
	local sortable_list_factions_uic = UIComponent(mapParchmentPanelClip:Find("sortable_list_factions"));

	mapParchment:Resize(sizeX + 120, sizeY + 100);
	mapParchmentPanel:Resize(sizeX + 120, sizeY + 100);
	mapParchment:SetMoveable(true);
	mapParchment:MoveTo((rootbX / 2) + (sizeX / 2) - 32, (rootbY / 2) - (sizeY / 2) - 56);
	mapParchment:SetMoveable(false);

	local mapParchmentPanelClipX, mapParchmentPanelClipY = mapParchmentPanelClip:Position();
	mapParchmentPanelClip:SetMoveable(true);
	mapParchmentPanelClip:MoveTo(mapParchmentPanelClipX, mapParchmentPanelClipY - 25);
	mapParchmentPanelClip:SetMoveable(false);
	sortable_list_factions_uic:DestroyChildren();

	mapParchment:CreateComponent(MAP_DECISIONS_MAP_NAMES[decision][1], "UI/new/maps/"..MAP_DECISIONS_MAP_NAMES[decision][1]);
	local map_uic = UIComponent(mapParchment:Find(MAP_DECISIONS_MAP_NAMES[decision][1]));
	local map_uicX, map_uicY = map_uic:Position();
	local mapParchmentX, mapParchmentY = mapParchment:Position();
	local mapParchmentbX, mapParchmentbY = mapParchment:Bounds();

	mapParchment:CreateComponent(decision.."_Decision_Tooltip", "UI/new/decision_question");
	local tltipDecisions = UIComponent(mapParchment:Find(decision.."_Decision_Tooltip"));

	tltipDecisions:SetMoveable(true);
	tltipDecisions:MoveTo(mapParchmentX - 4, mapParchmentY + 32);
	tltipDecisions:SetMoveable(false);

	mapParchment:CreateComponent("map_accept", "UI/new/basic_toggle_accept");
	local map_accept_uic = UIComponent(mapParchment:Find("map_accept"));

	map_accept_uic:SetMoveable(true);
	map_accept_uic:MoveTo(mapParchmentX - (sizeX / 2) + 8, mapParchmentY + sizeY + 56);
	map_accept_uic:SetMoveable(false);

	map_uic:SetMoveable(true);
	map_uic:MoveTo(mapParchmentX - sizeX + 32, mapParchmentY + 82);
	map_uic:SetMoveable(false);
	mapParchment:SetVisible(false);
end

function Refresh_Decisions_Map(decision)
	local root = cm:ui_root();
	local panDecisions = UIComponent(root:Find("Decisions_Panel"));
	local panDecisionsMapView = UIComponent(panDecisions:Find("Decisions_Panel_Map_View"));
	local mapParchment = UIComponent(panDecisionsMapView:Find(decision.."_Map_Parchment"));
	local mapParchmentPanel = UIComponent(mapParchment:Find("panel"));
	local map_accept_uic = UIComponent(mapParchment:Find("map_accept"));
	local map_uic = UIComponent(mapParchment:Find(MAP_DECISIONS_MAP_NAMES[decision][1]));
	local map_uicX, map_uicY = map_uic:Position();
	local tx_title_uic = UIComponent(mapParchmentPanel:Find("tx_title"));

	local regions_owned_counter = 0;
	local table_regions = Get_Decision_Regions(decision);
	local table_faction_pips = Get_Decision_Map_Faction_Pips(decision);

	for i = 1, #table_regions do
		local region_name = table_regions[i];
		local region = cm:model():world():region_manager():region_by_key(region_name);
		local owning_faction_name = region:owning_faction():name();
		local image_name = string.gsub(region_name, "att_", "dec_");
		local image_uic = UIComponent(map_uic:Find(image_name));

		image_uic:DestroyChildren();

		if owning_faction_name == cm:get_local_faction() then
			image_uic:PropagateImageColour(0, 204, 0, 150);
			regions_owned_counter = regions_owned_counter + 1;
		else
			image_uic:PropagateImageColour(204, 0, 0, 150);
		end


		image_uic:CreateComponent(region_name.."_logo", "UI/new/faction_flags/"..owning_faction_name.."_flag_small");

		local faction_logo_uic = UIComponent(image_uic:Find(region_name.."_logo"));
		faction_logo_uic:SetMoveable(true);
		faction_logo_uic:MoveTo(map_uicX + table_faction_pips[region_name][1], map_uicY + table_faction_pips[region_name][2]);
		faction_logo_uic:SetMoveable(false);
		faction_logo_uic:SetInteractive(false);
	end

	tx_title_uic:SetStateText(DECISIONS_STRINGS_MAP[decision].." - ("..tostring(regions_owned_counter).."/"..tostring(#table_regions)..")");
	map_accept_uic:SetState("active");
	mapParchment:SetVisible(true);
	--mapParchment:TriggerAnimation("show");
end

function OnComponentMouseOn_Decisions_UI(context)
	if context.string == "map_accept" then
		local btnAccept = UIComponent(context.component);

		btnAccept:SetTooltipText("Close Map");
	elseif string.find(context.string, "_Decision_Button") then
		local btnDecision = UIComponent(context.component);
		local decision = string.gsub(context.string, "_Decision_Button", "");

		btnDecision:SetTooltipText("Enact Decision");
	elseif string.find(context.string, "_Decision_Tooltip") then
		local tltipDecisions = UIComponent(context.component);
		local decision = string.gsub(context.string, "_Decision_Tooltip", "");

		tltipDecisions:SetTooltipText(Get_Decision_Tooltip(decision));
	elseif string.find(context.string, "_Decision_Map_Button") then
		local mapDecisions = UIComponent(context.component);

		mapDecisions:SetTooltipText("View a map of the regions required to enact this decision.");
	end
end

function OnComponentLClickUp_Decisions_UI(context)
	if context.string == "map_accept" then
		UIComponent(UIComponent(context.component):Parent()):SetVisible(false);
	elseif context.string == "button_decisions" then
		local root = cm:ui_root();
		local panDecisions = UIComponent(root:Find("Decisions_Panel"));

		if DECISION_PANEL_OPEN == false then
			panDecisions:SetVisible(true);
			RefreshDecisionsPanel();
			DECISION_PANEL_OPEN = true;
		else
			CloseDecisionsPanel(true);
		end

		Unhighlight_Decisions_Button();
	elseif DECISION_PANEL_OPEN == true then
		if context.string == "root" then
			CloseDecisionsPanel(false);
		elseif string.find(context.string, "_Decision_Button") then
			local root = cm:ui_root();
			UIComponent(context.component):SetState("inactive");

			local decision = string.gsub(context.string, "_Decision_Button", "");
			Decision_Button_Pressed(decision);
		elseif string.find(context.string, "_Decision_Map_Button") then
			local root = cm:ui_root();
			local decision = string.gsub(context.string, "_Decision_Map_Button", "");
			local panDecisions = UIComponent(root:Find("Decisions_Panel"));
			local mapParchment = UIComponent(panDecisions:Find(decision.."_Map_Parchment"));

			if mapParchment:Visible() == true then
				mapParchment:SetVisible(false);
			else
				Refresh_Decisions_Map(decision);
			end
		end
	end
end

function FactionTurnEnd_Decisions_UI(context)
	if context:faction():is_human() then
		CloseDecisionsPanel(false);
	end
end

function OnPanelOpenedCampaign_Decisions_UI(context)
	CloseDecisionsPanel(false);
end

function CloseDecisionsPanel(hover)
	local root = cm:ui_root();
	local panDecisions = UIComponent(root:Find("Decisions_Panel"));
	local btnDecisions = UIComponent(root:Find("button_decisions"));

	if #PRIORITY_DECISIONS > 0 then
		for i = 1, #PRIORITY_DECISIONS do
			if HasValue(MAP_DECISIONS, PRIORITY_DECISIONS[i][1]) then
				local mapParchment = UIComponent(panDecisions:Find(PRIORITY_DECISIONS[i][1].."_Map_Parchment"));

				if mapParchment:Address() ~= nil then
					mapParchment:SetVisible(false);
				end
			end
		end
	end

	if #AVAILABLE_DECISIONS > 0 then
		for i = 1, #AVAILABLE_DECISIONS do
			if HasValue(MAP_DECISIONS, AVAILABLE_DECISIONS[i][1]) then
				local mapParchment = UIComponent(panDecisions:Find(AVAILABLE_DECISIONS[i][1].."_Map_Parchment"));

				if mapParchment:Address() ~= nil then
					mapParchment:SetVisible(false);
				end
			end
		end
	end

	panDecisions:SetVisible(false);

	if hover == true then
		btnDecisions:SetState("hover");
	else
		btnDecisions:SetState("active");
	end

	DECISION_PANEL_OPEN = false;
end

function RefreshDecisionsPanel()
	local root = cm:ui_root();
	local panDecisions = UIComponent(root:Find("Decisions_Panel"));
	local panDecisionsView = UIComponent(panDecisions:Find("Decisions_Panel_View"));
	local curX, curY = panDecisions:Position();
	local txt_title_uic = UIComponent(panDecisions:Find("tx_title"));
	txt_title_uic:SetStateText(Get_DFN_Localisation(cm:get_local_faction()));
	panDecisionsView:DestroyChildren();
 
	if #PRIORITY_DECISIONS > 0 then
		for i = 1, #PRIORITY_DECISIONS do
			local decision_key = PRIORITY_DECISIONS[i][1];

			panDecisionsView:CreateComponent(decision_key.."_Decision_Button", "UI/new/button_small_accept");
			panDecisionsView:CreateComponent(decision_key.."_Decision_Tooltip", "UI/new/decision_question");
			panDecisionsView:CreateComponent(decision_key.."_Text", "UI/campaign ui/city_info_bar_horde");

			local btnDecisions = UIComponent(panDecisionsView:Find(decision_key.."_Decision_Button"));
			local tltipDecisions = UIComponent(panDecisionsView:Find(decision_key.."_Decision_Tooltip"));
			local textDecisions = UIComponent(panDecisionsView:Find(decision_key.."_Text"));
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

			if HasValue(MAP_DECISIONS, decision_key) then
				panDecisionsView:CreateComponent(decision_key.."_Decision_Map_Button", "UI/new/button_small_decision_map");

				local mapDecisions = UIComponent(panDecisionsView:Find(decision_key.."_Decision_Map_Button"));

				mapDecisions:Resize(24, 24);
				mapDecisions:SetMoveable(true);
				mapDecisions:MoveTo(curX + 540, curY + 103 + ((i - 1) * 32));
				mapDecisions:SetMoveable(false);

				local mapParchment = UIComponent(panDecisions:Find(decision_key.."_Map_Parchment"));

				if mapParchment:Address() == nil then
					Create_Decisions_Map(decision_key);
				end
			end

			textDecisions:SetMoveable(true);
			textDecisions:MoveTo(curX + 175, curY + 104 + ((i - 1) * 32));
			textDecisions:SetMoveable(false);
			textDecisions:SetInteractive(false);

			dy_name:SetStateText(DECISIONS_STRINGS[decision_key]);
			mon_frame:SetVisible(false);
			mon_24:SetVisible(false);
			diplomatic_relations_fill:SetVisible(false);

			textDecisions:Resize(200, 24);
		end
	end

	if #AVAILABLE_DECISIONS > 0 then
		for i = 1, #AVAILABLE_DECISIONS do
			local decision_key = AVAILABLE_DECISIONS[i][1];

			panDecisionsView:CreateComponent(decision_key.."_Decision_Button", "UI/new/button_small_accept");
			panDecisionsView:CreateComponent(decision_key.."_Decision_Tooltip", "UI/new/decision_question");
			panDecisionsView:CreateComponent(decision_key.."_Text", "UI/campaign ui/city_info_bar_horde");

			local btnDecisions = UIComponent(panDecisionsView:Find(decision_key.."_Decision_Button"));
			local tltipDecisions = UIComponent(panDecisionsView:Find(decision_key.."_Decision_Tooltip"));
			local textDecisions = UIComponent(panDecisionsView:Find(decision_key.."_Text"));
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

			if HasValue(MAP_DECISIONS, decision_key) then
				panDecisionsView:CreateComponent(decision_key.."_Decision_Map_Button", "UI/new/button_small_decision_map");

				local mapDecisions = UIComponent(panDecisionsView:Find(decision_key.."_Decision_Map_Button"));

				mapDecisions:Resize(24, 24);
				mapDecisions:SetMoveable(true);
				mapDecisions:MoveTo(curX + 540, curY + 103 + ((i - 1) * 32));
				mapDecisions:SetMoveable(false);

				local mapParchment = UIComponent(panDecisions:Find(decision_key.."_Map_Parchment"));

				if mapParchment:Address() == nil then
					Create_Decisions_Map(decision_key);
				end
			end

			textDecisions:SetMoveable(true);
			textDecisions:MoveTo(curX + 175, curY + 104 + ((i - 1 + #PRIORITY_DECISIONS) * 32));
			textDecisions:SetMoveable(false);
			textDecisions:SetInteractive(false);

			dy_name:SetStateText(DECISIONS_STRINGS[decision_key]);
			mon_frame:SetVisible(false);
			mon_24:SetVisible(false);
			diplomatic_relations_fill:SetVisible(false);

			textDecisions:Resize(200, 24);
		end
	end
end

function Highlight_Decisions_Button()
	highlight_component("button_decisions", true, false);
end

function Unhighlight_Decisions_Button()
	highlight_component("button_decisions", false, false);
end

-------------------------------------------------
-- DECISION SPECIFIC STUFF
-------------------------------------------------

function Get_Decision_Tooltip(decision)
	if decision == "restore_byzantine_empire" then
		return GetConditionsString_Byzantium();
	elseif decision == "restore_roman_empire" then
		return GetConditionsString_Roman_Empire();
	elseif decision == "form_kingdom_armenia" then
		return GetConditionsString_Armenia();
	elseif decision == "form_kingdom_italy" then
		return GetConditionsString_Italy();
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

function Get_Decision_Regions(decision)
	if decision == "form_kingdom_armenia" then
		return DeepCopy(REGIONS_ARMENIA);
	elseif decision == "form_kingdom_italy" then
		return DeepCopy(REGIONS_ITALY);
	elseif decision == "form_kingdom_poland" then
		return DeepCopy(REGIONS_POLAND);
	elseif decision == "form_kingdom_spain" then
		return DeepCopy(REGIONS_SPAIN_NO_PORTUGAL);
	elseif decision == "form_empire_golden_horde" then
		return DeepCopy(REGIONS_GOLDEN_HORDE);
	elseif decision == "form_empire_ilkhanate" then
		return DeepCopy(REGIONS_ILKHANATE);
	elseif decision == "restore_roman_empire" then
		return DeepCopy(REGIONS_ROME);
	end
end

function Get_Decision_Map_Faction_Pips(decision)
	if decision == "form_kingdom_armenia" then
		return DeepCopy(REGIONS_ARMENIA_FACTION_PIPS_LOCATIONS);
	elseif decision == "form_kingdom_italy" then
		return DeepCopy(REGIONS_ITALY_FACTION_PIPS_LOCATIONS);
	elseif decision == "form_kingdom_poland" then
		return DeepCopy(REGIONS_POLAND_FACTION_PIPS_LOCATIONS);
	elseif decision == "form_kingdom_spain" then
		return DeepCopy(REGIONS_SPAIN_FACTION_PIPS_LOCATIONS);
	elseif decision == "form_empire_golden_horde" then
		return DeepCopy(REGIONS_GOLDEN_HORDE_FACTION_PIPS_LOCATIONS);
	elseif decision == "form_empire_ilkhanate" then
		return DeepCopy(REGIONS_ILKHANATE_FACTION_PIPS_LOCATIONS);
	elseif decision == "restore_roman_empire" then
		return DeepCopy(REGIONS_ROME_FACTION_PIPS_LOCATIONS);
	end
end

function Decision_Button_Pressed(decision)
	if decision == "restore_byzantine_empire" then
		Byzantine_Empire_Restored(cm:get_local_faction());
	elseif decision == "restore_roman_empire" then
		Roman_Empire_Restored(cm:get_local_faction());
	elseif decision == "form_kingdom_armenia" then
		Armenian_Kingdom_Formed(cm:get_local_faction());
	elseif decision == "form_kingdom_italy" then
		Italian_Kingdom_Formed(cm:get_local_faction());
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
end
