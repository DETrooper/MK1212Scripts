----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: POPE COLLEGE OF CARDINALS
-- 	By: DETrooper
--
----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
-- System for Catholic factions to elect priests to popehood.

COLLEGE_OF_CARDINALS_CHARACTERS = {};
COLLEGE_OF_CARDINALS_VOTES = {};

function Add_Pope_College_Listeners()
	cm:add_listener(
		"CharacterBecomesFactionLeader_Pope_College",
		"CharacterBecomesFactionLeader",
		true,
		function(context) CharacterBecomesFactionLeader_Pope_College(context) end,
		true
	);
	cm:add_listener(
		"CharacterTurnStart_Pope_College",
		"CharacterTurnStart",
		true,
		function(context) CharacterTurnStart_Pope_College(context) end,
		true
	);
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

function CharacterBecomesFactionLeader_Pope_College(context)
	local faction_name = context:character():faction():name();
end

function CharacterTurnStart_Pope_College(context)

end

function FactionTurnStart_Pope_College(context)

end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:register_saving_game_callback(
	function(context)

	end
);

cm:register_loading_game_callback(
	function(context)

	end
);
