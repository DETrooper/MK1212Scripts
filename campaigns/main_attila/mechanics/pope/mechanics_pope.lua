---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: POPE
-- 	Modified By: DETrooper
-- 	Original Script by Creative Assembly
--
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- Controls several aspects related to the Pope, including: who the Pope is, consequences for declaring war on the Papacy, and occupying/sacking Rome.
-- Also serves as a hub for all papal-related scripts.

-- Other Pope stuff!!!
require("mechanics/pope/mechanics_pope_lists");
require("mechanics/pope/mechanics_pope_favour");
--require("mechanics/pope/mechanics_pope_college");
require("mechanics/pope/mechanics_pope_crusades");
--require("mechanics/pope/mechanics_pope_missions");
require("mechanics/pope/mechanics_pope_ui");

MIN_YEARS_YEARS_IN_OFFICE = 10; -- The minimum number of years a generated Pope must be in office before we consider replacing him.
MAX_YEARS_YEARS_IN_OFFICE = 20; -- The maximum number of years a generated Pope can be in office before we replace him.
PAPAL_STATES_KEY = "mk_fact_papacy";
POPE_MIN_AGE = 40; -- Minimum age for generated popes.
POPE_MAX_AGE = 70; -- Maximum age for generated popes.

AUTOMATIC_POPE_SELECTION = false;
CURRENT_POPE = 1;
LAST_POPE = 0;
PAPAL_STATES_DEAD = false;
POPE_CONTROLLING_FACTION = "mk_fact_papacy";
POPE_DEAD = false;

function Add_Pope_Listeners()
	cm:add_listener(
		"CharacterBecomesFactionLeader_Pope",
		"CharacterBecomesFactionLeader",
		true,
		function(context) CharacterBecomesFactionLeader_Pope(context) end,
		true
	);
	cm:add_listener(
		"FactionTurnStart_Pope",
		"FactionTurnStart",
		true,
		function(context) FactionTurnStart_Pope(context) end,
		true
	);

	Add_Pope_Favour_Listeners();
	--Add_Pope_Mission_Listeners();

	if cm:is_multiplayer() == false then
		Add_Crusade_Event_Listeners();
		--Add_Pope_College_Listeners();
		Add_Pope_UI_Listeners();
	else
		AUTOMATIC_POPE_SELECTION = true;
	end
	
	local faction = cm:model():world():faction_by_key(PAPAL_STATES_KEY);
	
	-- Nobody but the player can war the Pope!
	local faction_list = cm:model():world():faction_list();
	
	for i = 0, faction_list:num_items() - 1 do
		local current_faction = faction_list:item_at(i);
		
		if current_faction:is_null_interface() == false then
			if current_faction:name() ~= PAPAL_STATES_KEY then
				-- This is not the Pope, but stop the Pope going to war with them
				cm:force_diplomacy(PAPAL_STATES_KEY, current_faction:name(), "war", false, false);
				cm:force_diplomacy(PAPAL_STATES_KEY, current_faction:name(), "join war", false, false);
				cm:force_diplomacy( current_faction:name(), PAPAL_STATES_KEY, "join war", false, false);

				-- Can't ally the Pope...
				cm:force_diplomacy(PAPAL_STATES_KEY, current_faction:name(), "defensive alliance", false, false);
				cm:force_diplomacy(PAPAL_STATES_KEY, current_faction:name(), "military alliance", false, false);
				cm:force_diplomacy(current_faction:name(), PAPAL_STATES_KEY, "defensive alliance", false, false);
				cm:force_diplomacy(current_faction:name(), PAPAL_STATES_KEY, "military alliance", false, false);

				-- Can't marry the Pope...
				cm:force_diplomacy(PAPAL_STATES_KEY, current_faction:name(), "marriage", false, false);
				cm:force_diplomacy(current_faction:name(), PAPAL_STATES_KEY, "marriage", false, false);

				-- Can't vassalize the Pope...
				cm:force_diplomacy(PAPAL_STATES_KEY, current_faction:name(), "client state", false, false);
				cm:force_diplomacy(PAPAL_STATES_KEY, current_faction:name(), "vassal", false, false);
				cm:force_diplomacy(current_faction:name(), PAPAL_STATES_KEY, "client state", false, false);
				cm:force_diplomacy(current_faction:name(), PAPAL_STATES_KEY, "vassal", false, false);

				if current_faction:is_human() == false then
					-- This is an AI that is not the Pope, stop them going to war with the Pope
					cm:force_diplomacy(current_faction:name(), PAPAL_STATES_KEY, "war", false, false);
				end

				if cm:is_new_game() then
					if current_faction:is_human() == true and current_faction:state_religion() == "att_rel_chr_catholic" then
						cm:show_message_event(
							current_faction:name(),
							"message_event_text_text_mk_event_mk1212_popeintro_title",
							"message_event_text_text_mk_event_mk1212_popeintro_primary",
							"message_event_text_text_mk_event_mk1212_popeintro_secondary",
							true, 
							701
						);
					end
				end
			end
		end
	end

	if faction:is_null_interface() == false and faction:has_faction_leader() then
		local current_pope = faction:faction_leader();
		cm:hide_character("character_cqi:"..current_pope:command_queue_index(), true);
	end
end

function CharacterBecomesFactionLeader_Pope(context)
	if PAPAL_FAVOUR_SYSTEM_ACTIVE and not AUTOMATIC_POPE_SELECTION then
		local faction_name = context:character():faction():name();

		if faction_name == PAPAL_STATES_KEY then
			POPE_DEAD = true;
		end
	end
end

function FactionTurnStart_Pope(context)
	local papacy = cm:model():world():faction_by_key(PAPAL_STATES_KEY);

	if FactionIsAlive(PAPAL_STATES_KEY) ~= true and PAPAL_STATES_DEAD == false then
		Deactivate_Papal_Favour_System();
		PAPAL_STATES_DEAD = true;
	elseif FactionIsAlive(PAPAL_STATES_KEY) and PAPAL_STATES_DEAD == true then
		Activate_Papal_Favour_System();
		PAPAL_STATES_DEAD = false;
	end

	if context:faction():state_religion() == "att_rel_chr_catholic" and PAPAL_STATES_DEAD == false and context:faction():is_human() == true then
		if cm:is_multiplayer() == false then
			cm:make_region_visible_in_shroud(context:faction():name(), papacy:home_region():name());
		end
	end

	if context:faction():is_human() and AUTOMATIC_POPE_SELECTION then
		local turn_number = cm:model():turn_number();
		local years_in_office = (turn_number - LAST_POPE) / 2;

		if GetTurnFromYear(NextPope().year) == turn_number then
			CURRENT_POPE = CURRENT_POPE + 1;
			LAST_POPE = turn_number;
			Pope_Changeover_Automatic();
		elseif NextPope().year == -1 then
			output("Next Pope is to be spawned randomly...");
			-- There is no set date to install this Pope
			-- Make sure the current Pope has served his minimum term
			-- Give the current Pope an increasing chance of being replaced every turn
			if years_in_office >= MIN_YEARS_YEARS_IN_OFFICE then
				-- He's served his minimum term, he can now have a chance of being replaced
				local CHANCE = 100 / (MAX_YEARS_YEARS_IN_OFFICE - years_in_office);
				
				if cm:model():random_percent(CHANCE) then
					CURRENT_POPE = CURRENT_POPE + 1;
					LAST_POPE = turn_number;
					Pope_Changeover_Automatic();
				end
			end
		end
	end
end

function Pope_Changeover_Automatic()
	local age = cm:random_number(POPE_MAX_AGE, POPE_MIN_AGE);
	local name = GENERIC_POPE_NAMES[cm:random_number(#GENERIC_POPE_NAMES)];

	if POPE_LIST[CURRENT_POPE] then
		age = POPE_LIST[CURRENT_POPE].age;
		name = POPE_LIST[CURRENT_POPE].name;
	end
	
	Set_Papal_Controller(PAPAL_STATES_KEY);
	Pope_Changeover(name, age);
end

function Pope_Changeover(name, age)
	local papacy = cm:model():world():faction_by_key(PAPAL_STATES_KEY);

	-- Get a new Pope ready...
	cm:spawn_character_into_family_tree(
		PAPAL_STATES_KEY,				-- Faction Key
		name,							-- Forename Key
		"",								-- Family Name Key
		"",								-- Clan Name Key
		"", 							-- Other Name Key
		age, 							-- Age
		true, 							-- Is Male?
		"", 							-- Father Lookup
		"", 							-- Mother Lookup
		true, 							-- Is Immortal?
		"mk_pap_t1_pope", 				-- Art Set ID
		true, 							-- Make Heir?
		false							-- Is Attila?
	);
	
	-- Remove current Pope
	if papacy:has_faction_leader() then
		local current_pope = papacy:faction_leader();

		cm:set_character_immortality("character_cqi:"..current_pope:command_queue_index(), false);
		cm:kill_character("character_cqi:"..current_pope:command_queue_index(), false, false);
	end
	
	-- Give the new Pope his trait and hide him
	if papacy:has_faction_leader() then
		local current_pope = papacy:faction_leader();

		cm:force_add_trait("character_cqi:"..current_pope:command_queue_index(), "cha_trait_pope", false);
		cm:hide_character("character_cqi:"..current_pope:command_queue_index(), true);
	end
	
	-- Tell everyone about the new Pope!
	local faction_list = cm:model():world():faction_list();
	
	for i = 0, faction_list:num_items() - 1 do
		local current_faction = faction_list:item_at(i);
		
		if current_faction:is_null_interface() == false then
			-- Notify human Catholic factions about the new Pope.
			if current_faction:is_human() == true and current_faction:state_religion() == "att_rel_chr_catholic" then
				if current_faction:name() == POPE_CONTROLLING_FACTION then
					cm:show_message_event(
						current_faction:name(),
						"message_event_text_text_mk_event_pope_new_pope_player_faction_title",
						name,
						"message_event_text_text_mk_event_pope_new_pope_player_faction_secondary_detail",
						true,
						666
					);
				else
					cm:show_message_event(
						current_faction:name(),
						"message_event_text_text_mk_event_pope_new_pope_title",
						name,
						"message_event_text_text_mk_event_pope_new_pope_secondary_detail",
						true,
						666
					);
				end
			end
		end
	end
end

function NextPope()
	if POPE_LIST[CURRENT_POPE + 1] == nil then
		for i = 1, #POPE_LIST do
			if POPE_LIST[i].year == -1 then
				CURRENT_POPE = i-1;
				return POPE_LIST[CURRENT_POPE + 1];
			end
		end
	end

	return POPE_LIST[CURRENT_POPE + 1];
end

function Set_Papal_Controller(faction_name)
	local last_controller = cm:model():world():faction_by_key(POPE_CONTROLLING_FACTION);

	if last_controller:is_human() then
		cm:show_message_event(
			current_faction:name(),
			"message_event_text_text_mk_event_pope_new_pope_lost_control_title",
			name,
			"message_event_text_text_mk_event_pope_new_pope_lost_control_secondary_detail",
			true,
			666
		);
	end

	POPE_CONTROLLING_FACTION = faction_name;
end

------------------------------------------------
---------------- Saving/Loading ----------------
------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		cm:save_value("AUTOMATIC_POPE_SELECTION", AUTOMATIC_POPE_SELECTION, context);
		cm:save_value("CURRENT_POPE", CURRENT_POPE, context);
		cm:save_value("LAST_POPE", LAST_POPE, context);
		cm:save_value("PAPAL_STATES_DEAD", PAPAL_STATES_DEAD, context);
		cm:save_value("POPE_CONTROLLING_FACTION", POPE_CONTROLLING_FACTION, context);
	end
);

cm:register_loading_game_callback(
	function(context)
		AUTOMATIC_POPE_SELECTION = cm:load_value("AUTOMATIC_POPE_SELECTION", false, context);
		CURRENT_POPE = cm:load_value("CURRENT_POPE", 1, context);
		LAST_POPE = cm:load_value("LAST_POPE", 0, context);
		PAPAL_STATES_DEAD = cm:load_value("PAPAL_STATES_DEAD", false, context);
		POPE_CONTROLLING_FACTION = cm:load_value("POPE_CONTROLLING_FACTION", "mk_fact_papacy", context);
	end
);
