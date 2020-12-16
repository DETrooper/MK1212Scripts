----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: HOLY ROMAN EMPIRE ELECTIONS
-- 	By: DETrooper
--
----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
-- System for members of the HRE to elect the next emperor from among themselves.

HRE_FACTIONS_ELECTORS = {};
HRE_FACTIONS_VOTES = {};

function Add_HRE_Election_Listeners()
	cm:add_listener(
		"FactionTurnStart_HRE_Elections",
		"FactionTurnStart",
		true,
		function(context) FactionTurnStart_HRE_Elections(context) end,
		true
	);

	if cm:is_new_game() then
		HRE_FACTIONS_VOTES = DeepCopy(HRE_FACTIONS_VOTES_START);
	end
end

function FactionTurnStart_HRE_Elections(context)
	if not HRE_DESTROYED then
		if context:faction():name() == HRE_EMPEROR_KEY then
			if #HRE_FACTIONS_ELECTORS > 0 then
				for i = 1, #HRE_FACTIONS_ELECTORS do
					if not FactionIsAlive(HRE_FACTIONS_ELECTORS[i]) then
						table.remove(HRE_FACTIONS_ELECTORS, i);
					end
				end
			end
		end

		-- Has the first reform limiting the electors to a small group been passed?
		if CURRENT_HRE_REFORM < 1 then
			-- All factions in the HRE can currently vote.

			--[[if HasValue(HRE_FACTIONS, context:faction():name()) then
				Check_Faction_Votes_HRE_Elections(context:faction():name());
			end]]--
		-- Has the eighth reform which abolishes elections been passed?
		elseif CURRENT_HRE_REFORM < 8 then
			-- Only the prince-electors (and emperor) can vote.
			if #HRE_FACTIONS_ELECTORS < 7 then
				Add_New_Electors_HRE_Elections();
			end

			--[[if HasValue(HRE_FACTIONS_ELECTORS, context:faction():name()) or context:faction():name() == HRE_EMPEROR_KEY then
				Check_Faction_Votes_HRE_Elections(context:faction():name());
			end]]--
		end
	end
end

function Process_Election_Result_HRE_Elections()
	local max = 0;
	local winner = nil;

	for i = 1, #HRE_FACTIONS do
		local faction_name = HRE_FACTIONS[i];
		local num_votes = Calculate_Num_Votes_HRE_Elections(faction_name);

		if num_votes > max then
			winner, max = faction_name, num_votes;
		end
	end

	if winner then
		local faction_string = "factions_screen_name_"..winner;

		if FACTIONS_DFN_LEVEL[winner]  then
			if FACTIONS_DFN_LEVEL[winner] > 1 then
				faction_string = "campaign_localised_strings_string_"..winner.."_lvl"..tostring(FACTIONS_DFN_LEVEL[winner]);
			end
		end

		if winner ~= HRE_EMPEROR_KEY then
			HRE_Replace_Emperor(winner);
			-- Display election emperor change message event.

			cm:show_message_event(
				cm:get_local_faction(),
				"message_event_text_text_mk_event_hre_imperial_succession_title",
				faction_string,
				"message_event_text_text_mk_event_hre_imperial_succession_secondary",
				true, 
				713
			);
		else
			-- Display unique message event for retaining emperorship.
			local emperor_faction = cm:model():world():faction_by_key(HRE_EMPEROR_KEY);

			if HRE_EMPERORS_NAMES_NUMBERS[emperor_faction:faction_leader():get_forename()]  then
				HRE_EMPERORS_NAMES_NUMBERS[emperor_faction:faction_leader():get_forename()] = HRE_EMPERORS_NAMES_NUMBERS[emperor_faction:faction_leader():get_forename()] + 1;
			else
				HRE_EMPERORS_NAMES_NUMBERS[emperor_faction:faction_leader():get_forename()] = 1;
			end
	
			cm:show_message_event(
				cm:get_local_faction(),
				"message_event_text_text_mk_event_hre_imperial_title_retained_title",
				faction_string,
				"message_event_text_text_mk_event_hre_imperial_title_retained_secondary",
				true, 
				713
			);
		end
	else
		-- There was a tie or something, so make the emperor keep his post.
		if FactionIsAlive(HRE_EMPEROR_KEY) then
			local emperor_faction = cm:model():world():faction_by_key(HRE_EMPEROR_KEY);
			local faction_string = "factions_screen_name_"..HRE_EMPEROR_KEY;

			if HRE_EMPERORS_NAMES_NUMBERS[emperor_faction:faction_leader():get_forename()]  then
				HRE_EMPERORS_NAMES_NUMBERS[emperor_faction:faction_leader():get_forename()] = HRE_EMPERORS_NAMES_NUMBERS[emperor_faction:faction_leader():get_forename()] + 1;
			else
				HRE_EMPERORS_NAMES_NUMBERS[emperor_faction:faction_leader():get_forename()] = 1;
			end

			cm:show_message_event(
				cm:get_local_faction(),
				"message_event_text_text_mk_event_hre_imperial_title_retained_title",
				faction_string,
				"message_event_text_text_mk_event_hre_imperial_title_retained_secondary",
				true, 
				713
			);
		else
			-- Emperor is dead and nobody is voting or there was a tie. Is the HRE dead?
			HRE_Destroyed_Check();
		end
	end

	if not HRE_DESTROYED then
		Refresh_HRE_Elections();
	end
end

function Find_Strongest_Faction_HRE_Elections(required_states)
	local factions = {};
	local strongest_faction;

	if not required_states or (required_states and next(required_states) == nil) then
		required_states = {};

		-- Fill the required_states table with all HRE states as all will be valid.
		for k, v in pairs(HRE_STATES) do
			table.insert(required_states, k);
		end
	end

	-- If there is a pretender, always vote for them.
	if HRE_EMPEROR_PRETENDER_KEY ~= "nil" then
		return HRE_EMPEROR_PRETENDER_KEY;
	end

	for i = 1, #HRE_FACTIONS do
		local faction_name = HRE_FACTIONS[i];
		local faction = cm:model():world():faction_by_key(faction_name);
		local faction_state = HRE_Get_Faction_State(faction_name);
		local factions = {};

		if faction:is_human() or HasValue(required_states, faction_state) then
			table.insert(factions);
		end
	end

	strongest_faction = Get_Strongest_Faction(factions);

	if not strongest_faction then
		-- Still haven't found a faction to return. Pick one at random that isn't the emperor.
		local random_faction = HRE_FACTIONS[math.random(#HRE_FACTIONS)];

		while HRE_FACTIONS_STATES[random_faction] == "emperor" do
			random_faction = HRE_FACTIONS[math.random(#HRE_FACTIONS)];
		end

		strongest_faction = random_faction;
	end

	return strongest_faction;
end

function Refresh_HRE_Elections()
	for k, v in pairs(HRE_FACTIONS_VOTES) do
		if not HasValue(HRE_FACTIONS, k) then
			HRE_FACTIONS_VOTES[k] = nil;
		end

		if CURRENT_HRE_REFORM >= 1 then
			if not HasValue(HRE_FACTIONS_ELECTORS, k) then
				HRE_FACTIONS_VOTES[k] = nil;
			end
		end
	end

	if CURRENT_HRE_REFORM < 1 then
		for i = 1, #HRE_FACTIONS do
			local faction = cm:model():world():faction_by_key(HRE_FACTIONS[i]);
			
			if not faction:is_human() then
				Check_Faction_Votes_HRE_Elections(HRE_FACTIONS[i]);
			end
		end
	else
		for i = 1, #HRE_FACTIONS_ELECTORS do
			local faction = cm:model():world():faction_by_key(HRE_FACTIONS_ELECTORS[i]);
			
			if not faction:is_human() then
				Check_Faction_Votes_HRE_Elections(HRE_FACTIONS_ELECTORS[i]);
			end
		end
	end
end

function Add_New_Electors_HRE_Elections()
	while #HRE_FACTIONS_ELECTORS < 7 do
		local factions = {};
		local new_elector = nil;
		local new_elector_strength = 0;
	
		for i = 1, #HRE_FACTIONS do
			local faction_name = HRE_FACTIONS[i];

			if not HasValue(HRE_FACTIONS_ELECTORS, faction_name) and faction_name ~= HRE_EMPEROR_KEY then
				local faction = cm:model():world():faction_by_key(faction_name);
				local faction_strength = (faction:region_list():num_items() * 10) + (faction:num_allies() * 15);
				local forces = faction:military_force_list();

				for i = 0, forces:num_items() - 1 do
					local force = forces:item_at(i);
					local unit_list = forces:item_at(i):unit_list();

					faction_strength = faction_strength + unit_list:num_items();
				end

				table.insert(factions, {faction_name, faction_strength});
			end
		end

		for i = 1, #factions do
			if factions[i][2] > new_elector_strength then
				new_elector = factions[i][1];
				new_elector_strength = factions[i][2];
			end
		end

		if new_elector then
			table.insert(HRE_FACTIONS_ELECTORS, new_elector);
		else
			-- No electors found.
			break;
		end
	end

	Refresh_HRE_Elections();
end

function Check_Faction_Votes_HRE_Elections(faction_name)
	-- Make sure the faction can actually vote!
	if CURRENT_HRE_REFORM > 1 then
		if CURRENT_HRE_REFORM < 8 then
			if not HasValue(HRE_FACTIONS_ELECTORS, faction_name) then
				if HRE_FACTIONS_VOTES[faction_name] then
					HRE_FACTIONS_VOTES[faction_name] = nil;
				end
	
				return;
			end
		else
			if HRE_FACTIONS_VOTES[faction_name] then
				HRE_FACTIONS_VOTES[faction_name] = nil;
			end
	
			return;
		end
	end

	if FactionIsAlive(faction_name) then
		local emperor_alive = FactionIsAlive(HRE_EMPEROR_KEY);
		local faction_state = HRE_Get_Faction_State(faction_name);

		if faction_state == "loyal" or faction_state == "puppet" or faction_state == "emperor" then
			if emperor_alive then
				Cast_Vote_For_Faction_HRE(faction_name, HRE_EMPEROR_KEY);
			else
				-- Emperor faction is dead, so find strongest faction to elect emperor from among the loyalists' ranks.
				Cast_Vote_For_Faction_HRE(faction_name, Find_Strongest_Faction_HRE_Elections({"loyal", "puppet"}));
			end
		elseif faction_state == "neutral" then
			if emperor_alive then
				-- 50/50 chance of voting for themselves or for the emperor.
				local chance = cm:random_number(2);

				if chance == 1 then
					Cast_Vote_For_Faction_HRE(faction_name, HRE_EMPEROR_KEY);
				else
					Cast_Vote_For_Faction_HRE(faction_name, faction_name);
				end
			else
				Cast_Vote_For_Faction_HRE(faction_name, faction_name);
			end
		elseif faction_state == "ambitious" then
			Cast_Vote_For_Faction_HRE(faction_name, faction_name);
		elseif faction_state == "malcontent" or faction_state == "discontent" then
			Cast_Vote_For_Faction_HRE(faction_name, Find_Strongest_Faction_HRE_Elections({"malcontent", "discontent", "ambitious"}));
		else
			-- Faction doesn't have a state?
			HRE_State_Check(faction_name);
			Cast_Vote_For_Faction_HRE(faction_name, faction_name);
		end
	elseif HRE_FACTIONS_VOTES[faction_name] then
		HRE_FACTIONS_VOTES[faction_name] = nil;
	end
end

function Calculate_Num_Votes_HRE_Elections(faction_name)
	local votes = 0;

	for k, v in pairs(HRE_FACTIONS_VOTES) do
		if faction_name == v then
			votes = votes + 1;
		end
	end

	return votes;
end

function Cast_Vote_For_Faction_HRE(faction_name, candidate_faction_name)
	if CURRENT_HRE_REFORM == 0 or (CURRENT_HRE_REFORM > 0 and HasValue(HRE_FACTIONS_ELECTORS, faction_name)) then
		HRE_FACTIONS_VOTES[faction_name] = candidate_faction_name;
	end
end

function Cast_Vote_For_Factions_Candidate_HRE(faction_name, supporting_faction_name)
	if CURRENT_HRE_REFORM == 0 or (CURRENT_HRE_REFORM > 0 and HasValue(HRE_FACTIONS_ELECTORS, faction_name)) then
		HRE_FACTIONS_VOTES[faction_name] = HRE_FACTIONS_VOTES[supporting_faction_name];
	end
end

function HRE_Remove_Elector(faction_name)
	for i = 1, #HRE_FACTIONS_ELECTORS do
		if HRE_FACTIONS_ELECTORS[i] == faction_name then
			table.remove(HRE_FACTIONS_ELECTORS, i);
			break;
		end
	end

	if #HRE_FACTIONS_ELECTORS < 7 then
		Add_New_Electors_HRE_Elections();
	end
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		SaveTable(context, HRE_FACTIONS_ELECTORS, "HRE_FACTIONS_ELECTORS");
		SaveKeyPairTable(context, HRE_FACTIONS_VOTES, "HRE_FACTIONS_VOTES");
	end
);

cm:register_loading_game_callback(
	function(context)
		HRE_FACTIONS_ELECTORS = LoadTable(context, "HRE_FACTIONS_ELECTORS");
		HRE_FACTIONS_VOTES = LoadKeyPairTable(context, "HRE_FACTIONS_VOTES");
	end
);
