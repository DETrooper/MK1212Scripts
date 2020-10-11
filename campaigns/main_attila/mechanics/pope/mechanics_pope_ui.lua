--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: POPE UI
-- 	By: DETrooper
--
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------

--local dev = require("lua_scripts.dev");

CHARACTERS_ON_CRUSADE = {};
COLLEGE_OF_CARDINALS_PANEL_OPEN = false;
CRUSADER_RECRUITMENT_PANEL_CREATED = false;
CRUSADER_RECRUITMENT_PANEL_OPEN = false;
POPE_ELECTION_PANEL_OPEN = false;

function Add_Pope_UI_Listeners()
	cm:add_listener(
		"CharacterSelected_Pope_UI",
		"CharacterSelected",
		true,
		function(context) CharacterSelected_Pope_UI(context) end,
		true
	);
	cm:add_listener(
		"OnComponentMouseOn_Pope_UI",
		"ComponentMouseOn",
		true,
		function(context) OnComponentMouseOn_Pope_UI(context) end,
		true
	);
	cm:add_listener(
		"OnComponentLClickUp_Pope_UI",
		"ComponentLClickUp",
		true,
		function(context) OnComponentLClickUp_Pope_UI(context) end,
		true
	);
	cm:add_listener(
		"OnPanelOpenedCampaign_Pope_UI",
		"PanelOpenedCampaign",
		true,
		function(context) OnPanelOpenedCampaign_Pope_UI(context) end,
		true
	);
	cm:add_listener(
		"OnPanelClosedCampaign_Pope_UI",
		"PanelClosedCampaign",
		true,
		function(context) OnPanelClosedCampaign_Pope_UI(context) end,
		true
	);
	cm:add_listener(
		"TimeTrigger_Pope_UI",
		"TimeTrigger",
		true,
		function(context) TimeTrigger_Pope_UI(context) end,
		true
	);
	cm:add_listener(
		"UnitDisbanded_Pope_UI",
		"UnitDisbanded",
		true,
		function(context) UnitDisbanded_Pope_UI(context) end,
		true
	);

	CreateCollegeOfCardinalsPanel();
	CreateCrusaderRecruitmentPanel();

	if POPE_ELECTION_PANEL_OPEN == true then
		CreatePopeElectionPanel();
	end

	if CRUSADE_ACTIVE == true then
		PopulateCrusaderRecruitmentPanel();
	end
end

function CreateCollegeOfCardinalsPanel()
	local root = cm:ui_root();
	root:CreateComponent("college_of_cardinals_panel", "ui/new/college_of_cardinals_panel");

	PopulateCollegeOfCardinalsPanel();

	local crusader_units_panel_uic = UIComponent(root:Find("college_of_cardinals_panel"));

	crusader_units_panel_uic:SetVisible(false);
end

function CreateCrusaderRecruitmentPanel()
	local root = cm:ui_root();
	local garbage = UIComponent(root:Find("garbage"));
	garbage:CreateComponent("crusader_units_panel", "ui/new/units_panel_crusades");

	local crusader_units_panel_uic = UIComponent(garbage:Find("crusader_units_panel"));
	local crusader_recruitment_docker_uic = UIComponent(crusader_units_panel_uic:Find("recruitment_docker_crusaders"));

	root:Adopt(crusader_recruitment_docker_uic:Address());
	garbage:DestroyChildren();

	local crusader_recruitment_clip_uic = UIComponent(crusader_recruitment_docker_uic:Find("recruitment_clip"));
	local crusader_recruitment_options_uic = UIComponent(crusader_recruitment_clip_uic:Find("recruitment_options"));
	local crusader_list_box_uic = UIComponent(crusader_recruitment_options_uic:Find("list_box"));
	local button_confirm_uic = UIComponent(crusader_recruitment_options_uic:Find("button_confirm"));
	local tx_recruitment_options_uic = UIComponent(crusader_recruitment_options_uic:Find("tx_recruitment_options"));
	local tx_mercenariers_cost_uic = UIComponent(crusader_recruitment_options_uic:Find("tx_mercenariers_cost"));
	local layout_uic = UIComponent(root:Find("layout"));
	local hud_center_docker_uic = UIComponent(layout_uic:Find("hud_center_docker"));
	local posX, posY = hud_center_docker_uic:Position();

	crusader_recruitment_docker_uic:SetMoveable(true);
	crusader_recruitment_docker_uic:MoveTo(posX, posY - 253);
	crusader_recruitment_docker_uic:SetMoveable(false);
	crusader_recruitment_docker_uic:SetVisible(false);
	crusader_recruitment_clip_uic:SetVisible(true);
	crusader_recruitment_options_uic:SetVisible(true);
	button_confirm_uic:SetVisible(false);
	tx_recruitment_options_uic:SetStateText("Crusader Recruitment");
	tx_mercenariers_cost_uic:SetVisible(false);

	CRUSADER_RECRUITMENT_PANEL_CREATED = true;
end

function CreatePopeElectionPanel()
	local root = cm:ui_root();
	local garbage = UIComponent(root:Find("garbage"));
	local pope_election_panel_uic = UIComponent(garbage:CreateComponent("pope_election_panel", "ui/new/pope_election_panel"));
	local preferati_list_uic = UIComponent(pope_election_panel_uic:Find("preferati_list"));
	local listview_uic = UIComponent(preferati_list_uic:Find("listview"));
	local list_clip_uic = UIComponent(listview_uic:Find("list_clip"));
	local list_box_uic = UIComponent(list_clip_uic:Find("list_box"));

	for i = 1, 3 do
		local cardinal_template_uic = UIComponent(list_box_uic:CreateComponent("cardinal_template_"..tostring(i), "UI/new/cardinal_template"));
		local cardinal_template_uicX, cardinal_template_uicY = cardinal_template_uic:Position();
		local dy_cardinal_age_uic = UIComponent(cardinal_template_uic:Find("dy_cardinal_age"));
		local dy_cardinal_faction_uic = UIComponent(cardinal_template_uic:Find("dy_cardinal_faction"));
		local dy_cardinal_level_uic = UIComponent(cardinal_template_uic:Find("dy_cardinal_level"));
		local dy_cardinal_name_uic = UIComponent(cardinal_template_uic:Find("dy_cardinal_name"));
		local dy_cardinal_rank_uic = UIComponent(cardinal_template_uic:Find("dy_cardinal_rank"));
		local faction_logo_uic = UIComponent(cardinal_template_uic:CreateComponent("faction_logo", "UI/new/faction_flags/mk_fact_unknown_flag_big"));
		local tx_votes_uic = UIComponent(list_box_uic:CreateComponent("tx_votes_"..tostring(i), "UI/new/tx_votes"));
	
		faction_logo_uic:Resize(64, 64);
		faction_logo_uic:SetMoveable(true);
		faction_logo_uic:MoveTo(cardinal_template_uicX, cardinal_template_uicY + 22);
		faction_logo_uic:SetMoveable(false);
		faction_logo_uic:SetInteractive(false);
	end

	list_box_uic:Layout();

	for i = 1, 3 do
		local cardinal_template_uic = UIComponent(list_box_uic:Find("cardinal_template_"..tostring(i)));
		local cardinal_template_uicX, cardinal_template_uicY = cardinal_template_uic:Position();
		local button_vote_uic = UIComponent(list_box_uic:CreateComponent("button_vote_"..tostring(i), "UI/new/basic_toggle_accept"));

		button_vote_uic:SetMoveable(true);
		button_vote_uic:MoveTo(cardinal_template_uicX + 448, cardinal_template_uicY + 30);
		button_vote_uic:SetMoveable(false);
	end

	pope_election_panel_uic:LockPriority(60);
end

function RemovePopeElectionPanel()
	local root = cm:ui_root();
	local garbage = UIComponent(root:Find("garbage"));
	local pope_election_panel_uic = UIComponent(garbage:Find("pope_election_panel"));

	if pope_election_panel_uic then
		garbage:DestroyChildren();
	end
end

function CharacterSelected_Pope_UI(context)
	local character = context:character();
	local root = cm:ui_root();
	local button_college_of_cardinals_uic = UIComponent(root:Find("button_college_of_cardinals"));
	local button_crusaders_uic = UIComponent(root:Find("button_crusaders"));
	local button_join_crusade_uic = UIComponent(root:Find("button_join_crusade"));

	button_college_of_cardinals_uic:SetVisible(false); -- Default to not visible.
	button_crusaders_uic:SetVisible(false); -- Default to not visible.
	button_join_crusade_uic:SetState("inactive"); -- Default to inactive.
	button_join_crusade_uic:SetVisible(false); -- Default to not visible.

	if character:character_type("dignitary") and character:faction():state_religion() == "att_rel_chr_catholic" then
		button_college_of_cardinals_uic:SetVisible(true);
	else
		if CRUSADER_RECRUITMENT_PANEL_OPEN == true then
			CloseCrusaderRecruitmentPanel(false);
		end

		if CRUSADE_ACTIVE == true then
			local faction_name = cm:get_local_faction();
			
			if character:faction():name() == faction_name then
				if HasValue(FACTION_EXCOMMUNICATED, faction_name) ~= true and character:faction():state_religion() == "att_rel_chr_catholic" then
					if character:military_force():unit_list():num_items() > 1 then
						-- Not an agent or lone general.
						button_join_crusade_uic:SetVisible(true);

						if not HasValue(CHARACTERS_ON_CRUSADE, LAST_CHARACTER_SELECTED:cqi()) then
							button_join_crusade_uic:SetState("active");
						elseif LAST_CHARACTER_SELECTED:region():majority_religion() == "att_rel_chr_catholic" then
							button_crusaders_uic:SetVisible(true);
						end
					end
				end
			end
		end
	end
end

function OnComponentMouseOn_Pope_UI(context)
	if context.string == "button_join_crusade" then
		local button_join_crusade_uic = UIComponent(context.component);
		local faction_name = cm:get_local_faction();
		local faction = cm:model():world():faction_by_key(faction_name);

		if faction:at_war_with(cm:model():world():faction_by_key(CURRENT_CRUSADE_TARGET_OWNER)) == false then
			button_join_crusade_uic:SetTooltipText("Send this army on Crusade!\n\n[[rgba:230:0:0:150]]Note that clicking this button will declare war![[/rgba]]");
		else
			button_join_crusade_uic:SetTooltipText("Send this army on Crusade!");
		end
	elseif POSTBATTLE_DECISION_ENEMY_CATHOLIC == true then
		if context.string == "button_kill" then
			local root = cm:ui_root();
			local tooltip_captive_options_uic = UIComponent(root:Find("tooltip_captive_options"));
			local txt_description_uic = UIComponent(tooltip_captive_options_uic:Find("txt_description"));
			local txt_description_text = txt_description_uic:GetStateText();
			local faction_name = cm:get_local_faction();

			if FACTION_POPE_FAVOUR[faction_name] > 1 then
				txt_description_uic:SetStateText(txt_description_text.."\n\n[[rgba:230:0:0:150]]Executing the captives of a fellow Catholic faction will result in the loss of Papal Favour![[/rgba]]");
				tooltip_captive_options_uic:Resize(278, 270);
			elseif FACTION_EXCOMMUNICATED[faction_name] ~= true then
				txt_description_uic:SetStateText(txt_description_text.."\n\n[[rgba:230:0:0:150]]With your Papal Favour already so low, executing the captives of a fellow Catholic faction will result in your excommunication![[/rgba]]");
				tooltip_captive_options_uic:Resize(278, 290);
			end
		elseif context.string == "option_button" then
			local option_button_uic = UIComponent(context.component);
			local option_button_parent_id = UIComponent(option_button_uic:Parent()):Id();
			local faction_name = cm:get_local_faction();

			if option_button_parent_id == "occupation_decision_loot" or option_button_parent_id == "occupation_decision_sack" then
				local tooltip_text = "";

				if option_button_parent_id == "occupation_decision_loot" then
					tooltip_text = subLootOccupy;
				else
					tooltip_text = subSack;
				end

				if FACTION_POPE_FAVOUR[faction_name] > 1 then
					option_button_uic:SetTooltipText(tooltip_text.."\n\n[[rgba:230:0:0:150]]Sacking the settlement of a fellow Catholic faction will result in the loss of Papal Favour![[/rgba]]");
				elseif FACTION_EXCOMMUNICATED[faction_name] == false then
					option_button_uic:SetTooltipText(tooltip_text.."\n\n[[rgba:230:0:0:150]]With your Papal Favour already so low, sacking the settlement of a fellow Catholic faction will result in your excommunication![[/rgba]]");
				end
			end
		end
	elseif CRUSADER_RECRUITMENT_PANEL_OPEN == true then
		if string.find(context.string, "_crusader") then
			local unit_card_uic = UIComponent(context.component);

			if unit_card_uic:CurrentState() == "active" then
				local unit_name = string.gsub(context.string, "_crusader", "");

				if UNIT_NAMES_LOCALISATION[unit_name]  then
					unit_card_uic:SetTooltipText(UNIT_NAMES_LOCALISATION[unit_name].."\n\nLeft-click to recruit this Crusader unit.");
				else
					unit_card_uic:SetTooltipText("Unknown Unit\n\nLeft-click to recruit this Crusader unit.");
				end

				UpdateUnitInformationPanel(unit_name);
				SetUnitInformationPanelVisible(true, false);
			end
		end
	end
end

function OnComponentLClickUp_Pope_UI(context)
	if context.string == "button_college_of_cardinals" then
		if COLLEGE_OF_CARDINALS_PANEL_OPEN == false then
			OpenCollegeOfCardinalsPanel();
		else
			CloseCollegeOfCardinalsPanel(true);
		end
	elseif context.string == "button_join_crusade" then
		local faction_name = LAST_CHARACTER_SELECTED:faction():name();
		local faction = LAST_CHARACTER_SELECTED:faction();
		local force = LAST_CHARACTER_SELECTED:cqi();

		cm:apply_effect_bundle_to_characters_force("mk_bundle_army_crusade", force, 0, true);

		if not HasValue(CURRENT_CRUSADE_FACTIONS_JOINED, faction_name) then
			table.insert(CURRENT_CRUSADE_FACTIONS_JOINED, faction_name);

			if faction:at_war_with(cm:model():world():faction_by_key(CURRENT_CRUSADE_TARGET_OWNER)) == false then
				cm:force_declare_war(faction_name, CURRENT_CRUSADE_TARGET_OWNER);
			end

			cm:force_diplomacy(faction_name, CURRENT_CRUSADE_TARGET_OWNER, "peace", false, false);
			cm:force_diplomacy(CURRENT_CRUSADE_TARGET_OWNER, faction_name, "peace", false, false);
			cm:trigger_mission(faction_name, CURRENT_CRUSADE_MISSION_KEY);

			cm:show_message_event(
				faction_name, 
				"message_event_text_text_mk_event_crusade_"..tostring(CURRENT_CRUSADE).."_title", 
				"message_event_text_text_mk_event_crusade_joined_primary", 
				"message_event_text_text_mk_event_crusade_joined_secondary", 
				true,
				706
			);

			if FACTION_EXCOMMUNICATED[faction_name] == true then
				Remove_Excommunication_Manual(faction_name);
			end

			Add_Pope_Favour(faction_name, 2, "joined_crusade");
			Update_Pope_Favour(faction);
		end

		if LAST_CHARACTER_SELECTED:region():majority_religion() == "att_rel_chr_catholic" then
			local root = cm:ui_root();
			local button_crusaders_uic = UIComponent(root:Find("button_crusaders"));

			button_crusaders_uic:SetVisible(true);
		end

		UIComponent(context.component):SetState("inactive");
		table.insert(CHARACTERS_ON_CRUSADE, LAST_CHARACTER_SELECTED:cqi());
	elseif context.string == "button_crusaders" then
		if CRUSADER_RECRUITMENT_PANEL_OPEN == false then
			OpenCrusaderRecruitmentPanel();
		else
			CloseCrusaderRecruitmentPanel(true);
		end
	elseif COLLEGE_OF_CARDINALS_PANEL_OPEN == true then
		if context.string == "button_ok" or context.string == "root" then
			CloseCollegeOfCardinalsPanel(false);
		end
	elseif CRUSADER_RECRUITMENT_PANEL_OPEN == true then
	 	if context.string == "button_minimise" or context.string == "button_recruitment" or context.string == "button_mercenaries" or context.string == "root" then
			CloseCrusaderRecruitmentPanel(false);
		elseif string.find(context.string, "_crusader") then
			if LAST_CHARACTER_SELECTED:military_force():unit_list():num_items() < 20 then
				local unit_card_uic = UIComponent(context.component);
				local unit_card_max_units_uic = UIComponent(unit_card_uic:Find("max_units"));
				local unit_icon_uic = UIComponent(unit_card_uic:Find("unit_icon"));

				if unit_card_uic:CurrentState() == "active" then
					local unit_name = string.gsub(context.string, "_crusader", "");
					local unit_num_left = CURRENT_CRUSADE_RECRUITABLE_UNITS_CAPS[unit_name];

					cm:add_unit_to_force(unit_name, LAST_CHARACTER_SELECTED:military_force():command_queue_index());
					unit_card_max_units_uic:SetStateText(tostring(unit_num_left - 1));

					if unit_num_left - 1 == 0 then
						unit_card_uic:SetDisabled(true);
						unit_icon_uic:SetState("inactive");
					end

					CURRENT_CRUSADE_RECRUITABLE_UNITS_CAPS[unit_name] = unit_num_left - 1;

					-- Refresh the units panel so the recruited crusader units show. The army unit list UI does not update on its own.
					-- This is about to get really janky :(

					-- First we want to try the auto-merge shortcut as that refreshes the unit list, but if any units are damaged we can't do that.
					local root = cm:ui_root();
					local army_full_strength = true;
					local unit_list = LAST_CHARACTER_SELECTED:military_force():unit_list();

					for i = 0, unit_list:num_items() - 1 do
						local unit = unit_list:item_at(i);

						if unit:percentage_proportion_of_full_strength() ~= 100 then
							army_full_strength = false;
							break;
						end
					end

					if army_full_strength == true then
						-- Army has no units that can be merged, so it's safe to use auto_merge_units.
						local units_panel_uic = UIComponent(root:Find("units_panel"));
						local main_units_panel_uic = UIComponent(units_panel_uic:Find("main_units_panel"));
						local button_group_unit_uic = UIComponent(main_units_panel_uic:Find("button_group_unit"));
						local button_merge_uic = UIComponent(button_group_unit_uic:Find("button_merge"));

						button_merge_uic:TriggerShortcut("auto_merge_units");
						RefreshCrusaderRecruitmentPanel(true, true);
						cm:add_time_trigger("Reselect_Crusader_Recruitment_Button", 0.2);
					else
						-- Can't use auto_merge_units or else units will be inadvertently merged.
						-- Instead we'll have to click on the army again to refresh its unit list.
						-- This is done using the army dropdown panel in the top right, which has the unfortunate side effect of appearing for a split second and making noise. Oh well.
						local layout_uic = UIComponent(root:Find("layout"));
						local bar_small_top_uic = UIComponent(layout_uic:Find("bar_small_top"));
						local tab_units_uic = UIComponent(bar_small_top_uic:Find("tab_units"));
						local units_dropdown_uic = UIComponent(root:Find("units_dropdown"));

						if tab_units_uic:CurrentState() == "selected" then
							-- Good news, the unit dropdown panel is already open!
							local character_cqi_str = tostring(LAST_CHARACTER_SELECTED:cqi());
							local sortable_list_units_uic = UIComponent(units_dropdown_uic:Find("sortable_list_units"));
							local list_box_uic = UIComponent(sortable_list_units_uic:Find("list_box"));

							for i = 0, list_box_uic:ChildCount() - 1 do
								local child = UIComponent(list_box_uic:Find(i));

								if child:Id() == "character_row_"..character_cqi_str then
									child:SimulateClick();
								end
							end

							cm:add_time_trigger("Check_Army_Size", 0.0);
						else
							-- We'll need to open the unit dropdown panel and there's a delay from it opening and being able to click on the army button.
							tab_units_uic:SimulateClick();
							cm:add_time_trigger("Hide_Units_Dropdown", 0.0);
						end
					end
				end
			end
		end
	elseif POPE_ELECTION_PANEL_OPEN == true then
		if context.string == "button_accept" then
			RemovePopeElectionPanel();
		elseif string.find(context.string, "button_vote_") then
			RefreshPopeElectionPanel();
		end
	end
end

function OnPanelOpenedCampaign_Pope_UI(context)
	if context.string == "events" then
		if CRUSADE_END_EVENT_OPEN == true then
			local num_owned_regions = 0;
			local root = cm:ui_root();
			local option3_button = find_uicomponent_by_table(root, {"panel_manager", "events", "event_dilemma", "dilemma3_window", "dilemma3_template", "choice_button"});
			local option4_button = find_uicomponent_by_table(root, {"panel_manager", "events", "event_dilemma", "dilemma4_window", "dilemma4_template", "choice_button"});

			option4_button:SetState("inactive"); -- Default to inactive in case player owns only the crusade target.

			if cm:model():world():region_manager():region_by_key(JERUSALEM_REGION_KEY):owning_faction():state_religion() == "att_rel_chr_catholic" or HasValue(CURRENT_CRUSADE_TARGET_OWNED_REGIONS, JERUSALEM_REGION_KEY) ~= true then
				option3_button:SetState("inactive");
			end

			for i = 1, #CURRENT_CRUSADE_TARGET_OWNED_REGIONS do
				if cm:model():world():region_manager():region_by_key(CURRENT_CRUSADE_TARGET_OWNED_REGIONS[i]):owning_faction():name() == cm:get_local_faction() then
					num_owned_regions = num_owned_regions + 1;

					if num_owned_regions > 1 then
						-- Player owns more than just the crusade target so enable the option to only give away the crusade target and keep the other conquered land.
						option4_button:SetState("active");
						break;
					end
				end
			end

			CRUSADE_END_EVENT_OPEN = false;
		end
	end

	CloseCollegeOfCardinalsPanel(false);
	CloseCrusaderRecruitmentPanel(false);
end

function OnPanelClosedCampaign_Pope_UI(context)
	if context.string == "units_panel" then
		CloseCrusaderRecruitmentPanel(false);
		SetUnitInformationPanelVisible(false, false);
	end
end

function TimeTrigger_Pope_UI(context)
	if context.string == "Check_Army_Size" then
		RefreshCrusaderRecruitmentPanel(true, false);
	elseif context.string == "Reactivate_Crusader_Recruitment_Button" then
		local root = cm:ui_root();
		local crusader_recruitment_docker_uic = UIComponent(root:Find(6));
		local button_crusaders_uic = UIComponent(root:Find("button_crusaders"));

		button_crusaders_uic:SetState("hover");
		button_crusaders_uic:SetInteractive(true);
	elseif context.string == "Reselect_Crusader_Recruitment_Button" then
		local root = cm:ui_root();
		local crusader_recruitment_docker_uic = UIComponent(root:Find(6));
		local button_crusaders_uic = UIComponent(root:Find("button_crusaders"));

		button_crusaders_uic:SetState("selected");
		button_crusaders_uic:SetInteractive(true);
	elseif context.string == "Hide_Units_Dropdown" then
		local root = cm:ui_root();
		local layout_uic = UIComponent(root:Find("layout"));
		local bar_small_top_uic = UIComponent(layout_uic:Find("bar_small_top"));
		local tab_units_uic = UIComponent(bar_small_top_uic:Find("tab_units"));
		local units_dropdown_uic = UIComponent(root:Find("units_dropdown"));
		local sortable_list_units_uic = UIComponent(units_dropdown_uic:Find("sortable_list_units"));
		local list_box_uic = UIComponent(sortable_list_units_uic:Find("list_box"));
		local character_cqi_str = tostring(LAST_CHARACTER_SELECTED:cqi());

		for i = 0, list_box_uic:ChildCount() - 1 do
			local child = UIComponent(list_box_uic:Find(i));

			if child:Id() == "character_row_"..character_cqi_str then
				child:SimulateClick();
			end
		end

		tab_units_uic:SimulateClick();

		cm:add_time_trigger("Check_Army_Size", 0.0);
		cm:add_time_trigger("Reselect_Crusader_Recruitment_Button", 0.0);
	end
end

function UnitDisbanded_Pope_UI(context)
	if CRUSADER_RECRUITMENT_PANEL_OPEN == true then
		if LAST_CHARACTER_SELECTED  then
			RefreshCrusaderRecruitmentPanel(false, false);
			cm:add_time_trigger("Reselect_Crusader_Recruitment_Button", 0.1);
		end
	end
end

function OpenCollegeOfCardinalsPanel()
	local root = cm:ui_root();
	local college_of_cardinals_panel_uic = UIComponent(root:Find("college_of_cardinals_panel"));

	college_of_cardinals_panel_uic:SetVisible(true);

	COLLEGE_OF_CARDINALS_PANEL_OPEN = true;
end

function CloseCollegeOfCardinalsPanel(hover)
	local root = cm:ui_root();
	local college_of_cardinals_panel_uic = UIComponent(root:Find("college_of_cardinals_panel"));
	local button_college_of_cardinals_uic = UIComponent(root:Find("button_college_of_cardinals"));

	college_of_cardinals_panel_uic:SetVisible(false);

	if hover == true then
		button_college_of_cardinals_uic:SetState("hover");
	else
		button_college_of_cardinals_uic:SetState("active");
	end

	COLLEGE_OF_CARDINALS_PANEL_OPEN = false;
end

function PopulateCollegeOfCardinalsPanel()
	local root = cm:ui_root();
	local college_of_cardinals_panel_uic = UIComponent(root:Find("college_of_cardinals_panel"));
	local listview_uic = UIComponent(college_of_cardinals_panel_uic:Find("listview"));
	local list_clip_uic = UIComponent(listview_uic:Find("list_clip"));
	local list_box_uic = UIComponent(list_clip_uic:Find("list_box"));
	local title_plaque_pope_uic = UIComponent(college_of_cardinals_panel_uic:Find("title_plaque_pope"));
	local tx_pope_uic = UIComponent(title_plaque_pope_uic:Find("tx_pope"));
	local papacy = cm:model():world():faction_by_key(PAPAL_STATES_KEY);
	local current_pope = papacy:faction_leader();

	list_box_uic:DestroyChildren();

	if current_pope then
		tx_pope_uic:SetStateText("Pope "..NAMES_TO_LOCALISATION[current_pope:get_forename()] or "Name Not Found");
	end

	local preferati = {};
	local cardinals = {};

	for k, v in pairs(COLLEGE_OF_CARDINALS_CHARACTERS) do
		if v == "preferati" then
			table.insert(preferati, k);
		else
			table.insert(cardinals, k);
		end
	end

	for i = 1, #preferati do
		if i == 1 then
			list_box_uic:CreateComponent("dy_preferati", "ui/new/preferati_hbar");
		end

		SetupCardinalTemplate(preferati[i], list_box_uic);
	end

	for i = 1, #cardinals do
		if i == 1 then
			list_box_uic:CreateComponent("dy_cardinals", "ui/new/cardinals_hbar");
		end

		SetupCardinalTemplate(cardinals[i], list_box_uic);
	end

	list_box_uic:Layout();
end

function SetupCardinalTemplate(character_cqi, list_box_uic)
	local character = cm:model():character_for_command_queue_index(tonumber(character_cqi));

	if character then
		local character_faction = character:faction();
		local character_faction_name = character_faction:name();
		local character_rank = COLLEGE_OF_CARDINALS_CHARACTERS[character_cqi];
		local character_rank_string = "Cardinal";

		if character_rank == "preferati" then
			character_rank_string = "Preferati";
		end

		list_box_uic:CreateComponent("cardinal_template_"..character_cqi, "UI/new/cardinal_template");

		local cardinal_template_uic = UIComponent(list_box_uic:Find("cardinal_template_"..character_cqi));
		local cardinal_template_uicX, cardinal_template_uicY = cardinal_template_uic:Position();
		local dy_cardinal_age_uic = UIComponent(cardinal_template_uic:Find("dy_cardinal_age"));
		--local dy_cardinal_date_joined_uic = UIComponent(cardinal_template_uic:Find("dy_cardinal_date_joined"));
		local dy_cardinal_faction_uic = UIComponent(cardinal_template_uic:Find("dy_cardinal_faction"));
		local dy_cardinal_level_uic = UIComponent(cardinal_template_uic:Find("dy_cardinal_level"));
		local dy_cardinal_name_uic = UIComponent(cardinal_template_uic:Find("dy_cardinal_name"));
		local dy_cardinal_rank_uic = UIComponent(cardinal_template_uic:Find("dy_cardinal_rank"));

		dy_cardinal_age_uic:SetStateText(tostring(character:age()));
		--dy_cardinal_date_joined_uic:SetStateText("1212");
		dy_cardinal_faction_uic:SetStateText(Get_DFN_Localisation(character_faction_name));
		dy_cardinal_level_uic:SetStateText(tostring(character:rank()));
		dy_cardinal_name_uic:SetStateText(NAMES_TO_LOCALISATION[character:get_forename()] or "Name Not Found");
		dy_cardinal_rank_uic:SetStateText(character_rank_string);

		if HasValue(FACTIONS_WITH_IMAGES, character_faction_name) then
			cardinal_template_uic:CreateComponent("faction_logo", "UI/new/faction_flags/"..character_faction_name.."_flag_big");
		else
			cardinal_template_uic:CreateComponent("faction_logo", "UI/new/faction_flags/mk_fact_unknown_flag_big");
		end

		local faction_logo_uic = UIComponent(cardinal_template_uic:Find("faction_logo"));

		faction_logo_uic:Resize(64, 64);
		faction_logo_uic:SetMoveable(true);
		faction_logo_uic:MoveTo(cardinal_template_uicX, cardinal_template_uicY + 22);
		faction_logo_uic:SetMoveable(false);
		faction_logo_uic:SetInteractive(false);
	end
end

function OpenCrusaderRecruitmentPanel()
	local root = cm:ui_root();
	local crusader_recruitment_docker_uic = UIComponent(root:Find("recruitment_docker_crusaders"));
	local crusader_recruitment_clip_uic = UIComponent(crusader_recruitment_docker_uic:Find("recruitment_clip"));
	local crusader_recruitment_options_uic = UIComponent(crusader_recruitment_clip_uic:Find("recruitment_options"));
	local real_recruitment_docker_uic = UIComponent(root:Find("recuitment_docker"));
	local real_recruitment_options_uic = UIComponent(real_recruitment_docker_uic:Find("recruitment_options"));

	crusader_recruitment_docker_uic:SetVisible(true);
	--crusader_recruitment_options_uic:TriggerAnimation("SlideIn");

	if real_recruitment_options_uic:Visible() then
		real_recruitment_options_uic:SetVisible(false);
	end

	RefreshCrusaderRecruitmentPanel(true, false);

	CRUSADER_RECRUITMENT_PANEL_OPEN = true;
end

function CloseCrusaderRecruitmentPanel(hover)
	local root = cm:ui_root();
	local crusader_recruitment_docker_uic = UIComponent(root:Find("recruitment_docker_crusaders"));
	local crusader_recruitment_clip_uic = UIComponent(crusader_recruitment_docker_uic:Find("recruitment_clip"));
	local crusader_recruitment_options_uic = UIComponent(crusader_recruitment_clip_uic:Find("recruitment_options"));
	local button_crusaders_uic = UIComponent(root:Find("button_crusaders"));

	--crusader_recruitment_options_uic:TriggerAnimation("SlideOut");
	crusader_recruitment_docker_uic:SetVisible(false);

	if hover == true then
		button_crusaders_uic:SetInteractive(false);
		cm:add_time_trigger("Reactivate_Crusader_Recruitment_Button", 0.0);
	else
		button_crusaders_uic:SetState("active");
	end

	CRUSADER_RECRUITMENT_PANEL_OPEN = false;
end

function PopulateCrusaderRecruitmentPanel()
	local root = cm:ui_root();
	local crusader_recruitment_docker_uic = UIComponent(root:Find("recruitment_docker_crusaders"));
	local crusader_recruitment_clip_uic = UIComponent(crusader_recruitment_docker_uic:Find("recruitment_clip"));
	local crusader_recruitment_options_uic = UIComponent(crusader_recruitment_clip_uic:Find("recruitment_options"));
	local crusader_listview_uic = UIComponent(crusader_recruitment_options_uic:Find("listview"));
	local crusader_list_clip_uic = UIComponent(crusader_listview_uic:Find("list_clip"));
	local crusader_list_box_uic = UIComponent(crusader_list_clip_uic:Find("list_box"));
	local crusader_list_box_uicX, crusader_list_box_uicY = crusader_list_box_uic:Position();
	local crusader_hslider_uic = UIComponent(crusader_listview_uic:Find("hslider"));

	crusader_list_box_uic:DestroyChildren();

	for i = 1, #CURRENT_CRUSADE_RECRUITABLE_UNITS do
		local unit_name = CURRENT_CRUSADE_RECRUITABLE_UNITS[i];

		crusader_list_box_uic:CreateComponent(unit_name.."_crusader", "ui/new/unit_cards/"..unit_name);

		local unit_card_uic = UIComponent(crusader_list_box_uic:Find(i - 1));
		local unit_card_recruitment_cost_uic = UIComponent(unit_card_uic:Find("RecruitmentCost"));
		local unit_card_max_units_uic = UIComponent(unit_card_uic:Find("max_units"));
		local unit_card_merch_type_uic = UIComponent(unit_card_uic:Find("merch_type"));

		unit_card_uic:SetMoveable(true);
		unit_card_uic:MoveTo(crusader_list_box_uicX + (64 * (i - 1)), crusader_list_box_uicY);
		unit_card_uic:SetMoveable(false);
		unit_card_recruitment_cost_uic:SetVisible(false);
		unit_card_max_units_uic:SetVisible(true);
		unit_card_max_units_uic:SetStateText(tostring(CURRENT_CRUSADE_RECRUITABLE_UNITS_CAPS[unit_name]));
		unit_card_merch_type_uic:SetVisible(true);
		unit_card_merch_type_uic:SetState("crusader");
	end

	--crusader_hslider_uic:SetProperty("maxValue", "215");
	--dev.log(crusader_hslider_uic:GetProperty("maxValue"));
end

function RefreshCrusaderRecruitmentPanel(check_units, minus_one)
	local root = cm:ui_root();
	local button_crusaders_uic = UIComponent(root:Find("button_crusaders"));
	local crusader_recruitment_docker_uic = UIComponent(root:Find("recruitment_docker_crusaders"));
	local crusader_recruitment_clip_uic = UIComponent(crusader_recruitment_docker_uic:Find("recruitment_clip"));
	local crusader_recruitment_options_uic = UIComponent(crusader_recruitment_clip_uic:Find("recruitment_options"));
	local crusader_listview_uic = UIComponent(crusader_recruitment_options_uic:Find("listview"));
	local crusader_list_clip_uic = UIComponent(crusader_listview_uic:Find("list_clip"));
	local crusader_list_box_uic = UIComponent(crusader_list_clip_uic:Find("list_box"));

	if check_units == true then
		local units_panel_uic = UIComponent(root:Find("units_panel"));
		local main_units_panel_uic = UIComponent(units_panel_uic:Find("main_units_panel"));
		local units_uic = UIComponent(main_units_panel_uic:Find("units"));
		local target_number = 21; -- 20 unit cards + the frame UIC.

		if minus_one == true then
			-- Sometimes I can't expect the unit list to have been updated in time, such as when auto_merge_units is fired.
			target_number = 20;
		end

		if units_uic:ChildCount() >= target_number then
			for i = 0, crusader_list_box_uic:ChildCount() - 1 do
				local unit_card_uic = UIComponent(crusader_list_box_uic:Find(i));
				local unit_icon_uic = UIComponent(unit_card_uic:Find("unit_icon"));

				unit_card_uic:SetDisabled(true);
				unit_icon_uic:SetState("inactive");
			end
		else
			for i = 0, crusader_list_box_uic:ChildCount() - 1 do
				local unit_card_uic = UIComponent(crusader_list_box_uic:Find(i));
				local unit_icon_uic = UIComponent(unit_card_uic:Find("unit_icon"));
				local unit_name = string.gsub(unit_card_uic:Id(), "_crusader", "");
				local unit_num_left = CURRENT_CRUSADE_RECRUITABLE_UNITS_CAPS[unit_name];
	
				if unit_num_left == 0 then
					unit_card_uic:SetDisabled(true);
					unit_icon_uic:SetState("inactive");
				else
					unit_card_uic:SetDisabled(false);
					unit_icon_uic:SetState("active");
				end
			end
		end
	else
		for i = 0, crusader_list_box_uic:ChildCount() - 1 do
			local unit_card_uic = UIComponent(crusader_list_box_uic:Find(i));
			local unit_icon_uic = UIComponent(unit_card_uic:Find("unit_icon"));
			local unit_name = string.gsub(unit_card_uic:Id(), "_crusader", "");
			local unit_num_left = CURRENT_CRUSADE_RECRUITABLE_UNITS_CAPS[unit_name];

			if unit_num_left == 0 then
				unit_card_uic:SetDisabled(true);
				unit_icon_uic:SetState("inactive");
			else
				unit_card_uic:SetDisabled(false);
				unit_icon_uic:SetState("active");
			end
		end
	end
end

function RefreshPopeElectionPanel()
	local root = cm:ui_root();
	local garbage = UIComponent(root:Find("garbage"));
	local pope_election_panel_uic = UIComponent(garbage:Find("pope_election_panel"));
	local button_set_uic = UIComponent(pope_election_panel_uic:Find("button_set"));
	local accept_uic = UIComponent(button_set_uic:Find("accept"));
	local button_accept_uic = UIComponent(accept_uic:Find("button_accept"));
	local preferati_list_uic = UIComponent(pope_election_panel_uic:Find("preferati_list"));
	local list_box_uic = UIComponent(preferati_list_uic:Find("list_box"));

	for i = 1, 3 do
		local cardinal_template_uic = UIComponent(list_box_uic:Find("cardinal_template_"..tostring(i)));
		local button_vote_uic = UIComponent(list_box_uic:Find("button_vote_"..tostring(i)));
		local tx_votes_uic = UIComponent(list_box_uic:Find("tx_votes_"..tostring(i)));
		local tx_votes_uicX, tx_votes_uicY = tx_votes_uic:Position();

		button_vote_uic:SetState("inactive");

		for j = 1, math.random(8) do
			local faction_logo_uic = UIComponent(list_box_uic:CreateComponent("faction_logo_"..tostring(i).."_"..tostring(j), "UI/new/faction_flags/mk_fact_unknown_flag_small"));

			faction_logo_uic:SetMoveable(true);
			faction_logo_uic:MoveTo(tx_votes_uicX + 48 + (25 * (j - 1)), tx_votes_uicY);
			faction_logo_uic:SetMoveable(false);
		end
	end

	button_set_uic:SetVisible(true);
	accept_uic:SetVisible(true);
	button_accept_uic:SetVisible(true);
end

------------------------------------------------
---------------- Saving/Loading ----------------
------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		cm:save_value("POPE_ELECTION_PANEL_OPEN", POPE_ELECTION_PANEL_OPEN, context);
		SaveTable(context, CHARACTERS_ON_CRUSADE, "CHARACTERS_ON_CRUSADE");
	end
);

cm:register_loading_game_callback(
	function(context)
		POPE_ELECTION_PANEL_OPEN = cm:load_value("POPE_ELECTION_PANEL_OPEN", false, context);
		CHARACTERS_ON_CRUSADE = LoadTableNumbers(context, "CHARACTERS_ON_CRUSADE");
	end
);
