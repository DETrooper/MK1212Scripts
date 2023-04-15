--------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: HOLY ROMAN EMPIRE DECREES
-- 	By: DETrooper
--
--------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------
-- System for the HRE's emperor to pass decrees with various boons and drawbacks for themself and the empire at large.

local hre_decree_duration = 15;

mkHRE.active_decree = "nil";
mkHRE.active_decree_turns_left = 0;
mkHRE.decrees = {
	-- Reforms are unlocked in order from first to last.
	{
		["key"] = "hre_decree_imperial_levies",
		["name"] = "Muster Imperial Levies",
		["cost"] = 15,
		["emperor_effect_bundle_key"] = "mk_effect_bundle_hre_decree_imperial_levies",
		["emperor_effects"] = {"Upkeep cost: +10% for land units", "Replenishment: +5%", "Army recruitment capacity: +1"},
		["member_effect_bundle_key"] = "mk_effect_bundle_hre_member_imperial_levies",
		["member_effects"] = {"Replenishment: +5%", "Army recruitment capacity: +1"}
	},
	{
		["key"] = "hre_decree_patronize_universities",
		["name"] = "Patronize Universities",
		["cost"] = 15,
		["emperor_effect_bundle_key"] = "mk_effect_bundle_hre_decree_patronize_universities",
		["emperor_effects"] = {"Research rate: +20%", "Agent recruit experience: +3 for priests", "Tax rate: -10%"},
		["member_effect_bundle_key"] = "mk_effect_bundle_hre_member_patronize_universities",
		["member_effects"] = {"Research rate: +20%", "Agent recruit experience: +3 for priests"}
	},
	{
		["key"] = "hre_decree_expand_bureaucracy",
		["name"] = "Expand The Bureaucracy",
		["cost"] = 15,
		["emperor_effect_bundle_key"] = "mk_effect_bundle_hre_decree_expand_bureaucracy",
		["emperor_effects"] = {"Loyalty: +2", "Corruption: +5%", "Tax rate: +15%"},
		["member_effect_bundle_key"] = "mk_effect_bundle_hre_member_expand_bureaucracy",
		["member_effects"] = {"Loyalty: +2", "Tax rate: +15%"}
	},
	{
		["key"] = "hre_decree_promote_commerce",
		["name"] = "Promote Commerce",
		["cost"] = 15,
		["emperor_effect_bundle_key"] = "mk_effect_bundle_hre_decree_promote_commerce",
		["emperor_effects"] = {"Trade income: -5% trade agreement tariffs", "Diplomatic standing: +10 with all factions", "Wealth: +25% from commercial buildings"},
		["member_effect_bundle_key"] = "mk_effect_bundle_hre_member_promote_commerce",
		["member_effects"] = {"Diplomatic standing: +10 with all factions", "Wealth: +25% from commercial buildings"}
	},
	{
		["key"] = "hre_decree_lessen_tax_burdens",
		["name"] = "Lessen Tax Burdens",
		["cost"] = 15,
		["emperor_effect_bundle_key"] = "mk_effect_bundle_hre_decree_lessen_tax_burdens",
		["emperor_effects"] = {"Population Growth: +0.5% Burgher and Peasantry Growth", "Tax rate: -15%", "Public order: +5"},
		["member_effect_bundle_key"] = "mk_effect_bundle_hre_member_lessen_tax_burdens",
		["member_effects"] = {"Population Growth: +0.5% Burgher and Peasantry Growth", "Public order: +5"}
	},
	{
		["key"] = "hre_decree_encourage_development",
		["name"] = "Encourage Development",
		["cost"] = 15,
		["emperor_effect_bundle_key"] = "mk_effect_bundle_hre_decree_encourage_development",
		["emperor_effects"] = {"Sanitation: +2", "Construction cost: -25%", "Tax rate: -15%"},
		["member_effect_bundle_key"] = "mk_effect_bundle_hre_member_encourage_development",
		["member_effects"] = {"Sanitation: +2", "Construction cost: -25%"}
	}
};

function mkHRE:Add_Decree_Listeners()
	cm:add_listener(
		"FactionTurnStart_HRE_Decrees",
		"FactionTurnStart",
		true,
		function(context) FactionTurnStart_HRE_Decrees(context) end,
		true
	);
end

function FactionTurnStart_HRE_Decrees(context)
	local faction = context:faction();
	local turn_number = cm:model():turn_number();

	if mkHRE:Get_Faction_State(faction:name()) == "emperor" then
		if mkHRE.active_decree_turns_left > 0 then
			mkHRE.active_decree_turns_left = mkHRE.active_decree_turns_left - 1;

			if mkHRE.active_decree_turns_left == 0 then
				mkHRE.active_decree = "nil";
			end
		end

		if not faction:is_human() then
			if mkHRE.active_decree == "nil" then 
				local random_decree = mkHRE.decrees[cm:random_number(#mkHRE.decrees)];

				if mkHRE.imperial_authority >= random_decree["cost"] then
					mkHRE:Activate_Decree(random_decree["key"]);
				end
			end
		end
	end
end

function mkHRE:Activate_Decree(decree_key)
	for i = 1, #mkHRE.decrees do
		if mkHRE.decrees[i]["key"] == decree_key then
			Apply_Decree_Effect_Bundle(mkHRE.decrees[i]["emperor_effect_bundle_key"], mkHRE.decrees[i]["member_effect_bundle_key"]);

			mkHRE.imperial_authority = mkHRE.imperial_authority - mkHRE.decrees[i]["cost"];
			mkHRE.active_decree = decree_key;
			mkHRE.active_decree_turns_left = hre_decree_duration;

			if table.HasValue(mkHRE.factions, cm:get_local_faction()) then
				cm:show_message_event(
					cm:get_local_faction(),
					"message_event_text_text_mk_event_hre_decree_title",
					"message_event_text_text_mk_event_hre_decree_primary_"..decree_key,
					"message_event_text_text_mk_event_hre_decree_secondary",
					true, 
					704
				);
			end

			break;
		end
	end

	-- Some decrees increase population growth, so re-compute region growth.
	Refresh_Region_Growths_Population(true);
end

function mkHRE:Deactivate_Decree(decree_key)
	for i = 1, #mkHRE.decrees do
		if mkHRE.decrees[i]["key"] == decree_key then
			if mkHRE.decrees[i]["emperor_effect_bundle_key"] ~= "none" then
				cm:remove_effect_bundle(mkHRE.decrees[i]["member_effect_bundle_key"], mkHRE.emperor_key);
			end

			if mkHRE.decrees[i]["member_effect_bundle_key"] ~= "none" then
				for j = 1, #mkHRE.factions do
					local faction_name = mkHRE.factions[j];

					cm:remove_effect_bundle(mkHRE.decrees[i]["member_effect_bundle_key"], faction_name);
				end
			end

			mkHRE.active_decree = "nil";
			mkHRE.active_decree_turns_left = 0;

			break;
		end
	end

	-- Some decrees increase population growth, so re-compute region growth.
	Refresh_Region_Growths_Population(true);
end

function Get_Decree_Property(decree_key, decree_property)
	for i = 1, #mkHRE.decrees do
		if mkHRE.decrees[i]["key"] == decree_key and mkHRE.decrees[i][decree_property]  then
			return mkHRE.decrees[i][decree_property];
		end
	end
end

function Apply_Decree_Effect_Bundle(emperor_effect_bundle_key, member_effect_bundle_key)
	for i = 1, #mkHRE.factions do
		local faction_name = mkHRE.factions[i];

		if mkHRE:Get_Faction_State(faction_name) == "emperor" then
			cm:apply_effect_bundle(emperor_effect_bundle_key, faction_name, hre_decree_duration);
		else
			cm:apply_effect_bundle(member_effect_bundle_key, faction_name, hre_decree_duration);
		end
	end
end

function Get_Decree_Tooltip(decree_key)
	local decreestring = "";

	for i = 1, #mkHRE.decrees do
		if mkHRE.decrees[i]["key"] == decree_key then
			local decree_name = mkHRE.decrees[i]["name"];
			local decree_cost = tostring(mkHRE.decrees[i]["cost"]);

			decreestring = decree_name.."\n----------------------------------------------\nEffects for the emperor:";

			for j = 1, #mkHRE.decrees[i]["emperor_effects"] do
				decreestring = decreestring.."\n"..mkHRE.decrees[i]["emperor_effects"][j];
			end

			decreestring = decreestring.."\n\nEffects for member-states:";

			for j = 1, #mkHRE.decrees[i]["member_effects"] do
				decreestring = decreestring.."\n"..mkHRE.decrees[i]["member_effects"][j];
			end

			decreestring = decreestring.."\n\nThis decree will cost "..decree_cost.." Imperial Authority to enact, and will last for "..tostring(hre_decree_duration).." turns.";
		end
	end

	return decreestring;
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		cm:save_value("mkHRE.active_decree", mkHRE.active_decree, context);
		cm:save_value("mkHRE.active_decree_turns_left", mkHRE.active_decree_turns_left, context);
	end
);

cm:register_loading_game_callback(
	function(context)
		mkHRE.active_decree = cm:load_value("mkHRE.active_decree", "nil", context);
		mkHRE.active_decree_turns_left = cm:load_value("mkHRE.active_decree_turns_left", 0, context);
	end
);
