------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MONGOLS: MONGOL INVASION
-- 	By: DETrooper
-- 	Some elements taken from The Last Roman.
--
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
-- Gives the Mongols armies, controls their events, and so-forth.

CUMANS_KEY = "mk_fact_cumans";
JOCHI_KEY = "mk_fact_goldenhorde";
KHWARAZM_KEY = "mk_fact_khwarazm";
TOLUI_KEY = "mk_fact_ilkhanate";

INDEPENDENCE_JOCHI = false;
INDEPENDENCE_TOLUI = false;
MONGOL_INVASION_STARTED = false;
MONGOL_INVASION_TURN = 15;

MIN_ARMY_STRENGTH_FORCES = 3; -- # of armies.
MIN_ARMY_STRENGTH_UNITS = 14; -- # of units before an army is considered too small.
MIN_ARMY_STRENGTH_PERCENT = 65; -- # of men left in an army on average before the army is considered too small.

BUNDLES_APPLIED_JOCHI = {};
BUNDLES_APPLIED_TOLUI = {};
FREE_UPKEEP_TIME = 25;

local free_upkeep_warn_after = 1;
local free_upkeep_warned_this_turn = false

function Add_Mongol_Invasion_Listeners()
	cm:add_listener(
		"FactionTurnStart_Mongol_Preservation",
		"FactionTurnStart",
		true,
		function(context) FactionTurnStart_Mongol_Preservation(context) end,
		true
	);
	cm:add_listener(
		"BattleCompleted_Mongol_Preservation",
		"BattleCompleted",
		true,
		function(context) OnBattleCompleted_Mongol_Preservation(context) end,
		true
	);

	if cm:is_new_game() then
		local jochi = cm:model():world():faction_by_key(JOCHI_KEY);
		local tolui = cm:model():world():faction_by_key(TOLUI_KEY);

		if jochi:is_human() == false then
			local forces = jochi:military_force_list();

			for i = 0, forces:num_items() - 1 do
				local force = forces:item_at(i);
				local unit_list = forces:item_at(i):unit_list();

				if unit_list:num_items() < MIN_ARMY_STRENGTH_UNITS then
					for j = 0, MIN_ARMY_STRENGTH_UNITS - unit_list:num_items() do
						cm:add_unit_to_force("mk_mon_t1_golden_horse_archers", force:command_queue_index());
					end
				end
			end
		end

		if tolui:is_human() == false then
			local forces = tolui:military_force_list();

			for i = 0, forces:num_items() - 1 do
				local force = forces:item_at(i);
				local unit_list = forces:item_at(i):unit_list();

				if unit_list:num_items() < MIN_ARMY_STRENGTH_UNITS then
					for j = 0, MIN_ARMY_STRENGTH_UNITS - unit_list:num_items() do
						cm:add_unit_to_force("mk_mon_t1_ilkhan_horse_archers", force:command_queue_index());
					end
				end
			end
		end
	end
end

function FactionTurnStart_Mongol_Preservation(context)
	local cumans = cm:model():world():faction_by_key(CUMANS_KEY);
	local jochi = cm:model():world():faction_by_key(JOCHI_KEY);
	local khwarazm = cm:model():world():faction_by_key(KHWARAZM_KEY);
	local tolui = cm:model():world():faction_by_key(TOLUI_KEY);
	local host_name = (cm:model():faction_for_command_queue_index(HUMAN_FACTIONS[1])):name();
	local turn_number = cm:model():turn_number();

	if context:faction():name() == JOCHI_KEY then
		free_upkeep_warned_this_turn = false;

		if jochi:is_human() == false then
			if turn_number == 1 then
				if jochi:at_war_with(cumans) == false then
					cm:force_declare_war(JOCHI_KEY, CUMANS_KEY);
				end
			elseif turn_number == MONGOL_INVASION_TURN then
				local valid_factions = {};

				for i = 1, #REGIONS_GOLDEN_HORDE do
					local region = cm:model():world():region_manager():region_by_key(REGIONS_GOLDEN_HORDE[i]);

					-- Make sure region is not razed.
					if not region:owning_faction():is_null_interface() and region:owning_faction():name() ~= "rebels" then
						local region_owning_faction_name = region:owning_faction():name();

						if region_owning_faction_name ~= JOCHI_KEY and region_owning_faction_name ~= TOLUI_KEY then
							if region:owning_faction():at_war_with(jochi) == false and region:owning_faction():allied_with(jochi) == false then
								table.insert(valid_factions, region_owning_faction_name);
								SetFactionsHostile(JOCHI_KEY, region_owning_faction_name);
							end
						end
					end
				end

				-- There seems to some bugs when allied to an AI faction that is force to declare war on multiple factions,
				-- so instead we're just gonna make the AI mongol hate everyone but only declare war on the strongest.
				if #valid_factions > 0 then
					local strongest_faction = Get_Strongest_Faction(valid_factions);

					if strongest_faction then
						cm:force_declare_war(JOCHI_KEY, strongest_faction);
					end
				end
			end

			if turn_number < MONGOL_INVASION_TURN then
				MongolArmyChecks(JOCHI_KEY);
			end
		end
	elseif context:faction():name() == TOLUI_KEY then
		free_upkeep_warned_this_turn = false;

		if tolui:is_human() == false then
			if turn_number == 1 then
				if tolui:at_war_with(khwarazm) == false then
					cm:force_declare_war(JOCHI_KEY, KHWARAZM_KEY);
				end
			elseif turn_number == MONGOL_INVASION_TURN then
				local valid_factions = {};

				for i = 1, #REGIONS_ILKHANATE do
					local region = cm:model():world():region_manager():region_by_key(REGIONS_ILKHANATE[i]);

					-- Make sure region is not razed.
					if not region:owning_faction():is_null_interface() and region:owning_faction():name() ~= "rebels" then
						local region_owning_faction_name = region:owning_faction():name();

						if region_owning_faction_name ~= JOCHI_KEY and region_owning_faction_name ~= TOLUI_KEY then
							if region:owning_faction():at_war_with(tolui) == false and region:owning_faction():allied_with(tolui) == false then
								table.insert(valid_factions, region_owning_faction_name);
								SetFactionsHostile(TOLUI_KEY, region_owning_faction_name);
							end
						end
					end
				end

				-- There seems to some bugs when allied to an AI faction that is force to declare war on multiple factions,
				-- so instead we're just gonna make the AI mongol hate everyone but only declare war on the strongest.
				if #valid_factions > 0 then
					local strongest_faction = Get_Strongest_Faction(valid_factions);

					if strongest_faction then
						cm:force_declare_war(TOLUI_KEY, strongest_faction);
					end
				end
			end

			if turn_number < MONGOL_INVASION_TURN then
				MongolArmyChecks(TOLUI_KEY);
			end
		end
	end

	if turn_number == MONGOL_INVASION_TURN and MONGOL_INVASION_STARTED == false then
		MONGOL_INVASION_STARTED = true;

		if INDEPENDENCE_JOCHI == false then
			SpawnMongolArmyInZone(JOCHI_KEY, GOLDEN_HORDE_INVASION_ARMY, "att_reg_scythia_sarai", GOLDEN_HORDE_SPAWN_ZONE);
			SpawnMongolArmyInZone(JOCHI_KEY, GOLDEN_HORDE_INVASION_ARMY, "att_reg_scythia_sarai", GOLDEN_HORDE_SPAWN_ZONE);
			SpawnMongolArmyInZone(JOCHI_KEY, GOLDEN_HORDE_INVASION_ARMY, "att_reg_scythia_sarai", GOLDEN_HORDE_SPAWN_ZONE);
			SpawnMongolArmyInZone(JOCHI_KEY, GOLDEN_HORDE_ALT_INVASION_ARMY, "att_reg_scythia_sarai", GOLDEN_HORDE_SPAWN_ZONE);
			SpawnMongolArmyInZone(JOCHI_KEY, GOLDEN_HORDE_ALT_INVASION_ARMY, "att_reg_scythia_sarai", GOLDEN_HORDE_SPAWN_ZONE);

			if jochi:is_human() == false then
				cm:force_change_cai_faction_personality(JOCHI_KEY, "att_expansionist_dominator_aggressive_variant_cultural_dislikes_sassanids");
			end
		end

		if INDEPENDENCE_TOLUI == false then
			SpawnMongolArmyInZone(TOLUI_KEY, ILKHANATE_INVASION_ARMY, "att_reg_transcaspia_dahistan", ILKHANATE_SPAWN_ZONE);
			SpawnMongolArmyInZone(TOLUI_KEY, ILKHANATE_INVASION_ARMY, "att_reg_transcaspia_dahistan", ILKHANATE_SPAWN_ZONE);
			SpawnMongolArmyInZone(TOLUI_KEY, ILKHANATE_INVASION_ARMY, "att_reg_transcaspia_dahistan", ILKHANATE_SPAWN_ZONE);
			SpawnMongolArmyInZone(TOLUI_KEY, ILKHANATE_ALT_INVASION_ARMY, "att_reg_transcaspia_dahistan", ILKHANATE_SPAWN_ZONE);
			SpawnMongolArmyInZone(TOLUI_KEY, ILKHANATE_ALT_INVASION_ARMY, "att_reg_transcaspia_dahistan", ILKHANATE_SPAWN_ZONE);

			if tolui:is_human() == false then
				cm:force_change_cai_faction_personality(TOLUI_KEY, "att_expansionist_dominator_aggressive_variant_cultural_dislikes_sassanids");
			end
		end

		local faction_name = (cm:model():faction_for_command_queue_index(HUMAN_FACTIONS[1])):name();
		cm:show_message_event(
			faction_name,
			"message_event_text_text_mk_event_mongol_invasion_title",
			"message_event_text_text_mk_event_mongol_invasion_primary",
			"message_event_text_text_mk_event_mongol_invasion_secondary",
			true,
			715
		);

		if HUMAN_FACTIONS[2]  then 
			local faction_name = (cm:model():faction_for_command_queue_index(HUMAN_FACTIONS[2])):name();
			cm:show_message_event(
				faction_name,
				"message_event_text_text_mk_event_mongol_invasion_title",
				"message_event_text_text_mk_event_mongol_invasion_primary",
				"message_event_text_text_mk_event_mongol_invasion_secondary",
				true,
				715
			);
		end
	end

	if host_name == context:faction():name() then -- Only do this once per round, on the hosts turn.
		for i = 1, #BUNDLES_APPLIED_JOCHI do
			BUNDLES_APPLIED_JOCHI[i].timer = BUNDLES_APPLIED_JOCHI[i].timer - 1;
			
			if BUNDLES_APPLIED_JOCHI[i].timer == free_upkeep_warn_after then
				if free_upkeep_warned_this_turn == false then
					WarnAboutUpkeep(BUNDLES_APPLIED_JOCHI[i].cqi);
				end

				table.remove(BUNDLES_APPLIED_JOCHI, i);
			end
		end

		for i = 1, #BUNDLES_APPLIED_TOLUI do
			BUNDLES_APPLIED_TOLUI[i].timer = BUNDLES_APPLIED_TOLUI[i].timer - 1;
			
			if BUNDLES_APPLIED_TOLUI[i].timer == free_upkeep_warn_after then
				if free_upkeep_warned_this_turn == false then
					WarnAboutUpkeep(BUNDLES_APPLIED_TOLUI[i].cqi);
				end

				table.remove(BUNDLES_APPLIED_TOLUI, i);
			end
		end
	end
end

function OnBattleCompleted_Mongol_Preservation(context)
	local turn_number = cm:model():turn_number();

	if turn_number < MONGOL_INVASION_TURN then
		local pending_battle = cm:model():pending_battle();
		local attacker_result = pending_battle:attacker_battle_result();
		local defender_result = pending_battle:defender_battle_result();

		if pending_battle:has_attacker() then
			if pending_battle:attacker():has_military_force() and pending_battle:attacker():faction():is_human() == false and (pending_battle:attacker():faction():name() == JOCHI_KEY or pending_battle:attacker():faction():name() == TOLUI_KEY) then
				MongolArmyChecks(pending_battle:attacker():faction():name());
			end
		end
	
		if pending_battle:has_defender() then
			if pending_battle:defender():has_military_force() and pending_battle:defender():faction():is_human() == false and (pending_battle:defender():faction():name() == JOCHI_KEY or pending_battle:defender():faction():name() == TOLUI_KEY) then
				MongolArmyChecks(pending_battle:defender():faction():name());
			end
		end
	end
end

function ApplyMongolInvasionBundle(CQI)
 	cm:apply_effect_bundle_to_characters_force("mk_bundle_army_mongol_invasion", CQI, FREE_UPKEEP_TIME, true);
	
	local character = cm:model():character_for_command_queue_index(CQI);
	local force_cqi = character:military_force():command_queue_index();
	
	local new_bundle = {};
	new_bundle.cqi = force_cqi;
	new_bundle.timer = FREE_UPKEEP_TIME;
	
	if character:faction():name() == JOCHI_KEY then
		table.insert(BUNDLES_APPLIED_JOCHI, new_bundle);
	elseif character:faction():name() == TOLUI_KEY then
		table.insert(BUNDLES_APPLIED_TOLUI, new_bundle);
	end
end

function WarnAboutUpkeep(CQI)
	-- Make sure this force exists!
	if cm:model():has_military_force_command_queue_index(CQI) then
		local force_gen = cm:model():military_force_for_command_queue_index(CQI):general_character();

		cm:show_message_event_located(
			force_gen:faction():name(),
			"message_event_text_text_mk_event_mongol_invasion_upkeep_title",
			"message_event_text_text_mk_event_mongol_invasion_upkeep_primary",
			"message_event_text_text_mk_event_mongol_invasion_upkeep_secondary",
			force_gen:logical_position_x(),
			force_gen:logical_position_y(),
			false,
			190
		);
	end
end

function SpawnMongolArmyInZone(faction_name, unit_list, region, zone)
	local turn_number = cm:model():turn_number();
	local x = math.random(zone.x1, zone.x2);
	local y = math.random(zone.y2, zone.y1);

	cm:create_force(
		faction_name, 					-- name of faction
		unit_list,		 				-- comma-separated units
		region, 						-- home region
		x,						-- x coordinate
		y,						-- y coordinate
		faction_name..tostring(x)..tostring(y)..tostring(turn_number), 	-- string id for army
		true,
		function(cqi)
			ApplyMongolInvasionBundle(cqi)
		end
	);
end

function MongolArmyChecks(faction_name)
	local faction = cm:model():world():faction_by_key(faction_name);
	local army = nil;
	local zone = nil;

	if faction_name == JOCHI_KEY then
		army = GOLDEN_HORDE_INVASION_ARMY;
		zone = GOLDEN_HORDE_SPAWN_ZONE;
	elseif faction_name == TOLUI_KEY then
		army = ILKHANATE_INVASION_ARMY;
		zone = ILKHANATE_SPAWN_ZONE;
	end

	local battered_armies = 0;
	local forces = faction:military_force_list();
	
	if forces:num_items() < MIN_ARMY_STRENGTH_FORCES then
		SpawnMongolArmyInZone(faction_name, army, "att_reg_scythia_sarai", zone);
		SpawnMongolArmyInZone(faction_name, army, "att_reg_scythia_sarai", zone);
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
			SpawnMongolArmyInZone(faction_name, army, "att_reg_scythia_sarai", zone);
			SpawnMongolArmyInZone(faction_name, army, "att_reg_scythia_sarai", zone);
		end
	end
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		cm:save_value("INDEPENDENCE_JOCHI", INDEPENDENCE_JOCHI, context);
		cm:save_value("INDEPENDENCE_TOLUI", INDEPENDENCE_TOLUI, context);
		cm:save_value("MONGOL_INVASION_STARTED", MONGOL_INVASION_STARTED, context);

		local upkeep_savestring = "";
		
		for i = 1, #BUNDLES_APPLIED_JOCHI do
			upkeep_savestring = upkeep_savestring..BUNDLES_APPLIED_JOCHI[i].cqi..","..BUNDLES_APPLIED_JOCHI[i].timer..",;";
		end	
		cm:save_value("jochi_upkeep_savestring", upkeep_savestring, context);

		for i = 1, #BUNDLES_APPLIED_TOLUI do
			upkeep_savestring = upkeep_savestring..BUNDLES_APPLIED_TOLUI[i].cqi..","..BUNDLES_APPLIED_TOLUI[i].timer..",;";
		end	
		cm:save_value("tolui_upkeep_savestring", upkeep_savestring, context);
	end
);

cm:register_loading_game_callback(
	function(context)
		INDEPENDENCE_JOCHI = cm:load_value("INDEPENDENCE_JOCHI", false, context);
		INDEPENDENCE_TOLUI = cm:load_value("INDEPENDENCE_TOLUI", false, context);
		MONGOL_INVASION_STARTED = cm:load_value("MONGOL_INVASION_STARTED", false, context);

		local upkeep_savestring = cm:load_value("jochi_upkeep_savestring", "", context);
		
		if upkeep_savestring ~= ""  then
			BUNDLES_APPLIED_JOCHI = {};
			local first_split = SplitString(upkeep_savestring, ";");
			
			for i = 1, #first_split do
				local second_split = SplitString(first_split[i], ",");
				local new_bundle = {};
				new_bundle.cqi = tonumber(second_split[1]);
				new_bundle.timer = tonumber(second_split[2]);
				table.insert(BUNDLES_APPLIED_JOCHI, new_bundle);
			end
		end

		local upkeep_savestring = cm:load_value("tolui_upkeep_savestring", "", context);
		
		if upkeep_savestring ~= ""  then
			BUNDLES_APPLIED_TOLUI = {};
			local first_split = SplitString(upkeep_savestring, ";");
			
			for i = 1, #first_split do
				local second_split = SplitString(first_split[i], ",");
				local new_bundle = {};
				new_bundle.cqi = tonumber(second_split[1]);
				new_bundle.timer = tonumber(second_split[2]);
				table.insert(BUNDLES_APPLIED_TOLUI, new_bundle);
			end
		end
	end
);
