---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: THE BLACK DEATH
-- 	Modified By: DETrooper
-- 	Original Script by Creative Assembly
--
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
-- Reworked Plague of Justinian script from The Last Roman DLC for the Bubonic Plague.
-- Follows a linear, more historical path rather than dynamically spreading (as cool as that was!).

BUBONIC_PLAGUE_KEY = "black_death";
PLAGUE_PHASE = "DORMANT";			-- Used for tracking plague progress.
PLAGUE_START_TURN = 269;			-- Plague starts in 1346 (turn 269).
PLAGUE_CONTRACTION_CHANCE = 33;		-- The chance of characters contracting the plague.
PLAGUE_TRAIT = "mk_trait_bubonic_plague";		-- Trait given to characters when they contract the plague.
SANITATION_SAFE_LEVEL = 10;			-- The level of sanitation at which a region becomes safe from the plague.

function Add_Plague_Listeners()
	cm:add_listener(
		"FactionTurnStart_Plague",
		"FactionTurnStart",
		true,
		function(context) OnFactionTurnStart_Plague(context) end,
		true
	);
end

function OnFactionTurnStart_Plague(context)
	local turn_number = cm:model():turn_number();
	local faction_list = cm:model():world():faction_list();

	if PLAGUE_PHASE ~= "DORMANT" and PLAGUE_PHASE ~= "ENDED" then
		--[[for i = 0, faction_list:num_items() - 1 do
			local faction = faction_list:item_at(i);

			for j = 0, faction:character_list():num_items() - 1 do
				local character = faction:character_list():item_at(j);

				if character:has_trait(PLAGUE_TRAIT) then
					cm:kill_character("character_cqi:"..character:command_queue_index(), false, false);
				end
			end
		end]]--
	end

	if turn_number == PLAGUE_START_TURN and PLAGUE_PHASE == "DORMANT" then
		PLAGUE_PHASE = "1346";
				
		-- Make sure these regions get infected
		for i = 1, #REGIONS_1346 do
			local region_sanitation = cm:model():world():region_manager():region_by_key(REGIONS_1346[i]);
			local sanitation = region_sanitation:sanitation() - region_sanitation:squalor();
								
			if sanitation < SANITATION_SAFE_LEVEL then
				GiveRegionPlague(REGIONS_1346[i]);
			end
		end

		for i = 0, faction_list:num_items() - 1 do
			local faction = faction_list:item_at(i);
			local forces = faction:military_force_list();

			for j = 0, forces:num_items() - 1 do
				local force = forces:item_at(j);
				local general = force:general_character();

				--[[if cm:model():random_percent(PLAGUE_CONTRACTION_CHANCE) then
					cm:force_add_trait("character_cqi:"..general:command_queue_index(), PLAGUE_TRAIT, true);
				end]]--
			
				if force:upkeep() > 0 then	
					for k = 1, #REGIONS_1346 do
						if general:has_region() then
							if general:region():name() == REGIONS_1346[k] then
								local region_sanitation = cm:model():world():region_manager():region_by_key(REGIONS_1346[k]);
								local sanitation = region_sanitation:sanitation() - region_sanitation:squalor();
								
								if sanitation < SANITATION_SAFE_LEVEL then
									GiveArmyPlague(general);
								end
							end
						end
					end
				end
			end
		end
					
		local faction_name = (cm:model():faction_for_command_queue_index(HUMAN_FACTIONS[1])):name();
		cm:show_message_event(
			faction_name,
			"message_event_text_text_mk_event_black_death_title",
			"message_event_text_text_mk_event_black_death_primary",
			"message_event_text_text_mk_event_black_death_secondary",
			true,
			714
		);

		if HUMAN_FACTIONS[2]  then 
			local faction_name = (cm:model():faction_for_command_queue_index(HUMAN_FACTIONS[2])):name();
			cm:show_message_event(
				faction_name,
				"message_event_text_text_mk_event_black_death_title",
				"message_event_text_text_mk_event_black_death_primary",
				"message_event_text_text_mk_event_black_death_secondary",
				true,
				714
			);
		end
	elseif turn_number == PLAGUE_START_TURN + 2 and PLAGUE_PHASE == "1346" then
		PLAGUE_PHASE = "1347";
				
		-- Make sure these regions get infected
		for i = 1, #REGIONS_1347 do
			local region_sanitation = cm:model():world():region_manager():region_by_key(REGIONS_1347[i]);
			local sanitation = region_sanitation:sanitation() - region_sanitation:squalor();
								
			if sanitation < SANITATION_SAFE_LEVEL then
				GiveRegionPlague(REGIONS_1347[i]);
			end
		end

		for i = 0, faction_list:num_items() - 1 do
			local faction = faction_list:item_at(i);
			local forces = faction:military_force_list();

			for j = 0, forces:num_items() - 1 do
				local force = forces:item_at(j);
				local general = force:general_character();

				--[[if cm:model():random_percent(PLAGUE_CONTRACTION_CHANCE) then
					cm:force_add_trait("character_cqi:"..general:command_queue_index(), PLAGUE_TRAIT, true);
				end]]--
			
				if force:upkeep() > 0 then				
					for k = 1, #REGIONS_1347 do
						if general:has_region() then
							if general:region():name() == REGIONS_1347[k] then
								local region_sanitation = cm:model():world():region_manager():region_by_key(REGIONS_1347[k]);
								local sanitation = region_sanitation:sanitation() - region_sanitation:squalor();
								
								if sanitation < SANITATION_SAFE_LEVEL then
									GiveArmyPlague(general);
								end
							end
						end
					end
				end
			end
		end
	elseif turn_number == PLAGUE_START_TURN + 4 and PLAGUE_PHASE == "1347" then
		PLAGUE_PHASE = "1348";
				
		-- Make sure these regions get infected
		for i = 1, #REGIONS_1348 do
			local region_sanitation = cm:model():world():region_manager():region_by_key(REGIONS_1348[i]);
			local sanitation = region_sanitation:sanitation() - region_sanitation:squalor();
								
			if sanitation < SANITATION_SAFE_LEVEL then
				GiveRegionPlague(REGIONS_1348[i]);
			end
		end

		for i = 0, faction_list:num_items() - 1 do
			local faction = faction_list:item_at(i);
			local forces = faction:military_force_list();

			for j = 0, forces:num_items() - 1 do
				local force = forces:item_at(j);
				local general = force:general_character();

				--[[if cm:model():random_percent(PLAGUE_CONTRACTION_CHANCE) then
					cm:force_add_trait("character_cqi:"..general:command_queue_index(), PLAGUE_TRAIT, true);
				end]]--
			
				if force:upkeep() > 0 then				
					for k = 1, #REGIONS_1348 do
						if general:has_region() then
							if general:region():name() == REGIONS_1348[k] then
								local region_sanitation = cm:model():world():region_manager():region_by_key(REGIONS_1348[k]);
								local sanitation = region_sanitation:sanitation() - region_sanitation:squalor();
								
								if sanitation < SANITATION_SAFE_LEVEL then
									GiveArmyPlague(general);
								end
							end
						end
					end
				end
			end
		end
	elseif turn_number == PLAGUE_START_TURN + 6 and PLAGUE_PHASE == "1348" then
		PLAGUE_PHASE = "1349";
				
		-- Make sure these regions get infected
		for i = 1, #REGIONS_1349 do
			local region_sanitation = cm:model():world():region_manager():region_by_key(REGIONS_1349[i]);
			local sanitation = region_sanitation:sanitation() - region_sanitation:squalor();
								
			if sanitation < SANITATION_SAFE_LEVEL then
				GiveRegionPlague(REGIONS_1349[i]);
			end
		end

		for i = 0, faction_list:num_items() - 1 do
			local faction = faction_list:item_at(i);
			local forces = faction:military_force_list();

			for j = 0, forces:num_items() - 1 do
				local force = forces:item_at(j);
				local general = force:general_character();

				--[[if cm:model():random_percent(PLAGUE_CONTRACTION_CHANCE) then
					cm:force_add_trait("character_cqi:"..general:command_queue_index(), PLAGUE_TRAIT, true);
				end]]--
			
				if force:upkeep() > 0 then				
					for k = 1, #REGIONS_1349 do
						if general:has_region() then
							if general:region():name() == REGIONS_1349[k] then
								local region_sanitation = cm:model():world():region_manager():region_by_key(REGIONS_1349[k]);
								local sanitation = region_sanitation:sanitation() - region_sanitation:squalor();
								
								if sanitation < SANITATION_SAFE_LEVEL then
									GiveArmyPlague(general);
								end
							end
						end
					end
				end
			end
		end
	elseif turn_number == PLAGUE_START_TURN + 8 and PLAGUE_PHASE == "1349" then
		PLAGUE_PHASE = "1350";
				
		-- Make sure these regions get infected
		for i = 1, #REGIONS_1350 do
			local region_sanitation = cm:model():world():region_manager():region_by_key(REGIONS_1350[i]);
			local sanitation = region_sanitation:sanitation() - region_sanitation:squalor();
								
			if sanitation < SANITATION_SAFE_LEVEL then
				GiveRegionPlague(REGIONS_1350[i]);
			end
		end

		for i = 0, faction_list:num_items() - 1 do
			local faction = faction_list:item_at(i);
			local forces = faction:military_force_list();

			for j = 0, forces:num_items() - 1 do
				local force = forces:item_at(j);
				local general = force:general_character();

				--[[if cm:model():random_percent(PLAGUE_CONTRACTION_CHANCE) then
					cm:force_add_trait("character_cqi:"..general:command_queue_index(), PLAGUE_TRAIT, true);
				end]]--
			
				if force:upkeep() > 0 then				
					for k = 1, #REGIONS_1350 do
						if general:has_region() then
							if general:region():name() == REGIONS_1350[k] then
								local region_sanitation = cm:model():world():region_manager():region_by_key(REGIONS_1350[k]);
								local sanitation = region_sanitation:sanitation() - region_sanitation:squalor();
								
								if sanitation < SANITATION_SAFE_LEVEL then
									GiveArmyPlague(general);
								end
							end
						end
					end
				end
			end
		end
	elseif turn_number == PLAGUE_START_TURN + 10 and PLAGUE_PHASE == "1350" then
		PLAGUE_PHASE = "1351";
				
		-- Make sure these regions get infected
		for i = 1, #REGIONS_1351 do
			local region_sanitation = cm:model():world():region_manager():region_by_key(REGIONS_1351[i]);
			local sanitation = region_sanitation:sanitation() - region_sanitation:squalor();
								
			if sanitation < SANITATION_SAFE_LEVEL then
				GiveRegionPlague(REGIONS_1351[i]);
			end
		end

		for i = 0, faction_list:num_items() - 1 do
			local faction = faction_list:item_at(i);
			local forces = faction:military_force_list();

			for j = 0, forces:num_items() - 1 do
				local force = forces:item_at(j);
				local general = force:general_character();

				--[[if cm:model():random_percent(PLAGUE_CONTRACTION_CHANCE) then
					cm:force_add_trait("character_cqi:"..general:command_queue_index(), PLAGUE_TRAIT, true);
				end]]--
			
				if force:upkeep() > 0 then				
					for k = 1, #REGIONS_1351 do
						if general:has_region() then
							if general:region():name() == REGIONS_1351[k] then
								local region_sanitation = cm:model():world():region_manager():region_by_key(REGIONS_1351[k]);
								local sanitation = region_sanitation:sanitation() - region_sanitation:squalor();
								
								if sanitation < SANITATION_SAFE_LEVEL then
									GiveArmyPlague(general);
								end
							end
						end
					end
				end
			end
		end
	elseif turn_number == PLAGUE_START_TURN + 12 and PLAGUE_PHASE == "1351" then
		PLAGUE_PHASE = "1352";
				
		-- Make sure these regions get infected
		for i = 1, #REGIONS_1352 do
			local region_sanitation = cm:model():world():region_manager():region_by_key(REGIONS_1352[i]);
			local sanitation = region_sanitation:sanitation() - region_sanitation:squalor();
								
			if sanitation < SANITATION_SAFE_LEVEL then
				GiveRegionPlague(REGIONS_1352[i]);
			end
		end

		for i = 0, faction_list:num_items() - 1 do
			local faction = faction_list:item_at(i);
			local forces = faction:military_force_list();

			for j = 0, forces:num_items() - 1 do
				local force = forces:item_at(j);
				local general = force:general_character();

				--[[if cm:model():random_percent(PLAGUE_CONTRACTION_CHANCE) then
					cm:force_add_trait("character_cqi:"..general:command_queue_index(), PLAGUE_TRAIT, true);
				end]]--
			
				if force:upkeep() > 0 then				
					for k = 1, #REGIONS_1352 do
						if general:has_region() then
							if general:region():name() == REGIONS_1352[k] then
								local region_sanitation = cm:model():world():region_manager():region_by_key(REGIONS_1352[k]);
								local sanitation = region_sanitation:sanitation() - region_sanitation:squalor();
								
								if sanitation < SANITATION_SAFE_LEVEL then
									GiveArmyPlague(general);
								end
							end
						end
					end
				end
			end
		end
	elseif turn_number == PLAGUE_START_TURN + 20 and PLAGUE_PHASE == "1352" then
		PLAGUE_PHASE = "ENDED";
	end
end

function GiveRegionPlague(region_name)
	cm:infect_region_with_plague(BUBONIC_PLAGUE_KEY, region_name);
end

function GiveArmyPlague(general)
	local gen_cqi = general:command_queue_index();
	cm:infect_force_with_plague(BUBONIC_PLAGUE_KEY, "character_cqi:"..gen_cqi);
end

cm:register_saving_game_callback(
	function(context)
		cm:save_value("PLAGUE_PHASE", PLAGUE_PHASE, context);
	end
);

cm:register_loading_game_callback(
	function(context)
		PLAGUE_PHASE = cm:load_value("PLAGUE_PHASE", "DORMANT", context);
	end
);