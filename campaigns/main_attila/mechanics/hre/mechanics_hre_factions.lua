---------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: HOLY ROMAN EMPIRE FACTIONS
-- 	By: DETrooper
--
---------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
-- Keeps track of which factions are in the HRE, and which faction is the emperor.

HRE_EMPEROR_KEY = "mk_fact_hre"; -- Starting emperor.
HRE_EMPEROR_PRETENDER_KEY = "mk_fact_sicily"; -- Starting pretender, isn't in the HRE proper though.
HRE_EMPEROR_PRETENDER_COOLDOWN = 0; -- Every time a pretender is vanquished there will be a cooldown before the Pope can make a new one.
HRE_IMPERIAL_AUTHORITY = 40; -- Starting Imperial Authority.
HRE_IMPERIAL_AUTHORITY_GAIN_RATE = 1; -- Base Imperial Authority gain per turn.
HRE_IMPERIAL_AUTHORITY_GAIN_PER_REGION = 0.1; -- Imperial Authority gain per region in the HRE.
HRE_IMPERIAL_AUTHORITY_MIN = 0; -- Minimum Imperial Authority.
HRE_IMPERIAL_AUTHORITY_MAX = 100; -- Maximum Imperial Authority.

HRE_FRANKFURT_STATUS = "capital";

FACTIONS_HRE = {};
FACTIONS_HRE_STATES = {};

function Add_HRE_Faction_Listeners()
	cm:add_listener(
		"FactionTurnStart_HRE_Factions",
		"FactionTurnStart",
		true,
		function(context) FactionTurnStart_HRE_Factions(context) end,
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
		"GarrisonOccupiedEvent_HRE_Frankfurt",
		"GarrisonOccupiedEvent",
		true,
		function(context) GarrisonOccupiedEvent_HRE_Frankfurt(context) end,
		true
	);

	if cm:is_new_game() then
		FACTIONS_HRE = DeepCopy(FACTIONS_HRE_START);
		FACTIONS_HRE_STATES = DeepCopy(FACTIONS_HRE_STATES_START);
	end
end

function FactionTurnStart_HRE_Factions(context)
	if context:faction():name() == HRE_EMPEROR_KEY then
		local faction_list = cm:model():world():faction_list();

		for i = 0, faction_list:num_items() - 1 do
			local current_faction = faction_list:item_at(i);

			if HasValue(FACTIONS_HRE, current_faction:name()) and current_faction:name() ~= HRE_EMPEROR_KEY then
				HRE_State_Check(current_faction:name());
			elseif current_faction:name() == HRE_EMPEROR_KEY then
				FACTIONS_HRE_STATES[current_faction:name()] = "emperor";
			elseif current_faction:name() == HRE_EMPEROR_PRETENDER_KEY then
				FACTIONS_HRE_STATES[current_faction:name()] = "pretender";
			else
				FACTIONS_HRE_STATES[current_faction:name()] = nil;
			end
		end

		HRE_IMPERIAL_AUTHORITY = HRE_Calculate_Imperial_Authority();

		if HRE_EMPEROR_PRETENDER_KEY == nil and PLAYER_EXCOMMUNICATED[HRE_EMPEROR_KEY] == true and HRE_EMPEROR_PRETENDER_COOLDOWN == 0 then
			HRE_Assign_New_Pretender(false);
		elseif HRE_EMPEROR_PRETENDER_KEY ~= nil then
			if cm:model():world():faction_by_key(HRE_EMPEROR_PRETENDER_KEY):has_home_region() == false then
				HRE_Vanquish_Pretender();
			end
		end

		if HRE_EMPEROR_PRETENDER_COOLDOWN > 0 then
			HRE_EMPEROR_PRETENDER_COOLDOWN = HRE_EMPEROR_PRETENDER_COOLDOWN - 1;
		end
	end

	HRE_Button_Check(); -- Check every turn if the HRE panel should be hidden or not.
end

function CharacterBecomesFactionLeader_HRE_Factions(context)
	local faction_name = context:character():faction():name();
	local faction_state = HRE_Get_Faction_State(faction_name);

	-- When faction leaders of HRE member states die, set their attitude to neutral if not a puppet, then check to see if their state should be something else.
	if HasValue(FACTIONS_HRE, faction_name) and faction_name ~= HRE_EMPEROR_KEY then
		if faction_state ~= "puppet" then
			HRE_Set_Faction_State(faction_name, "neutral");
			HRE_State_Check(faction_name);
		end
	end
end

function DilemmaChoiceMadeEvent_HRE_Pretender(context)
	if context:dilemma() == "mk_dilemma_hre_pretender_nomination" then
		if context:choice() == 0 then
			-- Choice made to become a pretender!
			local pretender = cm:get_local_faction();

			HRE_EMPEROR_PRETENDER_KEY = pretender;
			local faction_string = "factions_screen_name_"..pretender;

			if FACTIONS_DFN_LEVEL[pretender] ~= nil then
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
				707
			);

			cm:force_declare_war(pretender, HRE_EMPEROR_KEY);
		elseif context:choice() == 1 then
			-- Choice made to reject the Pope's offer!
			HRE_Assign_New_Pretender(true);
		end

		HRE_Button_Check();
	end
end


function GarrisonOccupiedEvent_HRE_Frankfurt(context)
	local frankfurt_owner_name = cm:model():world():region_manager():region_by_key("att_reg_germania_uburzis"):owning_faction():name();

	if frankfurt_owner_name ~= nil then
		if HasValue(FACTIONS_HRE, frankfurt_owner_name) then
			if frankfurt_owner_name == HRE_EMPEROR_KEY then
				HRE_FRANKFURT_STATUS = "capital";
			else
				HRE_FRANKFURT_STATUS = "inside_hre";
			end
		else
			HRE_FRANKFURT_STATUS = "outside_hre";
		end
	else
		-- It's been razed.
		HRE_FRANKFURT_STATUS = "desolate";
	end
end

function HRE_State_Check(faction_name)
	-- Find which attitude an HRE member state should have towards the emperor.
	local faction_list = cm:model():world():faction_list();
	local faction = cm:model():world():faction_by_key(faction_name);
	local faction_state = HRE_Get_Faction_State(faction_name);
	local emperor_faction = cm:model():world():faction_by_key(HRE_EMPEROR_KEY);

	-- If the HRE member state is not malcontent but is at war with the emperor, make them malcontent.
	if faction_state ~= "malcontent" then
		if faction:at_war_with(emperor_faction) then
			HRE_Set_Faction_State(faction_name, "malcontent");
			return;
		end
	end

	if faction_state ~= "puppet" then
		if emperor_faction:is_human() then
			if HasValue(FACTIONS_VASSALIZED, faction_name) then
				HRE_Set_Faction_State(faction_name, "puppet");
				return;
			end
		end

		-- If the HRE member state is not a puppet and has an ally that is at war with the HRE, make them discontent.
		for i = 0, faction_list:num_items() - 1 do
			local possible_ally = faction_list:item_at(i);

			if faction:allied_with(possible_ally) == true and HasValue(FACTIONS_HRE, possible_ally:name()) then
				if possible_ally:at_war_with(emperor_faction) then
					HRE_Set_Faction_State(possible_ally:name(), "discontent");
					return;
				end
			end
		end
	end
end

function HRE_Calculate_Imperial_Authority()
	local authority = HRE_IMPERIAL_AUTHORITY;
	local num_regions = #HRE_REGIONS;

	authority = authority + HRE_IMPERIAL_AUTHORITY_GAIN_RATE + (HRE_IMPERIAL_AUTHORITY_GAIN_PER_REGION * num_regions);

	if authority > HRE_IMPERIAL_AUTHORITY_MAX then
		authority = 100;
	elseif authority < HRE_IMPERIAL_AUTHORITY_MIN then
		authority = 0;
	end

	return authority;
end

function HRE_Replace_Emperor(faction_name)
	cm:set_faction_name_override(faction_name, "campaign_localised_strings_string_mk_faction_holy_roman_empire");

	if HRE_FRANKFURT_STATUS == "capital" and cm:model():world():region_manager():region_by_key("att_reg_germania_uburzis"):owning_faction():name() ~= faction_name then
		cm:transfer_region_to_faction("att_reg_germania_uburzis", faction_name);
	end

	HRE_Vanquish_Pretender();

	HRE_EMPEROR_KEY = faction_name;
	HRE_Button_Check();
end

function HRE_Assign_New_Pretender(player_rejected)
	local faction_list = cm:model():world():faction_list();
	local emperor_faction = cm:model():world():faction_by_key(HRE_EMPEROR_KEY);
	local pretender = nil;
	local pretender_weight = 0;

	for i = 0, faction_list:num_items() - 1 do
		local current_faction = faction_list:item_at(i);
		local current_faction_name = current_faction:name();

		if HasValue(FACTIONS_HRE, current_faction_name) ~= true and current_faction:state_religion() == "att_rel_chr_catholic" then
			if current_faction:allied_with(emperor_faction) ~= true and PLAYER_EXCOMMUNICATED[current_faction_name] ~= true then
				local forces = current_faction:military_force_list();
				local num_regions = current_faction:region_list():num_items();
				local num_units = 0;

				for j = 0, forces:num_items() - 1 do
					local force = forces:item_at(j);
					local unit_list = forces:item_at(i):unit_list();

					num_units = num_units + unit_list:num_items();
				end

				local weight = num_units + (num_regions * 10);

				if weight > pretender_weight then
					if current_faction:is_human() then
						if player_rejected == false then
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

	if pretender ~= nil then
		if cm:model():world():faction_by_key(pretender):is_human() then
			cm:trigger_dilemma(faction_name, "mk_dilemma_hre_pretender_nomination");
		else
			HRE_EMPEROR_PRETENDER_KEY = pretender;
			local faction_string = "factions_screen_name_"..pretender;

			if FACTIONS_DFN_LEVEL[pretender] ~= nil then
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
				707
			);

			cm:force_declare_war(pretender, HRE_EMPEROR_KEY);
		end
	else
		-- Something went horribly wrong and there's no viable pretender.
		HRE_Vanquish_Pretender(); -- Reset cooldown.
	end

	HRE_Button_Check();
end

function HRE_Vanquish_Pretender()
	local emperor_faction = cm:model():world():faction_by_key(HRE_EMPEROR_KEY);
	local pretender_faction = cm:model():world():faction_by_key(HRE_EMPEROR_PRETENDER_KEY);

	if pretender_faction:at_war_with(emperor_faction) then
		cm:force_make_peace(HRE_EMPEROR_KEY, HRE_EMPEROR_PRETENDER_KEY);
	end

	HRE_EMPEROR_PRETENDER_COOLDOWN = 10;
	HRE_EMPEROR_PRETENDER_KEY = nil;
	HRE_Button_Check();
end

function HRE_Set_Faction_State(faction_name, state)
	FACTIONS_HRE_STATES[faction_name] = state;
end

function HRE_Get_Faction_State(faction_name)
	if FACTIONS_HRE_STATES[faction_name] == nil then
		FACTIONS_HRE_STATES[faction_name] = "neutral";
	end

	return FACTIONS_HRE_STATES[faction_name];
end

function HRE_Remove_From_Empire(faction_name)
	for i = 1, #FACTIONS_HRE do
		if FACTIONS_HRE[i] == faction_name then
			table.remove(FACTIONS_HRE, i);
		end	
	end
end

function Get_Authority_Tooltip()
	local num_regions = #HRE_REGIONS;

	local authoritystring = "Current Imperial Authority: "..tostring(HRE_IMPERIAL_AUTHORITY);
	authoritystring = authoritystring.."\n\nEmperorship: [[rgba:8:201:27:150]]+"..tostring(HRE_IMPERIAL_AUTHORITY_GAIN_RATE).."[[/rgba]]";
	authoritystring = authoritystring.."\nRegions in the HRE: [[rgba:8:201:27:150]]+"..tostring(HRE_IMPERIAL_AUTHORITY_GAIN_PER_REGION * num_regions).."[[/rgba]]";
	authoritystring = authoritystring.."\n\nProjected Growth: [[rgba:8:201:27:150]]"..tostring(HRE_Calculate_Imperial_Authority() - HRE_IMPERIAL_AUTHORITY).."[[/rgba]]";
	authoritystring = authoritystring.."\nProjected Imperial Authority: [[rgba:8:201:27:150]]"..tostring(HRE_Calculate_Imperial_Authority()).."[[/rgba]]";

	return authoritystring;
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		SaveTable(context, FACTIONS_HRE, "FACTIONS_HRE");
		SaveKeyPairTable(context, FACTIONS_HRE_STATES, "FACTIONS_HRE_STATES");
		cm:save_value("HRE_EMPEROR_KEY", HRE_EMPEROR_KEY, context);
		cm:save_value("HRE_EMPEROR_PRETENDER_KEY", HRE_EMPEROR_PRETENDER_KEY, context);
		cm:save_value("HRE_EMPEROR_PRETENDER_COOLDOWN", HRE_EMPEROR_PRETENDER_COOLDOWN, context);
		cm:save_value("HRE_IMPERIAL_AUTHORITY", HRE_IMPERIAL_AUTHORITY, context);
		cm:save_value("HRE_FRANKFURT_STATUS", HRE_FRANKFURT_STATUS, context);
	end
);

cm:register_loading_game_callback(
	function(context)
		FACTIONS_HRE = LoadTable(context, "FACTIONS_HRE");
		FACTIONS_HRE_STATES = LoadKeyPairTable(context, "FACTIONS_HRE_STATES");
		HRE_EMPEROR_KEY = cm:load_value("HRE_EMPEROR_KEY", "mk_fact_hre", context);
		HRE_EMPEROR_PRETENDER_KEY = cm:load_value("HRE_EMPEROR_PRETENDER_KEY", "mk_fact_sicily", context);
		HRE_EMPEROR_PRETENDER_COOLDOWN = cm:load_value("HRE_EMPEROR_PRETENDER_COOLDOWN", 0, context);
		HRE_IMPERIAL_AUTHORITY = cm:load_value("HRE_IMPERIAL_AUTHORITY", 40, context);
		HRE_FRANKFURT_STATUS = cm:load_value("HRE_FRANKFURT_STATUS", "capital", context);
	end
);