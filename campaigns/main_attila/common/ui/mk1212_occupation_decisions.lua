---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - COMMON UI: OCCUPATION DECISIONS
-- 	By: DETrooper
--
---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------
-- Adds a 'gift to faction' occupation decision that replaces the occupy decision.

local valid_allies = {};
local valid_vassals = {};

function Add_MK1212_Occupation_Decision_Listeners()
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
end

function OnComponentLClickUp_Occupation_Decisions(context)
	if context.string == "gift_button" then
		local occupation_decision_occupy_uic = UIComponent(UIComponent(context.component):Parent());
		local option_button_uic = UIComponent(occupation_decision_occupy_uic:Find("option_button"));
		local dy_option_uic = UIComponent(option_button_uic:Find("dy_option"));
		
		dy_option_uic:SetStateText("Gift to Faction");
	end
end

function OnPanelOpenedCampaign_Occupation_Decisions(context)
	if context.string == "settlement_captured" then
		local settlement_captured_uic = UIComponent(context.component);
		local button_parent_uic = UIComponent(settlement_captured_uic:Find("button_parent"));
		local button_parent_uicbX, button_parent_uicbY = button_parent_uic:Bounds();
		local occupation_decision_occupy_uic = UIComponent(button_parent_uic:Find("occupation_decision_occupy"));
		local occupation_decision_occupy_uicX, occupation_decision_occupy_uicY = occupation_decision_occupy_uic:Position();

		-- If occupy button is enabled then search all factions for valid allies/vassals that can be gifted a region.
		if occupation_decision_occupy_uic and occupation_decision_occupy_uic:Visible() then
			local faction_list = cm:model():world():faction_list();
			local gift_button_uic = UIComponent(occupation_decision_occupy_uic:CreateComponent("gift_button", "ui/new/button_small_accept"));
			local human_faction_name = cm:get_local_faction();
			local human_faction = cm:model():world():faction_by_key(human_faction_name);

			gift_button_uic:SetMoveable(true);
			gift_button_uic:MoveTo(occupation_decision_occupy_uicX + 60, occupation_decision_occupy_uicY + 60);
			gift_button_uic:SetMoveable(false);

			for i = 0, faction_list:num_items() - 1 do
				local current_faction = faction_list:item_at(i);
				local current_faction_name = current_faction:name();

				-- Faction is allied/vassalized.
				if current_faction:allied_with(human_faction) then
					table.insert(valid_allies, current_faction);
				elseif (FACTIONS_TO_FACTIONS_VASSALIZED and FACTIONS_TO_FACTIONS_VASSALIZED[human_faction_name] and HasValue(FACTIONS_TO_FACTIONS_VASSALIZED[human_faction_name], current_faction_name)) then
					table.insert(valid_vassals, current_faction);
				end
			end

			if #valid_allies > 1 or #valid_vassals > 1 then
				gift_button_uic:SetState("active");
			end
		end
	end
end
