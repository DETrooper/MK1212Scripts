-------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: HOLY ROMAN EMPIRE UI
-- 	By: DETrooper
--
-------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------

HRE_PANEL_OPEN = false;
HRE_FACTION_SELECTED = nil;

function Add_HRE_UI_Listeners()
	cm:add_listener(
		"FactionTurnEnd_HRE_UI",
		"FactionTurnEnd",
		true,
		function(context) FactionTurnEnd_HRE_UI(context) end,
		true
	);
	cm:add_listener(
		"OnComponentMouseOn_HRE_UI",
		"ComponentMouseOn",
		true,
		function(context) OnComponentMouseOn_HRE_UI(context) end,
		true
	);
	cm:add_listener(
		"OnComponentLClickUp_HRE_UI",
		"ComponentLClickUp",
		true,
		function(context) OnComponentLClickUp_HRE_UI(context) end,
		true
	);
	cm:add_listener(
		"OnPanelOpenedCampaign_HRE_UI",
		"PanelOpenedCampaign",
		true,
		function(context) OnPanelOpenedCampaign_HRE_UI(context) end,
		true
	);
	cm:add_listener(
		"TimeTrigger_HRE_UI",
		"TimeTrigger",
		true,
		function(context) TimeTrigger_HRE_UI(context) end,
		true
	);

	CreateHREPanel();
end

function CreateHREPanel()
	local root = cm:ui_root();

	root:CreateComponent("HRE_Panel", "UI/new/hre_panel");
	local panHRE = UIComponent(root:Find("HRE_Panel"));
	local panHREX, panHREY = panHRE:Position();
	local btnHREInfo = UIComponent(panHRE:Find("hre_info"));
	local btnHREInfoX, btnHREInfoY = btnHREInfo:Position();
	local HREInfo_tab_child_uic = UIComponent(btnHREInfo:Find("tab_child"));
	local btnHREPolicies = UIComponent(panHRE:Find("hre_policies"));
	local policies_tab_child_uic = UIComponent(btnHREPolicies:Find("tab_child"));
	local policies_panel_uic = UIComponent(policies_tab_child_uic:Find("policies_panel"));
	local btnVote = UIComponent(panHRE:Find("button_vote"));
	local btnVoteX, btnVoteY = btnVote:Position();
	local btnBackCandidate = UIComponent(panHRE:Find("button_back_candidate"));
	local btnClose = UIComponent(panHRE:Find("button_close"));

	btnClose:SetMoveable(true);
	btnClose:MoveTo(btnVoteX - 175, btnVoteY);
	btnClose:SetMoveable(false);

	panHRE:CreateComponent("hre_map", "UI/new/maps/hre_map");

	local map_uic = UIComponent(panHRE:Find("hre_map"));
	map_uic:SetMoveable(true);
	map_uic:MoveTo(btnVoteX - 717, btnVoteY - 707);
	map_uic:SetMoveable(false);

	local garbage = UIComponent(root:Find("garbage"));

	garbage:CreateComponent("HRE_Parchment", "UI/campaign ui/objectives_screen");
	local parchment_uic = UIComponent(panHRE:Find("parchment"));
	local parchment_uicX, parchment_uicY = parchment_uic:Position();
	local title_plaque_uic = UIComponent(garbage:Find("title_plaque"));
	local tx_objectives_uic = UIComponent(garbage:Find("tx_objectives"));
	local tx_title_uic = UIComponent(garbage:Find("tx_title"));
	local progress_bar_uic = UIComponent(garbage:Find("progress_bar"));

	panHRE:Adopt(title_plaque_uic:Address());
	tx_title_uic:Resize(600, 43);
	parchment_uic:Adopt(tx_title_uic:Address());
	title_plaque_uic:SetMoveable(true);
	title_plaque_uic:MoveTo(parchment_uicX - 382, parchment_uicY - 49);
	title_plaque_uic:SetMoveable(false);
	tx_title_uic:SetMoveable(true);
	tx_title_uic:MoveTo(parchment_uicX + 27, parchment_uicY + 218);
	tx_title_uic:SetMoveable(false);
	progress_bar_uic:SetVisible(false);
	tx_objectives_uic:SetStateText("Pretender: Federico II");
	tx_title_uic:SetStateText("This faction is the emperor!");
	garbage:DestroyChildren();

	garbage:CreateComponent("HRE_Titles", "UI/campaign ui/objectives_screen");
	title_plaque_uic = UIComponent(garbage:Find("title_plaque"));
	tx_title_uic = UIComponent(garbage:Find("tx_title"));
	tx_objectives_uic = UIComponent(garbage:Find("tx_objectives"));
	panHRE:Adopt(title_plaque_uic:Address());
	progress_bar_uic = UIComponent(garbage:Find("progress_bar"));

	tx_title_uic:Resize(600, 43);
	parchment_uic:Adopt(tx_title_uic:Address());
	title_plaque_uic:SetMoveable(true);
	title_plaque_uic:MoveTo(parchment_uicX - 686, parchment_uicY - 49);
	title_plaque_uic:SetMoveable(false);
	tx_title_uic:SetMoveable(true);
	tx_title_uic:MoveTo(parchment_uicX + 27, parchment_uicY + 383);
	tx_title_uic:SetMoveable(false);
	progress_bar_uic:SetVisible(false);
	tx_objectives_uic:SetStateText("Emperor: Otto IV");
	tx_title_uic:SetStateText("Elections");
	garbage:DestroyChildren();

	parchment_uic:CreateComponent("Parchment_UI_Layer", "UI/campaign ui/script_dummy");
	parchment_uic:CreateComponent("Election_UI_Layer", "UI/campaign ui/script_dummy");

	parchment_uic:Adopt(btnVote:Address());
	parchment_uic:Adopt(btnBackCandidate:Address());
	btnVote:SetMoveable(true);
	btnVote:MoveTo(parchment_uicX + 53, parchment_uicY + 644);
	btnVote:SetMoveable(false);
	btnBackCandidate:SetMoveable(true);
	btnBackCandidate:MoveTo(parchment_uicX + 333, parchment_uicY + 644);
	btnBackCandidate:SetMoveable(false);
	btnBackCandidate:SetVisible(true);

	Update_Map_Regions_HRE_UI(root);
	Setup_Reforms_HRE_UI(root);
	Setup_Decrees_HRE_UI(root);

	garbage:CreateComponent("HRE_Text", "UI/campaign ui/clan");
	local btnSummary = UIComponent(garbage:Find("Summary"));
   	local btnRecords = UIComponent(garbage:Find("Records"));
	btnSummary:ClearSound();
	btnSummary:SimulateClick();

	local bar_uic = UIComponent(garbage:Find("bar"));
	bar_uic:DestroyChildren();
	bar_uic:SetVisible(false);
	parchment_uic:Adopt(bar_uic:Address());

	btnRecords:ClearSound();
	btnRecords:SimulateClick();
	cm:add_time_trigger("HRE_Text_Setup", 0.1);

	panHRE:SetVisible(false);
end

function OnComponentMouseOn_HRE_UI(context)
	if context.string == "button_vote" then
		UIComponent(context.component):SetTooltipText("Cast your vote for this faction in the next election for the Holy Roman Emperor.");
	elseif context.string == "button_back_candidate" then
		UIComponent(context.component):SetTooltipText("Back this faction's candidate in the next election for the Holy Roman Emperor.");
	elseif context.string == "dy_imperium" then
		if HRE_PANEL_OPEN == true then
			if HRE_FACTION_SELECTED == HRE_EMPEROR_KEY then
				UIComponent(context.component):SetTooltipText(Get_Authority_Tooltip());
			else
				UIComponent(context.component):SetTooltipText(HRE_STATES[HRE_FACTIONS_STATES[HRE_FACTION_SELECTED]][2]);
			end
		end
	elseif context.string == "tx_authority" then
		UIComponent(context.component):SetTooltipText(Get_Authority_Tooltip());
	elseif string.find(context.string, "button_decree_") then
		local tltipDecree = UIComponent(context.component);
		local decree_number = string.gsub(context.string, "button_decree_", "");
		local decree_key = HRE_DECREES[tonumber(decree_number)]["key"];

		tltipDecree:SetTooltipText(Get_Decree_Tooltip(decree_key));
	elseif string.find(context.string, "_Reform_Tooltip") then
		local tltipReform = UIComponent(context.component);
		local reform_key = string.gsub(context.string, "_Reform_Tooltip", "");

		tltipReform:SetTooltipText(Get_Reform_Tooltip(reform_key));
	elseif string.find(context.string, "_Reform_Button") then
		local btnReform = UIComponent(context.component);

		if cm:get_local_faction() == HRE_EMPEROR_KEY then
			btnReform:SetTooltipText("Pass this reform!");
		else
			if HasValue(HRE_REFORMS_VOTES, cm:get_local_faction()) then
				btnReform:SetTooltipText("Retract your vote from this reform.");
			else
				btnReform:SetTooltipText("Vote in favor of this reform.");
			end
		end
	elseif string.find(context.string, "_logo") then
		local state = "";
		local in_hre = "";

		if string.find(context.string, "mk_fact_") then
			local faction_name = string.gsub(context.string, "_logo", "");

			if HasValue(HRE_FACTIONS, faction_name) and faction_name ~= HRE_EMPEROR_KEY then
				local faction_state = HRE_FACTIONS_STATES[faction_name];
			
				if faction_state == "malcontent" or faction_state == "pretender" or faction_state == "ambitious" then
					state = "\n\nAttitude: [[rgba:255:0:0:150]]"..HRE_STATES[faction_state][1].."[[/rgba]]";
				elseif faction_state == "discontent" then
					state = "\n\nAttitude: [[rgba:255:255:0:150]]"..HRE_STATES[faction_state][1].."[[/rgba]]";
				elseif faction_state == "loyal" or faction_state == "emperor" then
					state = "\n\nAttitude: [[rgba:8:201:27:150]]"..HRE_STATES[faction_state][1].."[[/rgba]]";
				elseif faction_state == "puppet" then
					state = "\n\nAttitude: [[rgba:51:153:255:150]]"..HRE_STATES[faction_state][1].."[[/rgba]]";
				else
					state = "\n\nAttitude: "..HRE_STATES[faction_state][1];
				end
			elseif faction_name == HRE_EMPEROR_KEY then
				in_hre = "\n\n[[rgba:255:215:0:150]]This faction is the Emperor![[/rgba]]";
			elseif faction_name == HRE_EMPEROR_PRETENDER_KEY then
				in_hre = "\n\n[[rgba:255:215:0:150]]This faction is a pretender to the throne![[/rgba]]";
			else
				in_hre = "\n\n[[rgba:255:0:0:150]]This faction is not in the Holy Roman Empire![[/rgba]]";
			end

			UIComponent(context.component):SetTooltipText(Get_DFN_Localisation(faction_name)..in_hre..state);
		elseif string.find(context.string, "att_reg_") then
			local region_name = string.gsub(context.string, "_logo", "");
			local region = cm:model():world():region_manager():region_by_key(region_name);
			local owning_faction_name = region:owning_faction():name();
			local population = "0";

			if POPULATION_REGIONS_POPULATIONS[region_name] ~= nil then
				population = tostring(Get_Total_Population_Region(region_name));
			end

			if HasValue(HRE_FACTIONS, owning_faction_name) and owning_faction_name ~= HRE_EMPEROR_KEY then
				local faction_state = HRE_FACTIONS_STATES[owning_faction_name];
			
				if faction_state == "malcontent" or faction_state == "pretender" or faction_state == "ambitious" then
					state = "\n\nAttitude: [[rgba:255:0:0:150]]"..HRE_STATES[faction_state][1].."[[/rgba]]";
				elseif faction_state == "discontent" then
					state = "\n\nAttitude: [[rgba:255:255:0:150]]"..HRE_STATES[faction_state][1].."[[/rgba]]";
				elseif faction_state == "loyal" or faction_state == "emperor" then
					state = "\n\nAttitude: [[rgba:8:201:27:150]]"..HRE_STATES[faction_state][1].."[[/rgba]]";
				elseif faction_state == "puppet" then
					state = "\n\nAttitude: [[rgba:51:153:255:150]]"..HRE_STATES[faction_state][1].."[[/rgba]]";
				else
					state = "\n\nAttitude: "..HRE_STATES[faction_state][1];
				end
			elseif owning_faction_name == HRE_EMPEROR_KEY then
				in_hre = "\n\n[[rgba:255:215:0:150]]This faction is the Emperor![[/rgba]]";
			elseif owning_faction_name == HRE_EMPEROR_PRETENDER_KEY then
				in_hre = "\n\n[[rgba:255:215:0:150]]This faction is a pretender to the throne![[/rgba]]";
			else
				in_hre = "\n\n[[rgba:255:0:0:150]]This faction is not in the Holy Roman Empire![[/rgba]]";
			end

			UIComponent(context.component):SetTooltipText("Region: "..REGIONS_NAMES_LOCALISATION[region_name].."\nPopulation: "..population.."\nOwner: "..Get_DFN_Localisation(owning_faction_name)..in_hre..state);
		end
	end
end

function OnComponentLClickUp_HRE_UI(context)
	if context.string == "button_hre" then
		if HRE_PANEL_OPEN == false then
			OpenHREPanel();
			HRE_PANEL_OPEN = true;
		else
			CloseHREPanel(true);
		end
	elseif context.string == "root" and HRE_PANEL_OPEN == true then
		CloseHREPanel(false);
	elseif context.string == "button_close" then
		if UIComponent(UIComponent(UIComponent(context.component):Parent()):Parent()):Id() == "HRE_Panel" then
			CloseHREPanel(false);
		end
	elseif context.string == "button_vote" then
		local root = cm:ui_root();

		UIComponent(context.component):SetState("inactive");
		Cast_Vote_For_Faction_HRE(cm:get_local_faction(), HRE_FACTION_SELECTED);
		Update_State_HRE_UI(HRE_FACTION_SELECTED);
		Setup_Elector_Faction_Info_HRE_UI(root, HRE_FACTION_SELECTED);
	elseif context.string == "button_back_candidate" then
		local root = cm:ui_root();

		UIComponent(context.component):SetState("inactive");
		Cast_Vote_For_Factions_Candidate_HRE(cm:get_local_faction(), HRE_FACTION_SELECTED);
		Update_State_HRE_UI(HRE_FACTION_SELECTED);
		Setup_Elector_Faction_Info_HRE_UI(root, HRE_FACTION_SELECTED);
	elseif string.find(context.string, "button_decree_") then
		local decree_number = string.gsub(context.string, "button_decree_", "");

		if HRE_ACTIVE_DECREE == "nil" then
			Activate_Decree(HRE_DECREES[tonumber(decree_number)]["key"]);
		end

		Update_Active_Decrees_HRE_UI();
	elseif string.find(context.string, "_Reform_Button") then
		if UIComponent(context.component):CurrentState() ~= "inactive" then
			if cm:get_local_faction() == HRE_EMPEROR_KEY then
				Pass_HRE_Reform(CURRENT_HRE_REFORM + 1);
				Update_Authority_HRE_UI();
			else
				if HasValue(HRE_REFORMS_VOTES, cm:get_local_faction()) then
					Remove_Vote_For_Current_Reform_HRE(cm:get_local_faction());
				else
					Cast_Vote_For_Current_Reform_HRE(cm:get_local_faction());
				end
			end

			Update_Reforms_HRE_UI();
		end
	elseif string.find(context.string, "_logo") then
		local root = cm:ui_root();

		if string.find(context.string, "mk_fact_") then
			local faction_name = string.gsub(context.string, "_logo", "");
			local faction = cm:model():world():faction_by_key(faction_name);
			local capital_name = faction:home_region():name();

			Setup_Faction_Info_HRE_UI(root, faction_name);
		elseif string.find(context.string, "att_reg_") then
			local region_name = string.gsub(context.string, "_logo", "");
			local region = cm:model():world():region_manager():region_by_key(region_name);
			local owning_faction_name = region:owning_faction():name();

			Setup_Faction_Info_HRE_UI(root, owning_faction_name);
		end
	end
end

function FactionTurnEnd_HRE_UI(context)
	if context:faction():is_human() then
		CloseHREPanel(false);
	end
end

function OnPanelOpenedCampaign_HRE_UI(context)
	CloseHREPanel(false);
end

function TimeTrigger_HRE_UI(context)
	if context.string == "HRE_Text_Setup" then
		local root = cm:ui_root();
		local garbage = UIComponent(root:Find("garbage"));
		local panHRE = UIComponent(root:Find("HRE_Panel"));
		local parchment_uic = UIComponent(panHRE:Find("parchment"));
		local parchment_uicX, parchment_uicY = parchment_uic:Position();
		local faction_context_subpanel_uic = UIComponent(garbage:Find("faction_context_subpanel"));
		local dy_name_uic = UIComponent(faction_context_subpanel_uic:Find("dy_name"));
		local dy_faction_symbol_uic = UIComponent(faction_context_subpanel_uic:Find("dy_faction_symbol"));

		dy_faction_symbol_uic:SetVisible(false);
		parchment_uic:Adopt(faction_context_subpanel_uic:Address());
		garbage:DestroyChildren();

		faction_context_subpanel_uic:SetMoveable(true);
		faction_context_subpanel_uic:MoveTo(parchment_uicX - 60, parchment_uicY + 210);
		faction_context_subpanel_uic:SetMoveable(false);
		dy_name_uic:Resize(570, 30);
		dy_name_uic:SetMoveable(true);
		dy_name_uic:MoveTo(parchment_uicX + 40, parchment_uicY + 10);
		dy_name_uic:SetMoveable(false);

		for i = 0, faction_context_subpanel_uic:ChildCount() - 1 do
			local child = UIComponent(faction_context_subpanel_uic:Find(i));
		
			if child:Id() == "tx_prosperity" or child:Id() == "tx_faction_leader" or child:Id() == "tx_imperium" then
				local childX, childY = child:Position();

				child:SetMoveable(true);
				child:MoveTo(childX - 110, childY);
				child:SetMoveable(false);
			elseif child:Id() == "tx_hordes_owned" then
				local dy_hordes_owned_uic = UIComponent(child:Find("dy_hordes_owned"));

				child:SetMoveable(true);
				child:MoveTo(parchment_uicX + 260, parchment_uicY + 412);
				child:SetMoveable(false);
				dy_hordes_owned_uic:SetMoveable(true);
				dy_hordes_owned_uic:MoveTo(parchment_uicX + 378, parchment_uicY + 576);
				dy_hordes_owned_uic:SetMoveable(false);
			end

			if child:Id() ~= "dy_name" and child:Id() ~= "dy_faction_symbol" then		
				for j = 0, child:ChildCount() - 1 do
					local sub_child = UIComponent(child:Find(j));
					local sub_childX, sub_childY = sub_child:Position();

					sub_child:SetMoveable(true);
					sub_child:MoveTo(sub_childX - 80, sub_childY);
					sub_child:SetMoveable(false);
				end
			end
		end
	end
end

function OpenHREPanel()
	local root = cm:ui_root();
	local panHRE = UIComponent(root:Find("HRE_Panel"));
	local btnHREInfo = UIComponent(panHRE:Find("hre_info"));
	local HREInfo_tab_child_uic = UIComponent(btnHREInfo:Find("tab_child"));
	local tx_objectives_uic1 = UIComponent(UIComponent(panHRE:Find(4)):Find("tx_objectives"));
	local tx_objectives_uic2 = UIComponent(UIComponent(panHRE:Find(5)):Find("tx_objectives"));
	local btnHREPolicies = UIComponent(panHRE:Find("hre_policies"));
	local hre_emperor_faction = cm:model():world():faction_by_key(HRE_EMPEROR_KEY);
	local emperor_number = "";
	local hre_regions_owned = 0;

	tx_objectives_uic1:DestroyChildren();
	tx_objectives_uic2:DestroyChildren();

	if HRE_EMPEROR_PRETENDER_KEY ~= "nil" then
		local hre_pretender_faction = cm:model():world():faction_by_key(HRE_EMPEROR_PRETENDER_KEY);
		local pretender_number = "";

		if HRE_EMPERORS_NAMES_NUMBERS[hre_pretender_faction:faction_leader():get_forename()] ~= nil then
			pretender_number = HRE_EMPERORS_ROMAN_NUMERALS[HRE_EMPERORS_NAMES_NUMBERS[hre_pretender_faction:faction_leader():get_forename()]];
		end

		tx_objectives_uic1:SetStateText("Pretender: "..NAMES_TO_LOCALISATION[hre_pretender_faction:faction_leader():get_forename()].." "..pretender_number);
		tx_objectives_uic1:CreateComponent(HRE_EMPEROR_PRETENDER_KEY.."_logo", "UI/new/faction_flags/"..HRE_EMPEROR_PRETENDER_KEY.."_flag_small");

		local faction_logo_uic = UIComponent(tx_objectives_uic1:Find(0));
		local tx_objectives_uic1X, tx_objectives_uic1Y = tx_objectives_uic1:Position();
		faction_logo_uic:SetMoveable(true);
		faction_logo_uic:MoveTo(tx_objectives_uic1X - 32, tx_objectives_uic1Y + 4);
		faction_logo_uic:SetMoveable(false);
	else
		tx_objectives_uic1:SetStateText("Pretender: None");
	end

	if HRE_EMPERORS_NAMES_NUMBERS[hre_emperor_faction:faction_leader():get_forename()] ~= nil then
		emperor_number = HRE_EMPERORS_ROMAN_NUMERALS[HRE_EMPERORS_NAMES_NUMBERS[hre_emperor_faction:faction_leader():get_forename()]];
	end

	tx_objectives_uic2:SetStateText("Emperor: "..NAMES_TO_LOCALISATION[hre_emperor_faction:faction_leader():get_forename()].." "..emperor_number);
	tx_objectives_uic2:CreateComponent(HRE_EMPEROR_KEY.."_logo", "UI/new/faction_flags/"..HRE_EMPEROR_KEY.."_flag_small");

	local faction_logo_uic = UIComponent(tx_objectives_uic2:Find(0));
	local tx_objectives_uic2X, tx_objectives_uic2Y = tx_objectives_uic2:Position();
	faction_logo_uic:SetMoveable(true);
	faction_logo_uic:MoveTo(tx_objectives_uic2X - 32, tx_objectives_uic2Y + 4);
	faction_logo_uic:SetMoveable(false);

	--[[tx_objectives_uic1:SetStateText("Emperor: "..NAMES_TO_LOCALISATION[hre_emperor_faction:faction_leader():get_forename()].." "..number);

	for i = 1, #HRE_REGIONS do
		local region_name = HRE_REGIONS[i];
		local region = cm:model():world():region_manager():region_by_key(region_name);
		local owning_faction_name = region:owning_faction():name();

		if HasValue(HRE_FACTIONS, owning_faction_name) then
			hre_regions_owned = hre_regions_owned + 1;
		end
	end

	tx_objectives_uic2:SetStateText("Imperial Territory: ("..tostring(hre_regions_owned).."/"..tostring(#HRE_REGIONS)..")");]]--

	Update_Map_Regions_HRE_UI(root);
	Setup_Faction_Info_HRE_UI(root, cm:get_local_faction());
	Update_Reforms_HRE_UI();
	Update_Active_Decrees_HRE_UI();
	panHRE:SetVisible(true);
end

function CloseHREPanel(hover)
	local root = cm:ui_root();
	local panHRE = UIComponent(root:Find("HRE_Panel"));
	local btnHRE = UIComponent(root:Find("button_hre"));
	panHRE:SetVisible(false);

	if hover == true then
		btnHRE:SetState("hover");
	else
		btnHRE:SetState("active");
	end

	HRE_PANEL_OPEN = false;
end

function Update_Map_Regions_HRE_UI(root)
	local panHRE = UIComponent(root:Find("HRE_Panel"));
	local map_uic = UIComponent(panHRE:Find("hre_map"));
	local map_uicX, map_uicY = map_uic:Position();

	for i = 1, #HRE_REGIONS do
		local region_name = HRE_REGIONS[i];
		local region = cm:model():world():region_manager():region_by_key(region_name);
		local owning_faction_name = region:owning_faction():name();
		local image_name = HRE_REGIONS_TO_IMAGES[region_name];
		local image_uic = UIComponent(map_uic:Find(image_name));

		image_uic:DestroyChildren();

		if owning_faction_name == HRE_EMPEROR_KEY then
			image_uic:PropagateImageColour(255, 215, 0, 150);
		elseif HasValue(HRE_FACTIONS, owning_faction_name) then
			image_uic:PropagateImageColour(0, 204, 0, 150);
		else
			image_uic:PropagateImageColour(204, 0, 0, 150);
		end

		--if HasValue(FACTIONS_WITH_IMAGES, owning_faction_name) then
			image_uic:CreateComponent(region_name.."_logo", "UI/new/faction_flags/"..owning_faction_name.."_flag_small");
		--else
			--image_uic:CreateComponent(region_name.."_logo", "UI/campaign ui/faction_flag_small");
		--end

		local faction_logo_uic = UIComponent(image_uic:Find(region_name.."_logo"));
		faction_logo_uic:SetMoveable(true);
		faction_logo_uic:MoveTo(map_uicX + HRE_REGION_FACTION_PIPS_LOCATIONS[region_name][1], map_uicY + HRE_REGION_FACTION_PIPS_LOCATIONS[region_name][2]);
		faction_logo_uic:SetMoveable(false);
	end
end

function Setup_Reforms_HRE_UI(root)
	local panHRE = UIComponent(root:Find("HRE_Panel"));
	local btnHREPolicies = UIComponent(panHRE:Find("hre_policies"));
	local btnHREPolicies_tab_child_uic = UIComponent(btnHREPolicies:Find("tab_child"));

	btnHREPolicies_tab_child_uic:CreateComponent("Reforms_Panel_View", "UI/campaign ui/script_dummy");
	local panReformsView = UIComponent(btnHREPolicies_tab_child_uic:Find("Reforms_Panel_View"));
	local curX, curY = panReformsView:Position();

	panReformsView:Resize(545, 300);
	panReformsView:SetMoveable(true);
	panReformsView:MoveTo(curX - 140, curY + 162);
	panReformsView:SetMoveable(false);
	curX, curY = panReformsView:Position();

	for i = 1, #HRE_REFORMS do
		panReformsView:CreateComponent(HRE_REFORMS[i]["key"].."_Reform_Button", "UI/new/button_small_accept");
		panReformsView:CreateComponent(HRE_REFORMS[i]["key"].."_Reform_Tooltip", "UI/new/decision_question");
		panReformsView:CreateComponent(HRE_REFORMS[i]["key"].."_Text", "UI/campaign ui/city_info_bar_horde");

		local btnReform = UIComponent(panReformsView:Find(HRE_REFORMS[i]["key"].."_Reform_Button"));
		local tltipReform = UIComponent(panReformsView:Find(HRE_REFORMS[i]["key"].."_Reform_Tooltip"));
		local textReform = UIComponent(panReformsView:Find(HRE_REFORMS[i]["key"].."_Text"));
		local mon_frame = UIComponent(textReform:Find("mon_frame"));
		local mon_24 = UIComponent(textReform:Find("mon_24"));
		local dy_name = UIComponent(textReform:Find("dy_name"));
		local diplomatic_relations_fill = UIComponent(textReform:Find("diplomatic_relations_fill"));

		btnReform:Resize(24, 24);
		btnReform:SetMoveable(true);
		btnReform:MoveTo(curX + 435, curY + ((i - 1) * 32));
		btnReform:SetMoveable(false);

		tltipReform:SetMoveable(true);
		tltipReform:MoveTo(curX + 400, curY + 1 + ((i - 1) * 32));
		tltipReform:SetMoveable(false);

		textReform:SetMoveable(true);
		textReform:MoveTo(curX + 32, curY + 1 + ((i - 1) * 32));
		textReform:SetMoveable(false);
		textReform:SetInteractive(false);

		dy_name:SetStateText(HRE_REFORMS[i]["name"]);
		mon_frame:SetVisible(false);
		mon_24:SetVisible(false);
		diplomatic_relations_fill:SetVisible(false);

		textReform:Resize(200, 24);
	end

	Update_Reforms_HRE_UI();
end

function Setup_Decrees_HRE_UI(root)
	local panHRE = UIComponent(root:Find("HRE_Panel"));
	local btnHREPolicies = UIComponent(panHRE:Find("hre_policies"));
	local btnHREPolicies_tab_child_uic = UIComponent(btnHREPolicies:Find("tab_child"));

	for i = 1, #HRE_DECREES do
		local btnDecree = UIComponent(btnHREPolicies_tab_child_uic:Find("button_decree_"..tostring(i)));
		local btnDecreeString = UIComponent(btnDecree:Find("string"));

		btnDecreeString:SetStateText(HRE_DECREES[i]["name"]);
	end
end

function Update_Reforms_HRE_UI()
	local root = cm:ui_root();
	local panHRE = UIComponent(root:Find("HRE_Panel"));
	local btnHREPolicies = UIComponent(panHRE:Find("hre_policies"));
	local btnHREPolicies_tab_child_uic = UIComponent(btnHREPolicies:Find("tab_child"));
	local tx_reforms = UIComponent(btnHREPolicies_tab_child_uic:Find("tx_reforms"));
	local panReformsView = UIComponent(btnHREPolicies_tab_child_uic:Find("Reforms_Panel_View"));

	for i = 1, #HRE_REFORMS do
		local btnReform = UIComponent(panReformsView:Find(HRE_REFORMS[i]["key"].."_Reform_Button"));

		if CURRENT_HRE_REFORM == i - 1 then
			if cm:get_local_faction() == HRE_EMPEROR_KEY then
				if HRE_IMPERIAL_AUTHORITY == HRE_REFORM_COST and #HRE_REFORMS_VOTES >= math.ceil((#HRE_FACTIONS - 1) / 2) then
					btnReform:SetState("active");
				else
					btnReform:SetState("inactive");
				end
			else
				if HasValue(HRE_REFORMS_VOTES, cm:get_local_faction()) then
					btnReform:SetState("active");
				end
			end
		else
			btnReform:SetState("inactive");
		end
	end

	tx_reforms:SetStateText("Support For "..HRE_REFORMS[CURRENT_HRE_REFORM + 1]["name"]..": ("..tostring(#HRE_REFORMS_VOTES).." / "..tostring(#HRE_FACTIONS - 1)..")");
end

function Update_Active_Decrees_HRE_UI()
	local root = cm:ui_root();
	local panHRE = UIComponent(root:Find("HRE_Panel"));
	local btnHREPolicies = UIComponent(panHRE:Find("hre_policies"));
	local btnHREPolicies_tab_child_uic = UIComponent(btnHREPolicies:Find("tab_child"));
	local tx_decrees_uic = UIComponent(btnHREPolicies_tab_child_uic:Find("tx_decrees"));

	if HRE_ACTIVE_DECREE == "nil" then
		tx_decrees_uic:SetStateText("There is currently no active decree!");

		if HRE_ACTIVE_DECREE_TURNS_LEFT > 0 then
			for i = 1, #HRE_DECREES do
				local button_decree = UIComponent(btnHREPolicies_tab_child_uic:Find("button_decree_"..tostring(i)));

				button_decree:SetState("inactive");
			end
		else
			if cm:get_local_faction() == HRE_EMPEROR_KEY then
				for i = 1, #HRE_DECREES do
					local button_decree = UIComponent(btnHREPolicies_tab_child_uic:Find("button_decree_"..tostring(i)));

					if HRE_DECREES[i]["cost"] > HRE_IMPERIAL_AUTHORITY then
						button_decree:SetState("inactive");
					else
						button_decree:SetState("active");
					end
				end
			else
				for i = 1, #HRE_DECREES do
					local button_decree = UIComponent(btnHREPolicies_tab_child_uic:Find("button_decree_"..tostring(i)));

					button_decree:SetState("inactive");
				end
			end
		end
	else
		if HRE_ACTIVE_DECREE_TURNS_LEFT == 1 then
			tx_decrees_uic:SetStateText("'"..Get_Decree_Property(HRE_ACTIVE_DECREE, "name").."' is active for "..tostring(HRE_ACTIVE_DECREE_TURNS_LEFT).." more turn!");
		else
			tx_decrees_uic:SetStateText("'"..Get_Decree_Property(HRE_ACTIVE_DECREE, "name").."' is active for "..tostring(HRE_ACTIVE_DECREE_TURNS_LEFT).." more turns!");	
		end

		for i = 1, #HRE_DECREES do
			local button_decree = UIComponent(btnHREPolicies_tab_child_uic:Find("button_decree_"..tostring(i)));

			button_decree:SetState("inactive");
		end
	end

	Update_Authority_HRE_UI();
end

function Update_Authority_HRE_UI()
	local root = cm:ui_root();
	local panHRE = UIComponent(root:Find("HRE_Panel"));
	local btnHREPolicies = UIComponent(panHRE:Find("hre_policies"));
	local btnHREPolicies_tab_child_uic = UIComponent(btnHREPolicies:Find("tab_child"));
	local tx_authority_uic = UIComponent(btnHREPolicies_tab_child_uic:Find("tx_authority"));

	tx_authority_uic:SetStateText("Imperial Authority: ("..Round_Number_Text(HRE_IMPERIAL_AUTHORITY).." / "..tostring(HRE_IMPERIAL_AUTHORITY_MAX)..")");
end

function Round_Imperial_Authority_HRE_UI()
	local authority = tostring(HRE_IMPERIAL_AUTHORITY);

	for i = 1, string.len(authority) do
		local char = string.sub(authority, i, i);

		if char == "." then
			local tenth = string.sub(authority, i + 1, i + 1);
			local hundredth = string.sub(authority, i + 2, i + 2);
			
			tenth = tonumber(tenth);
			hundredth = tonumber(hundredth);
			
			if hundredth < 5 then
				if tenth ~= 0 then
					tenth = tenth - 1;
					
					if tenth == 0 then
						authority = string.sub(authority, 0, i - 1);
						return authority;
					end
				else
					authority = string.sub(authority, 0, i - 1);
					return authority;
				end
			elseif hundredth >= 5 then
				if tenth ~= 9 then
					tenth = tenth + 1;
				else
					authority = string.sub(authority, 0, i - 1);
					
					local new_num = tonumber(authority) + 1;
					return tostring(new_num);
				end
			else
				authority = string.sub(authority, 0, i - 1);
				return authority;
			end
			
			authority = string.sub(authority, 0, i);
			return authority;
		end
	end

	return authority;
end

function Setup_Faction_Info_HRE_UI(root, faction_name)
	local population = "0";
	local hre_regions = 0;
	local fealty = "";
	local in_hre = " This faction is a member of the Holy Roman Empire!";
	local faction = cm:model():world():faction_by_key(faction_name);
	local panHRE = UIComponent(root:Find("HRE_Panel"));
	local tx_title_uic = UIComponent(panHRE:Find("tx_title"));
	local btnHREInfo = UIComponent(panHRE:Find("hre_info"));
	local btnVote = UIComponent(panHRE:Find("button_vote"));
	local btnBackCandidate = UIComponent(panHRE:Find("button_back_candidate"));
	local parchment_uic = UIComponent(panHRE:Find("parchment"));
	local parchment_uicX, parchment_uicY = parchment_uic:Position();
	local parchment_ui_layer_uic = UIComponent(parchment_uic:Find("Parchment_UI_Layer"));
	local election_ui_layer_uic = UIComponent(parchment_uic:Find("Election_UI_Layer"));
	local faction_context_subpanel_uic = UIComponent(parchment_uic:Find("faction_context_subpanel"));
	local dy_name_uic = UIComponent(faction_context_subpanel_uic:Find("dy_name"));

	btnHREInfo:SimulateClick();

	parchment_ui_layer_uic:DestroyChildren();

	if faction_name == HRE_EMPEROR_KEY then
		in_hre = " This faction is the Emperor!";
	elseif faction_name == HRE_EMPEROR_PRETENDER_KEY then
		in_hre = " This faction is a pretender to the throne!";
	elseif HasValue(HRE_FACTIONS_ELECTORS, faction_name) then
		in_hre = " This faction is a Prince-Elector!";
	elseif not HasValue(HRE_FACTIONS, faction_name) then
		in_hre = " This faction is not in the Holy Roman Empire!";
	end

	tx_title_uic:SetStateText(in_hre);
	dy_name_uic:SetStateText(" "..Get_DFN_Localisation(faction_name));

	--if HasValue(FACTIONS_WITH_IMAGES, faction_name) then
		parchment_ui_layer_uic:CreateComponent(faction_name.."_logo", "UI/new/faction_flags/"..faction_name.."_flag_big");
	--else
		--parchment_ui_layer_uic:CreateComponent(faction_name.."_logo", "UI/new/faction_flags/".."mk_fact_hre_flag_big");
	--end

	local faction_logo_uic = UIComponent(parchment_ui_layer_uic:Find(faction_name.."_logo"));
	faction_logo_uic:SetMoveable(true);
	faction_logo_uic:MoveTo(parchment_uicX + 48, parchment_uicY + 60);
	faction_logo_uic:SetMoveable(false);
	faction_logo_uic:SetInteractive(false);

	if HasValue(HRE_FACTIONS, faction_name) or HRE_EMPEROR_PRETENDER_KEY == faction_name then
		Setup_Elector_Faction_Info_HRE_UI(root, faction_name);

		for i = 0, faction_context_subpanel_uic:ChildCount() - 1 do
			local child = UIComponent(faction_context_subpanel_uic:Find(i));

			if child:Id() ~= "dy_name" and child:Id() ~= "dy_faction_symbol" and child:Id() ~= "tx_hordes_owned" then
				child:SetVisible(true);
			end
		end

		local child_1 = UIComponent(parchment_uic:Find(0));
		local child_2 = UIComponent(parchment_uic:Find(1));
		UIComponent(child_1:Find("hbar")):SetVisible(true);

		if faction_name == HRE_EMPEROR_PRETENDER_KEY or (CURRENT_HRE_REFORM > 0 and HasValue(HRE_FACTIONS_ELECTORS, faction_name) == false) then
			UIComponent(child_2:Find("tx_title")):SetVisible(false);
		else
			UIComponent(child_2:Find("tx_title")):SetVisible(true);
		end

		if HasValue(HRE_FACTIONS_WITH_CANDIDATE_IMAGES, faction_name) then
			parchment_ui_layer_uic:CreateComponent(faction_name.."_candidate", "UI/new/hre_candidates/"..faction_name.."_candidate");
			parchment_ui_layer_uic:CreateComponent(faction_name.."_candidate_name", "UI/campaign ui/city_info_bar_horde");
		else
			parchment_ui_layer_uic:CreateComponent(faction_name.."_candidate", "UI/new/hre_candidates/mk_fact_unknown_candidate");
			parchment_ui_layer_uic:CreateComponent(faction_name.."_candidate_name", "UI/campaign ui/city_info_bar_horde");
		end

		local faction_candidate_uic = UIComponent(parchment_ui_layer_uic:Find(faction_name.."_candidate"));
		local faction_candidate_name_uic = UIComponent(parchment_ui_layer_uic:Find(faction_name.."_candidate_name"));
		local dy_candidate_name = UIComponent(faction_candidate_name_uic:Find("dy_name"));
		local mon_frame = UIComponent(faction_candidate_name_uic:Find("mon_frame"));
		local mon_24 = UIComponent(faction_candidate_name_uic:Find("mon_24"));
		local diplomatic_relations_fill = UIComponent(faction_candidate_name_uic:Find("diplomatic_relations_fill"));

		faction_candidate_uic:SetMoveable(true);
		faction_candidate_uic:MoveTo(parchment_uicX + 286, parchment_uicY + 70);
		faction_candidate_uic:SetMoveable(false);
		faction_candidate_uic:SetInteractive(false);
		faction_candidate_name_uic:SetMoveable(true);
		faction_candidate_name_uic:MoveTo(parchment_uicX + 201, parchment_uicY + 178);
		faction_candidate_name_uic:SetMoveable(false);
		dy_candidate_name:SetStateText(NAMES_TO_LOCALISATION[faction:faction_leader():get_forename()].." ");
		mon_frame:SetVisible(false);
		mon_24:SetVisible(false);
		diplomatic_relations_fill:SetVisible(false);

		local dy_home_region_uic = UIComponent(faction_context_subpanel_uic:Find("dy_home-region"));
		local tx_provinces_owned_uic = UIComponent(faction_context_subpanel_uic:Find("tx_provinces_owned"));
		local dy_provinces_owned_uic = UIComponent(tx_provinces_owned_uic:Find("dy_provinces_owned"));
		local tx_regions_owned_uic = UIComponent(faction_context_subpanel_uic:Find("tx_regions_owned"));
		local dy_regions_owned_uic = UIComponent(tx_regions_owned_uic:Find("dy_regions_owned"));
		local tx_faction_leader_uic = UIComponent(faction_context_subpanel_uic:Find("tx_faction_leader"));
		local dy_faction_leader_uic = UIComponent(tx_faction_leader_uic:Find("dy_faction_leader"));
		local tx_prosperity_uic = UIComponent(faction_context_subpanel_uic:Find("tx_prosperity"));
		local dy_prosperity_uic = UIComponent(tx_prosperity_uic:Find("dy_prosperity"));
		local tx_imperium_uic = UIComponent(faction_context_subpanel_uic:Find("tx_imperium"));
		local dy_imperium_uic = UIComponent(tx_imperium_uic:Find("dy_imperium"));

		dy_home_region_uic:SetStateText(REGIONS_NAMES_LOCALISATION[faction:home_region():name()]);
		dy_provinces_owned_uic:SetStateText(tostring(faction:region_list():num_items()));
		tx_regions_owned_uic:SetStateText("Regions in HRE:");

		for i = 1, #HRE_REGIONS do
			local region = cm:model():world():region_manager():region_by_key(HRE_REGIONS[i]);

			if region:owning_faction():name() == faction_name then
				hre_regions = hre_regions + 1;
			end
		end

		dy_regions_owned_uic:SetStateText(tostring(hre_regions));
		tx_faction_leader_uic:SetStateText("Faction rank:");

		if FACTIONS_DFN_LEVEL[faction_name] == 1 then
			dy_faction_leader_uic:SetStateText("County/Duchy");
		elseif FACTIONS_DFN_LEVEL[faction_name] == 2 then
			dy_faction_leader_uic:SetStateText("Kingdom");
		elseif FACTIONS_DFN_LEVEL[faction_name] >= 3 then
			dy_faction_leader_uic:SetStateText("Empire");
		end

		tx_prosperity_uic:SetStateText("Population:");
		dy_prosperity_uic:SetStateText(tostring(POPULATION_FACTION_TOTAL_POPULATIONS[faction_name]));

		if HasValue(HRE_FACTIONS, faction_name) and faction_name ~= HRE_EMPEROR_KEY then
			tx_imperium_uic:SetStateText("Attitude:");
			dy_imperium_uic:SetStateText(HRE_STATES[HRE_FACTIONS_STATES[faction_name]][1]);
		elseif faction_name == HRE_EMPEROR_KEY then
			tx_imperium_uic:SetStateText("Authority:");
			dy_imperium_uic:SetStateText(Round_Number_Text(HRE_IMPERIAL_AUTHORITY).."/100");
		elseif faction_name == HRE_EMPEROR_PRETENDER_KEY then
			tx_imperium_uic:SetStateText("Authority:");
			dy_imperium_uic:SetStateText("N/A");
		end
	else
		faction_logo_uic:SetState("faded");
		election_ui_layer_uic:SetVisible(false);

		for i = 0, faction_context_subpanel_uic:ChildCount() - 1 do
			local child = UIComponent(faction_context_subpanel_uic:Find(i));

			if child:Id() ~= "dy_name" then
				child:SetVisible(false);
			end
		end

		local child_1 = UIComponent(parchment_uic:Find(0));
		local child_2 = UIComponent(parchment_uic:Find(1));
		local bar_uic = UIComponent(parchment_uic:Find("bar"));

		UIComponent(child_1:Find("hbar")):SetVisible(false);
		UIComponent(child_2:Find("tx_title")):SetVisible(false);
		btnVote:SetVisible(false);
		btnBackCandidate:SetVisible(false);
		bar_uic:SetVisible(false);
	end

	HRE_FACTION_SELECTED = faction_name;
end

function Update_State_HRE_UI(faction_name)
	if faction_name ~= HRE_EMPEROR_PRETENDER_KEY then
		local root = cm:ui_root();
		local panHRE = UIComponent(root:Find("HRE_Panel"));
		local parchment_uic = UIComponent(panHRE:Find("parchment"));
		local faction_context_subpanel_uic = UIComponent(parchment_uic:Find("faction_context_subpanel"));
		local tx_imperium_uic = UIComponent(faction_context_subpanel_uic:Find("tx_imperium"));
		local dy_imperium_uic = UIComponent(tx_imperium_uic:Find("dy_imperium"));

		tx_imperium_uic:SetStateText("Attitude:");
		dy_imperium_uic:SetStateText(HRE_STATES[HRE_FACTIONS_STATES[faction_name]][1]);
		panHRE:SetVisible(true);
	end
end

function Setup_Elector_Faction_Info_HRE_UI(root, info_faction_name)
	local panHRE = UIComponent(root:Find("HRE_Panel"));
	local parchment_uic = UIComponent(panHRE:Find("parchment"));
	local parchment_uicX, parchment_uicY = parchment_uic:Position();
	local faction_context_subpanel_uic = UIComponent(parchment_uic:Find("faction_context_subpanel"));
	local btnVote = UIComponent(panHRE:Find("button_vote"));
	local btnBackCandidate = UIComponent(panHRE:Find("button_back_candidate"));
	local election_ui_layer_uic = UIComponent(parchment_uic:Find("Election_UI_Layer"));
	election_ui_layer_uic:DestroyChildren();

	local faction_name = HRE_FACTIONS_VOTES[info_faction_name];
	local faction = cm:model():world():faction_by_key(faction_name);
	local human_faction_name = cm:get_local_faction();

	if info_faction_name ~= HRE_EMPEROR_PRETENDER_KEY then
		if (CURRENT_HRE_REFORM == 0 or (CURRENT_HRE_REFORM > 0 and HasValue(HRE_FACTIONS_ELECTORS, info_faction_name))) and CURRENT_HRE_REFORM < 8 then
			if HasValue(HRE_FACTIONS_WITH_CANDIDATE_IMAGES, faction_name) then
				election_ui_layer_uic:CreateComponent("candidate", "UI/new/hre_candidates/"..faction_name.."_candidate");
				election_ui_layer_uic:CreateComponent("candidate_name", "UI/campaign ui/city_info_bar_horde");
			else
				election_ui_layer_uic:CreateComponent("candidate", "UI/new/hre_candidates/mk_fact_unknown_candidate");
				election_ui_layer_uic:CreateComponent("candidate_name", "UI/campaign ui/city_info_bar_horde");
			end

			election_ui_layer_uic:CreateComponent(faction_name.."_logo", "UI/new/faction_flags/"..faction_name.."_flag_small");

			local candidate_uic = UIComponent(election_ui_layer_uic:Find("candidate"));
			local candidate_name_uic = UIComponent(election_ui_layer_uic:Find("candidate_name"));
			local dy_candidate_name_uic = UIComponent(candidate_name_uic:Find("dy_name"));
			local candidate_icon_uic = UIComponent(election_ui_layer_uic:Find(faction_name.."_logo"));
			local mon_frame_candidate = UIComponent(candidate_name_uic:Find("mon_frame"));
			local mon_24_candidate = UIComponent(candidate_name_uic:Find("mon_24"));
			local diplomatic_relations_fill_candidate = UIComponent(candidate_name_uic:Find("diplomatic_relations_fill"));
			local tx_hordes_owned_uic = UIComponent(faction_context_subpanel_uic:Find("tx_hordes_owned"));
			local dy_hordes_owned_uic = UIComponent(tx_hordes_owned_uic:Find("dy_hordes_owned"));
			local bar_uic = UIComponent(parchment_uic:Find("bar"));

			candidate_uic:SetMoveable(true);
			candidate_uic:MoveTo(parchment_uicX + 286, parchment_uicY + 435);
			candidate_uic:SetMoveable(false);
			candidate_uic:SetInteractive(false);
			candidate_name_uic:SetMoveable(true);
			candidate_name_uic:MoveTo(parchment_uicX + 201, parchment_uicY + 543);
			candidate_name_uic:SetMoveable(false);
			dy_candidate_name_uic:SetStateText(NAMES_TO_LOCALISATION[faction:faction_leader():get_forename()].." ");
			candidate_icon_uic:SetMoveable(true);
			candidate_icon_uic:MoveTo(parchment_uicX + 291, parchment_uicY + 514);
			candidate_icon_uic:SetMoveable(false);
			mon_frame_candidate:SetVisible(false);
			mon_24_candidate:SetVisible(false);
			diplomatic_relations_fill_candidate:SetVisible(false);

			local num_votes = Calculate_Num_Votes_HRE_Elections(faction_name);

			tx_hordes_owned_uic:SetVisible(true);
			dy_hordes_owned_uic:SetVisible(true);
			tx_hordes_owned_uic:SetStateText("Chosen Candidate:");
			dy_hordes_owned_uic:SetStateText("Votes: "..tostring(num_votes));

			if num_votes > 0 then
				bar_uic:Resize((26 * num_votes) + 4, 24);
				bar_uic:SetVisible(true);
				bar_uic:SetInteractive(false);
			else
				bar_uic:SetVisible(false);
			end

			num_votes = num_votes / 2;

			for k, v in pairs(HRE_FACTIONS_VOTES) do
				if faction_name == v then
					election_ui_layer_uic:CreateComponent(tostring(k).."_logo", "UI/new/faction_flags/"..tostring(k).."_flag_small");
					local current_logo_uic = UIComponent(election_ui_layer_uic:Find(election_ui_layer_uic:ChildCount() - 1));

					current_logo_uic:SetMoveable(true);
					current_logo_uic:MoveTo(parchment_uicX + 302 + (26 * num_votes), parchment_uicY + 600);
					current_logo_uic:SetMoveable(false);
					bar_uic:SetMoveable(true);
					bar_uic:MoveTo(parchment_uicX + 299 + (26 * num_votes), parchment_uicY + 600);
					bar_uic:SetMoveable(false);

					num_votes = num_votes - 1;
				end
			end
		else
			local tx_hordes_owned_uic = UIComponent(faction_context_subpanel_uic:Find("tx_hordes_owned"));
			local dy_hordes_owned_uic = UIComponent(tx_hordes_owned_uic:Find("dy_hordes_owned"));
			local bar_uic = UIComponent(parchment_uic:Find("bar"));

			tx_hordes_owned_uic:SetStateText("");
			dy_hordes_owned_uic:SetStateText("");
			bar_uic:SetVisible(false);
		end
	end

	if CURRENT_HRE_REFORM < 8 then
		if info_faction_name == HRE_EMPEROR_PRETENDER_KEY then
			local tx_hordes_owned_uic = UIComponent(faction_context_subpanel_uic:Find("tx_hordes_owned"));
			local bar_uic = UIComponent(parchment_uic:Find("bar"));

			election_ui_layer_uic:SetVisible(false);
			tx_hordes_owned_uic:SetVisible(false);
			btnVote:SetVisible(true);
			btnVote:SetMoveable(true);
			btnVote:MoveTo(parchment_uicX + 193, parchment_uicY + 644);
			btnVote:SetMoveable(false);
			btnBackCandidate:SetVisible(false);
			bar_uic:SetVisible(false);

			if not HasValue(HRE_FACTIONS, cm:get_local_faction()) then
				btnVote:SetVisible(false);
				return;
			end

			if CURRENT_HRE_REFORM == 0 or (CURRENT_HRE_REFORM > 0 and HasValue(HRE_FACTIONS_ELECTORS, human_faction_name)) then
				if HRE_FACTIONS_VOTES[human_faction_name] == info_faction_name then
					btnVote:SetState("inactive");
				else
					btnVote:SetState("active");
				end
			else
				btnVote:SetVisible(false);
			end
		else
			local tx_hordes_owned_uic = UIComponent(faction_context_subpanel_uic:Find("tx_hordes_owned"));

			election_ui_layer_uic:SetVisible(true);
			tx_hordes_owned_uic:SetVisible(true);

			if not HasValue(HRE_FACTIONS, cm:get_local_faction()) then
				btnBackCandidate:SetVisible(false);
				btnVote:SetVisible(false);
				return;
			end

			if CURRENT_HRE_REFORM == 0 or (CURRENT_HRE_REFORM > 0 and HasValue(HRE_FACTIONS_ELECTORS, human_faction_name)) then
				if human_faction_name == info_faction_name or HRE_FACTIONS_VOTES[faction_name] == info_faction_name then
					btnVote:MoveTo(parchment_uicX + 193, parchment_uicY + 644);
					btnBackCandidate:SetVisible(false);
				elseif HRE_FACTIONS_VOTES[human_faction_name] == HRE_FACTIONS_VOTES[info_faction_name] then
					btnVote:MoveTo(parchment_uicX + 53, parchment_uicY + 644);
					btnBackCandidate:MoveTo(parchment_uicX + 333, parchment_uicY + 644);
					btnBackCandidate:SetVisible(true);
					btnBackCandidate:SetState("inactive");
				else
					btnVote:MoveTo(parchment_uicX + 53, parchment_uicY + 644);
					btnBackCandidate:MoveTo(parchment_uicX + 333, parchment_uicY + 644);
					btnBackCandidate:SetVisible(true);
					btnBackCandidate:SetState("active");
				end

				btnVote:SetVisible(true);

				if HRE_FACTIONS_VOTES[human_faction_name] == info_faction_name then
					btnVote:SetState("inactive");
				else
					btnVote:SetState("active");
				end
			else
				btnBackCandidate:SetVisible(false);
				btnVote:SetVisible(false);
			end
		end
	else
		btnVote:SetVisible(false);
		btnBackCandidate:SetVisible(false);
	end
end
