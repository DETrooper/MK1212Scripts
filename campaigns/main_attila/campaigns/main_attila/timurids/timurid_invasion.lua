------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - TIMURIDS: TIMURID INVASION
-- 	By: DETrooper
-- 	Some elements taken from The Last Roman.
--
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
-- Gives the Timurids armies, controls their events, and so-forth.

TIMURIDS_KEY = "mk_fact_timurids";

TIMURID_INVASION_STARTED = false;
TIMURID_INVASION_TURN = 169;
TIMURID_PROTECTION_TURNS = 5; -- How many turns after the invasion turn should the Timurids be protected?

MIN_ARMY_STRENGTH_FORCES = 4; -- # of armies.
MIN_ARMY_STRENGTH_UNITS = 14; -- # of units before an army is considered too small.
MIN_ARMY_STRENGTH_PERCENT = 65; -- # of men left in an army on average before the army is considered too small.

function Add_Timurid_Invasion_Listeners()
	cm:add_listener(
		"FactionTurnStart_Timurid_Preservation",
		"FactionTurnStart",
		true,
		function(context) FactionTurnStart_Timurid_Preservation(context) end,
		true
	);
	cm:add_listener(
		"BattleCompleted_Timurid_Preservation",
		"BattleCompleted",
		true,
		function(context) OnBattleCompleted_Timurid_Preservation(context) end,
		true
	);
	cm:add_listener(
		"TimeTrigger_Timurid_Invasion",
		"TimeTrigger",
		true,
		function(context) TimeTrigger_Timurid_Invasion(context) end,
		true
	);
end

function FactionTurnStart_Timurid_Preservation(context)
	local turn_number = cm:model():turn_number();

	if context:faction():name() == TIMURIDS_KEY then
		if TIMURID_INVASION_STARTED == true and turn_number < TIMURID_INVASION_TURN + TIMURID_PROTECTION_TURNS then
			TimuridArmyChecks(TIMURIDS_KEY);
		end
	end

	if turn_number == TIMURID_INVASION_TURN and TIMURID_INVASION_STARTED == false then
		TIMURID_INVASION_STARTED = true;

		SpawnTimuridArmyInZone(TIMURIDS_KEY, TIMURID_INVASION_ARMY, "att_reg_scythia_sarai", TIMURID_SPAWN_ZONE);
		SpawnTimuridArmyInZone(TIMURIDS_KEY, TIMURID_INVASION_ARMY, "att_reg_scythia_sarai", TIMURID_SPAWN_ZONE);
		SpawnTimuridArmyInZone(TIMURIDS_KEY, TIMURID_INVASION_ARMY, "att_reg_scythia_sarai", TIMURID_SPAWN_ZONE);
		SpawnTimuridArmyInZone(TIMURIDS_KEY, TIMURID_ALT_INVASION_ARMY, "att_reg_scythia_sarai", TIMURID_SPAWN_ZONE);
		SpawnTimuridArmyInZone(TIMURIDS_KEY, TIMURID_ALT_INVASION_ARMY, "att_reg_scythia_sarai", TIMURID_SPAWN_ZONE);

		cm:force_change_cai_faction_personality(TIMURIDS_KEY, "att_expansionist_dominator_aggressive_variant_cultural_dislikes_sassanids");
		--cm:add_time_trigger("timurid_war", 0.1);

		local faction_name = (cm:model():faction_for_command_queue_index(HUMAN_FACTIONS[1])):name();
		cm:show_message_event(
			faction_name,
			"message_event_text_text_mk_event_timurid_invasion_title",
			"message_event_text_text_mk_event_timurid_invasion_primary",
			"message_event_text_text_mk_event_timurid_invasion_secondary",
			true,
			715
		);

		if HUMAN_FACTIONS[2] ~= nil then 
			local faction_name = (cm:model():faction_for_command_queue_index(HUMAN_FACTIONS[2])):name();
			cm:show_message_event(
				faction_name,
				"message_event_text_text_mk_event_timurid_invasion_title",
				"message_event_text_text_mk_event_timurid_invasion_primary",
				"message_event_text_text_mk_event_timurid_invasion_secondary",
				true,
				715
			);
		end
	end
end

function OnBattleCompleted_Timurid_Preservation(context)
	local turn_number = cm:model():turn_number();

	if turn_number < TIMURID_INVASION_TURN + TIMURID_PROTECTION_TURNS then
		local pending_battle = cm:model():pending_battle();
		local attacker_result = pending_battle:attacker_battle_result();
		local defender_result = pending_battle:defender_battle_result();

		if pending_battle:has_attacker() then
			if pending_battle:attacker():has_military_force() and pending_battle:attacker():faction():is_human() == false and pending_battle:attacker():faction():name() == TIMURIDS_KEY then
				TimuridArmyChecks(pending_battle:attacker():faction():name());
			end
		end
	
		if pending_battle:has_defender() then
			if pending_battle:defender():has_military_force() and pending_battle:defender():faction():is_human() == false and pending_battle:defender():faction():name() == TIMURIDS_KEY then
				TimuridArmyChecks(pending_battle:defender():faction():name());
			end
		end
	end
end

function SpawnTimuridArmyInZone(faction_name, unit_list, region, zone)
	local turn_number = cm:model():turn_number();
	local x = math.random(zone.x1 , zone.x2);
	local y = math.random(zone.y2 , zone.y1);

	cm:create_force(
		faction_name, 					-- name of faction
		unit_list,		 				-- comma-separated units
		region, 						-- home region
		x,						-- x coordinate
		y,						-- y coordinate
		faction_name..tostring(x)..tostring(y)..tostring(turn_number), 	-- string id for army
		true,
		function(cqi)
			cm:apply_effect_bundle_to_characters_force("mk_bundle_army_timurid_invasion", cqi, 20, true)
		end
	);
end

function TimuridArmyChecks(faction_name)
	local faction = cm:model():world():faction_by_key(faction_name);
	local zone = nil;

	if faction_name == TIMURIDS_KEY then
		zone = TIMURID_SPAWN_ZONE;
	end

	local battered_armies = 0;
	local forces = faction:military_force_list();
	
	if forces:num_items() < MIN_ARMY_STRENGTH_FORCES then
		SpawnTimuridArmyInZone(faction_name, TIMURID_INVASION_ARMY, "att_reg_scythia_sarai", zone);
		SpawnTimuridArmyInZone(faction_name, TIMURID_INVASION_ARMY, "att_reg_scythia_sarai", zone);
	else
		for i = 0, forces:num_items() - 1 do
			local force_avg_strength = 100;
			local unit_list = forces:item_at(i):unit_list();

			if unit_list:num_items() < MIN_ARMY_STRENGTH_UNITS then
				battered_armies = battered_armies + 1;
				break;

			elseif unit_list:num_items() > MIN_ARMY_STRENGTH_UNITS then
				for j = 0, unit_list:num_items() - 1 do
					local unit = unit_list:item_at(j);

					force_avg_strength = (force_avg_strength + unit:percentage_proportion_of_full_strength()) / 2;
				end
			end

			if force_avg_strength < MIN_ARMY_STRENGTH_PERCENT then
				battered_armies = battered_armies + 1;
			end
		end

		if forces:num_items() - battered_armies < MIN_ARMY_STRENGTH_FORCES then
			SpawnTimuridArmyInZone(faction_name, TIMURID_INVASION_ARMY, "att_reg_scythia_sarai", zone);
			SpawnTimuridArmyInZone(faction_name, TIMURID_INVASION_ARMY, "att_reg_scythia_sarai", zone);
		end
	end
end

function TimeTrigger_Timurid_Invasion(context)
	if context.string == "timurid_war" then
		local timurids = cm:model():world():faction_by_key(TIMURIDS_KEY);

		for i = 1, #REGIONS_ILKHANATE do
			local region = cm:model():world():region_manager():region_by_key(REGIONS_ILKHANATE[i]);
		
			if region:owning_faction():name() ~= TIMURIDS_KEY and region:owning_faction():name() ~= TIMURIDS_KEY then
				if region:owning_faction():at_war_with(timurids) == false and region:owning_faction():allied_with(timurids) == false then
					cm:force_declare_war(TIMURIDS_KEY, region:owning_faction():name());
					SetFactionsHostile(TIMURIDS_KEY, region:owning_faction():name());
				end
			end
		end
	end
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		cm:save_value("TIMURID_INVASION_STARTED", TIMURID_INVASION_STARTED, context);
	end
);

cm:register_loading_game_callback(
	function(context)
		TIMURID_INVASION_STARTED = cm:load_value("TIMURID_INVASION_STARTED", false, context);
	end
);