-----------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: HOLY ROMAN EMPIRE EVENTS
-- 	By: DETrooper
--
-----------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------
-- Events which can occur for the emperor and members of the HRE.

HRE_EVENTS_MIN_TURN = 4; -- First turn that an HRE event can occur.
HRE_EVENTS_TURNS_BETWEEN_DILEMMAS_MAX = 12;
HRE_EVENTS_TURNS_BETWEEN_DILEMMAS_MIN = 4;
HRE_EVENTS_TIMER = 0;

HRE_CURRENT_EVENT = "";
HRE_CURRENT_EVENT_FACTION1 = "";
HRE_CURRENT_EVENT_FACTION2 = "";

function Add_HRE_Event_Listeners()
	local emperor_faction = cm:model():world():faction_by_key(HRE_EMPEROR_KEY);

	if emperor_faction:is_human() then
		cm:add_listener(
			"FactionTurnStart_HRE_Events",
			"FactionTurnStart",
			true,
			function(context) FactionTurnStart_HRE_Events(context) end,
			true
		);
		cm:add_listener(
			"DillemaOrIncidentStarted_HRE_Events",
			"DillemaOrIncidentStarted",
			true,
			function(context) DillemaOrIncidentStarted_HRE_Events(context) end,
			true
		);
		cm:add_listener(
			"DilemmaChoiceMadeEvent_HRE_Events",
			"DilemmaChoiceMadeEvent",
			true,
			function(context) DilemmaChoiceMadeEvent_HRE_Events(context) end,
			true
		);
		cm:add_listener(
			"PanelOpenedCampaign_HRE_Events",
			"PanelOpenedCampaign",
			true,
			function(context) PanelOpenedCampaign_HRE_Events(context) end,
			true
		);
	end
end

function Remove_HRE_Event_Listeners()
	cm:remove_listener("FactionTurnStart_HRE_Events");
	cm:remove_listener("DilemmaChoiceMadeEvent_HRE_Events");
	cm:remove_listener("DillemaOrIncidentStarted_HRE_Events");
	cm:remove_listener("PanelOpenedCampaign_HRE_Events");

	HRE_EVENTS_TIMER = 0;
end

function FactionTurnStart_HRE_Events(context)
	if context:faction():is_human() then
		local faction_name = context:faction():name();

		if faction_name == HRE_EMPEROR_KEY then
			local turn_number = cm:model():turn_number();

			if turn_number >= HRE_EVENTS_MIN_TURN then
				if HRE_EVENTS_TIMER > 0 then
					HRE_EVENTS_TIMER = HRE_EVENTS_TIMER - 1;
				elseif HRE_EVENTS_TIMER <= 0 then
					HRE_Event_Pick_Random_Event();
				end
			end
		end
	end
end

function DillemaOrIncidentStarted_HRE_Events(context)
	HRE_CURRENT_EVENT = context.string;
	HRE_EVENTS_TIMER = cm:random_number(HRE_EVENTS_TURNS_BETWEEN_DILEMMAS_MAX, HRE_EVENTS_TURNS_BETWEEN_DILEMMAS_MIN);
end

function DilemmaChoiceMadeEvent_HRE_Events(context)
	HRE_CURRENT_EVENT = "";
	HRE_CURRENT_EVENT_FACTION1 = "";
	HRE_CURRENT_EVENT_FACTION2 = "";
end

function PanelOpenedCampaign_HRE_Events(context)
	if HRE_CURRENT_EVENT == "mk_dilemma_hre_border_dispute" then
		
	elseif HRE_CURRENT_EVENT == "mk_dilemma_hre_imperial_immediacy" then
		
	elseif HRE_CURRENT_EVENT == "mk_dilemma_hre_noble_conflict" then
		
	elseif HRE_CURRENT_EVENT == "mk_dilemma_hre_imperial_diet" then
		
	end
end

function HRE_Event_Pick_Random_Event()
	local chance = cm:random_number(1, 4);

	if chance == 1 then
		HRE_Event_Pick_Random_Bordering_Factions();

		if HRE_CURRENT_EVENT_FACTION1 ~= "" and HRE_CURRENT_EVENT_FACTION2 ~= "" then
			cm:trigger_dilemma(HRE_EMPEROR_KEY, "mk_dilemma_hre_border_dispute");
		else
			HRE_EVENTS_TIMER = HRE_EVENTS_TIMER + 1;
		end
	elseif chance == 2 then
		HRE_Event_Pick_Random_Faction();

		if HRE_CURRENT_EVENT_FACTION1 ~= "" then
			cm:trigger_dilemma(HRE_EMPEROR_KEY, "mk_dilemma_hre_imperial_immediacy");
		else
			HRE_EVENTS_TIMER = HRE_EVENTS_TIMER + 1;
		end
	elseif chance == 3 then
		HRE_Event_Pick_Random_Bordering_Factions();

		if HRE_CURRENT_EVENT_FACTION1 ~= "" and HRE_CURRENT_EVENT_FACTION2 ~= "" then
			cm:trigger_dilemma(HRE_EMPEROR_KEY, "mk_dilemma_hre_noble_conflict");
		else
			HRE_EVENTS_TIMER = HRE_EVENTS_TIMER + 1;
		end
	elseif chance == 4 then
		HRE_Event_Pick_Random_Faction();

		if HRE_CURRENT_EVENT_FACTION1 ~= "" then
			cm:trigger_dilemma(HRE_EMPEROR_KEY, "mk_dilemma_hre_imperial_diet");
		else
			HRE_EVENTS_TIMER = HRE_EVENTS_TIMER + 1;
		end
	end
end

function HRE_Event_Pick_Random_Faction()
	local rand = cm:random_number(1, #FACTIONS_HRE);
	local random_faction = HRE_Event_Pick_Random_Faction();

	if #FACTIONS_HRE > 1 then
		while FACTIONS_HRE[rand] == HRE_EMPEROR_KEY do
			rand = cm:random_number(1, #FACTIONS_HRE);
		end
	end

	HRE_CURRENT_EVENT_FACTION1 = FACTIONS_HRE[rand];
end

function HRE_Event_Pick_Random_Bordering_Factions()
	HRE_Event_Pick_Random_Faction(); -- Set Faction 1.

	local bordering_factions = {};

	for i = 1, #FACTIONS_HRE do
		local potential_faction = FACTIONS_HRE[i];

		if potential_faction ~= HRE_EMPEROR_KEY and potential_faction ~= HRE_CURRENT_EVENT_FACTION1 then
			if Does_Faction_Border_Faction(HRE_CURRENT_EVENT_FACTION1, potential_faction) then
				table.insert(bordering_factions, potential_faction);
			end
		end
	end

	if bordering_factions == 0 then
		return;
	end

	local rand = cm:random_number(1, #bordering_factions);

	HRE_CURRENT_EVENT_FACTION2 = bordering_factions[rand];
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		cm:save_value("HRE_EVENTS_TIMER", HRE_EVENTS_TIMER, context);
	end
);

cm:register_loading_game_callback(
	function(context)
		HRE_EVENTS_TIMER = cm:load_value("HRE_EVENTS_TIMER", 0, context);
	end
);