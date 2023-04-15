------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: DECISIONS UI
-- 	By: DETrooper
--
------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------
DECISION_PANEL_OPEN = false;

function mkDecisions:Add_Decisions_UI_Listeners()
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

	self:CreateDecisionsPanel();
end

function mkDecisions:CreateDecisionsPanel()
	local root = cm:ui_root();
	local faction_name = cm:get_local_faction();
	local panDecisions = UIComponent(root:CreateComponent("Decisions_Panel", "UI/new/objectives_screen"));
	local tabgroup_uic = UIComponent(panDecisions:Find("TabGroup"));
	local txt_title_uic = UIComponent(panDecisions:Find("tx_title"));
	local panDecisionsView = UIComponent(panDecisions:CreateComponent("Decisions_Panel_View", "UI/campaign ui/script_dummy"));

	panDecisions:Adopt(txt_title_uic:Address());
	tabgroup_uic:SetVisible(false);
	UIComponent(panDecisions:Find("button_info")):SetVisible(false);
	UIComponent(panDecisions:Find("button_info_holder")):SetVisible(false);
	UIComponent(panDecisions:Find("progress_bar")):SetVisible(false);
	UIComponent(panDecisions:Find("tx_objectives")):SetStateText(UI_LOCALISATION["decisions"]);
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

function mkDecisions:Create_Decisions_Map(decision_key)
	local map_information = self.decision_registry[decision_key].map_information;
	local root = cm:ui_root();
	local rootbX, rootbY = root:Bounds();
	local panDecisions = UIComponent(root:Find("Decisions_Panel"));
	local panDecisionsView = UIComponent(panDecisions:Find("Decisions_Panel_View"));
	local sizeX, sizeY = tonumber(map_information.x), tonumber(map_information.y);
	local panDecisionsMapView = UIComponent(panDecisions:CreateComponent("Decisions_Panel_Map_View", "UI/campaign ui/script_dummy"));
	local mapParchment = UIComponent(panDecisionsMapView:CreateComponent(decision_key.."_Map_Parchment", "UI/new/map_parchment_"..tostring(sizeX)));
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

	local map_uic = UIComponent(mapParchment:CreateComponent(map_information.map_name, "UI/new/maps/"..map_information.map_name));
	local map_uicX, map_uicY = map_uic:Position();
	local mapParchmentX, mapParchmentY = mapParchment:Position();
	local mapParchmentbX, mapParchmentbY = mapParchment:Bounds();
	local tltipDecisions = UIComponent(mapParchment:CreateComponent(decision_key.."_Decision_Tooltip", "UI/new/decision_question"));

	tltipDecisions:SetMoveable(true);
	tltipDecisions:MoveTo(mapParchmentX - 4, mapParchmentY + 32);
	tltipDecisions:SetMoveable(false);

	local map_accept_uic = UIComponent(mapParchment:CreateComponent("map_accept", "UI/new/basic_toggle_accept"));

	map_accept_uic:SetMoveable(true);
	map_accept_uic:MoveTo(mapParchmentX - (sizeX / 2) + 8, mapParchmentY + sizeY + 56);
	map_accept_uic:SetMoveable(false);

	map_uic:SetMoveable(true);
	map_uic:MoveTo(mapParchmentX - sizeX + 32, mapParchmentY + 82);
	map_uic:SetMoveable(false);
	mapParchment:SetVisible(false);
end

function mkDecisions:Refresh_Decisions_Map(decision_key)
	local root = cm:ui_root();
	local panDecisions = UIComponent(root:Find("Decisions_Panel"));
	local panDecisionsMapView = UIComponent(panDecisions:Find("Decisions_Panel_Map_View"));
	local mapParchment = UIComponent(panDecisionsMapView:Find(decision_key.."_Map_Parchment"));
	local mapParchmentPanel = UIComponent(mapParchment:Find("panel"));
	local map_accept_uic = UIComponent(mapParchment:Find("map_accept"));
	local map_uic = UIComponent(mapParchment:Find(self.decision_registry[decision_key].map_information.map_name));
	local map_uicX, map_uicY = map_uic:Position();
	local tx_title_uic = UIComponent(mapParchmentPanel:Find("tx_title"));

	local regions_owned_counter = 0;
	local table_regions = self.decision_registry[decision_key].required_regions;
	local table_faction_pips = self.decision_registry[decision_key].map_information.map_pips;

	if table_regions and table_faction_pips then
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

			if table.HasValue(FACTIONS_WITH_IMAGES, owning_faction_name) then
				image_uic:CreateComponent(region_name.."_logo", "UI/new/faction_flags/"..owning_faction_name.."_flag_small");
			else
				image_uic:CreateComponent(region_name.."_logo", "UI/new/faction_flags/mk_fact_unknown_flag_small");
			end

			local faction_logo_uic = UIComponent(image_uic:Find(region_name.."_logo"));
			faction_logo_uic:SetMoveable(true);
			faction_logo_uic:MoveTo(map_uicX + table_faction_pips[region_name][1], map_uicY + table_faction_pips[region_name][2]);
			faction_logo_uic:SetMoveable(false);
			faction_logo_uic:SetInteractive(false);
		end
	end

	tx_title_uic:SetStateText(UI_LOCALISATION["decision_map_"..decision_key].." - ("..tostring(regions_owned_counter).."/"..tostring(#table_regions)..")");
	map_accept_uic:SetState("active");
	mapParchment:SetVisible(true);
	--mapParchment:TriggerAnimation("show");
end

function OnComponentMouseOn_Decisions_UI(context)
	if DECISION_PANEL_OPEN == true then
		if context.string == "map_accept" then
			local btnAccept = UIComponent(context.component);

			btnAccept:SetTooltipText(UI_LOCALISATION["decision_close_map"]);
		elseif string.find(context.string, "_Decision_Button") then
			local btnDecision = UIComponent(context.component);
			local decision = string.gsub(context.string, "_Decision_Button", "");

			btnDecision:SetTooltipText(UI_LOCALISATION["decision_enact_decision"]);
		elseif string.find(context.string, "_Decision_Tooltip") then
			local tltipDecisions = UIComponent(context.component);
			local decision = string.gsub(context.string, "_Decision_Tooltip", "");

			tltipDecisions:SetTooltipText(mkDecisions.decision_registry[decision].tooltip() or "");
		elseif string.find(context.string, "_Decision_Map_Button") then
			local mapDecisions = UIComponent(context.component);

			mapDecisions:SetTooltipText(UI_LOCALISATION["decision_map_button"]);
		end
	end
end

function OnComponentLClickUp_Decisions_UI(context)
	if context.string == "button_decisions" then
		local root = cm:ui_root();
		local panDecisions = UIComponent(root:Find("Decisions_Panel"));

		if DECISION_PANEL_OPEN == false then
			panDecisions:SetVisible(true);
			mkDecisions:RefreshDecisionsPanel();
			DECISION_PANEL_OPEN = true;
		else
			mkDecisions:CloseDecisionsPanel(true);
		end

		mkDecisions:Unhighlight_Decisions_Button();
	elseif DECISION_PANEL_OPEN == true then
		if context.string == "root" then
			mkDecisions:CloseDecisionsPanel(false);
		elseif context.string == "map_accept" then
			UIComponent(UIComponent(context.component):Parent()):SetVisible(false);
		elseif string.find(context.string, "_Decision_Button") then
			local decision_key = string.gsub(context.string, "_Decision_Button", "");
			local root = cm:ui_root();

			UIComponent(context.component):SetState("inactive");

			if mkDecisions.decision_registry[decision_key].callback then
				mkDecisions.decision_registry[decision_key].callback(cm:get_local_faction());
			end
		
			mkDecisions:RefreshDecisionsPanel();
		elseif string.find(context.string, "_Decision_Map_Button") then
			local root = cm:ui_root();
			local decision_key = string.gsub(context.string, "_Decision_Map_Button", "");
			local panDecisions = UIComponent(root:Find("Decisions_Panel"));
			local mapParchment = UIComponent(panDecisions:Find(decision_key.."_Map_Parchment"));

			if mapParchment:Visible() == true then
				mapParchment:SetVisible(false);
			else
				mkDecisions:Refresh_Decisions_Map(decision_key);
			end
		end
	end
end

function FactionTurnEnd_Decisions_UI(context)
	if context:faction():is_human() then
		mkDecisions:CloseDecisionsPanel(false);

		local root = cm:ui_root();
		local btnDecisions = UIComponent(root:Find("button_decisions"));

		btnDecisions:SetState("inactive");
	end
end

function OnPanelOpenedCampaign_Decisions_UI(context)
	mkDecisions:CloseDecisionsPanel(false);
end

function mkDecisions:CloseDecisionsPanel(hover)
	local root = cm:ui_root();
	local panDecisions = UIComponent(root:Find("Decisions_Panel"));
	local btnDecisions = UIComponent(root:Find("button_decisions"));

	if #self.decisions > 0 then
		for _, decision in ipairs(self.decisions) do
			if self.decision_registry[decision[1]].map_information then
				local mapParchment = UIComponent(panDecisions:Find(self.decisions[i][1].."_Map_Parchment"));

				if mapParchment:Address()  then
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

function mkDecisions:RefreshDecisionsPanel()
	local root = cm:ui_root();
	local panDecisions = UIComponent(root:Find("Decisions_Panel"));
	local panDecisionsView = UIComponent(panDecisions:Find("Decisions_Panel_View"));
	local curX, curY = panDecisions:Position();
	local txt_title_uic = UIComponent(panDecisions:Find("tx_title"));
	txt_title_uic:SetStateText(Get_DFN_Localisation(cm:get_local_faction()));
	panDecisionsView:DestroyChildren();
	
	local offset = 0;
 
	if #self.decisions > 0 then
		for i, decision in ipairs(self.decisions) do
			local decision_key = decision[1];
			local priority_decision = decision[4];

			if priority_decision then
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

				if decision[3] == false then
					btnDecisions:SetState("inactive");
				end

				tltipDecisions:SetMoveable(true);
				tltipDecisions:MoveTo(curX + 575, curY + 104 + ((i - 1) * 32));
				tltipDecisions:SetMoveable(false);
				--tltipDecisions:SetInteractive(false);

				if self.decision_registry[decision_key].map_information then
					panDecisionsView:CreateComponent(decision_key.."_Decision_Map_Button", "UI/new/button_small_decision_map");

					local mapDecisions = UIComponent(panDecisionsView:Find(decision_key.."_Decision_Map_Button"));

					mapDecisions:Resize(24, 24);
					mapDecisions:SetMoveable(true);
					mapDecisions:MoveTo(curX + 540, curY + 103 + ((i - 1) * 32));
					mapDecisions:SetMoveable(false);

					local mapParchment = UIComponent(panDecisions:Find(decision_key.."_Map_Parchment"));

					if mapParchment:Address() == nil then
						self:Create_Decisions_Map(decision_key);
					end
				end

				textDecisions:SetMoveable(true);
				textDecisions:MoveTo(curX + 175, curY + 104 + ((i - 1) * 32));
				textDecisions:SetMoveable(false);
				textDecisions:SetInteractive(false);

				dy_name:SetStateText(UI_LOCALISATION["decision_title_"..decision_key] or "Unknown Title");
				mon_frame:SetVisible(false);
				mon_24:SetVisible(false);
				diplomatic_relations_fill:SetVisible(false);

				textDecisions:Resize(200, 24);
				
				offset = offset + 1;
			end
		end

		for i, decision in ipairs(self.decisions) do
			local decision_key = decision[1];
			local priority_decision = decision[4];

			if not priority_decision then
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
				btnDecisions:MoveTo(curX + 610, curY + 103 + ((i - 1 + offset) * 32));
				btnDecisions:SetMoveable(false);

				if decision[3] == false then
					btnDecisions:SetState("inactive");
				end

				tltipDecisions:SetMoveable(true);
				tltipDecisions:MoveTo(curX + 575, curY + 104 + ((i - 1 + offset) * 32));
				tltipDecisions:SetMoveable(false);
				--tltipDecisions:SetInteractive(false);

				if self.decision_registry[decision_key].map_information then
					panDecisionsView:CreateComponent(decision_key.."_Decision_Map_Button", "UI/new/button_small_decision_map");

					local mapDecisions = UIComponent(panDecisionsView:Find(decision_key.."_Decision_Map_Button"));

					mapDecisions:Resize(24, 24);
					mapDecisions:SetMoveable(true);
					mapDecisions:MoveTo(curX + 540, curY + 103 + ((i - 1) * 32));
					mapDecisions:SetMoveable(false);

					local mapParchment = UIComponent(panDecisions:Find(decision_key.."_Map_Parchment"));

					if mapParchment:Address() == nil then
						self:Create_Decisions_Map(decision_key);
					end
				end

				textDecisions:SetMoveable(true);
				textDecisions:MoveTo(curX + 175, curY + 104 + ((i - 1 + offset) * 32));
				textDecisions:SetMoveable(false);
				textDecisions:SetInteractive(false);

				dy_name:SetStateText(UI_LOCALISATION["decision_title_"..decision_key] or "Unknown Title");
				mon_frame:SetVisible(false);
				mon_24:SetVisible(false);
				diplomatic_relations_fill:SetVisible(false);

				textDecisions:Resize(200, 24);
			end
		end
	end
end

function mkDecisions:Highlight_Decisions_Button()
	highlight_component("button_decisions", true, false);
end

function mkDecisions:Unhighlight_Decisions_Button()
	highlight_component("button_decisions", false, false);
end
