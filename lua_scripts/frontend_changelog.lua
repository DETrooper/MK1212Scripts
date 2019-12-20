local dev = require("lua_scripts.dev");
local util = require "lua_scripts.util";
local scripting = require "lua_scripts.EpisodicScripting";


local changelogpriority = false; -- If true, always display.
local changelogstring = 	"Welcome to the MK1212 Campaign Open Alpha!\n\n"..
			"After nearly 5 years of developing our campaign on Total War: Attila, we've finally gotten around to releasing an Open Alpha available to all players.\n\n"..
			"The campaign as it stands is obviously in an incomplete state, though we have plans to add much content in the near future. It currently includes 57 playable factions and various scripted mechanics, though many of these are incomplete. Notably missing from the campaign are expansive technology trees, naval units, mercenaries, and the HRE system, though these will be added in due time. Do note that the support of scripted features in multiplayer campaigns is precarious at best, while some features are excluded entirely due to the extreme difficulty or outright impossibility of networking them.\n\n"..
			"We'd like to extend our thanks to our testers, both old and new for their spirited and helpful feedback. Be sure to join our discord to participate in community discussion and give any feedback to the developers of the mod.\n\n"..
			"Discord Link: discord.gg/WzbeUxR (May be subject to change).";

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
		if dev.settings["changelogNumber"] == nil then
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
	if UIComponent(scripting.m_root:Find("changelog")):Visible() == true then
		UIComponent(scripting.m_root:Find("changelog")):SetVisible(false);
	end

	if context.string == "main" then
		UIComponent(scripting.m_root:Find("button_message")):SetState("active");
	else
		UIComponent(scripting.m_root:Find("button_message")):SetState("inactive");
 	end
end;

function OnComponentLClickUp_Changelog(context)
	if context.string == "changelog_accept" or context.string == "button_home" then
		UIComponent(scripting.m_root:Find("changelog")):SetVisible(false);
	elseif context.string == "button_message" then
		if UIComponent(scripting.m_root:Find("changelog")):Visible() == true then
			UIComponent(scripting.m_root:Find("changelog")):SetVisible(false);
		else
			CreateChangelog();
		end
	end
end;

function CreateChangelog()
	UIComponent(scripting.m_root:Find("logo")):DestroyChildren();
	UIComponent(scripting.m_root:Find("logo")):CreateComponent("changelog", "UI/campaign ui/events");
	UIComponent(scripting.m_root:Find("changelog")):CreateComponent("changelog_accept", "UI/new/basic_toggle_accept");

	local logo_uic = UIComponent(scripting.m_root:Find("logo"));
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
	local button_campaign_uic = UIComponent(scripting.m_root:Find("button_campaign"));
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
			changelog_accept_uic:MoveTo(curX3 + 112, curY3 + 325);
			changelog_accept_uic:SetMoveable(false);

		end, 
		1
	);

	changelog_tx_title_uic:SetStateText("Medieval Kingdoms 1212 AD");
	changelog_dy_subtitle_uic:SetStateText("Campaign Open Alpha "..version_number_string);
	changelog_text_uic:SetStateText(changelogstring);
	changelog_uic:SetVisible(true);
end