--------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: HOLY ROMAN EMPIRE REGIONS
-- 	By: DETrooper
--
--------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------
-- Keeps track of the HRE's regions.

local hre_region_reconquered_authority_gain = 10; -- Imperial Authority gained if a region is reconquered into the HRE.
local hre_region_lost_authority_loss = 15; -- Imperial Authority lost if an imperial region is lost to an outside power.
local hre_unlawful_territory_duration = 10;

mkHRE.regions_in_empire = {};
mkHRE.regions_owners = {};
mkHRE.regions_unlawful_territory = {};

function mkHRE:Add_Region_Listeners()
	cm:add_listener(
		"FactionTurnStart_HRE_Regions",
		"FactionTurnStart",
		true,
		function(context) FactionTurnStart_HRE_Regions(context) end,
		true
	);

	if cm:is_new_game() then
		for i = 1, #self.regions do
			local region_name = self.regions[i];
			local region_owning_faction_name = cm:model():world():region_manager():region_by_key(region_name):owning_faction():name();

			if HasValue(self.factions, region_owning_faction_name) then
				table.insert(self.regions_in_empire, region_name);
			end

			if region_name ~= self.frankfurt_region_key then
				self.regions_owners[region_name] = region_owning_faction_name;
			end
		end
	end
end

function FactionTurnStart_HRE_Regions(context)
	if not mkHRE.destroyed and mkHRE.current_reform < 9 then
		if context:faction():is_human() then
			mkHRE:Check_Regions_In_Empire();
		end
	end
end

function mkHRE:Check_Regions_In_Empire()
    -- First remove any existing expansion effect bundles
    for i = 1, #self.factions do
        self:Remove_Imperial_Expansion_Effect_Bundles(self.factions[i])
    end

    -- If HRE is destroyed or fully unified (reform 9), don't reapply the effects
    if self.destroyed or self.current_reform == 9 then
        return
    end

    -- Track regions and their owners
    local regions_in_empire = {}
    local factions_to_regions_in_empire = {}
    
    -- Check each HRE region
    for i = 1, #self.regions do
        local region_name = self.regions[i]
        local region_owning_faction_name = cm:model():world():region_manager():region_by_key(region_name):owning_faction():name()
        
        if HasValue(self.factions, region_owning_faction_name) then
            table.insert(regions_in_empire, region_name)
            
            -- Don't count Frankfurt for the expansionism effect
            if region_name ~= self.frankfurt_region_key then
                if not factions_to_regions_in_empire[region_owning_faction_name] then
                    factions_to_regions_in_empire[region_owning_faction_name] = {}
                end
                table.insert(factions_to_regions_in_empire[region_owning_faction_name], region_name)
            end
            
            -- Handle region reconquest
            if not HasValue(self.regions_in_empire, region_name) then
                self:Region_Reconquered(region_name)
            end
        end
        
        -- Update region ownership tracking
        self.regions_owners[region_name] = region_owning_faction_name
    end
    
    -- Check for lost regions
    for i = 1, #self.regions_in_empire do
        local region_name = self.regions_in_empire[i]
        if not HasValue(regions_in_empire, region_name) then
            self:Region_Lost(region_name)
        end
    end
    
    -- Apply expansionism debuff based on region count
    for faction_name, faction_regions in pairs(factions_to_regions_in_empire) do
        if #faction_regions > 3 then
            if #faction_regions == #self.regions - 1 then
            cm:apply_effect_bundle("mk_effect_bundle_hre_imperial_expansionism_"..tostring(#faction_regions - 1), faction_name, 0);
            else
            cm:apply_effect_bundle("mk_effect_bundle_hre_imperial_expansionism_"..tostring(#faction_regions), faction_name, 0);
            end
        end
    end
    
    -- Update stored region list
    self.regions_in_empire = regions_in_empire
end

function mkHRE:Region_Reconquered(region_name)
	local faction_name = cm:get_local_faction();

	if faction_name == self.emperor_key then
		cm:show_message_event(
			faction_name,
			"message_event_text_text_mk_event_hre_region_reconquered_title",
			"regions_onscreen_"..region_name,
			"message_event_text_text_mk_event_hre_region_reconquered_secondary_emperor",
			true, 
			728
		);
	elseif HasValue(self.factions, faction_name) then
		cm:show_message_event(
			faction_name,
			"message_event_text_text_mk_event_hre_region_reconquered_title",
			"regions_onscreen_"..region_name,
			"message_event_text_text_mk_event_hre_region_reconquered_secondary_member",
			true, 
			728
		);
	end

	self:Change_Imperial_Authority(hre_region_reconquered_authority_gain);
end

function mkHRE:Region_Lost(region_name)
	local faction_name = cm:get_local_faction();

	if faction_name == self.emperor_key then
		cm:show_message_event(
			faction_name,
			"message_event_text_text_mk_event_hre_region_lost_title",
			"regions_onscreen_"..region_name,
			"message_event_text_text_mk_event_hre_region_lost_secondary_emperor",
			true, 
			703
		);
	elseif HasValue(self.factions, faction_name) then
		cm:show_message_event(
			faction_name,
			"message_event_text_text_mk_event_hre_region_lost_title",
			"regions_onscreen_"..region_name,
			"message_event_text_text_mk_event_hre_region_lost_secondary_member",
			true, 
			703
		);
	end

	self:Change_Imperial_Authority(-hre_region_lost_authority_loss);
end

function mkHRE:Remove_Imperial_Expansion_Effect_Bundles(faction_name)
	for i = 4, #self.regions - 1 do
		cm:remove_effect_bundle("mk_effect_bundle_hre_imperial_expansionism_"..tostring(i), faction_name);
	end
end

function mkHRE:Issue_Unlawful_Territory_Ultimatum(region_name)
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

	cm:apply_effect_bundle_to_region("mk_effect_bundle_unlawful_territory", region_name, hre_unlawful_territory_duration);
end

function mkHRE:Remove_Unlawful_Territory_Effect_Bundles(faction_name)
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
		SaveTable(context, mkHRE.regions_in_empire, "mkHRE.regions_in_empire");
		SaveTable(context, mkHRE.regions_unlawful_territory, "mkHRE.regions_unlawful_territory");
		SaveKeyPairTable(context, mkHRE.regions_owners, "mkHRE.regions_owners");
	end
);

cm:register_loading_game_callback(
	function(context)
		mkHRE.regions_in_empire = LoadTable(context, "mkHRE.regions_in_empire");
		mkHRE.regions_unlawful_territory = LoadTable(context, "mkHRE.regions_unlawful_territory");
		mkHRE.regions_owners = LoadKeyPairTable(context, "mkHRE.regions_owners");
	end
);