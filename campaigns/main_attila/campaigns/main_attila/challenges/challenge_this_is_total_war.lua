-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - CHALLENGES: THIS IS TOTAL WAR
-- 	By: DETrooper
--
-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

function Add_Challenge_This_Is_Total_War_Listeners()
	cm:add_listener(
		"FactionTurnStart_This_Is_Total_War",
		"FactionTurnStart",
		true,
		function(context) FactionTurnStart_This_Is_Total_War(context) end,
		true
	);
	cm:add_listener(
		"FactionTurnEnd_This_Is_Total_War",
		"FactionTurnStart",
		true,
		function(context) FactionTurnEnd_This_Is_Total_War(context) end,
		true
	);
	cm:add_listener(
		"FactionEncountersOtherFaction_This_Is_Total_War",
		"FactionEncountersOtherFaction",
		true,
		function(context) FactionEncountersOtherFaction_This_Is_Total_War(context) end,
		true
	);

	if cm:is_new_game() then
		Force_Stop_Papal_Favour_System();

		local faction_list = cm:model():world():faction_list();

		for i = 0, faction_list:num_items() - 1 do
			if faction_list:item_at(i):is_human() then
				War_Check_This_Is_Total_War(faction_list:item_at(i));
			end
		end
	end

	STORY_EVENTS_ENABLED = false;
	WarWearinessNerf();

	ui_state.diplomacy:set_allowed(false, true);
	ui_state.subjugation_button:set_allowed(false, true);
end

function FactionTurnStart_This_Is_Total_War(context)
	if context:faction():is_human() then
		War_Check_This_Is_Total_War(context:faction());
	end
end

function FactionTurnEnd_This_Is_Total_War(context)
	if context:faction():is_human() then
		War_Check_This_Is_Total_War(context:faction());
	end

end

function FactionEncountersOtherFaction_This_Is_Total_War(context)
	if not cm:is_new_game() then
		if context:faction():name() == FACTION_TURN and context:faction():is_human() then
			War_Check_This_Is_Total_War(context:faction());
		elseif context:other_faction():name() == FACTION_TURN and context:other_faction():is_human() then
			War_Check_This_Is_Total_War(context:other_faction());
		end
	end
end

function War_Check_This_Is_Total_War(faction)
	local faction_list = cm:model():world():faction_list();

	for i = 0, faction_list:num_items() - 1 do
		local other_faction = faction_list:item_at(i);

		if other_faction:is_human() == false and other_faction:has_faction_leader() then
			if other_faction:at_war_with(faction) == false then
				cm:force_declare_war(faction:name(), other_faction:name());

				for j = 1, #DIPLOMACY_OPTIONS do
					if DIPLOMACY_OPTIONS[j] ~= "war" then
						cm:force_diplomacy(faction:name(), other_faction:name(), DIPLOMACY_OPTIONS[j], false, false);
						cm:force_diplomacy(other_faction:name(), faction:name(), DIPLOMACY_OPTIONS[j], false, false);
					end
				end
			end
		end
	end
end