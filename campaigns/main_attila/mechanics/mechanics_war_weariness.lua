-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: WAR WEARINESS
-- 	Modified By: DETrooper
-- 	Original Script by Creative Assembly
--
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------

PLAYER_WAR_WEARINESS = {}; -- This is the level of war weariness the players faction is suffering
PLAYER_WAR_WEARINESS_EVENTS = {}; -- Keep track of the events shown to each player
PLAYER_WAR_WEARINESS_TURNS_AT_WAR = {}; -- The amount of turns each faction has been at war.

TURN_AT_PEACE = -3; -- This is the amount that a faction will always recover by every turn if at peace
TURN_AT_WAR = 1; -- This is the amount war weariness will increase if at war (used to be per faction).
TURN_AT_WAR_DELAY = 4; -- Amount of turns that should pass before the TURN_AT_WAR penalty begins to apply.

MAX_WAR_WEARINESS = 100; -- This is the maximum amount that the war weariness value can increase to, it can be set higher than the max war weariness level to allow a slower recovery at the top end of the scale
MIN_WAR_WEARINESS = -5; -- This is the minimum amount that the war weariness value can decrease to, it can be set lower than zero to allow the player to essentially 'bank' long periods of peace

PEACE_MADE = -3; -- The amount war weariness decreases by if the faction makes peace with someone
TROOPS_AT_HOME = -1; -- This is the maximum amount war weariness will decrease by if the player has kept their troops at home.

-- Difficulty modifiers for passive increase
WW_EASY_MOD = 0.5;
WW_NORMAL_MOD = 1.0;
WW_HARD_MOD = 1.5;
WW_VERY_HARD_MOD = 2.0;
WW_LEGENDARY_MOD = 2.0;

-- These are the values that war weariness will change by given that the player achieves that result in a battle
battle_result_values = {
	["heroic_victory"] = -10,
	["decisive_victory"] = -5,
	["close_victory"] = -3,
	["pyrrhic_victory"] = -1,
	["valiant_defeat"] = 4,
	["close_defeat"] = 6,
	["decisive_defeat"] = 8,
	["crushing_defeat"] = 10
};

function Add_War_Weariness_Listeners()
	cm:add_listener(
		"FactionTurnStart_WW",
		"FactionTurnStart",
		true,
		function(context) FactionTurnStart_WW(context) end,
		true
	);
	cm:add_listener(
		"BattleCompleted_WW",
		"BattleCompleted",
		true,
		function(context) BattleCompleted_WW(context) end,
		true
	);
	cm:add_listener(
		"FactionLeaderSignsPeaceTreaty_WW",
		"FactionLeaderSignsPeaceTreaty",
		true,
		function(context) FactionLeaderSignsPeaceTreaty_WW(context) end,
		true
	);
	
	local difficulty = cm:model():difficulty_level();

	if difficulty == 1 then -- Easy
		TURN_AT_WAR = TURN_AT_WAR * WW_EASY_MOD;
	elseif difficulty == 0 then -- Normal
		TURN_AT_WAR = TURN_AT_WAR * WW_NORMAL_MOD;
	elseif difficulty == -1 then -- Hard
		TURN_AT_WAR = TURN_AT_WAR * WW_HARD_MOD;
	elseif difficulty == -2 then -- Very Hard
		TURN_AT_WAR = TURN_AT_WAR * WW_VERY_HARD_MOD;
	elseif difficulty == -3 then -- Legendary
		TURN_AT_WAR = TURN_AT_WAR * WW_LEGENDARY_MOD;
	end
	
	if cm:is_new_game() then	
		local faction_list = cm:model():world():faction_list();
		
		for i = 0, faction_list:num_items() - 1 do
			local current_faction = faction_list:item_at(i);
			
			if current_faction:is_null_interface() == false then
				if current_faction:is_human() == true then
					cm:show_message_event(
						current_faction:name(),
						"message_event_text_text_mk_event_mk1212_wwintro_title",
						"message_event_text_text_mk_event_mk1212_wwintro_primary",
						"message_event_text_text_mk_event_mk1212_wwintro_secondary",
						true, 
						723
					);

					cm:apply_effect_bundle("att_bundle_war_weariness_0", current_faction:name(), 0);
				end

				PLAYER_WAR_WEARINESS[current_faction:name()] = 0;
				PLAYER_WAR_WEARINESS_TURNS_AT_WAR[current_faction:name()] = 0;
			end
		end
	end
end

function FactionTurnStart_WW(context)
	local faction = context:faction();
	local faction_name = faction:name();

	-- Turn based war weariness increase/decrease depending on war and army locations		
	if faction:at_war() then
		-- AT WAR (DOES NOT AFFECT HORDES IN MK1212)

		if faction:is_horde() == false then
			if PLAYER_WAR_WEARINESS_TURNS_AT_WAR[faction_name] ~= nil then
				if PLAYER_WAR_WEARINESS_TURNS_AT_WAR[faction_name] >= TURN_AT_WAR_DELAY then
					Add_War_Weariness(faction_name, TURN_AT_WAR);

					local troopsAtHome = ArmiesInOwnLands(faction);
				
					if troopsAtHome >= 100 then
						Add_War_Weariness(faction_name, TROOPS_AT_HOME);
					elseif troopsAtHome >= 75 then
						Add_War_Weariness(faction_name, TROOPS_AT_HOME / 2);
					end
				end

				PLAYER_WAR_WEARINESS_TURNS_AT_WAR[faction_name] = PLAYER_WAR_WEARINESS_TURNS_AT_WAR[faction_name] + 1;
			else
				PLAYER_WAR_WEARINESS_TURNS_AT_WAR[faction_name] = 1;
			end
		end
	else
		-- AT PEACE
		PLAYER_WAR_WEARINESS_TURNS_AT_WAR[faction_name] = 0;
		Add_War_Weariness(faction_name, TURN_AT_PEACE);
	end
	
	Update_War_Weariness(faction);
end

function Update_War_Weariness(faction)
	if faction:is_null_interface() then
		return;
	end

	local war_weariness = 0;
	local bundle_applied = false;
	
	if PLAYER_WAR_WEARINESS[faction:name()]  then
		war_weariness = PLAYER_WAR_WEARINESS[faction:name()];
	end
	
	-----------------------------------------------------------
	---------------- Apply the correct effects ----------------
	-----------------------------------------------------------
	for i = 0, 100 do
		cm:remove_effect_bundle("att_bundle_war_weariness_"..i, faction:name());
	end
	
	-- Can only handle whole numbers
	war_weariness = math.floor(war_weariness);
	
	if war_weariness > 0 then
		cm:apply_effect_bundle("att_bundle_war_weariness_"..war_weariness, faction:name(), 0);
		bundle_applied = true;
	else
		cm:apply_effect_bundle("att_bundle_war_weariness_0", faction:name(), 0);
	end
	
	-----------------------------------------------------------
	---------------- Handle the message events ----------------
	-----------------------------------------------------------
	local last_shown_event = "DECREASED";
	
	if PLAYER_WAR_WEARINESS_EVENTS[faction:name()]  then
		last_shown_event = PLAYER_WAR_WEARINESS_EVENTS[faction:name()];
	end
	
	if last_shown_event == "DECREASED" then
		if bundle_applied == true then
			Show_War_Weariness_Message(faction:name(), "cha_rel_christianity_increase");
			PLAYER_WAR_WEARINESS_EVENTS[faction:name()] = "INCREASED";
		end
	end
end

function FactionLeaderSignsPeaceTreaty_WW(context)
	if context:character():faction():is_human() then
		Add_War_Weariness(context:character():faction():name(), PEACE_MADE);
	end
end

function BattleCompleted_WW(context)
	local attacker_result = cm:model():pending_battle():attacker_battle_result();
	local defender_result = cm:model():pending_battle():defender_battle_result();
	
	if attacker_result == "close_defeat" and defender_result == "close_defeat" then
		-- They've both had a close defeat, must have been a retreat not a battle!
		return;
	elseif attacker_result == nil or defender_result == nil then
		return;
	end

	local attacker_cqi, attacker_force_cqi, attacker_name = cm:pending_battle_cache_get_attacker(1);
	local defender_cqi, defender_force_cqi, defender_name = cm:pending_battle_cache_get_defender(1);
	local attacker = cm:model():world():faction_by_key(attacker_name);
	local defender = cm:model():world():faction_by_key(defender_name);
	
	if attacker:is_null_interface() == false then		
		--if attacker:is_human() then
			local ww_value = battle_result_values[attacker_result];
			
			Add_War_Weariness(attacker:name(), ww_value);
			Update_War_Weariness(attacker);
		--end
	end
	
	if defender:is_null_interface() == false then		
		--if defender:is_human() then
			local ww_value = battle_result_values[defender_result];

			Add_War_Weariness(defender:name(), ww_value);
			Update_War_Weariness(defender);
		--end
	end
end

-------------------------------------------
---------------- Functions ----------------
-------------------------------------------
function Add_War_Weariness(faction, amount)

	if PLAYER_WAR_WEARINESS[faction] == nil then
		PLAYER_WAR_WEARINESS[faction] = MIN_WAR_WEARINESS + amount;
		PLAYER_WAR_WEARINESS[faction] = math.max(PLAYER_WAR_WEARINESS[faction], MIN_WAR_WEARINESS);
		PLAYER_WAR_WEARINESS[faction] = math.min(PLAYER_WAR_WEARINESS[faction], MAX_WAR_WEARINESS);
	else
		PLAYER_WAR_WEARINESS[faction] = PLAYER_WAR_WEARINESS[faction] + amount;
		PLAYER_WAR_WEARINESS[faction] = math.max(PLAYER_WAR_WEARINESS[faction], MIN_WAR_WEARINESS);
		PLAYER_WAR_WEARINESS[faction] = math.min(PLAYER_WAR_WEARINESS[faction], MAX_WAR_WEARINESS);
	end
end

function WarWearinessNerf()
	TURN_AT_WAR = 0;
end

function ArmiesInOwnLands(player)
	local forceCount = player:military_force_list():num_items();
	local trueForces = 0;
	local forcesAtHome = 0;

	for i = 0, forceCount - 1 do
		local force = player:military_force_list():item_at(i);
		
		if force:upkeep() > 0 then
			trueForces = trueForces + 1;
		
			if force:has_general() then
				local general = force:general_character();
				
				if general:has_region() then
					local regionOwner = general:region():owning_faction();
				
					if regionOwner:is_null_interface() == false then
						if regionOwner:name() == player:name() then
							forcesAtHome = forcesAtHome + 1;
						end
					end
				end
			end
		end
	end
	
	if trueForces > 0 then
		local percentAtHome = (forcesAtHome / trueForces) * 100;
		return percentAtHome;
	else
		-- Can't find any armies
		return 0;
	end
end

function Show_War_Weariness_Message(faction_name, event_ID)
	--local event_num = war_weariness_events[event_ID].num;
	local event_text = war_weariness_events[event_ID].text;
	local title = event_texts[event_text].title;
	local primary = event_texts[event_text].primary;
	local secondary = event_texts[event_text].secondary;	

	cm:show_message_event(
		faction_name,
		title,
		primary,
		secondary,
		false,
		723
	);
end

------------------------------------------------
---------------- Saving/Loading ----------------
------------------------------------------------
cm:register_loading_game_callback(
	function(context)
		PLAYER_WAR_WEARINESS = LoadKeyPairTableNumbers(context, "PLAYER_WAR_WEARINESS");
		PLAYER_WAR_WEARINESS_EVENTS = LoadKeyPairTable(context, "PLAYER_WAR_WEARINESS_EVENTS");
		PLAYER_WAR_WEARINESS_TURNS_AT_WAR = LoadKeyPairTableNumbers(context, "PLAYER_WAR_WEARINESS_TURNS_AT_WAR");
	end
);
cm:register_saving_game_callback(
	function(context)
		SaveKeyPairTable(context, PLAYER_WAR_WEARINESS, "PLAYER_WAR_WEARINESS");
		SaveKeyPairTable(context, PLAYER_WAR_WEARINESS_EVENTS, "PLAYER_WAR_WEARINESS_EVENTS");
		SaveKeyPairTable(context, PLAYER_WAR_WEARINESS_TURNS_AT_WAR, "PLAYER_WAR_WEARINESS_TURNS_AT_WAR");
	end
);

------------------------------------------------
-------------- Event Text Strings --------------
------------------------------------------------
war_weariness_events = {
	["cha_rel_christianity_increase"] = {num = 401, text = "increase"},
	["cha_rel_christianity_decrease"] = {num = 403, text = "decrease"},
};
event_texts = {
	["increase"] = {
	title = "event_feed_strings_text_att_event_feed_string_scripted_event_war_weariness_increase_title",
	primary = "event_feed_strings_text_att_event_feed_string_scripted_event_war_weariness_increase_primary_detail",
	secondary = "event_feed_strings_text_att_event_feed_string_scripted_event_war_weariness_increase_secondary_detail"
	},
	["decrease"] = {
	title = "event_feed_strings_text_att_event_feed_string_scripted_event_war_weariness_decrease_title",
	primary = "event_feed_strings_text_att_event_feed_string_scripted_event_war_weariness_decrease_primary_detail",
	secondary = "event_feed_strings_text_att_event_feed_string_scripted_event_war_weariness_decrease_secondary_detail"
	}
};
