---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - GRAND CAMPAIGN START DATE SELECTION
-- 	By: DETrooper
--
---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------

CHAPTER_SELECTED = 1;

eh:add_listener(
	"OnFrontendScreenTransition_Campaign_Selection",
	"FrontendScreenTransition",
	true,
	function(context) OnFrontendScreenTransition_Campaign_Selection(context) end,
	true
);

eh:add_listener(
	"OnComponentLClickUp_Campaign_Selection",
	"ComponentLClickUp",
	true,
	function(context) OnComponentLClickUp_Campaign_Selection(context) end,
	true
);

function OnFrontendScreenTransition_Campaign_Selection(context)
	if context.string == "sp_start_date" then
		tm:callback(
			function()
				CHAPTER_SELECTED = 1;
				local chapter_2_uic = UIComponent(scripting.m_root:Find("2"));
				local watermark_uic = UIComponent(scripting.m_root:Find("watermark"));
				chapter_2_uic:SetState("inactive");
				chapter_2_uic:SetInteractive(false);
				watermark_uic:SetVisible(false);
			end, 
			0.1
		);
	end
end;

function OnComponentLClickUp_Campaign_Selection(context)
	if context.string == "1" then
		CHAPTER_SELECTED = 1;
	elseif context.string == "2" then
		CHAPTER_SELECTED = 2;
	elseif context.string == "button_select" then
		local button_select_uic = UIComponent(context.component);
		button_select_uic:SetState("active");
		if CHAPTER_SELECTED == 1 then
			local button_new_campaign_uic = UIComponent(scripting.m_root:Find("button_new_campaign"));
			button_new_campaign_uic:SimulateClick();
		elseif CHAPTER_SELECTED == 2 then
			local button_new_campaign_uic = UIComponent(scripting.m_root:Find("button_dlc_campaign_1"));
			button_new_campaign_uic:SimulateClick();
		end
	end
end;
