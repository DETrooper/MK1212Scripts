-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - COMMON: VASSAL TRACKING
-- 	By: DETrooper
--
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- Sadly, Attila does not have built-in functions for checking if a faction is a vassal.
-- As such, a tracking system is necessary if annexing vassals is going to be a thing.

local liberator = nil;
local proposer = nil;
local recipient = nil;
local vassal = nil;

FACTIONS_TO_FACTIONS_VASSALIZED = {};

function Add_MK1212_Vassal_Tracking_Listeners()
	cm:add_listener(
		"FactionTurnStart_Vassal_Tracking",
		"FactionTurnStart",
		true,
		function(context) FactionTurnStart_Vassal_Tracking(context) end,
		true
	);
	cm:add_listener(
		"FactionBecomesLiberationVassal_Vassal_Tracking",
		"FactionBecomesLiberationVassal",
		true,
		function(context) FactionBecomesLiberationVassal_Vassal_Tracking(context) end,
		true
	);
	cm:add_listener(
		"FactionSubjugatesOtherFaction_Vassal_Tracking",
		"FactionSubjugatesOtherFaction",
		true,
		function(context) FactionSubjugatesOtherFaction_Vassal_Tracking(context) end,
		true
	);
	cm:add_listener(
		"PositiveDiplomaticEvent_Vassal_Tracking",
		"PositiveDiplomaticEvent",
		true,
		function(context) PositiveDiplomaticEvent_Vassal_Tracking(context) end,
		true
	);
	cm:add_listener(
		"FactionLeaderDeclaresWar_Vassal_Tracking",
		"FactionLeaderDeclaresWar",
		true,
		function(context) FactionLeaderDeclaresWar_Vassal_Tracking(context) end,
		true
	)
	cm:add_listener(
		"TimeTrigger_Vassal_Tracking",
		"TimeTrigger",
		true,
		function(context) TimeTrigger_Vassal_Tracking(context) end,
		true
	);

	if cm:is_new_game() then
		VassalTrackingSetup();
	end
end

function VassalTrackingSetup()
	local faction_list = cm:model():world():faction_list();

	for i = 0, faction_list:num_items() - 1 do
		local faction = faction_list:item_at(i);
		local faction_name = faction:name();

		FACTIONS_TO_FACTIONS_VASSALIZED[faction_name] = {};

		if FACTIONS_TO_FACTIONS_VASSALIZED_START[faction_name] then
			for j = 1, #FACTIONS_TO_FACTIONS_VASSALIZED_START[faction_name] do
				local vassal_faction_name = FACTIONS_TO_FACTIONS_VASSALIZED_START[faction_name][j];

				table.insert(FACTIONS_TO_FACTIONS_VASSALIZED[faction_name], vassal_faction_name);
			end
		end
	end
end

function FactionTurnStart_Vassal_Tracking(context)
	local faction_name = context:faction():name();
	local faction_is_human = context:faction():is_human();

	if FACTIONS_TO_FACTIONS_VASSALIZED[faction_name] == nil then
		FACTIONS_TO_FACTIONS_VASSALIZED[faction_name] = {};
	end

	for i = 1, #FACTIONS_TO_FACTIONS_VASSALIZED[faction_name] do
		local vassal_faction_name = FACTIONS_TO_FACTIONS_VASSALIZED[faction_name][i];
		local vassal_faction = cm:model():world():faction_by_key(vassal_faction_name);

		if FactionIsAlive(vassal_faction_name) ~= true or vassal_faction:has_home_region() ~= true then
			
		end
	end
end

function FactionBecomesLiberationVassal_Vassal_Tracking(context)
	local liberating_faction_name = context:liberating_character():faction():name();
	local vassal_faction_name = context:faction():name();

	if not HasValue(FACTIONS_TO_FACTIONS_VASSALIZED[liberating_faction_name], vassal_faction_name) then
		table.insert(FACTIONS_TO_FACTIONS_VASSALIZED[liberating_faction_name], vassal_faction_name);
		liberator = liberating_faction_name;
		cm:add_time_trigger("vassal_check", 0.1);
	else
		-- Something has gone horribly wrong!!!!!!
	end
end

function FactionSubjugatesOtherFaction_Vassal_Tracking(context)
	vassal = context:other_faction():name();
end

function PositiveDiplomaticEvent_Vassal_Tracking(context)
	proposer = context:proposer():name();
	recipient = context:recipient():name();
	cm:add_time_trigger("diplo_vassal_check", 0.5);
end

function FactionLeaderDeclaresWar_Vassal_Tracking(context)
	local faction_name = context:character():faction():name();

	if #FACTIONS_TO_FACTIONS_VASSALIZED[faction_name] > 0 then
		for i = 1, #FACTIONS_TO_FACTIONS_VASSALIZED[faction_name] do
			local vassal_faction_name = FACTIONS_TO_FACTIONS_VASSALIZED[faction_name][i];
			local vassal_faction = cm:model():world():faction_by_key(vassal_faction_name);

			if vassal_faction:at_war_with(context:character():faction()) then
				FACTIONS_VASSALIZED_DELAYS[vassal_faction_name] = nil;

				if Get_Vassal_Currently_Annexing(faction_name) == vassal_faction_name then
					Stop_Annexing_Vassal(faction_name, vassal_faction_name);
				end

				table.remove(FACTIONS_TO_FACTIONS_VASSALIZED[faction_name], i);
				return;
			end
		end
	else
		-- Faction has no vassals or is a vassal.
		local master_faction_name = Get_Vassal_Overlord(faction_name);

		if master_faction_name  then
			if cm:model():world():faction_by_key(master_faction_name):at_war_with(context:character():faction()) then
				for i = 1, #FACTIONS_TO_FACTIONS_VASSALIZED[master_faction_name] do
					if FACTIONS_TO_FACTIONS_VASSALIZED[master_faction_name][i] == faction_name then
						FACTIONS_VASSALIZED_DELAYS[faction_name] = nil;

						if Get_Vassal_Currently_Annexing(master_faction_name) == faction_name then
							Stop_Annexing_Vassal(master_faction_name, faction_name);
						end

						table.remove(FACTIONS_TO_FACTIONS_VASSALIZED[master_faction_name], i);
						return;
					end
				end
			end
		end
	end
end

function TimeTrigger_Vassal_Tracking(context)
	if context.string == "vassal_check" then
		local liberator_faction = cm:model():world():faction_by_key(liberator);
		local vassalized_faction_name = FACTIONS_TO_FACTIONS_VASSALIZED[liberator][#FACTIONS_TO_FACTIONS_VASSALIZED[liberator]];
		local vassalized_faction = cm:model():world():faction_by_key(vassalized_faction_name);
		local is_ally = liberator_faction:allied_with(vassalized_faction);
		
		--dev.log("VASSAL CHECK: "..vassalized_faction_name.." - Is Ally: "..tostring(is_ally));
		
		if is_ally == true then
			-- They were liberated instead of vassalized, so remove them.
			table.remove(FACTIONS_TO_FACTIONS_VASSALIZED[liberator], #FACTIONS_TO_FACTIONS_VASSALIZED[liberator]);
		else
			Faction_Vassalized(liberator, vassalized_faction_name, false, true, true);
		end
		
		--dev.log("\tFACTIONS_TO_FACTIONS_VASSALIZED["..liberator.."]: "..table.concat(FACTIONS_TO_FACTIONS_VASSALIZED[liberator], ","));

		liberator = nil;
		proposer = nil;
		recipient = nil;
		vassal = nil;
	elseif context.string == "diplo_vassal_check" then
		if proposer  and recipient  and vassal  then
			if recipient == vassal then
				--dev.log("RECIPIENT == VASSAL");

				if not HasValue(FACTIONS_TO_FACTIONS_VASSALIZED[proposer], recipient) then
					Faction_Vassalized(proposer, recipient, true, true, true);
				else
					-- Something has gone horribly wrong!!!!!!
				end
			end

			--dev.log("\tFACTIONS_TO_FACTIONS_VASSALIZED["..proposer.."]: "..table.concat(FACTIONS_TO_FACTIONS_VASSALIZED[proposer], ","));

			liberator = nil;
			proposer = nil;
			recipient = nil;
			vassal = nil;
		end
	end
end

function Faction_Vassalized(master_faction_name, vassalized_faction_name, add_to_table, transfer_vassals, make_peace)
	local master_faction = cm:model():world():faction_by_key(master_faction_name);
	local vassalized_faction = cm:model():world():faction_by_key(vassalized_faction_name);

	if add_to_table == true then
		if FACTIONS_TO_FACTIONS_VASSALIZED[master_faction_name] == nil then
			FACTIONS_TO_FACTIONS_VASSALIZED[master_faction_name] = {};
		end
		
		table.insert(FACTIONS_TO_FACTIONS_VASSALIZED[master_faction_name], vassalized_faction_name);
	end

	if transfer_vassals == true then
		Vassal_Transfer_Vassals_To_New_Master(master_faction_name, vassalized_faction_name);
	end

	if make_peace == true then
		Vassal_Make_Peace_With_Other_Vassals(vassalized_faction);
	end

	cm:trigger_event("FactionVassalized", master_faction, vassalized_faction);
end

function Faction_Unvassalized(master_faction_name, vassalized_faction_name)
	local master_faction = cm:model():world():faction_by_key(master_faction_name);
	local vassalized_faction = cm:model():world():faction_by_key(vassalized_faction_name);

	if FACTIONS_TO_FACTIONS_VASSALIZED[master_faction_name] == nil then
		FACTIONS_TO_FACTIONS_VASSALIZED[master_faction_name] = {};
	else
		for i = 1, #FACTIONS_TO_FACTIONS_VASSALIZED[master_faction_name] do
			local current_vassal_name = FACTIONS_TO_FACTIONS_VASSALIZED[master_faction_name][i];

			if current_vassal_name == vassalized_faction_name then
				table.remove(FACTIONS_TO_FACTIONS_VASSALIZED[master_faction_name], i);
				break;
			end
		end
	end

	cm:trigger_event("FactionUnvassalized", master_faction, vassalized_faction);
end

function Get_Vassal_Overlord(vassal_faction_name)
	for k, v in pairs(FACTIONS_TO_FACTIONS_VASSALIZED) do
		if #v > 0 then
			for i = 1, #v do
				if v[i] == vassal_faction_name then
					return k;
				end
			end
		end
	end
end

function Vassal_Transfer_Vassals_To_New_Master(master_faction_name, vassalized_faction_name)
	if FACTIONS_TO_FACTIONS_VASSALIZED[vassalized_faction_name] then
		if #FACTIONS_TO_FACTIONS_VASSALIZED[vassalized_faction_name] > 0 then
			for i = 1, #FACTIONS_TO_FACTIONS_VASSALIZED[vassalized_faction_name] do
				Faction_Vassalized(master_faction_name, FACTIONS_TO_FACTIONS_VASSALIZED[vassalized_faction_name][i], false, false, true);
			end
		end
	end

	FACTIONS_TO_FACTIONS_VASSALIZED[vassalized_faction_name] = {};
end

function Vassal_Make_Peace_With_Other_Vassals(faction)
	local faction_list = cm:model():world():faction_list();

	for i = 0, faction_list:num_items() - 1 do
		local current_faction = faction_list:item_at(i);
		local current_faction_name = current_faction:name();

		if current_faction:at_war_with(faction) then
			if HasValue(FACTIONS_TO_FACTIONS_VASSALIZED[faction:name()], current_faction) then
				cm:force_make_peace(current_faction_name, faction:name());
			end
		end
	end
end

------------------------------------------------
---------------- Saving/Loading ----------------
------------------------------------------------
cm:register_loading_game_callback(
	function(context)
		FACTIONS_TO_FACTIONS_VASSALIZED = LoadKeyPairTables(context, "FACTIONS_TO_FACTIONS_VASSALIZED");
	end
);

cm:register_saving_game_callback(
	function(context)
		SaveKeyPairTables(context, FACTIONS_TO_FACTIONS_VASSALIZED, "FACTIONS_TO_FACTIONS_VASSALIZED");
	end
);
