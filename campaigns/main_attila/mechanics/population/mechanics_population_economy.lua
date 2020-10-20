-----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: POPULATION ECONOMY
-- 	By: DETrooper
--
-----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------

function Add_Population_Economy_Listeners()
	cm:add_listener(
		"FactionTurnStart_Population_Economy",
		"FactionTurnStart",
		true,
		function(context) FactionTurnStart_Population_Economy(context) end,
		true
	);
	cm:add_listener(
		"CharacterEntersGarrison_Population_Economy",
		"CharacterEntersGarrison",
		true,
		function(context) CharacterEntersGarrison_Population_Economy(context) end,
		true
	);

	if cm:is_new_game() then
		local faction_list = cm:model():world():faction_list();

		for i = 0, faction_list:num_items() - 1 do
			local current_faction = faction_list:item_at(i);

			if current_faction:is_horde() == false and current_faction:region_list():num_items() > 0 then
				Apply_Region_Economy_Factionwide(current_faction);
			end
		end
	end
end

function FactionTurnStart_Population_Economy(context)
	if cm:model():turn_number() ~= 1 then
		if not context:faction():is_horde() then
			if context:faction():region_list():num_items() > 0 then
				Apply_Region_Economy_Factionwide(context:faction());
			end
		else
			Apply_Horde_Economy_Factionwide(context:faction());
		end
	end
end

function CharacterEntersGarrison_Population_Economy(context)
	if context:character():has_region() then
		Apply_Region_Economy(context:character():region());
	end
end

function Apply_Region_Economy_Factionwide(faction)
	local regions = faction:region_list();

	for i = 0, regions:num_items() - 1 do
		local region = regions:item_at(i);

		Apply_Region_Economy(region);
	end
end

function Apply_Region_Economy(region)
	local population_size = Get_Total_Population_Region(region:name());

	cm:remove_effect_bundle_from_region("mk_bundle_population_bundle_region", region:name());

	for i = 1, #POPULATION_SIZES do
		cm:remove_effect_bundle_from_region(POPULATION_SIZES_TO_EFFECT_BUNDLES[i], region:name());
	end

	cm:apply_effect_bundle_to_region("mk_bundle_population_bundle_region", region:name(), 0);

	for i = 1, #POPULATION_SIZES do
		if (population_size > tonumber(POPULATION_SIZES[i])) then
			cm:apply_effect_bundle_to_region(POPULATION_SIZES_TO_EFFECT_BUNDLES[i], region:name(), 0);
			break;
		end
	end
end
