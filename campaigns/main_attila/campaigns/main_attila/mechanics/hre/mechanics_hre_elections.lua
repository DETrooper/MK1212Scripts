----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: HOLY ROMAN EMPIRE ELECTIONS
-- 	By: DETrooper
--
----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
-- System for members of the HRE to elect the next emperor from among themselves.

FACTIONS_HRE_ELECTORS = {};
FACTIONS_HRE_VOTES = {};

function Add_HRE_Election_Listeners()
	cm:add_listener(
		"FactionTurnStart_HRE_Elections",
		"FactionTurnStart",
		true,
		function(context) FactionTurnStart_HRE_Elections(context) end,
		true
	);

	if cm:is_new_game() then
		FACTIONS_HRE_VOTES = DeepCopy(FACTIONS_HRE_VOTES_START);
	end
end

function FactionTurnStart_HRE_Elections(context)
	if context:faction():name() == HRE_EMPEROR_KEY then
		if #FACTIONS_HRE_ELECTORS > 0 then
			for i = 1, #FACTIONS_HRE_ELECTORS do
				if not FactionIsAlive(FACTIONS_HRE_ELECTORS[i]) then
					table.remove(FACTIONS_HRE_ELECTORS, i);
				end
			end
		end
	end

	-- Has the first reform limiting the electors to a small group been passed?
	if CURRENT_HRE_REFORM < 1 then
		-- All factions in the HRE can currently vote.

		--[[if HasValue(FACTIONS_HRE, context:faction():name()) then
			Check_Faction_Votes_HRE_Elections(context:faction():name());
		end]]--
	-- Has the eighth reform which abolishes elections been passed?
	elseif CURRENT_HRE_REFORM < 8 then
		-- Only the prince-electors (and emperor) can vote.
		if #FACTIONS_HRE_ELECTORS < 7 then
			Add_New_Electors_HRE_Elections();
		end

		--[[if HasValue(FACTIONS_HRE_ELECTORS, context:faction():name()) or context:faction():name() == HRE_EMPEROR_KEY then
			Check_Faction_Votes_HRE_Elections(context:faction():name());
		end]]--
	end
end

function Process_Election_Result_HRE_Elections()
	local max = 0;
	local winner = nil;

	for k, v in ipairs(FACTIONS_HRE_VOTES) do
		if FACTIONS_HRE_VOTES[k] > max then
			winner, max = k, v;
		end
	end

	if winner ~= nil then
		local faction_string = "factions_screen_name_"..winner;

		if FACTIONS_DFN_LEVEL[winner] ~= nil then
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
		local faction_string = "factions_screen_name_"..HRE_EMPEROR_KEY;

		cm:show_message_event(
			cm:get_local_faction(),
			"message_event_text_text_mk_event_hre_imperial_title_retained_title",
			faction_string,
			"message_event_text_text_mk_event_hre_imperial_title_retained_secondary",
			true, 
			713
		);
	end

	Refresh_HRE_Elections();
end

function Find_Strongest_Disloyal_Faction_HRE_Elections()
	local factions = {};
	local strongest_faction = nil;
	local strongest_faction_strength = 0;

	-- If there is a pretender, always vote for them.
	if HRE_EMPEROR_PRETENDER_KEY ~= nil then
		return HRE_EMPEROR_PRETENDER_KEY;
	end

	for i = 1, #FACTIONS_HRE do
		local faction_name = FACTIONS_HRE[i];
		local faction = cm:model():world():faction_by_key(faction_name);
		local faction_state = HRE_Get_Faction_State(faction_name);

		if faction_state == "malcontent" or faction_state == "discontent" or faction_state == "ambitious" then
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
		if factions[i][2] > strongest_faction_strength then
			strongest_faction = factions[i][1];
			strongest_faction_strength = factions[i][2];
		end
	end

	if strongest_faction == nil then
		-- Still haven't found a faction to return. Pick one at random that isn't the emperor.

		local random_faction = FACTIONS_HRE[math.random(#FACTIONS_HRE)];

		while FACTIONS_HRE_STATES[random_faction] == "emperor" do
			random_faction = FACTIONS_HRE[math.random(#FACTIONS_HRE)];
		end

		strongest_faction = random_faction;
	end

	return strongest_faction;
end

function Refresh_HRE_Elections()
	for k, v in pairs(FACTIONS_HRE_VOTES) do
		if not HasValue(FACTIONS_HRE, k) then
			FACTIONS_HRE_VOTES[k] = nil;
		end

		if CURRENT_HRE_REFORM >= 1 then
			if not HasValue(FACTIONS_HRE_ELECTORS, k) then
				FACTIONS_HRE_VOTES[k] = nil;
			end
		end
	end

	if CURRENT_HRE_REFORM < 1 then
		for i = 1, #FACTIONS_HRE do
			Check_Faction_Votes_HRE_Elections(FACTIONS_HRE[i]);
		end
	else
		for i = 1, #FACTIONS_HRE_ELECTORS do
			Check_Faction_Votes_HRE_Elections(FACTIONS_HRE_ELECTORS[i]);
		end
	end
end

function Add_New_Electors_HRE_Elections()
	local factions = {};
	local new_elector = nil;
	local new_elector_strength = 0;

	while #FACTIONS_HRE_ELECTORS < 7 do
		for i = 1, #FACTIONS_HRE do
			local faction_name = FACTIONS_HRE[i];
			local faction = cm:model():world():faction_by_key(faction_name);
			local faction_state = HRE_Get_Faction_State(faction_name);

			if faction_state == "malcontent" or faction_state == "discontent" or faction_state == "ambitious" then
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

		if new_elector ~= nil then
			table.insert(FACTIONS_HRE_ELECTORS, new_elector);
		else
			return;
		end
	end

	Refresh_HRE_Elections();
end

function Check_Faction_Votes_HRE_Elections(faction_name)
	local faction_state = HRE_Get_Faction_State(faction_name);

	if faction_state == "normal" or faction_state == "loyal" or faction_state == "puppet" or faction_state == "emperor" then
		Cast_Vote_For_Faction_HRE(faction_name, HRE_EMPEROR_KEY);
	elseif faction_state == "ambitious" then
		Cast_Vote_For_Faction_HRE(faction_name, faction_name);
	elseif faction_state == "malcontent" or faction_state == "discontent" then
		Cast_Vote_For_Faction_HRE(faction_name, Find_Strongest_Disloyal_Faction_HRE_Elections());
	else
		-- Faction doesn't have a state?
		HRE_State_Check(faction_name);
		Cast_Vote_For_Faction_HRE(faction_name, faction_name);
	end
end

function Calculate_Num_Votes_HRE_Elections(faction_name)
	local votes = 0;

	for k, v in pairs(FACTIONS_HRE_VOTES) do
		if faction_name == v then
			votes = votes + 1;
		end
	end

	return votes;
end

function Cast_Vote_For_Faction_HRE(faction_name, candidate_faction_name)
	FACTIONS_HRE_VOTES[faction_name] = candidate_faction_name;
end

function Cast_Vote_For_Factions_Candidate_HRE(faction_name, supporting_faction_name)
	FACTIONS_HRE_VOTES[faction_name] = FACTIONS_HRE_VOTES[supporting_faction_name];
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		SaveKeyPairTable(context, FACTIONS_HRE_ELECTORS, "FACTIONS_HRE_ELECTORS");
		SaveKeyPairTable(context, FACTIONS_HRE_VOTES, "FACTIONS_HRE_VOTES");
	end
);

cm:register_loading_game_callback(
	function(context)
		FACTIONS_HRE_ELECTORS = LoadKeyPairTable(context, "FACTIONS_HRE_ELECTORS");
		FACTIONS_HRE_VOTES = LoadKeyPairTable(context, "FACTIONS_HRE_VOTES");
	end
);