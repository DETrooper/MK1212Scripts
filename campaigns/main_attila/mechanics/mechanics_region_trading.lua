-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: REGION TRADING
-- 	By: DETrooper
--
-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------

local min_gift_value = 1500; -- Minimum value of a region before the AI will accept it as a gift.
local regions_giving = {}; -- Regions being given to the AI.
local regions_recieving = {}; -- Regions being demanded by the player.
local region_trade_panel_open = false;

function Add_Region_Trading_Listeners()
	cm:add_listener(
		"OnComponentLClickUp_Region_Trading_UI",
		"ComponentLClickUp",
		true,
		function(context) OnComponentLClickUp_Region_Trading_UI(context) end,
		true
	);
	cm:add_listener(
		"OnPanelOpenedCampaign_Region_Trading_UI",
		"PanelOpenedCampaign",
		true,
		function(context) OnPanelOpenedCampaign_Region_Trading_UI(context) end,
		true
	);
	cm:add_listener(
		"TimeTrigger_Region_Trading_UI",
		"TimeTrigger",
		true,
		function(context) TimeTrigger_Region_Trading_UI(context) end,
		true
	);
end

local function Calculate_Region_Value(region, purchaser_name)
	local buildings_list = region:garrison_residence():buildings();
	local owner = region:owning_faction();
	local regionX = region:settlement():logical_position_x();
	local regionY = region:settlement():logical_position_y();
	local farthest_region_distance;
	local value = 0; -- Value of the region.

	-- Increase the value of the region by the sum of the monetary value of its buildings.
	for i = 0, buildings_list:num_items() - 1 do
		local building_value = REGION_TRADING_BUILDING_VALUES[buildings_list:item_at(i):name()] or 0;

		value = value + building_value;
	end

	if purchaser_name then -- Region belongs to the player.
		local purchaser_faction = cm:model():world():faction_by_key(purchaser_name);
		local purchaser_region_list = purchaser_faction:region_list();

		-- Modify value based off the region owner's attitude towards the purchasing faction.
		local stance = cm:model():campaign_ai():strategic_stance_between_factions(owner:name(), purchaser_name);

		if REGION_TRADING_STANCE_MODIFIERS[tostring(stance)] then
			value = value + REGION_TRADING_STANCE_MODIFIERS[tostring(stance)];
		end

		-- Decrease the value of the region by its distance from the purchasing faction's borders.
		for i = 0, purchaser_region_list:num_items() - 1 do
			local purchaser_region = purchaser_region_list:item_at(i);
			local purchaser_region_adjacent_region_list = purchaser_region:adjacent_region_list();
			local purchaser_regionX = purchaser_region:settlement():logical_position_x();
			local purchaser_regionY = purchaser_region:settlement():logical_position_y();
			local purchaser_region_distance = ((purchaser_regionX - regionX) ^ 2 + (purchaser_regionY - regionY) ^ 2) ^ 0.5;

			-- If any of the purchasing faction's regions are adjacent to the traded region, skip the penalty.
			if purchaser_region_adjacent_region_list:num_items() > 0 then
				for k = 0, purchaser_region_adjacent_region_list:num_items() - 1 do
					local adjacent_region = purchaser_region_adjacent_region_list:item_at(k);

					if adjacent_region:name() == region:name() or purchaser_region_distance < 50 then
						farthest_region_distance = "adjacent";
						break;
					end
				end

				if farthest_region_distance == "adjacent" then
					break;
				end
			end

			if not farthest_region_distance or farthest_region_distance < purchaser_region_distance then
				farthest_region_distance = purchaser_region_distance;
			end
		end

		if farthest_region_distance and farthest_region_distance ~= "adjacent" then
			local distance_penalty = math.floor(farthest_region_distance * (value / 500));

			--dev.log(region:name().." pre-penalty value: "..tostring(value));
			value = value - distance_penalty;
			--dev.log(region:name().." post-penalty value: "..tostring(value));
		end
	end

	return value;
end

local function Calculate_Region_Trade_Value()
	local root = cm:ui_root();
	local diplomacy_dropdown_uic = UIComponent(root:Find("diplomacy_dropdown"));
	local offers_panel_uic = UIComponent(diplomacy_dropdown_uic:Find("offers_panel"));
	local offers_list_panel_uic = UIComponent(offers_panel_uic:Find("offers_list_panel"));
	local list_offers_uic = UIComponent(offers_list_panel_uic:Find("list_offers"));
	local list_offers_list_box_uic = UIComponent(list_offers_uic:Find("list_box"));
	local list_demands_uic = UIComponent(offers_list_panel_uic:Find("list_demands"));
	local list_demands_list_box_uic = UIComponent(list_demands_uic:Find("list_box"));
	local button_set1_uic = UIComponent(offers_panel_uic:Find("button_set1"));
	local tx_likelihood_uic = UIComponent(offers_list_panel_uic:Find("tx_likelihood_of_success"));
	local dy_chance_uic = UIComponent(tx_likelihood_uic:Find("dy_chance"));
	local current_trade_weight = 0; -- Current trade weight from the player's side.
	local current_trade_value_other = 0; -- Trade weight of the other faction in diplomacy.
	local regions_checked = 0;

	regions_giving = {}; -- clear table
	regions_recieving = {}; -- clear table

	for i = 0, list_offers_list_box_uic:ChildCount() - 1 do
		local child = UIComponent(list_offers_list_box_uic:Find(i));
		local checkbox_uic = UIComponent(child:Find("checkbox"));

		if checkbox_uic:CurrentState() == "selected" or checkbox_uic:CurrentState() == "selected_hover" or checkbox_uic:CurrentState() == "down" then
			local region = cm:model():world():region_manager():region_by_key(child:Id());

			current_trade_weight = current_trade_weight + Calculate_Region_Value(region, DIPLOMACY_SELECTED_FACTION);

			table.insert(regions_giving, region:name());

			regions_checked = regions_checked + 1;
		end
	end;

	for i = 0, list_demands_list_box_uic:ChildCount() - 1 do
		local child = UIComponent(list_demands_list_box_uic:Find(i));
		local checkbox_uic = UIComponent(child:Find("checkbox"));

		if checkbox_uic:CurrentState() == "selected" or checkbox_uic:CurrentState() == "selected_hover" or checkbox_uic:CurrentState() == "down" then
			local region = cm:model():world():region_manager():region_by_key(child:Id());

			current_trade_value_other = current_trade_value_other + Calculate_Region_Value(region);

			table.insert(regions_recieving, region:name());

			regions_checked = regions_checked + 1;
		end
	end;

	if regions_checked > 0 then
		if current_trade_weight < current_trade_value_other - min_gift_value or (current_trade_weight < min_gift_value and current_trade_value_other <= 0) then
			dy_chance_uic:SetState("low");
			UIComponent(button_set1_uic:Find("button_send")):SetState("inactive");
		elseif current_trade_weight < current_trade_value_other then
			dy_chance_uic:SetState("moderate");
			UIComponent(button_set1_uic:Find("button_send")):SetState("inactive");
		elseif current_trade_weight >= current_trade_value_other and current_trade_weight < current_trade_value_other + (min_gift_value * 2) then
			dy_chance_uic:SetState("moderate");
			UIComponent(button_set1_uic:Find("button_send")):SetState("active");
		elseif current_trade_weight >= current_trade_value_other + (min_gift_value * 2) then
			dy_chance_uic:SetState("high");
			UIComponent(button_set1_uic:Find("button_send")):SetState("active");
		end

		tx_likelihood_uic:SetVisible(true);
	else
		tx_likelihood_uic:SetVisible(false);
		UIComponent(button_set1_uic:Find("button_send")):SetState("inactive");
	end
end

local function Process_Region_Trade()
	local root = cm:ui_root();
	local diplomacy_dropdown_uic = UIComponent(root:Find("diplomacy_dropdown"));
	local offers_panel_uic = UIComponent(diplomacy_dropdown_uic:Find("offers_panel"));
	local offers_list_panel_uic = UIComponent(offers_panel_uic:Find("offers_list_panel"));
	local list_offers_uic = UIComponent(offers_list_panel_uic:Find("list_offers"));
	local list_offers_list_box_uic = UIComponent(list_offers_uic:Find("list_box"));
	local list_demands_uic = UIComponent(offers_list_panel_uic:Find("list_demands"));
	local list_demands_list_box_uic = UIComponent(list_demands_uic:Find("list_box"));
	local tx_likelihood_uic = UIComponent(offers_list_panel_uic:Find("tx_likelihood_of_success"));
	local button_set1_uic = UIComponent(offers_panel_uic:Find("button_set1"));
	local faction_name = cm:get_local_faction();

	if #regions_giving > 0 then
		for i = 1, #regions_giving do
			Transfer_Region_To_Faction(regions_giving[i], DIPLOMACY_SELECTED_FACTION);
		end
	end

	if #regions_recieving > 0 then
		for i = 1, #regions_recieving do
			Transfer_Region_To_Faction(regions_recieving[i], faction_name);
		end
	end

	UIComponent(button_set1_uic:Find("button_counteroffer")):SetVisible(true);
	list_offers_list_box_uic:DestroyChildren();
	list_offers_uic:SetVisible(false);
	list_demands_list_box_uic:DestroyChildren();
	list_demands_uic:SetVisible(false);
	tx_likelihood_uic:SetVisible(false);
end

local function Open_Region_Trading_Panel()
	local root = cm:ui_root();
	local diplomacy_dropdown_uic = UIComponent(root:Find("diplomacy_dropdown"));
	local offers_panel_uic = UIComponent(diplomacy_dropdown_uic:Find("offers_panel"));
	local offers_list_panel_uic = UIComponent(offers_panel_uic:Find("offers_list_panel"));
	local button_set1_uic = UIComponent(offers_panel_uic:Find("button_set1"));
	
	UIComponent(offers_panel_uic:Find("current_treaties")):SetVisible(false);
	UIComponent(offers_panel_uic:Find("their_offers")):SetVisible(false);
	UIComponent(offers_panel_uic:Find("your_offers")):SetVisible(false);
	UIComponent(button_set1_uic:Find("button_counteroffer")):SetVisible(false);

	local diplomacy_faction = cm:model():world():faction_by_key(DIPLOMACY_SELECTED_FACTION);
	local diplomacy_faction_capital = diplomacy_faction:home_region():name();
	local diplomacy_faction_regions = diplomacy_faction:region_list();
	local faction = cm:model():world():faction_by_key(cm:get_local_faction());
	local faction_capital = faction:home_region():name();
	local faction_regions = faction:region_list();
	local list_offers_uic = UIComponent(offers_list_panel_uic:Find("list_offers"));
	local list_offers_list_box_uic = UIComponent(list_offers_uic:Find("list_box"));
	local list_demands_uic = UIComponent(offers_list_panel_uic:Find("list_demands"));
	local list_demands_list_box_uic = UIComponent(list_demands_uic:Find("list_box"));
	local tx_likelihood_uic = UIComponent(offers_list_panel_uic:Find("tx_likelihood_of_success"));

	list_offers_list_box_uic:DestroyChildren();
	list_demands_list_box_uic:DestroyChildren();

	for i = 0, faction_regions:num_items() - 1 do
		local region = faction_regions:item_at(i);
		local region_name = region:name();

		if region_name ~= faction_capital and region:garrison_residence():is_under_siege() ~= true then
			UIComponent(list_offers_list_box_uic:CreateComponent(region_name, "ui/new/template_region_list_item")):SetStateText(REGIONS_NAMES_LOCALISATION[region_name]);
		end
	end

	for i = 0, diplomacy_faction_regions:num_items() - 1 do
		local region = diplomacy_faction_regions:item_at(i);
		local region_name = region:name();

		if region_name ~= diplomacy_faction_capital and region:garrison_residence():is_under_siege() ~= true then
			UIComponent(list_demands_list_box_uic:CreateComponent(region_name, "ui/new/template_region_list_item")):SetStateText(REGIONS_NAMES_LOCALISATION[region_name]);
		end
	end

	list_offers_list_box_uic:Layout();
	list_offers_uic:SetVisible(true);
	list_demands_list_box_uic:Layout();
	list_demands_uic:SetVisible(true);
	tx_likelihood_uic:SetVisible(false);
end

function OnComponentLClickUp_Region_Trading_UI(context)
	if context.string == "button_trade_regions" then
		local diplomacy_faction = cm:model():world():faction_by_key(DIPLOMACY_SELECTED_FACTION);

		if diplomacy_faction then
			local faction_panel_uic = UIComponent(UIComponent(context.component):Parent());

			region_trade_panel_open = true;

			UIComponent(faction_panel_uic:Find("button_ok")):SimulateClick();

			cm:add_time_trigger("region_trading_open_panel", 0);
		end
	elseif DIPLOMACY_PANEL_OPEN == true then
		if not region_trade_panel_open then
			if context.string == "map" or context.string == "button_icon" or context.string == "flag" or string.find(context.string, "faction_row_entry_") then
				local root = cm:ui_root();
				local diplomacy_dropdown_uic = UIComponent(root:Find("diplomacy_dropdown"));
				local button_trade_regions_uic = UIComponent(diplomacy_dropdown_uic:Find("button_trade_regions"));

				button_trade_regions_uic:SetState("inactive");

				cm:add_time_trigger("region_trading_diplo_hud_check", 0.1);
			end
		else
			if context.string == "button_cancel" then
				local root = cm:ui_root();
				local diplomacy_dropdown_uic = UIComponent(root:Find("diplomacy_dropdown"));
				local offers_panel_uic = UIComponent(diplomacy_dropdown_uic:Find("offers_panel"));
				local offers_list_panel_uic = UIComponent(offers_panel_uic:Find("offers_list_panel"));
				local list_offers_uic = UIComponent(offers_list_panel_uic:Find("list_offers"));
				local list_offers_list_box_uic = UIComponent(list_offers_uic:Find("list_box"));
				local list_demands_uic = UIComponent(offers_list_panel_uic:Find("list_demands"));
				local list_demands_list_box_uic = UIComponent(list_demands_uic:Find("list_box"));
				local tx_likelihood_uic = UIComponent(offers_list_panel_uic:Find("tx_likelihood_of_success"));
				local button_set1_uic = UIComponent(offers_panel_uic:Find("button_set1"));
				local button_trade_regions_uic = UIComponent(diplomacy_dropdown_uic:Find("button_trade_regions"));

				UIComponent(button_set1_uic:Find("button_counteroffer")):SetVisible(true);

				list_offers_list_box_uic:DestroyChildren();
				list_offers_uic:SetVisible(false);
				list_demands_list_box_uic:DestroyChildren();
				list_demands_uic:SetVisible(false);
				tx_likelihood_uic:SetVisible(false);

				if button_trade_regions_uic:CurrentState() == "down" then
					button_trade_regions_uic:SetState("active");
				end

				region_trade_panel_open = false;
			elseif context.string == "button_send" then
				Process_Region_Trade();

				region_trade_panel_open = false;
			elseif context.string == "checkbox" then
				Calculate_Region_Trade_Value();
			end
		end
	end
end

function OnPanelOpenedCampaign_Region_Trading_UI(context)
	if context.string == "diplomacy_dropdown" then
		cm:add_time_trigger("region_trading_diplo_hud_check", 0.1);
	end
end

function TimeTrigger_Region_Trading_UI(context)
	if context.string == "region_trading_diplo_hud_check" then
		local root = cm:ui_root();
		local diplomacy_dropdown_uic = UIComponent(root:Find("diplomacy_dropdown"));

		if diplomacy_dropdown_uic then
			local button_trade_regions_uic = UIComponent(diplomacy_dropdown_uic:Find("button_trade_regions"));

			button_trade_regions_uic:SetState("inactive");
			button_trade_regions_uic:SetVisible(true);

			if DIPLOMACY_SELECTED_FACTION then
				local diplomacy_faction = cm:model():world():faction_by_key(DIPLOMACY_SELECTED_FACTION);
				local faction = cm:model():world():faction_by_key(cm:get_local_faction());

				if diplomacy_faction then
					if diplomacy_faction:is_horde() or faction:is_horde() then
						-- Hordes cannot trade regions!
						return;
					end

					if diplomacy_faction:at_war_with(faction) ~= true then
						if FACTIONS_VASSALIZED_ANNEXING and FACTIONS_VASSALIZED_ANNEXING[DIPLOMACY_SELECTED_FACTION] == true then
							return;
						end

						button_trade_regions_uic:SetState("active");
					end
				end
			end
		end
	elseif context.string == "region_trading_open_panel" then
		Open_Region_Trading_Panel();
	end
end
