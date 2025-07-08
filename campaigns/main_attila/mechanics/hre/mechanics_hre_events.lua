-----------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: HOLY ROMAN EMPIRE EVENTS
-- 	By: DETrooper
--
-----------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------
-- Events which can occur for the emperor and members of the HRE.

local hre_current_event = "";
local hre_current_event_faction1 = "";
local hre_current_event_faction2 = "";
local hre_events_min_turn = 1; -- First turn that an HRE event can occur.
local hre_events_turns_between_dilemmas_max = 6;
local hre_events_turns_between_dilemmas_min = 3;
local hre_events_timer = -1;

function mkHRE:Add_Event_Listeners(emperor_key)

    -- Ensure the HRE system is not destroyed
    if not self.destroyed then
    else
        return
    end

    -- Use the provided emperor_key or fall back to self.emperor_key
    emperor_key = emperor_key or self.emperor_key
    if not emperor_key or emperor_key == "nil" then
        return
    end

    local emperor_faction = cm:model():world():faction_by_key(emperor_key)

    -- Check if the emperor is a human-controlled faction
    if emperor_faction:is_human() then

        -- Add various campaign event listeners
        cm:add_listener(
            "FactionTurnStart_HRE_Events_Wrapper",
            "FactionTurnStart",
            true,
            function(context) FactionTurnStart_HRE_Events_Wrapper(context) end,
            true
        )
        cm:add_listener(
            "DilemmaChoiceMadeEvent_HRE_Events",
            "DilemmaChoiceMadeEvent",
            true,
            function(context) DilemmaChoiceMadeEvent_HRE_Events(context) end,
            true
        )
        cm:add_listener(
            "DillemaOrIncidentStarted_HRE_Events",
            "DillemaOrIncidentStarted",
            true,
            function(context) DillemaOrIncidentStarted_HRE_Events(context) end,
            true
        )
        cm:add_listener(
            "OnComponentLClickUp_HRE_Events",
            "ComponentLClickUp",
            true,
            function(context) OnComponentMouseOnOrClick_HRE_Events(context) end,
            true
        )
        cm:add_listener(
            "OnComponentMouseOn_HRE_Events",
            "ComponentMouseOn",
            true,
            function(context) OnComponentMouseOnOrClick_HRE_Events(context) end,
            true
        )
        cm:add_listener(
            "PanelOpenedCampaign_HRE_Events",
            "PanelOpenedCampaign",
            true,
            function(context) PanelOpenedCampaign_HRE_Events(context) end,
            true
        )

        -- Initialize HRE events timer if this is a new game
        if cm:is_new_game() then
            hre_events_timer = cm:random_number(hre_events_turns_between_dilemmas_max - 1, hre_events_min_turn - 1)
        end
    else
    end
end

function Remove_HRE_Event_Listeners()
	cm:remove_listener("FactionTurnStart_HRE_Events");
	cm:remove_listener("DilemmaChoiceMadeEvent_HRE_Events");
	cm:remove_listener("DillemaOrIncidentStarted_HRE_Events");
	cm:remove_listener("OnComponentLClickUp_HRE_Events");
	cm:remove_listener("OnComponentMouseOn_HRE_Events");
	cm:remove_listener("PanelOpenedCampaign_HRE_Events");

	hre_events_timer = -1;
end


function FactionTurnStart_HRE_Events_Wrapper(context)
    local success, errorMsg = pcall(function() FactionTurnStart_HRE_Events(context) end)
    if not success then
        DebugLog("FactionTurnStart_HRE_Events Error: " .. errorMsg)
    end
end

function FactionTurnStart_HRE_Events(context)
	if context:faction():is_human() then
		local faction_name = context:faction():name();

		if faction_name == mkHRE.emperor_key then
			local turn_number = cm:model():turn_number();

			if hre_events_timer > 0 then
				hre_events_timer = hre_events_timer - 1;
			elseif hre_events_timer == 0 then
				mkHRE:Event_Pick_Random_Event();
			end
		end
	end
end

function DillemaOrIncidentStarted_HRE_Events(context)
	hre_current_event = context.string;
	hre_events_timer = cm:random_number(hre_events_turns_between_dilemmas_max, hre_events_turns_between_dilemmas_min);
end

function DilemmaChoiceMadeEvent_HRE_Events(context)
	if context:dilemma() == "mk_dilemma_hre_border_dispute" then
		if context:choice() == 0 then
			mkHRE:Set_Faction_State(hre_current_event_faction1, "loyal", true);
			mkHRE:Set_Faction_State(hre_current_event_faction2, "discontent", true);
		elseif context:choice() == 1 then
			mkHRE:Set_Faction_State(hre_current_event_faction1, "discontent", true);
			mkHRE:Set_Faction_State(hre_current_event_faction2, "loyal", true);
		elseif context:choice() == 2 then
			mkHRE:Change_Imperial_Authority(mkHRE.event_dilemmas[context:dilemma()][context:choice() + 1]);
		end
	elseif context:dilemma() == "mk_dilemma_hre_imperial_immediacy" then
		if context:choice() == 0 then
			mkHRE:Set_Faction_State(hre_current_event_faction1, "discontent", true);
			mkHRE:Change_Imperial_Authority(mkHRE.event_dilemmas[context:dilemma()][context:choice() + 1]);
		elseif context:choice() == 1 then
			mkHRE:Set_Faction_State(hre_current_event_faction1, "loyal", true);
			mkHRE:Change_Imperial_Authority(mkHRE.event_dilemmas[context:dilemma()][context:choice() + 1]);
		end
	elseif context:dilemma() == "mk_dilemma_hre_noble_conflict" then
		if context:choice() == 0 then
			mkHRE:Set_Faction_State(hre_current_event_faction2, "discontent", true);
			mkHRE:Change_Imperial_Authority(mkHRE.event_dilemmas[context:dilemma()][context:choice() + 1]);
		elseif context:choice() == 1 then
			mkHRE:Set_Faction_State(hre_current_event_faction1, "discontent", true);
			mkHRE:Change_Imperial_Authority(mkHRE.event_dilemmas[context:dilemma()][context:choice() + 1]);
		elseif context:choice() == 2 then
			mkHRE:Change_Imperial_Authority(mkHRE.event_dilemmas[context:dilemma()][context:choice() + 1]);
		end
	elseif context:dilemma() == "mk_dilemma_hre_imperial_diet" then
		if context:choice() == 0 then
			mkHRE:Set_Faction_State(hre_current_event_faction2, "discontent", true);
			mkHRE:Change_Imperial_Authority(mkHRE.event_dilemmas[context:dilemma()][context:choice() + 1]);
		elseif context:choice() == 1 then
			mkHRE:Set_Faction_State(hre_current_event_faction1, "discontent", true);
			mkHRE:Change_Imperial_Authority(mkHRE.event_dilemmas[context:dilemma()][context:choice() + 1]);
		elseif context:choice() == 2 then
			mkHRE:Set_Faction_State(hre_current_event_faction1, "loyal", true);
			mkHRE:Set_Faction_State(hre_current_event_faction2, "loyal", true);
		elseif context:choice() == 3 then
			mkHRE:Change_Imperial_Authority(mkHRE.event_dilemmas[context:dilemma()][context:choice() + 1]);
		end
	end
end

function OnComponentMouseOnOrClick_HRE_Events(context)
	if context.string == "choice_button" then
		local tooltip = string.gsub(UIComponent(context.component):GetTooltipText(), "faction1", Get_DFN_Localisation(hre_current_event_faction1));
		tooltip = string.gsub(tooltip, "faction2", Get_DFN_Localisation(hre_current_event_faction2));

		UIComponent(context.component):SetTooltipText(tooltip);
	end
end

function PanelOpenedCampaign_HRE_Events(context)
    DebugLog("PanelOpenedCampaign_HRE_Events");
    DebugLog("context.string: " .. context.string);
    DebugLog("hre_current_event: " .. hre_current_event);

	if context.string == "events" then
		if hre_current_event == "mk_dilemma_hre_border_dispute" or hre_current_event == "mk_dilemma_hre_noble_conflict" then
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

			local description_text = string.gsub(bg_description_txt:GetStateText(), "faction1", Get_DFN_Localisation(hre_current_event_faction1));
			description_text = string.gsub(description_text, "faction2", Get_DFN_Localisation(hre_current_event_faction2));
            DebugLog("description_text: " .. hre_current_event_faction2);
            DebugLog("Get_DFN_Localisation(hre_current_event_faction2): " .. Get_DFN_Localisation(hre_current_event_faction2));
            DebugLog("hre_current_event_faction2: " .. hre_current_event_faction2);
			local option1_effect1_text = "";
			local option1_effect2_text = "";
			local option2_effect1_text = "";
			local option2_effect2_text = "";
			local option3_effect1_text = "";

			if hre_current_event == "mk_dilemma_hre_border_dispute" then
				option1_effect1_text = string.gsub(option1_effect1_text_uic:GetStateText(), "faction", Get_DFN_Localisation(hre_current_event_faction1));
				option1_effect2_text = string.gsub(option1_effect2_text_uic:GetStateText(), "faction", Get_DFN_Localisation(hre_current_event_faction2));
				option2_effect1_text = string.gsub(option2_effect1_text_uic:GetStateText(), "faction", Get_DFN_Localisation(hre_current_event_faction2));
				option2_effect2_text = string.gsub(option2_effect2_text_uic:GetStateText(), "faction", Get_DFN_Localisation(hre_current_event_faction1));

				--[[local option1_effect1_icon_uic = find_uicomponent_by_table(cm:ui_root(), {"panel_manager", "events", "event_dilemma", "dilemma1_window", "dilemma1_template", "payload_window1", "effect1", "payload_icon"});
				local option1_effect2_icon_uic = find_uicomponent_by_table(cm:ui_root(), {"panel_manager", "events", "event_dilemma", "dilemma1_window", "dilemma1_template", "payload_window2", "effect2", "payload_icon"});
				local option2_effect1_icon_uic = find_uicomponent_by_table(cm:ui_root(), {"panel_manager", "events", "event_dilemma", "dilemma2_window", "dilemma2_template", "payload_window1", "effect1", "payload_icon"});
				local option2_effect2_icon_uic = find_uicomponent_by_table(cm:ui_root(), {"panel_manager", "events", "event_dilemma", "dilemma2_window", "dilemma2_template", "payload_window2", "effect2", "payload_icon"});

				option1_effect1_icon_uic:DestroyChildren();
				option1_effect2_icon_uic:DestroyChildren();
				option2_effect1_icon_uic:DestroyChildren();
				option2_effect2_icon_uic:DestroyChildren();

				option1_effect1_icon_uic:CreateComponent("faction_logo", "UI/new/faction_flags/"..hre_current_event_faction1.."_flag_small");
				option1_effect2_icon_uic:CreateComponent("faction_logo", "UI/new/faction_flags/"..hre_current_event_faction2.."_flag_small");
				option2_effect1_icon_uic:CreateComponent("faction_logo", "UI/new/faction_flags/"..hre_current_event_faction2.."_flag_small");
				option2_effect2_icon_uic:CreateComponent("faction_logo", "UI/new/faction_flags/"..hre_current_event_faction1.."_flag_small");]]--
			else
				option1_effect1_text = string.gsub(option1_effect1_text_uic:GetStateText(), "faction", Get_DFN_Localisation(hre_current_event_faction2));
				option1_effect2_text = string.gsub(option1_effect2_text_uic:GetStateText(), "number", tostring(mkHRE.event_dilemmas[hre_current_event][1]));
				option2_effect1_text = string.gsub(option2_effect1_text_uic:GetStateText(), "faction", Get_DFN_Localisation(hre_current_event_faction1));
				option2_effect2_text = string.gsub(option2_effect2_text_uic:GetStateText(), "number", tostring(mkHRE.event_dilemmas[hre_current_event][2]));

				--[[local option1_effect1_icon_uic = find_uicomponent_by_table(cm:ui_root(), {"panel_manager", "events", "event_dilemma", "dilemma1_window", "dilemma1_template", "payload_window1", "effect1", "payload_icon"});
				local option2_effect1_icon_uic = find_uicomponent_by_table(cm:ui_root(), {"panel_manager", "events", "event_dilemma", "dilemma2_window", "dilemma2_template", "payload_window1", "effect1", "payload_icon"});

				option1_effect1_icon_uic:DestroyChildren();
				option2_effect1_icon_uic:DestroyChildren();

				option1_effect1_icon_uic:CreateComponent("faction_logo", "UI/new/faction_flags/"..hre_current_event_faction2.."_flag_small");
				option2_effect1_icon_uic:CreateComponent("faction_logo", "UI/new/faction_flags/"..hre_current_event_faction1.."_flag_small");]]--
			end

			option3_effect1_text = string.gsub(option3_effect1_text_uic:GetStateText(), "number", tostring(-mkHRE.event_dilemmas[hre_current_event][3]));

			bg_description_txt:SetStateText(description_text);
			option1_button_text_uic:SetStateText(UI_LOCALISATION["hre_support_prefix"]..Get_DFN_Localisation(hre_current_event_faction1)..".");
			option2_button_text_uic:SetStateText(UI_LOCALISATION["hre_support_prefix"]..Get_DFN_Localisation(hre_current_event_faction2)..".");
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
		elseif hre_current_event == "mk_dilemma_hre_imperial_immediacy" then
			local bg_description_txt = find_uicomponent_by_table(cm:ui_root(), {"panel_manager", "events", "event_dilemma", "non_political", "bg_description", "dy_description", "Text"});
			local option1_button = find_uicomponent_by_table(cm:ui_root(), {"panel_manager", "events", "event_dilemma", "dilemma1B_window", "dilemma1_template", "choice_button"});
			local option2_button = find_uicomponent_by_table(cm:ui_root(), {"panel_manager", "events", "event_dilemma", "dilemma2B_window", "dilemma2_template", "choice_button"});
			local option1_effect1_text_uic = find_uicomponent_by_table(cm:ui_root(), {"panel_manager", "events", "event_dilemma", "dilemma1B_window", "dilemma1_template", "payload_window1", "effect1", "dy_payload"});
			local option1_effect2_text_uic = find_uicomponent_by_table(cm:ui_root(), {"panel_manager", "events", "event_dilemma", "dilemma1B_window", "dilemma1_template", "payload_window2", "effect2", "dy_payload"});
			local option2_effect1_text_uic = find_uicomponent_by_table(cm:ui_root(), {"panel_manager", "events", "event_dilemma", "dilemma2B_window", "dilemma2_template", "payload_window1", "effect1", "dy_payload"});
			local option2_effect2_text_uic = find_uicomponent_by_table(cm:ui_root(), {"panel_manager", "events", "event_dilemma", "dilemma2B_window", "dilemma2_template", "payload_window2", "effect2", "dy_payload"});

			local description_text = string.gsub(bg_description_txt:GetStateText(), "faction1", Get_DFN_Localisation(hre_current_event_faction1));
			local chance = cm:random_number(2);

			if chance == 2 then
				description_text = string.gsub(description_text, "subject of", "city under");
			end

			local option1_effect1_text = string.gsub(option1_effect1_text_uic:GetStateText(), "faction", Get_DFN_Localisation(hre_current_event_faction1));
			local option1_effect2_text = string.gsub(option1_effect2_text_uic:GetStateText(), "number", tostring(mkHRE.event_dilemmas[hre_current_event][1]));
			local option2_effect1_text = string.gsub(option2_effect1_text_uic:GetStateText(), "faction", Get_DFN_Localisation(hre_current_event_faction1));
			local option2_effect2_text = string.gsub(option2_effect2_text_uic:GetStateText(), "number", tostring(-mkHRE.event_dilemmas[hre_current_event][2]));

			bg_description_txt:SetStateText(description_text);
			option1_effect1_text_uic:SetStateText(option1_effect1_text);
			option1_effect2_text_uic:SetStateText(option1_effect2_text);
			option2_effect1_text_uic:SetStateText(option2_effect1_text);
			option2_effect2_text_uic:SetStateText(option2_effect2_text);
		elseif hre_current_event == "mk_dilemma_hre_imperial_diet" then
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

			local description_text = string.gsub(bg_description_txt:GetStateText(), "faction1", Get_DFN_Localisation(hre_current_event_faction1));
			description_text = string.gsub(description_text, "faction2", Get_DFN_Localisation(hre_current_event_faction2));

			local option1_effect1_text = string.gsub(option1_effect1_text_uic:GetStateText(), "faction", Get_DFN_Localisation(hre_current_event_faction2));
			local option1_effect2_text = string.gsub(option1_effect2_text_uic:GetStateText(), "number", tostring(mkHRE.event_dilemmas[hre_current_event][1]));
			local option2_effect1_text = string.gsub(option2_effect1_text_uic:GetStateText(), "faction", Get_DFN_Localisation(hre_current_event_faction1));
			local option2_effect2_text = string.gsub(option2_effect2_text_uic:GetStateText(), "number", tostring(mkHRE.event_dilemmas[hre_current_event][2]));
			local option3_effect1_text = string.gsub(option3_effect1_text_uic:GetStateText(), "faction", Get_DFN_Localisation(hre_current_event_faction1));
			local option3_effect2_text = string.gsub(option3_effect2_text_uic:GetStateText(), "faction", Get_DFN_Localisation(hre_current_event_faction2));
			local option4_effect1_text = string.gsub(option4_effect1_text_uic:GetStateText(), "number", tostring(mkHRE.event_dilemmas[hre_current_event][4]));

			bg_description_txt:SetStateText(description_text);
			option1_button_text_uic:SetStateText(UI_LOCALISATION["hre_support_prefix"]..Get_DFN_Localisation(hre_current_event_faction1)..".");
			option2_button_text_uic:SetStateText(UI_LOCALISATION["hre_support_prefix"]..Get_DFN_Localisation(hre_current_event_faction2)..".");
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

function mkHRE:Event_Pick_Random_Event()
	local chance = cm:random_number(4);

	if chance == 1 then
		self:Event_Pick_Random_Bordering_Factions();

		if hre_current_event_faction1 ~= "" and hre_current_event_faction2 ~= "" then
			cm:trigger_dilemma(mkHRE.emperor_key, "mk_dilemma_hre_border_dispute");
		else
			hre_events_timer = hre_events_timer + 1;
		end
	elseif chance == 2 then
		hre_current_event_faction1 = self:Event_Pick_Random_Faction(false, 1);

		if hre_current_event_faction1 ~= "" then
			cm:trigger_dilemma(mkHRE.emperor_key, "mk_dilemma_hre_imperial_immediacy");
		else
			hre_events_timer = hre_events_timer + 1;
		end
	elseif chance == 3 then
		self:Event_Pick_Random_Bordering_Factions();

		if hre_current_event_faction1 ~= "" and hre_current_event_faction2 ~= "" then
			cm:trigger_dilemma(mkHRE.emperor_key, "mk_dilemma_hre_noble_conflict");
		else
			hre_events_timer = hre_events_timer + 1;
		end
	elseif chance == 4 then
		hre_current_event_faction1 = self:Event_Pick_Random_Faction(false, 1);
		hre_current_event_faction2 = self:Event_Pick_Random_Faction(false, 2);

		if hre_current_event_faction1 ~= "" and hre_current_event_faction2 ~= "" then
			cm:trigger_dilemma(mkHRE.emperor_key, "mk_dilemma_hre_imperial_diet");
		else
			hre_events_timer = hre_events_timer + 1;
		end
	end
end

function mkHRE:Event_Pick_Random_Faction(should_have_bordering_hre_faction, number)
	local hre_factions = {};

	for i = 1, #mkHRE.factions do
		local potential_faction = mkHRE.factions[i];

		-- Make sure we don't get the same faction twice!
		if number == 1 or (number == 2 and hre_current_event_faction1 ~= potential_faction) then
			if potential_faction ~= mkHRE.emperor_key and mkHRE:Get_Faction_State(potential_faction) ~= "puppet" and cm:model():world():faction_by_key(potential_faction):at_war_with(cm:model():world():faction_by_key(mkHRE.emperor_key)) == false then
				if should_have_bordering_hre_faction == true then
					for j = 1, #mkHRE.factions do
						local bordering_faction = mkHRE.factions[j];

						if bordering_faction ~= mkHRE.emperor_key and bordering_faction ~= potential_faction then
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
	end

	if #hre_factions == 0 then
		return "";
	end

 	return hre_factions[cm:random_number(#hre_factions)];
end

function mkHRE:Event_Pick_Random_Bordering_Factions()
	hre_current_event_faction1 = self:Event_Pick_Random_Faction(true, 1); -- Set Faction 1.

	if hre_current_event_faction1 == "" then
		return;
	end

	local bordering_factions = {};

	for i = 1, #mkHRE.factions do
		local potential_faction = mkHRE.factions[i];

		if potential_faction ~= mkHRE.emperor_key and potential_faction ~= hre_current_event_faction1 and mkHRE:Get_Faction_State(potential_faction) ~= "puppet" and cm:model():world():faction_by_key(potential_faction):at_war_with(cm:model():world():faction_by_key(mkHRE.emperor_key)) == false then
			if Does_Faction_Border_Faction(hre_current_event_faction1, potential_faction) then
				table.insert(bordering_factions, potential_faction);
			end
		end
	end

	if #bordering_factions == 0 then
		hre_current_event_faction2 = "";
		return;
	end

	hre_current_event_faction2 = bordering_factions[cm:random_number(#bordering_factions)];
end

function mkHRE:HRE_Event_Reset_Timer()
    -- Set default values if not already defined
    hre_events_turns_between_dilemmas_max = hre_events_turns_between_dilemmas_max or 6
    hre_events_turns_between_dilemmas_min = hre_events_turns_between_dilemmas_min or 3
    
    -- Fix parameter order: min should come before max for cm:random_number
    hre_events_timer = cm:random_number(
        hre_events_turns_between_dilemmas_min,
        hre_events_turns_between_dilemmas_max
    )
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		cm:save_value("hre_current_event", hre_current_event, context);
		cm:save_value("hre_current_event_faction1", hre_current_event_faction1, context);
		cm:save_value("hre_current_event_faction2", hre_current_event_faction2, context);
		cm:save_value("hre_events_timer", hre_events_timer, context);
	end
);

cm:register_loading_game_callback(
	function(context)
		hre_current_event = cm:load_value("hre_current_event", "", context);
		hre_current_event_faction1 = cm:load_value("hre_current_event_faction1", "", context);
		hre_current_event_faction2 = cm:load_value("hre_current_event_faction2", "", context);
		hre_events_timer = cm:load_value("hre_events_timer", -1, context);
	end
);