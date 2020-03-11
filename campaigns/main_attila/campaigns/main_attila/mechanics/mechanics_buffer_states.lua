-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: BUFFER STATES
-- 	By: DETrooper
--
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

function Add_Buffer_States_Listeners()
	cm:add_listener(
		"OnComponentMouseOn_Buffer_UI",
		"ComponentMouseOn",
		true,
		function(context) OnComponentMouseOn_Buffer_UI(context) end,
		true
	);
	cm:add_listener(
		"OnComponentLClickUp_Buffer_UI",
		"ComponentLClickUp",
		true,
		function(context) OnComponentLClickUp_Buffer_UI(context) end,
		true
	);
	cm:add_listener(
		"SettlementSelected_Buffer",
		"SettlementSelected",
		true,
		function(context) OnSettlementSelected_Buffer(context) end,
		true
	);
	cm:add_listener(
		"SettlementDeselected_Buffer",
		"SettlementDeselected",
		true,
		function(context) OnSettlementDeselected_Buffer(context) end,
		true
	);
	cm:add_listener(
		"TimeTrigger_Buffer",
		"TimeTrigger",
		true,
		function(context) OnTimeTrigger_Buffer(context) end,
		true
	);

	CreateBufferButton();
end

function CreateBufferButton()
	local root = cm:ui_root();
	local army_details = UIComponent(root:Find("button_army_details"))
	local army_detailsX, army_detailsY = army_details:Position();

	root:CreateComponent("Buffer_Button", "UI/new/basic_toggle_buffer");
	local btnBuffer = UIComponent(root:Find("Buffer_Button"));
	btnBuffer:SetMoveable(true);
	btnBuffer:MoveTo(army_detailsX + 60, army_detailsY);
	btnBuffer:SetMoveable(false);
	btnBuffer:PropagatePriority(60);
	btnBuffer:SetTooltipText("Release a vassalized buffer state faction in this region.");
	btnBuffer:SetState("inactive"); 
	btnBuffer:SetVisible(false);

	root:CreateComponent("Buffer_Warning", "UI/new/buffer_warning");
	local panBufferWarning = UIComponent(root:Find("Buffer_Warning"));
	local curX, curY = panBufferWarning:Position();

	UIComponent(panBufferWarning:Find("heading_txt")):SetStateText("Release Buffer State?");
	UIComponent(panBufferWarning:Find("dy_buffer_info")):SetStateText("Faction: ".."\nRegion: ");
	UIComponent(panBufferWarning:Find("txt")):SetStateText("This faction will become your vassal.");

	panBufferWarning:SetVisible(false);
end

function OnComponentMouseOn_Buffer_UI(context)
	if context.string == "Buffer_Button" then
		local root = cm:ui_root();
		local btnBuffer = UIComponent(root:Find("Buffer_Button"));

		btnBuffer:SetTooltipText("Release a vassalized buffer state faction in this region.");
	end
end

function OnComponentLClickUp_Buffer_UI(context)
	if context.string == "Buffer_Button" then
		local root = cm:ui_root();
		local panBufferWarning = UIComponent(root:Find("Buffer_Warning"));
	
		if panBufferWarning:Visible() == false then
			local faction_string = FACTIONS_NAMES_LOCALISATION[REGIONS_LIBERATION_FACTIONS[REGION_SELECTED]];
			local region_string = REGIONS_NAMES_LOCALISATION[REGION_SELECTED];
			local dy_buffer_info_uic = UIComponent(panBufferWarning:Find("dy_buffer_info"));
			local scroll_frame_uic = UIComponent(panBufferWarning:Find("scroll_frame"));

			dy_buffer_info_uic:SetStateText("Faction: "..faction_string.."\nRegion: "..region_string);

			scroll_frame_uic:DestroyChildren();
			scroll_frame_uic:CreateComponent("faction_logo", "UI/new/faction_flags/"..REGIONS_LIBERATION_FACTIONS[REGION_SELECTED].."_flag_big");

			local faction_logo_uic = UIComponent(scroll_frame_uic:Find(0));
			local scroll_frame_uicX, scroll_frame_uicY = scroll_frame_uic:Position();
			faction_logo_uic:SetMoveable(true);
			faction_logo_uic:MoveTo(scroll_frame_uicX + 152, scroll_frame_uicY + 70);
			faction_logo_uic:SetMoveable(false);

			panBufferWarning:SetVisible(true);
		else
			BufferPanelClosed();
		end
	elseif context.string == "button_buffer_confirm" then
		local faction_name = FACTION_TURN;
		local faction = cm:model():world():faction_by_key(faction_name);
		local vassal_faction_name = REGIONS_LIBERATION_FACTIONS[REGION_SELECTED];
		local vassal_faction = cm:model():world():faction_by_key(vassal_faction_name);

		local spear_unit = BUFFER_STATE_SPEAR_UNITS[vassal_faction_name];
		local unit_list = spear_unit..","..spear_unit..","..spear_unit..","..spear_unit;

		if not FactionIsAlive(vassal_faction_name) then
			local region = cm:model():world():region_manager():region_by_key(REGION_SELECTED);
			local region_x = region:settlement():logical_position_x();
			local region_y = region:settlement():logical_position_y();

			cm:create_force(
				vassal_faction_name,
				unit_list,
				REGION_SELECTED,
				region_x,
				region_y,
				"VassalArmy_"..REGION_SELECTED..cm:model():turn_number(),
				true,
				function(cqi) 

				end
			);

			cm:force_make_vassal(faction_name, vassal_faction_name);
			cm:add_time_trigger("region_transfer", 0.1);

			if FACTIONS_VASSALIZED ~= nil then
				table.insert(FACTIONS_VASSALIZED, vassal_faction_name);
			else
				FACTIONS_VASSALIZED = {};
				table.insert(FACTIONS_VASSALIZED, vassal_faction_name);
			end
		else
			cm:transfer_region_to_faction(REGION_SELECTED, vassal_faction_name);
		end

		BufferPanelClosed();
		local root = cm:ui_root();
		local btnBuffer = UIComponent(root:Find("Buffer_Button"));
		btnBuffer:SetVisible(false);
	elseif context.string == "button_buffer_cancel" then
		BufferPanelClosed();
	elseif context.string == "root" then
		local root = cm:ui_root();
		local btnBuffer = UIComponent(root:Find("Buffer_Button"));
		btnBuffer:SetVisible(false);
	end
end

function OnSettlementSelected_Buffer(context)
	local faction_name = FACTION_TURN;
	local region_name = context:garrison_residence():region():name();
	local region_owner_name = context:garrison_residence():region():owning_faction():name();

	if region_owner_name == faction_name then
		local vassal_faction = cm:model():world():faction_by_key(REGIONS_LIBERATION_FACTIONS[region_name]);

		if not FactionIsAlive(REGIONS_LIBERATION_FACTIONS[region_name]) then
			local root = cm:ui_root();
			local btnBuffer = UIComponent(root:Find("Buffer_Button"));

			if cm:get_local_faction() == FACTION_TURN then
				btnBuffer:SetState("active"); 
				btnBuffer:SetVisible(true);
			end
		else
			if btnBuffer:Visible() == true then
				btnBuffer:SetState("inactive"); 
				btnBuffer:SetVisible(false);
			end
		end
	else
		if btnBuffer:Visible() == true then
			btnBuffer:SetState("inactive"); 
			btnBuffer:SetVisible(false);
		end
	end
end

function OnSettlementDeselected_Buffer(context)
	local root = cm:ui_root();
	local btnBuffer = UIComponent(root:Find("Buffer_Button"));

	if btnBuffer:Visible() == true then
		btnBuffer:SetState("inactive"); 
		btnBuffer:SetVisible(false);
	end
end

function OnTimeTrigger_Buffer(context)
	if context.string == "region_transfer" then
		if cm:model():world():region_manager():region_by_key(REGION_SELECTED):has_governor() then
			local governor = cm:model():world():region_manager():region_by_key(REGION_SELECTED):governor():command_queue_index();
			cm:set_character_immortality("character_cqi:"..governor, true);
			cm:transfer_region_to_faction(REGION_SELECTED, REGIONS_LIBERATION_FACTIONS[REGION_SELECTED]);
			cm:set_character_immortality("character_cqi:"..governor, false);
		else
			cm:transfer_region_to_faction(REGION_SELECTED, REGIONS_LIBERATION_FACTIONS[REGION_SELECTED]);
		end
	end
end

function BufferPanelClosed()
	local root = cm:ui_root();
	local panBufferWarning = UIComponent(root:Find("Buffer_Warning"));
	local btnBuffer = UIComponent(root:Find("Buffer_Button"));

	panBufferWarning:SetVisible(false);
	btnBuffer:SetState("active");
end