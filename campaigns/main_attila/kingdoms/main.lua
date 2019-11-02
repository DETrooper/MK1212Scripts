-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - KINGDOMS: MAIN
-- 	By: DETrooper
--
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------

require("kingdoms/kingdom_byzantium");
require("kingdoms/kingdom_golden_horde");
require("kingdoms/kingdom_ilkhanate");
require("kingdoms/kingdom_poland");
require("kingdoms/kingdom_serbia");
require("kingdoms/kingdom_spain");
require("kingdoms/list_regions");

function Kingdom_Initializer()
	Add_Kingdom_Byzantium_Listeners();
	Add_Kingdom_Golden_Horde_Listeners();
	Add_Kingdom_Ilkhanate_Listeners();
	Add_Kingdom_Poland_Listeners();
	Add_Kingdom_Serbia_Listeners();
	Add_Kingdom_Spain_Listeners();
end

function Rename_Faction(faction_key, rename_key)
	cm:set_faction_name_override(faction_key, "campaign_localised_strings_string_"..rename_key);
end

function Has_Required_Regions(faction_key, region_list)
	for i = 1, #region_list do
		local region = cm:model():world():region_manager():region_by_key(region_list[i]);
		
		if region:owning_faction():name() ~= faction_key then
			return false;
		end
	end
	return true;
end