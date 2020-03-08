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

function HRE_Regions_Setup()
	HRE_REGIONS_IN_EMPIRE = {};

	for i = 1, #HRE_REGIONS do
		local region_name = HRE_REGIONS[i];

		if HasValue(FACTIONS_HRE, cm:model():world():region_manager():region_by_key(region_name):owning_faction():name()) then
			table.insert(HRE_REGIONS_IN_EMPIRE, region_name);
		end
	end
end

function HRE_Check_Regions_In_Empire()
	local regions_in_empire = {};

	for i = 1, #HRE_REGIONS do
		local region_name = HRE_REGIONS[i];

		if HasValue(FACTIONS_HRE, cm:model():world():region_manager():region_by_key(region_name):owning_faction():name()) then
			table.insert(regions_in_empire, region_name);

			if not HasValue(HRE_REGIONS_IN_EMPIRE, region_name) then
				HRE_Region_Reconquered(region_name);
			end
		end
	end

	for i = 1, #HRE_REGIONS_IN_EMPIRE do
		local region_name =  HRE_REGIONS_IN_EMPIRE[i];

		if not HasValue(regions_in_empire, region_name) then
			HRE_Region_Lost(region_name);
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
	elseif HasValue(FACTIONS_HRE, faction_name) then
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
	elseif HasValue(FACTIONS_HRE, faction_name) then
		cm:show_message_event(
			faction_name,
			"message_event_text_text_mk_event_hre_region_lost_title",
			"regions_onscreen_"..region_name,
			"message_event_text_text_mk_event_hre_region_lost_secondary_member",
			true, 
			703
		);
	end

	HRE_Change_Imperial_Authority(HRE_REGION_LOST_AUTHORITY_LOSS);
end