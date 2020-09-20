---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - PACK CHECKING
-- 	By: DETrooper
--
---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------
-- Checks to see if all the required MK1212 .packs are enabled.

local dev = require("lua_scripts.dev");
local util = require "lua_scripts.util";

local all_packs_enabled = true;

REQUIRED_PACKS = {
	["1-1212scriptsTEST.pack"] = {enabled = true, order = 1, name = "1-1212scripts.pack"},
	--["1-1212scripts.pack"] = {enabled = true, order = 1, name = "Medieval Kingdoms 1212 AD Scripts"},
	["1212_all_settlement_walled_v2.pack"] = {enabled = false, order = 2, "All Settlement Walled - Siege Map Replacer"},
	["1212compiletest.pack"] = {enabled = false, order = 3, name = "1212compiletest.pack"},
	--["1212compbuild_v2.pack"] = {enabled = false, order = 3, name = "Medieval Kingdoms 1212 AD Base Pack"},
	["1212models1_v2.pack"] = {enabled = false, order = 4, name = "Medieval Kingdoms 1212 AD Models Pack 1"},
	["1212models2.pack"] = {enabled = false, order = 5, name = "Medieval Kingdoms 1212 AD Models Pack 2"},
	["1212models3.pack"] = {enabled = false, order = 6, name = "Medieval Kingdoms 1212 AD Models Pack 3"},
	["1212models4.pack"] = {enabled = false, order = 7, name = "Medieval Kingdoms 1212 AD Models Pack 4"},
	["1212models5.pack"] = {enabled = false, order = 8, name = "Medieval Kingdoms 1212 AD Models Pack 5"},
	["1212models6.pack"] = {enabled = false, order = 9, name = "Medieval Kingdoms 1212 AD Models Pack 6"},
	["1212models7.pack"] = {enabled = false, order = 10, name = "Medieval Kingdoms 1212 AD Models Pack 7"},
	--["1212music.pack"] = {enabled = false, order = 11, name = "Medieval Kingdoms 1212 AD Music"}
}

eh:add_listener(
	"OnUICreated_Pack_Check",
	"UICreated",
	true,
	function(context) OnUICreated_Pack_Check(context) end,
	true
);
eh:add_listener(
	"OnFrontendScreenTransition_Pack_Check",
	"FrontendScreenTransition",
	true,
	function(context) OnFrontendScreenTransition_Pack_Check(context) end,
	true
);
eh:add_listener(
	"OnComponentLClickUp_Pack_Check",
	"ComponentLClickUp",
	true,
	function(context) OnComponentLClickUp_Pack_Check(context) end,
	true
);

function OnUICreated_Pack_Check(context)
	local warning_string = "The following mandatory .pack files are missing:\n\n";

	if util.fileExists("used_mods.txt") == true then
		local modsFile = io.open("used_mods.txt", "r");
	
		for line in modsFile:lines() do
			if line:sub(1, 3) == "mod" then
				local packName = line:sub(6, #line - 2);

				if REQUIRED_PACKS[packName] then
					REQUIRED_PACKS[packName].enabled = true;
				end
			end
		end
	
		modsFile:close();
	end

	for k, v in pairs(REQUIRED_PACKS) do
		local pack = v;

		if pack.enabled ~= true then
			if all_packs_enabled == true then
				all_packs_enabled = false;
			end

			warning_string = warning_string..pack.name.."\n";
		end
	end

	if all_packs_enabled == false then
		warning_string = warning_string.."\nWe recommend downloading the missing files from the Steam Workshop for the best experience!";

		CreatePackWarning(warning_string);
	end
end

function OnFrontendScreenTransition_Pack_Check(context)
	if UIComponent(m_root:Find("pack_warning")):Visible() == true then
		UIComponent(m_root:Find("pack_warning")):SetVisible(false);
	end
end;

function OnComponentLClickUp_Pack_Check(context)
	if context.string == "pack_warning_accept" or context.string == "button_home" then
		UIComponent(m_root:Find("pack_warning")):SetVisible(false);
	end
end;

function CreatePackWarning(warning_string)
	m_root:CreateComponent("pack_warning", "UI/campaign ui/events");
	UIComponent(m_root:Find("pack_warning")):CreateComponent("pack_warning_accept", "UI/new/basic_toggle_accept");

	local pack_warning_uic = UIComponent(m_root:Find("pack_warning"));
	local pack_warning_accept_uic = UIComponent(pack_warning_uic:Find("pack_warning_accept"));
	local pack_warning_event_dilemma_uic = UIComponent(pack_warning_uic:Find("event_dilemma"));
	local pack_warning_event_standard_uic = UIComponent(pack_warning_uic:Find("event_standard"));
	local pack_warning_scroll_frame_uic = UIComponent(pack_warning_event_standard_uic:Find("scroll_frame"));
	local pack_warning_tx_title_uic = UIComponent(pack_warning_uic:Find("tx_title"));
	local pack_warning_dy_event_picture_uic = UIComponent(pack_warning_event_standard_uic:Find("dy_event_picture"));
	local pack_warning_textview_no_sub_uic = UIComponent(pack_warning_event_standard_uic:Find("textview_no_sub"));
	local pack_warning_textview_with_sub_uic = UIComponent(pack_warning_event_standard_uic:Find("textview_with_sub"));
	local pack_warning_dy_subtitle_uic = UIComponent(pack_warning_event_standard_uic:Find("dy_subtitle"));
	local pack_warning_text_uic = UIComponent(pack_warning_textview_with_sub_uic:Find("Text"));
	local button_campaign_uic = UIComponent(m_root:Find("button_campaign"));
	local curX, curY = pack_warning_uic:Position();
	local button_campaign_uicX, button_campaign_uicY = button_campaign_uic:Position();
	pack_warning_event_dilemma_uic:SetVisible(false);
	pack_warning_event_standard_uic:SetVisible(true);
	pack_warning_dy_event_picture_uic:SetVisible(false);
	pack_warning_textview_no_sub_uic:SetVisible(false);

	tm:callback(
		function() 
			pack_warning_uic:SetMoveable(true);
			pack_warning_uic:MoveTo(curX - 40, button_campaign_uicY - 80);
			pack_warning_uic:SetMoveable(false);
			pack_warning_event_standard_uic:Resize(505, 500);
			pack_warning_scroll_frame_uic:Resize(505, 580);
			pack_warning_textview_with_sub_uic:Resize(460, 500);

			local curX2, curY2 = pack_warning_textview_with_sub_uic:Position();
			local curX3, curY3 = pack_warning_dy_subtitle_uic:Position();
			pack_warning_textview_with_sub_uic:SetMoveable(true);
			pack_warning_textview_with_sub_uic:MoveTo(curX2, curY2 + 110);
			pack_warning_textview_with_sub_uic:SetMoveable(false);
			pack_warning_dy_subtitle_uic:SetMoveable(true);
			pack_warning_dy_subtitle_uic:MoveTo(curX3 - 5, curY3 - 240);
			pack_warning_dy_subtitle_uic:SetMoveable(false);

			pack_warning_accept_uic:SetMoveable(true);
			pack_warning_accept_uic:MoveTo(curX3 + 115, curY3 + 325);
			pack_warning_accept_uic:SetMoveable(false);
		end, 
		1
	);

	pack_warning_tx_title_uic:SetStateText("Medieval Kingdoms 1212 AD");
	pack_warning_dy_subtitle_uic:SetStateText("Warning! Missing .pack files!");
	pack_warning_text_uic:SetStateText(warning_string);
	pack_warning_uic:SetVisible(true);
end
