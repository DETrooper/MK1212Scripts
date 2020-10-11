----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: POPE COLLEGE OF CARDINALS
-- 	By: DETrooper
--
----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
-- System for Catholic factions to elect priests to popehood.

COLLEGE_OF_CARDINALS_MAX_CARDINALS = 20;
COLLEGE_OF_CARDINALS_MAX_PREFERATI = 3;
COLLEGE_OF_CARDINALS_MIN_RANK = 5; -- should also get trait att_trait_priest_rank_catholic_bishop at this rank via vanilla export_triggers.lua

COLLEGE_OF_CARDINALS_CHARACTERS = {};
COLLEGE_OF_CARDINALS_VOTES = {};

local election_factors = {
	["allied"] = {points = 10}, -- Candidate's faction is allied to the faction of the voting cardinal.
	["atheist"] = {points = -100, traits = {"att_trait_all_personality_all_atheist"}},
	["at_war"] = {points = -20}, -- Candidate's faction is at war with the faction of the voting cardinal.
	["charismatic"] = {points = 5, traits = {"att_trait_all_personality_all_innate_charismatic"}},
	["drunkard"] = {points = -5, traits = {"att_trait_all_personality_all_drink"}},
	["energetic"] = {points = 5, traits = {"att_trait_all_personality_all_energetic"}},
	["inbred"] = {points = -20, traits = {"att_trait_agent_physical_all_innate_inbred", "att_trait_agent_physical_all_innate_very_inbred", "att_trait_agent_physical_all_innate_very_very_inbred"}},
	["intelligent"] = {points = 5, traits = {"att_trait_all_personality_all_innate_intelligent"}},
	["lazy"] = {points = -5, traits = {"att_trait_all_personality_all_lazy"}},
	["lewd"] = {points = -10, traits = {"att_trait_all_personality_all_lewd"}},
	["mad"] = {points = -15, traits = {"att_trait_agent_personality_all_mad"}},
	["phlegmatic"] = {points = -5, traits = {"att_trait_all_personality_all_phlegmatic"}},
	["rank"] = {points = 5}, -- Multiplied for each rank (level 6 agent will get 30 for example).
	["same_faction"] = {points = 20}, -- Candidate belongs to the same faction as the voting cardinal.
	--["same_subculture"] = {points = 5}, -- Candidate belongs to the same subculture as the voting cardinal.
	["stupid"] = {points = -10, traits = {"att_trait_agent_personality_all_innate_stupid"}},
	["unhealthy"] = {points = -5, traits = {"att_trait_all_physical_all_unhealthy"}}
}

function Add_Pope_College_Listeners()
	cm:add_listener(
		"FactionTurnStart_Pope_College",
		"FactionTurnStart",
		true,
		function(context) FactionTurnStart_Pope_College(context) end,
		true
	);

	if cm:is_new_game() then
		--COLLEGE_OF_CARDINALS_CHARACTERS = DeepCopy(COLLEGE_OF_CARDINALS_CHARACTERS_START);
	end
end

function FactionTurnStart_Pope_College(context)
	if PAPAL_FAVOUR_SYSTEM_ACTIVE then
		if context:faction():is_human() then
			Pope_College_Check();

			if POPE_DEAD then
				if context:faction():state_religion() == "att_rel_chr_catholic" then
					CreatePopeElectionPanel();
				else
					Process_Pope_College_Election();
				end
			end
		end

		-- On the Pope's turn, assign a new cardinal if the College of Cardinals is below its max size.
		if context:faction():name() == PAPAL_STATES_KEY then
			if #COLLEGE_OF_CARDINALS_CHARACTERS < COLLEGE_OF_CARDINALS_MAX_CARDINALS then
				local faction_list = cm:model():world():faction_list();
				local highest_ranking_character = nil;
				local highest_rank = 0;

				for i = 0, faction_list:num_items() - 1 do
					local current_faction = faction_list:item_at(i);
					local character_list = current_faction:character_list();
	
					for i = 0, character_list:num_items() - 1 do
						local character = character_list:item_at(i);
						
						if character:character_type("dignitary") and character:faction():state_religion() == "att_rel_chr_catholic" and character:rank() >= COLLEGE_OF_CARDINALS_MIN_RANK then
							if not COLLEGE_OF_CARDINALS_CHARACTERS[tostring(character:cqi())] and not FACTION_EXCOMMUNICATED[character:faction():name()] then
								if character:rank() > highest_rank then
									highest_ranking_character = character;
								end
							end
						end
					end
				end

				if highest_ranking_character then
					COLLEGE_OF_CARDINALS_CHARACTERS[tostring(highest_ranking_character:cqi())] = "cardinal";

					if highest_ranking_character:faction():is_human() then
						cm:show_message_event(
							highest_ranking_character:faction():name(),
							"message_event_text_text_mk_event_college_of_cardinals_cardinal_added_title",
							highest_ranking_character:get_forename(),
							"message_event_text_text_mk_event_college_of_cardinals_cardinal_added_secondary",
							true, 
							701
						);
					end
				end
			end
		end
	end
end

function Pope_College_Check()
	local preferati = Determine_Preferati_Pope_College_Elections();

	for k, v in pairs(COLLEGE_OF_CARDINALS_CHARACTERS) do
		local character = cm:model():character_for_command_queue_index(tonumber(k));

		if character then
			local character_cqi = tostring(character:cqi());
			local character_is_preferati = false;

			for i = 1, #preferati do
				if preferati[i][1] == character_cqi then
					COLLEGE_OF_CARDINALS_CHARACTERS[character_cqi] = "preferati";
					character_is_preferati = true;
				end
			end

			if character_is_preferati == false then
				COLLEGE_OF_CARDINALS_CHARACTERS[character_cqi] = "cardinal";
			end
		else
			-- Character is dead.
			COLLEGE_OF_CARDINALS_CHARACTERS = nil;
		end
	end

	--[[for i = 1, #COLLEGE_OF_CARDINALS_CHARACTERS do
		if not COLLEGE_OF_CARDINALS_CHARACTERS[i] then
			table.remove(COLLEGE_OF_CARDINALS_CHARACTERS, i);

			if i < #COLLEGE_OF_CARDINALS_CHARACTERS then
				i = i - 1;
			end
		end
	end]]--
end

function Calculate_Num_Votes_Pope_College_Elections(cqi)
	local votes = 0;

	for k, v in pairs(COLLEGE_OF_CARDINALS_VOTES) do
		if v == cqi then
			votes = votes + 1;
		end
	end

	return votes;
end

function Check_Votes_Pope_College_Elections(character)
	-- Cardinals will vote for one of the top three candidates for the next Papacy based on a number of factors.
	-- These factors are primarily personality traits and also some basic diplomatic checks. The agent's rank is also factored in.

	if character then -- Should exist if this function got called but I'll check anyways.
		local character_faction = character:faction();
		local top_scoring_candidate = nil;
		local top_scoring_candidate_points = 0;
		
		for k, v in pairs(COLLEGE_OF_CARDINALS_CHARACTERS) do
			local candidate_character = cm:model():character_for_command_queue_index(tonumber(k));

			if candidate_character then
				local candidate_faction = candidate_character:faction();
				local candidate_points = 0;

				-- Rank check.
				candidate_points = candidate_points + (election_factors["rank"].points * candidate_character:rank());
				
				-- Faction-level checks.
				if character_faction:name() == candidate_faction:name() then
					candidate_points = candidate_points + election_factors["same_faction"].points;
				elseif character_faction:at_war_with(candidate_faction) then
					candidate_points = candidate_points + election_factors["at_war"].points;
				elseif character_faction:allied_with(candidate_faction) then
					candidate_points = candidate_points + election_factors["allied"].points;
				end

				-- Trait checks.
				for k2, v2 in pairs(election_factors) do
					if v2.traits then
						for i = 1, v2.traits do
							if candidate_character:has_trait(v2.traits[i]) then
								candidate_points = candidate_points + v2.points;
								break;
							end
						end
					end
				end

				if candidate_points > top_scoring_candidate_points then
					top_scoring_candidate = candidate_character;
					top_scoring_candidate_points = candidate_points;
				end
			end
		end

		if top_scoring_candidate then
			COLLEGE_OF_CARDINALS_VOTES[tostring(character:cqi())] = tostring(top_scoring_candidate:cqi());
		end
	end
end

function Determine_Preferati_Pope_College_Elections()
	local preferati = {};

	for k, v in pairs(COLLEGE_OF_CARDINALS_CHARACTERS) do
		local character = cm:model():character_for_command_queue_index(tonumber(k));

		if character then
			local character_rank = character:rank();

			if #preferati > COLLEGE_OF_CARDINALS_MAX_PREFERATI then
				table.insert(preferati, {tostring(character:cqi()), character_rank});
			elseif #preferati > 1 then
				for i = 2, #preferati do
					if (character_rank > preferati[i - 1][2] and character_rank <= preferati[i][2]) or (i == #preferati and character_rank > preferati[i][2]) then
						preferati[i - 1] = {tostring(character:cqi()), character_rank};
					end
				end
			end

			-- We want the preferati table to be sorted based on lowest rank to highest.
			if #preferati > 1 then
				local table_reshuffled = true;

				while table_reshuffled == true do
					table_reshuffled = false;

					for i = 2, #preferati do
						if preferati[i][2] < preferati[i - 1][2] then
							local temp = preferati[i][2];

							preferati[i][2] = preferati[i -1][2];
							preferati[i - 1][2] = temp;

							table_reshuffled = true;
						end
					end
				end
			end
		end
	end

	return preferati;
end

function Process_Pope_College_Election()
	local max = 0;
	local winner = nil;

	for k, v in pairs(COLLEGE_OF_CARDINALS_CHARACTERS) do
		local character = cm:model():character_for_command_queue_index(tonumber(k));

		if character then
			Check_Votes_Pope_College_Elections(character);
		end
	end

	for k, v in pairs(COLLEGE_OF_CARDINALS_CHARACTERS) do
		if v == "preferati" then
			local num_votes = Calculate_Num_Votes_HRE_Elections(k);

			if num_votes > max then
				winner, max = cm:model():character_for_command_queue_index(tonumber(k)), num_votes;
			end
		end
	end

	if winner then
		Set_Papal_Controller(winner:faction():name());
		Pope_Changeover(winner:get_forename(), winner:age());

		-- Todo: Suppress messages.
		cm:set_character_immortality("character_cqi:"..winner:command_queue_index(), false);
		cm:kill_character("character_cqi:"..winner:command_queue_index(), false, false);
	else
		-- Something went wrong so automatically generate a Pope.

		Pope_Changeover_Automatic();
	end
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		SaveKeyPairTable(context, COLLEGE_OF_CARDINALS_CHARACTERS, "COLLEGE_OF_CARDINALS_CHARACTERS");
		SaveKeyPairTable(context, COLLEGE_OF_CARDINALS_VOTES, "COLLEGE_OF_CARDINALS_VOTES");
	end
);

cm:register_loading_game_callback(
	function(context)
		COLLEGE_OF_CARDINALS_CHARACTERS = LoadKeyPairTable(context, "COLLEGE_OF_CARDINALS_CHARACTERS");
		COLLEGE_OF_CARDINALS_VOTES = LoadKeyPairTable(context, "COLLEGE_OF_CARDINALS_VOTES");
	end
);
