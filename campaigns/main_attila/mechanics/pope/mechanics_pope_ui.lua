--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: POPE UI
-- 	By: DETrooper
--
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------

CHARACTERS_ON_CRUSADE = {};

function Add_Pope_UI_Listeners()
	cm:add_listener(
		"CharacterSelected_Pope_UI",
		"CharacterSelected",
		true,
		function(context) CharacterSelected_Pope_UI(context) end,
		true
	);
	cm:add_listener(
		"OnComponentMouseOn_Pope_UI",
		"ComponentMouseOn",
		true,
		function(context) OnComponentMouseOn_Pope_UI(context) end,
		true
	);
	cm:add_listener(
		"OnComponentLClickUp_Pope_UI",
		"ComponentLClickUp",
		true,
		function(context) OnComponentLClickUp_Pope_UI(context) end,
		true
	);
	cm:add_listener(
		"FactionTurnEnd_Pope_UI",
		"FactionTurnEnd",
		true,
		function(context) FactionTurnEnd_Pope_UI(context) end,
		true
	);
	cm:add_listener(
		"OnPanelOpenedCampaign_Pope_UI",
		"PanelOpenedCampaign",
		true,
		function(context) OnPanelOpenedCampaign_Pope_UI(context) end,
		true
	);
	cm:add_listener(
		"OnPanelClosedCampaign_Pope_UI",
		"PanelClosedCampaign",
		true,
		function(context) OnPanelClosedCampaign_Pope_UI(context) end,
		true
	);
	cm:add_listener(
		"TimeTrigger_Pope_UI",
		"TimeTrigger",
		true,
		function(context) TimeTrigger_Pope_UI(context) end,
		true
	);
end

function CharacterSelected_Pope_UI(context)
	local root = cm:ui_root();
	local btnCrusade = UIComponent(root:Find("button_join_crusade"));

	btnCrusade:SetState("inactive"); -- Default to inactive.
	btnCrusade:SetVisible(false); -- Default to not visible.

	if CRUSADE_ACTIVE == true then
		local faction_name = cm:get_local_faction();
		
		if context:character():faction():state_religion() == "att_rel_chr_catholic" and context:character():faction():name() == faction_name then
			if context:character():military_force():unit_list():num_items() > 1 then
				-- Not an agent or lone general.
				btnCrusade:SetVisible(true);

				if not HasValue(CHARACTERS_ON_CRUSADE, LAST_CHARACTER_SELECTED:cqi()) then
					btnCrusade:SetState("active");
				end
			end
		end
	end
end

function OnComponentMouseOn_Pope_UI(context)
	if context.string == "button_join_crusade" then
		local root = cm:ui_root();
		local btnCrusade = UIComponent(root:Find("button_join_crusade"));
		local faction_name = cm:get_local_faction();
		local faction =  cm:model():world():faction_by_key(faction_name);
		if faction:at_war_with(cm:model():world():faction_by_key(CURRENT_CRUSADE_TARGET_OWNER)) == false then
			btnCrusade:SetTooltipText("Send this army on Crusade!\n\n[[rgba:200:10:10:150]]Note that clicking this button will declare war![[/rgba:200:10:10:150]]");
		else
			btnCrusade:SetTooltipText("Send this army on Crusade!");
		end
	end
end

function OnComponentLClickUp_Pope_UI(context)
	if context.string == "button_join_crusade" then
		local faction_name = LAST_CHARACTER_SELECTED:faction():name();
		local faction = LAST_CHARACTER_SELECTED:faction();

		if not HasValue(CURRENT_CRUSADE_FACTIONS_JOINED, faction_name) then
			table.insert(CURRENT_CRUSADE_FACTIONS_JOINED, faction_name);

			if faction:at_war_with(cm:model():world():faction_by_key(CURRENT_CRUSADE_TARGET_OWNER)) == false then
				cm:force_declare_war(faction_name, CURRENT_CRUSADE_TARGET_OWNER);
			end

			cm:force_diplomacy(faction_name, CURRENT_CRUSADE_TARGET_OWNER, "peace", false, false);
			cm:force_diplomacy(CURRENT_CRUSADE_TARGET_OWNER, faction_name, "peace", false, false);

			cm:trigger_mission(faction_name, CURRENT_CRUSADE_MISSION_KEY);

			cm:show_message_event(
				faction_name, 
				"message_event_text_text_mk_event_crusade_"..tostring(CURRENT_CRUSADE).."_title", 
				"message_event_text_text_mk_event_crusade_joined_primary", 
				"message_event_text_text_mk_event_crusade_joined_secondary", 
				true,
				706
			);

			if FACTION_EXCOMMUNICATED[faction_name] == true then
				Remove_Excommunication_Manual(faction_name);
			end

			Add_Pope_Favour(faction_name, 2, "joined_crusade");
			Update_Pope_Favour(faction);
		end

		local root = cm:ui_root();
		local btnCrusade = UIComponent(root:Find("button_join_crusade"));
		btnCrusade:SetState("inactive");
		table.insert(CHARACTERS_ON_CRUSADE, LAST_CHARACTER_SELECTED:cqi());
		local force = LAST_CHARACTER_SELECTED:cqi();
		cm:apply_effect_bundle_to_characters_force("mk_bundle_army_crusade", force, 0, true);
	elseif context.string == "root" then
		local root = cm:ui_root();
		local btnCrusade = UIComponent(root:Find("button_join_crusade"));
		btnCrusade:SetVisible(false);
	end
end

function FactionTurnEnd_Pope_UI(context)
	if context:faction():is_human() then
		local root = cm:ui_root();
		local btnCrusade = UIComponent(root:Find("button_join_crusade"));
		btnCrusade:SetVisible(false);
	end
end

function OnPanelOpenedCampaign_Pope_UI(context)
	if context.string == "campaign_tactical_map" or context.string == "clan" or context.string == "diplomacy_dropdown" or context.string == "popup_pre_battle" or context.string == "settlement_captured" or context.string == "technology_panel" then
		local root = cm:ui_root();
		local btnCrusade = UIComponent(root:Find("button_join_crusade"));
		btnCrusade:SetVisible(false);
	elseif context.string == "events" then
		if CRUSADE_END_EVENT_OPEN == true then
			local num_owned_regions = 0;
			local option3_button = find_uicomponent_by_table(cm:ui_root(), {"panel_manager", "events", "event_dilemma", "dilemma3_window", "dilemma3_template", "choice_button"});
			local option4_button = find_uicomponent_by_table(cm:ui_root(), {"panel_manager", "events", "event_dilemma", "dilemma4_window", "dilemma4_template", "choice_button"});

			option4_button:SetState("inactive"); -- Default to inactive in case player owns only the crusade target.

			if cm:model():world():region_manager():region_by_key(JERUSALEM_KEY):owning_faction():state_religion() == "att_rel_chr_catholic" then
				option3_button:SetState("inactive");
			end

			for i = 1, #CURRENT_CRUSADE_TARGET_OWNED_REGIONS do
				if cm:model():world():region_manager():region_by_key(CURRENT_CRUSADE_TARGET_OWNED_REGIONS[i]):owning_faction():name() == cm:get_local_faction() then
					num_owned_regions = num_owned_regions + 1;

					if num_owned_regions < 1 then
						-- Player owns more than just the crusade target so enable the option to only give away the crusade target and keep the other conquered land.
						option4_button:SetState("active");
						break;
					end
				end
			end

			CRUSADE_END_EVENT_OPEN = false;
		end
	end
end

function OnPanelClosedCampaign_Pope_UI(context)
	if context.string == "campaign_tactical_map" or context.string == "clan" or context.string == "diplomacy_dropdown" or context.string == "popup_pre_battle" or context.string == "settlement_captured" or context.string == "technology_panel" then
		cm:add_time_trigger("Check_Army_Details_Visible", 0.5);
	end
end

function TimeTrigger_Pope_UI(context)
	if context.string == "Check_Army_Details_Visible" then
		local root = cm:ui_root();
		if ARMY_SELECTED == true and CRUSADE_ACTIVE == true then
			local btnCrusade = UIComponent(root:Find("button_join_crusade"));
			btnCrusade:SetVisible(true);
		end
	end
end

------------------------------------------------
---------------- Saving/Loading ----------------
------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		SaveTable(context, CHARACTERS_ON_CRUSADE, "CHARACTERS_ON_CRUSADE");
	end
);

cm:register_loading_game_callback(
	function(context)
		CHARACTERS_ON_CRUSADE = LoadTableNumbers(context, "CHARACTERS_ON_CRUSADE");
	end
);
