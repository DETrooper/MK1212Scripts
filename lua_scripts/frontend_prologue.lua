local dev = require("lua_scripts.dev");
local scripting = require "lua_scripts.EpisodicScripting";

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
	if context.string == "sp_prologue" then
		tm:callback(
			function()
				CHAPTER_SELECTED = 1;
				local chapter_2_uic = UIComponent(scripting.m_root:Find("2"));
				local watermark_uic = UIComponent(scripting.m_root:Find("watermark"));
				chapter_2_uic:SetState("inactive");
				chapter_2_uic:SetInteractive(false);
				watermark_uic:SetVisible(false);

				local button_start_campaign_uic = UIComponent(scripting.m_root:Find("button_start_campaign"));
				local curX, curY = button_start_campaign_uic:Position();
				local button_start_campaign_uic_string = UIComponent(scripting.m_root:Find("string"));
				button_start_campaign_uic:SetDisabled(true);

				local button_select_uic = UIComponent(scripting.m_root:Find("button_select")); -- Created in frontend_scripted.lua
				local button_select_text_uic = UIComponent(scripting.m_root:Find("button_txt"));
				button_select_text_uic:SetStateText("[[rgba:255:255:255:150]]Select Campaign[[/rgba:255:255:255:150]]");
				--button_select_uic:PropagatePriority(200);
				button_select_uic:Resize(355, 51);
				button_select_uic:SetMoveable(true);
				button_select_uic:MoveTo(curX, curY);
				button_select_uic:SetMoveable(false);
				button_select_uic:SetVisible(true);
				--local button_dlc_campaign_uic = UIComponent(scripting.m_root:Find("button_dlc_campaign_1"));
				--dev.log(button_dlc_campaign_uic:GetProperty("campaign_key"));
			end, 
			0.1
		);
	else
		local button_select_uic = UIComponent(scripting.m_root:Find("button_select"));
		button_select_uic:SetVisible(false);
	end
end;

function OnComponentLClickUp_Campaign_Selection(context)
	if context.string == "1" then
		CHAPTER_SELECTED = 1;
	elseif context.string == "2" then
		CHAPTER_SELECTED = 2;
	elseif context.string == "button_select" then
		local button_select_uic = UIComponent(scripting.m_root:Find("button_select"));
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
