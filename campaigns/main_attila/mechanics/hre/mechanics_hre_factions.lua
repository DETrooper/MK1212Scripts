---------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: HOLY ROMAN EMPIRE FACTIONS
-- 	By: DETrooper
--
---------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
-- Keeps track of which factions are in the HRE, and which faction is the emperor.

FACTIONS_HRE = {};
FACTIONS_HRE_FEALTY = {};
MAX_FEALTY = 10;
MIN_FEALTY = 0;
HRE_EMPEROR_KEY = "mk_fact_hre";
HRE_EMPEROR_PRETENDER_KEY = "mk_fact_sicily";

local dev = require("lua_scripts.dev");

function Add_HRE_Faction_Listeners()
	cm:add_listener(
		"FactionTurnStart_HRE_Factions",
		"FactionTurnStart",
		true,
		function(context) FactionTurnStart_HRE_Factions(context) end,
		true
	);

	if cm:is_new_game() then
		local faction_list = cm:model():world():faction_list();

		for i = 0, faction_list:num_items() - 1 do
			local current_faction = faction_list:item_at(i);

			for j = 1, #FACTIONS_HRE_START do
				if current_faction:name() == FACTIONS_HRE_START[j] then
					table.insert(FACTIONS_HRE, current_faction:name());
					FACTIONS_HRE_FEALTY[current_faction:name()] = 5;
					break;
				end
			end
		end
	end
end

function FactionTurnStart_HRE_Factions(context)
	if context:faction():name() == HRE_EMPEROR_KEY then
		local faction_list = cm:model():world():faction_list();
		local turn_number = cm:model():turn_number();

		for i = 0, faction_list:num_items() - 1 do
			local current_faction = faction_list:item_at(i);

			if current_faction:name() ~= HRE_EMPEROR_KEY and FACTIONS_HRE[current_faction:name()] ~= nil then
				HRE_Fealty_Check(current_faction:name());
			end
		end
	end
end

function HRE_Fealty_Check(faction_name)

end

function HRE_Replace_Emperor(faction_name)
	local faction_list = cm:model():world():faction_list();
	local turn_number = cm:model():turn_number();

	if cm:model():world():faction_by_key(HRE_EMPEROR_KEY):region_list():num_items() > 0 then
		cm:grant_faction_handover(faction_name, HRE_EMPEROR_KEY, turn_number-1, turn_number-1, context);
	end

	cm:set_faction_name_override(faction_name, "campaign_localised_strings_string_mk_faction_holy_roman_empire");
	HRE_EMPEROR_KEY = faction_name;

	for i = 0, faction_list:num_items() - 1 do
		local current_faction = faction_list:item_at(i);

		if current_faction:name() ~= HRE_EMPEROR_KEY and FACTIONS_HRE[current_faction:name()] ~= nil then
			cm:grant_faction_handover(HRE_EMPEROR_KEY, current_faction:name(), turn_number-1, turn_number-1, context);
		end
	end
end

function HRE_Increase_Fealty(faction_name, amount, reason)
	if FACTIONS_HRE_FEALTY[faction_name] == nil then
		FACTIONS_HRE_FEALTY[faction_name] = 5 + amount;
		FACTIONS_HRE_FEALTY[faction_name] = math.max(FACTIONS_HRE_FEALTY[faction_name], MIN_FEALTY);
		FACTIONS_HRE_FEALTY[faction_name] = math.min(FACTIONS_HRE_FEALTY[faction_name], MAX_FEALTY);
	else
		FACTIONS_HRE_FEALTY[faction_name] = FACTIONS_HRE_FEALTY[faction_name] + amount;
		FACTIONS_HRE_FEALTY[faction_name] = math.max(FACTIONS_HRE_FEALTY[faction_name], MIN_FEALTY);
		FACTIONS_HRE_FEALTY[faction_name] = math.min(FACTIONS_HRE_FEALTY[faction_name], MAX_FEALTY);
	end

	cm:show_message_event(
		HRE_EMPEROR_KEY,
		"message_event_text_text_mk_event_hre_fealty_increase_title",
		"campaign_localised_strings_string_"..faction_name.."_lvl"..tostring(FACTIONS_DFN_LEVEL[faction_name]),
		"message_event_text_text_mk_event_hre_fealty_increase_secondary_"..reason,
		true, 
		704
	);
end

function HRE_Decrease_Fealty(faction_name, amount, reason)
	if FACTIONS_HRE_FEALTY[faction_name] == nil then
		FACTIONS_HRE_FEALTY[faction_name] = 5 - amount;
		FACTIONS_HRE_FEALTY[faction_name] = math.max(FACTIONS_HRE_FEALTY[faction_name], MIN_FEALTY);
		FACTIONS_HRE_FEALTY[faction_name] = math.min(FACTIONS_HRE_FEALTY[faction_name], MAX_FEALTY);
	else
		FACTIONS_HRE_FEALTY[faction_name] = FACTIONS_HRE_FEALTY[faction_name] - amount;
		FACTIONS_HRE_FEALTY[faction_name] = math.max(FACTIONS_HRE_FEALTY[faction_name], MIN_FEALTY);
		FACTIONS_HRE_FEALTY[faction_name] = math.min(FACTIONS_HRE_FEALTY[faction_name], MAX_FEALTY);
	end

	cm:show_message_event(
		HRE_EMPEROR_KEY,
		"message_event_text_text_mk_event_hre_fealty_decrease_title",
		"campaign_localised_strings_string_"..faction_name.."_lvl"..tostring(FACTIONS_DFN_LEVEL[faction_name]),
		"message_event_text_text_mk_event_hre_fealty_decrease_secondary_"..reason,
		true, 
		704
	);
end

function HRE_Remove_From_Empire(faction_name)
	for i = 1, #FACTIONS_HRE do
		if FACTIONS_HRE[i] == faction_name then
			dev.log("Removing faction from HRE: "..FACTIONS_HRE[i]);
			table.remove(FACTIONS_HRE, i);
			dev.log("Faction removed from the HRE.");
		end	
	end
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		SaveTable(context, FACTIONS_HRE, "FACTIONS_HRE");
		SaveKeyPairTable(context, FACTIONS_HRE_FEALTY, "FACTIONS_HRE_FEALTY");
		cm:save_value("HRE_EMPEROR_KEY", HRE_EMPEROR_KEY, context);
		cm:save_value("HRE_EMPEROR_PRETENDER_KEY", HRE_EMPEROR_PRETENDER_KEY, context);
	end
);

cm:register_loading_game_callback(
	function(context)
		FACTIONS_HRE = LoadTable(context, "FACTIONS_HRE");
		FACTIONS_HRE_FEALTY = LoadKeyPairTableNumbers(context, "FACTIONS_HRE_FEALTY");
		HRE_EMPEROR_KEY = cm:load_value("HRE_EMPEROR_KEY", "mk_fact_hre", context);
		HRE_EMPEROR_PRETENDER_KEY = cm:load_value("HRE_EMPEROR_PRETENDER_KEY", "mk_fact_sicily", context);
	end
);