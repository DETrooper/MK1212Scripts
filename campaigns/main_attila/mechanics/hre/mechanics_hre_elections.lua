----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: HOLY ROMAN EMPIRE ELECTIONS
-- 	By: DETrooper
--
----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
-- System for members of the HRE to elect the next emperor from among themselves.

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
		SaveKeyPairTable(context, FACTIONS_HRE_VOTES, "FACTIONS_HRE_VOTES");
	end
);

cm:register_loading_game_callback(
	function(context)
		FACTIONS_HRE_VOTES = LoadKeyPairTable(context, "FACTIONS_HRE_VOTES");
	end
);