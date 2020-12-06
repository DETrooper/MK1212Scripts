--------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: HOLY ROMAN EMPIRE DECREES
-- 	By: DETrooper
--
--------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------
-- System for the HRE's emperor to pass decrees with various boons and drawbacks for themself and the empire at large.

HRE_ACTIVE_DECREE = "nil";
HRE_ACTIVE_DECREE_TURNS_LEFT = 0;
HRE_DECREE_DURATION = 15;

HRE_DECREES = {
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

function Add_HRE_Decrees_Listeners()
	cm:add_listener(
		"FactionTurnStart_HRE_Decrees",
		"FactionTurnStart",
		true,
		function(context) FactionTurnStart_HRE_Decrees(context) end,
		true
	);
end

function FactionTurnStart_HRE_Decrees(context)
	local turn_number = cm:model():turn_number();

	if HRE_Get_Faction_State(context:faction():name()) == "emperor" then
		if HRE_ACTIVE_DECREE_TURNS_LEFT > 0 then
			HRE_ACTIVE_DECREE_TURNS_LEFT = HRE_ACTIVE_DECREE_TURNS_LEFT - 1;

			if HRE_ACTIVE_DECREE_TURNS_LEFT == 0 then
				HRE_ACTIVE_DECREE = "nil";
			end
		end

		if not context:faction():is_human() then
			if HRE_ACTIVE_DECREE == "nil" then 
				local random_decree = HRE_DECREES[cm:random_number(#HRE_DECREES)];

				if HRE_IMPERIAL_AUTHORITY >= random_decree["cost"] then
					Activate_Decree(random_decree["key"]);
				end
			end
		end
	end
end

function Activate_Decree(decree_key)
	for i = 1, #HRE_DECREES do
		if HRE_DECREES[i]["key"] == decree_key then
			Apply_Decree_Effect_Bundle(HRE_DECREES[i]["emperor_effect_bundle_key"], HRE_DECREES[i]["member_effect_bundle_key"]);

			HRE_IMPERIAL_AUTHORITY = HRE_IMPERIAL_AUTHORITY - HRE_DECREES[i]["cost"];
			HRE_ACTIVE_DECREE = decree_key;
			HRE_ACTIVE_DECREE_TURNS_LEFT = HRE_DECREE_DURATION;

			if HasValue(HRE_FACTIONS, cm:get_local_faction()) then
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

function Deactivate_Decree(decree_key)
	for i = 1, #HRE_DECREES do
		if HRE_DECREES[i]["key"] == decree_key then
			if HRE_DECREES[i]["emperor_effect_bundle_key"] ~= "none" then
				cm:remove_effect_bundle(HRE_DECREES[i]["member_effect_bundle_key"], HRE_EMPEROR_KEY);
			end

			if HRE_DECREES[i]["member_effect_bundle_key"] ~= "none" then
				for j = 1, #HRE_FACTIONS do
					local faction_name = HRE_FACTIONS[j];

					cm:remove_effect_bundle(HRE_DECREES[i]["member_effect_bundle_key"], faction_name);
				end
			end

			HRE_ACTIVE_DECREE = "nil";
			HRE_ACTIVE_DECREE_TURNS_LEFT = 0;

			break;
		end
	end

	-- Some decrees increase population growth, so re-compute region growth.
	Refresh_Region_Growths_Population(true);
end

function Get_Decree_Property(decree_key, decree_property)
	for i = 1, #HRE_DECREES do
		if HRE_DECREES[i]["key"] == decree_key and HRE_DECREES[i][decree_property]  then
			return HRE_DECREES[i][decree_property];
		end
	end
end

function Apply_Decree_Effect_Bundle(emperor_effect_bundle_key, member_effect_bundle_key)
	for i = 1, #HRE_FACTIONS do
		local faction_name = HRE_FACTIONS[i];

		if HRE_Get_Faction_State(faction_name) == "emperor" then
			cm:apply_effect_bundle(emperor_effect_bundle_key, faction_name, HRE_DECREE_DURATION);
		else
			cm:apply_effect_bundle(member_effect_bundle_key, faction_name, HRE_DECREE_DURATION);
		end
	end
end

function Get_Decree_Tooltip(decree_key)
	local decreestring = "";

	for i = 1, #HRE_DECREES do
		if HRE_DECREES[i]["key"] == decree_key then
			local decree_name = HRE_DECREES[i]["name"];
			local decree_cost = tostring(HRE_DECREES[i]["cost"]);

			decreestring = decree_name.."\n----------------------------------------------\nEffects for the emperor:";

			for j = 1, #HRE_DECREES[i]["emperor_effects"] do
				decreestring = decreestring.."\n"..HRE_DECREES[i]["emperor_effects"][j];
			end

			decreestring = decreestring.."\n\nEffects for member-states:";

			for j = 1, #HRE_DECREES[i]["member_effects"] do
				decreestring = decreestring.."\n"..HRE_DECREES[i]["member_effects"][j];
			end

			decreestring = decreestring.."\n\nThis decree will cost "..decree_cost.." Imperial Authority to enact, and will last for "..tostring(HRE_DECREE_DURATION).." turns.";
		end
	end

	return decreestring;
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		cm:save_value("HRE_ACTIVE_DECREE", HRE_ACTIVE_DECREE, context);
		cm:save_value("HRE_ACTIVE_DECREE_TURNS_LEFT", HRE_ACTIVE_DECREE_TURNS_LEFT, context);
	end
);

cm:register_loading_game_callback(
	function(context)
		HRE_ACTIVE_DECREE = cm:load_value("HRE_ACTIVE_DECREE", "nil", context);
		HRE_ACTIVE_DECREE_TURNS_LEFT = cm:load_value("HRE_ACTIVE_DECREE_TURNS_LEFT", 0, context);
	end
);
