---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - FRONTEND SCRIPTS
-- 	By: DETrooper
--
---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------
-- At some point I should do all the UI translations via hex-editing so there isn't this disgusting mess of code.

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
version_number = 2300;
version_number_string = "v2.4.0.0";

local checkbox_lucky_nations_selected = false;

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

require("lua_scripts/frontend_cb_crash_fix");
require("lua_scripts/frontend_challenges");
require("lua_scripts/frontend_changelog");
--require("lua_scripts/frontend_disclaimer");
require("lua_scripts/frontend_discord");
--require("lua_scripts/frontend_hbs"); -- There are no historical battles for MK1212 yet.
require("lua_scripts/frontend_mp_campaign");
require("lua_scripts/frontend_pack_check");
require("lua_scripts/frontend_start_date");
require("lua_scripts/frontend_strings");

function OnUICreated_MK1212_Frontend(context)
	if context then
		m_root = UIComponent(context.component);

		ChangeFrontend(context);
	end
end

function ChangeFrontend(context)
	--local button_historical_battle_uic = UIComponent(m_root:Find("button_historical_battle"));
	local text_version_number_uic = UIComponent(m_root:Find("version_number"));

	-- Not sure why but this seems to be causing a crash. Hex-edited sp_frame to make it start as inactive for now.
	--[[if button_historical_battle_uic then
		button_historical_battle_uic:SetState("inactive");
	end]]--

	if text_version_number_uic then
		text_version_number_uic:SetStateText(FRONTEND_STRINGS["text_version_string"]..version_number_string);
	end

	svr:SaveBool("SBOOL_IRONMAN_ENABLED", false);
	svr:SaveBool("SBOOL_LUCKY_NATIONS_ENABLED", false);

	checkbox_lucky_nations_selected = false;
end

function OnComponentLClickUp_MK1212_Frontend(context)
	if string.find(context.string, "button_start_date") or string.find(context.string, "att_fact_group") then
		tm:callback(
			function()
				ChangeCampaignMenu();
			end, 
			1
		);
	elseif string.find(context.string, "mk_fact") or string.find(context.string, "att_fact") then
		ChangeCampaignMenuFaction(context.string);
	elseif context.string == "checkbox_ironman" then
		if UIComponent(context.component):CurrentState() == "selected_down" or UIComponent(context.component):CurrentState() == "active" then
			svr:SaveBool("SBOOL_IRONMAN_ENABLED", false);

			if checkbox_lucky_nations_selected == true then
				UIComponent(m_root:Find("checkbox_lucky_nations")):SetState("selected");
			else
				svr:SaveBool("SBOOL_LUCKY_NATIONS_ENABLED", false);

				UIComponent(m_root:Find("checkbox_lucky_nations")):SetState("active");
			end
		elseif UIComponent(context.component):CurrentState() == "down" or UIComponent(context.component):CurrentState() == "selected" then
			svr:SaveBool("SBOOL_IRONMAN_ENABLED", true);
			svr:SaveBool("SBOOL_LUCKY_NATIONS_ENABLED", true);

			UIComponent(m_root:Find("checkbox_lucky_nations")):SetState("selected_inactive");
		end
	elseif context.string == "checkbox_lucky_nations" then
		if UIComponent(context.component):CurrentState() == "selected_down" or UIComponent(context.component):CurrentState() == "active" then
			svr:SaveBool("SBOOL_LUCKY_NATIONS_ENABLED", false);

			checkbox_lucky_nations_selected = false;
		elseif UIComponent(context.component):CurrentState() == "down" or UIComponent(context.component):CurrentState() == "selected" then
			svr:SaveBool("SBOOL_LUCKY_NATIONS_ENABLED", true);

			checkbox_lucky_nations_selected = true;
		end
	elseif context.string == "button_random_faction" then
		SelectRandomFaction();
	end

	-- For custom battles. There's a hardcoded limit apparently on how many columns of factions display leading to a UI overflow off screen, so that needs to be fixed manually.
	if UIComponent(m_root:Find("battle_setup")):Visible() then
		if context.string == "button_change_faction" or context.string == "faction_dropdown" then
			tm:callback(
				function() 
					local battle_setup_uic = UIComponent(m_root:Find("battle_setup"));
					local faction_dropdown_uic = UIComponent(battle_setup_uic:Find("faction_dropdown"));

					if faction_dropdown_uic then
						local popup_menu_uic = UIComponent(faction_dropdown_uic:Find("popup_menu"));
						local popup_list_uic = UIComponent(popup_menu_uic:Find("popup_list"))
						local delay = (popup_list_uic:ChildCount() * 11) - 100;

						if popup_menu_uic and popup_menu_uic:Visible() then
							tm:callback(
								function() 
									local faction_dropdown_uic = UIComponent(m_root:Find("faction_dropdown"));

									if faction_dropdown_uic then
										local popup_menu_uic = UIComponent(faction_dropdown_uic:Find("popup_menu"));

										if popup_menu_uic and popup_menu_uic:Visible() then
											local popup_list_uic = UIComponent(popup_menu_uic:Find("popup_list"));
											local popup_menuX, popup_menuY = popup_menu_uic:Position();
											local popup_listX, popup_listY = popup_list_uic:Position();

											local boundsX = 225;
											local boundsY = 30;
											local column = 1;
											local row = 1;
											local max_rows = 18;
											local num_columns = math.ceil(popup_list_uic:ChildCount() / max_rows);

											if popup_list_uic:ChildCount() < max_rows then
												max_rows = popup_list_uic:ChildCount();
											end

											popup_menu_uic:Resize((225 * num_columns), (30 * max_rows) + 12);
											--popup_menu_uic:SetMoveable(true);
											--popup_menu_uic:MoveTo(popup_menuX - ((boundsX * num_columns) / 2), popup_menuY);
											--popup_menu_uic:SetMoveable(false);

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
										end
									end
								end,
								delay
							);
						end
					end
				end,
				100
			);
		elseif UIComponent(UIComponent(context.component):Parent()) then
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
	if UIComponent(UIComponent(context.component):Parent()) then
		local parent_id = UIComponent(UIComponent(context.component):Parent()):Id();
	
		if parent_id == "army_box" or parent_id == "units_box" then
			ChangeUnitStatsLayout();
		end
	elseif context.string == "tab_unit_info" then
		ChangeUnitStatsLayout();
	end
end

function ChangeCampaignMenu()
	local sp_grand_campaign_uic = UIComponent(m_root:Find("sp_grand_campaign"));
	local tx_header_uic = UIComponent(sp_grand_campaign_uic:Find("tx_header"));
	local tx_factions_uic = UIComponent(sp_grand_campaign_uic:Find("tx_factions"));
	local effects_uic = UIComponent(sp_grand_campaign_uic:Find("effects"));
	local effects_dlc_uic = UIComponent(sp_grand_campaign_uic:Find("effects_dlc"));
	local leader_window_uic = UIComponent(sp_grand_campaign_uic:Find("3D_window"));
	local faction_details_parent_uic = UIComponent(sp_grand_campaign_uic:Find("faction_details_parent"));
	local button_start_campaign_uic = UIComponent(sp_grand_campaign_uic:Find("button_start_campaign"));
	local start_year_uic = UIComponent(sp_grand_campaign_uic:Find("dy_start_year"));
	local curX, curY = leader_window_uic:Position();
	local max_columns = 20;
	local spacing = 67;
	local factions = {};

	curX = curX + 34; -- I made some changes to the leader window's bounds and I'm too lazy to go fix all the offsets now.

	tx_header_uic:SetStateText(FRONTEND_STRINGS["campaign_title_"..tostring(CAMPAIGN_START_DATE_SELECTED)]);

	if CAMPAIGN_START_DATE_SELECTED == 1 then
		local faction_button_group_uic = UIComponent(sp_grand_campaign_uic:Find("faction_button_group"));
		local att_fact_group_roman_uic = UIComponent(sp_grand_campaign_uic:Find("att_fact_group_roman"));
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

		faction_details_parent_uic:Resize(436, 616);
		tx_factions_uic:SetStateText("Faction");
		start_year_uic:Resize(400, 64);
	elseif CAMPAIGN_START_DATE_SELECTED == 2 then	
		local faction_group_button_group_uic = UIComponent(sp_grand_campaign_uic:Find("faction_group_button_group"));
		local att_fact_group_barbarian_m_uic = UIComponent(sp_grand_campaign_uic:Find("att_fact_group_barbarian_m"));
		local button_purchase_uic = UIComponent(sp_grand_campaign_uic:Find("button_purchase"));
		local col = 0;
		local row = 1;

		att_fact_group_barbarian_m_uic:SetVisible(false);

		--Alphabetically sort the factions.
		for i = 0, faction_group_button_group_uic:ChildCount() - 1 do
			local faction_uic = UIComponent(faction_group_button_group_uic:Find(i));
			local faction_id = faction_uic:Id();

			if not string.find(faction_id, "att_fact_group") then
				table.insert(factions, faction_id);
			end
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
		 
		button_start_campaign_uic:SetVisible(true);
		button_purchase_uic:SetVisible(false);
		effects_uic:SetVisible(true);
		faction_details_parent_uic:Resize(436, 616);
		start_year_uic:Resize(400, 64);
	end

	-- Left Side
	local tx_faction_leader_uic = UIComponent(sp_grand_campaign_uic:Find("tx_faction_leader"));
	local dy_faction_leader_uic = UIComponent(sp_grand_campaign_uic:Find("dy_faction_leader"));
	local tx_religion_uic = UIComponent(sp_grand_campaign_uic:Find("tx_religion"));
	local dy_religion_uic = UIComponent(sp_grand_campaign_uic:Find("dy_religion"));
	local header_faction_uic = UIComponent(sp_grand_campaign_uic:Find("header_faction"));
	local header_cultural_uic = UIComponent(sp_grand_campaign_uic:Find("header_cultural"));
	local effect_description_window_uic = UIComponent(sp_grand_campaign_uic:Find("effect_description_window"));
	local faction_trait_icon_uic = UIComponent(sp_grand_campaign_uic:Find("faction_trait_icon"));
	local entries_window_uic = UIComponent(sp_grand_campaign_uic:Find("entries_window"));
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
	local maps_uic = UIComponent(sp_grand_campaign_uic:Find("maps"));
	local map_rome_uic = find_uicomponent_by_table(m_root, {"sp_grand_campaign", "docker", "details_panel", "maps", "map_rome"});
	local maps_frame_uic = find_uicomponent_by_table(m_root, {"sp_grand_campaign", "docker", "details_panel", "maps", "map_rome", "frame"});
	local difficulty_hbar_uic = find_uicomponent_by_table(m_root, {"sp_grand_campaign", "docker", "details_panel", "hbar"});
	local difficulty_uic = UIComponent(sp_grand_campaign_uic:Find("dy_clan_difficulty"));
	local initial_challenge_uic = UIComponent(sp_grand_campaign_uic:Find("tx_initial_challenge:"));
	local icon_date_uic = UIComponent(sp_grand_campaign_uic:Find("icon_date"));
	local effect_title_uic = UIComponent(sp_grand_campaign_uic:Find("effect_title"));
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

	SelectRandomFaction();

	button_start_campaign_uic:SetInteractive(false);

	tm:callback(
		function() 
			if button_start_campaign_uic then
				button_start_campaign_uic:SetInteractive(true);
			end
		end,
		1000
	);
end

function ChangeCampaignMenuFaction(faction_name)
	local sp_grand_campaign_uic = UIComponent(m_root:Find("sp_grand_campaign"));
	local start_year_uic = UIComponent(sp_grand_campaign_uic:Find("dy_start_year"));
	local strength_text = "NOT FOUND";
	local weakness_text = "NOT FOUND";

	if FACTION_STRENGTHS[faction_name] then 
		strength_text = FACTION_STRENGTHS[faction_name];
	end

	if FACTION_WEAKNESSES[faction_name] then
		weakness_text = FACTION_WEAKNESSES[faction_name];
	end

	start_year_uic:SetVisible(true);
	start_year_uic:SetStateText("[[rgba:63:35:13:150]]"..FRONTEND_STRINGS["faction_strength"]..strength_text.."\n"..FRONTEND_STRINGS["faction_weakness"]..weakness_text.."[[/rgba:63:35:13:150]]");

	tm:callback(
		function()
			local sp_grand_campaign_uic = UIComponent(m_root:Find("sp_grand_campaign"));
			local effects_dlc_uic = UIComponent(sp_grand_campaign_uic:Find("effects_dlc"));
			local effect_description_window_uic = UIComponent(effects_dlc_uic:Find("effect_description_window"));
			local entries_window_uic = UIComponent(effects_dlc_uic:Find("entries_window"));
			local leader_window_uic = UIComponent(sp_grand_campaign_uic:Find("3D_window"));
			local curX, curY = leader_window_uic:Position();

			effects_dlc_uic:SetVisible(true);
			effects_dlc_uic:Resize(377, 40);
			effects_dlc_uic:SetMoveable(true);
			effects_dlc_uic:MoveTo(curX - 398, curY + 506);
			effects_dlc_uic:SetMoveable(false);
			effect_description_window_uic:SetMoveable(true);
			effect_description_window_uic:MoveTo(curX - 304, curY + 81);
			effect_description_window_uic:SetMoveable(false);
			entries_window_uic:SetVisible(false);

			if FACTION_POPULATIONS[faction_name] then
				effect_description_window_uic:SetStateText(FRONTEND_STRINGS["population"]..FACTION_POPULATIONS[faction_name]);
			else
				effect_description_window_uic:SetStateText(FRONTEND_STRINGS["population"].."NOT FOUND")
			end
		end,
		1
	);
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

function SelectRandomFaction()
	local sp_grand_campaign_uic = UIComponent(m_root:Find("sp_grand_campaign"));

	if CAMPAIGN_START_DATE_SELECTED == 1 then
		local faction_button_group_uic = UIComponent(sp_grand_campaign_uic:Find("faction_button_group"));
		local faction_id = math.random(faction_button_group_uic:ChildCount() - 1);
		local faction_uic = UIComponent(faction_button_group_uic:Find(faction_id));

		faction_uic:SimulateClick(); -- Click random faction.
		faction_uic:SetState("selected");
	else
		local faction_button_group_uic = UIComponent(sp_grand_campaign_uic:Find("faction_group_button_group"));
		local factions = {};

		for i = 0, faction_button_group_uic:ChildCount() - 1 do
			local faction_uic = UIComponent(faction_button_group_uic:Find(i));
			local faction_id = faction_uic:Id();

			table.insert(factions, faction_id);
		end

		local faction_id = factions[math.random(#factions)];
		local faction_uic = UIComponent(faction_button_group_uic:Find(faction_id));

		faction_uic:SimulateClick(); -- Click random faction.
		faction_uic:SetState("selected");
	end
end