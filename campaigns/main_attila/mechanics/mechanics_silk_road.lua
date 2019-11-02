------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: SILK ROAD
-- 	By: DETrooper
--
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------

SPICE_REGIONS = {
	"att_reg_aethiopia_adulis",
	"att_reg_arabia_felix_eudaemon",
	"att_reg_arabia_felix_omana",
	"att_reg_asorstan_meshan",
	"att_reg_makran_harmosia"
};

function Add_Silk_Road_Listeners()
	cm:add_listener(
		"FactionTurnStart_Silk_Road",
		"FactionTurnStart",
		true,
		function(context) FactionTurnStart_Silk_Road(context) end,
		true
	);

	local faction_name = FACTION_TURN;
	local faction = cm:model():world():faction_by_key(faction_name);

	--Check_Silk_Trade(faction);
	Check_Spice_Ports(faction);
end

function FactionTurnStart_Silk_Road(context)
	--Check_Silk_Trade(context:faction());
	Check_Spice_Ports(context:faction());
end

function Check_Spice_Ports(faction)
	local spice_owned = 0;
	local regions = faction:region_list();
	
	for i = 0, regions:num_items() - 1 do
		local region = regions:item_at(i);
		
		for s = 1, #SPICE_REGIONS do
			if region:name() == SPICE_REGIONS[s] then
				spice_owned = spice_owned + 1;
			end
		end
	end

	for i = 1, 5 do
		cm:remove_effect_bundle("mk_bundle_spice_trade_"..i, faction:name());
	end
	
	if spice_owned ~= 0 then
		cm:apply_effect_bundle("mk_bundle_spice_trade_"..spice_owned, faction:name(), 0);
	end
end