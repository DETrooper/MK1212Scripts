--------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: HOLY ROMAN EMPIRE REGIONS
-- 	By: DETrooper
--
--------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------
-- Keeps track of the HRE's regions.

HRE_REGION_RECONQUERED_AUTHORITY_GAIN = 10; -- Imperial Authority gained if a region is reconquered into the HRE.
HRE_REGION_LOST_AUTHORITY_LOSS = 15; -- Imperial Authority lost if an imperial region is lost to an outside power.

HRE_REGIONS_IN_EMPIRE = {};
HRE_REGIONS_OWNERS = {};
HRE_REGIONS_UNLAWFUL_TERRITORY = {};

HRE_UNLAWFUL_TERRITORY_DURATION = 10;

function Add_HRE_Region_Listeners()
	cm:add_listener(
		"FactionTurnStart_HRE_Regions",
		"FactionTurnStart",
		true,
		function(context) FactionTurnStart_HRE_Regions(context) end,
		true
	);

	if cm:is_new_game() then
		for i = 1, #HRE_REGIONS do
			local region_name = HRE_REGIONS[i];
			local region_owning_faction_name = cm:model():world():region_manager():region_by_key(region_name):owning_faction():name();

			if HasValue(HRE_FACTIONS, region_owning_faction_name) then
				table.insert(HRE_REGIONS_IN_EMPIRE, region_name);
			end

			if region_name ~= HRE_FRANKFURT_KEY then
				HRE_REGIONS_OWNERS[region_name] = region_owning_faction_name;
			end
		end
	end
end

function FactionTurnStart_HRE_Regions(context)
	if not HRE_DESTROYED then
		if context:faction():is_human() then
			HRE_Check_Regions_In_Empire();
		end
	end
end

function HRE_Check_Regions_In_Empire()
	local regions_in_empire = {};
	local factions_to_regions_in_empire = {};

	for i = 1, #HRE_FACTIONS do
		HRE_Remove_Imperial_Expansion_Effect_Bundles(HRE_FACTIONS[i]);
	end

	for i = 1, #HRE_REGIONS do
		local region_name = HRE_REGIONS[i];
		local region_owning_faction_name = cm:model():world():region_manager():region_by_key(region_name):owning_faction():name();

		if HasValue(HRE_FACTIONS, region_owning_faction_name) then
			table.insert(regions_in_empire, region_name);

			if region_name ~= HRE_FRANKFURT_KEY then
				if factions_to_regions_in_empire[region_owning_faction_name] == nil then
					factions_to_regions_in_empire[region_owning_faction_name] = {};
				end

				table.insert(factions_to_regions_in_empire[region_owning_faction_name], region_name);
			end

			if not HasValue(HRE_REGIONS_IN_EMPIRE, region_name) then
				HRE_Region_Reconquered(region_name);
			end
		end

		HRE_REGIONS_OWNERS[region_name] = region_owning_faction_name;
	end

	for i = 1, #HRE_REGIONS_IN_EMPIRE do
		local region_name =  HRE_REGIONS_IN_EMPIRE[i];

		if not HasValue(regions_in_empire, region_name) then
			HRE_Region_Lost(region_name);
		end
	end

	for k, v in pairs(factions_to_regions_in_empire) do
		if #v > 3 then
			if #v == #HRE_REGIONS - 1 then
				cm:apply_effect_bundle("mk_effect_bundle_hre_imperial_expansionism_"..tostring(#v - 1), k, 0);
			else
				cm:apply_effect_bundle("mk_effect_bundle_hre_imperial_expansionism_"..tostring(#v), k, 0);
			end
		end
	end

	HRE_REGIONS_IN_EMPIRE = regions_in_empire;
end

function HRE_Region_Reconquered(region_name)
	local faction_name = cm:get_local_faction();

	if faction_name == HRE_EMPEROR_KEY then
		cm:show_message_event(
			faction_name,
			"message_event_text_text_mk_event_hre_region_reconquered_title",
			"regions_onscreen_"..region_name,
			"message_event_text_text_mk_event_hre_region_reconquered_secondary_emperor",
			true, 
			728
		);
	elseif HasValue(HRE_FACTIONS, faction_name) then
		cm:show_message_event(
			faction_name,
			"message_event_text_text_mk_event_hre_region_reconquered_title",
			"regions_onscreen_"..region_name,
			"message_event_text_text_mk_event_hre_region_reconquered_secondary_member",
			true, 
			728
		);
	end

	HRE_Change_Imperial_Authority(HRE_REGION_RECONQUERED_AUTHORITY_GAIN);
end

function HRE_Region_Lost(region_name)
	local faction_name = cm:get_local_faction();

	if faction_name == HRE_EMPEROR_KEY then
		cm:show_message_event(
			faction_name,
			"message_event_text_text_mk_event_hre_region_lost_title",
			"regions_onscreen_"..region_name,
			"message_event_text_text_mk_event_hre_region_lost_secondary_emperor",
			true, 
			703
		);
	elseif HasValue(HRE_FACTIONS, faction_name) then
		cm:show_message_event(
			faction_name,
			"message_event_text_text_mk_event_hre_region_lost_title",
			"regions_onscreen_"..region_name,
			"message_event_text_text_mk_event_hre_region_lost_secondary_member",
			true, 
			703
		);
	end

	HRE_Change_Imperial_Authority(-HRE_REGION_LOST_AUTHORITY_LOSS);
end

function HRE_Remove_Imperial_Expansion_Effect_Bundles(faction_name)
	for i = 4, #HRE_REGIONS - 1 do
		cm:remove_effect_bundle("mk_effect_bundle_hre_imperial_expansionism_"..tostring(i), faction_name);
	end
end

function HRE_Issue_Unlawful_Territory_Ultimatum(region_name)
	local region_owning_faction = cm:model():world():region_manager():region_by_key(region_name):owning_faction();

	if region_owning_faction:is_human() then
		cm:show_message_event(
			region_owning_faction:name(),
			"message_event_text_text_mk_event_hre_unlawful_territory_title",
			"regions_onscreen_"..region_name,
			"message_event_text_text_mk_event_hre_unlawful_territory_secondary",
			true, 
			703
		);		
	end

	cm:apply_effect_bundle_to_region("mk_effect_bundle_unlawful_territory", region_name, HRE_UNLAWFUL_TERRITORY_DURATION);
end

function HRE_Remove_Unlawful_Territory_Effect_Bundles(faction_name)
	local region_list = cm:model():world():faction_by_key(faction_name):region_list();

	if region_list:num_items() > 0 then
		for i = 0, region_list:num_items() - 1 do
			local region = region_list:item_at(i);

			cm:remove_effect_bundle_from_region("mk_effect_bundle_unlawful_territory", region:name());
		end
	end
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		SaveTable(context, HRE_REGIONS_IN_EMPIRE, "HRE_REGIONS_IN_EMPIRE");
		SaveTable(context, HRE_REGIONS_UNLAWFUL_TERRITORY, "HRE_REGIONS_UNLAWFUL_TERRITORY");
		SaveKeyPairTable(context, HRE_REGIONS_OWNERS, "HRE_REGIONS_OWNERS");
	end
);

cm:register_loading_game_callback(
	function(context)
		HRE_REGIONS_IN_EMPIRE = LoadTable(context, "HRE_REGIONS_IN_EMPIRE");
		HRE_REGIONS_UNLAWFUL_TERRITORY = LoadTable(context, "HRE_REGIONS_UNLAWFUL_TERRITORY");
		HRE_REGIONS_OWNERS = LoadKeyPairTable(context, "HRE_REGIONS_OWNERS");
	end
);
