system.ClearRequiredFiles();

package.path = ";?.lua;data/ui/templates/?.lua;data/ui/?.lua"

require "data.lua_scripts.all_scripted"

events = get_events();

local advice = require "data.lua_scripts.export_advice"

local m_user_defined_event_callbacks = {}

function AddEventCallBack(event, func, add_to_user_defined_list)
	assert(events[event] ~= nil, "Attempting to add event callback to non existant event ("..event..")")
	assert(func ~= nil, "Attempting to add a non existant function to event "..event)

	-- Push the function to the back of the list of function for the specified address	
	events[event][#events[event]+1] = func
	
	if add_to_user_defined_list ~= false then
		m_user_defined_event_callbacks[#m_user_defined_event_callbacks+1] = {}
		m_user_defined_event_callbacks[#m_user_defined_event_callbacks].event = event
		m_user_defined_event_callbacks[#m_user_defined_event_callbacks].func = func
	end
end



--
--	Script support for historic battle and prologue frontend
-- 

require "lua_scripts.FE_Script_Header";
eh = event_handler:new(AddEventCallBack);
tm = timer_manager:new(Timers);
svr = ScriptedValueRegistry:new();
m_root = nil;

require "lua_scripts.frontend_strings"
require "lua_scripts.frontend_changelog"
require "lua_scripts.frontend_prologue"
require "lua_scripts.frontend_hbs"

local dev = require("lua_scripts.dev");
local util = require "lua_scripts.util"
scripting = require "lua_scripts.EpisodicScripting";

adopted = false;
cutscenes_enabled = true; -- default to true

require("lua_scripts.logging_callbacks");

--
--	Create handle to the UI root when it's created
--

eh:add_listener(
	"OnUICreated",
	"UICreated",
	true,
	function(context) OnUICreated(context) end,
	true
);

eh:add_listener(
	"OnFrontendScreenTransition",
	"FrontendScreenTransition",
	true,
	function(context) ChangeFrontend(context) end,
	true
);

eh:add_listener(
	"OnComponentLClickUp",
	"ComponentLClickUp",
	true,
	function(context) OnComponentLClickUp(context) end,
	true
);

eh:add_listener(
	"OnComponentMouseOn",
	"ComponentMouseOn",
	true,
	function(context) OnMouseOn(context) end,
	true
);

function OnUICreated(context)
	if util.fileExists("MK1212_config.txt") == true then
		if tonumber(dev.settings["cutscenesEnabled"]) == 0 then
			cutscenes_enabled = false;
		else
			cutscenes_enabled = true;
		end
	else
		dev.writeSettings("MK1212_config.txt");
	end

	scripting.m_root:CreateComponent("button_select", "ui/templates/text_button");
	scripting.m_root:CreateComponent("button_random_faction", "ui/new/button_small_randfact");
	scripting.m_root:CreateComponent("checkbox_campaign_cutscenes", "ui/templates/checkbox");
	scripting.m_root:CreateComponent("text_campaign_cutscenes", "ui/campaign ui/script_dummy");
	local button_select_uic = UIComponent(scripting.m_root:Find("button_select"));
	local button_select_text_uic = UIComponent(scripting.m_root:Find("button_txt"));
	local button_random_faction_uic = UIComponent(scripting.m_root:Find("button_random_faction"));
	local checkbox_campaign_cutscenes_uic = UIComponent(scripting.m_root:Find("checkbox_campaign_cutscenes"));
	local text_campaign_cutscenes_uic = UIComponent(scripting.m_root:Find("text_campaign_cutscenes"));
	button_select_text_uic:SetStateText("[[rgba:255:255:255:150]]Select Campaign[[/rgba:255:255:255:150]]");
	checkbox_campaign_cutscenes_uic:SetTooltipText("Check this box to enable campaign cutscenes. Note that these will be unskippable.");
	--text_campaign_cutscenes_uic:SetStateText("[[rgba:255:255:242:150]]Enable Campaign Cutscenes[[/rgba:255:255:242:150]]");
	button_select_uic:SetVisible(false);
	button_random_faction_uic:SetVisible(false);	
	checkbox_campaign_cutscenes_uic:SetVisible(false);
	text_campaign_cutscenes_uic:SetVisible(false);

	ChangeFrontend(context);
	ChangeCampaignsPanel();
end

function ChangeFrontend(context)
	adopted = false;

	local text_version_number_uic = UIComponent(scripting.m_root:Find("version_number"));
	local curX, curY = text_version_number_uic:Position();

	text_version_number_uic:SetStateText("Medieval Kingdoms 1212: Campaign Build v5.0.0");
	text_version_number_uic:SetMoveable(true);
	text_version_number_uic:MoveTo(curX - 8, curY);
	text_version_number_uic:SetMoveable(false);

	local checkbox_campaign_cutscenes_uic = UIComponent(scripting.m_root:Find("checkbox_campaign_cutscenes"));
	local text_campaign_cutscenes_uic = UIComponent(scripting.m_root:Find("text_campaign_cutscenes"));
	checkbox_campaign_cutscenes_uic:SetVisible(false);

	if cutscenes_enabled == true then
		checkbox_campaign_cutscenes_uic:SetState("selected");
	else
		checkbox_campaign_cutscenes_uic:SetState("active");				
	end

	text_campaign_cutscenes_uic:SetStateText("");
	text_campaign_cutscenes_uic:SetVisible(false);

	local button_historical_battle_uic = UIComponent(scripting.m_root:Find("button_historical_battle"));
	button_historical_battle_uic:SetState("inactive");

	local effect_title_uic = UIComponent(scripting.m_root:Find("effect_title"));
	effect_title_uic:SetDisabled(true);

	ChangeCampaignsPanel();
end

function OnComponentLClickUp(context)
	if context.string == "button_new_campaign" then
		tm:callback(
			function() 
				local faction_panel_uic = UIComponent(scripting.m_root:Find("faction_panel"));
				local curX, curY = faction_panel_uic:Position();
				faction_panel_uic:Resize(1300, 254);
				faction_panel_uic:SetMoveable(true);
				faction_panel_uic:MoveTo(curX, curY - 74);
				faction_panel_uic:SetMoveable(false);

				local start_year_uic = UIComponent(scripting.m_root:Find("dy_start_year"));
				local effect_title_uic = UIComponent(scripting.m_root:Find("effect_title"));
				start_year_uic:Resize(400, 64, true);
				start_year_uic:SetStateText("[[rgba:63:35:13:150]]"..FACTION_STRENGTHS[FACTIONS_CAMPAIGN_1[1]].."\n"..FACTION_WEAKNESSES[FACTIONS_CAMPAIGN_1[1]].."[[/rgba:63:35:13:150]]");
				
				local faction_id = math.random(#FACTIONS_CAMPAIGN_1);
				local faction_button_group_uic = UIComponent(scripting.m_root:Find("faction_button_group"));
				local faction_uic = UIComponent(faction_button_group_uic:Find(FACTIONS_CAMPAIGN_1[faction_id]));
				--faction_uic:ClearSound();
				faction_uic:SimulateClick(); -- Click random faction.
				faction_uic:SetState("selected");
			end, 
			1
		);
	end

	if context.string == "button_dlc_campaign_1" then
		tm:callback(
			function() 
				local faction_panel_uic = UIComponent(scripting.m_root:Find("faction_panel"));
				local curX, curY = faction_panel_uic:Position();
				faction_panel_uic:Resize(1300, 254);
				faction_panel_uic:SetMoveable(true);
				faction_panel_uic:MoveTo(curX, curY - 74);
				faction_panel_uic:SetMoveable(false);

				local start_year_uic = UIComponent(scripting.m_root:Find("dy_start_year"));
				local effect_title_uic = UIComponent(scripting.m_root:Find("effect_title"));
				start_year_uic:Resize(400, 64, true);
				start_year_uic:SetStateText("[[rgba:63:35:13:150]]"..FACTION_STRENGTHS[FACTIONS_CAMPAIGN_2[1]].."\n"..FACTION_WEAKNESSES[FACTIONS_CAMPAIGN_2[1]].."[[/rgba:63:35:13:150]]");

				local button_purchase_uic = UIComponent(scripting.m_root:Find("button_purchase"));
				button_purchase_uic:SetVisible(false);
				local button_start_campaign_uic = UIComponent(scripting.m_root:Find("button_start_campaign"));
				button_start_campaign_uic:SetVisible(true);

				local faction_id = math.random(#FACTIONS_CAMPAIGN_2);
				local faction_button_group_uic = UIComponent(scripting.m_root:Find("faction_group_button_group"));
				local faction_uic = UIComponent(faction_button_group_uic:Find(FACTIONS_CAMPAIGN_2[faction_id]));
				--faction_uic:ClearSound();
				faction_uic:SimulateClick(); -- Click 1st faction.
				faction_uic:SetState("selected");
			end, 
			1
		);
	end

	if context.string == "button_new_campaign" or context.string == "button_dlc_campaign_1" or string.find(context.string, "att_fact_group") or string.find(context.string, "mk_fact") or string.find(context.string, "att_fact") then
		tm:callback(
			function()
				ChangeEffects();
			end, 
			1
		);
	end

	if context.string == "button_introduction" then
		adopted = false;
	end

	if context.string == "checkbox_campaign_cutscenes" then	
		if util.fileExists("MK1212_config.txt") == false then
			writeSettings("MK1212_config.txt");
		end

		if UIComponent(scripting.m_root:Find("checkbox_campaign_cutscenes")):CurrentState() == "selected_down" or UIComponent(scripting.m_root:Find("checkbox_campaign_cutscenes")):CurrentState() == "active" then
			dev.changeSetting("MK1212_config.txt", "cutscenesEnabled", 0);
			cutscenes_enabled = false;
		elseif UIComponent(scripting.m_root:Find("checkbox_campaign_cutscenes")):CurrentState() == "down" or UIComponent(scripting.m_root:Find("checkbox_campaign_cutscenes")):CurrentState() == "selected" then
			dev.changeSetting("MK1212_config.txt", "cutscenesEnabled", 1);
			cutscenes_enabled = true;
		end
	end

	if context.string == "button_random_faction" then
		if CHAPTER_SELECTED == 1 then
			local faction_id = math.random(#FACTIONS_CAMPAIGN_1);
			local faction_button_group_uic = UIComponent(scripting.m_root:Find("faction_button_group"));
			local faction_uic = UIComponent(faction_button_group_uic:Find(FACTIONS_CAMPAIGN_1[faction_id]));
			faction_uic:SimulateClick(); -- Click random faction.
			faction_uic:SetState("selected");	
		else
			local faction_id = math.random(#FACTIONS_CAMPAIGN_2);
			local faction_button_group_uic = UIComponent(scripting.m_root:Find("faction_group_button_group"));
			local faction_uic = UIComponent(faction_button_group_uic:Find(FACTIONS_CAMPAIGN_2[faction_id]));
			faction_uic:SimulateClick(); -- Click random faction.
			faction_uic:SetState("selected");	
		end	
	end

	if FACTION_WEAKNESSES[context.string] ~= nil then
		local start_year_uic = UIComponent(scripting.m_root:Find("dy_start_year"));
		start_year_uic:SetStateText("[[rgba:63:35:13:150]]"..FACTION_STRENGTHS[context.string].."\n"..FACTION_WEAKNESSES[context.string].."[[/rgba:63:35:13:150]]");
	end

	if FACTION_POPULATIONS[context.string] ~= nil then
		local effect_description_window_uic = UIComponent(scripting.m_root:Find("effect_description_window"));
		effect_description_window_uic:SetStateText("Population: "..FACTION_POPULATIONS[context.string]);
	end

	--[[if context.string == "att_fact_group_barbarian" then
		tm:callback(
			function() 
				local tx_factions_uic = UIComponent(scripting.m_root:Find("tx_factions"));
				local curX, curY = tx_factions_uic:Position();

				local croatia_uic = UIComponent(scripting.m_root:Find("mk_fact_croatia"));
				local serbia_uic = UIComponent(scripting.m_root:Find("mk_fact_serbia"));
				local hungary_uic = UIComponent(scripting.m_root:Find("mk_fact_hungary"));
				local wallachia_uic = UIComponent(scripting.m_root:Find("mk_fact_wallachia"));
				local latinempire_uic = UIComponent(scripting.m_root:Find("mk_fact_latinempire"));
				local bulgaria_uic = UIComponent(scripting.m_root:Find("mk_fact_bulgaria"));
				local epirus_uic = UIComponent(scripting.m_root:Find("mk_fact_epirus"));

				croatia_uic:SetMoveable(true);
				serbia_uic:SetMoveable(true);
				hungary_uic:SetMoveable(true);
				wallachia_uic:SetMoveable(true);
				latinempire_uic:SetMoveable(true);
				bulgaria_uic:SetMoveable(true);
				epirus_uic:SetMoveable(true);

				croatia_uic:MoveTo(curX + 3, curY + 38);
				serbia_uic:MoveTo(curX + 71, curY + 38);
				hungary_uic:MoveTo(curX + 139, curY + 38);
				wallachia_uic:MoveTo(curX + 207, curY + 38);
				latinempire_uic:MoveTo(curX + 275, curY + 38);
				bulgaria_uic:MoveTo(curX + 343, curY + 38);
				epirus_uic:MoveTo(curX + 173, curY + 106);

				croatia_uic:SetMoveable(false);
				serbia_uic:SetMoveable(false);
				hungary_uic:SetMoveable(false);
				wallachia_uic:SetMoveable(false);
				latinempire_uic:SetMoveable(false);
				bulgaria_uic:SetMoveable(false);
				epirus_uic:SetMoveable(false);
			end, 
			1
		);
	end]]--

	tm:callback(
		function()
			if UIComponent(scripting.m_root:Find("3D_window")):Visible() == false or UIComponent(scripting.m_root:Find("3D_window")):Visible() == nil then
				local checkbox_campaign_cutscenes_uic = UIComponent(scripting.m_root:Find("checkbox_campaign_cutscenes"));
				local button_random_faction_uic = UIComponent(scripting.m_root:Find("button_random_faction"));
				local text_campaign_cutscenes_uic = UIComponent(scripting.m_root:Find("text_campaign_cutscenes"));
				checkbox_campaign_cutscenes_uic:SetVisible(false);
				text_campaign_cutscenes_uic:SetStateText("");
				text_campaign_cutscenes_uic:SetVisible(false);
				button_random_faction_uic:SetVisible(false);
			end
		end, 
		0.2
	);

	-- For custom battles.
	if context.string == "button_change_faction" then
		tm:callback(
			function() 
				local faction_dropdown_uic = UIComponent(scripting.m_root:Find("faction_dropdown"));
				local popup_menu_uic = UIComponent(faction_dropdown_uic:Find("popup_menu"));
				local popup_list_uic = UIComponent(popup_menu_uic:Find("popup_list"));
				local popup_menuX, popup_menuY = popup_menu_uic:Position();
				local popup_listX, popup_listY = popup_list_uic:Position();

				local boundsX = 225;
				local boundsY = 32;
				local columns = math.ceil(popup_list_uic:ChildCount() / 20);
				local column = 1;
				local row = 0;

				popup_menu_uic:Resize((225 * columns), 650);
				popup_menu_uic:SetMoveable(true);
				popup_menu_uic:MoveTo(popup_menuX - ((boundsX * columns) / 2), popup_menuY);
				popup_menu_uic:SetMoveable(false);

				popup_listX, popup_listY = popup_list_uic:Position(); -- Reset pos.
				
				for i = 1, popup_list_uic:ChildCount() do
					local uic = UIComponent(popup_list_uic:Find("option"..tostring(i - 1)));

					if row < 20 then
						row = row + 1;
					else
						row = 1;
					end

					if i > 20 and i < 40 then
						column = 2;
					elseif i > 40 and i < 60 then
						column = 3;
					elseif i > 60 and i < 80 then
						column = 4;
					elseif i > 80 then
						column = 5;
					end

					uic:SetMoveable(true);
					uic:MoveTo(popup_listX - boundsX + (boundsX * column), popup_listY + (boundsY * (row - 1)));
					uic:SetMoveable(false);
				end
			end,
			1
		);
	end
end

function OnMouseOn(context)
	if context.string == "button_campaign" then
		tm:callback(
			function() 
				ChangeCampaignsPanel();
			end, 
			1
		);
	end
end

function ChangeCampaignsPanel()
	local campaign_menu_uic = UIComponent(scripting.m_root:Find("campaign_menu"));
	campaign_menu_uic:Resize(300, 230);
	local button_load_campaign_uic = UIComponent(scripting.m_root:Find("button_load_campaign"));
	local button_prologue_uic = UIComponent(scripting.m_root:Find("button_introduction"));
	local button_dlc_campaign_1_uic = UIComponent(scripting.m_root:Find("button_dlc_campaign_1"));
	local button_dlc_campaign_2_uic = UIComponent(scripting.m_root:Find("button_dlc_campaign_2"));
	local button_new_campaign_uic = UIComponent(scripting.m_root:Find("button_new_campaign"));
	local button_multiplayer_campaign_uic = UIComponent(scripting.m_root:Find("button_multiplayer_campaign"));
	local curX, curY = button_load_campaign_uic:Position();

	--button_prologue_uic:SetVisible(false);
	--button_new_campaign_uic:SetVisible(false);
	--button_dlc_campaign_1_uic:SetVisible(false);
	button_dlc_campaign_2_uic:SetVisible(false);
	button_new_campaign_uic:SetMoveable(true);
	button_new_campaign_uic:MoveTo(-100, -100);
	button_new_campaign_uic:SetMoveable(false);
	button_dlc_campaign_1_uic:SetMoveable(true);
	button_dlc_campaign_1_uic:MoveTo(-100, -200);
	button_dlc_campaign_1_uic:SetMoveable(false);
	button_multiplayer_campaign_uic:SetMoveable(true);
	button_multiplayer_campaign_uic:MoveTo(curX, curY + 120);
	button_multiplayer_campaign_uic:SetMoveable(false);
end

function ChangeEffects()
	local sp_grand_campaign_uic = UIComponent(scripting.m_root:Find("sp_grand_campaign"));
	local tx_header_uic = UIComponent(scripting.m_root:Find("tx_header"));
	local tx_factions_uic = UIComponent(scripting.m_root:Find("tx_factions"));
	local effects_uic = UIComponent(scripting.m_root:Find("effects"));
	local effects_dlc_uic = UIComponent(scripting.m_root:Find("effects_dlc"));
	local leader_window_uic = UIComponent(scripting.m_root:Find("3D_window"));
	local curX, curY = leader_window_uic:Position();

	if CHAPTER_SELECTED == 1 then
		tx_header_uic:SetStateText("Early Campaign - 1212 AD");
		tx_factions_uic:SetStateText("Faction");
		local faction_button_group_uic = UIComponent(scripting.m_root:Find("faction_button_group"));
		local att_fact_group_roman_uic = UIComponent(scripting.m_root:Find("att_fact_group_roman"));
		att_fact_group_roman_uic:SetVisible(false);

		for i = 1, #FACTIONS_CAMPAIGN_1 do
			local faction_uic = UIComponent(faction_button_group_uic:Find(FACTIONS_CAMPAIGN_1[i]));
			faction_uic:SetMoveable(true);
			if i < 19 or i == 19 then
				faction_uic:MoveTo(curX - 528 + (67 * i), curY - 249);
			elseif i > 19 and i < 38 or i == 38  then
				faction_uic:MoveTo(curX - 528 + (67 * (i - 19)), curY - 182);
			elseif i > 38 then
				faction_uic:MoveTo(curX - 495 + (67 * (i - 38)), curY - 115);
			end
			faction_uic:SetMoveable(false);
 		end

		local faction_details_parent_uic = UIComponent(scripting.m_root:Find("faction_details_parent"));
		faction_details_parent_uic:Resize(436, 616);
	elseif CHAPTER_SELECTED == 2 then	
		tx_header_uic:SetStateText("Late Campaign - 1337 AD");
		--[[local faction_details_parent_uic = UIComponent(scripting.m_root:Find("faction_details_parent"));
		faction_details_parent_uic:Resize(436, 465);]]--

		local faction_group_button_group_uic = UIComponent(scripting.m_root:Find("faction_group_button_group"));
		local att_fact_group_barbarian_m_uic = UIComponent(scripting.m_root:Find("att_fact_group_barbarian_m"));
		att_fact_group_barbarian_m_uic:SetVisible(false);

		for i = 1, #FACTIONS_CAMPAIGN_2 do
			local faction_uic = UIComponent(faction_group_button_group_uic:Find(FACTIONS_CAMPAIGN_2[i]));
			UIComponent(faction_uic:Find("label")):SetVisible(false);
			UIComponent(faction_uic:Find("icon_new_content")):SetVisible(false);
			faction_uic:SetMoveable(true);
			if i < 19 or i == 19 then
				faction_uic:MoveTo(curX - 528 + (67 * i), curY - 249);
			elseif i > 19 and i < 38 or i == 38  then
				faction_uic:MoveTo(curX - 528 + (67 * (i - 19)), curY - 182);
			elseif i > 38 then
				faction_uic:MoveTo(curX - 461 + (67 * (i - 38)), curY - 115);
			end
			faction_uic:SetMoveable(false);
 		end
		effects_uic:SetVisible(true);
	end

	-- Left Side
	local tx_faction_leader_uic = UIComponent(scripting.m_root:Find("tx_faction_leader"));
	local dy_faction_leader_uic = UIComponent(scripting.m_root:Find("dy_faction_leader"));
	local tx_religion_uic = UIComponent(scripting.m_root:Find("tx_religion"));
	local dy_religion_uic = UIComponent(scripting.m_root:Find("dy_religion"));
	local header_faction_uic = UIComponent(scripting.m_root:Find("header_faction"));
	local header_cultural_uic = UIComponent(scripting.m_root:Find("header_cultural"));
	local effect_description_window_uic = UIComponent(scripting.m_root:Find("effect_description_window"));
	local faction_trait_icon_uic = UIComponent(scripting.m_root:Find("faction_trait_icon"));
	local entries_window_uic = UIComponent(scripting.m_root:Find("entries_window"));
	header_cultural_uic:SetVisible(false);
	effects_dlc_uic:SetVisible(true);
	effects_dlc_uic:Resize(377, 40);
	effects_dlc_uic:SetMoveable(true);
	effects_dlc_uic:MoveTo(curX - 432, curY + 506);
	effects_dlc_uic:SetMoveable(false);
	header_faction_uic:SetStateText("");
	header_faction_uic:SetMoveable(true);
	header_faction_uic:MoveTo(curX - 441, curY + 534);
	header_faction_uic:SetMoveable(false);
	tx_religion_uic:SetMoveable(true);
	tx_religion_uic:MoveTo(curX - 398, curY + 99);
	tx_religion_uic:SetMoveable(false);
	--dy_religion_uic:SetMoveable(true);
	--dy_religion_uic:MoveTo(curX - 229, curY + 99);
	--dy_religion_uic:SetMoveable(false);
	effect_description_window_uic:SetMoveable(true);
	effect_description_window_uic:MoveTo(curX - 338, curY + 81);
	effect_description_window_uic:SetMoveable(false);
	entries_window_uic:SetVisible(false);

	--dev.log(faction_trait_icon_uic:InterfaceFunction("CampaignEffectsBundleIcon"));
	
	-- Right Side
	local checkbox_campaign_cutscenes_uic = UIComponent(scripting.m_root:Find("checkbox_campaign_cutscenes"));
	local button_random_faction_uic = UIComponent(scripting.m_root:Find("button_random_faction"));
	local text_campaign_cutscenes_uic = UIComponent(scripting.m_root:Find("text_campaign_cutscenes"));

	checkbox_campaign_cutscenes_uic:SetMoveable(true);
	--checkbox_campaign_cutscenes_uic:MoveTo(curX + 80, curY + 583);
	checkbox_campaign_cutscenes_uic:MoveTo(curX + 78, curY - 20);
	checkbox_campaign_cutscenes_uic:SetMoveable(false);
	button_random_faction_uic:SetMoveable(true);
	button_random_faction_uic:MoveTo(curX + 795, curY - 55);
	button_random_faction_uic:SetMoveable(false);
	text_campaign_cutscenes_uic:Resize(200, 48);
	text_campaign_cutscenes_uic:SetMoveable(true);
	--text_campaign_cutscenes_uic:MoveTo(curX + 110, curY + 591);
	text_campaign_cutscenes_uic:MoveTo(curX + 108, curY - 12);
	text_campaign_cutscenes_uic:SetMoveable(false);
	checkbox_campaign_cutscenes_uic:SetVisible(true);
	button_random_faction_uic:SetTooltipText("Select random faction!");
	button_random_faction_uic:SetVisible(true);
	text_campaign_cutscenes_uic:SetStateText("[[rgba:255:255:242:150]]Enable Campaign Cutscenes[[/rgba:255:255:242:150]]");
	text_campaign_cutscenes_uic:SetVisible(true);

	local maps_uic = UIComponent(scripting.m_root:Find("maps"));
	local map_rome_uic = find_uicomponent_by_table(scripting.m_root, {"sp_grand_campaign", "docker", "details_panel", "maps", "map_rome"});
	local maps_frame_uic = find_uicomponent_by_table(scripting.m_root, {"sp_grand_campaign", "docker", "details_panel", "maps", "map_rome", "frame"});
	local difficulty_hbar_uic = find_uicomponent_by_table(scripting.m_root, {"sp_grand_campaign", "docker", "details_panel", "hbar"});
	local difficulty_uic = UIComponent(scripting.m_root:Find("dy_clan_difficulty"));
	local initial_challenge_uic = UIComponent(scripting.m_root:Find("tx_initial_challenge:"));
	local start_year_uic = UIComponent(scripting.m_root:Find("dy_start_year")); 
	local icon_date_uic = UIComponent(scripting.m_root:Find("icon_date"));
	local effect_title_uic = UIComponent(scripting.m_root:Find("effect_title"));
	local text_version_number_uic = UIComponent(scripting.m_root:Find("version_number"));
	--maps_uic:Resize(360, 258);
	--maps_frame_uic:Resize(387, 242);
	--map_rome_uic:SetVisible(false);
	--maps_frame_uic:SetVisible(false);
	--difficulty_hbar_uic:SetMoveable(true);
	--difficulty_hbar_uic:MoveTo(curX + 435, curY + 540);
	--difficulty_hbar_uic:SetMoveable(false);
	difficulty_uic:SetMoveable(true);
	difficulty_uic:MoveTo(curX + 557, curY + 515);
	difficulty_uic:SetMoveable(false);
	initial_challenge_uic:SetMoveable(true);
	initial_challenge_uic:MoveTo(curX + 434, curY + 515);
	initial_challenge_uic:SetMoveable(false);

	icon_date_uic:SetVisible(false);
	start_year_uic:SetMoveable(true);
	start_year_uic:MoveTo(curX + 430, curY + 545);
	start_year_uic:SetMoveable(false);

	effect_title_uic:SetVisible(false);

	if adopted == false then
		UIComponent(scripting.m_root:Find("sp_grand_campaign")):Adopt(effect_title_uic:Address());
		adopted = true;
	end
end