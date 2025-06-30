---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - PACK CHECKING
-- 	By: DETrooper
--
---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------
-- Checks to see if all the required MK1212 .packs are enabled, and if so then enforce load order.

local dev = require("lua_scripts/dev");
local util = require("lua_scripts/util");

local all_packs_enabled = true;
local all_packs_in_order = true;

REQUIRED_PACKS = {
	{key = "1-1212scripts.pack", enabled = true, packPos = nil, order = 1, name = "Medieval Kingdoms 1212 AD Scripts"},
	{key = "Custom cities beta.pack", enabled = false, packPos = nil, order = 2, name = "All Settlement Walled - Siege Map Replacer"},
	{key = "1212compbuild_v2.pack", enabled = false, packPos = nil, order = 3, name = "Medieval Kingdoms 1212 AD Base Pack"},
	{key = "1212models1_v2.pack", enabled = false, packPos = nil, order = 4, name = "Medieval Kingdoms 1212 AD Models Pack 1"},
	{key = "1212models2.pack", enabled = false, packPos = nil, order = 5, name = "Medieval Kingdoms 1212 AD Models Pack 2"},
	{key = "1212models3.pack", enabled = false, packPos = nil, order = 6, name = "Medieval Kingdoms 1212 AD Models Pack 3"},
	{key = "1212models4.pack", enabled = false, packPos = nil, order = 7, name = "Medieval Kingdoms 1212 AD Models Pack 4"},
	{key = "1212models5.pack", enabled = false, packPos = nil, order = 8, name = "Medieval Kingdoms 1212 AD Models Pack 5"},
	{key = "1212models6.pack", enabled = false, packPos = nil, order = 9, name = "Medieval Kingdoms 1212 AD Models Pack 6"},
	{key = "1212models7.pack", enabled = false, packPos = nil, order = 10, name = "Medieval Kingdoms 1212 AD Models Pack 7"},
	{key = "1212models8.pack", enabled = false, packPos = nil, order = 11, name = "Medieval Kingdoms 1212 AD Models Pack 8"},
	{key = "1212models9.pack", enabled = false, packPos = nil, order = 12, name = "Medieval Kingdoms 1212 AD Models Pack 9"},
	{key = "1212music.pack", enabled = false, packPos = nil, order = 13, name = "Medieval Kingdoms 1212 AD Music"}
};

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
	if not svr:LoadBool("SBOOL_Pack_Check_Already_Shown") then
		--local kmm_path = os.getenv("APPDATA")..[[\Kaedrin Mod Manager\Profiles\Attila\profile_LastUsedMods.txt"]];
		local modsFile;

		if --[[not util.fileExists(kmm_path) and]] util.fileExists("used_mods.txt") then
			modsFile = io.open("used_mods.txt", "r");
		end

		ShowPackWarning(modsFile);

		svr:SaveBool("SBOOL_Pack_Check_Already_Shown", true);
	end
end

function OnFrontendScreenTransition_Pack_Check(context)
	local pack_warning_uic = UIComponent(m_root:Find("pack_warning"));

	if pack_warning_uic and pack_warning_uic:Visible() == true then
		pack_warning_uic:SetVisible(false);
	end
end;

function OnComponentLClickUp_Pack_Check(context)
	if context.string == "pack_warning_accept" or context.string == "button_home" then
		local pack_warning_uic = UIComponent(m_root:Find("pack_warning"));

		if pack_warning_uic and pack_warning_uic:Visible() == true then
			pack_warning_uic:SetVisible(false);
		end;
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

function ShowPackWarning(modsFile)
	local packPos = 0;
	local warning_string = "";

	if modsFile then
		for line in modsFile:lines() do
			if line:sub(1, 3) == "mod" then
				local pack_name = line:sub(6, #line - 2);

				for i = 1, #REQUIRED_PACKS do
					if REQUIRED_PACKS[i].key == pack_name then
						pack_found = true;
						packPos = packPos + 1;
						REQUIRED_PACKS[i].enabled = true;
						REQUIRED_PACKS[i].packPos = packPos;

						if all_packs_in_order == true then
							if packPos ~= REQUIRED_PACKS[i].order then
								all_packs_in_order = false;
							end
						end

						break;
					end
				end
			end
		end
	
		modsFile:close();
	end

	warning_string = warning_string.."The following mandatory .pack files are missing:\n\n";

	for i = 1, #REQUIRED_PACKS do
		local pack = REQUIRED_PACKS[i];

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
	elseif all_packs_in_order == false then
		warning_string = "The following .pack files are out of order:\n\n";

		for i = 1, #REQUIRED_PACKS do
			local pack = REQUIRED_PACKS[i];

			if pack.packPos ~= pack.order then
				warning_string = warning_string.."("..tostring(pack.packPos)..") "..pack.name.."\nRecommended: "..tostring(pack.order).."\n";
			end
		end

		warning_string = warning_string.."\nOut of order .pack files may make MK1212 multiplayer impossible due to incompatible versions.";

		CreatePackWarning(warning_string);
	end
end