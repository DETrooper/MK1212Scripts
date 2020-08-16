----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - LUCKY NATIONS
-- 	By: DETrooper
--
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

LUCKY_NATIONS_ENABLED = false;

function Add_Lucky_Nations_Listeners()
	if cm:is_new_game() then
		local svr = ScriptedValueRegistry:new();

		LUCKY_NATIONS_ENABLED = svr:LoadBool("SBOOL_LUCKY_NATIONS_ENABLED");
	end

	if LUCKY_NATIONS_ENABLED then
		cm:add_listener(
			"FactionTurnStart_Lucky_Nations",
			"FactionTurnStart",
			true,
			function(context) FactionTurnStart_Lucky_Nations(context) end,
			true
		);
		cm:add_listener(
			"PendingBattle_Lucky_Nations",
			"PendingBattle",
			true,
			function(context) PendingBattle_Lucky_Nations(context) end,
			true
		);

		if cm:is_new_game() then
			local faction_list = cm:model():world():faction_list();

			for i = 0, faction_list:num_items() - 1 do
				local current_faction = faction_list:item_at(i);
				local current_faction_name = current_faction:name();

				if not current_faction:is_human() then
					if FactionIsAlive(current_faction_name) then
						if HasValue(LUCKY_NATIONS, current_faction_name) then
							cm:apply_effect_bundle("mk_bundle_lucky_nation", current_faction_name, 0);
						end
					end
				end
			end
		end
	end
end

function FactionTurnStart_Lucky_Nations(context)
	local faction_name = context:faction():name();
	
	if not context:faction():is_human() then
		if HasValue(LUCKY_NATIONS, faction_name) then
			cm:apply_effect_bundle("mk_bundle_lucky_nation", faction_name, 0); -- Keep applying this in case the faction has just come back to life, it won't stack.
			cm:treasury_mod(faction_name, 2500);
		end
	end
end

function PendingBattle_Lucky_Nations(context)
	local pending_battle = cm:model():pending_battle();
		
	if pending_battle:has_attacker() and pending_battle:has_defender() then
		local attacker = pending_battle:attacker():faction();
		local defender = pending_battle:defender():faction();

		if attacker:is_human() ~= true and defender:is_human() ~= true then
			local attacker_lucky = HasValue(LUCKY_NATIONS, attacker:name());
			local defender_lucky = HasValue(LUCKY_NATIONS, defender:name());

			if attacker_lucky == true and defender_lucky ~= true then
				--cm:win_next_autoresolve_battle(attacker:name());
				cm:modify_next_autoresolve_battle(
					1, 			-- attacker win chance
					0.75,	 	-- defender win chance
					0.75,	 	-- attacker losses modifier
					1,			-- defender losses modifier
					false		-- force wipe out loser
				);
			elseif defender_lucky == true and attacker_lucky ~= true then
				--cm:win_next_autoresolve_battle(defender:name());
				cm:modify_next_autoresolve_battle(
					0.75, 		-- attacker win chance
					1,	 		-- defender win chance
					1,	 		-- attacker losses modifier
					0.75,		-- defender losses modifier
					false		-- force wipe out loser
				);
			end
		end
	end
end

------------------------------------------------
---------------- Saving/Loading ----------------
------------------------------------------------
cm:register_loading_game_callback(
	function(context)
		LUCKY_NATIONS_ENABLED = cm:load_value("LUCKY_NATIONS_ENABLED", false, context);
	end
);

cm:register_saving_game_callback(
	function(context)
		cm:save_value("LUCKY_NATIONS_ENABLED", LUCKY_NATIONS_ENABLED, context);
	end
);
