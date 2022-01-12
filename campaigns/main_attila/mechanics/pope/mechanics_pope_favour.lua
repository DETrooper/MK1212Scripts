------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: POPE FAVOUR
-- 	By: DETrooper
--
------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------

-- This is the code that makes the Pope disapprove of your actions, you heretic!
-- Favour works from 0 to 10, similar to Medieval II. Being at 1 is a mild chance of excommunication, while 0 is excommunication for sure!
-- This script also handles the 'borrow money from the pope' decision for Catholic factions.

PAPAL_STATES_KEY = "mk_fact_papacy";

PAPAL_FAVOUR_SYSTEM_ACTIVE = true; -- Disabled if Papal States faction does not exist.
PAPAL_FAVOUR_SYSTEM_FORCE_STOPPED = false; -- Papal favour will never restart even if the Papal States faction is alive.
FACTION_POPE_FAVOUR = {};
FACTION_EXCOMMUNICATED = {};
MAX_POPE_FAVOUR = 10;
MIN_POPE_FAVOUR = 0;
AT_WAR_WITH_POPE = {};
FAVOUR_LAST_ATTACKED_GARRISON = "";
POSTBATTLE_DECISION_ENEMY_CATHOLIC = false;
POSTBATTLE_DECISION_MADE_RECENTLY = false;
POPE_DEPOSED = false;

function Add_Pope_Favour_Listeners()
	cm:add_listener(
		"FactionTurnStart_Check_Catholic_Nations",
		"FactionTurnStart",
		true,
		function(context) FactionTurnStart_Check_Catholic_Nations(context) end,
		true
	);

	if PAPAL_FAVOUR_SYSTEM_ACTIVE == true and PAPAL_FAVOUR_SYSTEM_FORCE_STOPPED == false then
		Activate_Papal_Favour_System();
	end

	if cm:is_multiplayer() == false then
		Register_Decision(
			"ask_pope_for_money", 
			function() 	
				local conditionstring = "Conditions:\n\n([[rgba:8:201:27:150]]Y[[/rgba]]) - Is religion: Catholic.\n";
				local money = "5000";
				local faction_name = cm:get_local_faction();
				
				if FACTION_EXCOMMUNICATED[faction_name] == true then
					conditionstring = conditionstring.."([[rgba:255:0:0:150]]X[[/rgba]]) - Is not excommunicated.\n";
				else
					conditionstring = conditionstring.."([[rgba:8:201:27:150]]Y[[/rgba]]) - Is not excommunicated.\n";
				end
			
				if FACTION_POPE_FAVOUR[faction_name] > 7 then
					conditionstring = conditionstring.."([[rgba:8:201:27:150]]Y[[/rgba]]) - Papal Favour is greater than 7.\n";
				else
					conditionstring = conditionstring.."([[rgba:255:0:0:150]]X[[/rgba]]) - Papal Favour is greater than 7.\n";
				end
			
				if FACTION_POPE_FAVOUR[faction_name] == 9 then
					money = "7500";
				elseif FACTION_POPE_FAVOUR[faction_name] == 10 then
					money = "10000";
				end
			
				conditionstring = conditionstring.."\nEffects:\n\n- Recieve [[rgba:255:215:0:215]]"..money.." money[[/rgba]] at the cost of [[rgba:255:0:0:150]]3 Papal Favour[[/rgba]].";
			
				return conditionstring;
			end, 
			nil, 
			nil, 
			Decision_Pope_Money
		);
	end
	
	local faction_list = cm:model():world():faction_list();
	local pope_faction = cm:model():world():faction_by_key(PAPAL_STATES_KEY);

	for i = 0, faction_list:num_items() - 1 do
		local current_faction = faction_list:item_at(i);

		AT_WAR_WITH_POPE[current_faction:name()] = current_faction:at_war_with(pope_faction);

		if cm:is_new_game() then
			if current_faction:state_religion() == "att_rel_chr_catholic" and current_faction ~= pope_faction then
				if current_faction:name() ~= "mk_fact_hre" and current_faction:name() ~= "mk_fact_portugal" then
					cm:apply_effect_bundle("mk_bundle_pope_favour_5", current_faction:name(), 0);
					FACTION_POPE_FAVOUR[current_faction:name()] = 5;

					if current_faction:is_human() and cm:is_multiplayer() == false then
						Add_Decision("ask_pope_for_money", current_faction:name(), false, false);
					end
				else
					Force_Excommunication(current_faction:name(), true);
				end
			end
		end
	end
end

function Activate_Papal_Favour_System()
	cm:add_listener(
		"FactionLeaderDeclaresWar_Pope",
		"FactionLeaderDeclaresWar",
		true,
		function(context) Check_Excommunication_Pope_War(context) end,
		true
	);
	cm:add_listener(
		"GarrisonAttackedEvent_Pope",
		"GarrisonAttackedEvent",
		true,
		function(context) GarrisonAttackedEvent_Pope(context) end,
		true
	);
	cm:add_listener(
		"CharacterPerformsOccupationDecisionLoot_Pope",
		"CharacterPerformsOccupationDecisionLoot",
		true,
		function(context) Check_If_Catholic_Attacked(context, "LOOTED") end,
		true
	);
	cm:add_listener(
		"CharacterPerformsOccupationDecisionSack_Pope",
		"CharacterPerformsOccupationDecisionSack",
		true,
		function(context) Check_If_Catholic_Attacked(context, "SACKED") end,
		true 
	);
	cm:add_listener(
		"CharacterPerformsOccupationDecisionOccupy_Pope",
		"CharacterPerformsOccupationDecisionOccupy",
		true,
		function(context) Check_If_Catholic_Attacked(context, "OCCUPY") end,
		true
	);
	cm:add_listener(
		"CharacterCompletedBattle_Pope_Favour",
		"CharacterCompletedBattle",
		true,
		function(context) CharacterCompletedBattle_Pope_Favour(context) end,
		true
	);
	cm:add_listener(
		"CharacterParticipatedAsSecondaryGeneralInBattle_Pope_Favour",
		"CharacterParticipatedAsSecondaryGeneralInBattle",
		true,
		function(context) CharacterCompletedBattle_Pope_Favour(context) end,
		true
	);
	cm:add_listener(
		"CharacterPostBattleEnslave_Pope",
		"CharacterPostBattleEnslave",
		true,
		function(context) CharacterPostBattle_Favour(context, "ENSLAVE") end,
		true
	);
	cm:add_listener(
		"CharacterPostBattleRelease_Pope",
		"CharacterPostBattleRelease",
		true,
		function(context) CharacterPostBattle_Favour(context, "RELEASE") end,
		true
	);
	cm:add_listener(
		"CharacterPostBattleSlaughter_Pope",
		"CharacterPostBattleSlaughter",
		true,
		function(context) CharacterPostBattle_Favour(context, "SLAUGHTER") end,
		true
	);
	cm:add_listener(
		"CharacterBecomesFactionLeader_Pope",
		"CharacterBecomesFactionLeader",
		true,
		function(context) Remove_Excommunication(context) end,
		true
	);
	cm:add_listener(
		"DilemmaChoiceMadeEvent_Pope",
		"DilemmaChoiceMadeEvent",
		true,
		function(context) DilemmaChoiceMadeEvent_Pope(context) end,
		true
	);
	cm:add_listener(
		"FactionReligionConverted_Pope",
		"FactionReligionConverted",
		true,
		function(context) FactionReligionConverted_Pope(context) end,
		true
	);
	cm:add_listener(
		"MissionFailed_Check_Mission",
		"MissionFailed",
		true,
		function(context) MissionFailed_Check_Mission(context) end,
		true
	);
	cm:add_listener(
		"MissionSucceeded_Check_Mission",
		"MissionSucceeded",
		true,
		function(context) MissionSucceeded_Check_Mission(context) end,
		true
	);
	cm:add_listener(
		"TimeTrigger_Pope",
		"TimeTrigger",
		true,
		function(context) TimeTrigger_Pope(context) end,
		true
	);
end

function Reactivate_Papal_Favour_System()
	if PAPAL_FAVOUR_SYSTEM_FORCE_STOPPED == false then
		PAPAL_FAVOUR_SYSTEM_ACTIVE = true;
		Activate_Papal_Favour_System();

		local faction_list = cm:model():world():faction_list();

		for i = 0, faction_list:num_items() - 1 do
			local current_faction = faction_list:item_at(i);

			cm:remove_effect_bundle("mk_bundle_christian_dejection", current_faction:name());

			if current_faction:state_religion() == "att_rel_chr_catholic" then
				cm:apply_effect_bundle("mk_bundle_pope_favour_5", current_faction:name(), 0);
				FACTION_POPE_FAVOUR[current_faction:name()] = 5;

				if current_faction:is_human() and cm:is_multiplayer() == false then
					Add_Decision("ask_pope_for_money", current_faction:name(), false, false);
				end
			end

			cm:show_message_event(
				current_faction:name(),
				"message_event_text_text_mk_event_pope_papacy_restored_title",
				"message_event_text_text_mk_event_pope_papacy_restored_primary",
				"message_event_text_text_mk_event_pope_papacy_restored_secondary",
				true,
				701
			);
		end
	end
end

function Deactivate_Papal_Favour_System()
	PAPAL_FAVOUR_SYSTEM_ACTIVE = false;
	cm:remove_listener("FactionLeaderDeclaresWar_Pope");
	cm:remove_listener("GarrisonAttackedEvent_Pope");
	cm:remove_listener("CharacterPerformsOccupationDecisionLoot_Pope");
	cm:remove_listener("CharacterPerformsOccupationDecisionSack_Pope");
	cm:remove_listener("CharacterPerformsOccupationDecisionOccupy_Pope");
	cm:remove_listener("CharacterCompletedBattle_Pope_Favour");
	cm:remove_listener("CharacterParticipatedAsSecondaryGeneralInBattle_Pope_Favour");
	cm:remove_listener("CharacterPostBattleEnslave_Pope");
	cm:remove_listener("CharacterPostBattleRelease_Pope");
	cm:remove_listener("CharacterPostBattleSlaughter_Pope");
	cm:remove_listener("CharacterBecomesFactionLeader_Pope");
	cm:remove_listener("DilemmaChoiceMadeEvent_Pope");
	cm:remove_listener("FactionReligionConverted_Pope");
	cm:remove_listener("MissionFailed_Check_Mission");
	cm:remove_listener("MissionSucceeded_Check_Mission");
	cm:remove_listener("TimeTrigger_Pope");

	local faction_list = cm:model():world():faction_list();

	for i = 0, faction_list:num_items() - 1 do
		local current_faction = faction_list:item_at(i);

		AT_WAR_WITH_POPE[current_faction:name()] = false;

		if FACTION_EXCOMMUNICATED[current_faction:name()] == true then
			Remove_Excommunication_Manual(current_faction:name());
		end

		if current_faction:is_human() and cm:is_multiplayer() == false then
			Remove_Decision("ask_pope_for_money");
		end

		for j = 0, 10 do
			cm:remove_effect_bundle("mk_bundle_pope_favour_"..j, current_faction:name());
		end
	end
end

function Force_Stop_Papal_Favour_System()
	Deactivate_Papal_Favour_System();
	PAPAL_FAVOUR_SYSTEM_FORCE_STOPPED = true;
end

function FactionTurnStart_Check_Catholic_Nations(context)
	local faction_name = context:faction():name();
	local faction_religion = context:faction():state_religion();
	local turn_number = cm:model():turn_number();

	if faction_religion == "att_rel_chr_catholic" and faction_name ~= PAPAL_STATES_KEY then
		local pope_faction = cm:model():world():faction_by_key(PAPAL_STATES_KEY);
		local war_with_pope = context:faction():at_war_with(pope_faction);

		AT_WAR_WITH_POPE[faction_name] = war_with_pope;

		if PAPAL_FAVOUR_SYSTEM_ACTIVE then
			-- Todo: See if this block is even necessary, dunno why it would be.
			if context:faction():is_human() and cm:model():turn_number() > 1 then
				-- Human faction changed religion, giving them an effect bundle!
				cm:apply_effect_bundle("mk_bundle_pope_favour_5", faction_name, 0);
			end

			if FACTION_EXCOMMUNICATED[faction_name] ~= true then
				if war_with_pope then
					Force_Excommunication(faction_name);
				else
					-- Possible stances from strategic_stance_between_factions are -3 to 3, corresponding to diplomatic stances (i.e. 2 being Very Friendly, -2 being Hostile).
					local stance = cm:model():campaign_ai():strategic_stance_between_factions(PAPAL_STATES_KEY, faction_name);

					if stance <= -3 then
						local chance = cm:random_number(3);

						if chance == 1 then
							Subtract_Pope_Favour(faction_name, 1, "relations_decay");
						end
					elseif stance == -2 then
						local chance = cm:random_number(6);

						if chance == 1 then
							Subtract_Pope_Favour(faction_name, 1, "relations_decay");
						end
					elseif stance == 2 then
						local chance = cm:random_number(6);

						if chance == 1 then
							Add_Pope_Favour(faction_name, 1, "relations_increase");
						end
					elseif stance >= 3 then
						local chance = cm:random_number(3);
						
						if chance == 1 then
							Add_Pope_Favour(faction_name, 1, "relations_increase");
						end
					end
				end
			end

			Update_Pope_Favour(context:faction());
		end
	elseif faction_religion ~= "att_rel_chr_catholic" and FACTION_POPE_FAVOUR[faction_name]  then
		-- Faction is no longer Catholic!
		FACTION_POPE_FAVOUR[faction_name] = nil;

		for i = 0, 10 do
			cm:remove_effect_bundle("mk_bundle_pope_favour_"..i, faction_name);
		end

		Remove_Excommunication_Manual(faction_name);

		if context:faction():is_human() and cm:is_multiplayer() == false then
			Remove_Decision("ask_pope_for_money");
		end
	end

	if faction_name == PAPAL_STATES_KEY and PAPAL_FAVOUR_SYSTEM_ACTIVE == false then
		-- Papal States liberated!
		Reactivate_Papal_Favour_System();
	end
end

function GarrisonAttackedEvent_Pope(context)
	FAVOUR_LAST_ATTACKED_GARRISON = "";

	if context:garrison_residence():is_null_interface() == false then
		if context:garrison_residence():faction():is_null_interface() == false then
			FAVOUR_LAST_ATTACKED_GARRISON = context:garrison_residence():faction():name();
		end
	end
end

function Check_If_Catholic_Attacked(context, type)
	local region = FindClosestRegion(context:character():logical_position_x(), context:character():logical_position_y(), "none"); -- Taking the character's region may be inaccurate if they're at sea or across a strait.

	if region then
		local region_name = region:name();
		local faction_name = context:character():faction():name();

		if region_name ~= "att_reg_italia_roma" and faction_name ~= PAPAL_STATES_KEY then
			if type == "LOOTED" or type == "SACKED" then
				if SackExploitCheck_Pope(region_name) == true then
					if context:character():faction():is_human() and context:character():faction():state_religion() == "att_rel_chr_catholic" and FACTION_EXCOMMUNICATED[faction_name] ~= true then
						local defender_cqi, defender_force_cqi, defender_name = cm:pending_battle_cache_get_defender(1);

						if defender_name ~= "rebels" then
							if FAVOUR_LAST_ATTACKED_GARRISON ~= "" and (FAVOUR_LAST_ATTACKED_GARRISON ~= defender_name) then
								defender_name = FAVOUR_LAST_ATTACKED_GARRISON;
							end

							local sacked_faction = cm:model():world():faction_by_key(defender_name);

							if sacked_faction:is_null_interface() == false then
								local sacked_rel = sacked_faction:state_religion();

								if sacked_rel == "att_rel_chr_catholic" then
									-- Sacked/Looted another Catholic faction!
									Subtract_Pope_Favour(faction_name, 1, "sacked_settlement");
								end
							end
						end
					end
				end
			end
		else
			if region:owning_faction():name() == PAPAL_STATES_KEY then
				if context:character():faction():is_human() then
					if context:character():faction():state_religion() == "att_rel_chr_catholic" then
						cm:trigger_dilemma(faction_name, "mk_dilemma_rome_attacked_christian");
						Force_Excommunication(faction_name);
					else
						cm:show_message_event(
							faction_name,
							"message_event_text_text_mk_event_pope_rome_attacked_nonchrist_title",
							"message_event_text_text_mk_event_pope_rome_attacked_nonchrist_primary",
							"message_event_text_text_mk_event_pope_rome_attacked_nonchrist_secondary",
							true,
							708
						);

						for i = 0, faction_list:num_items() - 1 do
							local current_faction = faction_list:item_at(i);

							if current_faction:state_religion() == "att_rel_chr_catholic" then
								cm:apply_effect_bundle("mk_bundle_christian_dejection", current_faction:name(), 0);
							end
						end

						Deactivate_Papal_Favour_System();
					end
				end
			end
		end
	end
end

function Check_Excommunication_Pope_War(context)
	if AT_WAR_WITH_POPE[context:character():faction():name()] == false then
		-- They weren't at war with the Pope...
		local pope_faction = cm:model():world():faction_by_key(PAPAL_STATES_KEY);
		local now_at_war = context:character():faction():at_war_with(pope_faction);
			
		if now_at_war == true then
			-- They are now at war with the Pope!
			AT_WAR_WITH_POPE[context:character():faction():name()] = true;
				
			if context:character():faction():state_religion() == "att_rel_chr_catholic" then
				Force_Excommunication(context:character():faction():name());
			else
				cm:show_message_event(
					context:character():faction():name(),
					"message_event_text_text_mk_event_pope_enemy_of_christendom_title",
					"message_event_text_text_mk_event_pope_enemy_of_christendom_primary",
					"message_event_text_text_mk_event_pope_enemy_of_christendom_secondary",
					true,
					709
				);

				cm:apply_effect_bundle("mk_bundle_christendoms_outcry", context:character():faction():name(), 0);
			end
		end
	end
end

function CharacterCompletedBattle_Pope_Favour(context)
	local character = context:character();

	if character:faction():state_religion() == "att_rel_chr_catholic" and character:faction():is_human() then	
		local character_force_cqi = -1;
		
		if character:has_military_force() then
			character_force_cqi = character:military_force():command_queue_index();
		end
		
		if character_force_cqi == -1 then
			return;
		end
		
		local pending_battle = cm:model():pending_battle();
		local attacker_result = nil;
		local defender_result = nil;
		
		if pending_battle:has_attacker() then
			attacker_result = pending_battle:attacker_battle_result();
		end
		
		if pending_battle:has_defender() then
			defender_result = pending_battle:defender_battle_result();
		end
		
		if attacker_result == "close_defeat" and defender_result == "close_defeat" then
			-- They've both had a close defeat, probably a retreat!
			POSTBATTLE_DECISION_ENEMY_CATHOLIC = false;
			return;
		end

		if pending_battle:attacker():has_military_force() and pending_battle:attacker():faction():state_religion() == "att_rel_chr_catholic" and pending_battle:defender():has_military_force() and pending_battle:defender():faction():state_religion() == "att_rel_chr_catholic" then
			POSTBATTLE_DECISION_ENEMY_CATHOLIC = true;
		else
			POSTBATTLE_DECISION_ENEMY_CATHOLIC = false;
		end
	end
end

function CharacterPostBattle_Favour(context, type)
	if context:character():faction():state_religion() == "att_rel_chr_catholic" and context:character():faction():is_human() and POSTBATTLE_DECISION_MADE_RECENTLY == false and POSTBATTLE_DECISION_ENEMY_CATHOLIC == true then
		if FACTION_EXCOMMUNICATED[context:character():faction():name()] ~= true then
			if type == "RELEASE" then
				Add_Pope_Favour(context:character():faction():name(), 1, "released_captives");
			elseif type == "SLAUGHTER" then
				local faction_name = context:character():faction():name();

				if faction_name ~= PAPAL_STATES_KEY and faction_name ~= POPE_CONTROLLING_FACTION then
					Subtract_Pope_Favour(context:character():faction():name(), 1, "slaughtered_captives");
				end
			end
		end

		POSTBATTLE_DECISION_MADE_RECENTLY = true;
		
		cm:add_time_trigger("Postbattle_Decision_Pope", 1);

		Update_Pope_Favour(context:character():faction());
	end
end

function DilemmaChoiceMadeEvent_Pope(context)
	if context:dilemma() == "mk_dilemma_rome_attacked_christian" then
		local papacy = cm:model():world():faction_by_key(PAPAL_STATES_KEY);

		if context:choice() == 0 then
			-- Choice made to keep a puppet pope!
			Remove_Excommunication_Manual(context:faction():name());
			FACTION_POPE_FAVOUR[context:faction():name()] = 10;
			Update_Pope_Favour(context:faction());
		elseif context:choice() == 1 then
			-- Choice made to depose the pope!
			POPE_DEPOSED = true;
			--[[if papacy:is_null_interface() == false then
				cm:grant_faction_handover(context:faction():name(), PAPAL_STATES_KEY, turn_number-1, turn_number-1, context);
			end]]--
			Deactivate_Papal_Favour_System();
		end
	end
end

function FactionReligionConverted_Pope(context)
	local faction = context:faction();
	local faction_name = faction:name();
	local state_religion = faction:state_religion();

	if PAPAL_FAVOUR_SYSTEM_ACTIVE == true then
		if state_religion == "att_rel_chr_catholic" then
			if faction_name == CURRENT_CRUSADE_TARGET_OWNER then
				End_Crusade("aborted");
			end

			Update_Pope_Favour(faction);
		elseif FACTION_POPE_FAVOUR[faction_name]  then
			FACTION_POPE_FAVOUR[faction_name] = nil;

			for i = 0, 10 do
				cm:remove_effect_bundle("mk_bundle_pope_favour_"..i, faction_name);
			end

			Remove_Excommunication_Manual(faction_name);

			if faction:is_human() then 
				if cm:is_multiplayer() == false then
					Remove_Decision("ask_pope_for_money");
				end

				if MISSION_TAKE_JERUSALEM_ACTIVE == true then
					MISSION_TAKE_JERUSALEM_ACTIVE = false;
					cm:remove_listener("CharacterEntersGarrison_Jerusalem");
					cm:cancel_custom_mission(faction_name, "mk_mission_crusades_take_jerusalem_dilemma");
					Make_Peace_Crusades(faction_name);
				end
			end

			if HasValue(CURRENT_CRUSADE_FACTIONS_JOINED, faction_name) then
				Remove_Faction_From_Crusade(faction_name);
			end
		end
	end
end

function MissionSucceeded_Check_Mission(context)
	local faction_name = context:faction():name();

	if faction_name ~= PAPAL_STATES_KEY then
		local mission_name = context:mission():mission_record_key();

		if mission_name == "att_religious_catholic_assassinate_character_1" then
			Add_Pope_Favour(faction_name, 1, "mission_succeed_generic");
		elseif mission_name == "att_religious_catholic_construct_bch_religion_catholic_legendary_1" then
			Add_Pope_Favour(faction_name, 1, "mission_succeed_generic");
		elseif mission_name == "att_religious_catholic_construct_bch_religion_catholic_major_1" then
			Add_Pope_Favour(faction_name, 1, "mission_succeed_generic");
		elseif mission_name == "att_religious_catholic_construct_bch_religion_catholic_minor_1" then
			Add_Pope_Favour(faction_name, 1, "mission_succeed_generic");
		elseif mission_name == "att_religious_catholic_construct_building_religious_1" then
			Add_Pope_Favour(faction_name, 1, "mission_succeed_generic");
		elseif mission_name == "att_religious_catholic_convert_region_1" then
			Add_Pope_Favour(faction_name, 1, "mission_succeed_generic");
		elseif mission_name == "att_religious_catholic_declare_war_1" then
			Add_Pope_Favour(faction_name, 1, "mission_succeed_generic");
		elseif mission_name == "att_religious_catholic_recruit_agent_1" then
			Add_Pope_Favour(faction_name, 1, "mission_succeed_generic");
		elseif mission_name == "mk_religious_catholic_intervention_end_war" then
			Add_Pope_Favour(faction_name, 1, "mission_succeed_peace");
		end

		if context:faction():state_religion() == "att_rel_chr_catholic" then
			Update_Pope_Favour(context:faction());	
		end
	end
end

function MissionFailed_Check_Mission(context)
	local faction_name = context:faction():name();

	if faction_name ~= PAPAL_STATES_KEY and faction_name ~= POPE_CONTROLLING_FACTION then
		local mission_name = context:mission():mission_record_key();

		if mission_name == "att_religious_catholic_construct_bch_religion_catholic_legendary_1" then
			Subtract_Pope_Favour(faction_name, 1, "mission_fail_generic");
		elseif mission_name == "att_religious_catholic_construct_bch_religion_catholic_major_1" then
			Subtract_Pope_Favour(faction_name, 1, "mission_fail_generic");
		elseif mission_name == "att_religious_catholic_construct_bch_religion_catholic_minor_1" then
			Subtract_Pope_Favour(faction_name, 1, "mission_fail_generic");
		elseif mission_name == "att_religious_catholic_construct_building_religious_1" then
			Subtract_Pope_Favour(faction_name, 1, "mission_fail_generic");
		elseif mission_name == "att_religious_catholic_convert_region_1" then
			Subtract_Pope_Favour(faction_name, 1, "mission_fail_generic");
		elseif mission_name == "att_religious_catholic_recruit_agent_1" then
			Subtract_Pope_Favour(faction_name, 1, "mission_fail_generic");
		elseif mission_name == "mk_religious_catholic_intervention_end_war" then
			Subtract_Pope_Favour(faction_name, 3, "mission_fail_peace");
		end
		
		if context:faction():state_religion() == "att_rel_chr_catholic" then
			Update_Pope_Favour(context:faction());	
		end
	end
end

function Update_Pope_Favour(faction)
	local pope_favour = 5;
	local bundle_applied = false;
	
	if FACTION_POPE_FAVOUR[faction:name()]  then
		pope_favour = FACTION_POPE_FAVOUR[faction:name()];
	else
		FACTION_POPE_FAVOUR[faction:name()] = 5;
	end

	-- Remove every Pope favour effect bundle from 0 to 10.
	for i = 0, 10 do
		cm:remove_effect_bundle("mk_bundle_pope_favour_"..i, faction:name());
	end
	
	-- Can only handle whole numbers
	pope_favour = math.floor(pope_favour);
	
	if pope_favour > 0 then
		cm:apply_effect_bundle("mk_bundle_pope_favour_"..pope_favour, faction:name(), 0);
		bundle_applied = true;
	else
		cm:apply_effect_bundle("mk_bundle_pope_favour_0", faction:name(), 0);
	end

	Check_Excommunication_Low_Favour(faction);

	if faction:is_human() and cm:is_multiplayer() == false then
		if pope_favour > 7 then
			Enable_Decision("ask_pope_for_money");
		else
			Disable_Decision("ask_pope_for_money");
		end
	end
end

function Check_Excommunication_Low_Favour(faction)
	local faction_name = faction:name();

	if FACTION_POPE_FAVOUR[faction_name] == 0 and FACTION_EXCOMMUNICATED[faction_name] ~= true then
		cm:apply_effect_bundle("mk_bundle_pope_excommunication", faction_name, 0);
		FACTION_EXCOMMUNICATED[faction_name] = true;

		if faction:is_human() and cm:is_multiplayer() == false then
			Remove_Decision("ask_pope_for_money");
		end

		if IRONMAN_ENABLED then
			if faction:is_human() and cm:is_multiplayer() == false then
				Unlock_Achievement("achievement_its_only_human_to_sin");
			end
		end

		cm:show_message_event(
			faction_name,
			"message_event_text_text_mk_event_pope_excommunication_title",
			"message_event_text_text_mk_event_pope_excommunication_primary",
			"message_event_text_text_mk_event_pope_excommunication_secondary",
			true, 
			707
		);

		local faction_list = cm:model():world():faction_list();

		for i = 0, faction_list:num_items() - 1 do
			local current_faction = faction_list:item_at(i);
			local current_faction_name = current_faction:name();

			if current_faction_name ~= faction_name and current_faction:is_human() then
				local faction_string = "factions_screen_name_"..faction_name;

				if FACTIONS_DFN_LEVEL[faction_name] and FACTIONS_DFN_LEVEL[faction_name] > 1 then
					faction_string = "campaign_localised_strings_string_"..faction_name.."_lvl"..tostring(FACTIONS_DFN_LEVEL[faction_name]);
				end

				cm:show_message_event(
					current_faction_name,
					"message_event_text_text_mk_event_pope_excommunication_other_title",
					faction_string,
					"message_event_text_text_mk_event_pope_excommunication_other_secondary",
					true,
					707
				);
			end
		end

		if NICKNAMES then
			Increase_Character_Nickname_Stat(faction:faction_leader():cqi(), "times_excommunicated", 1);
		end
	end
end

function Force_Excommunication(faction_name, silent)
	if FACTION_EXCOMMUNICATED[faction_name] ~= true then
		local faction = cm:model():world():faction_by_key(faction_name);

		FACTION_POPE_FAVOUR[faction_name] = 0;
		FACTION_EXCOMMUNICATED[faction_name] = true;

		for i = 0, 10 do
			cm:remove_effect_bundle("mk_bundle_pope_favour_"..i, faction_name);
		end

		cm:apply_effect_bundle("mk_bundle_pope_favour_0", faction_name, 0);
		cm:apply_effect_bundle("mk_bundle_pope_excommunication", faction_name, 0);

		if faction:is_human() and cm:is_multiplayer() == false then
			Remove_Decision("ask_pope_for_money");
		end

		if not silent then
			if IRONMAN_ENABLED then
				if faction:is_human() and cm:is_multiplayer() == false then
					Unlock_Achievement("achievement_its_only_human_to_sin");
				end
			end

			cm:show_message_event(
				faction_name,
				"message_event_text_text_mk_event_pope_excommunication_title",
				"message_event_text_text_mk_event_pope_excommunication_primary",
				"message_event_text_text_mk_event_pope_excommunication_secondary",
				true, 
				707
			);

			Increase_Character_Nickname_Stat(faction:faction_leader():cqi(), "times_excommunicated", 1);

			local faction_list = cm:model():world():faction_list();

			for i = 0, faction_list:num_items() - 1 do
				local current_faction = faction_list:item_at(i);
				local current_faction_name = current_faction:name();

				if current_faction_name ~= faction_name and current_faction:is_human() then
					local faction_string = "factions_screen_name_"..faction_name;

					if FACTIONS_DFN_LEVEL[faction_name] and FACTIONS_DFN_LEVEL[faction_name] > 1 then
						faction_string = "campaign_localised_strings_string_"..faction_name.."_lvl"..tostring(FACTIONS_DFN_LEVEL[faction_name]);
					end

					cm:show_message_event(
						current_faction_name,
						"message_event_text_text_mk_event_pope_excommunication_other_title",
						faction_string,
						"message_event_text_text_mk_event_pope_excommunication_other_secondary",
						true,
						707
					);
				end
			end
		end
	end
end

function Remove_Excommunication(context)
	-- This faction has a new leader, so lets remove their excommunication!

	if FACTION_EXCOMMUNICATED[context:character():faction():name()] == true then
		FACTION_EXCOMMUNICATED[context:character():faction():name()] = false;
		cm:remove_effect_bundle("mk_bundle_pope_excommunication", context:character():faction():name());

		if context:character():faction():state_religion() == "att_rel_chr_catholic" then
			FACTION_POPE_FAVOUR[context:character():faction():name()] = 2;

			if context:character():faction():is_human() and cm:is_multiplayer() == false then
				Add_Decision("ask_pope_for_money", context:character():faction():name(), false, false);
			end

			cm:show_message_event(
				context:faction():name(),
				"message_event_text_text_mk_event_pope_excommunication_lifted_title",
				"message_event_text_text_mk_event_pope_excommunication_lifted_primary",
				"message_event_text_text_mk_event_pope_excommunication_lifted_secondary",
				true, 
				701
			);

			local faction_list = cm:model():world():faction_list();

			for i = 0, faction_list:num_items() - 1 do
				local current_faction = faction_list:item_at(i);

				if current_faction:name() ~= context:faction():name() and current_faction:is_human() then
					local rank = FACTIONS_DFN_LEVEL(context:faction():name());

					cm:show_message_event(
						current_faction:name(),
						"message_event_text_text_mk_event_pope_excommunication_lifted_other_title",
						"campaign_localised_strings_string_"..context:faction():name().."_lvl"..tostring(rank),
						"message_event_text_text_mk_event_pope_excommunication_lifted_other_secondary",
						true, 
						707
					);
				end
			end
		end
	end
end

function Remove_Excommunication_Manual(faction_name)
	local faction = cm:model():world():faction_by_key(faction_name);

	FACTION_EXCOMMUNICATED[faction_name] = false;
	cm:remove_effect_bundle("mk_bundle_pope_excommunication", faction_name);

	if faction:state_religion() == "att_rel_chr_catholic" and PAPAL_FAVOUR_SYSTEM_ACTIVE == true then
		FACTION_POPE_FAVOUR[faction_name] = 2;

		if faction:is_human() and cm:is_multiplayer() == false then
			Add_Decision("ask_pope_for_money", faction_name, false, false);
		end

		cm:show_message_event(
			faction_name,
			"message_event_text_text_mk_event_pope_excommunication_lifted_title",
			"message_event_text_text_mk_event_pope_excommunication_lifted_primary",
			"message_event_text_text_mk_event_pope_excommunication_lifted_secondary",
			true, 
			701
		);

		local faction_list = cm:model():world():faction_list();

		for i = 0, faction_list:num_items() - 1 do
			local current_faction = faction_list:item_at(i);

			if current_faction:name() ~= faction_name and current_faction:is_human() then
				local rank = FACTIONS_DFN_LEVEL(faction_name);

				cm:show_message_event(
					current_faction:name(),
					"message_event_text_text_mk_event_pope_excommunication_lifted_other_title",
					"campaign_localised_strings_string_"..faction_name.."_lvl"..tostring(rank),
					"message_event_text_text_mk_event_pope_excommunication_lifted_other_secondary",
					true, 
					707
				);
			end
		end

		Update_Pope_Favour(faction);
	end
end

function Decision_Pope_Money(faction_name)
	local faction =  cm:model():world():faction_by_key(faction_name);

	if FACTION_POPE_FAVOUR[faction_name] == 8 then
		cm:treasury_mod(faction_name, 5000);
	elseif FACTION_POPE_FAVOUR[faction_name] == 9 then
		cm:treasury_mod(faction_name, 7500);
	elseif FACTION_POPE_FAVOUR[faction_name] == 10 then
		cm:treasury_mod(faction_name, 10000);
	end

	Subtract_Pope_Favour(faction_name, 3, "borrowed_money");
end

function Add_Pope_Favour(faction_name, amount, reason)
	local faction =  cm:model():world():faction_by_key(faction_name);

	if FACTION_POPE_FAVOUR[faction_name] == nil then
		FACTION_POPE_FAVOUR[faction_name] = 5 + amount;
		FACTION_POPE_FAVOUR[faction_name] = math.max(FACTION_POPE_FAVOUR[faction_name], MIN_POPE_FAVOUR);
		FACTION_POPE_FAVOUR[faction_name] = math.min(FACTION_POPE_FAVOUR[faction_name], MAX_POPE_FAVOUR);
	else
		FACTION_POPE_FAVOUR[faction_name] = FACTION_POPE_FAVOUR[faction_name] + amount;
		FACTION_POPE_FAVOUR[faction_name] = math.max(FACTION_POPE_FAVOUR[faction_name], MIN_POPE_FAVOUR);
		FACTION_POPE_FAVOUR[faction_name] = math.min(FACTION_POPE_FAVOUR[faction_name], MAX_POPE_FAVOUR);
	end

	cm:show_message_event(
		faction_name,
		"message_event_text_text_mk_event_pope_favour_increase_title",
		"message_event_text_text_mk_event_pope_favour_increase_primary_"..reason,
		"message_event_text_text_mk_event_pope_favour_increase_secondary_"..reason,
		true, 
		701
	);

	Update_Pope_Favour(faction);
end

function Subtract_Pope_Favour(faction_name, amount, reason)
	local faction =  cm:model():world():faction_by_key(faction_name);

	if FACTION_POPE_FAVOUR[faction_name] == nil then
		FACTION_POPE_FAVOUR[faction_name] = 5 - amount;
		FACTION_POPE_FAVOUR[faction_name] = math.max(FACTION_POPE_FAVOUR[faction_name], MIN_POPE_FAVOUR);
		FACTION_POPE_FAVOUR[faction_name] = math.min(FACTION_POPE_FAVOUR[faction_name], MAX_POPE_FAVOUR);
	else
		FACTION_POPE_FAVOUR[faction_name] = FACTION_POPE_FAVOUR[faction_name] - amount;
		FACTION_POPE_FAVOUR[faction_name] = math.max(FACTION_POPE_FAVOUR[faction_name], MIN_POPE_FAVOUR);
		FACTION_POPE_FAVOUR[faction_name] = math.min(FACTION_POPE_FAVOUR[faction_name], MAX_POPE_FAVOUR);
	end

	cm:show_message_event(
		faction_name,
		"message_event_text_text_mk_event_pope_favour_decrease_title",
		"message_event_text_text_mk_event_pope_favour_decrease_primary_"..reason,
		"message_event_text_text_mk_event_pope_favour_decrease_secondary_"..reason,
		true, 
		707
	);

	Update_Pope_Favour(faction);
end

function TimeTrigger_Pope(context)
	if context.string == "Postbattle_Decision_Pope" then
		POSTBATTLE_DECISION_MADE_RECENTLY = false;
	end
end

------------------------------------------------
---------------- Saving/Loading ----------------
------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		SaveKeyPairTable(context, FACTION_POPE_FAVOUR, "FACTION_POPE_FAVOUR");
		SaveBooleanPairTable(context, FACTION_EXCOMMUNICATED, "FACTION_EXCOMMUNICATED");
		cm:save_value("PAPAL_FAVOUR_SYSTEM_ACTIVE", PAPAL_FAVOUR_SYSTEM_ACTIVE, context);
		cm:save_value("PAPAL_FAVOUR_SYSTEM_FORCE_STOPPED", PAPAL_FAVOUR_SYSTEM_FORCE_STOPPED, context);
		cm:save_value("FAVOUR_LAST_ATTACKED_GARRISON", FAVOUR_LAST_ATTACKED_GARRISON, context);
		cm:save_value("POPE_DEPOSED", POPE_DEPOSED, context);
	end
);

cm:register_loading_game_callback(
	function(context)
		FACTION_POPE_FAVOUR = LoadKeyPairTableNumbers(context, "FACTION_POPE_FAVOUR");
		FACTION_EXCOMMUNICATED = LoadBooleanPairTable(context, "FACTION_EXCOMMUNICATED");
		PAPAL_FAVOUR_SYSTEM_ACTIVE = cm:load_value("PAPAL_FAVOUR_SYSTEM_ACTIVE", true, context);
		PAPAL_FAVOUR_SYSTEM_FORCE_STOPPED = cm:load_value("PAPAL_FAVOUR_SYSTEM_FORCE_STOPPED", false, context);
		FAVOUR_LAST_ATTACKED_GARRISON = cm:load_value("FAVOUR_LAST_ATTACKED_GARRISON", "", context);
		POPE_DEPOSED = cm:load_value("POPE_DEPOSED", false, context);
	end
);
