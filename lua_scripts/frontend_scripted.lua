---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - FRONTEND SCRIPTS
-- 	By: DETrooper
--
---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------

system.ClearRequiredFiles();

package.path = ";?.lua;data/ui/templates/?.lua;data/ui/?.lua"

require "data.lua_scripts.all_scripted"

events = get_events();

local m_user_defined_event_callbacks = {}

function AddEventCallBack(event, func, add_to_user_defined_list)
	assert(events[event] , "Attempting to add event callback to non existant event ("..event..")")
	assert(func , "Attempting to add a non existant function to event "..event)

	-- Push the function to the back of the list of function for the specified address	
	events[event][#events[event]+1] = func
	
	if add_to_user_defined_list ~= false then
		m_user_defined_event_callbacks[#m_user_defined_event_callbacks+1] = {}
		m_user_defined_event_callbacks[#m_user_defined_event_callbacks].event = event
		m_user_defined_event_callbacks[#m_user_defined_event_callbacks].func = func
	end
end

require("lua_scripts.fe_script_header");

eh = event_handler:new(AddEventCallBack);
m_root = nil;
svr = ScriptedValueRegistry:new();
tm = timer_manager:new(Timers);
version_number = 2000;
version_number_string = "v2.0.0";

eh:add_listener(
	"OnUICreated_MK1212_Frontend",
	"UICreated",
	true,
	function(context) OnUICreated_MK1212_Frontend(context) end,
	true
);
eh:add_listener(
	"OnFrontendScreenTransition_MK1212_Frontend",
	"FrontendScreenTransition",
	true,
	function(context) ChangeFrontend(context) end,
	true
);
eh:add_listener(
	"OnComponentLClickUp_MK1212_Frontend",
	"ComponentLClickUp",
	true,
	function(context) OnComponentLClickUp_MK1212_Frontend(context) end,
	true
);
eh:add_listener(
	"OnComponentMouseOn_MK1212_Frontend",
	"ComponentMouseOn",
	true,
	function(context) OnComponentMouseOn_MK1212_Frontend(context) end,
	true
);

require("lua_scripts/frontend_challenges");
--require("lua_scripts/frontend_changelog"); -- Obsolete now that there's a direct discord invite.
require("lua_scripts/frontend_disclaimer");
require("lua_scripts/frontend_discord");
--require("lua_scripts/frontend_hbs"); -- There are no historical battles for MK1212 yet.
require("lua_scripts/frontend_mp_campaign");
require("lua_scripts/frontend_start_date");
require("lua_scripts/frontend_strings");

function OnUICreated_MK1212_Frontend(context)
	if context then
		m_root = UIComponent(context.component);

		ChangeFrontend(context);
		ChangeCampaignsPanel();
	end
end

function ChangeFrontend(context)
	local button_historical_battle_uic = UIComponent(m_root:Find("button_historical_battle"));
	local text_version_number_uic = UIComponent(m_root:Find("version_number"));

	if button_historical_battle_uic then
		button_historical_battle_uic:SetState("inactive");
	end

	if text_version_number_uic then
		text_version_number_uic:SetStateText(FRONTEND_STRINGS["text_version_string"]..version_number_string);
	end

	svr:SaveBool("SBOOL_IRONMAN_ENABLED", false);
	svr:SaveBool("SBOOL_LUCKY_NATIONS_ENABLED", false);

	ChangeCampaignsPanel();
end

function OnComponentLClickUp_MK1212_Frontend(context)
	if context.string == "button_new_campaign" or context.string == "button_dlc_campaign_1" or string.find(context.string, "att_fact_group") or string.find(context.string, "mk_fact") or string.find(context.string, "att_fact") then
		tm:callback(
			function()
				ChangeEffects();
			end, 
			1
		);

		if string.find(context.string, "mk_fact") then
			local start_year_uic = UIComponent(m_root:Find("dy_start_year"));
			local strength_text = "NOT FOUND";
			local weakness_text = "NOT FOUND"
	
			if FACTION_STRENGTHS[context.string]  then 
				strength_text = FACTION_STRENGTHS[context.string];
			end
	
			if FACTION_WEAKNESSES[context.string]  then
				weakness_text = FACTION_WEAKNESSES[context.string];
			end
	
			start_year_uic:SetStateText("[[rgba:63:35:13:150]]"..FRONTEND_STRINGS["faction_strength"]..strength_text.."\n"..FRONTEND_STRINGS["faction_weakness"]..weakness_text.."[[/rgba:63:35:13:150]]");
	
			if FACTION_POPULATIONS[context.string]  then
				local effect_description_window_uic = UIComponent(m_root:Find("effect_description_window"));
				effect_description_window_uic:SetStateText("Population: "..FACTION_POPULATIONS[context.string]);
			end
		end
	end

	if context.string == "button_new_campaign" then
		tm:callback(
			function() 
				local start_year_uic = UIComponent(m_root:Find("dy_start_year"));
				start_year_uic:Resize(400, 64, true);

				local faction_button_group_uic = UIComponent(m_root:Find("faction_button_group"));
				local faction_id = math.random(faction_button_group_uic:ChildCount() - 1);
				local faction_uic = UIComponent(faction_button_group_uic:Find(faction_id));
				faction_uic:SimulateClick(); -- Click random faction.
				faction_uic:SetState("selected");

				local sp_grand_campaign_uic = UIComponent(m_root:Find("sp_grand_campaign"));
				local button_start_campaign_uic = UIComponent(sp_grand_campaign_uic:Find("button_start_campaign"));
				button_start_campaign_uic:SetInteractive(false);

				tm:callback(
					function() 
						button_start_campaign_uic:SetInteractive(true);
					end,
					1000
				);
			end, 
			1
		);
	elseif context.string == "button_dlc_campaign_1" then
		tm:callback(
			function() 
				local button_purchase_uic = UIComponent(m_root:Find("button_purchase"));
				button_purchase_uic:SetVisible(false);
				local button_start_campaign_uic = UIComponent(m_root:Find("button_start_campaign"));
				button_start_campaign_uic:SetVisible(true);

				local start_year_uic = UIComponent(m_root:Find("dy_start_year"));
				start_year_uic:Resize(400, 64, true);

				local faction_button_group_uic = UIComponent(m_root:Find("faction_group_button_group"));
				local faction_id = math.random(faction_button_group_uic:ChildCount() - 1);
				local faction_uic = UIComponent(faction_button_group_uic:Find(faction_id));
				faction_uic:SimulateClick(); -- Click 1st faction.
				faction_uic:SetState("selected");

				local sp_grand_campaign_uic = UIComponent(m_root:Find("sp_grand_campaign"));
				local button_start_campaign_uic = UIComponent(sp_grand_campaign_uic:Find("button_start_campaign"));
				button_start_campaign_uic:SetInteractive(false);

				tm:callback(
					function() 
						button_start_campaign_uic:SetInteractive(true);
					end,
					1000
				);
			end, 
			1
		);
	elseif context.string == "checkbox_ironman" then
		if UIComponent(context.component):CurrentState() == "selected_down" or UIComponent(context.component):CurrentState() == "active" then
			svr:SaveBool("SBOOL_IRONMAN_ENABLED", false);

			UIComponent(m_root:Find("checkbox_lucky_nations")):SetState("selected");
		elseif UIComponent(context.component):CurrentState() == "down" or UIComponent(context.component):CurrentState() == "selected" then
			svr:SaveBool("SBOOL_IRONMAN_ENABLED", true);
			svr:SaveBool("SBOOL_LUCKY_NATIONS_ENABLED", true);

			UIComponent(m_root:Find("checkbox_lucky_nations")):SetState("selected_inactive");
		end
	elseif context.string == "checkbox_lucky_nations" then
		if UIComponent(context.component):CurrentState() == "selected_down" or UIComponent(context.component):CurrentState() == "active" then
			svr:SaveBool("SBOOL_LUCKY_NATIONS_ENABLED", false);
		elseif UIComponent(context.component):CurrentState() == "down" or UIComponent(context.component):CurrentState() == "selected" then
			svr:SaveBool("SBOOL_LUCKY_NATIONS_ENABLED", true);
		end
	elseif context.string == "button_random_faction" then
		if CHAPTER_SELECTED == 1 then
			local faction_button_group_uic = UIComponent(m_root:Find("faction_button_group"));
			local faction_id = math.random(faction_button_group_uic:ChildCount() - 1);
			local faction_uic = UIComponent(faction_button_group_uic:Find(faction_id));
			faction_uic:SimulateClick(); -- Click random faction.
			faction_uic:SetState("selected");	
		else
			local faction_button_group_uic = UIComponent(m_root:Find("faction_group_button_group"));
			local faction_id = math.random(faction_button_group_uic:ChildCount() - 1);
			local faction_uic = UIComponent(faction_button_group_uic:Find(faction_id));
			faction_uic:SimulateClick(); -- Click random faction.
			faction_uic:SetState("selected");	
		end
	end

	-- For custom battles.
	if UIComponent(m_root:Find("battle_setup")):Visible() then
		if context.string == "button_change_faction" then
			tm:callback(
				function() 
					local faction_dropdown_uic = UIComponent(m_root:Find("faction_dropdown"));
					local popup_menu_uic = UIComponent(faction_dropdown_uic:Find("popup_menu"));
					local popup_list_uic = UIComponent(popup_menu_uic:Find("popup_list"));
					local popup_menuX, popup_menuY = popup_menu_uic:Position();
					local popup_listX, popup_listY = popup_list_uic:Position();

					local boundsX = 225;
					local boundsY = 32;
					local column = 1;
					local row = 1;
					local max_rows = 21;
					local num_columns = math.ceil(popup_list_uic:ChildCount() / max_rows);

					if popup_list_uic:ChildCount() < max_rows then
						max_rows = popup_list_uic:ChildCount();
					end

					popup_menu_uic:Resize((225 * num_columns), (31 * max_rows) + 10);
					popup_menu_uic:SetMoveable(true);
					popup_menu_uic:MoveTo(popup_menuX - ((boundsX * num_columns) / 2), popup_menuY);
					popup_menu_uic:SetMoveable(false);

					popup_listX, popup_listY = popup_list_uic:Position(); -- Reset pos.
					
					for i = 1, popup_list_uic:ChildCount() do
						local uic = UIComponent(popup_list_uic:Find("option"..tostring(i - 1)));

						if i > 1 then
							row = row + 1;

							if row % max_rows == 1 then
								column = column + 1;
								row = 1;
							end
						end

						uic:SetMoveable(true);
						uic:MoveTo(popup_listX - boundsX + (boundsX * column), popup_listY + (boundsY * (row - 1)));
						uic:SetMoveable(false);
						uic:SetVisible(true);
					end
				end,
				1
			);
		elseif UIComponent(UIComponent(context.component):Parent())  then
			local parent_id = UIComponent(UIComponent(context.component):Parent()):Id();
		
			if parent_id == "army_box" or parent_id == "units_box" then
				ChangeUnitStatsLayout();
			end
		elseif context.string == "tab_unit_info" then
			ChangeUnitStatsLayout();
		end
	end
end

function OnComponentMouseOn_MK1212_Frontend(context)
	if context.string == "button_campaign" then
		tm:callback(
			function() 
				ChangeCampaignsPanel();
			end, 
			1
		);
	elseif UIComponent(UIComponent(context.component):Parent())  then
		local parent_id = UIComponent(UIComponent(context.component):Parent()):Id();
	
		if parent_id == "army_box" or parent_id == "units_box" then
			ChangeUnitStatsLayout();
		end
	elseif context.string == "tab_unit_info" then
		ChangeUnitStatsLayout();
	end
end

function ChangeCampaignsPanel()
	local campaign_menu_uic = UIComponent(m_root:Find("campaign_menu"));

	if campaign_menu_uic then
		campaign_menu_uic:Resize(300, 230);
		local button_load_campaign_uic = UIComponent(m_root:Find("button_load_campaign"));
		local button_dlc_campaign_1_uic = UIComponent(m_root:Find("button_dlc_campaign_1"));
		local button_dlc_campaign_2_uic = UIComponent(m_root:Find("button_dlc_campaign_2"));
		local button_new_campaign_uic = UIComponent(m_root:Find("button_new_campaign"));
		local button_multiplayer_campaign_uic = UIComponent(m_root:Find("button_multiplayer_campaign"));
		local curX, curY = button_load_campaign_uic:Position();

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
end

function ChangeEffects()
	local sp_grand_campaign_uic = UIComponent(m_root:Find("sp_grand_campaign"));
	local tx_header_uic = UIComponent(sp_grand_campaign_uic:Find("tx_header"));
	local tx_factions_uic = UIComponent(sp_grand_campaign_uic:Find("tx_factions"));
	local effects_uic = UIComponent(sp_grand_campaign_uic:Find("effects"));
	local effects_dlc_uic = UIComponent(sp_grand_campaign_uic:Find("effects_dlc"));
	local leader_window_uic = UIComponent(sp_grand_campaign_uic:Find("3D_window"));
	local curX, curY = leader_window_uic:Position();
	local max_columns = 20;
	local spacing = 67;
	local factions = {};

	curX = curX + 34; -- I made some changes to the leader window's bounds and I'm too lazy to go fix all the offsets now.

	tx_header_uic:SetStateText(FRONTEND_STRINGS["campaign_title_"..tostring(CHAPTER_SELECTED)]);

	if CHAPTER_SELECTED == 1 then
		local faction_button_group_uic = UIComponent(m_root:Find("faction_button_group"));
		local att_fact_group_roman_uic = UIComponent(m_root:Find("att_fact_group_roman"));
		local col = 0;
		local row = 1;
		local row_offset = 0;

		att_fact_group_roman_uic:SetVisible(false);

		--Alphabetically sort the factions.
		for i = 0, faction_button_group_uic:ChildCount() - 1 do
			local faction_uic = UIComponent(faction_button_group_uic:Find(i));
			local faction_id = faction_uic:Id();

			table.insert(factions, faction_id);
		end

		table.sort(factions);

		for i = 1, #factions do
			local faction_uic = UIComponent(faction_button_group_uic:Find(factions[i]));
			faction_uic:SetMoveable(true);

			col = col + 1;

			if col > max_columns then
				if #factions - i < max_columns then
					row_offset = (spacing / 2) * (max_columns - (#factions - (i - 1)));
				end

				col = 1;
				row = row + 1;
			end

			faction_uic:MoveTo(curX - 562 + (spacing * col) + row_offset, curY - (249 - spacing * (row - 1)));
			faction_uic:SetMoveable(false);
 		end

		local faction_details_parent_uic = UIComponent(m_root:Find("faction_details_parent"));
		faction_details_parent_uic:Resize(436, 616);
		tx_factions_uic:SetStateText("Faction");
	elseif CHAPTER_SELECTED == 2 then	
		local faction_group_button_group_uic = UIComponent(m_root:Find("faction_group_button_group"));
		local att_fact_group_barbarian_m_uic = UIComponent(m_root:Find("att_fact_group_barbarian_m"));
		local col = 0;
		local row = 1;

		att_fact_group_barbarian_m_uic:SetVisible(false);

		--Alphabetically sort the factions.
		for i = 0, faction_button_group_uic:ChildCount() - 1 do
			local faction_uic = UIComponent(faction_button_group_uic:Find(i));
			local faction_id = faction_uic:Id();

			table.insert(factions, faction_id);
		end

		table.sort(factions);

		for i = 1, #factions do
			local faction_uic = UIComponent(faction_group_button_group_uic:Find(factions[i]));

			UIComponent(faction_uic:Find("label")):SetVisible(false);
			UIComponent(faction_uic:Find("icon_new_content")):SetVisible(false);
			faction_uic:SetMoveable(true);

			col = col + 1;

			if col > max_columns then
				col = 1;
				row = row + 1;
			end

			faction_uic:MoveTo(curX - 562 + (spacing * col), curY - (249 - spacing * (row - 1)));
			faction_uic:SetMoveable(false);
		 end
		 
		effects_uic:SetVisible(true);

		local faction_details_parent_uic = UIComponent(m_root:Find("faction_details_parent"));
		faction_details_parent_uic:Resize(436, 465);
	end

	-- Left Side
	local tx_faction_leader_uic = UIComponent(m_root:Find("tx_faction_leader"));
	local dy_faction_leader_uic = UIComponent(m_root:Find("dy_faction_leader"));
	local tx_religion_uic = UIComponent(m_root:Find("tx_religion"));
	local dy_religion_uic = UIComponent(m_root:Find("dy_religion"));
	local header_faction_uic = UIComponent(m_root:Find("header_faction"));
	local header_cultural_uic = UIComponent(m_root:Find("header_cultural"));
	local effect_description_window_uic = UIComponent(m_root:Find("effect_description_window"));
	local faction_trait_icon_uic = UIComponent(m_root:Find("faction_trait_icon"));
	local entries_window_uic = UIComponent(m_root:Find("entries_window"));
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
	effect_description_window_uic:SetMoveable(true);
	effect_description_window_uic:MoveTo(curX - 338, curY + 81);
	effect_description_window_uic:SetMoveable(false);
	entries_window_uic:SetVisible(false);
	
	-- Right Side
	local maps_uic = UIComponent(m_root:Find("maps"));
	local map_rome_uic = find_uicomponent_by_table(m_root, {"sp_grand_campaign", "docker", "details_panel", "maps", "map_rome"});
	local maps_frame_uic = find_uicomponent_by_table(m_root, {"sp_grand_campaign", "docker", "details_panel", "maps", "map_rome", "frame"});
	local difficulty_hbar_uic = find_uicomponent_by_table(m_root, {"sp_grand_campaign", "docker", "details_panel", "hbar"});
	local difficulty_uic = UIComponent(m_root:Find("dy_clan_difficulty"));
	local initial_challenge_uic = UIComponent(m_root:Find("tx_initial_challenge:"));
	local start_year_uic = UIComponent(m_root:Find("dy_start_year")); 
	local icon_date_uic = UIComponent(m_root:Find("icon_date"));
	local effect_title_uic = UIComponent(m_root:Find("effect_title"));
	local text_version_number_uic = UIComponent(m_root:Find("version_number"));
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
end

function ChangeUnitStatsLayout()
	-- Odd stats go left, even go right.
	local dynamic_stats_uic = find_uicomponent_by_table(m_root, {"battle_setup", "dock_area", "main", "panel_battle_setup", "settings_info_tab_group", "tab_unit_info", "tab_child", "unit_info_background", "unit_info", "details", "dynamic_stats"});
	local dynamic_stats_uicX, dynamic_stats_uicY = dynamic_stats_uic:Position();
	local row = 0;

	if dynamic_stats_uic  then
		for i = 0, dynamic_stats_uic:ChildCount() - 1 do
			local stat_uic = UIComponent(dynamic_stats_uic:Find(i));

			stat_uic:SetMoveable(true);

			if ((i + 1) % 2 == 0) then
				stat_uic:MoveTo(dynamic_stats_uicX + 214, dynamic_stats_uicY + (24 * row));
				row = row + 1;
			else
				stat_uic:MoveTo(dynamic_stats_uicX, dynamic_stats_uicY + (24 * row));
			end

			stat_uic:SetMoveable(false);
		end
	end
end
