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
CRUSADER_RECRUITMENT_PANEL_CREATED = false;
CRUSADER_RECRUITMENT_PANEL_OPEN = false;

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

	CreateCrusaderRecruitmentPanel();

	if CRUSADE_ACTIVE == true then
		PopulateCrusaderRecruitmentPanel();
	end
end

function CreateCrusaderRecruitmentPanel()
	local root = cm:ui_root();
	local garbage = UIComponent(root:Find("garbage"));
	garbage:CreateComponent("crusader_units_panel", "ui/new/units_panel_crusades");

	local crusader_units_panel_uic = UIComponent(garbage:Find("crusader_units_panel"));
	local crusader_recruitment_docker_uic = UIComponent(crusader_units_panel_uic:Find("recruitment_docker_crusaders"));

	root:Adopt(crusader_recruitment_docker_uic:Address());
	--garbage:DestroyChildren();

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

function CharacterSelected_Pope_UI(context)
	local root = cm:ui_root();
	local button_crusaders_uic = UIComponent(root:Find("button_crusaders"));
	local button_join_crusade_uic = UIComponent(root:Find("button_join_crusade"));

	button_crusaders_uic:SetVisible(false); -- Default to not visible.
	button_join_crusade_uic:SetState("inactive"); -- Default to inactive.
	button_join_crusade_uic:SetVisible(false); -- Default to not visible.

	if CRUSADER_RECRUITMENT_PANEL_OPEN == true then
		CloseCrusaderRecruitmentPanel(false);
	end

	if CRUSADE_ACTIVE == true then
		local faction_name = cm:get_local_faction();
		
		if context:character():faction():name() == faction_name then
			if HasValue(FACTION_EXCOMMUNICATED, faction_name) ~= true and context:character():faction():state_religion() == "att_rel_chr_catholic" then
				if context:character():military_force():unit_list():num_items() > 1 then
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

function OnComponentMouseOn_Pope_UI(context)
	if context.string == "button_join_crusade" then
		local button_join_crusade_uic = UIComponent(context.component);
		local faction_name = cm:get_local_faction();
		local faction =  cm:model():world():faction_by_key(faction_name);

		if faction:at_war_with(cm:model():world():faction_by_key(CURRENT_CRUSADE_TARGET_OWNER)) == false then
			button_join_crusade_uic:SetTooltipText("Send this army on Crusade!\n\n[[rgba:200:10:10:150]]Note that clicking this button will declare war![[/rgba:200:10:10:150]]");
		else
			button_join_crusade_uic:SetTooltipText("Send this army on Crusade!");
		end
	elseif CRUSADER_RECRUITMENT_PANEL_OPEN == true then
		if string.find(context.string, "_crusader") then
			local unit_card_uic = UIComponent(context.component);

			if unit_card_uic:CurrentState() == "active" then
				local unit_name = string.gsub(context.string, "_crusader", "");

				if UNIT_NAMES_LOCALISATION[unit_name] ~= nil then
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
	if context.string == "button_join_crusade" then
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

					-- Refresh the units panel so the recruited units show.
					local root = cm:ui_root();
					local layout_uic = UIComponent(root:Find("layout"));
					local bar_small_top_uic = UIComponent(layout_uic:Find("bar_small_top"));
					local tab_units_uic = UIComponent(bar_small_top_uic:Find("tab_units"));
					local units_dropdown_uic = UIComponent(root:Find("units_dropdown"));

					if tab_units_uic:CurrentState() == "selected" then
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
						tab_units_uic:SimulateClick();
						cm:add_time_trigger("Hide_Units_Dropdown", 0.0);
					end
				end
			end
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

	CloseCrusaderRecruitmentPanel(false);
end

function OnPanelClosedCampaign_Pope_UI(context)
	if context.string == "units_panel" then
		CloseCrusaderRecruitmentPanel(false);
		SetUnitInformationPanelVisible(false, false);
	end
end

function UnitDisbanded_Pope_UI(context)
	if CRUSADER_RECRUITMENT_PANEL_OPEN == true then
		if LAST_CHARACTER_SELECTED ~= nil then
			RefreshCrusaderRecruitmentPanel(false);
		end
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

	RefreshCrusaderRecruitmentPanel(true);

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

function RefreshCrusaderRecruitmentPanel(check_units)
	local root = cm:ui_root();
	local button_crusaders_uic = UIComponent(root:Find("button_crusaders"));
	local crusader_recruitment_docker_uic = UIComponent(root:Find("recruitment_docker_crusaders"));
	local crusader_recruitment_clip_uic = UIComponent(crusader_recruitment_docker_uic:Find("recruitment_clip"));
	local crusader_recruitment_options_uic = UIComponent(crusader_recruitment_clip_uic:Find("recruitment_options"));
	local crusader_listview_uic = UIComponent(crusader_recruitment_options_uic:Find("listview"));
	local crusader_list_clip_uic = UIComponent(crusader_listview_uic:Find("list_clip"));
	local crusader_list_box_uic = UIComponent(crusader_list_clip_uic:Find("list_box"));

	-- Sometimes the crusader recruitment button is set to active, like when disbanding a unit.
	if button_crusaders_uic:CurrentState() == "active" then
		cm:add_time_trigger("Reselect_Crusader_Recruitment_Button", 0.0);
	end

	if check_units == true then
		local units_panel_uic = UIComponent(root:Find("units_panel"));
		local main_units_panel_uic = UIComponent(units_panel_uic:Find("main_units_panel"));
		local units_uic = UIComponent(main_units_panel_uic:Find("units"));

		if units_uic:ChildCount() >= 21 then
			for i = 0, crusader_list_box_uic:ChildCount() - 1 do
				local unit_card_uic = UIComponent(crusader_list_box_uic:Find(i));
				local unit_icon_uic = UIComponent(unit_card_uic:Find("unit_icon"));

				unit_card_uic:SetDisabled(true);
				unit_icon_uic:SetState("inactive");
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

function TimeTrigger_Pope_UI(context)
	if context.string == "Check_Army_Size" then
		RefreshCrusaderRecruitmentPanel(true);
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

------------------------------------------------
---------------- Saving/Loading ----------------
------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		SaveTable(context, CHARACTERS_ON_CRUSADE, "CHARACTERS_ON_CRUSADE");
	end
);

cm:register_loading_game_callback(
	function(context)
		CHARACTERS_ON_CRUSADE = LoadTableNumbers(context, "CHARACTERS_ON_CRUSADE");
	end
);
