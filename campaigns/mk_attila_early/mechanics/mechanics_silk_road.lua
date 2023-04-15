------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: SILK ROAD
-- 	By: DETrooper
--
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------

SPICE_REGIONS = {
	"mk_reg_aden",
	"mk_reg_bahla",
	"mk_reg_basra",
	"mk_reg_hormuz",
	"mk_reg_massawa"
};

function Add_Silk_Road_Listeners()
	cm:add_listener(
		"FactionTurnStart_Silk_Road",
		"FactionTurnStart",
		true,
		function(context) FactionTurnStart_Silk_Road(context) end,
		true
	);

	if cm:is_new_game() then
		local faction_name = FACTION_TURN;
		local faction = cm:model():world():faction_by_key(faction_name);

		--Check_Silk_Trade(faction);
		Check_Spice_Ports(faction);
	end
end

function FactionTurnStart_Silk_Road(context)
	--Check_Silk_Trade(context:faction());
	Check_Spice_Ports(context:faction());
end

function Check_Spice_Ports(faction)
	local num_spice_regions = #SPICE_REGIONS;
	local spice_owned = 0;
	local faction_name = faction:name();
	local faction_regions = faction:region_list();
	
	for i = 0, faction_regions:num_items() - 1 do
		local region = faction_regions:item_at(i);
		
		if table.HasValue(SPICE_REGIONS, region:name()) then
			spice_owned = spice_owned + 1;
		end
	end

	for i = 1, num_spice_regions do
		cm:remove_effect_bundle("mk_bundle_spice_trade_"..i, faction_name);
	end
	
	if spice_owned > 0 then
		cm:apply_effect_bundle("mk_bundle_spice_trade_"..spice_owned, faction_name, 0);

		if spice_owned == num_spice_regions then
			Unlock_Achievement("achievement_the_spice_must_flow");
		end
	end
end
