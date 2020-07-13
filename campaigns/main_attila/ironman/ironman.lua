-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - IRONMAN MODE
-- 	By: DETrooper
--
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

IRONMAN_ENABLED = false;
IRONMAN_DIPLOMACY_OCCURED = false;

function Add_Ironman_Listeners()
	if cm:is_new_game() then
		local svr = ScriptedValueRegistry:new();

		IRONMAN_ENABLED = svr:LoadBool("SBOOL_IRONMAN_ENABLED");
	end

	if IRONMAN_ENABLED then
		cm:add_listener(
			"FactionTurnStart_Ironman",
			"FactionTurnStart",
			true,
			function(context) FactionTurnStartOrEnd_Ironman(context) end,
			true
		);
		cm:add_listener(
			"FactionAboutToEndTurn_Ironman",
			"FactionAboutToEndTurn",
			true,
			function(context) FactionTurnStartOrEnd_Ironman(context) end,
			true
		);
		cm:add_listener(
			"FactionLeaderDeclaresWar_Ironman",
			"FactionLeaderDeclaresWar",
			true,
			function(context) Check_Diplomacy_Ironman(context) end,
			true
		);
		cm:add_listener(
			"FactionLeaderSignsPeaceTreaty_Ironman",
			"FactionLeaderSignsPeaceTreaty",
			true,
			function(context) Check_Diplomacy_Ironman(context) end,
			true
		);
		cm:add_listener(
			"PendingBattle_Ironman",
			"PendingBattle",
			true,
			function(context) Check_Battle_Ironman(context) end,
			true
		);
		cm:add_listener(
			"BattleCompleted_Ironman",
			"BattleCompleted",
			true,
			function(context) Check_Battle_Ironman(context) end,
			true
		);
		cm:add_listener(
			"PanelClosedCampaign_Ironman",
			"PanelClosedCampaign",
			true,
			function(context) PanelClosedCampaign_Ironman(context) end,
			true
		);
		cm:add_listener(
			"DilemmaChoiceMadeEvent_Antonina",
			"DilemmaChoiceMadeEvent",
			true,
			function(context) DilemmaChoiceMadeEvent_Ironman(context) end,
			true
		);
		cm:add_listener(
			"TimeTrigger_Ironman",
			"TimeTrigger",
			true,
			function(context) TimeTrigger_Ironman(context) end,
			true
		);

		cm:disable_saving_game(true);
	end
end

function FactionTurnStartOrEnd_Ironman(context)
	if context:faction():is_human() then
		Save_Game_Ironman(0.5);
	end
end

function Check_Diplomacy_Ironman(context)
	if context:character():faction():is_human() then
		-- Cannot save while in the diplomacy menu.
		IRONMAN_DIPLOMACY_OCCURED = true;
	end
end

function Check_Battle_Ironman(context)
	--local difficulty = cm:model():difficulty_level();
	local pending_battle = cm:model():pending_battle();

	--if difficulty > -3 then
		if pending_battle:has_attacker() then
			if pending_battle:attacker():faction():is_human() then
				Save_Game_Ironman(0.1);
			end
		end
	
		if pending_battle:has_defender() then
			if pending_battle:defender():faction():is_human() then
				Save_Game_Ironman(0.1);
			end
		end
	--end
end

function PanelClosedCampaign_Ironman(context)
	if IRONMAN_DIPLOMACY_OCCURED == true then
		IRONMAN_DIPLOMACY_OCCURED = false;

		Save_Game_Ironman(0.1);
	end
end

function DilemmaChoiceMadeEvent_Ironman(context)
	Save_Game_Ironman(0.5);
end

function Save_Game_Ironman(disable_delay)
	cm:disable_saving_game(false);
	cm:autosave_at_next_opportunity();
	cm:add_time_trigger("disable_saving", disable_delay);
end

function TimeTrigger_Ironman(context)
	if context.string == "disable_saving" then
		cm:disable_saving_game(true);
	end
end

------------------------------------------------
---------------- Saving/Loading ----------------
------------------------------------------------
cm:register_loading_game_callback(
	function(context)
		IRONMAN_ENABLED = cm:load_value("IRONMAN_ENABLED", false, context);
	end
);

cm:register_saving_game_callback(
	function(context)
		cm:save_value("IRONMAN_ENABLED", IRONMAN_ENABLED, context);
	end
);
