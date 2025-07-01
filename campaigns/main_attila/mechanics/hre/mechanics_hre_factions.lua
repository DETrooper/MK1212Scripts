---------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: HOLY ROMAN EMPIRE FACTIONS
-- 	By: DETrooper
--
---------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
-- Keeps track of which factions are in the HRE, and which faction is the emperor. Also handles imperial authority and liberation.

local hre_emperor_mission_authority_reward = 50; -- The amount of Imperial Authority rewarded for beating a pretender.
local hre_imperial_authority_start = 40; -- Starting Imperial Authority. New emperors should also start with this amount.
local hre_imperial_authority_gain_rate = 1; -- Base Imperial Authority gain per turn.
local hre_imperial_authority_gain_per_region = 0.3; -- Imperial Authority gain per region in the HRE.
local hre_faction_state_change_cooldown = 2; -- How many turns before a faction's state can change after it has been changed?

mkHRE.emperor_key = "mk_fact_hre"; -- Starting emperor.
mkHRE.emperor_mission_win_turn = 0;
mkHRE.emperor_mission_active = false;
mkHRE.emperor_pretender_key = "mk_fact_sicily"; -- Starting pretender, isn't in the HRE proper though.
mkHRE.emperor_pretender_cooldown = 0; -- Every time a pretender is vanquished there will be a cooldown before the Pope can make a new one.
mkHRE.imperial_authority = 40; -- Imperial Authority (Can be spent on decrees, reforms, or in events).
mkHRE.imperial_authority_min = 0; -- Minimum Imperial Authority.
mkHRE.imperial_authority_max = 100; -- Maximum Imperial Authority.

mkHRE.frankfurt_region_key = "att_reg_germania_uburzis";
mkHRE.frankfurt_status = "capital";

mkHRE.liberated_faction = nil;
mkHRE.liberation_disabled = true;
mkHRE.factions = {};
mkHRE.factions_to_states = {};
mkHRE.faction_state_change_cooldowns = {};

function mkHRE:Add_Faction_Listeners()
	cm:add_listener(
		"FactionTurnStart_HRE_Factions_Wrapper",
		"FactionTurnStart",
		true,
		function(context) FactionTurnStart_HRE_Factions_Wrapper(context) end,
		true
	);
	cm:add_listener(
		"BattleCompleted_HRE_Factions",
		"BattleCompleted",
		true,
		function(context) BattleCompleted_HRE_Factions(context) end,
		true
	);
	cm:add_listener(
		"CharacterBecomesFactionLeader_HRE_Factions",
		"CharacterBecomesFactionLeader",
		true,
		function(context) CharacterBecomesFactionLeader_HRE_Factions(context) end,
		true
	);
	cm:add_listener(
		"DilemmaChoiceMadeEvent_HRE_Pretender",
		"DilemmaChoiceMadeEvent",
		true,
		function(context) DilemmaChoiceMadeEvent_HRE_Pretender(context) end,
		true
	);
	cm:add_listener(
		"FactionBecomesLiberationVassal_HRE_Factions",
		"FactionBecomesLiberationVassal",
		true,
		function(context) FactionBecomesLiberationVassal_HRE_Factions(context) end,
		true
	);
	cm:add_listener(
		"FactionLeaderDeclaresWar_HRE_Factions",
		"FactionLeaderDeclaresWar",
		true,
		function(context) FactionLeaderDeclaresWar_HRE_Factions(context) end,
		true
	)
	cm:add_listener(
		"GarrisonAttackedEvent_HRE_Factions",
		"GarrisonAttackedEvent",
		true,
		function(context) GarrisonAttackedEvent_HRE_Factions(context) end,
		true
	);
	cm:add_listener(
		"GarrisonOccupiedEvent_HRE_Frankfurt",
		"GarrisonOccupiedEvent",
		true,
		function(context) GarrisonOccupiedEvent_HRE_Frankfurt(context) end,
		true
	);
	cm:add_listener(
		"MissionIssued_HRE_Factions",
		"MissionIssued",
		true,
		function(context) MissionIssued_HRE_Factions(context) end,
		true
	);
	cm:add_listener(
		"TimeTrigger_HRE_Factions",
		"TimeTrigger",
		true,
		function(context) TimeTrigger_HRE_Factions(context) end,
		true
	);

	if cm:is_new_game() then
		self.factions = DeepCopy(self.factions_start);
		self.factions_to_states = DeepCopy(self.factions_to_states_start);

		for i = 1, #self.factions do
			self.faction_state_change_cooldowns[self.factions[i]] = hre_faction_state_change_cooldown;
		end
	end
end

function FactionTurnStart_HRE_Factions_Wrapper(context)
    local success, errorMsg = pcall(function() FactionTurnStart_HRE_Factions(context) end)
    if not success then
        DebugLog("FactionTurnStart_HRE_Factions Error: " .. errorMsg)
    end
end

function FactionTurnStart_HRE_Factions(context)
    local faction_name = context:faction():name();

    if faction_name == mkHRE.emperor_key and mkHRE.current_reform < 9 then
        local faction_list = cm:model():world():faction_list();

        for i = 0, faction_list:num_items() - 1 do
            local current_faction = faction_list:item_at(i);
            local current_faction_name = current_faction:name();

            if HasValue(mkHRE.factions, current_faction_name) and current_faction_name ~= mkHRE.emperor_key then
                mkHRE:State_Check(current_faction_name);
            elseif current_faction_name == mkHRE.emperor_key then
                mkHRE.factions_to_states[current_faction_name] = "emperor";
            elseif current_faction_name == mkHRE.emperor_pretender_key then
                mkHRE.factions_to_states[current_faction_name] = "pretender";
            else
                mkHRE.factions_to_states[current_faction_name] = nil;
            end
        end

        mkHRE.imperial_authority = mkHRE:Calculate_Imperial_Authority();

        if mkHRE.emperor_pretender_key == "nil" and FACTION_EXCOMMUNICATED[faction_name] == true and mkHRE.emperor_pretender_cooldown <= 0 then
            if context:faction():is_human() then
                mkHRE:Assign_New_Pretender(true);
            else
                mkHRE:Assign_New_Pretender(false);
            end
        elseif mkHRE.emperor_pretender_key ~= "nil" then
            if cm:model():world():faction_by_key(mkHRE.emperor_pretender_key):has_home_region() == false then
                mkHRE:HRE_Vanquish_Pretender();
            end
        end

        if mkHRE.emperor_pretender_cooldown > 0 then
            mkHRE.emperor_pretender_cooldown = mkHRE.emperor_pretender_cooldown - 1;
        end

		for k, v in pairs(mkHRE.faction_state_change_cooldowns) do
			if mkHRE.faction_state_change_cooldowns[k] > 0 then
				mkHRE.faction_state_change_cooldowns[k] = mkHRE.faction_state_change_cooldowns[k] - 1;
			end
		end

		if mkHRE.emperor_mission_active == false then
			if mkHRE.emperor_pretender_key ~= "nil" then
				if context:faction():is_human() then
					cm:trigger_mission(mkHRE.emperor_key, "mk_mission_story_hre_survive_pretender");
				else
					mkHRE.emperor_mission_win_turn = cm:model():turn_number() + 9;
				end

				mkHRE.emperor_mission_active = true;
			end
		else
			local emperor_faction = cm:model():world():faction_by_key(mkHRE.emperor_key);
			local pretender_faction = cm:model():world():faction_by_key(mkHRE.emperor_pretender_key);

			if cm:model():turn_number() == mkHRE.emperor_mission_win_turn then
				if emperor_faction:is_human() then
					cm:override_mission_succeeded_status(mkHRE.emperor_key, "mk_mission_story_hre_survive_pretender", true);
				elseif pretender_faction:is_human() then
					cm:override_mission_succeeded_status(mkHRE.emperor_pretender_key, "mk_mission_story_pretender_take_frankfurt", false);
				end

				mkHRE:Pretender_End_Mission(false, "time");
			end
		end

		if mkHRE.liberation_disabled == true then
			mkHRE.liberation_disabled = false;
		end
	else
		if mkHRE.liberation_disabled == true then
			mkHRE.liberation_disabled = true;
		end
	end

	if context:faction():is_human() then
		mkHRE:Check_Factions_In_Empire(); -- Check every turn to see which factions are still in the HRE or which should be removed (such as if they were destroyed).

		mkHRE:Button_Check(); -- Check every turn if the HRE panel should be hidden or not.
		mkHRE:Destroyed_Check(); -- Check to see if the HRE as a whole is destroyed.
		mkHRE:Emperor_Check(); -- Check to see if the emperor's faction is dead or destroyed.
	end
end

function BattleCompleted_HRE_Factions(context)
	mkHRE:Check_Factions_In_Empire();
end

function CharacterBecomesFactionLeader_HRE_Factions(context)
	local faction_name = context:character():faction():name();

	-- When faction leaders of HRE member states die, set their attitude to neutral if not a puppet, then check to see if their state should be something else.
	if faction_name ~= mkHRE.emperor_key and HasValue(mkHRE.factions, faction_name) and not context:character():faction():is_human() then
		local faction_state = mkHRE:Get_Faction_State(faction_name);

		if faction_state ~= "puppet" then
			mkHRE:Set_Faction_State(faction_name, "neutral", true);
			mkHRE:State_Check(faction_name);

			if mkHRE.current_reform > 1 and mkHRE.current_reform < 8 then
				mkHRE:Check_Faction_Votes_HRE_Elections(faction_name);
			end
		end
	elseif mkHRE.emperor_pretender_key ~= "nil" then
		if faction_name == mkHRE.emperor_pretender_key then
			local emperor_faction = cm:model():world():faction_by_key(mkHRE.emperor_key);

			if emperor_faction:is_human() then
				cm:override_mission_succeeded_status(mkHRE.emperor_key, "mk_mission_story_hre_survive_pretender", true);
			elseif context:character():faction():is_human() then
				cm:override_mission_succeeded_status(mkHRE.emperor_pretender_key, "mk_mission_story_pretender_take_frankfurt", false);
			end

			mkHRE:Pretender_End_Mission(false, "death");
		elseif faction_name == mkHRE.emperor_key then
			local pretender_faction = cm:model():world():faction_by_key(mkHRE.emperor_pretender_key);

			if context:character():faction():is_human() then
				cm:override_mission_succeeded_status(mkHRE.emperor_key, "mk_mission_story_hre_survive_pretender", false);
			elseif pretender_faction:is_human() then
				cm:override_mission_succeeded_status(mkHRE.emperor_pretender_key, "mk_mission_story_pretender_take_frankfurt", true);
			end

			mkHRE:Pretender_End_Mission(true, "victory");
		end
	elseif faction_name == mkHRE.emperor_key and mkHRE.current_reform < 8 then
		mkHRE:Process_Election_Result_HRE_Elections();
	end
end

function DilemmaChoiceMadeEvent_HRE_Pretender(context)
	if context:dilemma() == "mk_dilemma_hre_pretender_nomination" then
		if context:choice() == 0 then
			-- Choice made to become a pretender!
			local pretender = context:faction():name();

			mkHRE.emperor_pretender_key = pretender;
			local faction_string = "factions_screen_name_"..pretender;

			if FACTIONS_DFN_LEVEL[pretender]  then
				if FACTIONS_DFN_LEVEL[pretender] > 1 then
					faction_string = "campaign_localised_strings_string_"..pretender.."_lvl"..tostring(FACTIONS_DFN_LEVEL[pretender]);
				end
			end

			cm:show_message_event(
				cm:get_local_faction(),
				"message_event_text_text_mk_event_hre_pretender_nominated_title",
				faction_string,
				"message_event_text_text_mk_event_hre_pretender_nominated_secondary",
				true, 
				712
			);

			cm:force_declare_war(mkHRE.emperor_key, pretender);
			SetFactionsHostile(pretender, mkHRE.emperor_key);
			mkHRE:Refresh_HRE_Elections();
		elseif context:choice() == 1 then
			-- Choice made to reject the Pope's offer!
			Subtract_Pope_Favour(context:faction():name(), 2, "refused_pretender");
			mkHRE:Assign_New_Pretender(true);
		end

		mkHRE:Button_Check();
	end
end

function FactionBecomesLiberationVassal_HRE_Factions(context)
	if context:liberating_character():faction():name() == mkHRE.emperor_key then
		if HasValue(mkHRE.factions_start, context:faction():name()) then
			mkHRE.liberated_faction = context:faction():name();

			cm:add_time_trigger("hre_liberation_check", 0.5);
		end
	end
end

function FactionLeaderDeclaresWar_HRE_Factions(context)
	local emperor_faction = context:character():faction();

	if emperor_faction:name() == mkHRE.emperor_key then
		for i = 1, #mkHRE.factions do
			local member_faction = mkHRE.factions[i];

			if emperor_faction:at_war_with(member_faction) and member_faction:started_war_this_turn() then
				mkHRE:Change_Imperial_Authority(-50);

				if emperor_faction:is_human() then
					local member_faction_name = member_faction:name();
					local member_faction_string = "factions_screen_name_"..member_faction_name;

					if FACTIONS_DFN_LEVEL[member_faction_name] and FACTIONS_DFN_LEVEL[member_faction_name] > 1 then
						member_faction_string = "campaign_localised_strings_string_"..member_faction_name.."_lvl"..tostring(FACTIONS_DFN_LEVEL[member_faction_name]);
					end

					cm:show_message_event(
						emperor_faction:name(),
						"message_event_text_text_mk_event_hre_war_declared_on_member_state_title",
						member_faction_string,
						"message_event_text_text_mk_event_hre_war_declared_on_member_state_secondary",
						true, 
						728
					);
				end
			end
		end
	end
end

function GarrisonAttackedEvent_HRE_Factions(context)
	if HasValue(mkHRE.regions, context:garrison_residence():region():name()) and context:character():faction():name() == mkHRE.emperor_key then
		if mkHRE.liberation_disabled == true then
			mkHRE.liberation_disabled = false;
		end
	elseif mkHRE.liberation_disabled == false then
		mkHRE.liberation_disabled = true;
	end
end

function GarrisonOccupiedEvent_HRE_Frankfurt(context)
	local frankfurt_owner_name = cm:model():world():region_manager():region_by_key(mkHRE.frankfurt_region_key):owning_faction():name();
	local region_name = context:garrison_residence():region():name();
	local region_owning_faction_name = context:garrison_residence():region():owning_faction():name();

	if frankfurt_owner_name  then
		if HasValue(mkHRE.factions, frankfurt_owner_name) then
			if frankfurt_owner_name == mkHRE.emperor_key then
				mkHRE.frankfurt_status = "capital";
			else
				mkHRE.frankfurt_status = "inside_hre";
			end
		else
			if frankfurt_owner_name == mkHRE.emperor_pretender_key then
				local emperor_faction = cm:model():world():faction_by_key(mkHRE.emperor_key);
				local pretender_faction = cm:model():world():faction_by_key(mkHRE.emperor_pretender_key);

				if emperor_faction:is_human() then
					cm:override_mission_succeeded_status(mkHRE.emperor_key, "mk_mission_story_hre_survive_pretender", false);
				elseif pretender_faction:is_human() then
					cm:override_mission_succeeded_status(mkHRE.emperor_pretender_key, "mk_mission_story_pretender_take_frankfurt", true);
				end

				mkHRE:Pretender_End_Mission(true, "victory");
			else
				mkHRE.frankfurt_status = "outside_hre";
			end
		end
	else
		-- It's been razed.
		mkHRE.frankfurt_status = "desolate";
	end

	if mkHRE.regions_owners[region_name] ~= region_owning_faction_name then
		if HasValue(mkHRE.factions, mkHRE.regions_owners[region_name]) == true and region_owning_faction_name ~= mkHRE.emperor_key then
			mkHRE:Issue_Unlawful_Territory_Ultimatum(region_name);
		end
	end

	mkHRE:Check_Factions_In_Empire();
	mkHRE:Check_Regions_In_Empire();
end

function MissionIssued_HRE_Factions(context)
	local mission_name = context:mission():mission_record_key();

	if context:faction():name() == mkHRE.emperor_pretender_key then
		if mission_name == "mk_mission_story_pretender_take_frankfurt" then
			if mkHRE.frankfurt_status == "capital" then
				cm:make_region_seen_in_shroud(context:faction():name(), mkHRE.frankfurt_region_key);
			end

			mkHRE.emperor_mission_win_turn = cm:model():turn_number() + 9;
		end
	elseif context:faction():name() == mkHRE.emperor_key then
		if mission_name == "mk_mission_story_hre_survive_pretender" then
			mkHRE.emperor_mission_win_turn = cm:model():turn_number() + 9;
		end
	end
end

function TimeTrigger_HRE_Factions(context)
	if context.string == "hre_liberation_check" then
		local faction = cm:model():world():faction_by_key(mkHRE.emperor_key);
		local vassalized_faction = cm:model():world():faction_by_key(mkHRE.liberated_faction);
		local is_ally = faction:allied_with(vassalized_faction);

		if not HasValue(mkHRE.factions, mkHRE.liberated_faction) and HasValue(mkHRE.factions_start, mkHRE.liberated_faction) then
			table.insert(mkHRE.factions, mkHRE.liberated_faction);
		end
		
		if is_ally == true then
			-- They were liberated instead of vassalized, so set their state to loyal.
			mkHRE:Set_Faction_State(mkHRE.liberated_faction, "loyal", true);
		else
			mkHRE:Set_Faction_State(mkHRE.liberated_faction, "puppet", true)
		end

		mkHRE.liberated_faction = nil;
		mkHRE:Check_Regions_In_Empire();
	elseif context.string == "hre_frankfurt_transfer_delay" then
		local owning_faction_name = cm:model():world():region_manager():region_by_key(mkHRE.frankfurt_region_key):owning_faction():name();

		-- If conqueror is an HRE faction, transfer Frankfurt to the new emperor!
		if owning_faction_name ~= mkHRE.emperor_key and HasValue(mkHRE.factions, owning_faction_name) then
			Transfer_Region_To_Faction(mkHRE.frankfurt_region_key, mkHRE.emperor_key);
		end
	end
end

function mkHRE:State_Check(faction_name)
    local faction_list    = cm:model():world():faction_list()
    local faction         = cm:model():world():faction_by_key(faction_name)
    local emperor_faction = cm:model():world():faction_by_key(self.emperor_key)
    local stance          = cm:model():campaign_ai():strategic_stance_between_factions(faction_name, self.emperor_key)
    local turn_number     = cm:model():turn_number()

    -- Retrieve and log current state
    local faction_state = self:Get_Faction_State(faction_name)
    DebugLog("Faction: " .. faction_name .. ", State: " .. tostring(faction_state))

    -- Validate faction interface
    if not faction or faction:is_null_interface() then
        return
    end

    -- Force "malcontent" if at war or deeply hostile
    if faction_state ~= "malcontent"
       and (faction:at_war_with(emperor_faction) or (turn_number > 1 and stance <= -3))
    then
        self:Set_Faction_State(faction_name, "malcontent", true)
        return
    end

    -- Handle vassalized "puppet" state
    if faction_state ~= "puppet" then
        if emperor_faction:is_human()
           and FACTIONS_TO_FACTIONS_VASSALIZED[self.emperor_key]
           and HasValue(FACTIONS_TO_FACTIONS_VASSALIZED[self.emperor_key], faction_name)
        then
            self:Set_Faction_State(faction_name, "puppet", true)
            return
        end

        -- Discontent if allied with a foe of the Emperor
        for i = 0, faction_list:num_items() - 1 do
            local ally = faction_list:item_at(i)
            if faction:allied_with(ally)
               and HasValue(self.factions, ally:name())
               and ally:at_war_with(emperor_faction)
            then
                self:Set_Faction_State(faction_name, "discontent", false)
                return
            end
        end

        -- Dynamic stance-based loyalty adjustments
        if turn_number > 1 then
            if stance >= 3 then
                faction_state = "loyal"
            elseif stance > 0 then
                faction_state = "neutral"
            elseif stance == -1 then
                faction_state = "discontent"
            elseif stance <= -2 then
                faction_state = "malcontent"
            end
            self:Set_Faction_State(faction_name, faction_state, faction_state ~= "neutral")

            -- Optional: small drift from neutral into 'ambitious'
            if faction_state == "neutral" and cm:random_number(10) == 1 then
                self:Set_Faction_State(faction_name, "ambitious", false)
            end
        end
    end
end

function mkHRE:Calculate_Imperial_Authority()
	local authority = self.imperial_authority;
	local current_reform = self.current_reform;
	local gain = hre_imperial_authority_gain_rate + (hre_imperial_authority_gain_per_region * #self.regions_in_empire);

	if current_reform < 5 then
		authority = authority + gain;
	elseif current_reform >= 5 then
		authority = authority + (gain * 1.5);
	elseif current_reform >= 7 then
		authority = authority + (gain * 1.75);
	end

	if authority > self.imperial_authority_max then
		authority = 100;
	elseif authority < self.imperial_authority_min then
		authority = 0;
	end

	return authority;
end

function mkHRE:Check_Factions_In_Empire()
	if not self.destroyed then
		local hre_factions_copy = DeepCopy(self.factions);

		for i = 1, #hre_factions_copy do
			local faction_name = hre_factions_copy[i];
		
			if not FactionIsAlive(faction_name) then
				self:Remove_From_Empire(faction_name);
			end
		end

		for i = 1, #self.factions_start do
			local faction_name = self.factions_start[i];
		
			if FactionIsAlive(faction_name) and HasValue(self.factions, faction_name) == false then
				self:Add_To_Empire(faction_name);
			end	
		end
	end
end

function mkHRE:Destroyed_Check()
	local hre_faction_alive = false;

	for i = 1, #self.factions do
		if FactionIsAlive(self.factions[i]) then
			hre_faction_alive = true;
			break;
		end
	end

	if not hre_faction_alive then
		local faction_list = cm:model():world():faction_list();

		for i = 0, faction_list:num_items() - 1 do
			self:Remove_Unlawful_Territory_Effect_Bundles(faction_list:item_at(i):name());
		end

		self.destroyed = true;

		cm:show_message_event(
			cm:get_local_faction(),
			"message_event_text_text_mk_event_hre_destroyed_title",
			"message_event_text_text_mk_event_hre_destroyed_primary",
			"message_event_text_text_mk_event_hre_destroyed_secondary",
			true, 
			713
		);
	end
end

function mkHRE:Emperor_Check()
    -- Wrap entire function in pcall for error tracking
    local success, error_msg = pcall(function()
        -- Early exit conditions
        if self.destroyed then
            return
        end
        
        -- Add cooldown check
        if self.emperor_replacement_cooldown and self.emperor_replacement_cooldown > 0 then
            self.emperor_replacement_cooldown = self.emperor_replacement_cooldown - 1
            return
        end

        -- Validate current state
        local current_emperor = self.emperor_key
        local emperor_faction = current_emperor ~= "nil" and cm:model():world():faction_by_key(current_emperor) or nil
        
        -- Handle pretender scenarios first
        if self.emperor_pretender_key and self.emperor_pretender_key ~= "nil" then
            local pretender_faction = cm:model():world():faction_by_key(self.emperor_pretender_key)
            
            -- Validate pretender state
            if not FactionIsAlive(self.emperor_pretender_key) then
                
                -- Update mission status
                pcall(function()
                    if emperor_faction and emperor_faction:is_human() then
                        cm:override_mission_succeeded_status(
                            current_emperor,
                            "mk_mission_story_hre_survive_pretender",
                            true
                        )
                    elseif pretender_faction and pretender_faction:is_human() then
                        cm:override_mission_succeeded_status(
                            self.emperor_pretender_key,
                            "mk_mission_story_pretender_take_frankfurt",
                            false
                        )
                    end
                end)
                
                -- End pretender mission
                self:Pretender_End_Mission(false, "death")
                return
            
            -- Check if emperor was destroyed
            elseif not FactionIsAlive(current_emperor) then
                
                -- Update mission status
                pcall(function()
                    if emperor_faction and emperor_faction:is_human() then
                        cm:override_mission_succeeded_status(
                            current_emperor,
                            "mk_mission_story_hre_survive_pretender",
                            false
                        )
                    elseif pretender_faction and pretender_faction:is_human() then
                        cm:override_mission_succeeded_status(
                            self.emperor_pretender_key,
                            "mk_mission_story_pretender_take_frankfurt",
                            true
                        )
                    end
                end)
                
                -- Handle pretender victory
                self:Pretender_End_Mission(true, "victory")
                return
            end
            
        -- Handle non-pretender scenarios
        else
            -- Check if we need new elections
            local need_election = false
            
            -- If emperor doesn't exist or is destroyed
            if current_emperor == "nil" or not FactionIsAlive(current_emperor) then
                need_election = true
            end
            
            -- Process election if needed and not at final reform
            if need_election and self.current_reform < 8 then
                if not self.election_in_progress then
                    
                    -- Set cooldown to prevent rapid re-elections
                    self.emperor_replacement_cooldown = 2
                    
                    -- Start election process
                    self.election_in_progress = true
                    
                    local election_success = pcall(function()
                        self:Refresh_HRE_Elections()
                        self:Process_Election_Result_HRE_Elections()
                    end)
                    
                    if not election_success then
                        self.election_in_progress = false
                    end
                else
                    DebugLog("Election already in progress during Emperor_Check")
                end
            end
        end
    end)
    
    if not success then
        -- Log error and attempt recovery
        DebugLog("Emperor_Check failed: " .. tostring(error_msg))
        self.election_in_progress = false
        self.emperor_replacement_cooldown = 0
    end
end



function mkHRE:Replace_Emperor(faction_name)
    -- Master try-catch for the entire operation
    local success, error_msg = pcall(function()
        -- Initial validation
        if not faction_name or faction_name == "nil" then
            error("Invalid faction_name parameter")
        end

        -- Store initial state
        local old_emperor = self.emperor_key
        self.emperor_key = faction_name -- Set this early to prevent race conditions
        
        -- Validate both factions exist before proceeding
        local new_emperor_faction = cm:model():world():faction_by_key(faction_name)
        local old_emperor_faction = old_emperor and cm:model():world():faction_by_key(old_emperor) or nil
        
        if not new_emperor_faction or new_emperor_faction:is_null_interface() == true then
            error("New emperor faction interface is invalid: " .. tostring(faction_name))
        end

        -- Handle effect bundles first (these are relatively safe operations)
        if self.current_reform > 0 and old_emperor then
            for i = 1, self.current_reform - 1 do
                pcall(function()
                    cm:remove_effect_bundle("mk_effect_bundle_reform_" .. tostring(i), old_emperor)
                end)
            end
        end

        pcall(function()
            cm:apply_effect_bundle("mk_effect_bundle_reform_" .. tostring(self.current_reform), faction_name, 0)
        end)

        -- Deactivate decrees before state changes
        if self.active_decree ~= "nil" then
            pcall(function()
                self:Deactivate_Decree(self.active_decree)
            end)
        end

        -- Update faction lists and states
        if old_emperor then
            for i = #self.factions, 1, -1 do
                if self.factions[i] == old_emperor then
                    if not HasValue(self.factions_start, old_emperor) then
                        table.remove(self.factions, i)
                    end
                    break
                end
            end
        end

        -- Ensure new emperor is in factions list
        if not HasValue(self.factions, faction_name) then
            table.insert(self.factions, faction_name)
        end

        -- Set core state values
        self.imperial_authority = hre_imperial_authority_start
        
        -- Update faction states with individual error handling
        if old_emperor then
            pcall(function()
                local new_state = HasValue(self.factions_start, old_emperor) and "neutral" or "not_in_empire"
                self:Set_Faction_State(old_emperor, new_state, true)
            end)
        end

        pcall(function()
            self:Set_Faction_State(faction_name, "emperor", true)
        end)

        -- Handle pretender victory case separately
        if faction_name == self.emperor_pretender_key then
            pcall(function()
                self:Handle_Pretender_Victory(old_emperor, faction_name)
            end)
        end

        -- Update DFN states
        if old_emperor then
            pcall(function()
                DFN_Enable_Forming_Kingdoms(old_emperor)
                DFN_Refresh_Faction_Name(old_emperor)
            end)
        end

        pcall(function()
            DFN_Disable_Forming_Kingdoms(faction_name)
            DFN_Refresh_Faction_Name(faction_name)
        end)

        -- Setup new emperor events if human
        if new_emperor_faction:is_human() then
            if self.Add_Event_Listeners then
                pcall(function()
                    self:Add_Event_Listeners(faction_name)
                end)
            end
            if self.HRE_Event_Reset_Timer then
                pcall(function()
                    self:HRE_Event_Reset_Timer()
                end)
            end
        end

        -- Cleanup operations
        pcall(function()
            self:HRE_Vanquish_Pretender()
            self:Remove_Unlawful_Territory_Effect_Bundles(faction_name)
        end)

        -- Schedule Frankfurt transfer
        cm:add_time_trigger("hre_frankfurt_transfer_delay", 0.5)

        -- Final state updates
        self.liberation_disabled = (FACTION_TURN ~= faction_name)
        self.election_in_progress = false

    end)

    if not success then
        -- Attempt recovery if operation fails
        self.election_in_progress = false
        -- Revert emperor key if operation failed early
        if self.emperor_key == faction_name then
            self.emperor_key = old_emperor
        end
    end
end

function mkHRE:Assign_New_Pretender(exclude_player)
    if self.emperor_pretender_cooldown > 0 then
        DebugLog("Assign_New_Pretender: Cooldown active (" .. tostring(self.emperor_pretender_cooldown) .. "). No new pretender assigned.");
        return;
    end
	local faction_list = cm:model():world():faction_list();
	local emperor_faction = cm:model():world():faction_by_key(self.emperor_key);
	local pretender = nil;
	local pretender_weight = 0;

	for i = 0, faction_list:num_items() - 1 do
		local current_faction = faction_list:item_at(i);
		local current_faction_name = current_faction:name();

		if HasValue(self.factions, current_faction_name) ~= true and current_faction:state_religion() == "att_rel_chr_catholic" and current_faction:is_horde() == false then
			if current_faction:allied_with(emperor_faction) ~= true and FACTION_EXCOMMUNICATED[current_faction_name] ~= true then
				local forces = current_faction:military_force_list();
				local num_regions = current_faction:region_list():num_items();
				local num_units = 0;

				if forces:num_items() > 0 then
					for j = 0, forces:num_items() - 1 do
						local force = forces:item_at(j);
						local unit_list = force:unit_list();

						num_units = num_units + unit_list:num_items();
					end
				end

				local weight = num_units + (num_regions * 10);

				if weight > pretender_weight then
					if current_faction:is_human() then
						if exclude_player == false then
							pretender = current_faction_name;
							pretender_weight = weight;
						end
					else
						pretender = current_faction_name;
						pretender_weight = weight;
					end
				end
			end
		end
	end

	if pretender  then
		local pretender_faction = cm:model():world():faction_by_key(pretender);

		if pretender_faction:is_human() then
			cm:trigger_dilemma(pretender, "mk_dilemma_hre_pretender_nomination");
		else
			self.emperor_pretender_key = pretender;
			local faction_string = "factions_screen_name_"..pretender;

			self:Set_Faction_State(pretender, "pretender", true);

			if FACTIONS_DFN_LEVEL[pretender]  then
				if FACTIONS_DFN_LEVEL[pretender] > 1 then
					faction_string = "campaign_localised_strings_string_"..pretender.."_lvl"..tostring(FACTIONS_DFN_LEVEL[pretender]);
				end
			end

			if self.emperors_names_numbers[pretender_faction:faction_leader():get_forename()]  then
				self.emperors_names_numbers[pretender_faction:faction_leader():get_forename()] = self.emperors_names_numbers[pretender_faction:faction_leader():get_forename()] + 1;
			else
				self.emperors_names_numbers[pretender_faction:faction_leader():get_forename()] = 1;
			end

			cm:show_message_event(
				cm:get_local_faction(),
				"message_event_text_text_mk_event_hre_pretender_nominated_title",
				faction_string,
				"message_event_text_text_mk_event_hre_pretender_nominated_secondary",
				true, 
				712
			);

			if not pretender_faction:at_war_with(emperor_faction) then
				cm:force_declare_war(self.emperor_key, pretender);
			end

			cm:force_diplomacy(self.emperor_key, pretender, "peace", false, false);
			cm:force_diplomacy(pretender, self.emperor_key, "peace", false, false);
			SetFactionsHostile(pretender, self.emperor_key);
		end
	else
		-- Something went horribly wrong and there's no viable pretender.
		self:HRE_Vanquish_Pretender(); -- Reset cooldown.
	end

	self:Refresh_HRE_Elections();
	self:Button_Check();
end

function mkHRE:HRE_Vanquish_Pretender()
    if self.emperor_pretender_key ~= "nil" and self.emperor_pretender_key ~= self.emperor_key then
        local emperor_faction = cm:model():world():faction_by_key(self.emperor_key);
        local pretender_faction = cm:model():world():faction_by_key(self.emperor_pretender_key);

        cm:force_diplomacy(self.emperor_key, self.emperor_pretender_key, "peace", true, true);
        cm:force_diplomacy(self.emperor_pretender_key, self.emperor_key, "peace", true, true);

        if pretender_faction:at_war_with(emperor_faction) then
            cm:force_make_peace(self.emperor_key, self.emperor_pretender_key);
        end

        SetFactionsNeutral(self.emperor_key, self.emperor_pretender_key);

        if not HasValue(self.factions_start, self.emperor_pretender_key) then
            self:Set_Faction_State(self.emperor_pretender_key, "not_in_empire", true);
        else
            self:Set_Faction_State(self.emperor_pretender_key, "neutral", true);
        end
    end

    self.emperor_pretender_cooldown = 10; -- Set cooldown duration
    DebugLog("HRE_Vanquish_Pretender: Cooldown set to 10 turns.");
    self.emperor_pretender_key = "nil";

    self:Refresh_HRE_Elections();
    self:Button_Check();
end

function mkHRE:Pretender_End_Mission(success, reason)
	self.emperor_mission_active = false;
	self.emperor_mission_win_turn = 0;

	if success == true then
		self:Replace_Emperor(self.emperor_pretender_key);
	else
		self:Change_Imperial_Authority(hre_emperor_mission_authority_reward);

		if reason == "death" then
			cm:show_message_event(
				self.emperor_pretender_key,
				"message_event_text_text_mk_event_sic_lost_claim_title", 
				"message_event_text_text_mk_event_sic_lost_claim_primary", 
				"message_event_text_text_mk_event_sic_lost_claim_secondary_death", 
				true,
				713
			);
		else
			cm:show_message_event(
				self.emperor_pretender_key,
				"message_event_text_text_mk_event_sic_lost_claim_title", 
				"message_event_text_text_mk_event_sic_lost_claim_primary", 
				"message_event_text_text_mk_event_sic_lost_claim_secondary", 
				true,
				713
			);
		end

		self:HRE_Vanquish_Pretender();
	end

	for i = 1, #self.factions do
		if self.factions[i] ~= self.emperor_key then
			-- Re-enable war in case it's still disabled.
			cm:force_diplomacy(self.factions[i], self.emperor_key, "war", true, true);
			cm:force_diplomacy(self.factions[i], self.emperor_pretender_key, "war", true, true);
		end
	end
end

function mkHRE:Set_Faction_State(faction_name, state, ignore_cooldown)
	if state == "not_in_empire" then
		self.factions_to_states[faction_name] = nil;
	end

	if ignore_cooldown == true or self.faction_state_change_cooldowns[faction_name] == 0 then
		self.factions_to_states[faction_name] = state;
		self.faction_state_change_cooldowns[faction_name] = hre_faction_state_change_cooldown;
		self:Refresh_HRE_Elections();
	end
end

function mkHRE:Get_Faction_State(faction_name)
	if HasValue(self.factions, faction_name) then
		if self.factions_to_states[faction_name] == nil then
			self.factions_to_states[faction_name] = "neutral";
		end
	else
		return "not_in_empire";
	end

	return self.factions_to_states[faction_name];
end

function mkHRE:Add_To_Empire(faction_name)
	if not HasValue(self.factions, faction_name) then
		table.insert(self.factions, faction_name);
	end
	
	self:State_Check(faction_name);
end

function mkHRE:Remove_From_Empire(faction_name)
	for i = 1, #self.factions do
		if self.factions[i] == faction_name then
			self.factions_to_states[faction_name] = nil;
			self.faction_state_change_cooldowns[faction_name] = 0;

			self:Remove_Imperial_Expansion_Effect_Bundles(faction_name);

			if faction_name == self.emperor_key then
				self:Emperor_Check();
			end

			table.remove(self.factions, i);
			break;
		end
	end

	self:HRE_Remove_Elector(faction_name);
	self:Refresh_HRE_Elections();
end

function mkHRE:Change_Imperial_Authority(amount)
	local authority = self.imperial_authority + amount;

	if authority > self.imperial_authority_max then
		authority = 100;
	elseif authority < self.imperial_authority_min then
		authority = 0;
	end

	self.imperial_authority = authority;
end

function mkHRE:Get_Authority_Tooltip()
	local num_regions = #self.regions_in_empire;

	local authoritystring = "Current Imperial Authority: "..Round_Number_Text(self.imperial_authority);
	authoritystring = authoritystring.."\n\nEmperorship Held: [[rgba:8:201:27:150]]+"..Round_Number_Text(hre_imperial_authority_gain_rate).."[[/rgba]]";
	authoritystring = authoritystring.."\nRegions in the HRE: [[rgba:8:201:27:150]]+"..Round_Number_Text(hre_imperial_authority_gain_per_region * num_regions).."[[/rgba]]";

	if self.current_reform >= 5 then
		authoritystring = authoritystring.."\nReforms: [[rgba:8:201:27:150]]+25%[[/rgba]]";
	elseif self.current_reform >= 7 then
		authoritystring = authoritystring.."\nReforms: [[rgba:8:201:27:150]]+50%[[/rgba]]";
	end

	if self.imperial_authority == self.imperial_authority_max then
		authoritystring = authoritystring.."\n\nProjected Growth: [[rgba:255:0:0:150]]None[[/rgba]]";
		authoritystring = authoritystring.."\nProjected Imperial Authority: [[rgba:8:201:27:150]]100[[/rgba]]";
	elseif self:Calculate_Imperial_Authority() > self.imperial_authority_max then
		authoritystring = authoritystring.."\n\nProjected Growth: [[rgba:255:255:0:150]]+"..Round_Number_Text(self:Calculate_Imperial_Authority() - self.imperial_authority_max).."[[/rgba]]";
		authoritystring = authoritystring.."\nProjected Imperial Authority: [[rgba:8:201:27:150]]100[/rgba]]";
	else
		authoritystring = authoritystring.."\n\nProjected Growth: [[rgba:8:201:27:150]]+"..Round_Number_Text(self:Calculate_Imperial_Authority() - self.imperial_authority).."[[/rgba]]";
		authoritystring = authoritystring.."\nProjected Imperial Authority: [[rgba:8:201:27:150]]"..Round_Number_Text(self:Calculate_Imperial_Authority()).."[[/rgba]]";
	end

	return authoritystring;
end

-- Debug function to list all known faction keys.
function Debug_All_Faction_Keys()
    local faction_list = cm:model():world():faction_list()
    DebugLog("---- BEGIN FACTION KEYS ----")

    for i = 0, faction_list:num_items() - 1 do
        local faction = faction_list:item_at(i)
        DebugLog("Faction #" .. tostring(i) .. ": " .. faction:name())
    end

    DebugLog("---- END FACTION KEYS ----")
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		SaveTable(context, mkHRE.factions, "mkHRE.factions");
		SaveKeyPairTable(context, mkHRE.factions_to_states, "mkHRE.factions_to_states");
		SaveKeyPairTable(context, mkHRE.faction_state_change_cooldowns, "mkHRE.faction_state_change_cooldowns");
		cm:save_value("mkHRE.emperor_key", mkHRE.emperor_key, context);
		cm:save_value("mkHRE.emperor_mission_active", mkHRE.emperor_mission_active, context);
		cm:save_value("mkHRE.emperor_mission_win_turn", mkHRE.emperor_mission_win_turn, context);
		cm:save_value("mkHRE.emperor_pretender_key", mkHRE.emperor_pretender_key, context);
		cm:save_value("mkHRE.emperor_pretender_cooldown", mkHRE.emperor_pretender_cooldown, context);
		cm:save_value("mkHRE.imperial_authority", mkHRE.imperial_authority, context);
		cm:save_value("mkHRE.frankfurt_status", mkHRE.frankfurt_status, context);
		cm:save_value("mkHRE.liberation_disabled", mkHRE.liberation_disabled, context);
	end
);

cm:register_loading_game_callback(
	function(context)
		mkHRE.factions = LoadTable(context, "mkHRE.factions");
		mkHRE.factions_to_states = LoadKeyPairTable(context, "mkHRE.factions_to_states");
		mkHRE.faction_state_change_cooldowns = LoadKeyPairTableNumbers(context, "mkHRE.faction_state_change_cooldowns");
		mkHRE.emperor_key = cm:load_value("mkHRE.emperor_key", "mk_fact_hre", context);
		mkHRE.emperor_mission_active = cm:load_value("mkHRE.emperor_mission_active", false, context);
		mkHRE.emperor_mission_win_turn = cm:load_value("mkHRE.emperor_mission_win_turn", 0, context);
		mkHRE.emperor_pretender_key = cm:load_value("mkHRE.emperor_pretender_key", "mk_fact_sicily", context);
		mkHRE.emperor_pretender_cooldown = cm:load_value("mkHRE.emperor_pretender_cooldown", 0, context);
		mkHRE.imperial_authority = cm:load_value("mkHRE.imperial_authority", 40, context);
		mkHRE.frankfurt_status = cm:load_value("mkHRE.frankfurt_status", "capital", context);
		mkHRE.liberation_disabled = cm:load_value("mkHRE.liberation_disabled", true, context);
	end
);