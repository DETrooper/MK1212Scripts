----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - ISLAM: HAJJ
-- 	By: DETrooper
--
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------

NEEDS_TO_GO_ON_HAJJ_P1 = true; -- At the start of the game, existing faction leader should go on hajj.
NEEDS_TO_GO_ON_HAJJ_P2 = true; -- For player 2 if MP campaign.
HAJJ_WAITING_TIME_P1 = 0;
HAJJ_WAITING_TIME_P2 = 0;

function Add_Islam_Hajj_Listeners()
	cm:add_listener(
		"FactionTurnStart_Hajj_Check",
		"FactionTurnStart",
		true,
		function(context) Hajj_Check(context) end,
		true
	);
	cm:add_listener(
		"DilemmaChoiceMadeEvent_Hajj",
		"DilemmaChoiceMadeEvent",
		true,
		function(context) DilemmaChoiceMadeEvent_Hajj(context) end,
		true
	);
	cm:add_listener(
		"CharacterBecomesFactionLeader_Islamic_Hajj",
		"CharacterBecomesFactionLeader",
		true,
		function(context) CharacterBecomesFactionLeader_Islamic_Hajj(context) end,
		true
	);
end

function Hajj_Check(context)
	local faction_name_p1 = (cm:model():faction_for_command_queue_index(HUMAN_FACTIONS[1])):name();

	if context:faction():is_human() == true and (context:faction():state_religion() == "att_rel_semitic_paganism" or context:faction():state_religion() == "mk_rel_ibadi_islam" or context:faction():state_religion() == "mk_rel_shia_islam") then
		if context:faction():name() == faction_name_p1 then
			if HAJJ_WAITING_TIME_P1 > 0 then
				HAJJ_WAITING_TIME_P1 = HAJJ_WAITING_TIME_P1 - 1;
			end
			if NEEDS_TO_GO_ON_HAJJ_P1 == true and HAJJ_WAITING_TIME_P1 <= 0 then
				NEEDS_TO_GO_ON_HAJJ_P1 = false;
				cm:trigger_dilemma(faction_name_p1, "mk_dilemma_islam_hajj");
			end
		end
		if ( HUMAN_FACTIONS[2]  ) then
			local faction_name_p2 = (cm:model():faction_for_command_queue_index(HUMAN_FACTIONS[2])):name();

			if context:faction():name() == faction_name_p2 then
				if HAJJ_WAITING_TIME_P2 > 0 then
					HAJJ_WAITING_TIME_P2 = HAJJ_WAITING_TIME_P2 - 1;
				end
				if NEEDS_TO_GO_ON_HAJJ_P2 == true and HAJJ_WAITING_TIME_P2 <= 0 then
					NEEDS_TO_GO_ON_HAJJ_P2 = false;
					cm:trigger_dilemma(faction_name_p2, "mk_dilemma_islam_hajj");
				end
			end
		end
	end
end

function DilemmaChoiceMadeEvent_Hajj(context)
	local faction_name_p1 = (cm:model():faction_for_command_queue_index(HUMAN_FACTIONS[1])):name();

	if context:faction():name() == faction_name_p1 then
		if context:dilemma() == "mk_dilemma_islam_hajj" then
			if context:choice() == 0 then
	
			elseif context:choice() == 1 then
				HAJJ_WAITING_TIME_P1 = 1;
				NEEDS_TO_GO_ON_HAJJ_P1 = true;
			elseif context:choice() == 2 then
				HAJJ_WAITING_TIME_P1 = 5;
				NEEDS_TO_GO_ON_HAJJ_P1 = true;
			end
		end
	end
	if ( HUMAN_FACTIONS[2]  ) then
		local faction_name_p2 = (cm:model():faction_for_command_queue_index(HUMAN_FACTIONS[2])):name();
		if context:faction():name() == faction_name_p1 then
			if context:dilemma() == "mk_dilemma_islam_hajj" then
				if context:choice() == 0 then
	
				elseif context:choice() == 1 then
					HAJJ_WAITING_TIME_P1 = 1;
					NEEDS_TO_GO_ON_HAJJ_P1 = true;
				elseif context:choice() == 2 then
					HAJJ_WAITING_TIME_P1 = 5;
					NEEDS_TO_GO_ON_HAJJ_P1 = true;
				end
			end
		end
	end
end

function CharacterBecomesFactionLeader_Islamic_Hajj(context)
	local faction_name_p1 = (cm:model():faction_for_command_queue_index(HUMAN_FACTIONS[1])):name();

	if context:character():faction():is_human() == true and (context:character():faction():state_religion() == "att_rel_semitic_paganism" or context:character():faction():state_religion() == "mk_rel_ibadi_islam" or context:character():faction():state_religion() == "mk_rel_shia_islam") then
		if context:character():faction():name() == faction_name_p1 then
			NEEDS_TO_GO_ON_HAJJ = true;
			HAJJ_WAITING_TIME_P1 = 0;
		end
		if ( HUMAN_FACTIONS[2]  ) then 
			local faction_name_p2 = (cm:model():faction_for_command_queue_index(HUMAN_FACTIONS[2])):name();

			if context:character():faction():name() == faction_name_p2 then
				NEEDS_TO_GO_ON_HAJJ_P2 = true;
				HAJJ_WAITING_TIME_P2 = 0;
			end
		end
	end
end

cm:register_saving_game_callback(
	function(context)
		cm:save_value("NEEDS_TO_GO_ON_HAJJ_P1", NEEDS_TO_GO_ON_HAJJ_P1, context);
		cm:save_value("NEEDS_TO_GO_ON_HAJJ_P2", NEEDS_TO_GO_ON_HAJJ_P2, context);
		cm:save_value("HAJJ_WAITING_TIME_P1", HAJJ_WAITING_TIME_P1, context);
		cm:save_value("HAJJ_WAITING_TIME_P2", HAJJ_WAITING_TIME_P2, context);
	end
);

cm:register_loading_game_callback(
	function(context)
		NEEDS_TO_GO_ON_HAJJ_P1 = cm:load_value("NEEDS_TO_GO_ON_HAJJ_P1", true, context);
		NEEDS_TO_GO_ON_HAJJ_P2 = cm:load_value("NEEDS_TO_GO_ON_HAJJ_P2", true, context);
		HAJJ_WAITING_TIME_P1 = cm:load_value("HAJJ_WAITING_TIME_P1", 0, context);
		HAJJ_WAITING_TIME_P2 = cm:load_value("HAJJ_WAITING_TIME_P2", 0, context);
	end
);