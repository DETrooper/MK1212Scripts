----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: HOLY ROMAN EMPIRE ELECTIONS
-- 	By: DETrooper
--
----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
-- System for members of the HRE to elect the next emperor from among themselves.

mkHRE.elector_factions = {};
mkHRE.elector_votes = {};

function mkHRE:Add_Election_Listeners()
	cm:add_listener(
		"FactionTurnStart_HRE_Elections_Wrapper",
		"FactionTurnStart",
		true,
		function(context) FactionTurnStart_HRE_Elections_Wrapper(context) end,
		true
	);

	if cm:is_new_game() then
		self.elector_votes = DeepCopy(self.elector_votes_start);
	end
end

function FactionTurnStart_HRE_Elections_Wrapper(context)
    local success, errorMsg = pcall(function() 
        -- Add pre-execution state logging
        DebugLog("Pre-execution state:")
        DebugLog("Current reform: " .. tostring(mkHRE.current_reform))
        DebugLog("Emperor key: " .. tostring(mkHRE.emperor_key))
        DebugLog("Elector factions count: " .. tostring(#(mkHRE.elector_factions or {})))
        
        FactionTurnStart_HRE_Elections(context) 
    end)
    if not success then
        DebugLog("FactionTurnStart_HRE_Elections Error: " .. errorMsg)
        -- Add post-error state logging
        DebugLog("Post-error state:")
        DebugLog("Context valid: " .. tostring(context and context:faction() ~= nil))
        DebugLog("HRE destroyed: " .. tostring(mkHRE.destroyed))
    end
end

function FactionTurnStart_HRE_Elections(context)
    -- Exit early if HRE is destroyed or context is invalid
    if not context or not context:faction() or mkHRE.destroyed then 
        return 
    end

    -- Complete initialization block
    mkHRE.elector_factions = mkHRE.elector_factions or {}
    mkHRE.current_reform = mkHRE.current_reform or 0
    mkHRE.factions = mkHRE.factions or {}
    mkHRE.faction_states = mkHRE.faction_states or {
        malcontent = {},
        discontent = {},
        ambitious = {},
        neutral = {},
        loyal = {},
        puppet = {}
    }
    mkHRE.elector_votes = mkHRE.elector_votes or {}
    
    local current_faction = context:faction():name()
    
    -- Add state validation
    if current_faction then
        local faction_state = mkHRE:Get_Faction_State(current_faction)
        if not faction_state then
            mkHRE:Set_Faction_State(current_faction, "neutral", true)
        end
    end
    
    -- Check if the current faction is the emperor and clean up dead electors
    if current_faction == mkHRE.emperor_key and #mkHRE.elector_factions > 0 then
        for i = #mkHRE.elector_factions, 1, -1 do
            if not FactionIsAlive(mkHRE.elector_factions[i]) then
                table.remove(mkHRE.elector_factions, i)
            end
        end
    end

    -- Handle voting based on reforms
    if mkHRE.current_reform < 1 then
        -- All factions in the HRE can currently vote
        if mkHRE.factions and HasValue(mkHRE.factions, current_faction) then
            mkHRE:Check_Faction_Votes_HRE_Elections(current_faction)
        end
    elseif mkHRE.current_reform < 8 then
        -- Only prince-electors (and emperor) can vote
        if #mkHRE.elector_factions < 7 then
            local success, error = pcall(function()
                mkHRE:Add_New_Electors_HRE_Elections()
            end)
            if not success then
                DebugLog("Error adding new electors: " .. tostring(error))
            end
        end
        
        if HasValue(mkHRE.elector_factions, current_faction) or current_faction == mkHRE.emperor_key then
            mkHRE:Check_Faction_Votes_HRE_Elections(current_faction)
        end
    end

    -- Add validation check
    if not mkHRE:ValidateElectionState() then
        DebugLog("Warning: Election state validation failed for faction " .. current_faction)
    end
end

function mkHRE:ValidateElectionState()
    local state_issues = {}
    
    -- Check essential tables
    if not self.elector_factions then state_issues[#state_issues + 1] = "elector_factions nil" end
    if not self.factions then state_issues[#state_issues + 1] = "factions nil" end
    if not self.faction_states then state_issues[#state_issues + 1] = "faction_states nil" end
    if not self.elector_votes then state_issues[#state_issues + 1] = "elector_votes nil" end
    
    -- Check essential values
    if not self.emperor_key then state_issues[#state_issues + 1] = "emperor_key nil" end
    if not self.current_reform then state_issues[#state_issues + 1] = "current_reform nil" end
    
    -- Log any issues
    if #state_issues > 0 then
        DebugLog("Election state validation issues: " .. table.concat(state_issues, ", "))
        return false
    end
    return true
end

function mkHRE:Process_Election_Result_HRE_Elections()
    -- Early exit if election already in progress
    if self.election_in_progress then
        DebugLog("Election already in progress. Skipping...")
        return false
    end

    -- Set election flag at start
    self.election_in_progress = true
    
    -- Wrap entire process in pcall
    local success, error_msg = pcall(function()
        -- Validate HRE state first
        if self.destroyed then
            error("Cannot process election - HRE is destroyed")
        end

        -- Snapshot current state
        local current_emperor = self.emperor_key
        DebugLog("Starting election process. Current emperor: " .. tostring(current_emperor))

        -- Get valid factions and validate list
        local factions_involved = {}
        
        -- Validate and copy factions list
        for _, faction_name in ipairs(self.factions or {}) do
            local faction = cm:model():world():faction_by_key(faction_name)
            if faction and not faction:is_null_interface() and FactionIsAlive(faction_name) then
                table.insert(factions_involved, faction_name)
            end
        end

        -- Add pretender if valid
        if self.emperor_pretender_key and self.emperor_pretender_key ~= "nil" then
            local pretender = cm:model():world():faction_by_key(self.emperor_pretender_key)
            if pretender and not pretender:is_null_interface() and FactionIsAlive(self.emperor_pretender_key) then
                table.insert(factions_involved, self.emperor_pretender_key)
            end
        end

        -- Check if we have any valid factions
        if #factions_involved == 0 then
            error("No valid factions for election")
        end

        -- Determine winner
        local max_votes = 0
        local winner = nil
        local winner_votes_map = {}

        -- Count votes
        for _, faction_name in ipairs(factions_involved) do
            local num_votes = self:Calculate_Num_Votes(faction_name)
            winner_votes_map[faction_name] = num_votes
            DebugLog(faction_name .. " received " .. tostring(num_votes) .. " votes.")
            
            if num_votes > max_votes then
                winner = faction_name
                max_votes = num_votes
            end
        end

        -- Validate winner
        if not winner then
            error("No winner determined from vote count")
        end

        -- Double check winner validity
        local winner_faction = cm:model():world():faction_by_key(winner)
        if not winner_faction or winner_faction:is_null_interface() or not FactionIsAlive(winner) then
            error("Winning faction became invalid: " .. tostring(winner))
        end

        -- Log election results
        DebugLog("Election winner determined: " .. winner .. " with " .. tostring(max_votes) .. " votes")
        
        -- Set up faction string for localization
        local faction_string = "factions_screen_name_" .. winner
        if FACTIONS_DFN_LEVEL[winner] and FACTIONS_DFN_LEVEL[winner] > 1 then
            faction_string = "campaign_localised_strings_string_" .. winner .. "_lvl" .. tostring(FACTIONS_DFN_LEVEL[winner])
        end

        -- Trigger election event
          local trigger_success = pcall(function()
              Trigger_HRE_Election(winner)
          end)
          if not trigger_success then
              DebugLog("Warning: Failed to trigger election event")
          end

        -- Replace emperor
        if type(self.Replace_Emperor) ~= "function" then
            error("Replace_Emperor function not defined")
        end

        -- Attempt emperor replacement
        local replace_success, replace_error = pcall(function()
            self:Replace_Emperor(winner)
        end)
        
        DebugLog("Post Replace Emperor Nut Clarity");
        
        if not replace_success then
            error("Emperor replacement failed: " .. tostring(replace_error))
        end

        -- Final validation
        local new_emperor_faction = cm:model():world():faction_by_key(self.emperor_key)
        if not new_emperor_faction or new_emperor_faction:is_null_interface() == true or not FactionIsAlive(self.emperor_key) then
            error("New emperor faction invalid after replacement")
        end

        return true
    end)

    -- Cleanup and error handling
    if not success then
        DebugLog("Election processing failed: " .. tostring(error_msg))
        -- Attempt to restore to safe state
        self.election_in_progress = false
        self:Refresh_HRE_Elections()
        return false
    end

    -- Successful completion cleanup
    self.election_in_progress = false
    if not self.destroyed then
        self:Refresh_HRE_Elections()
    end
    
    DebugLog("Process_Election_Result_HRE_Elections end");
    return true
end

function Trigger_HRE_Election(winning_faction_key)
    -- Input validation
    if not winning_faction_key or winning_faction_key == "" then
        return
    end
   
    -- Set up faction string for localization
    local faction_string = "factions_screen_name_"..winning_faction_key
    if FACTIONS_DFN_LEVEL[winning_faction_key] and FACTIONS_DFN_LEVEL[winning_faction_key] > 1 then
        faction_string = "campaign_localised_strings_string_"..winning_faction_key.."_lvl"..tostring(FACTIONS_DFN_LEVEL[winning_faction_key])
    end

    for i = 1, #mkHRE.factions do
        local faction_key = mkHRE.factions[i]
                            
        if FactionIsAlive(faction_key) then
            cm:show_message_event(
                faction_key,
                "message_event_text_text_mk_event_hre_election_title",
                faction_string,
                "message_event_text_text_mk_event_hre_election_description",
                true,
                936
            )
        end
    end
end

function mkHRE:Find_Strongest_Factions_HRE_Elections(required_states, num_factions)
    local faction_strengths = {}
    
    -- Set default num_factions if nil
    num_factions = num_factions or 1
    
    -- Ensure required_states is a valid table
    if not required_states or #required_states == 0 then
        required_states = {}
        for state_name, _ in pairs(self.faction_states) do
            table.insert(required_states, state_name)
        end
    end
    
    -- Ensure "malcontent" is included if needed
    if HasValue(required_states, "discontent") or HasValue(required_states, "pretender") then
        if not HasValue(required_states, "malcontent") then
            table.insert(required_states, "malcontent")
        end
    end
    
    DebugLog("Required states: " .. table.concat(required_states, ", "))
    DebugLog("Num factions: " .. tostring(num_factions))
    
    -- Process factions
    for _, faction_name in ipairs(self.factions) do
        local faction = cm:model():world():faction_by_key(faction_name)
        
        -- Validate faction existence and activity
        if faction and not faction:is_null_interface() and FactionIsAlive(faction_name) then
            local faction_state = self:Get_Faction_State(faction_name)
            
            if faction_state and HasValue(required_states, faction_state) then
                local faction_strength = 0
                
                -- Strength from regions
                local num_regions = faction:region_list():num_items()
                faction_strength = faction_strength + (num_regions * 15)
                
                -- Strength from allies
                faction_strength = faction_strength + (faction:num_allies() * 20)
                
                -- Strength from treasury (weighted more)
                faction_strength = faction_strength + (faction:treasury() / 500)
                
                -- Strength from military forces
                local forces = faction:military_force_list()
                for j = 0, forces:num_items() - 1 do
                    local force = forces:item_at(j)
                    local unit_list = force:unit_list()
                    faction_strength = faction_strength + (unit_list:num_items() * 3)
                end
                
                -- Store faction strength
                table.insert(faction_strengths, {faction_name, faction_strength})
            end
        end
    end
    
    -- Sort factions by strength (descending)
    table.sort(faction_strengths, function(a, b) return a[2] > b[2] end)
    
    -- Return strongest factions
    local strongest_factions = {}
    local count = math.min(num_factions or 1, #faction_strengths)
    
    for i = 1, count do
        table.insert(strongest_factions, faction_strengths[i][1])
    end
    
    DebugLog("Strongest factions: " .. table.concat(strongest_factions, ", "))
    return strongest_factions
end

function mkHRE:Refresh_HRE_Elections()
	for k, v in pairs(self.elector_votes) do
		if not HasValue(self.factions, k) then
			self.elector_votes[k] = nil;
		end

		if self.current_reform >= 1 then
			if not HasValue(self.elector_factions, k) then
				self.elector_votes[k] = nil;
			end
		end
	end

	if self.current_reform < 1 then
		for i = 1, #self.factions do
			local faction = cm:model():world():faction_by_key(self.factions[i]);
			
			if not faction:is_human() then
				self:Check_Faction_Votes_HRE_Elections(self.factions[i]);
			end
		end
	else
		for i = 1, #self.elector_factions do
			local faction = cm:model():world():faction_by_key(self.elector_factions[i]);
			
			if not faction:is_human() then
				self:Check_Faction_Votes_HRE_Elections(self.elector_factions[i]);
			end
		end
	end
end
   
function mkHRE:Add_New_Electors_HRE_Elections()
    -- First ensure player is included if they're in HRE
    local player_faction = cm:get_local_faction()
    if HasValue(self.factions, player_faction) and not HasValue(self.elector_factions, player_faction) then
        table.insert(self.elector_factions, player_faction)
    end
    
    -- Remove excess electors if we somehow have more than 7
    while #self.elector_factions > 7 do
        -- Remove the weakest elector (excluding player)
        local weakest_elector = nil
        local weakest_strength = math.huge
        
        for i = 1, #self.elector_factions do
            local faction_name = self.elector_factions[i]
            if faction_name ~= player_faction then
                local faction = cm:model():world():faction_by_key(faction_name)
                local faction_strength = 0
                
                -- Calculate strength based on regions
                local num_regions = faction:region_list():num_items()
                faction_strength = faction_strength + (num_regions * 15)
                
                -- Calculate strength based on allies
                faction_strength = faction_strength + (faction:num_allies() * 20)
                
                -- Calculate strength based on treasury
                faction_strength = faction_strength + (faction:treasury() / 1000)
                
                -- Calculate strength based on military units
                local forces = faction:military_force_list()
                for i = 0, forces:num_items() - 1 do
                    local force = forces:item_at(i)
                    local unit_list = force:unit_list()
                    faction_strength = faction_strength + (unit_list:num_items() * 2)
                end
                
                if faction_strength < weakest_strength then
                    weakest_elector = faction_name
                    weakest_strength = faction_strength
                end
            end
        end
        
        if weakest_elector then
            self:HRE_Remove_Elector(weakest_elector)
        end
    end
    
    while #self.elector_factions < 7 do
        local factions = {}
        local new_elector = nil
        local new_elector_strength = 0
    
        for i = 1, #self.factions do
            local faction_name = self.factions[i]
            if not HasValue(self.elector_factions, faction_name) and faction_name ~= self.emperor_key then
                local faction = cm:model():world():faction_by_key(faction_name)
                local faction_strength = 0
                
                -- Calculate strength based on regions
                local num_regions = faction:region_list():num_items()
                faction_strength = faction_strength + (num_regions * 15)
                
                -- Calculate strength based on allies
                faction_strength = faction_strength + (faction:num_allies() * 20)
                
                -- Calculate strength based on treasury
                faction_strength = faction_strength + (faction:treasury() / 1000)
                
                -- Calculate strength based on military units
                local forces = faction:military_force_list()
                for i = 0, forces:num_items() - 1 do
                    local force = forces:item_at(i)
                    local unit_list = force:unit_list()
                    faction_strength = faction_strength + (unit_list:num_items() * 2)
                end
                
                table.insert(factions, {faction_name, faction_strength})
            end
        end
        
        for i = 1, #factions do
            if factions[i][2] > new_elector_strength then
                new_elector = factions[i][1]
                new_elector_strength = factions[i][2]
            end
        end
        
        if new_elector then
            table.insert(self.elector_factions, new_elector)
        else
            -- No electors found.
            break
        end
    end
    
    self:Refresh_HRE_Elections()
end

function mkHRE:Check_Faction_Votes_HRE_Elections(faction_name)
    DebugLog("========= Starting Vote Check for " .. faction_name .. " =========")

    -- Early validation
    if not HasValue(self.factions, faction_name) or not FactionIsAlive(faction_name) then
        DebugLog("Vote Check Failed: Faction invalid or dead")
        return
    end

    -- Ensure elector votes table is initialized
    self.elector_votes = self.elector_votes or {}

    -- Get current state
    local faction_state = self:Get_Faction_State(faction_name) or "neutral"
    DebugLog("Initial State: Faction=" .. faction_name
             .. ", State=" .. faction_state
             .. ", Current Vote=" .. tostring(self.elector_votes[faction_name]))

    -- Restrict voting based on reform stage
    if self.current_reform > 1 then
        if self.current_reform < 8 and not HasValue(self.elector_factions, faction_name) then
            DebugLog("Vote Check Failed: Not an elector during reforms")
            self.elector_votes[faction_name] = nil
            return
        elseif self.current_reform >= 8 then
            DebugLog("Vote Check Failed: Past reform 8")
            self.elector_votes[faction_name] = nil
            return
        end
    end

    -- Skip vassals unless they’re official puppets
    local overlord = Get_Vassal_Overlord(faction_name)
    if overlord and faction_state ~= "puppet" then
        DebugLog("Vote Check Skipped: Vassal under " .. overlord)
        return
    end

    -- 1) Loyal / Puppet / Emperor always back the sitting emperor (or strongest loyalist if he’s dead)
    if faction_state == "loyal" or faction_state == "puppet" or faction_state == "emperor" then
        if FactionIsAlive(self.emperor_key) then
            if self.elector_votes[self.emperor_key] then
                self:Cast_Vote_For_Factions_Candidate_HRE(faction_name, self.emperor_key)
            else
                self:Cast_Vote_For_Faction(faction_name, self.emperor_key)
            end
        else
            local strongest = self:Find_Strongest_Faction_HRE_Elections({"loyal","puppet"}) or faction_name
            self:Cast_Vote_For_Faction(faction_name, strongest)
        end

    -- 2) Neutral factions decide at random: emperor, pretender/strongest opposition, or any other
    elseif faction_state == "neutral" then
        local roll = cm:random_number(3)
        DebugLog("Neutral Vote Roll: " .. roll)

        local vote_target
        if roll == 1 then
            vote_target = self.emperor_key
            DebugLog("Neutral Vote: Emperor")
        elseif roll == 2 then
            if self.emperor_pretender_key and self.emperor_pretender_key ~= "nil" then
                vote_target = self.emperor_pretender_key
                DebugLog("Neutral Vote: Pretender")
            else
                local opp = {"malcontent","discontent","ambitious"}
                local top = self:Find_Strongest_Factions_HRE_Elections(opp) or {}
                vote_target = top[1] or faction_name
                DebugLog("Neutral Vote: Strongest opposition -> " .. vote_target)
            end
        else
            local all = self.factions or {}
            if #all > 0 then
                vote_target = all[cm:random_number(#all)]
                DebugLog("Neutral Vote: Random -> " .. vote_target)
            else
                vote_target = faction_name
                DebugLog("Neutral Vote: Fallback self")
            end
        end

        self:Cast_Vote_For_Faction(faction_name, vote_target)
        DebugLog("Neutral faction " .. faction_name .. " voted for " .. vote_target)

    -- 3) Open opposition factions back the pretender or the strongest discontent
    elseif faction_state == "malcontent" or faction_state == "discontent" or faction_state == "ambitious" then
        DebugLog("Opposition Vote Logic Starting")
        local vote_target = (self.emperor_pretender_key and self.emperor_pretender_key ~= "nil")
                            and self.emperor_pretender_key
                         or (self:Find_Strongest_Factions_HRE_Elections({"malcontent","discontent","ambitious"}) or {self.emperor_key})[1]
        DebugLog("Opposition Vote: Chose " .. tostring(vote_target))
        self:Cast_Vote_For_Faction(faction_name, vote_target)

    -- 4) Fallback: nobody matched above, default to emperor or self
    else
        DebugLog("Fallback Vote: defaulting to emperor or self")
        self:Cast_Vote_For_Faction(faction_name, self.emperor_key or faction_name)
    end

    DebugLog("========= Vote Check Complete for " .. faction_name .. " =========")
end

function mkHRE:Calculate_Num_Votes(faction_name)
	local votes = 0;

	for k, v in pairs(self.elector_votes) do
		if faction_name == v then
			votes = votes + 1;
		end
	end

	return votes;
end

function mkHRE:Cast_Vote_For_Faction(faction_name, candidate_faction_name)
    -- Input validation
    if not faction_name or not candidate_faction_name then
        return
    end

    -- Eligibility check and vote assignment
    if self.current_reform == 0 or (self.current_reform > 0 and HasValue(self.elector_factions, faction_name)) then
        -- Check if faction is in HRE
        if HasValue(self.factions, faction_name) then
            self.elector_votes[faction_name] = candidate_faction_name
            
            -- Handle vassals
            local vassalized_factions = FACTIONS_TO_FACTIONS_VASSALIZED[faction_name]
            for _, vassal_faction_name in ipairs(vassalized_factions or {}) do
                -- Only allow HRE vassals that are electors to vote
                if HasValue(self.factions, vassal_faction_name) and 
                   (self.current_reform == 0 or HasValue(self.elector_factions, vassal_faction_name)) then
                    self.elector_votes[vassal_faction_name] = candidate_faction_name
                end
            end
        end
    end
end

function mkHRE:Cast_Vote_For_Factions_Candidate_HRE(faction_name, supporting_faction_name)
    if faction_name and supporting_faction_name and self.elector_votes[supporting_faction_name] then
        -- Check if faction can vote and is in HRE
        if HasValue(self.factions, faction_name) and
           (self.current_reform == 0 or (self.current_reform > 0 and HasValue(self.elector_factions, faction_name))) then
            
            self.elector_votes[faction_name] = self.elector_votes[supporting_faction_name]
            
            -- Handle vassals
            local vassalized_factions = FACTIONS_TO_FACTIONS_VASSALIZED[faction_name]
            if vassalized_factions then
                for i = 1, #vassalized_factions do
                    local vassal_faction_name = vassalized_factions[i]
                    -- Only allow HRE vassals that are electors to vote
                    if HasValue(self.factions, vassal_faction_name) and
                       (self.current_reform == 0 or HasValue(self.elector_factions, vassal_faction_name)) then
                        self.elector_votes[vassal_faction_name] = self.elector_votes[supporting_faction_name]
                    end
                end
            end
        end
    end
end

function mkHRE:HRE_Remove_Elector(faction_name)
	for i = 1, #self.elector_factions do
		if self.elector_factions[i] == faction_name then
			table.remove(self.elector_factions, i);
			break;
		end
	end

	if #self.elector_factions < 7 then
		self:Add_New_Electors_HRE_Elections();
	end
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		SaveTable(context, mkHRE.elector_factions, "mkHRE.elector_factions");
		SaveKeyPairTable(context, mkHRE.elector_votes, "mkHRE.elector_votes");
	end
);

cm:register_loading_game_callback(
	function(context)
		mkHRE.elector_factions = LoadTable(context, "mkHRE.elector_factions");
		mkHRE.elector_votes = LoadKeyPairTable(context, "mkHRE.elector_votes");
	end
);