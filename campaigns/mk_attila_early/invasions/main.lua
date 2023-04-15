-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - INVASIONS: MAIN
-- 	By: DETrooper
--
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

require("invasions/invasion_lists");
require("invasions/mongol_invasion");
require("invasions/timurid_invasion");

function Invasion_Initializer()
	Add_Mongol_Invasion_Listeners();
	Add_Timurid_Invasion_Listeners();
end

function Invasion_Build_Unit_List(faction, army_type)
	local unit_list = "";
	local units_added = 0;

	for k, v in pairs(GOLDEN_HORDE_ARMY_TEMPLATES["army_type"].minimum) do
		for i = 1, v do
			if i > 1 then
				unit_list = ","..unit_list..k;
			else
				unit_list = unit_list..k;
			end

			units_added = units_added + 1;
		end
	end

	while units_added < 19 do
		local random_unit_key = table.Random(GOLDEN_HORDE_ARMY_TEMPLATES["army_type"].adds);

		unit_list = ","..unit_list..random_unit_key;

		units_added = units_added + 1;
	end

	return unit_list;
end

function Invasion_Warn_About_Upkeep(CQI, event_string)
	-- Make sure this force exists!
	if cm:model():has_military_force_command_queue_index(CQI) then
		local force_gen = cm:model():military_force_for_command_queue_index(CQI):general_character();

		cm:show_message_event_located(
			force_gen:faction():name(),
			"message_event_text_text_mk_event_"..event_string.."_upkeep_title",
			"message_event_text_text_mk_event_"..event_string.."_upkeep_primary",
			"message_event_text_text_mk_event_"..event_string.."_upkeep_secondary",
			force_gen:logical_position_x(),
			force_gen:logical_position_y(),
			false,
			190
		);
	end
end
