---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MULTIPLAYER CAMPAIGN DISCLAIMER
-- 	By: DETrooper
--
---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------

disclaimertitlestring = "Multiplayer Scripts Disclaimer";
disclaimerstring = "Due to a lack of networking functionality in Total War: Attila's scripting environment, a great number of scripted features have been disabled for multiplayer campaigns."..
					"\n\nEnabled Features:\nInvasions\nPapal Favour\nStarting Battles\nWar Weariness\nWorld Events\n\nPartially Working Features:\nDynamic Faction Names (Automatic)\nKingdom Events (Automatic)\nStory Events(HRE & Sicily Disabled)"..
					"\n\nDisabled Features:\nAnnexing Vassals\nBuffer States\nChallenges\nCrusades\nDecisions\nHoly Roman Empire System\nIronman/Achievements\nPopulation";

eh:add_listener(
	"OnFrontendScreenTransition_MP_Campaign",
	"FrontendScreenTransition",
	true,
	function(context) OnFrontendScreenTransition_MP_Campaign(context) end,
	true
);
eh:add_listener(
	"OnComponentLClickUp_MP_Campaign",
	"ComponentLClickUp",
	true,
	function(context) OnComponentLClickUp_MP_Campaign(context) end,
	true
);

function OnFrontendScreenTransition_MP_Campaign(context)
	if context.string == "mp_grand_campaign" then
		tm:callback(
			function()
				CreateScriptDisclaimer();
			end, 
			0.1
		);
	end
end;

function OnComponentLClickUp_MP_Campaign(context)
	if context.string == "disclaimer_accept" or context.string == "button_home" then
		local mp_grand_campaign_uic = UIComponent(m_root:Find("mp_grand_campaign"));
		local disclaimer_uic = UIComponent(mp_grand_campaign_uic:Find("disclaimer"));

		disclaimer_uic:SetVisible(false);
	elseif context.string == "button_disclaimer" then
		local mp_grand_campaign_uic = UIComponent(m_root:Find("mp_grand_campaign"));
		local disclaimer_uic = UIComponent(mp_grand_campaign_uic:Find("disclaimer"));

		if disclaimer_uic:Visible() then
			disclaimer_uic:SetVisible(false);
		else
			disclaimer_uic:SetVisible(true);
		end
	end
end;


function CreateScriptDisclaimer()
	local mp_grand_campaign_uic = UIComponent(m_root:Find("mp_grand_campaign"));

	if not mp_grand_campaign_uic:Find("disclaimer") then
		local disclaimer_uic = UIComponent(mp_grand_campaign_uic:CreateComponent("disclaimer", "UI/campaign ui/events"));
		local disclaimer_accept_uic = UIComponent(disclaimer_uic:CreateComponent("disclaimer_accept", "UI/new/basic_toggle_accept"));
		local disclaimer_event_dilemma_uic = UIComponent(disclaimer_uic:Find("event_dilemma"));
		local disclaimer_event_standard_uic = UIComponent(disclaimer_uic:Find("event_standard"));
		local disclaimer_scroll_frame_uic = UIComponent(disclaimer_event_standard_uic:Find("scroll_frame"));
		local disclaimer_tx_title_uic = UIComponent(disclaimer_uic:Find("tx_title"));
		local disclaimer_dy_event_picture_uic = UIComponent(disclaimer_event_standard_uic:Find("dy_event_picture"));
		local disclaimer_textview_no_sub_uic = UIComponent(disclaimer_event_standard_uic:Find("textview_no_sub"));
		local disclaimer_textview_with_sub_uic = UIComponent(disclaimer_event_standard_uic:Find("textview_with_sub"));
		local disclaimer_dy_subtitle_uic = UIComponent(disclaimer_event_standard_uic:Find("dy_subtitle"));
		local disclaimer_text_uic = UIComponent(disclaimer_textview_with_sub_uic:Find("Text"));
		local button_campaign_uic = UIComponent(m_root:Find("button_campaign"));
		local curX, curY = disclaimer_uic:Position();
		local button_campaign_uicX, button_campaign_uicY = button_campaign_uic:Position();
		
		disclaimer_event_dilemma_uic:SetVisible(false);
		disclaimer_event_standard_uic:SetVisible(true);
		disclaimer_dy_event_picture_uic:SetVisible(false);
		disclaimer_textview_no_sub_uic:SetVisible(false);

		tm:callback(
			function() 
				disclaimer_uic:SetMoveable(true);
				disclaimer_uic:MoveTo(curX - 40, button_campaign_uicY - 80);
				disclaimer_uic:SetMoveable(false);
				disclaimer_event_standard_uic:Resize(505, 500);
				disclaimer_scroll_frame_uic:Resize(505, 580);
				disclaimer_textview_with_sub_uic:Resize(460, 500);

				local curX2, curY2 = disclaimer_textview_with_sub_uic:Position();
				local curX3, curY3 = disclaimer_dy_subtitle_uic:Position();
				disclaimer_textview_with_sub_uic:SetMoveable(true);
				disclaimer_textview_with_sub_uic:MoveTo(curX2, curY2 + 110);
				disclaimer_textview_with_sub_uic:SetMoveable(false);
				disclaimer_dy_subtitle_uic:SetMoveable(true);
				disclaimer_dy_subtitle_uic:MoveTo(curX3 - 5, curY3 - 240);
				disclaimer_dy_subtitle_uic:SetMoveable(false);

				disclaimer_accept_uic:SetMoveable(true);
				disclaimer_accept_uic:MoveTo(curX3 + 125, curY3 + 325);
				disclaimer_accept_uic:SetMoveable(false);
			end, 
			1
		);

		disclaimer_tx_title_uic:SetStateText("Medieval Kingdoms 1212 AD");
		disclaimer_dy_subtitle_uic:SetStateText(disclaimertitlestring);
		disclaimer_text_uic:SetStateText(disclaimerstring);
		disclaimer_uic:SetVisible(false);
	end
end
