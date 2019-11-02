--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - STORY: AYYUBIDS
-- 	By: DETrooper
--
--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
-- This script is heavily reliant on pope_crusades.lua
-- Mission will fail if 5th crusade is successful.

-- todo: mamluks

AYYUBIDS_KEY = "mk_fact_ayyubids";
AYYUBIDS_MISSION_ISSUED = false;

function Add_Ayyubid_Story_Events_Listeners()
	local ayyubids = cm:model():world():faction_by_key(AYYUBIDS_KEY);

	if ayyubids:is_human() == true then
		cm:add_listener(
			"FactionTurnStart_Ayyubids",
			"FactionTurnStart",
			true,
			function(context) FactionTurnStart_Ayyubids(context) end,
			true
		);
	end
end

function FactionTurnStart_Ayyubids(context)
	if context:faction():name() == AYYUBIDS_KEY and AYYUBIDS_MISSION_ISSUED == false then
		if FIFTH_CRUSADE_TRIGGERED == true then
			if CURRENT_CRUSADE_TARGET_OWNER == AYYUBIDS_KEY then
				cm:trigger_mission(AYYUBIDS_KEY, "mk_mission_story_ayyubids_crusade_defense");
				AYYUBIDS_MISSION_ISSUED = true;
			end
		end
	end
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		cm:save_value("AYYUBIDS_MISSION_ISSUED", AYYUBIDS_MISSION_ISSUED, context);
	end
);

cm:register_loading_game_callback(
	function(context)
		AYYUBIDS_MISSION_ISSUED = cm:load_value("AYYUBIDS_MISSION_ISSUED", false, context);
	end
);