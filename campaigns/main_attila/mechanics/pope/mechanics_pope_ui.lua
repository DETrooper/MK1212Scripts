--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: POPE UI
-- 	By: DETrooper
--
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------

CHARACTERS_ON_CRUSADE = {};

local dev = require("lua_scripts.dev");

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

	CreateCrusadeButton();
end
	
function CreateCrusadeButton()
	local root = cm:ui_root();
	local army_details = UIComponent(root:Find("button_army_details"))
	local army_detailsX, army_detailsY = army_details:Position()

	root:CreateComponent("Crusade_Button", "UI/new/basic_toggle_crusade");
	local btnCrusade = UIComponent(root:Find("Crusade_Button"));
	btnCrusade:SetMoveable(true);
	btnCrusade:MoveTo(army_detailsX + 60, army_detailsY);
	btnCrusade:SetMoveable(false);
	btnCrusade:PropagatePriority(60);
	btnCrusade:SetTooltipText("Send this army on Crusade!");
	btnCrusade:SetState("inactive"); 
	btnCrusade:SetVisible(false);
end

function CharacterSelected_Pope_UI(context)
	local faction_name = cm:get_local_faction();
	LAST_CHARACTER_SELECTED = context:character();

	if FIFTH_CRUSADE_TRIGGERED == true and FIFTH_CRUSADE_ENDED == false then
		if context:character():faction():state_religion() == "att_rel_chr_catholic" and context:character():faction():name() == faction_name then
			if context:character():military_force():unit_list():num_items() > 1 then
				-- Not an agent or lone general.
				local root = cm:ui_root();
				local btnCrusade = UIComponent(root:Find("Crusade_Button"));
				btnCrusade:SetVisible(true);
				btnCrusade:SetState("inactive"); -- Default to inactive.

				for i = 0, #CHARACTERS_ON_CRUSADE do
					if CHARACTERS_ON_CRUSADE[i] == LAST_CHARACTER_SELECTED:cqi() then
						btnCrusade:SetState("inactive");
						break;
					else
						btnCrusade:SetState("active");
					end
				end
			end
		end
	end
end

function OnComponentMouseOn_Pope_UI(context)
	if context.string == "Crusade_Button" then
		local root = cm:ui_root();
		local btnCrusade = UIComponent(root:Find("Crusade_Button"));
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
	if context.string == "Crusade_Button" then
		local faction_name = LAST_CHARACTER_SELECTED:faction():name();
		local faction = LAST_CHARACTER_SELECTED:faction();

		if CRUSADE_JOINED[faction_name] == "not joined" then
			CRUSADE_JOINED[faction_name] = "joined";

			if faction:at_war_with(cm:model():world():faction_by_key(CURRENT_CRUSADE_TARGET_OWNER)) == false then
				cm:force_declare_war(faction_name, CURRENT_CRUSADE_TARGET_OWNER);
			end

			cm:force_diplomacy(faction_name, CURRENT_CRUSADE_TARGET_OWNER, "peace", false, false);
			cm:force_diplomacy(CURRENT_CRUSADE_TARGET_OWNER, faction_name, "peace", false, false);

			cm:trigger_mission(faction_name, "mk_mission_crusades_take_cairo");

			cm:show_message_event(
				faction_name, 
				"message_event_text_text_mk_event_crusade_fifth_crusade_title", 
				"message_event_text_text_mk_event_crusade_fifth_crusade_joined_primary", 
				"message_event_text_text_mk_event_crusade_fifth_crusade_joined_secondary", 
				true,
				706
			);

			if PLAYER_EXCOMMUNICATED[faction_name] == true then
				Remove_Excommunication_Manual(faction_name);
			end

			Add_Pope_Favour(faction_name, 2, "joined_crusade");
			Update_Pope_Favour(faction);
		end

		local root = cm:ui_root();
		local btnCrusade = UIComponent(root:Find("Crusade_Button"));
		btnCrusade:SetState("inactive");
		table.insert(CHARACTERS_ON_CRUSADE, LAST_CHARACTER_SELECTED:cqi());
		local force = LAST_CHARACTER_SELECTED:cqi();
		cm:apply_effect_bundle_to_characters_force("mk_bundle_army_crusade", force, 0, true);
	elseif context.string == "root" then
		local root = cm:ui_root();
		local btnCrusade = UIComponent(root:Find("Crusade_Button"));
		btnCrusade:SetVisible(false);
	end
end

function FactionTurnEnd_Pope_UI(context)
	if context:faction():is_human() then
		local root = cm:ui_root();
		local btnCrusade = UIComponent(root:Find("Crusade_Button"));
		btnCrusade:SetVisible(false);
	end
end

function OnPanelOpenedCampaign_Pope_UI(context)
	if context.string == "campaign_tactical_map" or context.string == "clan" or context.string == "diplomacy_dropdown" or context.string == "popup_pre_battle" or context.string == "settlement_captured" or context.string == "technology_panel" then
		local root = cm:ui_root();
		local btnCrusade = UIComponent(root:Find("Crusade_Button"));
		btnCrusade:SetVisible(false);
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
		if ARMY_SELECTED == true and FIFTH_CRUSADE_TRIGGERED == true and FIFTH_CRUSADE_ENDED == false then
			local btnCrusade = UIComponent(root:Find("Crusade_Button"));
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