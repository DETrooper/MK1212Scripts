-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - STORY: MAIN
-- 	By: DETrooper
--
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------

require("story/story_aragon");
require("story/story_ayyubids");
require("story/story_england");
require("story/story_france");
require("story/story_hungary");
require("story/story_hre");
require("story/story_reconquista");
require("story/story_sicily");
require("story/story_teutonic_order");

function Story_Initializer()
	Add_Aragon_Story_Events_Listeners();
	Add_Ayyubid_Story_Events_Listeners();
	Add_England_Story_Events_Listeners();
	Add_France_Story_Events_Listeners();
	Add_Hungary_Story_Events_Listeners();
	Add_HRE_Story_Events_Listeners();
	Add_Reconquista_Story_Events_Listeners();
	Add_Sicily_Story_Events_Listeners();
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