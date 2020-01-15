----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - STARTING BATTLES: LAS NAVAS
-- 	By: DETrooper
--
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------

LAS_NAVAS_X = 111
LAS_NAVAS_Y = 310

ALMOHADS_KEY = "mk_fact_almohads";
ARAGON_KEY = "mk_fact_aragon";
CASTILE_KEY = "mk_fact_castile";
NAVARRE_KEY = "mk_fact_navarre";

BATTLE_LAS_NAVAS_OCCURED = false;

function Add_Las_Navas_Listeners()
	local almohads = cm:model():world():faction_by_key(ALMOHADS_KEY);
	local aragon = cm:model():world():faction_by_key(ARAGON_KEY);
	local castile = cm:model():world():faction_by_key(CASTILE_KEY);
	local navarre = cm:model():world():faction_by_key(NAVARRE_KEY);

	if almohads:is_human() == true or aragon:is_human() == true or castile:is_human() == true or navarre:is_human() == true then
		if BATTLE_LAS_NAVAS_OCCURED == false then
			cm:add_listener(
				"BattleCompleted_Las_Navas",
				"BattleCompleted",
				true,
				function(context) BattleCompleted_Las_Navas(context) end,
				true
			);
			cm:add_listener(
				"OnComponentLClickUp_Las_Navas_UI",
				"ComponentLClickUp",
				true,
				function(context) OnComponentLClickUp_Las_Navas_UI(context) end,
				true
			);
		end

		if cm:is_new_game() then
			if almohads:is_human() == true then
				Las_Navas_Setup(ALMOHADS_KEY);
			elseif aragon:is_human() == true then
				Las_Navas_Setup(ARAGON_KEY);
			elseif castile:is_human() == true then
				Las_Navas_Setup(CASTILE_KEY);
			elseif navarre:is_human() == true then
				Las_Navas_Setup(NAVARRE_KEY);
			end
		end
	else
		if cm:is_new_game() then
			-- No factions are human, so let's give Navarra some units, otherwise the 6 AI armies will stand there for years too scared to attack.

			local navarre_commander = get_closest_commander_to_position_from_faction(
				navarre,
				LAS_NAVAS_X, 
				LAS_NAVAS_Y, 
				true
			);

			cm:add_unit_to_force("mk_cas_t1_spear_militia", navarre_commander:military_force():command_queue_index());
			cm:add_unit_to_force("mk_cas_t1_spear_militia", navarre_commander:military_force():command_queue_index());
			cm:add_unit_to_force("mk_cas_t1_almocaden", navarre_commander:military_force():command_queue_index());
			cm:add_unit_to_force("mk_cas_t1_almocaden", navarre_commander:military_force():command_queue_index());
			cm:add_unit_to_force("mk_cas_t1_almocaden", navarre_commander:military_force():command_queue_index());
			cm:add_unit_to_force("mk_cas_t1_almocaden", navarre_commander:military_force():command_queue_index());
		end
	end
end

function Las_Navas_Setup(faction_name)
	local almohads = cm:model():world():faction_by_key(ALMOHADS_KEY);
	local aragon = cm:model():world():faction_by_key(ARAGON_KEY);
	local castile = cm:model():world():faction_by_key(CASTILE_KEY);
	local navarre = cm:model():world():faction_by_key(NAVARRE_KEY);

	local almohads_gen_string = char_lookup_str(
		get_closest_commander_to_position_from_faction(
			almohads,
			LAS_NAVAS_X, 
			LAS_NAVAS_Y, 
			true
		)
	);
	local aragon_gen_string = char_lookup_str(
		get_closest_commander_to_position_from_faction(
			aragon,
			LAS_NAVAS_X, 
			LAS_NAVAS_Y, 
			true
		)
	);
	local castile_gen_string = char_lookup_str(
		get_closest_commander_to_position_from_faction(
			castile,
			LAS_NAVAS_X, 
			LAS_NAVAS_Y, 
			true
		)
	);
	local navarre_gen_string = char_lookup_str(
		get_closest_commander_to_position_from_faction(
			navarre,
			LAS_NAVAS_X, 
			LAS_NAVAS_Y, 
			true
		)
	);

	cm:override_ui("disable_prebattle_retreat", true);

	if faction_name == ALMOHADS_KEY then
		cm:attack(almohads_gen_string, castile_gen_string, true);
	elseif faction_name == ARAGON_KEY then
		cm:attack(aragon_gen_string, almohads_gen_string, true);
	elseif faction_name == CASTILE_KEY then
		cm:attack(castile_gen_string, almohads_gen_string, true);
	elseif faction_name == NAVARRE_KEY then
		cm:attack(navarre_gen_string, almohads_gen_string, true);
	end
end

function BattleCompleted_Las_Navas(context)
	local attacker_cqi, attacker_force_cqi, attacker_name = cm:pending_battle_cache_get_attacker(1);
	local defender_cqi, defender_force_cqi, defender_name = cm:pending_battle_cache_get_defender(1);
	local attacker_result = cm:model():pending_battle():attacker_battle_result();
	local defender_result = cm:model():pending_battle():defender_battle_result();

	if BATTLE_LAS_NAVAS_OCCURED == false then
		if attacker_name == ALMOHADS_KEY or attacker_name == ARAGON_KEY or attacker_name == CASTILE_KEY or attacker_name == NAVARRE_KEY then
			BATTLE_LAS_NAVAS_OCCURED = true;
			cm:override_ui("disable_prebattle_retreat", false);

			if attacker_result == "heroic_victory" or attacker_result == "decisive_victory" or attacker_result == "close_victory" or attacker_result == "pyrrhic_victory" then
				cm:apply_effect_bundle("mk_bundle_las_navas_victory", attacker_name, 10);
			else
				cm:apply_effect_bundle("mk_bundle_las_navas_victory", defender_name, 10);
			end

			cm:remove_listener("BattleCompleted_Las_Navas");
		end
	end
end

function OnComponentLClickUp_Las_Navas_UI(context)
	if context.string == "button_attack" then
		if FACTION_TURN == ALMOHADS_KEY or FACTION_TURN == ARAGON_KEY or FACTION_TURN == CASTILE_KEY or FACTION_TURN == NAVARRE_KEY then
			CampaignUI.OverrideLoadingScreenText("MK1212.Las_Navas_Loading_Screen_Override");
		end
	end
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		cm:save_value("BATTLE_LAS_NAVAS_OCCURED", BATTLE_LAS_NAVAS_OCCURED, context);
	end
);

cm:register_loading_game_callback(
	function(context)
		BATTLE_LAS_NAVAS_OCCURED = cm:load_value("BATTLE_LAS_NAVAS_OCCURED", false, context);
	end
);