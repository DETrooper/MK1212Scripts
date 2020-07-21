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
require("mechanics/pope/mechanics_pope_crusades");
--require("mechanics/pope/mechanics_pope_missions");
require("mechanics/pope/mechanics_pope_ui");

PAPAL_STATES_KEY = "mk_fact_papacy";
PAPAL_STATES_DEAD = false;
CURRENT_POPE = 1;
LAST_POPE = 0;
POPE_MIN_AGE = 40; -- Minimum age for generated popes.
POPE_MAX_AGE = 70; -- Maximum age for generated popes.
MIN_YEARS_YEARS_IN_OFFICE = 10; -- The minimum number of years a generated Pope must be in office before we consider replacing him.
MAX_YEARS_YEARS_IN_OFFICE = 20; -- The maximum number of years a generated Pope can be in office before we replace him.

function Add_Pope_Listeners()
	cm:add_listener(
		"FactionTurnStart_Pope",
		"FactionTurnStart",
		true,
		function(context) Pope_Term_Check(context) end,
		true
	);

	Add_Pope_Favour_Listeners();
	--Add_Pope_Mission_Listeners();

	if cm:is_multiplayer() == false then
		Add_Crusade_Event_Listeners();
		Add_Pope_UI_Listeners();
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

				if current_faction:is_human() == true and current_faction:state_religion() == "att_rel_chr_catholic" and cm:is_new_game() then
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

	if faction:is_null_interface() == false and faction:has_faction_leader() then
		local current_pope = faction:faction_leader();
		cm:hide_character("character_cqi:"..current_pope:command_queue_index(), true);
	end
end

function Pope_Term_Check(context)
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

	if context:faction():is_human() then
		local turn_number = cm:model():turn_number();
		local years_in_office = (turn_number - LAST_POPE) / 2;

		if GetTurnFromYear(NextPope().year) == turn_number then
			CURRENT_POPE = CURRENT_POPE + 1;
			LAST_POPE = turn_number;
			Pope_Changeover();
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
					Pope_Changeover();
				end
			end
		end
	end
end

function Pope_Changeover()
	local age = cm:random_number(POPE_MAX_AGE, POPE_MIN_AGE);
	local forename = GENERIC_POPE_NAMES[cm:random_number(#GENERIC_POPE_NAMES)];
	local papacy = cm:model():world():faction_by_key(PAPAL_STATES_KEY);

	if POPE_LIST[CURRENT_POPE]  then
		age = POPE_LIST[CURRENT_POPE].age;
		forename = POPE_LIST[CURRENT_POPE].name;
	end
	
	-- Get a new Pope ready...
	cm:spawn_character_into_family_tree(
		PAPAL_STATES_KEY,					-- Faction Key
		POPE_LIST[CURRENT_POPE].name,				-- Forename Key
		"",							-- Family Name Key
		"",							-- Clan Name Key
		"", 							-- Other Name Key
		age, 							-- Age
		true, 							-- Is Male?
		"", 							-- Father Lookup
		"", 							-- Mother Lookup
		true, 							-- Is Immortal?
		"cha_pope", 						-- Art Set ID
		true, 							-- Make Heir?
		false							-- Is Attila?
	);
	
	-- Remove current Pope
	if papacy:has_faction_leader() then
		local current_pope = papacy:faction_leader();

		cm:set_character_immortality("character_cqi:"..current_pope:command_queue_index(), false);
		cm:kill_character("character_cqi:"..current_pope:command_queue_index(), false, false);
	end
	
	-- Give the new Pope his trait
	if papacy:has_faction_leader() then
		local current_pope = papacy:faction_leader();

		cm:force_add_trait("character_cqi:"..current_pope:command_queue_index(), "cha_trait_pope", false);
	end
	
	-- Hide the new Pope
	if papacy:has_faction_leader() then
		local current_pope = papacy:faction_leader();

		cm:hide_character("character_cqi:"..current_pope:command_queue_index(), true);
	end
	
	-- Tell everyone about the new Pope!
	local faction_list = cm:model():world():faction_list();
	
	for i = 0, faction_list:num_items() - 1 do
		local current_faction = faction_list:item_at(i);
		
		if current_faction:is_null_interface() == false then
			-- Only show Human Christians
			if current_faction:is_human() == true and current_faction:state_religion() == "att_rel_chr_catholic" then
				cm:show_message_event(
					current_faction:name(),
					"message_event_text_text_mk_event_pope_new_pope_title",
					POPE_LIST[CURRENT_POPE].name,
					"message_event_text_text_mk_event_pope_new_pope_secondary_detail",
					true,
					666
				);
			end
		end
	end
end

function IsPopeAlive()
	local faction = cm:model():world():faction_by_key(PAPAL_STATES_KEY);

	if faction:is_null_interface() == false and faction:has_faction_leader() then
		return true;
	else
		return false;
	end
end

function CurrentPope()
	return POPE_LIST[CURRENT_POPE];
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

------------------------------------------------
---------------- Saving/Loading ----------------
------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		cm:save_value("PAPAL_STATES_DEAD", PAPAL_STATES_DEAD, context);
		cm:save_value("CURRENT_POPE", CURRENT_POPE, context);
		cm:save_value("LAST_POPE", LAST_POPE, context);
	end
);

cm:register_loading_game_callback(
	function(context)
		PAPAL_STATES_DEAD = cm:load_value("PAPAL_STATES_DEAD", false, context);
		CURRENT_POPE = cm:load_value("CURRENT_POPE", 1, context);
		LAST_POPE = cm:load_value("LAST_POPE", 0, context);
	end
);
