-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - CHALLENGES: JUDGEMENT DAY
-- 	By: DETrooper
--
-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

function Add_Challenge_Judgement_Day_Listeners()
	cm:add_listener(
		"FactionTurnStart_Judgement_Day",
		"FactionTurnStart",
		true,
		function(context) FactionTurnStart_Judgement_Day(context) end,
		true
	);

	if cm:is_new_game() then
		local faction_list = cm:model():world():faction_list();

		for i = 0, faction_list:num_items() - 1 do
			local faction = faction_list:item_at(i);

			if faction:is_human() ~= true and FactionIsAlive(faction:name()) == true then
				cm:force_change_cai_faction_personality(faction:name(), "mk1212_judgement_day_ai_uprising");
			end
		end
	end
end

function FactionTurnStart_Judgement_Day(context)
	if not context:faction():is_human() then
		cm:force_change_cai_faction_personality(context:faction():name(), "mk1212_judgement_day_ai_uprising");
	end
end
