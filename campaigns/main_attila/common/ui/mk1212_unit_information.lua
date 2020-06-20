----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - COMMON UI: UNIT INFORMATION PANEL
-- 	By: DETrooper
--
----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------

--local dev = require("lua_scripts.dev");

require("common/ui/mk1212_unit_information_lists");

function Add_MK1212_Unit_Information_Listeners()
	cm:add_listener(
		"OnComponentMouseOn_Unit_Information_UI",
		"ComponentMouseOn",
		true,
		function(context) OnComponentMouseOn_Unit_Information_UI(context) end,
		true
	);

	CreateUnitInformationPanel()
end

function CreateUnitInformationPanel()
	local root = cm:ui_root();

	root:CreateComponent("custom_info_panel_holder", "ui/new/info_panel_holder");

	local info_panel_holder_uic = UIComponent(root:Find("custom_info_panel_holder"));
	local info_panel_background_uic = UIComponent(info_panel_holder_uic:Find("info_panel_background"));
	
	info_panel_background_uic:Resize(260, 620);
	info_panel_background_uic:CreateComponent("unit_information", "ui/new/unit_information_new");

	local unit_information_uic = UIComponent(info_panel_background_uic:Find("unit_information"));
	local top_section_uic = UIComponent(unit_information_uic:Find("top_section"));
	local tx_unit_type_uic = UIComponent(top_section_uic:Find("tx_unit-type"));
	local bullet_point_parent_uic = UIComponent(top_section_uic:Find("bullet_point_parent"));
	local details_uic = UIComponent(unit_information_uic:Find("details"));
	local dynamic_stats_uic = UIComponent(details_uic:Find("dynamic_stats"));
	local details_top_bar_uic = UIComponent(details_uic:Find("top_bar"));
	local xp_progress_backfill_uic = UIComponent(details_top_bar_uic:Find("XP_progress_backfill"));
	local button_expand_uic = UIComponent(unit_information_uic:Find("button_expand"));

	for i = 0, dynamic_stats_uic:ChildCount() - 1 do
		UIComponent(UIComponent(dynamic_stats_uic:Find(i)):Find("icon_compare")):SetVisible(false);
	end

	bullet_point_parent_uic:SetVisible(true);
	xp_progress_backfill_uic:SetVisible(false);
	info_panel_holder_uic:SetVisible(false);

	-- For some people the unit info panel will start minimized, so here's a ghetto solution.
	if button_expand_uic:CurrentState() == "active" then
		button_expand_uic:SetState("selected");
		dynamic_stats_uic:SetVisible(true);

		for i = 0, unit_information_uic:ChildCount() - 1 do
			local child_uic = UIComponent(unit_information_uic:Find(i));
			local child_uic_id = child_uic:Id();

			if child_uic_id ~= "button_expand" and child_uic_id ~= "ability_list" and child_uic_id ~= "hbar" then
				local child_pos_x, child_pos_y = child_uic:Position();

				child_uic:SetMoveable(true);
				child_uic:MoveTo(child_pos_x, child_pos_y - 240);
				child_uic:SetMoveable(false);
			end
		end
	end
end

function OnComponentMouseOn_Unit_Information_UI(context)
	if UIComponent(UIComponent(context.component):Parent()):Id() ~= "list_box" then
		SetUnitInformationPanelVisible(false, true);
	end
end

function UpdateUnitInformationPanel(unit_name)
	local root = cm:ui_root();
	local info_panel_holder_uic = UIComponent(root:Find("custom_info_panel_holder"));
	local info_panel_background_uic = UIComponent(info_panel_holder_uic:Find("info_panel_background"));
	local unit_information_uic = UIComponent(info_panel_background_uic:Find("unit_information"));
	local top_section_uic = UIComponent(unit_information_uic:Find("top_section"));
	local bullet_point_parent_uic = UIComponent(top_section_uic:Find("bullet_point_parent"));
	local tx_unit_type_uic = UIComponent(top_section_uic:Find("tx_unit-type"));
	local dy_troop_type_uic = UIComponent(top_section_uic:Find("custom_name_display"));
	local unit_tier_uic = UIComponent(top_section_uic:Find("unit_tier"));
	local unit_category_icon_uic = UIComponent(top_section_uic:Find("unit_category_icon"));
	local details_uic = UIComponent(unit_information_uic:Find("details"));
	local dynamic_stats_uic = UIComponent(details_uic:Find("dynamic_stats"));
	local details_top_bar_uic = UIComponent(details_uic:Find("top_bar"));
	local dy_men_uic = UIComponent(details_top_bar_uic:Find("dy_men"));
	local upkeep_cost_uic = UIComponent(details_top_bar_uic:Find("upkeep_cost"));
	local upkeep_cost_dy_value_uic = UIComponent(upkeep_cost_uic:Find("dy_value"));
	local ability_list_uic = UIComponent(unit_information_uic:Find("ability_list"));
	local ability_list_uicX, ability_list_uicY = ability_list_uic:Position();

	if UNIT_NAMES_LOCALISATION[unit_name] ~= nil then
		tx_unit_type_uic:SetStateText(UNIT_NAMES_LOCALISATION[unit_name]);
	else
		tx_unit_type_uic:SetStateText("Unknown Unit");
	end

	for i = 0, bullet_point_parent_uic:ChildCount() - 1 do
		local bullet_point_uic = UIComponent(bullet_point_parent_uic:Find(i));

		bullet_point_uic:SetVisible(false);
	end

	if unit_bullet_points[unit_name] ~= nil then
		for i = 1, #unit_bullet_points[unit_name] do
			local bullet_point = SplitString(unit_bullet_points[unit_name][i], "|");
			local bullet_point_uic = UIComponent(bullet_point_parent_uic:Find(i - 1));

			bullet_point_uic:SetState(bullet_point[1]);
			bullet_point_uic:SetStateText(bullet_point[2]);
			bullet_point_uic:SetVisible(true);
		end
	end

	if unit_info[unit_name] ~= nil then
		local num_men = tostring(unit_info[unit_name]["num_men"]);
		local upkeep_cost = tostring(unit_info[unit_name]["upkeep"]);
		local unit_weight = unit_info[unit_name]["unit_weight"];
		local unit_type = unit_info[unit_name]["unit_type"];
		local unit_tier = tostring(unit_info[unit_name]["tier"]);

		dy_men_uic:SetStateText(num_men.." ("..num_men..")");
		upkeep_cost_dy_value_uic:SetStateText(upkeep_cost);
		dy_troop_type_uic:SetStateText(unit_weights_texts[unit_weight].." "..ui_unit_groupings[unit_type][1]);
		unit_tier_uic:SetState(unit_tier);
		unit_category_icon_uic:SetState(unit_type);
	end

	if unit_stats[unit_name] ~= nil then
		local max_stats = dynamic_stats_uic:ChildCount();
		local stats_added = 0;

		for i = 1, #unit_stats_ordered do
			if stats_added == max_stats then
				break;
			else
				local stat_name = unit_stats_ordered[i];

				if unit_stats[unit_name][stat_name] ~= nil then
					local stat_uic = UIComponent(dynamic_stats_uic:Find(stats_added));
					local stat_name_uic = UIComponent(stat_uic:Find("stat_name"));
					local stat_value_uic = UIComponent(stat_uic:Find("dy_value"));
					local stat_bar_base_uic = UIComponent(stat_uic:Find("bar_base"));
					local stat_max_value = ui_unit_stats["stat_"..stat_name][3];
					local stat_percentage = unit_stats[unit_name][stat_name] / stat_max_value;

					stat_name_uic:SetStateText(ui_unit_stats["stat_"..stat_name][1]);
					stat_value_uic:SetStateText(tostring(unit_stats[unit_name][stat_name]));
					stat_bar_base_uic:Resize(49 * stat_percentage, 8);
					stat_uic:SetVisible(true);

					stats_added = stats_added + 1;
				end
			end
		end

		if stats_added < max_stats then
			for i = stats_added, max_stats - 1 do
				local stat_uic = UIComponent(dynamic_stats_uic:Find(i));

				stat_uic:SetVisible(false);
			end
		end
	end

	ability_list_uic:DestroyChildren();

	if unit_abilities[unit_name] ~= nil then
		for i = 1, #unit_abilities[unit_name] do
			ability_list_uic:CreateComponent("ability_icon"..tostring(i), "ui/new/ability_icons/"..unit_abilities[unit_name][i]);

			local ability_uic = UIComponent(ability_list_uic:Find(i - 1));

			ability_uic:SetMoveable(true);
			ability_uic:MoveTo(ability_list_uicX + (28 * (i - 1)), ability_list_uicY);
			ability_uic:SetMoveable(false);
		end
	end
end

function SetUnitInformationPanelVisible(visible, real_visible)
	local root = cm:ui_root();
	local info_panel_holder_uic = UIComponent(root:Find("custom_info_panel_holder"));
	local real_info_panel_holder_uic = UIComponent(root:Find("info_panel_holder"));
	local real_info_panel_background_uic = UIComponent(real_info_panel_holder_uic:Find("info_panel_background"));

	if visible == true then
		info_panel_holder_uic:SetVisible(true);
		real_info_panel_background_uic:SetVisible(false);
	else
		info_panel_holder_uic:SetVisible(false);

		if real_visible == true then
			real_info_panel_background_uic:SetVisible(true);
		end
	end
end
