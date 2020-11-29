-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: ANNEX VASSALS
-- 	By: DETrooper
--
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

ANNEX_TURN_REQUIREMENT = 20; -- How long until annexation can begin when you've made a new vassal?
ANNEX_TURNS_PER_REGION = 3; -- Once annexation process has started, how many turns per region should it take to complete?

FACTIONS_VASSALIZED_ANNEXING = {};
FACTIONS_VASSALIZED_ANNEXATION_TIME = {};
FACTIONS_VASSALIZED_DELAYS = {};

function Add_Annex_Vassals_Listeners()
	cm:add_listener(
		"FactionTurnStart_Annex",
		"FactionTurnStart",
		true,
		function(context) FactionTurnStart_Annex(context) end,
		true
	);
	cm:add_listener(
		"FactionUnvassalized_Annex",
		"FactionUnvassalized",
		true,
		function(context) FactionUnvassalized_Annex(context) end,
		true
	);
	cm:add_listener(
		"FactionVassalized_Annex",
		"FactionVassalized",
		true,
		function(context) FactionVassalized_Annex(context) end,
		true
	);
	cm:add_listener(
		"OnComponentMouseOn_Annex_UI",
		"ComponentMouseOn",
		true,
		function(context) OnComponentMouseOn_Annex_UI(context) end,
		true
	);
	cm:add_listener(
		"OnComponentLClickUp_Annex_UI",
		"ComponentLClickUp",
		true,
		function(context) OnComponentLClickUp_Annex_UI(context) end,
		true
	);
	cm:add_listener(
		"OnPanelOpenedCampaign_Annex_UI",
		"PanelOpenedCampaign",
		true,
		function(context) OnPanelOpenedCampaign_Annex_UI(context) end,
		true
	);
	cm:add_listener(
		"TimeTrigger_Annex_UI",
		"TimeTrigger",
		true,
		function(context) TimeTrigger_Annex_UI(context) end,
		true
	);

	if cm:is_new_game() then
		AnnexVassalsSetup();
	end
end

function AnnexVassalsSetup()
	local faction_list = cm:model():world():faction_list();

	for i = 0, faction_list:num_items() - 1 do
		local faction = faction_list:item_at(i);
		local faction_name = faction:name();

		FACTIONS_VASSALIZED_ANNEXING[faction_name] = false;

		if FACTIONS_VASSALIZED_ANNEXATION_TIME[faction_name] == nil then
			FACTIONS_VASSALIZED_ANNEXATION_TIME[faction_name] = -1;
		end

		if FACTIONS_TO_FACTIONS_VASSALIZED_START[faction_name] then
			for j = 1, #FACTIONS_TO_FACTIONS_VASSALIZED_START[faction_name] do
				local vassalized_faction_name = FACTIONS_TO_FACTIONS_VASSALIZED_START[faction_name][j];

				FACTIONS_VASSALIZED_ANNEXATION_TIME[vassalized_faction_name] = cm:model():world():faction_by_key(vassalized_faction_name):region_list():num_items() * ANNEX_TURNS_PER_REGION;
				FACTIONS_VASSALIZED_DELAYS[vassalized_faction_name] = ANNEX_TURN_REQUIREMENT;
			end
		end
	end
end

function FactionTurnStart_Annex(context)
	local faction_name = context:faction():name();
	local faction_is_human = context:faction():is_human();

	if FACTIONS_TO_FACTIONS_VASSALIZED[faction_name] == nil then
		FACTIONS_TO_FACTIONS_VASSALIZED[faction_name] = {};
	end

	for k, v in pairs(FACTIONS_VASSALIZED_DELAYS) do
		if HasValue(FACTIONS_TO_FACTIONS_VASSALIZED[faction_name], k) then
			if v > 0 then
				FACTIONS_VASSALIZED_DELAYS[k] = v - 1;
			end
		end
	end

	for i = 1, #FACTIONS_TO_FACTIONS_VASSALIZED[faction_name] do
		local vassalized_faction_name = FACTIONS_TO_FACTIONS_VASSALIZED[faction_name][i];
		local vassal_faction = cm:model():world():faction_by_key(vassalized_faction_name);

		if FACTIONS_VASSALIZED_ANNEXATION_TIME[vassalized_faction_name] == nil or FACTIONS_VASSALIZED_ANNEXING[vassalized_faction_name] == false then
			FACTIONS_VASSALIZED_ANNEXATION_TIME[vassalized_faction_name] = vassal_faction:region_list():num_items() * ANNEX_TURNS_PER_REGION;
		end

		if FACTIONS_VASSALIZED_ANNEXING[vassalized_faction_name] == true then
			local annexation_turns_left = FACTIONS_VASSALIZED_ANNEXATION_TIME[vassalized_faction_name];

			if vassal_faction:has_home_region() == true then
				if annexation_turns_left > 0 then
					FACTIONS_VASSALIZED_ANNEXATION_TIME[vassalized_faction_name] = annexation_turns_left - 1;
				end

				if FACTIONS_VASSALIZED_ANNEXATION_TIME[vassalized_faction_name] == 0 then
					cm:grant_faction_handover(faction_name, vassalized_faction_name, cm:model():turn_number() - 1, cm:model():turn_number() - 1, context);
					
					local faction_string = "factions_screen_name_"..vassalized_faction_name;

					if FACTIONS_DFN_LEVEL[vassalized_faction_name]  then
						if FACTIONS_DFN_LEVEL[vassalized_faction_name] > 1 then
							faction_string = "campaign_localised_strings_string_"..vassalized_faction_name.."_lvl"..tostring(FACTIONS_DFN_LEVEL[vassalized_faction_name]);
						end
					end

					cm:show_message_event(
						faction_name,
						"message_event_text_text_mk_event_annexed_vassal_title",
						faction_string,
						"message_event_text_text_mk_event_annexed_vassal_secondary",
						true,
						704
					);

					for i = 1, #FACTIONS_TO_FACTIONS_VASSALIZED[faction_name] do
						if FACTIONS_TO_FACTIONS_VASSALIZED[faction_name][i] == vassalized_faction_name then
							table.remove(FACTIONS_TO_FACTIONS_VASSALIZED[faction_name], i);
							break;
						end
					end

					Stop_Annexing_Vassal(faction_name, vassalized_faction_name);
				end
			else
				local faction_string = "factions_screen_name_"..vassalized_faction_name;

				if FACTIONS_DFN_LEVEL[vassalized_faction_name]  then
					if FACTIONS_DFN_LEVEL[vassalized_faction_name] > 1 then
						faction_string = "campaign_localised_strings_string_"..vassalized_faction_name.."_lvl"..tostring(FACTIONS_DFN_LEVEL[vassalized_faction_name]);
					end
				end

				cm:show_message_event(
					faction_name,
					"message_event_text_text_mk_event_annexation_aborted_title",
					faction_string,
					"message_event_text_text_mk_event_annexation_aborted_secondary",
					true,
					704
				);

				for i = 1, #FACTIONS_TO_FACTIONS_VASSALIZED[faction_name] do
					if FACTIONS_TO_FACTIONS_VASSALIZED[faction_name][i] == vassalized_faction_name then
						table.remove(FACTIONS_TO_FACTIONS_VASSALIZED[faction_name], i);
						break;
					end
				end

				Stop_Annexing_Vassal(faction_name, vassalized_faction_name);
			end
		elseif not faction_is_human and not vassal_faction:is_human() then
			if FACTIONS_VASSALIZED_DELAYS[vassalized_faction_name] == 0 and not Get_Vassal_Currently_Annexing(faction_name) then
				-- Todo: Add personality check?

				Start_Annexing_Vassal(faction_name, vassalized_faction_name);
			end
		end
	end
end

function FactionUnvassalized_Annex(context)
	local master_faction_name = context:faction():name();
	local vassalized_faction_name = context:other_faction():name();

	if FACTIONS_VASSALIZED_ANNEXING[vassalized_faction_name] == true then
		local faction_string = "factions_screen_name_"..vassalized_faction_name;

		if FACTIONS_DFN_LEVEL[vassalized_faction_name]  then
			if FACTIONS_DFN_LEVEL[vassalized_faction_name] > 1 then
				faction_string = "campaign_localised_strings_string_"..vassalized_faction_name.."_lvl"..tostring(FACTIONS_DFN_LEVEL[vassalized_faction_name]);
			end
		end

		if context:faction():is_human() then
			cm:show_message_event(
				master_faction_name,
				"message_event_text_text_mk_event_annexation_aborted_title",
				faction_string,
				"message_event_text_text_mk_event_annexation_aborted_secondary",
				true,
				704
			);
		end

		Stop_Annexing_Vassal(master_faction_name, vassalized_faction_name);
	else
		FACTIONS_VASSALIZED_DELAYS[vassalized_faction_name] = nil;
	end
end

function FactionVassalized_Annex(context)
	local master_faction_name = context:faction():name();
	local vassalized_faction_name = context:other_faction():name();

	FACTIONS_VASSALIZED_ANNEXING[vassalized_faction_name] = false;
	FACTIONS_VASSALIZED_ANNEXATION_TIME[vassalized_faction_name] = context:other_faction():region_list():num_items() * ANNEX_TURNS_PER_REGION;
	FACTIONS_VASSALIZED_DELAYS[vassalized_faction_name] = ANNEX_TURN_REQUIREMENT;
end

function OnComponentMouseOn_Annex_UI(context)
	if context.string == "button_annex_vassal" then
		local faction_name = cm:get_local_faction();
		local vassal_string = Get_DFN_Localisation(DIPLOMACY_SELECTED_FACTION);
		local cost = "n";
		local turns = "n";

		if HasValue(FACTIONS_TO_FACTIONS_VASSALIZED[faction_name], DIPLOMACY_SELECTED_FACTION) then
			if FACTIONS_VASSALIZED_ANNEXING[DIPLOMACY_SELECTED_FACTION] == false then
				for i = 1, #ANNEX_VASSALS_SIZES do
					if cm:model():world():faction_by_key(DIPLOMACY_SELECTED_FACTION):region_list():num_items() >= tonumber(ANNEX_VASSALS_SIZES[i]) then
						cost = ANNEX_VASSALS_PERCENTAGES[i];
						break;
					end
				end

				turns = FACTIONS_VASSALIZED_ANNEXATION_TIME[DIPLOMACY_SELECTED_FACTION];

				UIComponent(context.component):SetTooltipText(UI_LOCALISATION["annex_vassal_tooltip_pt1"]..vassal_string..UI_LOCALISATION["annex_vassal_tooltip_pt2"]..cost..UI_LOCALISATION["annex_vassal_tooltip_pt3"]..turns..UI_LOCALISATION["annex_vassal_tooltip_pt4"]);
			else
				UIComponent(context.component):SetTooltipText(UI_LOCALISATION["annex_vassal_annexing_tooltip_pt1"]..vassal_string..UI_LOCALISATION["annex_vassal_annexing_tooltip_pt2"]..FACTIONS_VASSALIZED_ANNEXATION_TIME[DIPLOMACY_SELECTED_FACTION]..UI_LOCALISATION["annex_vassal_annexing_tooltip_pt3"]);
			end
		else
			UIComponent(context.component):SetTooltipText(UI_LOCALISATION["annex_vassal_not_vassal_tooltip_pt1"]..vassal_string..UI_LOCALISATION["annex_vassal_not_vassal_tooltip_pt2"]);
		end
	elseif string.find(context.string, "mk_bundle_annex_vassal_regions_") then
		local vassalized_faction_name = Get_Vassal_Currently_Annexing(cm:get_local_faction());
		local root = cm:ui_root();
		local TechTooltipPopup = UIComponent(root:Find("TechTooltipPopup"));
		local description_window_uic = UIComponent(TechTooltipPopup:Find("description_window"));
		local vassal_string = Get_DFN_Localisation(vassalized_faction_name);

		description_window_uic:SetStateText(UI_LOCALISATION["annex_vassal_bundle_tooltip_pt1"]..vassal_string..UI_LOCALISATION["annex_vassal_bundle_tooltip_pt2"]..tostring(FACTIONS_VASSALIZED_ANNEXATION_TIME[vassalized_faction_name]));
	end
end

function OnComponentLClickUp_Annex_UI(context)
	if context.string == "button_annex_vassal" then
		local faction_name = cm:get_local_faction();

		if FACTIONS_VASSALIZED_ANNEXING[DIPLOMACY_SELECTED_FACTION] == false then
			Start_Annexing_Vassal(faction_name, DIPLOMACY_SELECTED_FACTION);
		else
			local faction_string = "factions_screen_name_"..DIPLOMACY_SELECTED_FACTION;

			if FACTIONS_DFN_LEVEL[DIPLOMACY_SELECTED_FACTION]  then
				if FACTIONS_DFN_LEVEL[DIPLOMACY_SELECTED_FACTION] > 1 then
					faction_string = "campaign_localised_strings_string_"..DIPLOMACY_SELECTED_FACTION.."_lvl"..tostring(FACTIONS_DFN_LEVEL[DIPLOMACY_SELECTED_FACTION]);
				end
			end

			cm:show_message_event(
				faction_name,
				"message_event_text_text_mk_event_annexation_aborted_title",
				faction_string,
				"message_event_text_text_mk_event_annexation_aborted_secondary_manual",
				true,
				704
			);

			Stop_Annexing_Vassal(faction_name, DIPLOMACY_SELECTED_FACTION);
		end

		local vassal_string = Get_DFN_Localisation(DIPLOMACY_SELECTED_FACTION);
		local cost = "n";
		local turns = "n";

		if HasValue(FACTIONS_TO_FACTIONS_VASSALIZED[faction_name], DIPLOMACY_SELECTED_FACTION) then
			if FACTIONS_VASSALIZED_ANNEXING[DIPLOMACY_SELECTED_FACTION] == false then
				for i = 1, #ANNEX_VASSALS_SIZES do
					if cm:model():world():faction_by_key(DIPLOMACY_SELECTED_FACTION):region_list():num_items() >= tonumber(ANNEX_VASSALS_SIZES[i]) then
						cost = ANNEX_VASSALS_PERCENTAGES[i];
						break;
					end
				end

				turns = FACTIONS_VASSALIZED_ANNEXATION_TIME[DIPLOMACY_SELECTED_FACTION];

				UIComponent(context.component):SetStateText("");
				UIComponent(context.component):SetTooltipText(UI_LOCALISATION["annex_vassal_tooltip_pt1"]..vassal_string..UI_LOCALISATION["annex_vassal_tooltip_pt2"]..cost..UI_LOCALISATION["annex_vassal_tooltip_pt3"]..turns..UI_LOCALISATION["annex_vassal_tooltip_pt4"]);
			else
				UIComponent(context.component):SetStateText("");
				UIComponent(context.component):SetTooltipText(UI_LOCALISATION["annex_vassal_annexing_tooltip_pt1"]..vassal_string..UI_LOCALISATION["annex_vassal_annexing_tooltip_pt2"]..FACTIONS_VASSALIZED_ANNEXATION_TIME[DIPLOMACY_SELECTED_FACTION]..UI_LOCALISATION["annex_vassal_annexing_tooltip_pt3"]);
			end
		else
			UIComponent(context.component):SetStateText("");
			UIComponent(context.component):SetTooltipText(UI_LOCALISATION["annex_vassal_not_vassal_tooltip_pt1"]..vassal_string..UI_LOCALISATION["annex_vassal_not_vassal_tooltip_pt2"]);
		end
	elseif DIPLOMACY_PANEL_OPEN == true then
		if context.string == "map" or context.string == "button_icon" or context.string == "flag" or string.find(context.string, "faction_row_entry_") then
			local root = cm:ui_root();
			local diplomacy_dropdown_uic = UIComponent(root:Find("diplomacy_dropdown"));
			local button_annex_vassal_uic = UIComponent(diplomacy_dropdown_uic:Find("button_annex_vassal"));

			button_annex_vassal_uic:SetStateText("");
			button_annex_vassal_uic:SetState("inactive");

			cm:add_time_trigger("annex_diplo_hud_check", 0.1);
		end
	end
end

function OnPanelOpenedCampaign_Annex_UI(context)
	if context.string == "diplomacy_dropdown" then
		cm:add_time_trigger("annex_diplo_hud_check", 0.1);
	end
end

function TimeTrigger_Annex_UI(context)
	if context.string == "annex_diplo_hud_check" then
		local root = cm:ui_root();
		local diplomacy_dropdown_uic = UIComponent(root:Find("diplomacy_dropdown"));
		local button_annex_vassal_uic = UIComponent(diplomacy_dropdown_uic:Find("button_annex_vassal"));
		--local faction_left_status_panel_uic = UIComponent(diplomacy_dropdown_uic:Find("faction_left_status_panel"));
		--local diplomatic_relations_uic = UIComponent(faction_left_status_panel_uic:Find("diplomatic_relations"));
		--local icon_vassals_uic = UIComponent( diplomatic_relations_uic:Find("icon_vassals"));
	
		local annexing_faction = Get_Vassal_Currently_Annexing(cm:get_local_faction());

		button_annex_vassal_uic:SetState("inactive");
		button_annex_vassal_uic:SetVisible(true);

		if not annexing_faction or annexing_faction == DIPLOMACY_SELECTED_FACTION then
			if FACTIONS_VASSALIZED_ANNEXING[DIPLOMACY_SELECTED_FACTION] == false then
				if HasValue(FACTIONS_TO_FACTIONS_VASSALIZED[cm:get_local_faction()], DIPLOMACY_SELECTED_FACTION) then
					DIPLOMACY_SELECTED_FACTION = DIPLOMACY_SELECTED_FACTION;
		
					if FACTIONS_VASSALIZED_DELAYS[DIPLOMACY_SELECTED_FACTION] == 0 then
						button_annex_vassal_uic:SetState("active"); 
					else
						button_annex_vassal_uic:SetStateText(tostring(FACTIONS_VASSALIZED_DELAYS[DIPLOMACY_SELECTED_FACTION]));
					end
				end
			elseif HasValue(FACTIONS_TO_FACTIONS_VASSALIZED[cm:get_local_faction()], DIPLOMACY_SELECTED_FACTION) then
				button_annex_vassal_uic:SetState("active");
			end
		end

		-- (Doesn't work) Having a true vassal (i.e. one released using the buffer state mechanic) will overwrite client states on the UI, so we need to fix that.
		--[[if icon_vassals_uic:CurrentState() == "vassal" then
			icon_vassals_uic:SetState("client_state");
		end]]--
	end
end

function Start_Annexing_Vassal(master_faction_name, vassalized_faction_name)
	if not Get_Vassal_Currently_Annexing(master_faction_name) then
		FACTIONS_VASSALIZED_ANNEXING[vassalized_faction_name] = true;

		for i = 1, #ANNEX_VASSALS_SIZES do
			if cm:model():world():faction_by_key(vassalized_faction_name):region_list():num_items() >= tonumber(ANNEX_VASSALS_SIZES[i]) then
				cm:apply_effect_bundle("mk_bundle_annex_vassal_regions_"..ANNEX_VASSALS_SIZES[i], master_faction_name, 0);
				break;
			end
		end
	end
end

function Stop_Annexing_Vassal(master_faction_name, vassalized_faction_name)
	FACTIONS_VASSALIZED_ANNEXING[vassalized_faction_name] = false;

	if FactionIsAlive(vassalized_faction_name) then
		FACTIONS_VASSALIZED_ANNEXATION_TIME[vassalized_faction_name] = cm:model():world():faction_by_key(vassalized_faction_name):region_list():num_items() * ANNEX_TURNS_PER_REGION;
	else
		FACTIONS_VASSALIZED_ANNEXATION_TIME[vassalized_faction_name] = -1;
	end

	for i = 1, #ANNEX_VASSALS_SIZES do
		cm:remove_effect_bundle("mk_bundle_annex_vassal_regions_"..ANNEX_VASSALS_SIZES[i], master_faction_name);
	end
end

function Get_Vassal_Currently_Annexing(faction_name)
	if FACTIONS_TO_FACTIONS_VASSALIZED[faction_name] == nil then
		FACTIONS_TO_FACTIONS_VASSALIZED[faction_name] = {};

		return;
	end

	for i = 1, #FACTIONS_TO_FACTIONS_VASSALIZED[faction_name] do
		local vassalized_faction_name = FACTIONS_TO_FACTIONS_VASSALIZED[faction_name][i];

		if FACTIONS_VASSALIZED_ANNEXING[vassalized_faction_name] == true then
			return vassalized_faction_name;
		end
	end
end

------------------------------------------------
---------------- Saving/Loading ----------------
------------------------------------------------
cm:register_loading_game_callback(
	function(context)
		FACTIONS_VASSALIZED_ANNEXING = LoadBooleanPairTable(context, "FACTIONS_VASSALIZED_ANNEXING");
		FACTIONS_VASSALIZED_ANNEXATION_TIME = LoadKeyPairTableNumbers(context, "FACTIONS_VASSALIZED_ANNEXATION_TIME");
		FACTIONS_VASSALIZED_DELAYS = LoadKeyPairTableNumbers(context, "FACTIONS_VASSALIZED_DELAYS");
	end
);

cm:register_saving_game_callback(
	function(context)
		SaveBooleanPairTable(context, FACTIONS_VASSALIZED_ANNEXING, "FACTIONS_VASSALIZED_ANNEXING");
		SaveKeyPairTable(context, FACTIONS_VASSALIZED_ANNEXATION_TIME, "FACTIONS_VASSALIZED_ANNEXATION_TIME");
		SaveKeyPairTable(context, FACTIONS_VASSALIZED_DELAYS, "FACTIONS_VASSALIZED_DELAYS");
	end
);
