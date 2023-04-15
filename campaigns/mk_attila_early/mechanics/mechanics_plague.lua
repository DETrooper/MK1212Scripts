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
-- Note that the plague lasts 4 turns (2 years at 2TPY), this can be changed in its DB.

BUBONIC_PLAGUE_KEY = "black_death";			-- Plague key in db (plagues_table).
PLAGUE_PHASE = "DORMANT";					-- Used for tracking plague progress.
PLAGUE_START_YEAR = 1346;					-- Plague starts in 1346 (turn 269 in 2TPY).
PLAGUE_END_YEAR = 1357; 					-- Plague ends in 1357 when all plague effects run out (turn 291 in 2TPY).
PLAGUE_CONTRACTION_CHANCE = 33;				-- The chance of characters contracting the plague.
PLAGUE_TRAIT = "mk_trait_bubonic_plague";	-- Trait given to characters when they contract the plague.
SANITATION_SAFE_LEVEL = 10;					-- The level of sanitation at which a region becomes safe from the plague.

REGIONS_TO_PLAGUE_TURNS = {};

function Add_Plague_Listeners()
	cm:add_listener(
		"FactionTurnStart_Plague",
		"FactionTurnStart",
		true,
		function(context) FactionTurnStart_Plague(context) end,
		true
	);
	cm:add_listener(
		"RegionTurnStart_Plague",
		"RegionTurnStart",
		true,
		function(context) RegionTurnStart_Plague(context) end,
		true
	);
end

function FactionTurnStart_Plague(context)
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

	if turn_number == GetTurnFromYear(PLAGUE_START_YEAR) and PLAGUE_PHASE == "DORMANT" then
		PLAGUE_PHASE = "1346";

		DoPlagueTurn();
				
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
	elseif PLAGUE_PHASE ~= "DORMANT" and PLAGUE_PHASE ~= "ENDED" then
		local year = GetYearFromTurn(turn_number, true);

		if tostring(year) ~= PLAGUE_PHASE then
			if year >= PLAGUE_END_YEAR then
				PLAGUE_PHASE = "ENDED";
			elseif (turn_number - PLAGUE_START_YEAR) % TURNS_PER_YEAR == 0 then
				PLAGUE_PHASE = tostring(tonumber(PLAGUE_PHASE) + 1);

				DoPlagueTurn();
			end
		end
	end
end

function RegionTurnStart_Plague(context)
	local region_name = context:region():name();
	local plague_turns = REGIONS_TO_PLAGUE_TURNS[region_name];

	if plague_turns and plague_turns > 0 then
		local new_turns = plague_turns - 1;

		if new_turns <= 0 then
			REGIONS_TO_PLAGUE_TURNS[region_name] = nil;
		else
			REGIONS_TO_PLAGUE_TURNS[region_name] = new_turns;
		end
	end
end

function DoPlagueTurn()
	if PLAGUE_REGIONS_BY_YEAR[PLAGUE_PHASE] then
		-- Make sure these regions get infected
		for i = 1, #PLAGUE_REGIONS_BY_YEAR[PLAGUE_PHASE] do
			local region_sanitation = cm:model():world():region_manager():region_by_key(PLAGUE_REGIONS_BY_YEAR[PLAGUE_PHASE][i]);
			local sanitation = region_sanitation:sanitation() - region_sanitation:squalor();
								
			if sanitation < SANITATION_SAFE_LEVEL then
				GiveRegionPlague(PLAGUE_REGIONS_BY_YEAR[PLAGUE_PHASE][i]);
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
					for k = 1, #PLAGUE_REGIONS_BY_YEAR[PLAGUE_PHASE] do
						if general:has_region() then
							if general:region():name() == PLAGUE_REGIONS_BY_YEAR[PLAGUE_PHASE][k] then
								local region_sanitation = cm:model():world():region_manager():region_by_key(PLAGUE_REGIONS_BY_YEAR[PLAGUE_PHASE][k]);
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
	end
end

function GiveRegionPlague(region_name)
	cm:infect_region_with_plague(BUBONIC_PLAGUE_KEY, region_name);

	REGIONS_TO_PLAGUE_TURNS[region_name] = 4;
end

function GiveArmyPlague(general)
	local gen_cqi = tostring(general:command_queue_index());
	
	cm:infect_force_with_plague(BUBONIC_PLAGUE_KEY, "character_cqi:"..gen_cqi);
end

function RegionHasPlague(region_name)
	local plague_turns = REGIONS_TO_PLAGUE_TURNS[region_name];

	if plague_turns and plague_turns > 0 then
		return true;
	end

	return false;
end

cm:register_saving_game_callback(
	function(context)
		cm:save_value("PLAGUE_PHASE", PLAGUE_PHASE, context);
		SaveKeyPairTable(context, REGIONS_TO_PLAGUE_TURNS, "REGIONS_TO_PLAGUE_TURNS");
	end
);

cm:register_loading_game_callback(
	function(context)
		PLAGUE_PHASE = cm:load_value("PLAGUE_PHASE", "DORMANT", context);
		REGIONS_TO_PLAGUE_TURNS = LoadKeyPairTableNumbers(context, "REGIONS_TO_PLAGUE_TURNS");
	end
);
