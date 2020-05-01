-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: ANNEX VASSALS
-- 	By: DETrooper
--
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

local proposer = nil;
local recipient = nil;
local vassal = nil;

ANNEX_TURN_REQUIREMENT = 20; -- How long until annexation can begin when you've made a new vassal?
ANNEX_TURNS_PER_REGION = 3; -- Once annexation process has started, how many turns per region should it take to complete?

FACTIONS_VASSALIZED = {};
FACTIONS_VASSALIZED_DELAYS = {};
VASSAL_SELECTED_CURRENTLY_ANNEXING = false;
VASSAL_SELECTED = "";
VASSAL_SELECTED_ANNEXATION_TIME = 0;

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
		local faction_name = faction_list:item_at(i):name();

		if faction_name == cm:get_local_faction() then
			if faction_name == "mk_fact_almohads" then
				table.insert(FACTIONS_VASSALIZED, "mk_fact_hafsids");
			elseif faction_name == "mk_fact_ayyubids" then
				table.insert(FACTIONS_VASSALIZED, "mk_fact_mecca");
			elseif faction_name == "mk_fact_bulgaria" then
				table.insert(FACTIONS_VASSALIZED, "mk_fact_wallachia");
			elseif faction_name == "mk_fact_france" then
				table.insert(FACTIONS_VASSALIZED, "mk_fact_burgundy");
			elseif faction_name == "mk_fact_hungary" then
				table.insert(FACTIONS_VASSALIZED, "mk_fact_croatia");
			elseif faction_name == "mk_fact_kiev" then
				table.insert(FACTIONS_VASSALIZED, "mk_fact_chernigov");
			elseif faction_name == "mk_fact_khwarazm" then
				table.insert(FACTIONS_VASSALIZED, "mk_fact_hazaraspids");
				table.insert(FACTIONS_VASSALIZED, "mk_fact_salghurids");
			elseif faction_name == "mk_fact_georgia" then
				table.insert(FACTIONS_VASSALIZED, "mk_fact_alania");
				table.insert(FACTIONS_VASSALIZED, "mk_fact_shirvan");
			elseif faction_name == "mk_fact_latinempire" then
				table.insert(FACTIONS_VASSALIZED, "mk_fact_achaea");
				table.insert(FACTIONS_VASSALIZED, "mk_fact_thessalonica");
			end
		end
	end

	for i = 1, #FACTIONS_VASSALIZED do
		FACTIONS_VASSALIZED_DELAYS[FACTIONS_VASSALIZED[i]] = tostring(ANNEX_TURN_REQUIREMENT);
	end
end

function FactionTurnStart_Annex(context)
	local faction_name = context:faction():name();

	if context:faction():is_human() == true then
		for k, v in pairs(FACTIONS_VASSALIZED_DELAYS) do
			if tonumber(v) > 0 then
				FACTIONS_VASSALIZED_DELAYS[k] = tostring(tonumber(v) - 1);
			end
		end

		if HasValue(FACTIONS_VASSALIZED, VASSAL_SELECTED) then
			if VASSAL_SELECTED_CURRENTLY_ANNEXING == true then
				if cm:model():world():faction_by_key(VASSAL_SELECTED):has_home_region() == true then
					if VASSAL_SELECTED_ANNEXATION_TIME > 0 then
						VASSAL_SELECTED_ANNEXATION_TIME = VASSAL_SELECTED_ANNEXATION_TIME - 1;
					end

					if VASSAL_SELECTED_ANNEXATION_TIME <= 0 then
						cm:grant_faction_handover(faction_name, VASSAL_SELECTED, cm:model():turn_number() - 1, cm:model():turn_number() - 1, context);
						
						local faction_string = "factions_screen_name_"..VASSAL_SELECTED;

						if FACTIONS_DFN_LEVEL[VASSAL_SELECTED] ~= nil then
							if FACTIONS_DFN_LEVEL[VASSAL_SELECTED] > 1 then
								faction_string = "campaign_localised_strings_string_"..VASSAL_SELECTED.."_lvl"..tostring(FACTIONS_DFN_LEVEL[VASSAL_SELECTED]);
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

						for i = 1, #FACTIONS_VASSALIZED do
							if FACTIONS_VASSALIZED[i] == VASSAL_SELECTED then
								table.remove(FACTIONS_VASSALIZED, i);
							end
						end

						VASSAL_SELECTED_CURRENTLY_ANNEXING = false;
						VASSAL_SELECTED = nil;

						for i = 1, #ANNEX_VASSALS_SIZES do
							cm:remove_effect_bundle("mk_bundle_annex_vassal_regions_"..ANNEX_VASSALS_SIZES[i], faction_name);
						end
					end
				else
					local faction_string = "factions_screen_name_"..VASSAL_SELECTED;

					if FACTIONS_DFN_LEVEL[VASSAL_SELECTED] ~= nil then
						if FACTIONS_DFN_LEVEL[VASSAL_SELECTED] > 1 then
							faction_string = "campaign_localised_strings_string_"..VASSAL_SELECTED.."_lvl"..tostring(FACTIONS_DFN_LEVEL[VASSAL_SELECTED]);
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

					for i = 1, #FACTIONS_VASSALIZED do
						if FACTIONS_VASSALIZED[i] == VASSAL_SELECTED then
							table.remove(FACTIONS_VASSALIZED, i);
						end
					end

					VASSAL_SELECTED_ANNEXATION_TIME = 0;
					VASSAL_SELECTED_CURRENTLY_ANNEXING = false;
					VASSAL_SELECTED = nil;

					for i = 1, #ANNEX_VASSALS_SIZES do
						cm:remove_effect_bundle("mk_bundle_annex_vassal_regions_"..ANNEX_VASSALS_SIZES[i], faction_name);
					end
				end
			end
		end
	end
end

function FactionBecomesLiberationVassal_Annex(context)
	if context:liberating_character():faction():name() == cm:get_local_faction() then
		if not HasValue(FACTIONS_VASSALIZED, context:faction():name()) then
			table.insert(FACTIONS_VASSALIZED, context:faction():name());
			cm:add_time_trigger("vassal_check", 0.1);
		else
			-- Something has gone horribly wrong!!!!!!
		end
	end
end

function FactionSubjugatesOtherFaction_Annex(context)
	vassal = context:other_faction():name();
end

function PositiveDiplomaticEvent_Annex(context)
	if context:proposer():is_human() == true then
		proposer = context:proposer():name();
		recipient = context:recipient():name();
		cm:add_time_trigger("diplo_vassal_check", 0.5);
	end
end

function FactionLeaderDeclaresWar_Annex(context)
	if HasValue(FACTIONS_VASSALIZED, context:character():faction():name()) == true then
		if context:character():faction():at_war_with(cm:model():world():faction_by_key(cm:get_local_faction())) then
			for i = 1, #FACTIONS_VASSALIZED do
				if FACTIONS_VASSALIZED[i] == context:character():faction():name() then
					table.remove(FACTIONS_VASSALIZED, i);
					FACTIONS_VASSALIZED_DELAYS[FACTIONS_VASSALIZED[i]] = nil;
				end
			end
		end
	elseif context:character():faction():name() == cm:get_local_faction() then
		for i = 1, #FACTIONS_VASSALIZED do
			if context:character():faction():at_war_with(cm:model():world():faction_by_key(FACTIONS_VASSALIZED[i])) then
				table.remove(FACTIONS_VASSALIZED, i);
				FACTIONS_VASSALIZED_DELAYS[FACTIONS_VASSALIZED[i]] = nil;
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

		if HasValue(FACTIONS_VASSALIZED, DIPLOMACY_SELECTED_FACTION) then
			if VASSAL_SELECTED_CURRENTLY_ANNEXING == false then
				for i = 1, #ANNEX_VASSALS_SIZES do
					if cm:model():world():faction_by_key(VASSAL_SELECTED):region_list():num_items() >= tonumber(ANNEX_VASSALS_SIZES[i]) then
						cost = ANNEX_VASSALS_PERCENTAGES[i];
						break;
					end
				end

				turns = VASSAL_SELECTED_ANNEXATION_TIME;

				UIComponent(context.component):SetTooltipText("Begin annexing the "..vassal_string..".\n\n[[rgba:255:0:0:150]]This will cost "..cost.." in tax rate for "..turns.." turns.[[/rgba]]");
			else
				UIComponent(context.component):SetTooltipText("Abort the annexation of the "..vassal_string..".\n\n[[rgba:255:0:0:150]]There are "..VASSAL_SELECTED_ANNEXATION_TIME.." turns left.[[/rgba]]");
			end
		else
			UIComponent(context.component):SetTooltipText("The "..vassal_string.." is not your vassal!");
		end
	elseif string.find(context.string, "mk_bundle_annex_vassal_regions_") then
		local root = cm:ui_root();
		local TechTooltipPopup = UIComponent(root:Find("TechTooltipPopup"));
		local description_window_uic = UIComponent(TechTooltipPopup:Find("description_window"));
		local vassal_string = Get_DFN_Localisation(VASSAL_SELECTED);

		description_window_uic:SetStateText("You are in the process annexing a vassal state, costing you a significant amount of money every turn.\n\nAnnexing Faction: "..vassal_string.."\n\nTurns Remaining: "..tostring(VASSAL_SELECTED_ANNEXATION_TIME));
	end
end

function OnComponentLClickUp_Annex_UI(context)
	if context.string == "button_annex_vassal" then
		local faction_name = cm:get_local_faction();

		if VASSAL_SELECTED_CURRENTLY_ANNEXING == false then
			VASSAL_SELECTED_CURRENTLY_ANNEXING = true;

			for i = 1, #ANNEX_VASSALS_SIZES do
				if cm:model():world():faction_by_key(VASSAL_SELECTED):region_list():num_items() >= tonumber(ANNEX_VASSALS_SIZES[i]) then
					cm:apply_effect_bundle("mk_bundle_annex_vassal_regions_"..ANNEX_VASSALS_SIZES[i], faction_name, 0);
					break;
				end
			end
		else
			local faction_string = "factions_screen_name_"..VASSAL_SELECTED;

			if FACTIONS_DFN_LEVEL[VASSAL_SELECTED] ~= nil then
				if FACTIONS_DFN_LEVEL[VASSAL_SELECTED] > 1 then
					faction_string = "campaign_localised_strings_string_"..VASSAL_SELECTED.."_lvl"..tostring(FACTIONS_DFN_LEVEL[VASSAL_SELECTED]);
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

			VASSAL_SELECTED_CURRENTLY_ANNEXING = false;
			VASSAL_SELECTED_ANNEXATION_TIME = cm:model():world():faction_by_key(VASSAL_SELECTED):region_list():num_items() * ANNEX_TURNS_PER_REGION;

			for i = 1, #ANNEX_VASSALS_SIZES do
				cm:remove_effect_bundle("mk_bundle_annex_vassal_regions_"..ANNEX_VASSALS_SIZES[i], faction_name);
			end
		end

		local vassal_string = Get_DFN_Localisation(DIPLOMACY_SELECTED_FACTION);
		local cost = "n";
		local turns = "n";

		if HasValue(FACTIONS_VASSALIZED, DIPLOMACY_SELECTED_FACTION) then
			if VASSAL_SELECTED_CURRENTLY_ANNEXING == false then
				for i = 1, #ANNEX_VASSALS_SIZES do
					if cm:model():world():faction_by_key(VASSAL_SELECTED):region_list():num_items() >= tonumber(ANNEX_VASSALS_SIZES[i]) then
						cost = ANNEX_VASSALS_PERCENTAGES[i];
						break;
					end
				end

				turns = VASSAL_SELECTED_ANNEXATION_TIME;

				UIComponent(context.component):SetTooltipText("Begin annexing the "..vassal_string..".\n\n[[rgba:255:0:0:150]]This will cost "..cost.." in tax rate for "..turns.." turns.[[/rgba]]");
			else
				UIComponent(context.component):SetTooltipText("Abort the annexation of the "..vassal_string..".\n\n[[rgba:255:0:0:150]]There are "..VASSAL_SELECTED_ANNEXATION_TIME.." turns left.[[/rgba]]");
			end
		else
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
		local faction_name = cm:get_local_faction();
		local faction = cm:model():world():faction_by_key(faction_name);
		local vassalized_faction = cm:model():world():faction_by_key(FACTIONS_VASSALIZED[#FACTIONS_VASSALIZED]);
		local is_ally = faction:allied_with(vassalized_faction);
		
		--dev.log("VASSAL CHECK: "..FACTIONS_VASSALIZED[#FACTIONS_VASSALIZED].." - Is Ally: "..tostring(is_ally));
		
		if is_ally == true then
			-- They were liberated instead of vassalized, so remove them.
			table.remove(FACTIONS_VASSALIZED, #FACTIONS_VASSALIZED);
			FACTIONS_VASSALIZED_DELAYS[FACTIONS_VASSALIZED[#FACTIONS_VASSALIZED]] = nil;
		else
			FACTIONS_VASSALIZED_DELAYS[FACTIONS_VASSALIZED[#FACTIONS_VASSALIZED]] = tostring(ANNEX_TURN_REQUIREMENT);
		end
		
		--dev.log("\tFACTIONS_VASSALIZED: "..table.concat(FACTIONS_VASSALIZED, ","));

		proposer = nil;
		recipient = nil;
		vassal = nil;
	elseif context.string == "diplo_vassal_check" then
		if proposer ~= nil and recipient ~= nil and vassal ~= nil then
			if recipient == vassal then
				--dev.log("RECIPIENT == VASSAL");

				if not HasValue(FACTIONS_VASSALIZED, recipient) then
					table.insert(FACTIONS_VASSALIZED, recipient);
				else
					-- Something has gone horribly wrong!!!!!!
				end

				FACTIONS_VASSALIZED_DELAYS[recipient] = tostring(ANNEX_TURN_REQUIREMENT);
			end

			--dev.log("\tFACTIONS_VASSALIZED: "..table.concat(FACTIONS_VASSALIZED, ","));

			proposer = nil;
			recipient = nil;
			vassal = nil;
		end
	elseif context.string == "annex_diplo_hud_check" then
		local root = cm:ui_root();
		local btnAnnex = UIComponent(root:Find("button_annex_vassal"));
	
		if VASSAL_SELECTED_CURRENTLY_ANNEXING == false then
			if HasValue(FACTIONS_VASSALIZED, DIPLOMACY_SELECTED_FACTION) then
				VASSAL_SELECTED = DIPLOMACY_SELECTED_FACTION;
				VASSAL_SELECTED_ANNEXATION_TIME = cm:model():world():faction_by_key(VASSAL_SELECTED):region_list():num_items() * ANNEX_TURNS_PER_REGION;
	
				if tonumber(FACTIONS_VASSALIZED_DELAYS[VASSAL_SELECTED]) == 0 then
					btnAnnex:SetState("active"); 
				else
					btnAnnex:SetState("inactive");
				end
			else
				btnAnnex:SetState("inactive");
			end
		elseif VASSAL_SELECTED_CURRENTLY_ANNEXING == true and DIPLOMACY_SELECTED_FACTION == VASSAL_SELECTED then
			btnAnnex:SetState("active");
		else
			btnAnnex:SetState("inactive");
		end
	end
end

------------------------------------------------
---------------- Saving/Loading ----------------
------------------------------------------------
cm:register_loading_game_callback(
	function(context)
		FACTIONS_VASSALIZED = LoadTable(context, "FACTIONS_VASSALIZED");
		FACTIONS_VASSALIZED_DELAYS = LoadKeyPairTable(context, "FACTIONS_VASSALIZED_DELAYS");
		VASSAL_SELECTED_CURRENTLY_ANNEXING = cm:load_value("VASSAL_SELECTED_CURRENTLY_ANNEXING", false, context);
		VASSAL_SELECTED = cm:load_value("VASSAL_SELECTED", "", context);
		VASSAL_SELECTED_ANNEXATION_TIME = cm:load_value("VASSAL_SELECTED_ANNEXATION_TIME", 0, context);
	end
);

cm:register_saving_game_callback(
	function(context)
		SaveTable(context, FACTIONS_VASSALIZED, "FACTIONS_VASSALIZED");
		SaveKeyPairTable(context, FACTIONS_VASSALIZED_DELAYS, "FACTIONS_VASSALIZED_DELAYS");
		cm:save_value("VASSAL_SELECTED_CURRENTLY_ANNEXING", VASSAL_SELECTED_CURRENTLY_ANNEXING, context);
		cm:save_value("VASSAL_SELECTED", VASSAL_SELECTED, context);
		cm:save_value("VASSAL_SELECTED_ANNEXATION_TIME", VASSAL_SELECTED_ANNEXATION_TIME, context);
	end
);
