----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
--
-- 	PRETENDER CRASH STOPGAP MEASURE
--
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
-- For some reason some pretenders with only 1 region left crash, so this should prevent that by gifting their 1 region away and killing all their characters.

FACTIONS_CAUSING_CRASHING = {
	"mk_fact_separatists_cumans",
	"mk_fact_separatists_goldenhorde",
	"mk_fact_separatists_ilkhanate"
};

FACTIONS_CAUSING_CRASHING_ALT_FACTIONS = {
	"mk_fact_cumans",
	"mk_fact_goldenhorde",
	"mk_fact_ilkhanate"
};

function Add_Stopgap_Listeners()
	cm:add_listener(
		"FactionTurnStart_Stopgap",
		"FactionTurnStart",
		true,
		function(context) FactionTurnStart_Stopgap(context) end,
		true
	);
	cm:add_listener(
		"FactionTurnEnd_Stopgap",
		"FactionTurnEnd",
		true,
		function(context) FactionTurnEnd_Stopgap(context) end,
		true
	);

	Check_Pretender_Factions_Stopgap();
end

function FactionTurnStart_Stopgap(context)
	if context:faction():is_human() then
		Check_Pretender_Factions_Stopgap();
	else
		for i = 1, #FACTIONS_CAUSING_CRASHING do
			if context:faction():name() == FACTIONS_CAUSING_CRASHING[i] then
				Check_Pretender_Factions_Stopgap();
			end
		end
	end
end

function FactionTurnEnd_Stopgap(context)
	if context:faction():is_human() then
		Check_Pretender_Factions_Stopgap();
	end
end

function Check_Pretender_Factions_Stopgap()
	for i = 1, #FACTIONS_CAUSING_CRASHING do
		local faction = cm:model():world():faction_by_key(FACTIONS_CAUSING_CRASHING[i]);

		if faction:region_list():num_items() > 0 or faction:military_force_list():num_items() > 0 then
			--dev.log("PURGING FACTION: "..FACTIONS_CAUSING_CRASHING[i]);
			local faction_parent = cm:model():world():faction_by_key(FACTIONS_CAUSING_CRASHING_ALT_FACTIONS[i]) 
			local region_list = faction:region_list();
			local character_list = faction:character_list();

			for k = 0, character_list:num_items() - 1 do
				local character = character_list:item_at(k);

				cm:kill_character("character_cqi:"..character:command_queue_index(), true, false);
			end

			for j = 0, region_list:num_items() - 1 do
				local region = region_list:item_at(j);

				if faction_parent:region_list():num_items() < 0 or faction_parent:military_force_list():num_items() < 0 then
					cm:transfer_region_to_faction(region:name(), FACTIONS_CAUSING_CRASHING_ALT_FACTIONS[i]);
				else			
					cm:set_region_abandoned(region:name());
				end
			end
		end
	end
end