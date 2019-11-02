---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: POPE MISSIONS
-- 	By: DETrooper
--
---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------

PAPAL_MISSION_ISSUED = false;
MISSION_MEDIAN_TURNS = 5;

HEATHEN_ALLIANCES = {};

local dev = require("lua_scripts.dev");

function Add_Pope_Mission_Listeners()
	--[[cm:add_listener(
		"FactionTurnStart_Check_Mission_Prerequisites",
		"FactionTurnStart",
		true,
		function(context) FactionTurnStart_Check_Mission_Prerequisites(context) end,
		true
	);]]--
	cm:add_listener(
		"RegionTurnStart_Check_Regions",
		"RegionTurnStart",
		true,
		function(context) RegionTurnStart_Check_Regions(context) end,
		true
	);
end

function FactionTurnStart_Check_Mission_Prerequisites(context)
	local faction_name = context:faction():name();
	local faction_religion = context:faction():state_religion();
	--local faction = cm:model():world():faction_by_key(faction_name);

	-- Check to see if allied with heathens.
	--[[if FACTIONS_CATHOLIC[faction_name] == true then
		local faction_list = cm:model():world():faction_list();
		for i = 0, faction_list:num_items() - 1 do
			local current_faction = faction_list:item_at(i);
			local current_faction_name = current_faction:name();
		
			if current_faction:state_religion() ~= "att_rel_chr_catholic" and faction:allied_with(current_faction) == true then
				HEATHEN_ALLIANCES[faction_name + current_faction_name] = true;
			elseif current_faction:state_religion() ~= "att_rel_chr_catholic" and faction:allied_with(current_faction) == false then
				HEATHEN_ALLIANCES[faction_name + current_faction_name] = false;
			end
		end
	dev.log(HEATHEN_ALLIANCES);
	end]]--
end

function RegionTurnStart_Check_Regions(context)
	local current_region_name = context:region():name();
	local owner = context:region():owning_faction();

	if context:region():majority_religion() ~= "att_rel_chr_catholic" and owner:state_religion() == "att_rel_chr_catholic" and owner:is_human() == true then
		dev.log(current_region_name);
	end
end