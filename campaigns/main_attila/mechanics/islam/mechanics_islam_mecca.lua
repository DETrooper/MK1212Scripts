----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - ISLAM: MECCA
-- 	By: DETrooper
--
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------

MECCA_REGION_KEY = "att_reg_arabia_magna_yathrib";
MECCA_OCCUPIED = false;
MECCA_RAZER = "nil";

local function Mecca_Destroyed(faction)
	local faction_list = cm:model():world():faction_list();

	for i = 0, faction_list:num_items() - 1 do
		local current_faction = faction_list:item_at(i);
		local current_faction_religion = current_faction:state_religion();
		local current_faction_name = current_faction:name();

		if current_faction:is_human() and MECCA_OCCUPIED == true then
			local faction_string = "factions_screen_name_"..faction:name();

			cm:show_message_event(
				current_faction_name,
				"message_event_text_text_mk_event_mecca_destroyed_title",
				faction_string,
				"message_event_text_text_mk_event_mecca_destroyed_secondary",
				true,
				734
			);
		end

		if current_faction_religion == "att_rel_semitic_paganism" or current_faction_religion == "mk_rel_ibadi_islam" or current_faction_religion == "mk_rel_shia_islam" then
			cm:apply_effect_bundle("mk_bundle_islamic_dejection", current_faction_name, 0);
		end

		cm:remove_effect_bundle("mk_bundle_islam_mecca", current_faction_name);
	end

	cm:apply_effect_bundle("mk_bundle_islams_outcry", faction:name(), 0);

	MECCA_OCCUPIED = true;
end

local function Mecca_Liberated(faction)
	local faction_list = cm:model():world():faction_list();

	for i = 0, faction_list:num_items() - 1 do
		local current_faction = faction_list:item_at(i);
		local current_faction_religion = current_faction:state_religion();
		local current_faction_name = current_faction:name();

		if current_faction:is_human() and MECCA_OCCUPIED == true then
			local faction_string = "factions_screen_name_"..faction:name();

			cm:show_message_event(
				current_faction_name,
				"message_event_text_text_mk_event_mecca_liberated_title",
				faction_string,
				"message_event_text_text_mk_event_mecca_liberated_secondary",
				true,
				733
			);
		end

		cm:remove_effect_bundle("mk_bundle_islamic_dejection", current_faction_name);
		cm:remove_effect_bundle("mk_bundle_islams_outcry", current_faction_name);
	end

	cm:apply_effect_bundle("mk_bundle_islam_mecca", faction:name(), 0);

	MECCA_OCCUPIED = false;
end

local function Mecca_Occupied(faction)
	local faction_list = cm:model():world():faction_list();

	for i = 0, faction_list:num_items() - 1 do
		local current_faction = faction_list:item_at(i);
		local current_faction_religion = current_faction:state_religion();
		local current_faction_name = current_faction:name();

		if current_faction:is_human() and not MECCA_OCCUPIED then
			local faction_string = "factions_screen_name_"..faction:name();

			cm:show_message_event(
				current_faction_name,
				"message_event_text_text_mk_event_mecca_attacked_title",
				faction_string,
				"message_event_text_text_mk_event_mecca_attacked_secondary",
				true,
				732
			);
		end

		if current_faction_religion == "att_rel_semitic_paganism" or current_faction_religion == "mk_rel_ibadi_islam" or current_faction_religion == "mk_rel_shia_islam" then
			cm:apply_effect_bundle("mk_bundle_islamic_dejection", current_faction_name, 0);
		end

		cm:remove_effect_bundle("mk_bundle_islam_mecca", current_faction_name);
	end

	cm:apply_effect_bundle("mk_bundle_islams_outcry", faction:name(), 0);

	MECCA_OCCUPIED = true;
end

function Add_Islam_Mecca_Listeners()
	cm:add_listener(
		"FactionTurnStart_Islam_Mecca",
		"FactionTurnStart",
		true,
		function(context) FactionTurnStart_Islam_Mecca(context) end,
		true
	);
	cm:add_listener(
		"CharacterPerformsOccupationDecisionLoot_Islam_Mecca",
		"CharacterPerformsOccupationDecisionLoot",
		true,
		function(context) CharacterPerformsOccupationDecision_Islam_Mecca(context, "LOOTED") end,
		true
	);
	cm:add_listener(
		"CharacterPerformsOccupationDecisionSack_Islam_Mecca",
		"CharacterPerformsOccupationDecisionSack",
		true,
		function(context) CharacterPerformsOccupationDecision_Islam_Mecca(context, "SACKED") end,
		true 
	);
	cm:add_listener(
		"CharacterPerformsOccupationDecisionOccupy_Islam_Mecca",
		"CharacterPerformsOccupationDecisionOccupy",
		true,
		function(context) CharacterPerformsOccupationDecision_Islam_Mecca(context, "OCCUPY") end,
		true
	);
	cm:add_listener(
		"CharacterPerformsOccupationDecisionRaze_Population",
		"CharacterPerformsOccupationDecisionRaze",
		true,
		function(context) CharacterPerformsOccupationDecision_Islam_Mecca(context, "RAZE") end,
		true
	);
	cm:add_listener(
		"FactionReligionConverted_Islam_Mecca",
		"FactionReligionConverted",
		true,
		function(context) Check_Mecca_Owner() end,
		true
	);

	if cm:is_new_game() then
		Check_Mecca_Owner();
	end
end

function Check_Mecca_Owner()
	local mecca = cm:model():world():region_manager():region_by_key(MECCA_REGION_KEY);
	local mecca_owner = mecca:owning_faction();

	if mecca_owner and mecca_owner:is_null_interface() ~= true then
		if mecca_owner:name() == "rebels" then
			-- Razed!
			if MECCA_RAZER ~= "nil" then
				Mecca_Destroyed(MECCA_RAZER);
			end
		else
			local mecca_owner_religion = mecca_owner:state_religion();

			if mecca_owner_religion ~= "att_rel_semitic_paganism" and mecca_owner_religion ~= "mk_rel_ibadi_islam" and mecca_owner_religion ~= "mk_rel_shia_islam" then
				if not MECCA_OCCUPIED then
					Mecca_Occupied(mecca_owner);
				else
					cm:apply_effect_bundle("mk_bundle_islams_outcry", mecca_owner:name(), 0);
				end
			else
				if MECCA_OCCUPIED then
					Mecca_Liberated(mecca_owner)
				else
					cm:apply_effect_bundle("mk_bundle_islam_mecca", mecca_owner:name(), 0);
				end
			end
		end
	end
end

function FactionTurnStart_Islam_Mecca(context)
	if context:faction():is_human() then
		local faction_list = cm:model():world():faction_list();

		for i = 0, faction_list:num_items() - 1 do
			local current_faction_name = faction_list:item_at(i):name();

			cm:remove_effect_bundle("mk_bundle_islamic_dejection", current_faction_name);
			cm:remove_effect_bundle("mk_bundle_islams_outcry", current_faction_name);
			cm:remove_effect_bundle("mk_bundle_islam_mecca", current_faction_name);
		end

		Check_Mecca_Owner();
	end
end

function CharacterPerformsOccupationDecision_Islam_Mecca(context, type)
	local region = FindClosestRegion(context:character():logical_position_x(), context:character():logical_position_y(), "none"); -- Taking the character's region may be inaccurate if they're at sea or across a strait.

	if region then
		local region_name = region:name();

		if region_name == MECCA_REGION_KEY then
			if type == "RAZE" then
				Mecca_Destroyed(faction);
			elseif SackExploitCheck_Pope(region_name) == true then
				local faction = context:character():faction();
				local religion = faction:state_religion();

				if religion == "att_rel_semitic_paganism" or religion == "mk_rel_ibadi_islam" or religion == "mk_rel_shia_islam" then
					if MECCA_OCCUPIED then
						Mecca_Liberated(faction);
					else
						local faction_list = cm:model():world():faction_list();
						
						for i = 0, faction_list:num_items() - 1 do
							local current_faction_name = faction_list:item_at(i):name();
							
							cm:remove_effect_bundle("mk_bundle_islam_mecca", current_faction_name);
						end

						cm:apply_effect_bundle("mk_bundle_islam_mecca", faction:name(), 0);
					end
				else
					Mecca_Occupied(faction);
				end
			end
		end
	end
end

cm:register_saving_game_callback(
	function(context)
		cm:save_value("MECCA_OCCUPIED", MECCA_OCCUPIED, context);
		cm:save_value("MECCA_RAZER", MECCA_RAZER, context);
	end
);

cm:register_loading_game_callback(
	function(context)
		MECCA_OCCUPIED = cm:load_value("MECCA_OCCUPIED", false, context);
		MECCA_RAZER = cm:load_value("MECCA_RAZER", "nil", context);
	end
);
