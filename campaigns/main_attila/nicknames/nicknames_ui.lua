-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - NICKNAMES: UI
-- 	By: DETrooper
--
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------

local CharacterInfoPopup_uic = nil;

function Add_Nicknames_UI_Listeners()
	cm:add_listener(
		"CharacterSelected_Nicknames",
		"CharacterSelected",
		true,
		function(context) CharacterSelected_Nicknames(context) end,
		true
	);
	cm:add_listener(
		"ComponentMouseOn_Nicknames",
		"ComponentMouseOn",
		true,
		function(context) ComponentMouseOn_Nicknames(context) end,
		true
	);
	cm:add_listener(
		"ComponentLClickUp_Nicknames",
		"ComponentLClickUp",
		true,
		function(context) ComponentLClickUp_Nicknames(context) end,
		true
	);
	cm:add_listener(
		"PanelOpenedCampaign_Nicknames",
		"PanelOpenedCampaign",
		true,
		function(context) PanelOpenedCampaign_Nicknames(context) end,
		true
	);
	cm:add_listener(
		"PanelClosedCampaign_Nicknames",
		"PanelClosedCampaign",
		true,
		function(context) PanelClosedCampaign_Nicknames(context) end,
		true
	);
	cm:add_listener(
		"TimeTrigger_Nicknames",
		"TimeTrigger",
		true,
		function(context) TimeTrigger_Nicknames(context) end,
		true
	);

	CharacterInfoPopup_uic = UIComponent(cm:ui_root():Find("CharacterInfoPopup"));
end

function CharacterSelected_Nicknames(context)
	cm:add_time_trigger("Character_Nickname", 0.0);
end

function ComponentMouseOn_Nicknames(context)
	cm:add_time_trigger("Character_Nickname", 0.0);
end

function ComponentLClickUp_Nicknames(context)
	if context.string == "tab_units" then
		cm:add_time_trigger("Check_Tab_Units_Nickname", 0.0);
	elseif DIPLOMACY_PANEL_OPEN == true then
		if context.string == "map" or context.string == "button_icon" or context.string == "flag" or string.find(context.string, "faction_row_entry_") then
			cm:add_time_trigger("Character_Nickname_Diplomacy", 0.1);
		end
	end
end

function PanelOpenedCampaign_Nicknames(context)
	if context.string == "army_details_panel" then
		cm:add_time_trigger("Character_Nickname_Details", 0.0);
	elseif context.string == "diplomacy_dropdown" then
		cm:add_time_trigger("Character_Nickname_Diplomacy", 0.1);
	end
end

function PanelClosedCampaign_Nicknames(context)
	cm:add_time_trigger("Character_Nickname", 0.0);
	cm:add_time_trigger("Check_Tab_Units_Nickname", 0.0);
end

function TimeTrigger_Nicknames(context)
	if context.string == "Character_Nickname" then
		if CharacterInfoPopup_uic:Visible() then
			if LAST_CHARACTER_SELECTED then
				local character_cqi = LAST_CHARACTER_SELECTED:cqi();
				local character_nickname = CHARACTERS_TO_NICKNAMES[tostring(character_cqi)];

				if character_nickname then
					local root = cm:ui_root();
					local dy_name_uic = find_uicomponent_by_table(root, {"layout", "info_panel_holder", "info_panel_background", "CharacterInfoPopup", "subpanel_character", "dy_name"});
					local character_nickname_loc = NICKNAMES_TO_LOCALISATION[character_nickname];

					if dy_name_uic then
						local character_name = dy_name_uic:GetStateText();

						-- Make sure the character name does not already contain the nickname.
						if not string.find(character_name, character_nickname_loc) then
							dy_name_uic:SetStateText(character_name.." "..character_nickname_loc);
						end
					end
				end
			end
		end
	elseif context.string == "Character_Nickname_Details" then
		if LAST_CHARACTER_SELECTED then
			local character_cqi = LAST_CHARACTER_SELECTED:cqi();
			local character_nickname = CHARACTERS_TO_NICKNAMES[tostring(character_cqi)];

			if character_nickname then
				local root = cm:ui_root();
				local dy_name_uic = find_uicomponent_by_table(root, {"panel_manager", "army_details_panel", "character_details_subpanel", "dy_name"});
				local dy_commander_uic = find_uicomponent_by_table(root, {"panel_manager", "army_details_panel", "army_details", "tx_commander", "dy_commander"});
				local character_nickname_loc = NICKNAMES_TO_LOCALISATION[character_nickname];

				if dy_name_uic then
					local character_name = dy_name_uic:GetStateText();

					-- Make sure the character name does not already contain the nickname.
					if not string.find(character_name, character_nickname_loc) then
						dy_name_uic:SetStateText(character_name.." "..character_nickname_loc);
					end
				end

				if dy_commander_uic then
					local character_commander_name = dy_commander_uic:GetStateText();

					-- Make sure the character name does not already contain the nickname.
					if not string.find(character_commander_name, character_nickname_loc) then
						dy_commander_uic:SetStateText(character_commander_name.." "..character_nickname_loc);
					end
				end
			end
		end
	elseif context.string == "Character_Nickname_Diplomacy" then
		local root = cm:ui_root();
		local diplomacy_dropdown_uic = UIComponent(root:Find("diplomacy_dropdown"));
		local faction_left_faction_leader = cm:model():world():faction_by_key(cm:get_local_faction()):faction_leader();

		if faction_left_faction_leader then
			local character_cqi = faction_left_faction_leader:cqi();
			local character_nickname = CHARACTERS_TO_NICKNAMES[tostring(character_cqi)];

			if character_nickname then
				local faction_left_status_panel_uic = UIComponent(diplomacy_dropdown_uic:Find("faction_left_status_panel"));
				local name_holder_uic = UIComponent(faction_left_status_panel_uic:Find("name_holder"));
				local dy_name_uic = UIComponent(name_holder_uic:Find("dy_name"));
				local character_nickname_loc = NICKNAMES_TO_LOCALISATION[character_nickname];

				if dy_name_uic then
					local character_name = dy_name_uic:GetStateText();
	
					-- Make sure the character name does not already contain the nickname.
					if not string.find(character_name, character_nickname_loc) then
						dy_name_uic:SetStateText(character_name.." "..character_nickname_loc);
					end
				end
			end
		end

		if DIPLOMACY_SELECTED_FACTION and DIPLOMACY_SELECTED_FACTION ~= cm:get_local_faction() then
			local faction_right_faction_leader = cm:model():world():faction_by_key(DIPLOMACY_SELECTED_FACTION):faction_leader();

			if faction_right_faction_leader then
				local character_cqi = faction_right_faction_leader:cqi();
				local character_nickname = CHARACTERS_TO_NICKNAMES[tostring(character_cqi)];

				if character_nickname then
					local faction_right_status_panel_uic = UIComponent(diplomacy_dropdown_uic:Find("faction_right_status_panel"));
					local name_holder_uic = UIComponent(faction_right_status_panel_uic:Find("name_holder"));
					local dy_name_uic = UIComponent(name_holder_uic:Find("dy_name"));
					local character_nickname_loc = NICKNAMES_TO_LOCALISATION[character_nickname];

					if dy_name_uic then
						local character_name = dy_name_uic:GetStateText();
		
						-- Make sure the character name does not already contain the nickname.
						if not string.find(character_name, character_nickname_loc) then
							dy_name_uic:SetStateText(character_name.." "..character_nickname_loc);
						end
					end
				end
			end
		end
	elseif context.string == "Check_Tab_Units_Nickname" then
		local root = cm:ui_root();
		local layout_uic = UIComponent(root:Find("layout"));
		local bar_small_top_uic = UIComponent(layout_uic:Find("bar_small_top"));
		local tab_units_uic = UIComponent(bar_small_top_uic:Find("tab_units"));
		local units_dropdown_uic = UIComponent(root:Find("units_dropdown"));

		if tab_units_uic:CurrentState() == "selected" or tab_units_uic:CurrentState() == "selected_hover" then
			-- The unit dropdown panel is open.
			local sortable_list_units_uic = UIComponent(units_dropdown_uic:Find("sortable_list_units"));
			local list_box_uic = UIComponent(sortable_list_units_uic:Find("list_box"));

			for i = 0, list_box_uic:ChildCount() - 1 do
				local child = UIComponent(list_box_uic:Find(i));

				if string.find(child:Id(), "character_row_") then
					local character_cqi = string.gsub(child:Id(), "character_row_", "");
					local character_nickname = CHARACTERS_TO_NICKNAMES[character_cqi];
					local character_nickname_loc = NICKNAMES_TO_LOCALISATION[character_nickname];
					local dy_character_name_uic = UIComponent(child:Find("dy_character_name"));

					if character_nickname then
						local character_name = dy_character_name_uic:GetStateText();

						-- Make sure the character name does not already contain the nickname.
						if not string.find(character_name, character_nickname_loc) then
							dy_character_name_uic:SetStateText(character_name.." "..character_nickname_loc);
						end
					end
				end
			end
		end
	end
end
