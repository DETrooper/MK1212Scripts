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

local dev = require("lua_scripts.dev");

function Add_HRE_UI_Listeners()
	if cm:model():world():faction_by_key("mk_fact_hre"):is_human() == true then
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
end

function CreateHREPanel()
	local root = cm:ui_root();

	root:CreateComponent("HRE_Panel", "UI/new/hre_panel");
	local panHRE = UIComponent(root:Find("HRE_Panel"));
	local panHREX, panHREY = panHRE:Position();
	local dy_heading_text_uic = UIComponent(panHRE:Find("dy_heading_text"));
	local btnHREMap = UIComponent(panHRE:Find("hre_map"));
	local btnHREMapX, btnHREMapY = btnHREMap:Position();
	local btnHREMapText = UIComponent(btnHREMap:Find("tx_records"));
	local HREMap_tab_child_uic = UIComponent(btnHREMap:Find("tab_child"));
	local btnPolicies = UIComponent(panHRE:Find("hre_policies"));
	local btnPoliciesText = UIComponent(btnPolicies:Find("tx_stats"));
	local policies_tab_child_uic = UIComponent(btnPolicies:Find("tab_child"));
	local policies_panel_uic = UIComponent(policies_tab_child_uic:Find("stats_panel"));
	local btnFealty = UIComponent(panHRE:Find("hre_upfealty"));
	local btnFealtyX, btnFealtyY = btnFealty:Position();
	local btnFealtyText = UIComponent(btnFealty:Find("string"));
	local btnBackCandidate = UIComponent(panHRE:Find("button_back_candidate"));
	local btnBackCandidateText = UIComponent(btnBackCandidate:Find("string"));
	local btnClose = UIComponent(panHRE:Find("button_close"));
	local btnCloseText = UIComponent(btnClose:Find("string"));

	dy_heading_text_uic:SetStateText("Holy Roman Empire");
	btnHREMapText:SetStateText("View Empire");
	btnPoliciesText:SetStateText("Decrees & Policies");
	btnFealtyText:SetStateText("Secure Fealty");
	btnBackCandidateText:SetStateText("Back Candidate");
	btnCloseText:SetStateText("Close Panel");

	HREMap_tab_child_uic:DestroyChildren();
	policies_panel_uic:DestroyChildren();
	btnClose:SetMoveable(true);
	btnClose:MoveTo(btnFealtyX - 175, btnFealtyY);
	btnClose:SetMoveable(false);

	Create_Image(HREMap_tab_child_uic, "hre_map_img");
	local map_uic = UIComponent(HREMap_tab_child_uic:Find("hre_map_img"));
	map_uic:SetMoveable(true);
	map_uic:MoveTo(btnFealtyX - 717, btnFealtyY - 700);
	map_uic:SetMoveable(false);

	Create_Image(HREMap_tab_child_uic, "hre_panel_hbars");
	local hbars_uic = UIComponent(HREMap_tab_child_uic:Find("hre_panel_hbars"));
	hbars_uic:SetMoveable(true);
	hbars_uic:MoveTo(panHREX, panHREY);
	hbars_uic:SetMoveable(false);

	local garbage = UIComponent(root:Find("garbage"));

	garbage:CreateComponent("HRE_Parchment", "UI/campaign ui/objectives_screen");
	local parchment_uic = UIComponent(garbage:Find("scroll_frame"));
	local parchment_uicX, parchment_uicY = parchment_uic:Position();
	local title_plaque_uic = UIComponent(garbage:Find("title_plaque"));
	local tx_objectives_uic = UIComponent(garbage:Find("tx_objectives"));
	local tx_title_uic = UIComponent(garbage:Find("tx_title"));
	local progress_bar_uic = UIComponent(garbage:Find("progress_bar"));

	parchment_uic:Resize(660, 718);
	HREMap_tab_child_uic:Adopt(parchment_uic:Address());
	HREMap_tab_child_uic:Adopt(title_plaque_uic:Address());
	tx_title_uic:Resize(600, 43);
	parchment_uic:Adopt(tx_title_uic:Address());
	parchment_uic:SetMoveable(true);
	parchment_uic:MoveTo(parchment_uicX + 387, parchment_uicY - 13);
	parchment_uic:SetMoveable(false);
	title_plaque_uic:SetMoveable(true);
	title_plaque_uic:MoveTo(parchment_uicX + 3, parchment_uicY - 18);
	title_plaque_uic:SetMoveable(false);
	tx_title_uic:SetMoveable(true);
	tx_title_uic:MoveTo(parchment_uicX + 414, parchment_uicY + 205);
	tx_title_uic:SetMoveable(false);
	progress_bar_uic:SetVisible(false);
	tx_objectives_uic:SetStateText("Emperor: Otto IV");
	tx_title_uic:SetStateText("This faction is the emperor!");
	garbage:DestroyChildren();

	garbage:CreateComponent("HRE_Titles", "UI/campaign ui/objectives_screen");
	title_plaque_uic = UIComponent(garbage:Find("title_plaque"));
	tx_title_uic = UIComponent(garbage:Find("tx_title"));
	tx_objectives_uic = UIComponent(garbage:Find("tx_objectives"));
	HREMap_tab_child_uic:Adopt(title_plaque_uic:Address());
	progress_bar_uic = UIComponent(garbage:Find("progress_bar"));

	tx_title_uic:Resize(600, 43);
	parchment_uic:Adopt(tx_title_uic:Address());
	title_plaque_uic:SetMoveable(true);
	title_plaque_uic:MoveTo(parchment_uicX - 297, parchment_uicY - 18);
	title_plaque_uic:SetMoveable(false);
	tx_title_uic:SetMoveable(true);
	tx_title_uic:MoveTo(parchment_uicX + 414, parchment_uicY + 370);
	tx_title_uic:SetMoveable(false);
	progress_bar_uic:SetVisible(false);
	tx_objectives_uic:SetStateText("Imperial Territory: (21/23)");
	tx_title_uic:SetStateText("Elections");
	garbage:DestroyChildren();

	parchment_uic:CreateComponent("Parchment_UI_Layer", "UI/campaign ui/script_dummy");
	parchment_uic:CreateComponent("Election_UI_Layer", "UI/campaign ui/script_dummy");

	parchment_uic:Adopt(btnFealty:Address());
	parchment_uic:Adopt(btnBackCandidate:Address());
	btnFealty:SetMoveable(true);
	btnFealty:MoveTo(parchment_uicX + 440, parchment_uicY + 630);
	btnFealty:SetMoveable(false);
	btnBackCandidate:SetMoveable(true);
	btnBackCandidate:MoveTo(parchment_uicX + 720, parchment_uicY + 630);
	btnBackCandidate:SetMoveable(false);
	btnBackCandidate:SetVisible(true);

	Create_Map_Regions_HRE_UI(root);

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
	if context.string == "hre_map" then
		UIComponent(context.component):SetTooltipText("This tab shows a map of the Holy Roman Empire and information on the selected faction.");
	elseif context.string == "hre_policies" then
		UIComponent(context.component):SetTooltipText("This tab, interactable with only by the emperor, contains imperial decrees which can be enacted with varied boons and drawbacks.");
	elseif context.string == "hre_upfealty" then
		UIComponent(context.component):SetTooltipText("Boost the fealty of this faction by placating them with gifts.");
	elseif context.string == "button_back_candidate" then
		UIComponent(context.component):SetTooltipText("Back this faction's candidate for a boost to their fealty!");
	elseif context.string == "dy_imperium" then
		if UIComponent(UIComponent(UIComponent(context.component):Parent()):Parent()):Id() == "faction_context_subpanel" then
			
		end
	elseif string.find(context.string, "_logo") then
		local fealty = "";
		local in_hre = "";

		if string.find(context.string, "mk_fact_") then
			local faction_name = string.gsub(context.string, "_logo", "");

			if HasValue(FACTIONS_HRE, faction_name) and faction_name ~= HRE_EMPEROR_KEY then
				if FACTIONS_HRE_FEALTY[faction_name] < 3 then
					fealty = "\n\nFealty: [[rgba:255:0:0:150]]"..tostring(FACTIONS_HRE_FEALTY[faction_name].."[[/rgba]]/10");
				elseif FACTIONS_HRE_FEALTY[faction_name] >= 3 and FACTIONS_HRE_FEALTY[faction_name] <= 7 then
					fealty = "\n\nFealty: [[rgba:255:255:0:150]]"..tostring(FACTIONS_HRE_FEALTY[faction_name].."[[/rgba]]/10");
				elseif FACTIONS_HRE_FEALTY[faction_name] > 7 then
					fealty = "\n\nFealty: [[rgba:8:201:27:150]]"..tostring(FACTIONS_HRE_FEALTY[faction_name].."[[/rgba]]/10");
				end
			elseif faction_name == HRE_EMPEROR_KEY then
				in_hre = "\n\n[[rgba:255:215:0:150]]This faction is the Emperor![[/rgba]]";
			elseif faction_name == HRE_EMPEROR_PRETENDER_KEY then
				in_hre = "\n\n[[rgba:255:215:0:150]]This faction is a pretender to the throne![[/rgba]]";
			else
				in_hre = "\n\n[[rgba:255:0:0:150]]This faction is not in the Holy Roman Empire![[/rgba]]";
			end

			UIComponent(context.component):SetTooltipText(Get_DFN_Localisation(faction_name)..in_hre..fealty);
		elseif string.find(context.string, "att_reg_") then
			local region_name = string.gsub(context.string, "_logo", "");
			local region = cm:model():world():region_manager():region_by_key(region_name);
			local owning_faction_name = region:owning_faction():name();
			local population = "0";

			if POPULATION_REGIONS_POPULATIONS[region_name] ~= nil then
				population = tostring(Get_Total_Population_Region(region_name));
			end

			if HasValue(FACTIONS_HRE, owning_faction_name) and owning_faction_name ~= HRE_EMPEROR_KEY then
				if FACTIONS_HRE_FEALTY[owning_faction_name] < 3 then
					fealty = "\n\nFealty: [[rgba:255:0:0:150]]"..tostring(FACTIONS_HRE_FEALTY[owning_faction_name].."[[/rgba]]/10");
				elseif FACTIONS_HRE_FEALTY[owning_faction_name] >= 3 and FACTIONS_HRE_FEALTY[owning_faction_name] <= 7 then
					fealty = "\n\nFealty: [[rgba:255:255:0:150]]"..tostring(FACTIONS_HRE_FEALTY[owning_faction_name].."[[/rgba]]/10");
				elseif FACTIONS_HRE_FEALTY[owning_faction_name] > 7 then
					fealty = "\n\nFealty: [[rgba:8:201:27:150]]"..tostring(FACTIONS_HRE_FEALTY[owning_faction_name].."[[/rgba]]/10");
				end
			elseif owning_faction_name == HRE_EMPEROR_KEY then
				in_hre = "\n\n[[rgba:255:215:0:150]]This faction is the Emperor![[/rgba]]";
			elseif owning_faction_name == HRE_EMPEROR_PRETENDER_KEY then
				in_hre = "\n\n[[rgba:255:215:0:150]]This faction is a pretender to the throne![[/rgba]]";
			else
				in_hre = "\n\n[[rgba:255:0:0:150]]This faction is not in the Holy Roman Empire![[/rgba]]";
			end

			UIComponent(context.component):SetTooltipText("Region: "..REGIONS_NAMES_LOCALISATION[region_name].."\nPopulation: "..population.."\nOwner: "..Get_DFN_Localisation(owning_faction_name)..in_hre..fealty);
		end
	end
end

function OnComponentLClickUp_HRE_UI(context)
	if context.string == "button_hre" then
		if HRE_PANEL_OPEN == false then
			OpenHREPanel();
			HRE_PANEL_OPEN = true;
		else
			CloseHREPanel();
		end
	elseif context.string == "root" and HRE_PANEL_OPEN == true then
		CloseHREPanel();
	elseif context.string == "button_close" then
		if UIComponent(UIComponent(UIComponent(context.component):Parent()):Parent()):Id() == "HRE_Panel" then
			CloseHREPanel();
		end
	elseif context.string == "hre_map" then
		UIComponent(context.component):SetTooltipText("This tab shows a map of the Holy Roman Empire and information on the selected faction.");
	elseif context.string == "hre_policies" then
		UIComponent(context.component):SetTooltipText("This tab, interactable with only by the emperor, contains imperial decrees which can be enacted with varied boons and drawbacks.");
	elseif context.string == "hre_upfealty" then
		UIComponent(context.component):SetState("inactive");

		HRE_Increase_Fealty(HRE_FACTION_SELECTED, 1, "boosted");
		Update_Fealty_HRE_UI(HRE_FACTION_SELECTED);
	elseif context.string == "button_back_candidate" then
		local root = cm:ui_root();

		UIComponent(context.component):SetState("inactive");

		if FACTIONS_HRE_VOTES[cm:get_local_faction()] ~= cm:get_local_faction() then
			HRE_Decrease_Fealty(FACTIONS_HRE_VOTES[HRE_FACTION_SELECTED], 3, "withdrew_support");
		end

		Cast_Vote_For_Factions_Candidate_HRE(cm:get_local_faction(), HRE_FACTION_SELECTED);
		HRE_Increase_Fealty(HRE_FACTION_SELECTED, 3, "supported_candidate");
		Update_Fealty_HRE_UI(HRE_FACTION_SELECTED);
		Setup_Elector_Faction_Info_HRE_UI(root, HRE_FACTION_SELECTED);
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
		CloseHREPanel();
	end
end

function OnPanelOpenedCampaign_HRE_UI(context)
	CloseHREPanel();
end

function TimeTrigger_HRE_UI(context)
	if context.string == "HRE_Text_Setup" then
		local root = cm:ui_root();
		local garbage = UIComponent(root:Find("garbage"));
		local panHRE = UIComponent(root:Find("HRE_Panel"));
		local parchment_uic = UIComponent(panHRE:Find("scroll_frame"));
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

		Setup_Faction_Info_HRE_UI(root, cm:get_local_faction());
	end
end

function OpenHREPanel()
	local root = cm:ui_root();
	local panHRE = UIComponent(root:Find("HRE_Panel"));
	local btnHREMap = UIComponent(panHRE:Find("hre_map"));
	local HREMap_tab_child_uic = UIComponent(btnHREMap:Find("tab_child"));
	local tx_objectives_uic1 = UIComponent(UIComponent(HREMap_tab_child_uic:Find(3)):Find("tx_objectives"));
	local tx_objectives_uic2 = UIComponent(UIComponent(HREMap_tab_child_uic:Find(4)):Find("tx_objectives"));
	local btnPolicies = UIComponent(panHRE:Find("hre_policies"));
	local hre_emperor_faction = cm:model():world():faction_by_key(HRE_EMPEROR_KEY);
	local number = "I";
	local hre_regions_owned = 0;

	if cm:get_local_faction() ~= HRE_EMPEROR_KEY then
		btnPolicies:SetState("inactive");
	else
		btnPolicies:SetState("active");
	end

	if HRE_EMPERORS_NAMES_NUMBERS[hre_emperor_faction:faction_leader():get_forename()] ~= nil then
		number = HRE_EMPERORS_ROMAN_NUMERALS[HRE_EMPERORS_NAMES_NUMBERS[hre_emperor_faction:faction_leader():get_forename()]];
	end

	tx_objectives_uic1:SetStateText("Emperor: "..NAMES_TO_LOCALISATION[hre_emperor_faction:faction_leader():get_forename()].." "..number);

	for i = 1, #HRE_REGIONS do
		local region_name = HRE_REGIONS[i];
		local region = cm:model():world():region_manager():region_by_key(region_name);
		local owning_faction_name = region:owning_faction():name();

		if HasValue(FACTIONS_HRE, owning_faction_name) then
			hre_regions_owned = hre_regions_owned + 1;
		end
	end

	tx_objectives_uic2:SetStateText("Imperial Territory: ("..tostring(hre_regions_owned).."/"..tostring(#HRE_REGIONS)..")");

	Setup_Faction_Info_HRE_UI(root, HRE_EMPEROR_KEY);
	panHRE:SetVisible(true);
end

function CloseHREPanel()
	local root = cm:ui_root();
	local panHRE = UIComponent(root:Find("HRE_Panel"));
	local btnHRE = UIComponent(root:Find("button_hre"));
	panHRE:SetVisible(false);
	btnHRE:SetState("active");
	HRE_PANEL_OPEN = false;
end

function Create_Map_Regions_HRE_UI(root)
	local panHRE = UIComponent(root:Find("HRE_Panel"));
	local map_uic = UIComponent(panHRE:Find("hre_map_img"));
	local map_uicX, map_uicY = map_uic:Position();

	for i = 1, #HRE_REGIONS do
		local region_name = HRE_REGIONS[i];
		local region = cm:model():world():region_manager():region_by_key(region_name);
		local owning_faction_name = region:owning_faction():name();
		local image_name = HRE_REGIONS_TO_IMAGES[region_name];

		Create_Image(map_uic, image_name);
		local image_uic = UIComponent(map_uic:Find(image_name));
		image_uic:SetMoveable(true);
		image_uic:MoveTo(map_uicX, map_uicY);
		image_uic:SetMoveable(false);

		if owning_faction_name == HRE_EMPEROR_KEY then
			image_uic:PropagateImageColour(255, 215, 0, 150);
		elseif HasValue(FACTIONS_HRE, owning_faction_name) then
			image_uic:PropagateImageColour(0, 204, 0, 150);
		else
			image_uic:PropagateImageColour(204, 0, 0, 150);
		end

		-- Temporary if statement until all faction logo UI files are made.
		if HasValue(FACTIONS_WITH_IMAGES, owning_faction_name) then
			map_uic:CreateComponent(region_name.."_logo", "UI/new/faction_flags/"..owning_faction_name.."_flag_small");
		else
			map_uic:CreateComponent(region_name.."_logo", "UI/campaign ui/faction_flag_small");
		end

		local faction_logo_uic = UIComponent(map_uic:Find(region_name.."_logo"));
		faction_logo_uic:SetMoveable(true);
		faction_logo_uic:MoveTo(map_uicX + HRE_REGION_FACTION_PIPS_LOCATIONS[region_name][1], map_uicY + HRE_REGION_FACTION_PIPS_LOCATIONS[region_name][2]);
		faction_logo_uic:SetMoveable(false);
	end
end

function Setup_Faction_Info_HRE_UI(root, faction_name)
	local population = "0";
	local hre_regions = 0;
	local fealty = "";
	local in_hre = " This faction is a member of the Holy Roman Empire!";
	local faction = cm:model():world():faction_by_key(faction_name);
	local panHRE = UIComponent(root:Find("HRE_Panel"));
	local tx_title_uic = UIComponent(panHRE:Find("tx_title"));
	local btnHREMap = UIComponent(panHRE:Find("hre_map"));
	local btnFealty = UIComponent(panHRE:Find("hre_upfealty"));
	local btnBackCandidate = UIComponent(panHRE:Find("button_back_candidate"));
	local HREMap_tab_child_uic = UIComponent(btnHREMap:Find("tab_child"));
	local parchment_uic = UIComponent(panHRE:Find("scroll_frame"));
	local parchment_uicX, parchment_uicY = parchment_uic:Position();
	local parchment_ui_layer_uic = UIComponent(parchment_uic:Find("Parchment_UI_Layer"));
	local election_ui_layer_uic = UIComponent(parchment_uic:Find("Election_UI_Layer"));
	local faction_context_subpanel_uic = UIComponent(parchment_uic:Find("faction_context_subpanel"));
	local dy_name_uic = UIComponent(faction_context_subpanel_uic:Find("dy_name"));

	parchment_ui_layer_uic:DestroyChildren();

	if faction_name == HRE_EMPEROR_KEY then
		in_hre = " This faction is the Emperor!";
	elseif faction_name == HRE_EMPEROR_PRETENDER_KEY then
		in_hre = " This faction is a pretender to the throne!";
	elseif not HasValue(FACTIONS_HRE, faction_name) then
		in_hre = " This faction is not in the Holy Roman Empire!";
	end

	tx_title_uic:SetStateText(in_hre);
	dy_name_uic:SetStateText(" "..Get_DFN_Localisation(faction_name));

	if HasValue(FACTIONS_WITH_IMAGES, faction_name) then
		parchment_ui_layer_uic:CreateComponent(faction_name.."_logo", "UI/new/faction_flags/"..faction_name.."_flag_big");
	else
		parchment_ui_layer_uic:CreateComponent(faction_name.."_logo", "UI/new/faction_flags/".."mk_fact_hre_flag_big");
	end

	local faction_logo_uic = UIComponent(parchment_ui_layer_uic:Find(faction_name.."_logo"));
	faction_logo_uic:SetMoveable(true);
	faction_logo_uic:MoveTo(parchment_uicX + 48, parchment_uicY + 60);
	faction_logo_uic:SetMoveable(false);
	faction_logo_uic:SetInteractive(false);

	if HasValue(FACTIONS_HRE, faction_name) or HRE_EMPEROR_PRETENDER_KEY == faction_name then
		if faction_name == HRE_EMPEROR_PRETENDER_KEY then
			local tx_hordes_owned_uic = UIComponent(faction_context_subpanel_uic:Find("tx_hordes_owned"));
			local bar_uic = UIComponent(parchment_uic:Find("bar"));

			election_ui_layer_uic:SetVisible(false);
			tx_hordes_owned_uic:SetVisible(false);
			btnFealty:SetVisible(false);
			btnBackCandidate:SetVisible(false);
			bar_uic:SetVisible(false);
		elseif faction_name == HRE_EMPEROR_KEY then
			local tx_hordes_owned_uic = UIComponent(faction_context_subpanel_uic:Find("tx_hordes_owned"));

			Setup_Elector_Faction_Info_HRE_UI(root, faction_name);
			election_ui_layer_uic:SetVisible(true);
			tx_hordes_owned_uic:SetVisible(true);
			btnFealty:SetVisible(true);
			btnBackCandidate:SetVisible(true);
			btnFealty:SetState("inactive");
			btnBackCandidate:SetState("inactive");
		else
			local tx_hordes_owned_uic = UIComponent(faction_context_subpanel_uic:Find("tx_hordes_owned"));

			Setup_Elector_Faction_Info_HRE_UI(root, faction_name);
			election_ui_layer_uic:SetVisible(true);
			tx_hordes_owned_uic:SetVisible(true);
			btnFealty:SetVisible(true);
			btnBackCandidate:SetVisible(true);

			btnFealty:SetState("active");

			if FACTIONS_HRE_VOTES[cm:get_local_faction()] ~= FACTIONS_HRE_VOTES[faction_name] then
				btnBackCandidate:SetState("active");
			else
				btnBackCandidate:SetState("inactive");
			end
		end

		for i = 0, faction_context_subpanel_uic:ChildCount() - 1 do
			local child = UIComponent(faction_context_subpanel_uic:Find(i));

			if child:Id() ~= "dy_name" and child:Id() ~= "dy_faction_symbol" and child:Id() ~= "tx_hordes_owned" then
				child:SetVisible(true);
			end
		end

		local child_1 = UIComponent(parchment_uic:Find(0));
		local child_2 = UIComponent(parchment_uic:Find(1));
		UIComponent(child_1:Find("hbar")):SetVisible(true);

		if faction_name == HRE_EMPEROR_PRETENDER_KEY then
			UIComponent(child_2:Find("tx_title")):SetVisible(false);
		else
			UIComponent(child_2:Find("tx_title")):SetVisible(true);
		end

		if HasValue(FACTIONS_WITH_IMAGES, faction_name) then
			parchment_ui_layer_uic:CreateComponent(faction_name.."_candidate", "UI/new/hre_candidates/"..faction_name.."_candidate");
			parchment_ui_layer_uic:CreateComponent(faction_name.."_candidate_name", "UI/campaign ui/city_info_bar_horde");
		else
			parchment_ui_layer_uic:CreateComponent(faction_name.."_candidate", "UI/new/hre_candidates/".."mk_fact_hre_candidate");
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

		if HasValue(FACTIONS_HRE, faction_name) and faction_name ~= HRE_EMPEROR_KEY then
			tx_imperium_uic:SetStateText("Fealty:");
			dy_imperium_uic:SetStateText(tostring(FACTIONS_HRE_FEALTY[faction_name]).."/10");
		elseif faction_name == HRE_EMPEROR_KEY then
			tx_imperium_uic:SetStateText("Authority:");
			dy_imperium_uic:SetStateText(tostring(HRE_IMPERIAL_AUTHORITY).."/100");
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
		btnFealty:SetVisible(false);
		btnBackCandidate:SetVisible(false);
		bar_uic:SetVisible(false);
	end

	HRE_FACTION_SELECTED = faction_name;
end

function Update_Fealty_HRE_UI(faction_name)
	local root = cm:ui_root();
	local panHRE = UIComponent(root:Find("HRE_Panel"));
	local parchment_uic = UIComponent(panHRE:Find("scroll_frame"));
	local faction_context_subpanel_uic = UIComponent(parchment_uic:Find("faction_context_subpanel"));
	local tx_imperium_uic = UIComponent(faction_context_subpanel_uic:Find("tx_imperium"));
	local dy_imperium_uic = UIComponent(tx_imperium_uic:Find("dy_imperium"));

	tx_imperium_uic:SetStateText("Fealty:");
	dy_imperium_uic:SetStateText(tostring(FACTIONS_HRE_FEALTY[faction_name]).."/10");
	panHRE:SetVisible(true);
end

function Setup_Elector_Faction_Info_HRE_UI(root, info_faction_name)
	local panHRE = UIComponent(root:Find("HRE_Panel"));
	local parchment_uic = UIComponent(panHRE:Find("scroll_frame"));
	local parchment_uicX, parchment_uicY = parchment_uic:Position();
	local faction_context_subpanel_uic = UIComponent(parchment_uic:Find("faction_context_subpanel"));
	local election_ui_layer_uic = UIComponent(parchment_uic:Find("Election_UI_Layer"));
	election_ui_layer_uic:DestroyChildren();

	local faction_name = FACTIONS_HRE_VOTES[info_faction_name];
	local faction = cm:model():world():faction_by_key(faction_name);

	election_ui_layer_uic:CreateComponent("candidate", "UI/new/hre_candidates/"..faction_name.."_candidate");
	election_ui_layer_uic:CreateComponent("candidate_name", "UI/campaign ui/city_info_bar_horde");
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

	for k, v in pairs(FACTIONS_HRE_VOTES) do
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
end