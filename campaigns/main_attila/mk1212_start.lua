-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
--	CAMPAIGN SCRIPT
--
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------

local fow_disabled = false;

function start_game_all_factions()
	local faction_list = cm:model():world():faction_list();

	if cm:is_new_game() then
		for i = 0, faction_list:num_items() - 1 do
			local current_faction = faction_list:item_at(i);

			if current_faction:is_human() then
				cm:show_message_event(
					current_faction:name(),
					"message_event_text_text_mk_event_mk1212_intro_title", 
					"message_event_text_text_mk_event_mk1212_intro_primary", 
					"message_event_text_text_mk_event_mk1212_intro_secondary", 
					true, 
					700
				);
			end

			-- Also remove useless faction group traits.
			cm:remove_effect_bundle("mk_group_trait_gallia_et_frisia", current_faction:name());
			cm:remove_effect_bundle("mk_group_trait_germania", current_faction:name());
			cm:remove_effect_bundle("mk_group_trait_haemus_et_carpathia", current_faction:name());
			cm:remove_effect_bundle("mk_group_trait_hispania_et_africa", current_faction:name());
			cm:remove_effect_bundle("mk_group_trait_italia", current_faction:name());
			cm:remove_effect_bundle("mk_group_trait_magna_persia", current_faction:name());
			cm:remove_effect_bundle("mk_group_trait_mare_germanicum", current_faction:name());
			cm:remove_effect_bundle("mk_group_trait_pontus-caspia", current_faction:name());
			cm:remove_effect_bundle("mk_group_trait_ruthenia_et_balticus", current_faction:name());
			cm:remove_effect_bundle("mk_group_trait_sinus_arabicus", current_faction:name());
			cm:remove_effect_bundle("mk_group_trait_terra_sancta_et_asia", current_faction:name());
		end
	end

	-- Vanilla scripts.
	start_general_ability_trait_system();

	-- Temporary stuff.
	Add_Stopgap_Listeners();

	-- MK1212 scripts.
	Add_MK1212_Discord_Listeners();
	Add_MK1212_Slots_Listeners();
	Common_Initializer();
	Challenge_Initializer();
	Byzantium_Initializer();
	Ironman_Initializer();
	Kingdom_Initializer();
	Lucky_Nations_Initializer();
	Mechanic_Initializer();
	Mongol_Initializer();
	Nicknames_Initializer();
	Starting_Battles_Initializer();
	Story_Initializer();
	Timurid_Initializer();

	if cm:is_multiplayer() then
		--Add_MK1212_Networking_Listeners();
	else
		Add_MK1212_Change_Capital_Listeners();
	end

	if fow_disabled then
		local region_list = cm:model():world():region_manager():region_list();

		for i = 0, region_list:num_items() - 1 do
			local region_name = region_list:item_at(i):name();

			cm:make_region_visible_in_shroud(cm:get_local_faction(), region_name);
		end
	end
end;

--------------------------------------------------------------------------------------------------------------------
-- Include R2TR scripts
--------------------------------------------------------------------------------------------------------------------

-- Enabling this seems to cause a 'Save Failed' error, not entirely sure why.

--[[require("lua_scripts.logging_callbacks");

dev.log("scripting.lua ended, all R2TR scripts loaded successfully\n");]]--
