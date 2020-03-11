---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MONGOLS: USER INTERFACE
-- 	By: DETrooper
--
---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------

function Add_Mongol_UI_Listeners()
	cm:add_listener(
		"OnPanelOpenedCampaign_Mongol_UI",
		"PanelOpenedCampaign",
		true,
		function(context) OnPanelOpenedCampaign_Mongol_UI(context) end,
		true
	);
end

function OnPanelOpenedCampaign_Mongol_UI(context)
	if INDEPENDENCE_JOCHI == false or INDEPENDENCE_TOLUI == false then
		if context.string == "settlement_captured" then
			local faction_name = FACTION_TURN;

			--[[if faction_name == JOCHI_KEY and INDEPENDENCE_JOCHI == false or faction_name == TOLUI_KEY and INDEPENDENCE_TOLUI == false then
				local root = cm:ui_root();
				local odRaze = UIComponent(root:Find("occupation_decision_raze_without_occupy"));
				local odLoot = UIComponent(root:Find("occupation_decision_loot"));
				local odSack = UIComponent(root:Find("occupation_decision_sack"));
				local odOccupy = UIComponent(root:Find("occupation_decision_occupy"));
				local odGift = UIComponent(root:Find("occupation_decision_gift_to_another_faction"));

				odRaze:SetVisible(false);
				odLoot:SetVisible(false);
				odSack:SetVisible(false);
				odOccupy:SetVisible(true);
				odOccupy:SetDisabled(false);
				odGift:SetVisible(true);
				odGift:SetDisabled(false);
			end]]--
		end
	end
end
