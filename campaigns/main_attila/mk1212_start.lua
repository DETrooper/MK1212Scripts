-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
--	CAMPAIGN SCRIPT
--
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------

function start_game_all_factions()
	local faction_list = cm:model():world():faction_list();

	if cm:is_new_game() then
		for i = 0, faction_list:num_items() - 1 do
			local current_faction = faction_list:item_at(i);
			cm:show_message_event(
				current_faction:name(),
				"message_event_text_text_mk_event_mk1212_intro_title", 
				"message_event_text_text_mk_event_mk1212_intro_primary", 
				"message_event_text_text_mk_event_mk1212_intro_secondary", 
				true, 
				700
			);

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
	Common_Initializer();
	Challenge_Initializer();
	Byzantium_Initializer();
	--Islamic_Initializer();
	Ironman_Initializer();
	Kingdom_Initializer();
	Mechanic_Initializer();
	Mongol_Initializer();
	Starting_Battles_Initializer();
	Story_Initializer();
	Timurid_Initializer();

	--if cm:is_multiplayer() then
		--Add_MK1212_Networking_Listeners();
	--end
end;

--------------------------------------------------------------------------------------------------------------------
-- Include R2TR scripts
--------------------------------------------------------------------------------------------------------------------

-- Enabling this seems to cause a 'Save Failed' error, not entirely sure why.

--[[local dev = require("lua_scripts.dev");

require("lua_scripts.logging_callbacks");

dev.log("scripting.lua ended, all R2TR scripts loaded successfully\n");]]--
