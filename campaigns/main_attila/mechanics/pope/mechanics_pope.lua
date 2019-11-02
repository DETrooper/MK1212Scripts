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
require("mechanics/pope/mechanics_pope_favour");
require("mechanics/pope/mechanics_pope_crusades");
--require("mechanics/pope/mechanics_pope_missions");
require("mechanics/pope/mechanics_pope_ui");

PAPAL_STATES_KEY = "mk_fact_papacy";
PAPAL_STATES_DEAD = false;
CURRENT_POPE = 1;
LAST_POPE = 0;
POPE_MIN_AGE = 40;
POPE_MAX_AGE = 51;
MIN_YEARS_YEARS_IN_OFFICE = 10; -- The minimum number of years a generated Pope must be in office before we consider replacing him
MAX_YEARS_YEARS_IN_OFFICE = 20; -- The maximum number of years a generated Pope can be in office before we replace him

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

	if papacy:is_null_interface() == true and PAPAL_STATES_DEAD == false then
		Deactivate_Papal_Favour_System();
		PAPAL_STATES_DEAD = true;
	elseif papacy:is_null_interface() == false and PAPAL_STATES_DEAD == true then
		Activate_Papal_Favour_System();
		PAPAL_STATES_DEAD = false;
	end

	if context:faction():state_religion() == "att_rel_chr_catholic" and papacy:is_null_interface() == false and context:faction():is_human() == true then
		cm:make_region_visible_in_shroud(context:faction():name(), papacy:home_region():name());
	end

	if context:faction():name() == PAPAL_STATES_KEY then
		local TURN_NUMBER = cm:model():turn_number();
		local YEARS_IN_OFFICE = (TURN_NUMBER - LAST_POPE) / 4;

		if NextPope().turn == TURN_NUMBER then
			CURRENT_POPE = CURRENT_POPE + 1;
			LAST_POPE = TURN_NUMBER;
			Pope_Changeover(context);
		elseif NextPope().turn == -1 then
			output("Next Pope is to be spawned randomly...");
			-- There is no set date to install this Pope
			-- Make sure the current Pope has served his minimum term
			-- Give the current Pope an increasing chance of being replaced every turn
			if YEARS_IN_OFFICE >= MIN_YEARS_YEARS_IN_OFFICE then
				-- He's served his minimum term, he can now have a chance of being replaced
				local CHANCE = 100 / (MAX_YEARS_YEARS_IN_OFFICE - YEARS_IN_OFFICE);
				
				if cm:model():random_percent(CHANCE) then
					CURRENT_POPE = CURRENT_POPE + 1;
					LAST_POPE = TURN_NUMBER;
					Pope_Changeover(context);
				end
			end
		end
	end
end

function Pope_Changeover(context)
	local POPE_AGE = cm:random_number(POPE_MAX_AGE, POPE_MIN_AGE);
	local IS_HEIR = true;
	
	-- Get a new Pope ready...
	cm:spawn_character_into_family_tree(
		PAPAL_STATES_KEY,				-- Faction Key
		POPE_LIST[CURRENT_POPE].name,	-- Forename Key
		"",								-- Family Name Key
		"",								-- Clan Name Key
		"", 							-- Other Name Key
		POPE_AGE, 						-- Age
		true, 							-- Is Male?
		"", 							-- Father Lookup
		"", 							-- Mother Lookup
		true, 							-- Is Immortal?
		"cha_pope", 					-- Art Set ID
		IS_HEIR, 						-- Make Heir?
		false							-- Is Attila?
	);
	
	-- Remove current Pope
	if context:faction():has_faction_leader() then
		local current_pope = context:faction():faction_leader();
		cm:set_character_immortality("character_cqi:"..current_pope:command_queue_index(), false);
		cm:kill_character("character_cqi:"..current_pope:command_queue_index(), false, false);
	end
	
	-- Give the new Pope his trait
	if context:faction():has_faction_leader() then
		local current_pope = context:faction():faction_leader();
		cm:force_add_trait("character_cqi:"..current_pope:command_queue_index(), "cha_trait_pope", false);
	end
	
	-- Hide the new Pope
	if context:faction():has_faction_leader() then
		local current_pope = context:faction():faction_leader();
		cm:hide_character("character_cqi:"..current_pope:command_queue_index(), true);
	end
	
	-- Tell everyone about the new Pope!
	local faction_list = cm:model():world():faction_list();
	local POPE_NAME = "";

	-- add more later!	
	if POPE_LIST[CURRENT_POPE].id == "Innocentius III" then
		POPE_NAME = "_innocentius_3";
	elseif POPE_LIST[CURRENT_POPE].id == "Honorius III" then
		POPE_NAME = "_honorious_3";
	elseif POPE_LIST[CURRENT_POPE].id == "Gregorius IX" then
		POPE_NAME = "_gregorius_9";
	elseif POPE_LIST[CURRENT_POPE].id == "Coelestinus IV" then
		POPE_NAME = "_coelestinus_1";
	elseif POPE_LIST[CURRENT_POPE].id == "Innocentius IV" then
		POPE_NAME = "_innocentius_4";
	end
	
	for i = 0, faction_list:num_items() - 1 do
		local current_faction = faction_list:item_at(i);
		
		if current_faction:is_null_interface() == false then
			-- Only show Human Christians
			if current_faction:is_human() == true and current_faction:state_religion() == "att_rel_chr_catholic" then
				cm:show_message_event(
					current_faction:name(),
					"message_event_text_text_mk_event_pope_new_pope_title",
					"message_event_text_text_mk_event_pope_new_pope_primary_detail"..POPE_NAME,
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
			if POPE_LIST[i].turn == -1 then
				CURRENT_POPE = i-1;
				return POPE_LIST[CURRENT_POPE + 1];
			end
		end
	end
	return POPE_LIST[CURRENT_POPE + 1];
end

POPE_LIST = {
	{id = "Innocentius III",	name = "names_name_2147380345", turn = -99}, -- All comments are the 1TPY equivalent.
	{id = "Honorius III",		name = "names_name_2147380346", turn = 14}, -- 4
	{id = "Gregorius IX",		name = "names_name_2147380347", turn = 60}, -- 15
	{id = "Coelestinus IV",	name = "names_name_2147380353", turn = 118}, -- 29
	{id = "Innocentius IV",	name = "names_name_2147380363", turn = 125}, -- 31
	{id = "Alexander IV",	name = "names_name_2147380367", turn = 169}, -- 42
	{id = "Urbanus IV",		name = "names_name_2147380369", turn = 197}, -- 49
	{id = "Clemens IV",		name = "names_name_2147380378", turn = 212}, -- 53
	{id = "Gregorius X",		name = "names_name_2147380386", turn = 238}, -- 59
	{id = "Innocentius V",	name = "names_name_2147380394", turn = 256}, -- 64
	{id = "Hadrianus V",		name = "names_name_2147380396", turn = 257}, -- 64
	{id = "Ioannes XXI",		name = "names_name_2147380401", turn = 258}, -- 65
	{id = "Nicolaus III",		name = "names_name_2147380406", turn = 262}, -- 66
	{id = "Martinus IV",		name = "names_name_2147380412", turn = 276}, -- 69
	{id = "Honorius IV",		name = "names_name_2147380421", turn = 292}, -- 73
	{id = "Nicolaus IV",		name = "names_name_2147380426", turn = 316}, -- 76
	{id = "Coelestinus V",	name = "names_name_2147380428", turn = 328}, -- 82
	{id = "Bonfatius VIII",	name = "names_name_2147380432", turn = 331}, -- 83
	{id = "Benedictus XI",	name = "names_name_2147380442", turn = -1},
	{id = "Clemens V",		name = "names_name_2147380449", turn = -1},
	{id = "Ioannes XXII",	name = "names_name_2147380458", turn = -1}
};

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