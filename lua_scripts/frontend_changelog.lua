---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - CHANGELOG/UPDATE INFORMATION
-- 	By: DETrooper
--
---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------

local dev = require("lua_scripts.dev");
local util = require "lua_scripts.util";

local changelogpriority = false; -- If true, always display.
local changelogstring = 	"Welcome to the MK1212 Campaign Open Alpha!\n\n"..
			"This update brings a wealth of new units, reworked rosters, and new playable factions in custom battles. Exciting new additions include cannon elephants, trebuchet artillery, and significantly larger battlefields. Several major bugs have also been fixed, such as the limit on the number of units per faction (though this comes at the cost of AI-generated armies in custom battles) and the infamous replay bug. Lastly, there has been major rebalancing and improvements to how the AI uses certain units such as cavalry.\n\n"..
			"The campaign has also recieved major changes, such as: a new playable faction - the Kingdom of Navarre, the addition of tier 2 and tier 3 units into the campaign, complete technology trees, the Holy Roman Empire system, Ironman mode with custom achievements, and the building slot limit being raised from 6 to 10.\n\n"..
			"We look forward to hearing any feedback you may have on the mod, which you can give in our mod's Discord channel. The mod now includes a convenient button that will open the Discord channel in your browser, found in the menu at the top-left of your screen.\n\n";

changelogcreated = false;

eh:add_listener(
	"OnUICreated_Changelog",
	"UICreated",
	true,
	function(context) OnUICreated_Changelog(context) end,
	true
);
eh:add_listener(
	"OnFrontendScreenTransition_Changelog",
	"FrontendScreenTransition",
	true,
	function(context) OnFrontendScreenTransition_Changelog(context) end,
	true
);
eh:add_listener(
	"OnComponentLClickUp_Changelog",
	"ComponentLClickUp",
	true,
	function(context) OnComponentLClickUp_Changelog(context) end,
	true
);

function OnUICreated_Changelog(context)
	if changelogpriority == true then 
		CreateChangelog();
	elseif util.fileExists("MK1212_config.txt") == true then
		if not dev.settings["changelogNumber"] then
			dev.writeSettings("MK1212_config.txt");
			CreateChangelog();
			dev.changeSetting("MK1212_config.txt", "changelogNumber", version_number);
		else
			if tonumber(dev.settings["changelogNumber"]) < version_number then
				CreateChangelog();
				dev.changeSetting("MK1212_config.txt", "changelogNumber", version_number);
			end
		end
	else
		dev.writeSettings("MK1212_config.txt");
		CreateChangelog();
	end
end;

function OnFrontendScreenTransition_Changelog(context)
	if UIComponent(m_root:Find("changelog")):Visible() == true then
		UIComponent(m_root:Find("changelog")):SetVisible(false);
	end

	if context.string == "main" then
		UIComponent(m_root:Find("button_message")):SetState("active");
	else
		UIComponent(m_root:Find("button_message")):SetState("inactive");
 	end
end;

function OnComponentLClickUp_Changelog(context)
	if context.string == "changelog_accept" or context.string == "button_home" then
		UIComponent(m_root:Find("changelog")):SetVisible(false);
	elseif context.string == "button_message" then
		if UIComponent(m_root:Find("changelog")):Visible() == true then
			UIComponent(m_root:Find("changelog")):SetVisible(false);
		else
			CreateChangelog();
		end
	end
end;

function CreateChangelog()
	UIComponent(m_root:Find("logo")):DestroyChildren();
	UIComponent(m_root:Find("logo")):CreateComponent("changelog", "UI/campaign ui/events");
	UIComponent(m_root:Find("changelog")):CreateComponent("changelog_accept", "UI/new/basic_toggle_accept");

	local logo_uic = UIComponent(m_root:Find("logo"));
	local changelog_uic = UIComponent(logo_uic:Find("changelog"));
	local changelog_accept_uic = UIComponent(changelog_uic:Find("changelog_accept"));
	local changelog_event_dilemma_uic = UIComponent(changelog_uic:Find("event_dilemma"));
	local changelog_event_standard_uic = UIComponent(changelog_uic:Find("event_standard"));
	local changelog_scroll_frame_uic = UIComponent(changelog_event_standard_uic:Find("scroll_frame"));
	local changelog_tx_title_uic = UIComponent(changelog_uic:Find("tx_title"));
	local changelog_dy_event_picture_uic = UIComponent(changelog_event_standard_uic:Find("dy_event_picture"));
	local changelog_textview_no_sub_uic = UIComponent(changelog_event_standard_uic:Find("textview_no_sub"));
	local changelog_textview_with_sub_uic = UIComponent(changelog_event_standard_uic:Find("textview_with_sub"));
	local changelog_dy_subtitle_uic = UIComponent(changelog_event_standard_uic:Find("dy_subtitle"));
	local changelog_text_uic = UIComponent(changelog_textview_with_sub_uic:Find("Text"));
	local button_campaign_uic = UIComponent(m_root:Find("button_campaign"));
	local curX, curY = changelog_uic:Position();
	local button_campaign_uicX, button_campaign_uicY = button_campaign_uic:Position();
	changelog_event_dilemma_uic:SetVisible(false);
	changelog_event_standard_uic:SetVisible(true);
	changelog_dy_event_picture_uic:SetVisible(false);
	changelog_textview_no_sub_uic:SetVisible(false);

	tm:callback(
		function() 
			changelog_uic:SetMoveable(true);
			changelog_uic:MoveTo(curX - 40, button_campaign_uicY - 80);
			changelog_uic:SetMoveable(false);
			changelog_event_standard_uic:Resize(505, 500);
			changelog_scroll_frame_uic:Resize(505, 580);
			changelog_textview_with_sub_uic:Resize(460, 500);

			local curX2, curY2 = changelog_textview_with_sub_uic:Position();
			local curX3, curY3 = changelog_dy_subtitle_uic:Position();
			changelog_textview_with_sub_uic:SetMoveable(true);
			changelog_textview_with_sub_uic:MoveTo(curX2, curY2 + 110);
			changelog_textview_with_sub_uic:SetMoveable(false);
			changelog_dy_subtitle_uic:SetMoveable(true);
			changelog_dy_subtitle_uic:MoveTo(curX3 - 5, curY3 - 240);
			changelog_dy_subtitle_uic:SetMoveable(false);

			changelog_accept_uic:SetMoveable(true);
			changelog_accept_uic:MoveTo(curX3 + 115, curY3 + 325);
			changelog_accept_uic:SetMoveable(false);
		end, 
		1
	);

	changelog_tx_title_uic:SetStateText("Medieval Kingdoms 1212 AD");
	changelog_dy_subtitle_uic:SetStateText("Campaign Open Alpha "..version_number_string);
	changelog_text_uic:SetStateText(changelogstring);
	changelog_uic:SetVisible(true);
end
