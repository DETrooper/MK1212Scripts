----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: HOLY ROMAN EMPIRE ELECTIONS
-- 	By: DETrooper
--
----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
-- System for members of the HRE to elect the next emperor from among themselves.

mkHRE.elector_factions = {};
mkHRE.elector_votes = {};

function mkHRE:Add_Election_Listeners()
	cm:add_listener(
		"FactionTurnStart_HRE_Elections",
		"FactionTurnStart",
		true,
		function(context) FactionTurnStart_HRE_Elections(context) end,
		true
	);

	if cm:is_new_game() then
		mkHRE.elector_votes = DeepCopy(mkHRE.elector_votes_start);
	end
end

function FactionTurnStart_HRE_Elections(context)
	if not mkHRE.destroyed then
		if context:faction():name() == mkHRE.emperor_key then
			if #mkHRE.elector_factions > 0 then
				for i = 1, #mkHRE.elector_factions do
					if not FactionIsAlive(mkHRE.elector_factions[i]) then
						table.remove(mkHRE.elector_factions, i);
					end
				end
			end
		end

		-- Has the first reform limiting the electors to a small group been passed?
		if mkHRE.current_reform < 1 then
			-- All factions in the HRE can currently vote.

			--[[if HasValue(mkHRE.factions, context:faction():name()) then
				mkHRE:Check_Faction_Votes_HRE_Elections(context:faction():name());
			end]]--
		-- Has the eighth reform which abolishes elections been passed?
		elseif mkHRE.current_reform < 8 then
			-- Only the prince-electors (and emperor) can vote.
			if #mkHRE.elector_factions < 7 then
				mkHRE:Add_New_Electors_HRE_Elections();
			end

			--[[if HasValue(mkHRE.elector_factions, context:faction():name()) or context:faction():name() == mkHRE.emperor_key then
				mkHRE:Check_Faction_Votes_HRE_Elections(context:faction():name());
			end]]--
		end
	end
end

function mkHRE:Process_Election_Result_HRE_Elections()
	local max = 0;
	local winner = nil;

	for i = 1, #mkHRE.factions do
		local faction_name = mkHRE.factions[i];
		local num_votes = self:Calculate_Num_Votes(faction_name);

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

		if winner ~= mkHRE.emperor_key then
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
			local emperor_faction = cm:model():world():faction_by_key(mkHRE.emperor_key);

			if mkHRE.emperors_names_numbers[emperor_faction:faction_leader():get_forename()]  then
				mkHRE.emperors_names_numbers[emperor_faction:faction_leader():get_forename()] = mkHRE.emperors_names_numbers[emperor_faction:faction_leader():get_forename()] + 1;
			else
				mkHRE.emperors_names_numbers[emperor_faction:faction_leader():get_forename()] = 1;
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
		if FactionIsAlive(mkHRE.emperor_key) then
			local emperor_faction = cm:model():world():faction_by_key(mkHRE.emperor_key);
			local faction_string = "factions_screen_name_"..mkHRE.emperor_key;

			if mkHRE.emperors_names_numbers[emperor_faction:faction_leader():get_forename()]  then
				mkHRE.emperors_names_numbers[emperor_faction:faction_leader():get_forename()] = mkHRE.emperors_names_numbers[emperor_faction:faction_leader():get_forename()] + 1;
			else
				mkHRE.emperors_names_numbers[emperor_faction:faction_leader():get_forename()] = 1;
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
			self:Destroyed_Check();
		end
	end

	if not self.destroyed then
		self:Refresh_HRE_Elections();
	end
end

function mkHRE:Find_Strongest_Faction_HRE_Elections(required_states)
	local factions = {};
	local strongest_faction;

	if not required_states then
		required_states = {};

		-- Fill the required_states table with all HRE states as all will be valid.
		for k, v in pairs(mkHRE.factions_states) do
			table.insert(required_states, k);
		end
	end

	-- If there is a pretender, always vote for them.
	if self.emperor_pretender_key ~= "nil" then
		return self.emperor_pretender_key;
	end

	-- Assemble a list of valid factions.
	for i = 1, #mkHRE.factions do
		local faction_name = mkHRE.factions[i];
		local faction = cm:model():world():faction_by_key(faction_name);

		if not faction:is_null_interface() and FactionIsAlive(faction_name) then
			local faction_state = mkHRE:Get_Faction_State(faction_name);
			local factions = {};

			if faction:is_human() or HasValue(required_states, faction_state) then
				table.insert(factions, faction_name);
			end
		end
	end

	strongest_faction = Get_Strongest_Faction(factions);

	if not strongest_faction then
		-- Still haven't found a faction to return. Pick one at random that isn't the emperor.
		--[[local random_faction = mkHRE.factions[math.random(#mkHRE.factions)];

		while mkHRE.factions_to_states[random_faction] == "emperor" do
			random_faction = mkHRE.factions[math.random(#mkHRE.factions)];
		end

		strongest_faction = random_faction;]]--
	end

	return strongest_faction;
end

function mkHRE:Refresh_HRE_Elections()
	for k, v in pairs(self.elector_votes) do
		if not HasValue(mkHRE.factions, k) then
			self.elector_votes[k] = nil;
		end

		if self.current_reform >= 1 then
			if not HasValue(self.elector_factions, k) then
				self.elector_votes[k] = nil;
			end
		end
	end

	if self.current_reform < 1 then
		for i = 1, #mkHRE.factions do
			local faction = cm:model():world():faction_by_key(mkHRE.factions[i]);
			
			if not faction:is_human() then
				self:Check_Faction_Votes_HRE_Elections(mkHRE.factions[i]);
			end
		end
	else
		for i = 1, #self.elector_factions do
			local faction = cm:model():world():faction_by_key(self.elector_factions[i]);
			
			if not faction:is_human() then
				self:Check_Faction_Votes_HRE_Elections(self.elector_factions[i]);
			end
		end
	end
end

function mkHRE:Add_New_Electors_HRE_Elections()
	while #self.elector_factions < 7 do
		local factions = {};
		local new_elector = nil;
		local new_elector_strength = 0;
	
		for i = 1, #mkHRE.factions do
			local faction_name = mkHRE.factions[i];

			if not HasValue(self.elector_factions, faction_name) and faction_name ~= mkHRE.emperor_key then
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
			table.insert(self.elector_factions, new_elector);
		else
			-- No electors found.
			break;
		end
	end

	self:Refresh_HRE_Elections();
end

function mkHRE:Check_Faction_Votes_HRE_Elections(faction_name)
	-- Make sure the faction can actually vote!
	if self.current_reform > 1 then
		if self.current_reform < 8 then
			if not HasValue(self.elector_factions, faction_name) then
				if self.elector_votes[faction_name] then
					self.elector_votes[faction_name] = nil;
				end
	
				return;
			end
		else
			if self.elector_votes[faction_name] then
				self.elector_votes[faction_name] = nil;
			end
	
			return;
		end
	end

	if FactionIsAlive(faction_name) then
		local emperor_alive = FactionIsAlive(mkHRE.emperor_key);
		local faction_state = mkHRE:Get_Faction_State(faction_name);
		local master_faction_name = Get_Vassal_Overlord(faction_name);

		if master_faction_name and faction_state ~= "puppet" then
			return;
		end

		if faction_state == "loyal" or faction_state == "puppet" or faction_state == "emperor" then
			if emperor_alive then
				if --[[self.current_reform == 0 and]] self.elector_votes[mkHRE.emperor_key] then
					self:Cast_Vote_For_Factions_Candidate_HRE(faction_name, mkHRE.emperor_key);
				else
					self:Cast_Vote_For_Faction(faction_name, mkHRE.emperor_key);
				end
			else
				-- Emperor faction is dead, so find strongest faction to elect emperor from among the loyalists' ranks.
				self:Cast_Vote_For_Faction(faction_name, self:Find_Strongest_Faction_HRE_Elections({"loyal", "puppet"}) or faction_name);
			end
		elseif faction_state == "neutral" then
			if emperor_alive then
				-- 50/50 chance of voting for themselves or for the emperor.
				local chance = cm:random_number(2);

				if chance == 1 then
					self:Cast_Vote_For_Faction(faction_name, mkHRE.emperor_key);
				else
					self:Cast_Vote_For_Faction(faction_name, faction_name);
				end
			else
				self:Cast_Vote_For_Faction(faction_name, faction_name);
			end
		elseif faction_state == "ambitious" then
			self:Cast_Vote_For_Faction(faction_name, faction_name);
		elseif faction_state == "malcontent" or faction_state == "discontent" then
			self:Cast_Vote_For_Faction(faction_name, self:Find_Strongest_Faction_HRE_Elections({"malcontent", "discontent", "ambitious"}) or faction_name);
		else
			-- Faction doesn't have a state?
			mkHRE:State_Check(faction_name);
			self:Cast_Vote_For_Faction(faction_name, faction_name);
		end
	elseif self.elector_votes[faction_name] then
		self.elector_votes[faction_name] = nil;
	end
end

function mkHRE:Calculate_Num_Votes(faction_name)
	local votes = 0;

	for k, v in pairs(self.elector_votes) do
		if faction_name == v then
			votes = votes + 1;
		end
	end

	return votes;
end

function mkHRE:Cast_Vote_For_Faction(faction_name, candidate_faction_name)
	if faction_name and candidate_faction_name then
		if self.current_reform == 0 or (self.current_reform > 0 and HasValue(self.elector_factions, faction_name)) then
			self.elector_votes[faction_name] = candidate_faction_name;

			local vassalized_factions = FACTIONS_TO_FACTIONS_VASSALIZED[faction_name];

			for i = 1, #vassalized_factions do
				local vassal_faction_name = vassalized_factions[i];

				if self.current_reform == 0 or (self.current_reform > 0 and HasValue(self.elector_factions, vassal_faction_name)) then
					self.elector_votes[vassal_faction_name] = candidate_faction_name;
				end
			end
		end
	end
end

function mkHRE:Cast_Vote_For_Factions_Candidate_HRE(faction_name, supporting_faction_name)
	if faction_name and supporting_faction_name and self.elector_votes[supporting_faction_name] then
		if self.current_reform == 0 or (self.current_reform > 0 and HasValue(self.elector_factions, faction_name)) then
			self.elector_votes[faction_name] = self.elector_votes[supporting_faction_name];

			local vassalized_factions = FACTIONS_TO_FACTIONS_VASSALIZED[faction_name];

			for i = 1, #vassalized_factions do
				local vassal_faction_name = vassalized_factions[i];

				if self.current_reform == 0 or (self.current_reform > 0 and HasValue(self.elector_factions, vassal_faction_name)) then
					self.elector_votes[vassal_faction_name] = supporting_faction_name;
				end
			end
		end
	end
end

function mkHRE:HRE_Remove_Elector(faction_name)
	for i = 1, #self.elector_factions do
		if self.elector_factions[i] == faction_name then
			table.remove(self.elector_factions, i);
			break;
		end
	end

	if #self.elector_factions < 7 then
		self:Add_New_Electors_HRE_Elections();
	end
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		SaveTable(context, mkHRE.elector_factions, "mkHRE.elector_factions");
		SaveKeyPairTable(context, mkHRE.elector_votes, "mkHRE.elector_votes");
	end
);

cm:register_loading_game_callback(
	function(context)
		mkHRE.elector_factions = LoadTable(context, "mkHRE.elector_factions");
		mkHRE.elector_votes = LoadKeyPairTable(context, "mkHRE.elector_votes");
	end
);
