------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - GRAND CAMPAIGN START DATE SELECTION
-- 	By: DETrooper
--
------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------

CAMPAIGN_START_DATES = 2; -- # of start dates.
CAMPAIGN_START_DATE_SELECTED = 1;

-- Temporary
LATE_CAMPAIGN_DISABLED = true;

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
		CAMPAIGN_START_DATE_SELECTED = 1;
		
		if LATE_CAMPAIGN_DISABLED == true then
			tm:callback(
				function()
					local start_date_2_uic = UIComponent(m_root:Find("2"));

					start_date_2_uic:SetState("inactive");
					start_date_2_uic:SetInteractive(false);
				end, 
				0.1
			);
		end
	end
end;

function OnComponentLClickUp_Campaign_Selection(context)
	if context.string == "1" or context.string == "2" then
		CAMPAIGN_START_DATE_SELECTED = tonumber(context.string);

		local sp_start_date_uic = UIComponent(m_root:Find("sp_start_date"));
		local details_panel_uic = UIComponent(sp_start_date_uic:Find("details_panel"));

		for i = 1, CAMPAIGN_START_DATES do
			local button_start_date_uic = UIComponent(details_panel_uic:Find("button_start_date_"..tostring(i)));

			if tostring(i) == context.string then
				button_start_date_uic:SetVisible(true);
			else
				button_start_date_uic:SetVisible(false);
			end
		end
	end
end;
