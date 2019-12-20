-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: ANNEX VASSALS
-- 	By: DETrooper
--
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
local dev = require("lua_scripts.dev");

ANNEX_TURN_REQUIREMENT = 10; -- How long until annexation can begin when you've made a new vassal?
ANNEX_TURNS_PER_REGION = 3; -- Once annexation process has started, how many turns per region should it take to complete?

FACTIONS_VASSALIZED = {};
FACTIONS_VASSALIZED_DELAYS = {};
VASSAL_SELECTED_CURRENTLY_ANNEXING = false;
VASSAL_SELECTED = nil;
VASSAL_SELECTED_ANNEXATION_TIME = 0;

PROPOSER = nil;
RECIPIENT = nil;
VASSAL = nil;

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
		"FactionLeaderDeclaresWar", -- the event to listen for
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
		"SettlementSelected_Annex",
		"SettlementSelected",
		true,
		function(context) OnSettlementSelected_Annex(context) end,
		true
	);
	cm:add_listener(
		"SettlementDeselected_Annex",
		"SettlementDeselected",
		true,
		function(context) OnSettlementDeselected_Annex(context) end,
		true
	);
	cm:add_listener(
		"TimeTrigger_Annex",
		"TimeTrigger",
		true,
		function(context) OnTimeTrigger_Annex(context) end,
		true
	);

	CreateAnnexButton();

	if cm:is_new_game() then
		AnnexVassalsSetup();
	end
end

function CreateAnnexButton()
	local root = cm:ui_root();
	local army_details = UIComponent(root:Find("button_army_details"))
	local army_detailsX, army_detailsY = army_details:Position();

	root:CreateComponent("Annex_Button", "UI/new/basic_toggle_annex");
	local btnAnnex = UIComponent(root:Find("Annex_Button"));
	btnAnnex:SetMoveable(true);
	btnAnnex:MoveTo(army_detailsX + 60, army_detailsY);
	btnAnnex:SetMoveable(false);
	btnAnnex:PropagatePriority(60);
	btnAnnex:SetState("inactive"); 
	btnAnnex:SetVisible(false);
end

function AnnexVassalsSetup()
	local faction_list = cm:model():world():faction_list();

	for i = 0, faction_list:num_items() - 1 do
		local faction_name = faction_list:item_at(i):name();

		if faction_name == "mk_fact_almohads" then
			if faction_name == cm:model():faction_for_command_queue_index(HUMAN_FACTIONS[1]):name() then
				table.insert(FACTIONS_VASSALIZED, "mk_fact_hafsids");
			end
		elseif faction_name == "mk_fact_ayyubids" then
			if faction_name == cm:model():faction_for_command_queue_index(HUMAN_FACTIONS[1]):name() then
				table.insert(FACTIONS_VASSALIZED, "mk_fact_mecca");
			end
		elseif faction_name == "mk_fact_bulgaria" then
			if faction_name == cm:model():faction_for_command_queue_index(HUMAN_FACTIONS[1]):name() then
				table.insert(FACTIONS_VASSALIZED, "mk_fact_wallachia");
			end
		elseif faction_name == "mk_fact_france" then
			if faction_name == cm:model():faction_for_command_queue_index(HUMAN_FACTIONS[1]):name() then
				table.insert(FACTIONS_VASSALIZED, "mk_fact_burgundy");
			end
		elseif faction_name == "mk_fact_hungary" then
			if faction_name == cm:model():faction_for_command_queue_index(HUMAN_FACTIONS[1]):name() then
				table.insert(FACTIONS_VASSALIZED, "mk_fact_croatia");
			end
		elseif faction_name == "mk_fact_kiev" then
			if faction_name == cm:model():faction_for_command_queue_index(HUMAN_FACTIONS[1]):name() then
				table.insert(FACTIONS_VASSALIZED, "mk_fact_chernigov");
			end
		elseif faction_name == "mk_fact_khwarazm" then
			if faction_name == cm:model():faction_for_command_queue_index(HUMAN_FACTIONS[1]):name() then
				table.insert(FACTIONS_VASSALIZED, "mk_fact_hazaraspids");
				table.insert(FACTIONS_VASSALIZED, "mk_fact_salghurids");
			end
		elseif faction_name == "mk_fact_georgia" then
			if faction_name == cm:model():faction_for_command_queue_index(HUMAN_FACTIONS[1]):name() then
				table.insert(FACTIONS_VASSALIZED, "mk_fact_alania");
				table.insert(FACTIONS_VASSALIZED, "mk_fact_shirvan");
			end
		elseif faction_name == "mk_fact_latinempire" then
			if faction_name == cm:model():faction_for_command_queue_index(HUMAN_FACTIONS[1]):name() then
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
		for i = 1, #FACTIONS_VASSALIZED do
			if tonumber(FACTIONS_VASSALIZED_DELAYS[FACTIONS_VASSALIZED[i]]) > 0 then
				FACTIONS_VASSALIZED_DELAYS[FACTIONS_VASSALIZED[i]] = tostring(tonumber(FACTIONS_VASSALIZED_DELAYS[FACTIONS_VASSALIZED[i]]) - 1);
			end
		end

		if HasValue(FACTIONS_VASSALIZED, VASSAL_SELECTED) == true then
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
	if context:liberating_character():faction():name() == cm:model():faction_for_command_queue_index(HUMAN_FACTIONS[1]):name() then
		table.insert(FACTIONS_VASSALIZED, context:faction():name());
		cm:add_time_trigger("vassal_check", 0.1);
	end
end

function FactionSubjugatesOtherFaction_Annex(context)
	VASSAL = context:other_faction():name();
end

function PositiveDiplomaticEvent_Annex(context)
	if context:proposer():is_human() == true then
		PROPOSER = context:proposer():name();
		RECIPIENT = context:recipient():name();
		cm:add_time_trigger("diplo_vassal_check", 0.5);
	end
end

function FactionLeaderDeclaresWar_Annex(context)
	if HasValue(FACTIONS_VASSALIZED, context:character():faction():name()) == true then
		if context:character():faction():at_war_with(cm:model():faction_for_command_queue_index(HUMAN_FACTIONS[1])) then
			for i = 1, #FACTIONS_VASSALIZED do
				if FACTIONS_VASSALIZED[i] == context:character():faction():name() then
					table.remove(FACTIONS_VASSALIZED, i);
					FACTIONS_VASSALIZED_DELAYS[FACTIONS_VASSALIZED[i]] = nil;
				end
			end
		end
	elseif context:character():faction():name() == cm:model():faction_for_command_queue_index(HUMAN_FACTIONS[1]):name() then
		for i = 1, #FACTIONS_VASSALIZED do
			if context:character():faction():at_war_with(cm:model():world():faction_by_key(FACTIONS_VASSALIZED[i])) then
				table.remove(FACTIONS_VASSALIZED, i);
				FACTIONS_VASSALIZED_DELAYS[FACTIONS_VASSALIZED[i]] = nil;
			end
		end		
	end
end

function OnComponentMouseOn_Annex_UI(context)
	if context.string == "Annex_Button" then
		local root = cm:ui_root();
		local btnAnnex = UIComponent(root:Find("Annex_Button"));
		local faction_name = FACTION_TURN;
		local vassal_string = Get_DFN_Localisation(VASSAL_SELECTED);
		local cost = "n";
		local turns = "n";

		if VASSAL_SELECTED_CURRENTLY_ANNEXING == false then
			for i = 1, #ANNEX_VASSALS_SIZES do
				if (cm:model():world():faction_by_key(VASSAL_SELECTED):region_list():num_items() >= tonumber(ANNEX_VASSALS_SIZES[i])) then
					cost = ANNEX_VASSALS_PERCENTAGES[i];
					break;
				end
			end

			if faction_name == cm:model():faction_for_command_queue_index(HUMAN_FACTIONS[1]):name() then
				turns = VASSAL_SELECTED_ANNEXATION_TIME;
			end

			btnAnnex:SetTooltipText("Begin annexing the "..vassal_string..".\n\n[[rgba:255:0:0:150]]This will cost "..cost.." in tax rate for "..turns.." turns.[[/rgba]]");
		else
			btnAnnex:SetTooltipText("Abort the annexation of the "..vassal_string..".\n\n[[rgba:255:0:0:150]]There are "..VASSAL_SELECTED_ANNEXATION_TIME.." turns left.[[/rgba]]");
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
	if context.string == "Annex_Button" then
		local faction_name = FACTION_TURN;

		if VASSAL_SELECTED_CURRENTLY_ANNEXING == false then
			if faction_name == cm:model():faction_for_command_queue_index(HUMAN_FACTIONS[1]):name() then
				VASSAL_SELECTED_CURRENTLY_ANNEXING = true;

				for i = 1, #ANNEX_VASSALS_SIZES do
					if (cm:model():world():faction_by_key(VASSAL_SELECTED):region_list():num_items() >= tonumber(ANNEX_VASSALS_SIZES[i])) then
						cm:apply_effect_bundle("mk_bundle_annex_vassal_regions_"..ANNEX_VASSALS_SIZES[i], faction_name, 0);
						break;
					end
				end
			end

			local root = cm:ui_root();
			local btnAnnex = UIComponent(root:Find("Annex_Button"));
			btnAnnex:SetVisible(false);
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


			VASSAL_SELECTED_ANNEXATION_TIME = 0;
			VASSAL_SELECTED_CURRENTLY_ANNEXING = false;

			for i = 1, #ANNEX_VASSALS_SIZES do
				cm:remove_effect_bundle("mk_bundle_annex_vassal_regions_"..ANNEX_VASSALS_SIZES[i], faction_name);
			end

			local root = cm:ui_root();
			local btnAnnex = UIComponent(root:Find("Annex_Button"));
			btnAnnex:SetVisible(false);
		end
	elseif context.string == "root" then
		local root = cm:ui_root();
		local btnAnnex = UIComponent(root:Find("Annex_Button"));
		btnAnnex:SetVisible(false);
	end
end

function OnSettlementSelected_Annex(context)
	local faction_name = FACTION_TURN;
	local region_owner_name = context:garrison_residence():region():owning_faction():name();

	if faction_name == cm:model():faction_for_command_queue_index(HUMAN_FACTIONS[1]):name() then
		if VASSAL_SELECTED_CURRENTLY_ANNEXING == false then
			if HasValue(FACTIONS_VASSALIZED, region_owner_name) == true then
				VASSAL_SELECTED = region_owner_name;
				VASSAL_SELECTED_ANNEXATION_TIME = context:garrison_residence():region():owning_faction():region_list():num_items() * ANNEX_TURNS_PER_REGION;

				if cm:get_local_faction() == FACTION_TURN then
					local root = cm:ui_root();
					local btnAnnex = UIComponent(root:Find("Annex_Button"));

					if tonumber(FACTIONS_VASSALIZED_DELAYS[VASSAL_SELECTED]) == 0 then
						btnAnnex:SetState("active"); 
					else
						btnAnnex:SetState("inactive");
					end

					btnAnnex:SetVisible(true);
				end
			end
		elseif VASSAL_SELECTED_CURRENTLY_ANNEXING == true and region_owner_name == VASSAL_SELECTED then
			if cm:get_local_faction() == FACTION_TURN then
				local root = cm:ui_root();
				local btnAnnex = UIComponent(root:Find("Annex_Button"));

				btnAnnex:SetState("active");
				btnAnnex:SetVisible(true);
			end
		end
	end
end

function OnSettlementDeselected_Annex(context)
	local root = cm:ui_root();
	local btnAnnex = UIComponent(root:Find("Annex_Button"));

	if btnAnnex:Visible() == true then
		btnAnnex:SetState("inactive"); 
		btnAnnex:SetVisible(false);
	end
end


function OnTimeTrigger_Annex(context)
	if context.string == "vassal_check" then
		local faction_name = FACTION_TURN;
		local faction = cm:model():world():faction_by_key(faction_name);
		local vassalized_faction = cm:model():world():faction_by_key(FACTIONS_VASSALIZED[#FACTIONS_VASSALIZED]);
		local is_ally = faction:allied_with(vassalized_faction);
		
		dev.log("VASSAL CHECK: "..FACTIONS_VASSALIZED[#FACTIONS_VASSALIZED].." - Is Ally: "..tostring(is_ally));
		
		if is_ally == true then
			-- They were liberated instead of vassalized, so remove them.
			table.remove(FACTIONS_VASSALIZED, #FACTIONS_VASSALIZED);
			FACTIONS_VASSALIZED_DELAYS[FACTIONS_VASSALIZED[#FACTIONS_VASSALIZED]] = nil;
		else
			FACTIONS_VASSALIZED_DELAYS[FACTIONS_VASSALIZED[#FACTIONS_VASSALIZED]] = tostring(ANNEX_TURN_REQUIREMENT);
		end
		
		dev.log("\tFACTIONS_VASSALIZED: "..table.concat(FACTIONS_VASSALIZED, ","));

		PROPOSER = nil;
		RECIPIENT = nil;
		VASSAL = nil;
	elseif context.string == "diplo_vassal_check" then
		if PROPOSER ~= nil and RECIPIENT ~= nil and VASSAL ~= nil then
			if RECIPIENT == VASSAL then
				dev.log("RECIPIENT == VASSAL");
				table.insert(FACTIONS_VASSALIZED, RECIPIENT);
				FACTIONS_VASSALIZED_DELAYS[RECIPIENT] = tostring(ANNEX_TURN_REQUIREMENT);
			end

			dev.log("\tFACTIONS_VASSALIZED: "..table.concat(FACTIONS_VASSALIZED, ","));

			PROPOSER = nil;
			RECIPIENT = nil;
			VASSAL = nil;
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
		VASSAL_SELECTED = cm:load_value("VASSAL_SELECTED", nil, context);
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