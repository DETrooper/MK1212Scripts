--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - STORY: WORLD EVENTS
-- 	By: DETrooper
--
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------

-- Fires, earthquakes, volcanoes, floods, famines, and more!

-- Great famine of 1315-1317.

-- Interesting historical facts like inventions and news from far-away lands.

--[[ List of scripted world events not included in here (i.e. handled elsewhere): 
Fifth Crusade Announced - Turn 7
Fifth Crusade Begins - Turn 11
Mongol Invasion Begins - Turn 15
Bubonic Plague Begins - Turn 269
Timurid Invasion - Turn 337
]]--

function Add_World_Story_Events_Listeners()
	cm:add_listener(
		"FactionTurnStart_World_Story_Events",
		"FactionTurnStart",
		true,
		function(context) World_Story_Events(context) end,
		true
	);
end

function World_Story_Events(context)
	local turn_number = cm:model():turn_number();

	if context:faction():is_human() then
		if turn_number == GetTurnFromYear(1300) then
			cm:show_message_event(
				context:faction():name(),
				"message_event_text_text_mk_event_14th_century_title", 
				"message_event_text_text_mk_event_14th_century_primary", 
				"message_event_text_text_mk_event_14th_century_secondary", 
				true,
				726
			);
		elseif turn_number == GetTurnFromYear(1315) then
			cm:show_message_event(
				context:faction():name(),
				"message_event_text_text_mk_event_great_famine_title", 
				"message_event_text_text_mk_event_great_famine_primary", 
				"message_event_text_text_mk_event_great_famine_secondary", 
				true,
				724
			);
		elseif turn_number == GetTurnFromYear(1318) then
			cm:show_message_event(
				context:faction():name(),
				"message_event_text_text_mk_event_little_ice_age_title", 
				"message_event_text_text_mk_event_little_ice_age_primary", 
				"message_event_text_text_mk_event_little_ice_age_secondary", 
				true,
				725
			);
		elseif turn_number == GetTurnFromYear(1400) then
			cm:show_message_event(
				context:faction():name(),
				"message_event_text_text_mk_event_15th_century_title", 
				"message_event_text_text_mk_event_15th_century_primary", 
				"message_event_text_text_mk_event_15th_century_secondary", 
				true,
				727
			);
		end
	end
end
