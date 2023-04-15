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
require("story/story_reconquista");
require("story/story_teutonic_order");
require("story/story_world");

if mkHRE then
	require("story/story_hre");
	require("story/story_sicily");
end

function Story_Initializer()
	if STORY_EVENTS_ENABLED == true then
		Add_Aragon_Story_Events_Listeners();
		--Add_Ayyubid_Story_Events_Listeners();
		Add_England_Story_Events_Listeners();
		Add_France_Story_Events_Listeners();
		Add_Hungary_Story_Events_Listeners();
		Add_Reconquista_Story_Events_Listeners();

		if cm:is_multiplayer() == false then
			Add_HRE_Story_Events_Listeners();
			Add_Sicily_Story_Events_Listeners();
		end
	end

	-- Add these anyway.
	Add_World_Story_Events_Listeners();
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
