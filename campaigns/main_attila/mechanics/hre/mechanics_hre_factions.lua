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
	cm:add_listener(
		"FactionBecomesLiberationVassal_HRE",
		"FactionBecomesLiberationVassal",
		true,
		function(context) FactionBecomesLiberationVassal_HRE(context) end,
		true
	);
	cm:add_listener(
		"TimeTrigger_HRE_Vassal",
		"TimeTrigger",
		true,
		function(context) TimeTrigger_HRE_Vassal(context) end,
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

function FactionTurnStart_HRE_Factions(context)
	if context:faction():name() == HRE_EMPEROR_KEY then
		local hre = cm:model():world():faction_by_key(HRE_EMPEROR_KEY);
		local faction_list = cm:model():world():faction_list();
		local turn_number = cm:model():turn_number();

		for i = 0, faction_list:num_items() - 1 do
			local current_faction = faction_list:item_at(i);

			if current_faction:name() ~= HRE_EMPEROR_KEY and FACTIONS_HRE[current_faction:name()] ~= nil then
				local faction = cm:model():world():faction_by_key(current_faction:name());
				local now_at_war = faction:at_war_with(hre);

				if now_at_war == true then
					-- War with HRE! Remove from FACTIONS_HRE list if in there!
					Remove_From_HRE(current_faction:name());
				end

				if not current_faction:region_list():num_items() > 0 then
					Remove_From_HRE(current_faction:name());
				end
			end
		end
	end
end

function FactionBecomesLiberationVassal_HRE(context)
	if context:liberating_character():faction():name() == HRE_EMPEROR_KEY then
		local faction_name = context:liberating_character():faction():name();
		dev.log("Adding faction to HRE: "..faction_name);
		table.insert(FACTIONS_HRE, faction_name);
		dev.log("Faction added!");
		cm:add_time_trigger("liberation_check", 0.1);
	end
end

function TimeTrigger_HRE_Vassal(context)
	if context.string == "liberation_check" then
		local hre = cm:model():world():faction_by_key(HRE_EMPEROR_KEY);
		local liberated_faction = cm:model():world():faction_by_key(FACTIONS_HRE[#FACTIONS_HRE]);
		local is_ally = hre:allied_with(liberated_faction);
			
		if is_ally == true then
			-- They were allied after liberation so we should make them a vassal by force!
			cm:force_make_vassal(HRE_EMPEROR_KEY, liberated_faction);
		end
	end
end

function Remove_From_HRE(faction_name)
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