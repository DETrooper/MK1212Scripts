-----------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: HOLY ROMAN EMPIRE EVENTS
-- 	By: DETrooper
--
-----------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------
-- Events which can occur for the emperor and members of the HRE.

HRE_EVENTS_MIN_TURN = 4; -- First turn that an HRE event can occur.
HRE_EVENTS_TURNS_BETWEEN_DILEMMAS_MAX = 12;
HRE_EVENTS_TURNS_BETWEEN_DILEMMAS_MIN = 4;
HRE_EVENTS_TIMER = -1;

HRE_CURRENT_EVENT = "";
HRE_CURRENT_EVENT_FACTION1 = "";
HRE_CURRENT_EVENT_FACTION2 = "";

function Add_HRE_Event_Listeners()
	if not HRE_DESTROYED and HRE_EMPEROR_KEY and HRE_EMPEROR_KEY ~= "nil" then
		local emperor_faction = cm:model():world():faction_by_key(HRE_EMPEROR_KEY);

		if emperor_faction:is_human() then
			cm:add_listener(
				"FactionTurnStart_HRE_Events",
				"FactionTurnStart",
				true,
				function(context) FactionTurnStart_HRE_Events(context) end,
				true
			);
			cm:add_listener(
				"DilemmaChoiceMadeEvent_HRE_Events",
				"DilemmaChoiceMadeEvent",
				true,
				function(context) DilemmaChoiceMadeEvent_HRE_Events(context) end,
				true
			);
			cm:add_listener(
				"DillemaOrIncidentStarted_HRE_Events",
				"DillemaOrIncidentStarted",
				true,
				function(context) DillemaOrIncidentStarted_HRE_Events(context) end,
				true
			);
			cm:add_listener(
				"OnComponentLClickUp_HRE_Events",
				"ComponentLClickUp",
				true,
				function(context) OnComponentMouseOnOrClick_HRE_Events(context) end,
				true
			);
			cm:add_listener(
				"OnComponentMouseOn_HRE_Events",
				"ComponentMouseOn",
				true,
				function(context) OnComponentMouseOnOrClick_HRE_Events(context) end,
				true
			);
			cm:add_listener(
				"PanelOpenedCampaign_HRE_Events",
				"PanelOpenedCampaign",
				true,
				function(context) PanelOpenedCampaign_HRE_Events(context) end,
				true
			);

			if cm:is_new_game() then
				HRE_EVENTS_TIMER = cm:random_number(HRE_EVENTS_TURNS_BETWEEN_DILEMMAS_MAX - 1, HRE_EVENTS_MIN_TURN - 1);
			end
		end
	end
end

function Remove_HRE_Event_Listeners()
	cm:remove_listener("FactionTurnStart_HRE_Events");
	cm:remove_listener("DilemmaChoiceMadeEvent_HRE_Events");
	cm:remove_listener("DillemaOrIncidentStarted_HRE_Events");
	cm:remove_listener("OnComponentLClickUp_HRE_Events");
	cm:remove_listener("OnComponentMouseOn_HRE_Events");
	cm:remove_listener("PanelOpenedCampaign_HRE_Events");

	HRE_EVENTS_TIMER = -1;
end

function FactionTurnStart_HRE_Events(context)
	if context:faction():is_human() then
		local faction_name = context:faction():name();

		if faction_name == HRE_EMPEROR_KEY then
			local turn_number = cm:model():turn_number();

			if HRE_EVENTS_TIMER > 0 then
				HRE_EVENTS_TIMER = HRE_EVENTS_TIMER - 1;
			elseif HRE_EVENTS_TIMER == 0 then
				HRE_Event_Pick_Random_Event();
			end
		end
	end
end

function DillemaOrIncidentStarted_HRE_Events(context)
	HRE_CURRENT_EVENT = context.string;
	HRE_EVENTS_TIMER = cm:random_number(HRE_EVENTS_TURNS_BETWEEN_DILEMMAS_MAX, HRE_EVENTS_TURNS_BETWEEN_DILEMMAS_MIN);
end

function DilemmaChoiceMadeEvent_HRE_Events(context)
	if context:dilemma() == "mk_dilemma_hre_border_dispute" then
		if context:choice() == 0 then
			HRE_Set_Faction_State(HRE_CURRENT_EVENT_FACTION1, "loyal", true);
			HRE_Set_Faction_State(HRE_CURRENT_EVENT_FACTION2, "discontent", true);
		elseif context:choice() == 1 then
			HRE_Set_Faction_State(HRE_CURRENT_EVENT_FACTION1, "discontent", true);
			HRE_Set_Faction_State(HRE_CURRENT_EVENT_FACTION2, "loyal", true);
		elseif context:choice() == 2 then
			HRE_Change_Imperial_Authority(HRE_EVENTS_DILEMMAS[context:dilemma()][context:choice() + 1]);
		end
	elseif context:dilemma() == "mk_dilemma_hre_imperial_immediacy" then
		if context:choice() == 0 then
			HRE_Set_Faction_State(HRE_CURRENT_EVENT_FACTION1, "discontent", true);
			HRE_Change_Imperial_Authority(HRE_EVENTS_DILEMMAS[context:dilemma()][context:choice() + 1]);
		elseif context:choice() == 1 then
			HRE_Set_Faction_State(HRE_CURRENT_EVENT_FACTION1, "loyal", true);
			HRE_Change_Imperial_Authority(HRE_EVENTS_DILEMMAS[context:dilemma()][context:choice() + 1]);
		end
	elseif context:dilemma() == "mk_dilemma_hre_noble_conflict" then
		if context:choice() == 0 then
			HRE_Set_Faction_State(HRE_CURRENT_EVENT_FACTION2, "discontent", true);
			HRE_Change_Imperial_Authority(HRE_EVENTS_DILEMMAS[context:dilemma()][context:choice() + 1]);
		elseif context:choice() == 1 then
			HRE_Set_Faction_State(HRE_CURRENT_EVENT_FACTION1, "discontent", true);
			HRE_Change_Imperial_Authority(HRE_EVENTS_DILEMMAS[context:dilemma()][context:choice() + 1]);
		elseif context:choice() == 2 then
			HRE_Change_Imperial_Authority(HRE_EVENTS_DILEMMAS[context:dilemma()][context:choice() + 1]);
		end
	elseif context:dilemma() == "mk_dilemma_hre_imperial_diet" then
		if context:choice() == 0 then
			HRE_Set_Faction_State(HRE_CURRENT_EVENT_FACTION2, "discontent", true);
			HRE_Change_Imperial_Authority(HRE_EVENTS_DILEMMAS[context:dilemma()][context:choice() + 1]);
		elseif context:choice() == 1 then
			HRE_Set_Faction_State(HRE_CURRENT_EVENT_FACTION1, "discontent", true);
			HRE_Change_Imperial_Authority(HRE_EVENTS_DILEMMAS[context:dilemma()][context:choice() + 1]);
		elseif context:choice() == 2 then
			HRE_Set_Faction_State(HRE_CURRENT_EVENT_FACTION1, "loyal", true);
			HRE_Set_Faction_State(HRE_CURRENT_EVENT_FACTION2, "loyal", true);
		elseif context:choice() == 3 then
			HRE_Change_Imperial_Authority(HRE_EVENTS_DILEMMAS[context:dilemma()][context:choice() + 1]);
		end
	end
end

function OnComponentMouseOnOrClick_HRE_Events(context)
	if context.string == "choice_button" then
		local tooltip = string.gsub(UIComponent(context.component):GetTooltipText(), "faction1", Get_DFN_Localisation(HRE_CURRENT_EVENT_FACTION1));
		tooltip = string.gsub(tooltip, "faction2", Get_DFN_Localisation(HRE_CURRENT_EVENT_FACTION2));

		UIComponent(context.component):SetTooltipText(tooltip);
	end
end

function PanelOpenedCampaign_HRE_Events(context)
	if context.string == "events" then
		if HRE_CURRENT_EVENT == "mk_dilemma_hre_border_dispute" or HRE_CURRENT_EVENT == "mk_dilemma_hre_noble_conflict" then
			local bg_description_txt = find_uicomponent_by_table(cm:ui_root(), {"panel_manager", "events", "event_dilemma", "non_political", "bg_description", "dy_description", "Text"});
			local option1_button = find_uicomponent_by_table(cm:ui_root(), {"panel_manager", "events", "event_dilemma", "dilemma1_window", "dilemma1_template", "choice_button"});
			local option1_button_text_uic = find_uicomponent_by_table(cm:ui_root(), {"panel_manager", "events", "event_dilemma", "dilemma1_window", "dilemma1_template", "choice_button", "dy_choice"});
			local option2_button = find_uicomponent_by_table(cm:ui_root(), {"panel_manager", "events", "event_dilemma", "dilemma2_window", "dilemma2_template", "choice_button"});
			local option2_button_text_uic = find_uicomponent_by_table(cm:ui_root(), {"panel_manager", "events", "event_dilemma", "dilemma2_window", "dilemma2_template", "choice_button", "dy_choice"});
			local option1_effect1_text_uic = find_uicomponent_by_table(cm:ui_root(), {"panel_manager", "events", "event_dilemma", "dilemma1_window", "dilemma1_template", "payload_window1", "effect1", "dy_payload"});
			local option1_effect2_text_uic = find_uicomponent_by_table(cm:ui_root(), {"panel_manager", "events", "event_dilemma", "dilemma1_window", "dilemma1_template", "payload_window2", "effect2", "dy_payload"});
			local option2_effect1_text_uic = find_uicomponent_by_table(cm:ui_root(), {"panel_manager", "events", "event_dilemma", "dilemma2_window", "dilemma2_template", "payload_window1", "effect1", "dy_payload"});
			local option2_effect2_text_uic = find_uicomponent_by_table(cm:ui_root(), {"panel_manager", "events", "event_dilemma", "dilemma2_window", "dilemma2_template", "payload_window2", "effect2", "dy_payload"});
			local option3_effect1_text_uic = find_uicomponent_by_table(cm:ui_root(), {"panel_manager", "events", "event_dilemma", "dilemma3_window", "dilemma3_template", "payload_window1", "effect1", "dy_payload"});

			local description_text = string.gsub(bg_description_txt:GetStateText(), "faction1", Get_DFN_Localisation(HRE_CURRENT_EVENT_FACTION1));
			description_text = string.gsub(description_text, "faction2", Get_DFN_Localisation(HRE_CURRENT_EVENT_FACTION2));

			local option1_effect1_text = "";
			local option1_effect2_text = "";
			local option2_effect1_text = "";
			local option2_effect2_text = "";
			local option3_effect1_text = "";

			if HRE_CURRENT_EVENT == "mk_dilemma_hre_border_dispute" then
				option1_effect1_text = string.gsub(option1_effect1_text_uic:GetStateText(), "faction", Get_DFN_Localisation(HRE_CURRENT_EVENT_FACTION1));
				option1_effect2_text = string.gsub(option1_effect2_text_uic:GetStateText(), "faction", Get_DFN_Localisation(HRE_CURRENT_EVENT_FACTION2));
				option2_effect1_text = string.gsub(option2_effect1_text_uic:GetStateText(), "faction", Get_DFN_Localisation(HRE_CURRENT_EVENT_FACTION2));
				option2_effect2_text = string.gsub(option2_effect2_text_uic:GetStateText(), "faction", Get_DFN_Localisation(HRE_CURRENT_EVENT_FACTION1));

				--[[local option1_effect1_icon_uic = find_uicomponent_by_table(cm:ui_root(), {"panel_manager", "events", "event_dilemma", "dilemma1_window", "dilemma1_template", "payload_window1", "effect1", "payload_icon"});
				local option1_effect2_icon_uic = find_uicomponent_by_table(cm:ui_root(), {"panel_manager", "events", "event_dilemma", "dilemma1_window", "dilemma1_template", "payload_window2", "effect2", "payload_icon"});
				local option2_effect1_icon_uic = find_uicomponent_by_table(cm:ui_root(), {"panel_manager", "events", "event_dilemma", "dilemma2_window", "dilemma2_template", "payload_window1", "effect1", "payload_icon"});
				local option2_effect2_icon_uic = find_uicomponent_by_table(cm:ui_root(), {"panel_manager", "events", "event_dilemma", "dilemma2_window", "dilemma2_template", "payload_window2", "effect2", "payload_icon"});

				option1_effect1_icon_uic:DestroyChildren();
				option1_effect2_icon_uic:DestroyChildren();
				option2_effect1_icon_uic:DestroyChildren();
				option2_effect2_icon_uic:DestroyChildren();

				option1_effect1_icon_uic:CreateComponent("faction_logo", "UI/new/faction_flags/"..HRE_CURRENT_EVENT_FACTION1.."_flag_small");
				option1_effect2_icon_uic:CreateComponent("faction_logo", "UI/new/faction_flags/"..HRE_CURRENT_EVENT_FACTION2.."_flag_small");
				option2_effect1_icon_uic:CreateComponent("faction_logo", "UI/new/faction_flags/"..HRE_CURRENT_EVENT_FACTION2.."_flag_small");
				option2_effect2_icon_uic:CreateComponent("faction_logo", "UI/new/faction_flags/"..HRE_CURRENT_EVENT_FACTION1.."_flag_small");]]--
			else
				option1_effect1_text = string.gsub(option1_effect1_text_uic:GetStateText(), "faction", Get_DFN_Localisation(HRE_CURRENT_EVENT_FACTION2));
				option1_effect2_text = string.gsub(option1_effect2_text_uic:GetStateText(), "number", tostring(HRE_EVENTS_DILEMMAS[HRE_CURRENT_EVENT][1]));
				option2_effect1_text = string.gsub(option2_effect1_text_uic:GetStateText(), "faction", Get_DFN_Localisation(HRE_CURRENT_EVENT_FACTION1));
				option2_effect2_text = string.gsub(option2_effect2_text_uic:GetStateText(), "number", tostring(HRE_EVENTS_DILEMMAS[HRE_CURRENT_EVENT][2]));

				--[[local option1_effect1_icon_uic = find_uicomponent_by_table(cm:ui_root(), {"panel_manager", "events", "event_dilemma", "dilemma1_window", "dilemma1_template", "payload_window1", "effect1", "payload_icon"});
				local option2_effect1_icon_uic = find_uicomponent_by_table(cm:ui_root(), {"panel_manager", "events", "event_dilemma", "dilemma2_window", "dilemma2_template", "payload_window1", "effect1", "payload_icon"});

				option1_effect1_icon_uic:DestroyChildren();
				option2_effect1_icon_uic:DestroyChildren();

				option1_effect1_icon_uic:CreateComponent("faction_logo", "UI/new/faction_flags/"..HRE_CURRENT_EVENT_FACTION2.."_flag_small");
				option2_effect1_icon_uic:CreateComponent("faction_logo", "UI/new/faction_flags/"..HRE_CURRENT_EVENT_FACTION1.."_flag_small");]]--
			end

			option3_effect1_text = string.gsub(option3_effect1_text_uic:GetStateText(), "number", tostring(-HRE_EVENTS_DILEMMAS[HRE_CURRENT_EVENT][3]));

			bg_description_txt:SetStateText(description_text);
			option1_button_text_uic:SetStateText(UI_LOCALISATION["hre_support_prefix"]..Get_DFN_Localisation(HRE_CURRENT_EVENT_FACTION1)..".");
			option2_button_text_uic:SetStateText(UI_LOCALISATION["hre_support_prefix"]..Get_DFN_Localisation(HRE_CURRENT_EVENT_FACTION2)..".");
			option1_effect1_text_uic:SetStateText(option1_effect1_text);
			option1_effect2_text_uic:SetStateText(option1_effect2_text);
			option2_effect1_text_uic:SetStateText(option2_effect1_text);
			option2_effect2_text_uic:SetStateText(option2_effect2_text);
			option3_effect1_text_uic:SetStateText(option3_effect1_text);

			-- I also don't like how 3-choice dilemmas have the 3rd choice not centered, so I'm gonna do that myself.
			local dilemma3_window_uic = find_uicomponent_by_table(cm:ui_root(), {"panel_manager", "events", "event_dilemma", "dilemma3_window"});
			local dilemma3_window_uicX, dilemma3_window_uicY = dilemma3_window_uic:Position();

			dilemma3_window_uic:SetMoveable(true);
			dilemma3_window_uic:MoveTo(dilemma3_window_uicX + 172, dilemma3_window_uicY);
			dilemma3_window_uic:SetMoveable(false);
		elseif HRE_CURRENT_EVENT == "mk_dilemma_hre_imperial_immediacy" then
			local bg_description_txt = find_uicomponent_by_table(cm:ui_root(), {"panel_manager", "events", "event_dilemma", "non_political", "bg_description", "dy_description", "Text"});
			local option1_button = find_uicomponent_by_table(cm:ui_root(), {"panel_manager", "events", "event_dilemma", "dilemma1B_window", "dilemma1_template", "choice_button"});
			local option2_button = find_uicomponent_by_table(cm:ui_root(), {"panel_manager", "events", "event_dilemma", "dilemma2B_window", "dilemma2_template", "choice_button"});
			local option1_effect1_text_uic = find_uicomponent_by_table(cm:ui_root(), {"panel_manager", "events", "event_dilemma", "dilemma1B_window", "dilemma1_template", "payload_window1", "effect1", "dy_payload"});
			local option1_effect2_text_uic = find_uicomponent_by_table(cm:ui_root(), {"panel_manager", "events", "event_dilemma", "dilemma1B_window", "dilemma1_template", "payload_window2", "effect2", "dy_payload"});
			local option2_effect1_text_uic = find_uicomponent_by_table(cm:ui_root(), {"panel_manager", "events", "event_dilemma", "dilemma2B_window", "dilemma2_template", "payload_window1", "effect1", "dy_payload"});
			local option2_effect2_text_uic = find_uicomponent_by_table(cm:ui_root(), {"panel_manager", "events", "event_dilemma", "dilemma2B_window", "dilemma2_template", "payload_window2", "effect2", "dy_payload"});

			local description_text = string.gsub(bg_description_txt:GetStateText(), "faction1", Get_DFN_Localisation(HRE_CURRENT_EVENT_FACTION1));
			local chance = cm:random_number(2);

			if chance == 2 then
				description_text = string.gsub(description_text, "subject of", "city under");
			end

			local option1_effect1_text = string.gsub(option1_effect1_text_uic:GetStateText(), "faction", Get_DFN_Localisation(HRE_CURRENT_EVENT_FACTION1));
			local option1_effect2_text = string.gsub(option1_effect2_text_uic:GetStateText(), "number", tostring(HRE_EVENTS_DILEMMAS[HRE_CURRENT_EVENT][1]));
			local option2_effect1_text = string.gsub(option2_effect1_text_uic:GetStateText(), "faction", Get_DFN_Localisation(HRE_CURRENT_EVENT_FACTION1));
			local option2_effect2_text = string.gsub(option2_effect2_text_uic:GetStateText(), "number", tostring(-HRE_EVENTS_DILEMMAS[HRE_CURRENT_EVENT][2]));

			bg_description_txt:SetStateText(description_text);
			option1_effect1_text_uic:SetStateText(option1_effect1_text);
			option1_effect2_text_uic:SetStateText(option1_effect2_text);
			option2_effect1_text_uic:SetStateText(option2_effect1_text);
			option2_effect2_text_uic:SetStateText(option2_effect2_text);
		elseif HRE_CURRENT_EVENT == "mk_dilemma_hre_imperial_diet" then
			local bg_description_txt = find_uicomponent_by_table(cm:ui_root(), {"panel_manager", "events", "event_dilemma", "non_political", "bg_description", "dy_description", "Text"});
			local option1_button = find_uicomponent_by_table(cm:ui_root(), {"panel_manager", "events", "event_dilemma", "dilemma1_window", "dilemma1_template", "choice_button"});
			local option1_button_text_uic = find_uicomponent_by_table(cm:ui_root(), {"panel_manager", "events", "event_dilemma", "dilemma1_window", "dilemma1_template", "choice_button", "dy_choice"});
			local option2_button = find_uicomponent_by_table(cm:ui_root(), {"panel_manager", "events", "event_dilemma", "dilemma2_window", "dilemma2_template", "choice_button"});
			local option2_button_text_uic = find_uicomponent_by_table(cm:ui_root(), {"panel_manager", "events", "event_dilemma", "dilemma2_window", "dilemma2_template", "choice_button", "dy_choice"});
			local option1_effect1_text_uic = find_uicomponent_by_table(cm:ui_root(), {"panel_manager", "events", "event_dilemma", "dilemma1_window", "dilemma1_template", "payload_window1", "effect1", "dy_payload"});
			local option1_effect2_text_uic = find_uicomponent_by_table(cm:ui_root(), {"panel_manager", "events", "event_dilemma", "dilemma1_window", "dilemma1_template", "payload_window2", "effect2", "dy_payload"});
			local option2_effect1_text_uic = find_uicomponent_by_table(cm:ui_root(), {"panel_manager", "events", "event_dilemma", "dilemma2_window", "dilemma2_template", "payload_window1", "effect1", "dy_payload"});
			local option2_effect2_text_uic = find_uicomponent_by_table(cm:ui_root(), {"panel_manager", "events", "event_dilemma", "dilemma2_window", "dilemma2_template", "payload_window2", "effect2", "dy_payload"});
			local option3_effect1_text_uic = find_uicomponent_by_table(cm:ui_root(), {"panel_manager", "events", "event_dilemma", "dilemma3_window", "dilemma3_template", "payload_window1", "effect1", "dy_payload"});
			local option3_effect2_text_uic = find_uicomponent_by_table(cm:ui_root(), {"panel_manager", "events", "event_dilemma", "dilemma3_window", "dilemma3_template", "payload_window2", "effect2", "dy_payload"});
			local option4_effect1_text_uic = find_uicomponent_by_table(cm:ui_root(), {"panel_manager", "events", "event_dilemma", "dilemma4_window", "dilemma4_template", "payload_window1", "effect1", "dy_payload"});

			local description_text = string.gsub(bg_description_txt:GetStateText(), "faction1", Get_DFN_Localisation(HRE_CURRENT_EVENT_FACTION1));
			description_text = string.gsub(description_text, "faction2", Get_DFN_Localisation(HRE_CURRENT_EVENT_FACTION2));

			local option1_effect1_text = string.gsub(option1_effect1_text_uic:GetStateText(), "faction", Get_DFN_Localisation(HRE_CURRENT_EVENT_FACTION2));
			local option1_effect2_text = string.gsub(option1_effect2_text_uic:GetStateText(), "number", tostring(HRE_EVENTS_DILEMMAS[HRE_CURRENT_EVENT][1]));
			local option2_effect1_text = string.gsub(option2_effect1_text_uic:GetStateText(), "faction", Get_DFN_Localisation(HRE_CURRENT_EVENT_FACTION1));
			local option2_effect2_text = string.gsub(option2_effect2_text_uic:GetStateText(), "number", tostring(HRE_EVENTS_DILEMMAS[HRE_CURRENT_EVENT][2]));
			local option3_effect1_text = string.gsub(option3_effect1_text_uic:GetStateText(), "faction", Get_DFN_Localisation(HRE_CURRENT_EVENT_FACTION1));
			local option3_effect2_text = string.gsub(option3_effect2_text_uic:GetStateText(), "faction", Get_DFN_Localisation(HRE_CURRENT_EVENT_FACTION2));
			local option4_effect1_text = string.gsub(option4_effect1_text_uic:GetStateText(), "number", tostring(HRE_EVENTS_DILEMMAS[HRE_CURRENT_EVENT][4]));

			bg_description_txt:SetStateText(description_text);
			option1_button_text_uic:SetStateText(UI_LOCALISATION["hre_support_prefix"]..Get_DFN_Localisation(HRE_CURRENT_EVENT_FACTION1)..".");
			option2_button_text_uic:SetStateText(UI_LOCALISATION["hre_support_prefix"]..Get_DFN_Localisation(HRE_CURRENT_EVENT_FACTION2)..".");
			option1_effect1_text_uic:SetStateText(option1_effect1_text);
			option1_effect2_text_uic:SetStateText(option1_effect2_text);
			option2_effect1_text_uic:SetStateText(option2_effect1_text);
			option2_effect2_text_uic:SetStateText(option2_effect2_text);
			option3_effect1_text_uic:SetStateText(option3_effect1_text);
			option3_effect2_text_uic:SetStateText(option3_effect2_text);
			option4_effect1_text_uic:SetStateText(option4_effect1_text);
		end
	end
end

function HRE_Event_Pick_Random_Event()
	local chance = cm:random_number(4);

	if chance == 1 then
		HRE_Event_Pick_Random_Bordering_Factions();

		if HRE_CURRENT_EVENT_FACTION1 ~= "" and HRE_CURRENT_EVENT_FACTION2 ~= "" then
			cm:trigger_dilemma(HRE_EMPEROR_KEY, "mk_dilemma_hre_border_dispute");
		else
			HRE_EVENTS_TIMER = HRE_EVENTS_TIMER + 1;
		end
	elseif chance == 2 then
		HRE_Event_Pick_Random_Faction(false);

		if HRE_CURRENT_EVENT_FACTION1 ~= "" then
			cm:trigger_dilemma(HRE_EMPEROR_KEY, "mk_dilemma_hre_imperial_immediacy");
		else
			HRE_EVENTS_TIMER = HRE_EVENTS_TIMER + 1;
		end
	elseif chance == 3 then
		HRE_Event_Pick_Random_Bordering_Factions();

		if HRE_CURRENT_EVENT_FACTION1 ~= "" and HRE_CURRENT_EVENT_FACTION2 ~= "" then
			cm:trigger_dilemma(HRE_EMPEROR_KEY, "mk_dilemma_hre_noble_conflict");
		else
			HRE_EVENTS_TIMER = HRE_EVENTS_TIMER + 1;
		end
	elseif chance == 4 then
		HRE_Event_Pick_Random_Faction(false);

		if HRE_CURRENT_EVENT_FACTION1 ~= "" then
			cm:trigger_dilemma(HRE_EMPEROR_KEY, "mk_dilemma_hre_imperial_diet");
		else
			HRE_EVENTS_TIMER = HRE_EVENTS_TIMER + 1;
		end
	end
end

function HRE_Event_Pick_Random_Faction(should_have_bordering_hre_faction)
	local rand = cm:random_number(#HRE_FACTIONS);
	local hre_factions = {};

	for i = 1, #HRE_FACTIONS do
		local potential_faction = HRE_FACTIONS[i];

		if potential_faction ~= HRE_EMPEROR_KEY and cm:model():world():faction_by_key(potential_faction):at_war_with(cm:model():world():faction_by_key(HRE_EMPEROR_KEY)) == false then
			if should_have_bordering_hre_faction == true then
				for j = 1, #HRE_FACTIONS do
					local bordering_faction = HRE_FACTIONS[j];

					if bordering_faction ~= HRE_EMPEROR_KEY and bordering_faction ~= potential_faction then
						if Does_Faction_Border_Faction(potential_faction, bordering_faction) then
							table.insert(hre_factions, potential_faction);
							break;
						end
					end
				end
			else
				table.insert(hre_factions, potential_faction);
			end
		end
	end

	if #hre_factions == 0 then
		HRE_CURRENT_EVENT_FACTION1 = "";
		return;
	end

	HRE_CURRENT_EVENT_FACTION1 = hre_factions[rand];
end

function HRE_Event_Pick_Random_Bordering_Factions()
	HRE_Event_Pick_Random_Faction(true); -- Set Faction 1.

	local bordering_factions = {};

	for i = 1, #HRE_FACTIONS do
		local potential_faction = HRE_FACTIONS[i];

		if potential_faction ~= HRE_EMPEROR_KEY and potential_faction ~= HRE_CURRENT_EVENT_FACTION1 and cm:model():world():faction_by_key(potential_faction):at_war_with(cm:model():world():faction_by_key(HRE_EMPEROR_KEY)) == false then
			if Does_Faction_Border_Faction(HRE_CURRENT_EVENT_FACTION1, potential_faction) then
				table.insert(bordering_factions, potential_faction);
			end
		end
	end

	if #bordering_factions == 0 then
		HRE_CURRENT_EVENT_FACTION2 = "";
		return;
	end

	local rand = cm:random_number(#bordering_factions);

	HRE_CURRENT_EVENT_FACTION2 = bordering_factions[rand];
end

function HRE_Event_Reset_Timer()
	HRE_EVENTS_TIMER = cm:random_number(HRE_EVENTS_TURNS_BETWEEN_DILEMMAS_MAX - 1, HRE_EVENTS_MIN_TURN - 1);
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		cm:save_value("HRE_CURRENT_EVENT", HRE_CURRENT_EVENT, context);
		cm:save_value("HRE_CURRENT_EVENT_FACTION1", HRE_CURRENT_EVENT_FACTION1, context);
		cm:save_value("HRE_CURRENT_EVENT_FACTION2", HRE_CURRENT_EVENT_FACTION2, context);
		cm:save_value("HRE_EVENTS_TIMER", HRE_EVENTS_TIMER, context);
	end
);

cm:register_loading_game_callback(
	function(context)
		HRE_CURRENT_EVENT = cm:load_value("HRE_CURRENT_EVENT", "", context);
		HRE_CURRENT_EVENT_FACTION1 = cm:load_value("HRE_CURRENT_EVENT_FACTION1", "", context);
		HRE_CURRENT_EVENT_FACTION2 = cm:load_value("HRE_CURRENT_EVENT_FACTION2", "", context);
		HRE_EVENTS_TIMER = cm:load_value("HRE_EVENTS_TIMER", -1, context);
	end
);
