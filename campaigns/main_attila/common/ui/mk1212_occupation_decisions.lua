---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - COMMON UI: OCCUPATION DECISIONS
-- 	By: DETrooper
--
---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------
-- Adds a 'gift to faction' occupation decision that replaces the occupy decision.

local selected_faction_name = nil;
local selected_region_name = nil;
local settlement_captured_open = false;
local valid_allies = {};
local valid_vassals = {};

function Add_MK1212_Occupation_Decision_Listeners()
	cm:add_listener(
		"CharacterPerformsOccupationDecisionOccupy_Occupation_Decisions",
		"CharacterPerformsOccupationDecisionOccupy",
		true,
		function(context) OnCharacterPerformsOccupationDecisionOccupy_Occupation_Decisions(context) end,
		true
	);
	cm:add_listener(
		"OnComponentLClickUp_Occupation_Decisions",
		"ComponentLClickUp",
		true,
		function(context) OnComponentLClickUp_Occupation_Decisions(context) end,
		true
	);
	cm:add_listener(
		"OnPanelOpenedCampaign_Occupation_Decisions",
		"PanelOpenedCampaign",
		true,
		function(context) OnPanelOpenedCampaign_Occupation_Decisions(context) end,
		true
	);
	cm:add_listener(
		"PanelClosedCampaign_Occupation_Decisions",
		"PanelClosedCampaign",
		true,
		function(context) OnPanelClosedCampaign_Occupation_Decisions(context) end,
		true
	);
	cm:add_listener(
		"TimeTrigger_Occupation_Decisions",
		"TimeTrigger",
		true,
		function(context) TimeTrigger_Occupation_Decisions(context) end,
		true
	);
end

function OnCharacterPerformsOccupationDecisionOccupy_Occupation_Decisions(context)
	if selected_faction_name then
		if context:character():faction():name() == cm:get_local_faction() then
			local selected_region = FindClosestRegion(context:character():logical_position_x(), context:character():logical_position_y(), "none"); -- Taking the character's region may be inaccurate if they're at sea or across a strait.

			if selected_region then
				selected_region_name = selected_region:name();
				
				cm:add_time_trigger("Gift_Region_Occupation_Decisions", 0.1);
			end
		end
	end
end

function OnComponentLClickUp_Occupation_Decisions(context)
	if settlement_captured_open then
		if context.string == "button_gift_region" then
			local button_gift_region_uic = UIComponent(context.component);
			local settlement_captured_uic = UIComponent(button_gift_region_uic:Parent());
			local button_parent_uic = UIComponent(settlement_captured_uic:Find("button_parent"));
			local occupation_decision_occupy_uic = UIComponent(button_parent_uic:Find("occupation_decision_occupy"));
			local option_button_uic = UIComponent(occupation_decision_occupy_uic:Find("option_button"));
			local dy_option_uic = UIComponent(option_button_uic:Find("dy_option"));
			
			if button_gift_region_uic:CurrentState() == "down" then
				dy_option_uic:SetStateText("Gift to Faction");

				for i = 0, button_parent_uic:ChildCount() - 1 do
					local occupation_decision_child_uic = UIComponent(button_parent_uic:Find(i));

					if occupation_decision_child_uic ~= occupation_decision_occupy_uic then
						if occupation_decision_child_uic:Visible() then
							local child_option_button_uic = UIComponent(occupation_decision_child_uic:Find("option_button"));

							child_option_button_uic:SetState("inactive");
						end
					end
				end

				ToggleGiftableFactionList(true);
			else
				dy_option_uic:SetStateText("Occupy");

				for i = 0, button_parent_uic:ChildCount() - 1 do
					local occupation_decision_child_uic = UIComponent(button_parent_uic:Find(i));

					if occupation_decision_child_uic ~= occupation_decision_occupy_uic then
						if occupation_decision_child_uic:Visible() then
							local child_option_button_uic = UIComponent(occupation_decision_child_uic:Find("option_button"));
							local child_dy_option_uic = UIComponent(child_option_button_uic:Find("dy_option"));

							child_option_button_uic:SetState("active");
							-- For some reason changing the state messes with the text color on this UIC so we'll need to change it back.
							--child_dy_option_uic:SetStateText("[[rgba:255:248:215]]"..child_dy_option_uic:GetStateText().."[[/rgba]]"); -- This doesn't work either :(
						end
					end
				end

				selected_faction_name = nil;

				ToggleGiftableFactionList(false);
			end
		elseif string.find(context.string, "faction_row_") then
			selected_faction_name = string.gsub(context.string, "faction_row_", "");
		end
	end
end

function OnPanelOpenedCampaign_Occupation_Decisions(context)
	if context.string == "settlement_captured" then
		selected_faction_name = nil;
		settlement_captured_open = true;
		valid_allies = {};
		valid_vassals = {};

		local settlement_captured_uic = UIComponent(context.component);
		local button_parent_uic = UIComponent(settlement_captured_uic:Find("button_parent"));
		local button_parent_uicbX, button_parent_uicbY = button_parent_uic:Bounds();
		local occupation_decision_occupy_uic = UIComponent(button_parent_uic:Find("occupation_decision_occupy"));
		local occupation_decision_occupy_uicX, occupation_decision_occupy_uicY = occupation_decision_occupy_uic:Position();

		-- If occupy button is enabled then search all factions for valid allies/vassals that can be gifted a region.
		if occupation_decision_occupy_uic and occupation_decision_occupy_uic:Visible() then
			local faction_list = cm:model():world():faction_list();
			local button_gift_region_uic = UIComponent(settlement_captured_uic:Find("button_gift_region"));
			local human_faction_name = cm:get_local_faction();
			local human_faction = cm:model():world():faction_by_key(human_faction_name);
			local faction_panel_uic = UIComponent(settlement_captured_uic:Find("faction_panel"));
			local list_box_uic = UIComponent(faction_panel_uic:Find("list_box"));

			button_gift_region_uic:SetState("inactive");
			button_gift_region_uic:SetVisible(true);

			if not SACKED_SETTLEMENTS[selected_region_name] == "sacked" then
				for i = 0, faction_list:num_items() - 1 do
					local current_faction = faction_list:item_at(i);
					local current_faction_name = current_faction:name();

					-- Faction is allied/vassalized.
					if current_faction:allied_with(human_faction) then
						table.insert(valid_allies, current_faction_name);
					elseif (FACTIONS_TO_FACTIONS_VASSALIZED and FACTIONS_TO_FACTIONS_VASSALIZED[human_faction_name] and HasValue(FACTIONS_TO_FACTIONS_VASSALIZED[human_faction_name], current_faction_name)) then
						-- Vassal tracking isn't 100% accurate so make sure the faction is alive.
						if FactionIsAlive(current_faction_name) then
							table.insert(valid_vassals, current_faction_name);
						end
					end
				end

				for i = 1, #valid_allies do
					if i == 1 then
						button_gift_region_uic:SetState("active");
						list_box_uic:CreateComponent("tx_allies_gift", "ui/new/allies_hbar");
					end

					local ally_name = valid_allies[i];
					local ally_row_uic = UIComponent(list_box_uic:CreateComponent("faction_row_"..ally_name, "ui/new/gift_region_faction_row"));
					local ally_row_uicX, ally_row_uicY = ally_row_uic:Position();

					UIComponent(ally_row_uic:Find("name")):SetStateText(Get_DFN_Localisation(ally_name));

					if HasValue(FACTIONS_WITH_IMAGES, ally_name) then
						ally_row_uic:CreateComponent("faction_logo", "UI/new/faction_flags/"..ally_name.."_flag_big");
					else
						ally_row_uic:CreateComponent("faction_logo", "UI/new/faction_flags/mk_fact_unknown_flag_big");
					end
			
					local faction_logo_uic = UIComponent(ally_row_uic:Find("faction_logo"));
			
					faction_logo_uic:Resize(48, 48);
					faction_logo_uic:SetMoveable(true);
					faction_logo_uic:MoveTo(ally_row_uicX, ally_row_uicY);
					faction_logo_uic:SetMoveable(false);
					faction_logo_uic:SetInteractive(false);
				end

				for i = 1, #valid_vassals do
					if i == 1 then
						button_gift_region_uic:SetState("active");
						list_box_uic:CreateComponent("tx_vassals_gift", "ui/new/vassals_hbar");
					end

					local vassal_name = valid_vassals[i];
					local vassal_row_uic = UIComponent(list_box_uic:CreateComponent("faction_row_"..vassal_name, "ui/new/gift_region_faction_row"));
					local vassal_row_uicX, vassal_row_uicY = vassal_row_uic:Position();

					UIComponent(vassal_row_uic:Find("name")):SetStateText(Get_DFN_Localisation(vassal_name));

					if HasValue(FACTIONS_WITH_IMAGES, vassal_name) then
						vassal_row_uic:CreateComponent("faction_logo", "UI/new/faction_flags/"..vassal_name.."_flag_big");
					else
						vassal_row_uic:CreateComponent("faction_logo", "UI/new/faction_flags/mk_fact_unknown_flag_big");
					end
			
					local faction_logo_uic = UIComponent(vassal_row_uic:Find("faction_logo"));
			
					faction_logo_uic:Resize(48, 48);
					faction_logo_uic:SetMoveable(true);
					faction_logo_uic:MoveTo(vassal_row_uicX, vassal_row_uicY);
					faction_logo_uic:SetMoveable(false);
					faction_logo_uic:SetInteractive(false);
				end

				list_box_uic:Layout();
			end
		end
	end
end

function OnPanelClosedCampaign_Occupation_Decisions(context)
	if context.string == "settlement_captured" then
		settlement_captured_open = false;
	end
end

function TimeTrigger_Occupation_Decisions(context)
	if context.string == "Gift_Region_Occupation_Decisions" then
		if selected_faction_name and selected_region_name then
			cm:transfer_region_to_faction(selected_region_name, selected_faction_name);

			selected_faction_name = nil;
			selected_region_name = nil;
		end
	end
end

function ToggleGiftableFactionList(visible)
	local root = cm:ui_root();
	local settlement_captured_uic = UIComponent(root:Find("settlement_captured"));

	UIComponent(settlement_captured_uic:Find("faction_panel")):SetVisible(visible);
end
