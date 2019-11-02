local dev = require("lua_scripts.dev");
local util = require "lua_scripts.util";
local scripting = require "lua_scripts.EpisodicScripting";


local changelogpriority = true; -- If true, always display.
local version_number = 500;
local version_number_string = "v5.0.0";
local changelogstring = 	"Welcome to Campaign Alpha v5.0.0!\n\n"..
			"This update adds the long-awaited HRE system, as well as new story events for a ton of new factions!\n\n"..
			""..
			"";

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
	CreateChangelog();

	if changelogpriority == true then 
		ShowChangelog();
	elseif util.fileExists("MK1212_config.txt") == true then
		if dev.settings["changelogNumber"] == nil then
			dev.writeSettings("MK1212_config.txt");
			ShowChangelog();
			dev.changeSetting("MK1212_config.txt", "changelogNumber", version_number);
		else
			if tonumber(dev.settings["changelogNumber"]) < version_number then
				ShowChangelog();
				dev.changeSetting("MK1212_config.txt", "changelogNumber", version_number);
			end
		end
	else
		dev.writeSettings("MK1212_config.txt");
		ShowChangelog();
	end
end;

function OnFrontendScreenTransition_Changelog(context)
	if UIComponent(scripting.m_root:Find("changelog")):Visible() == true then
		UIComponent(scripting.m_root:Find("changelog")):SetVisible(false);
	end
end;

function OnComponentLClickUp_Changelog(context)
	if context.string == "changelog_accept" then
		UIComponent(scripting.m_root:Find("changelog")):SetVisible(false);
	end
end;

function CreateChangelog()
	scripting.m_root:CreateComponent("changelog", "UI/campaign ui/events");
	scripting.m_root:CreateComponent("changelog_accept", "UI/new/basic_toggle_accept");

	local changelog_uic = UIComponent(scripting.m_root:Find("changelog"));
	local changelog_accept_uic = UIComponent(scripting.m_root:Find("changelog_accept"));
	local changelog_event_dilemma_uic = UIComponent(changelog_uic:Find("event_dilemma"));
	local changelog_event_standard_uic = UIComponent(changelog_uic:Find("event_standard"));
	local changelog_scroll_frame_uic = UIComponent(changelog_event_standard_uic:Find("scroll_frame"));
	local changelog_tx_title_uic = UIComponent(changelog_uic:Find("tx_title"));
	local changelog_dy_event_picture_uic = UIComponent(changelog_event_standard_uic:Find("dy_event_picture"));
	local changelog_textview_no_sub_uic = UIComponent(changelog_event_standard_uic:Find("textview_no_sub"));
	local changelog_textview_with_sub_uic = UIComponent(changelog_event_standard_uic:Find("textview_with_sub"));
	local changelog_dy_subtitle_uic = UIComponent(changelog_event_standard_uic:Find("dy_subtitle"));
	local changelog_text_uic = UIComponent(changelog_textview_with_sub_uic:Find("Text"));
	local curX, curY = changelog_uic:Position();
	changelog_event_dilemma_uic:SetVisible(false);
	changelog_event_standard_uic:SetVisible(true);
	changelog_dy_event_picture_uic:SetVisible(false);
	changelog_textview_no_sub_uic:SetVisible(false);

	tm:callback(
		function() 
			changelog_uic:SetMoveable(true);
			changelog_uic:MoveTo(curX - 40, curY + 100);
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
			changelog_accept_uic:MoveTo(curX3 + 80, curY3 + 325);
			changelog_accept_uic:SetMoveable(false);

		end, 
		1
	);

	changelog_tx_title_uic:SetStateText("Medieval Kingdoms 1212 AD");
	changelog_dy_subtitle_uic:SetStateText("Campaign Alpha "..version_number_string);
	changelog_text_uic:SetStateText(changelogstring);
	changelog_uic:Adopt(changelog_accept_uic:Address());
	changelog_uic:SetVisible(false);
end

function ShowChangelog()
	local changelog_uic = UIComponent(scripting.m_root:Find("changelog"));
	changelog_uic:SetVisible(true);
end