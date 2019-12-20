---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - BYZANTIUM: GREEK FIRE
-- 	By: DETrooper
--
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
-- Byzantine factions must maintain the costly Greek Fire or risk losing it forever.

CONSTANTINOPLE_KEY = "att_reg_thracia_constantinopolis";
GREEK_FIRE_TURNS_BETWEEN_DILEMMAS_MAX = 50;
GREEK_FIRE_TURNS_BETWEEN_DILEMMAS_MIN = 25;

GREEK_FIRE_UNITS = {
	"mk_byz_t1_siphonatores"
}

EXPLOSION_TRIGGERED = false;
GREEK_FIRE_EPIRUS = true;
GREEK_FIRE_EPIRUS_TIMER = 0;
GREEK_FIRE_NICAEA = true;
GREEK_FIRE_NICAEA_TIMER = 0;
GREEK_FIRE_TREBIZOND = true;
GREEK_FIRE_TREBIZOND_TIMER = 0;

function Add_Byzantium_Greek_Fire_Listeners()
	cm:add_listener(
		"FactionTurnStart_Byzantium_Greek_Fire_Check",
		"FactionTurnStart",
		true,
		function(context) Byzantium_Greek_Fire_Check(context) end,
		true
	);
	cm:add_listener(
		"DilemmaChoiceMadeEvent_Byzantium_Greek_Fire",
		"DilemmaChoiceMadeEvent",
		true,
		function(context) DilemmaChoiceMadeEvent_Byzantium_Greek_Fire(context) end,
		true
	);
	cm:add_listener(
		"DillemaOrIncidentStarted_Byzantium_Greek_Fire",
		"DillemaOrIncidentStarted",
		true,
		function(context) DillemaOrIncidentStarted_Byzantium_Greek_Fire(context) end,
		true
	);

	if cm:is_new_game() then
		GREEK_FIRE_EPIRUS_TIMER = cm:random_number(GREEK_FIRE_TURNS_BETWEEN_DILEMMAS_MAX, GREEK_FIRE_TURNS_BETWEEN_DILEMMAS_MIN);
		GREEK_FIRE_NICAEA_TIMER = cm:random_number(GREEK_FIRE_TURNS_BETWEEN_DILEMMAS_MAX, GREEK_FIRE_TURNS_BETWEEN_DILEMMAS_MIN);
		GREEK_FIRE_TREBIZOND_TIMER = cm:random_number(GREEK_FIRE_TURNS_BETWEEN_DILEMMAS_MAX, GREEK_FIRE_TURNS_BETWEEN_DILEMMAS_MIN);
	end	
end

function Byzantium_Greek_Fire_Check(context)
	if context:faction():name() == EPIRUS_KEY and GREEK_FIRE_EPIRUS == true then
		if GREEK_FIRE_EPIRUS_TIMER > 0 then
			GREEK_FIRE_EPIRUS_TIMER = GREEK_FIRE_EPIRUS_TIMER - 1;
		elseif GREEK_FIRE_EPIRUS_TIMER <= 0 then
			GREEK_FIRE_EPIRUS_TIMER = cm:random_number(GREEK_FIRE_TURNS_BETWEEN_DILEMMAS_MAX, GREEK_FIRE_TURNS_BETWEEN_DILEMMAS_MIN);

			if context:faction():is_human() then
				cm:trigger_dilemma(EPIRUS_KEY, "mk_dilemma_byzantium_greek_fire");
			end
		end

		if cm:model():world():region_manager():region_by_key(CONSTANTINOPLE_KEY):owning_faction():name() == faction_key then
			if EXPLOSION_TRIGGERED == false and cm:model():random_percent(1) then
				EXPLOSION_TRIGGERED = true;

				if context:faction():is_human() then
					cm:trigger_dilemma(EPIRUS_KEY, "mk_dilemma_byzantium_greek_fire_explosion");
				end
			end
		end
	elseif context:faction():name() == NICAEA_KEY and GREEK_FIRE_NICAEA == true then
		if GREEK_FIRE_NICAEA_TIMER > 0 then
			GREEK_FIRE_NICAEA_TIMER = GREEK_FIRE_NICAEA_TIMER - 1;
		elseif GREEK_FIRE_NICAEA_TIMER <= 0 then
			GREEK_FIRE_NICAEA_TIMER = cm:random_number(GREEK_FIRE_TURNS_BETWEEN_DILEMMAS_MAX, GREEK_FIRE_TURNS_BETWEEN_DILEMMAS_MIN);

			if context:faction():is_human() then
				cm:trigger_dilemma(NICAEA_KEY, "mk_dilemma_byzantium_greek_fire");
			end
		end

		if cm:model():world():region_manager():region_by_key(CONSTANTINOPLE_KEY):owning_faction():name() == faction_key then
			if EXPLOSION_TRIGGERED == false and cm:model():random_percent(1) then
				EXPLOSION_TRIGGERED = true;

				if context:faction():is_human() then
					cm:trigger_dilemma(NICAEA_KEY, "mk_dilemma_byzantium_greek_fire_explosion");
				end
			end
		end
	elseif context:faction():name() == TREBIZOND_KEY and GREEK_FIRE_TREBIZOND == true then
		if GREEK_FIRE_TREBIZOND_TIMER > 0 then
			GREEK_FIRE_TREBIZOND_TIMER = GREEK_FIRE_TREBIZOND_TIMER - 1;
		elseif GREEK_FIRE_TREBIZOND_TIMER <= 0 then
			GREEK_FIRE_TREBIZOND_TIMER = cm:random_number(GREEK_FIRE_TURNS_BETWEEN_DILEMMAS_MAX, GREEK_FIRE_TURNS_BETWEEN_DILEMMAS_MIN);

			if context:faction():is_human() then
				cm:trigger_dilemma(TREBIZOND_KEY, "mk_dilemma_byzantium_greek_fire");
			end
		end

		if cm:model():world():region_manager():region_by_key(CONSTANTINOPLE_KEY):owning_faction():name() == faction_key then
			if EXPLOSION_TRIGGERED == false and cm:model():random_percent(1) then
				EXPLOSION_TRIGGERED = true;

				if context:faction():is_human() then
					cm:trigger_dilemma(TREBIZOND_KEY, "mk_dilemma_byzantium_greek_fire_explosion");
				end
			end
		end
	end
end

function DilemmaChoiceMadeEvent_Byzantium_Greek_Fire(context)
	if context:dilemma() == "mk_dilemma_byzantium_greek_fire" or context:dilemma() == "mk_dilemma_byzantium_greek_fire_explosion" then
		if context:choice() == 0 then
			if context:faction():name() == EPIRUS_KEY then
				GREEK_FIRE_EPIRUS = false;
				GREEK_FIRE_EPIRUS_TIMER = nil;
			elseif context:faction():name() == NICAEA_KEY then
				GREEK_FIRE_NICAEA = false;
				GREEK_FIRE_NICAEA_TIMER = nil;
			elseif context:faction():name() == TREBIZOND_KEY then
				GREEK_FIRE_TREBIZOND = false;
				GREEK_FIRE_TREBIZOND_TIMER = nil;
			end

			cm:show_message_event(
				context:faction():name(),
				"message_event_text_text_mk_event_greek_fire_title",
				"message_event_text_text_mk_event_greek_fire_lost_primary",
				"message_event_text_text_mk_event_greek_fire_lost_secondary",
				true,
				716
			);

			for i = 1, #GREEK_FIRE_UNITS do
				local unit = GREEK_FIRE_UNITS[i];
				cm:add_event_restricted_unit_record_for_faction(unit, context:faction():name());
			end
		elseif context:choice() == 1 then
			cm:show_message_event(
				context:faction():name(),
				"message_event_text_text_mk_event_greek_fire_title",
				"message_event_text_text_mk_event_greek_fire_saved_primary",
				"message_event_text_text_mk_event_greek_fire_saved_secondary",
				true,
				717
			);
		end
	end
end

function DillemaOrIncidentStarted_Byzantium_Greek_Fire(context)
	if context.string == "mk_dilemma_byzantium_greek_fire_explosion" then
		local constantinople = cm:model():world():region_manager():region_by_key(CONSTANTINOPLE_KEY);
		local slot_list = constantinople:slot_list();

		for i = 0, slot_list:num_items() - 1 do
			local slot = slot_list:item_at(i);
		
			if slot:has_building() then		
				local building = slot:building();
			
				if string.find(building:name(), "castle") or string.find(building:name(), "city")  then
					local health = building:percent_health();
					local damage_amount = math.random(10, 40);
				
					damage_amount = health - damage_amount;
				
					if damage_amount < 0 then
						damage_amount = 0;
					end

					cm:instant_set_building_health_percent(CONSTANTINOPLE_KEY, building:name(), damage_amount);
				elseif string.find(building:name(), "port") then
					cm:instant_set_building_health_percent(CONSTANTINOPLE_KEY, building:name(), 0);
				end
			end
		end
	end
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		cm:save_value("EXPLOSION_TRIGGERED", EXPLOSION_TRIGGERED, context);
		cm:save_value("GREEK_FIRE_EPIRUS", GREEK_FIRE_EPIRUS, context);
		cm:save_value("GREEK_FIRE_EPIRUS_TIMER", GREEK_FIRE_EPIRUS_TIMER, context);
		cm:save_value("GREEK_FIRE_NICAEA", GREEK_FIRE_NICAEA, context);
		cm:save_value("GREEK_FIRE_NICAEA_TIMER", GREEK_FIRE_NICAEA_TIMER, context);
		cm:save_value("GREEK_FIRE_TREBIZOND", GREEK_FIRE_TREBIZOND, context);
		cm:save_value("GREEK_FIRE_TREBIZOND_TIMER", GREEK_FIRE_TREBIZOND_TIMER, context);
	end
);

cm:register_loading_game_callback(
	function(context)
		EXPLOSION_TRIGGERED = cm:load_value("EXPLOSION_TRIGGERED", false, context);
		GREEK_FIRE_EPIRUS = cm:load_value("GREEK_FIRE_EPIRUS", true, context);
		GREEK_FIRE_EPIRUS_TIMER = cm:load_value("GREEK_FIRE_EPIRUS_TIMER", 0, context);
		GREEK_FIRE_NICAEA = cm:load_value("GREEK_FIRE_NICAEA", true, context);
		GREEK_FIRE_NICAEA_TIMER = cm:load_value("GREEK_FIRE_NICAEA_TIMER", 0, context);
		GREEK_FIRE_TREBIZOND = cm:load_value("GREEK_FIRE_TREBIZOND", true, context);
		GREEK_FIRE_TREBIZOND_TIMER = cm:load_value("GREEK_FIRE_TREBIZOND_TIMER", 0, context);
	end
);