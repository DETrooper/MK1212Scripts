-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: ANNEX VASSALS
-- 	By: DETrooper
--
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

local liberator = nil;
local proposer = nil;
local recipient = nil;
local vassal = nil;

ANNEX_TURN_REQUIREMENT = 20; -- How long until annexation can begin when you've made a new vassal?
ANNEX_TURNS_PER_REGION = 3; -- Once annexation process has started, how many turns per region should it take to complete?

FACTIONS_TO_FACTIONS_VASSALIZED = {};
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
		"FactionBecomesLiberationVassal_Annex",
		"FactionBecomesLiberationVassal",
		true,
		function(context) FactionBecomesLiberationVassal_Annex(context) end,
		true
	);
	cm:add_listener(
		"FactionSubjugatesOtherFaction_Annex",
		"FactionSubjugatesOtherFaction",
		true,
		function(context) FactionSubjugatesOtherFaction_Annex(context) end,
		true
	);
	cm:add_listener(
		"PositiveDiplomaticEvent_Annex",
		"PositiveDiplomaticEvent",
		true,
		function(context) PositiveDiplomaticEvent_Annex(context) end,
		true
	);
	cm:add_listener(
		"FactionLeaderDeclaresWar_Annex",
		"FactionLeaderDeclaresWar",
		true,
		function(context) FactionLeaderDeclaresWar_Annex(context) end,
		true
	)
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

		FACTIONS_TO_FACTIONS_VASSALIZED[faction_name] = {};
		FACTIONS_VASSALIZED_ANNEXING[faction_name] = false;

		if FACTIONS_VASSALIZED_ANNEXATION_TIME[faction_name] == nil then
			FACTIONS_VASSALIZED_ANNEXATION_TIME[faction_name] = -1;
		end

		if FACTIONS_TO_FACTIONS_VASSALIZED_START[faction_name]  then
			for j = 1, #FACTIONS_TO_FACTIONS_VASSALIZED_START[faction_name] do
				local vassal_faction_name = FACTIONS_TO_FACTIONS_VASSALIZED_START[faction_name][j];

				table.insert(FACTIONS_TO_FACTIONS_VASSALIZED[faction_name], vassal_faction_name);
				FACTIONS_VASSALIZED_ANNEXATION_TIME[vassal_faction_name] = cm:model():world():faction_by_key(vassal_faction_name):region_list():num_items() * ANNEX_TURNS_PER_REGION;
				FACTIONS_VASSALIZED_DELAYS[vassal_faction_name] = ANNEX_TURN_REQUIREMENT;
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
		local vassal_faction_name = FACTIONS_TO_FACTIONS_VASSALIZED[faction_name][i];
		local vassal_faction = cm:model():world():faction_by_key(vassal_faction_name);

		if FACTIONS_VASSALIZED_ANNEXATION_TIME[vassal_faction_name] == nil or FACTIONS_VASSALIZED_ANNEXING[vassal_faction_name] == false then
			FACTIONS_VASSALIZED_ANNEXATION_TIME[vassal_faction_name] = vassal_faction:region_list():num_items() * ANNEX_TURNS_PER_REGION;
		end

		if FACTIONS_VASSALIZED_ANNEXING[vassal_faction_name] == true then
			local annexation_turns_left = FACTIONS_VASSALIZED_ANNEXATION_TIME[vassal_faction_name];

			if vassal_faction:has_home_region() == true then
				if annexation_turns_left > 0 then
					FACTIONS_VASSALIZED_ANNEXATION_TIME[vassal_faction_name] = annexation_turns_left - 1;
				end

				if FACTIONS_VASSALIZED_ANNEXATION_TIME[vassal_faction_name] == 0 then
					cm:grant_faction_handover(faction_name, vassal_faction_name, cm:model():turn_number() - 1, cm:model():turn_number() - 1, context);
					
					local faction_string = "factions_screen_name_"..vassal_faction_name;

					if FACTIONS_DFN_LEVEL[vassal_faction_name]  then
						if FACTIONS_DFN_LEVEL[vassal_faction_name] > 1 then
							faction_string = "campaign_localised_strings_string_"..vassal_faction_name.."_lvl"..tostring(FACTIONS_DFN_LEVEL[vassal_faction_name]);
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
						if FACTIONS_TO_FACTIONS_VASSALIZED[faction_name][i] == vassal_faction_name then
							table.remove(FACTIONS_TO_FACTIONS_VASSALIZED[faction_name], i);
							break;
						end
					end

					vassal_faction_name = nil;

					Stop_Annexing_Vassal(faction_name, vassal_faction_name);
				end
			else
				local faction_string = "factions_screen_name_"..vassal_faction_name;

				if FACTIONS_DFN_LEVEL[vassal_faction_name]  then
					if FACTIONS_DFN_LEVEL[vassal_faction_name] > 1 then
						faction_string = "campaign_localised_strings_string_"..vassal_faction_name.."_lvl"..tostring(FACTIONS_DFN_LEVEL[vassal_faction_name]);
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
					if FACTIONS_TO_FACTIONS_VASSALIZED[faction_name][i] == vassal_faction_name then
						table.remove(FACTIONS_TO_FACTIONS_VASSALIZED[faction_name], i);
						break;
					end
				end

				vassal_faction_name = nil;

				Stop_Annexing_Vassal(faction_name, vassal_faction_name);
			end
		elseif faction_is_human == false and vassal_faction:is_human() == false then
			if FACTIONS_VASSALIZED_DELAYS[vassal_faction_name] == 0 and Get_Vassal_Currently_Annexing(faction_name) == nil then
				-- Todo: Add personality check?

				Start_Annexing_Vassal(faction_name, vassal_faction_name);
			end
		end
	end
end

function FactionBecomesLiberationVassal_Annex(context)
	local liberating_faction_name = context:liberating_character():faction():name();
	local vassal_faction_name = context:faction():name();

	if not HasValue(FACTIONS_TO_FACTIONS_VASSALIZED[liberating_faction_name], vassal_faction_name) then
		table.insert(FACTIONS_TO_FACTIONS_VASSALIZED[liberating_faction_name], vassal_faction_name);
		liberator = liberating_faction_name;
		cm:add_time_trigger("vassal_check", 0.1);
	else
		-- Something has gone horribly wrong!!!!!!
	end
end

function FactionSubjugatesOtherFaction_Annex(context)
	vassal = context:other_faction():name();
end

function PositiveDiplomaticEvent_Annex(context)
	proposer = context:proposer():name();
	recipient = context:recipient():name();
	cm:add_time_trigger("diplo_vassal_check", 0.5);
end

function FactionLeaderDeclaresWar_Annex(context)
	local faction_name = context:character():faction():name();

	if #FACTIONS_TO_FACTIONS_VASSALIZED[faction_name] > 0 then
		for i = 1, #FACTIONS_TO_FACTIONS_VASSALIZED[faction_name] do
			local vassal_faction_name = FACTIONS_TO_FACTIONS_VASSALIZED[faction_name][i];
			local vassal_faction = cm:model():world():faction_by_key(vassal_faction_name);

			if vassal_faction:at_war_with(context:character():faction()) then
				FACTIONS_VASSALIZED_DELAYS[vassal_faction_name] = nil;

				if Get_Vassal_Currently_Annexing(faction_name) == vassal_faction_name then
					Stop_Annexing_Vassal(faction_name, vassal_faction_name);
				end

				table.remove(FACTIONS_TO_FACTIONS_VASSALIZED[faction_name], i);
				return;
			end
		end
	else
		-- Faction has no vassals or is a vassal.
		local master_faction_name = Get_Vassal_Overlord(faction_name);

		if master_faction_name  then
			if cm:model():world():faction_by_key(master_faction_name):at_war_with(context:character():faction()) then
				for i = 1, #FACTIONS_TO_FACTIONS_VASSALIZED[master_faction_name] do
					if FACTIONS_TO_FACTIONS_VASSALIZED[master_faction_name][i] == faction_name then
						FACTIONS_VASSALIZED_DELAYS[faction_name] = nil;

						if Get_Vassal_Currently_Annexing(master_faction_name) == faction_name then
							Stop_Annexing_Vassal(master_faction_name, faction_name);
						end

						table.remove(FACTIONS_TO_FACTIONS_VASSALIZED[master_faction_name], i);
						return;
					end
				end
			end
		end
	end
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

				UIComponent(context.component):SetTooltipText("Begin annexing the "..vassal_string..".\n\n[[rgba:255:0:0:150]]This will cost "..cost.." in tax rate for "..turns.." turns.[[/rgba]]");
			else
				UIComponent(context.component):SetTooltipText("Abort the annexation of the "..vassal_string..".\n\n[[rgba:255:0:0:150]]There are "..FACTIONS_VASSALIZED_ANNEXATION_TIME[DIPLOMACY_SELECTED_FACTION].." turns left.[[/rgba]]");
			end
		else
			UIComponent(context.component):SetTooltipText("The "..vassal_string.." is not your vassal!");
		end
	elseif string.find(context.string, "mk_bundle_annex_vassal_regions_") then
		local vassal_faction_name = Get_Vassal_Currently_Annexing(cm:get_local_faction());
		local root = cm:ui_root();
		local TechTooltipPopup = UIComponent(root:Find("TechTooltipPopup"));
		local description_window_uic = UIComponent(TechTooltipPopup:Find("description_window"));
		local vassal_string = Get_DFN_Localisation(vassal_faction_name);

		description_window_uic:SetStateText("You are in the process annexing a vassal state, costing you a significant amount of money every turn.\n\nAnnexing Faction: "..vassal_string.."\n\nTurns Remaining: "..tostring(FACTIONS_VASSALIZED_ANNEXATION_TIME[vassal_faction_name]));
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
				UIComponent(context.component):SetTooltipText("Begin annexing the "..vassal_string..".\n\n[[rgba:255:0:0:150]]This will cost "..cost.." in tax rate for "..turns.." turns.[[/rgba]]");
			else
				UIComponent(context.component):SetStateText("");
				UIComponent(context.component):SetTooltipText("Abort the annexation of the "..vassal_string..".\n\n[[rgba:255:0:0:150]]There are "..FACTIONS_VASSALIZED_ANNEXATION_TIME[DIPLOMACY_SELECTED_FACTION].." turns left.[[/rgba]]");
			end
		else
			UIComponent(context.component):SetStateText("");
			UIComponent(context.component):SetTooltipText("The "..vassal_string.." is not your vassal!");
		end
	elseif DIPLOMACY_PANEL_OPEN == true then
		if context.string == "map" or context.string == "button_icon" or string.find(context.string, "faction_row_entry_") then
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
	if context.string == "vassal_check" then
		local liberator_faction = cm:model():world():faction_by_key(liberator);
		local vassalized_faction_name = FACTIONS_TO_FACTIONS_VASSALIZED[liberator][#FACTIONS_TO_FACTIONS_VASSALIZED[liberator]];
		local vassalized_faction = cm:model():world():faction_by_key(vassalized_faction_name);
		local is_ally = liberator_faction:allied_with(vassalized_faction);
		
		--dev.log("VASSAL CHECK: "..vassalized_faction_name.." - Is Ally: "..tostring(is_ally));
		
		if is_ally == true then
			-- They were liberated instead of vassalized, so remove them.
			FACTIONS_VASSALIZED_DELAYS[vassalized_faction_name] = nil;
			table.remove(FACTIONS_TO_FACTIONS_VASSALIZED[liberator], #FACTIONS_TO_FACTIONS_VASSALIZED[liberator]);
		else
			Faction_Vassalized(liberator, vassalized_faction_name, false, true, true);
		end
		
		--dev.log("\tFACTIONS_TO_FACTIONS_VASSALIZED["..liberator.."]: "..table.concat(FACTIONS_TO_FACTIONS_VASSALIZED[liberator], ","));

		liberator = nil;
		proposer = nil;
		recipient = nil;
		vassal = nil;
	elseif context.string == "diplo_vassal_check" then
		if proposer  and recipient  and vassal  then
			if recipient == vassal then
				--dev.log("RECIPIENT == VASSAL");

				if not HasValue(FACTIONS_TO_FACTIONS_VASSALIZED[proposer], recipient) then
					Faction_Vassalized(proposer, recipient, true, true, true);
				else
					-- Something has gone horribly wrong!!!!!!
				end
			end

			--dev.log("\tFACTIONS_TO_FACTIONS_VASSALIZED["..proposer.."]: "..table.concat(FACTIONS_TO_FACTIONS_VASSALIZED[proposer], ","));

			liberator = nil;
			proposer = nil;
			recipient = nil;
			vassal = nil;
		end
	elseif context.string == "annex_diplo_hud_check" then
		local root = cm:ui_root();
		local diplomacy_dropdown_uic = UIComponent(root:Find("diplomacy_dropdown"));
		local btnAnnex = UIComponent(diplomacy_dropdown_uic:Find("button_annex_vassal"));
		--local faction_left_status_panel_uic = UIComponent(diplomacy_dropdown_uic:Find("faction_left_status_panel"));
		--local diplomatic_relations_uic = UIComponent(faction_left_status_panel_uic:Find("diplomatic_relations"));
		--local icon_vassals_uic = UIComponent( diplomatic_relations_uic:Find("icon_vassals"));

		btnAnnex:SetStateText("");
		btnAnnex:SetState("inactive");
	
		if FACTIONS_VASSALIZED_ANNEXING[DIPLOMACY_SELECTED_FACTION] == false then
			if HasValue(FACTIONS_TO_FACTIONS_VASSALIZED[cm:get_local_faction()], DIPLOMACY_SELECTED_FACTION) then
				DIPLOMACY_SELECTED_FACTION = DIPLOMACY_SELECTED_FACTION;
	
				if FACTIONS_VASSALIZED_DELAYS[DIPLOMACY_SELECTED_FACTION] == 0 then
					btnAnnex:SetState("active"); 
				else
					btnAnnex:SetStateText(tostring(FACTIONS_VASSALIZED_DELAYS[DIPLOMACY_SELECTED_FACTION]));
				end
			end
		elseif HasValue(FACTIONS_TO_FACTIONS_VASSALIZED[cm:get_local_faction()], DIPLOMACY_SELECTED_FACTION) then
			btnAnnex:SetState("active");
		end

		-- (Doesn't work) Having a true vassal (i.e. one released using the buffer state mechanic) will overwrite client states on the UI, so we need to fix that.
		--[[if icon_vassals_uic:CurrentState() == "vassal" then
			icon_vassals_uic:SetState("client_state");
		end]]--
	end
end

function Faction_Vassalized(master_faction_name, vassalized_faction_name, add_to_table, transfer_vassals, make_peace)
	local vassalized_faction = cm:model():world():faction_by_key(vassalized_faction_name);

	if add_to_table == true then
		if FACTIONS_TO_FACTIONS_VASSALIZED[master_faction_name] == nil then
			FACTIONS_TO_FACTIONS_VASSALIZED[master_faction_name] = {};
		end
		
		table.insert(FACTIONS_TO_FACTIONS_VASSALIZED[master_faction_name], vassalized_faction_name);
	end

	FACTIONS_VASSALIZED_ANNEXING[vassalized_faction_name] = false;
	FACTIONS_VASSALIZED_ANNEXATION_TIME[vassalized_faction_name] = vassalized_faction:region_list():num_items() * ANNEX_TURNS_PER_REGION;
	FACTIONS_VASSALIZED_DELAYS[vassalized_faction_name] = ANNEX_TURN_REQUIREMENT;

	if transfer_vassals == true then
		Vassal_Transfer_Vassals_To_New_Master(master_faction_name, vassalized_faction_name);
	end

	if make_peace == true then
		Vassal_Make_Peace_With_Other_Vassals(vassalized_faction);
	end
end

function Start_Annexing_Vassal(master_faction_name, vassalized_faction_name)
	FACTIONS_VASSALIZED_ANNEXING[vassalized_faction_name] = true;

	for i = 1, #ANNEX_VASSALS_SIZES do
		if cm:model():world():faction_by_key(vassalized_faction_name):region_list():num_items() >= tonumber(ANNEX_VASSALS_SIZES[i]) then
			cm:apply_effect_bundle("mk_bundle_annex_vassal_regions_"..ANNEX_VASSALS_SIZES[i], master_faction_name, 0);
			break;
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
		local vassal_faction_name = FACTIONS_TO_FACTIONS_VASSALIZED[faction_name][i];

		if FACTIONS_VASSALIZED_ANNEXING[vassal_faction_name] == true then
			return vassal_faction_name;
		end
	end
end

function Get_Vassal_Overlord(vassal_faction_name)
	for k, v in pairs(FACTIONS_TO_FACTIONS_VASSALIZED) do
		if #v > 0 then
			for i = 1, #v do
				if v[i] == vassal_faction_name then
					return k;
				end
			end
		end
	end
end

function Vassal_Transfer_Vassals_To_New_Master(master_faction_name, vassalized_faction_name)
	if #FACTIONS_TO_FACTIONS_VASSALIZED[vassalized_faction_name] > 0 then
		for i = 1, #FACTIONS_TO_FACTIONS_VASSALIZED[vassalized_faction_name] do
			Faction_Vassalized(master_faction_name, FACTIONS_TO_FACTIONS_VASSALIZED[vassalized_faction_name][i], false, false, true);
		end
	end

	FACTIONS_TO_FACTIONS_VASSALIZED[vassalized_faction_name] = {};
end

function Vassal_Make_Peace_With_Other_Vassals(faction)
	local faction_list = cm:model():world():faction_list();

	for i = 0, faction_list:num_items() - 1 do
		local current_faction = faction_list:item_at(i);
		local current_faction_name = current_faction:name();

		if current_faction:at_war_with(faction) then
			if HasValue(FACTIONS_TO_FACTIONS_VASSALIZED[faction:name()], current_faction) then
				cm:force_make_peace(current_faction_name, faction:name());
			end
		end
	end
end

------------------------------------------------
---------------- Saving/Loading ----------------
------------------------------------------------
cm:register_loading_game_callback(
	function(context)
		FACTIONS_TO_FACTIONS_VASSALIZED = LoadKeyPairTables(context, "FACTIONS_TO_FACTIONS_VASSALIZED");
		FACTIONS_VASSALIZED_ANNEXING = LoadBooleanPairTable(context, "FACTIONS_VASSALIZED_ANNEXING");
		FACTIONS_VASSALIZED_ANNEXATION_TIME = LoadKeyPairTableNumbers(context, "FACTIONS_VASSALIZED_ANNEXATION_TIME");
		FACTIONS_VASSALIZED_DELAYS = LoadKeyPairTableNumbers(context, "FACTIONS_VASSALIZED_DELAYS");
	end
);

cm:register_saving_game_callback(
	function(context)
		SaveKeyPairTables(context, FACTIONS_TO_FACTIONS_VASSALIZED, "FACTIONS_TO_FACTIONS_VASSALIZED");
		SaveBooleanPairTable(context, FACTIONS_VASSALIZED_ANNEXING, "FACTIONS_VASSALIZED_ANNEXING");
		SaveKeyPairTable(context, FACTIONS_VASSALIZED_ANNEXATION_TIME, "FACTIONS_VASSALIZED_ANNEXATION_TIME");
		SaveKeyPairTable(context, FACTIONS_VASSALIZED_DELAYS, "FACTIONS_VASSALIZED_DELAYS");
	end
);
