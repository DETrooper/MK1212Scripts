-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - STORY: TEUTONIC ORDER
-- 	By: DETrooper
--
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------

TEUTONIC_ORDER_KEY = "mk_fact_teutonicorder";
LITHUANIA_KEY = "mk_fact_lithuania";

TEUTONIC_TRUCE_NOTIFICATION_TURN = 2;

function Add_Teutonic_Order_Story_Events_Listeners()
	local teutonic_order = cm:model():world():faction_by_key(TEUTONIC_ORDER_KEY);
	local lithuania = cm:model():world():faction_by_key(LITHUANIA_KEY);

	if teutonic_order:is_human() == true then
		cm:add_listener(
			"FactionTurnStart_Teutonic_Order",
			"FactionTurnStart",
			true,
			function(context) FactionTurnStart_Teutonic_Order(context) end,
			true
		);
		cm:add_listener(
			"DilemmaChoiceMadeEvent_Teutonic_Order",
			"DilemmaChoiceMadeEvent",
			true,
			function(context) DilemmaChoiceMadeEvent_Teutonic_Order(context) end,
			true
		);
	end
end

function FactionTurnStart_Teutonic_Order(context)
	if context:faction():name() == TEUTONIC_ORDER_KEY then
		local turn_number = cm:model():turn_number();

		if turn_number == TEUTONIC_TRUCE_NOTIFICATION_TURN then
			
		end
	end
end
