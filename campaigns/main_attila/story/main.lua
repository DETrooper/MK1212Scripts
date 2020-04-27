-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - STORY: MAIN
-- 	By: DETrooper
--
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------

STORY_EVENTS_ENABLED = true;

require("story/story_aragon");
--require("story/story_ayyubids");
require("story/story_england");
require("story/story_france");
require("story/story_hungary");
require("story/story_hre");
require("story/story_reconquista");
require("story/story_sicily");
require("story/story_teutonic_order");
require("story/story_world");

function Story_Initializer()
	if STORY_EVENTS_ENABLED == true then
		Add_Aragon_Story_Events_Listeners();
		--Add_Ayyubid_Story_Events_Listeners();
		Add_England_Story_Events_Listeners();
		Add_France_Story_Events_Listeners();
		Add_Hungary_Story_Events_Listeners();
		Add_HRE_Story_Events_Listeners();
		Add_Reconquista_Story_Events_Listeners();
		Add_Sicily_Story_Events_Listeners();
	end

	-- Add these anyway.
	Add_World_Story_Events_Listeners();
end

function Are_Regions_Religion(religion_key, region_list)
	for i = 1, #region_list do
		local region = cm:model():world():region_manager():region_by_key(region_list[i]);

		if region:owning_faction():state_religion() ~= religion_key then
			return false;
		end
	end

	return true;
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		cm:save_value("STORY_EVENTS_ENABLED", STORY_EVENTS_ENABLED, context);
	end
);

cm:register_loading_game_callback(
	function(context)
		STORY_EVENTS_ENABLED = cm:load_value("STORY_EVENTS_ENABLED", true, context);
	end
);
