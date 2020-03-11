--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - CHALLENGES: NO RETREAT
-- 	By: DETrooper
--
--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------

function Add_Challenge_No_Retreat_Listeners()
	cm:add_listener(
		"PendingBattle_No_Retreat",
		"PendingBattle",
		true,
		function(context) PendingBattle_No_Retreat(context) end,
		true
	);

	cm:override_ui("disable_prebattle_retreat", true);

	if cm:is_new_game() then
		Add_Custom_Battlefield();
	end
end

function PendingBattle_No_Retreat(context)
	local pending_battle = cm:model():pending_battle();
		
	if pending_battle:has_attacker() then
		if pending_battle:attacker():faction():is_human() then
			cm:override_ui("disable_prebattle_retreat", true);
		end
	end

	if pending_battle:has_defender() then
		if pending_battle:defender():faction():is_human() then
			cm:override_ui("disable_prebattle_retreat", true);
		end
	end
end

function Add_Custom_Battlefield()
	cm:add_custom_battlefield(
		"no_retreat",
		0,
		0,
		5000,
		false,
		"",
		"campaigns/main_attila/challenges/battles/battle_no_retreat.lua",
		"",
		0,
		false,
		true
	);
end;