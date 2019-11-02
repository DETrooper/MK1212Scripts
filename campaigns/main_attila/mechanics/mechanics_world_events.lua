----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: WORLD EVENTS
-- 	By: DETrooper
--
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

-- Fires, earthquakes, volcanoes, floods, famines, and more!

-- Great famine of 1315-1317

-- Interesting historical facts like inventions and news from far-away lands.

-- List of scripted world events not included in here (i.e. handled elsewhere):
--[[
Fifth Crusade Announced - Turn 3
Fifth Crusade Begins - Turn 5
Mongol Invasion Begins - Turn 8
Bubonic Plague Begins - 135
]]--

function Add_World_Events_Listeners()
	cm:add_listener(
		"FactionTurnStart_World_Events",
		"FactionTurnStart",
		true,
		function(context) World_Events(context) end,
		true
	);
end

function World_Events(context)
	local turn_number = cm:model():turn_number();
end