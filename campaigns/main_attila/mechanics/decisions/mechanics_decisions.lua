-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: DECISIONS
-- 	By: DETrooper
--
-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------

require("mechanics/decisions/mechanics_decisions_lists");
require("mechanics/decisions/mechanics_decisions_ui");

AVAILABLE_DECISIONS = {};
PRIORITY_DECISIONS = {}; -- For important ones. Same as AVAILABLE_DECISIONS but these are at the top of the list and highlighted.

function Add_Decisions_Listeners()
	Add_Decisions_UI_Listeners();
end

function Add_Decision(decision_name, faction_name, enabled, priority)
	-- Check first if the decision already exists!
	if #PRIORITY_DECISIONS > 0 then
		for i = 1, #PRIORITY_DECISIONS do
			if PRIORITY_DECISIONS[i][1] == decision_name then
				return;
			end	
		end
	end

	if #AVAILABLE_DECISIONS > 0 then
		for i = 1, #AVAILABLE_DECISIONS do
			if AVAILABLE_DECISIONS[i][1] == decision_name then
				return;
			end	
		end
	end

	-- Decision does not already exist, so add it.
	local decision = {decision_name, faction_name, enabled};

	if priority == true then
		table.insert(PRIORITY_DECISIONS, decision);
	else
		table.insert(AVAILABLE_DECISIONS, decision);
	end
end

function Remove_Decision(decision_name)
	if #PRIORITY_DECISIONS > 0 then
		for i = 1, #PRIORITY_DECISIONS do
			if PRIORITY_DECISIONS[i][1] == decision_name then
				--dev.log("Removing decision: "..PRIORITY_DECISIONS[i][1]);
				table.remove(PRIORITY_DECISIONS, i);
				--dev.log("Decision removed.");
				return;
			end	
		end
	end

	if #AVAILABLE_DECISIONS > 0 then
		for i = 1, #AVAILABLE_DECISIONS do
			if AVAILABLE_DECISIONS[i][1] == decision_name then
				--dev.log("Removing decision: "..AVAILABLE_DECISIONS[i][1]);
				table.remove(AVAILABLE_DECISIONS, i);
				--dev.log("Decision removed.");
				return;
			end	
		end
	end
end

function Enable_Decision(decision_name)
	if #PRIORITY_DECISIONS > 0 then
		for i = 1, #PRIORITY_DECISIONS do
			if PRIORITY_DECISIONS[i][1] == decision_name and PRIORITY_DECISIONS[i][3] == false then
				PRIORITY_DECISIONS[i][3] = true;
				Highlight_Decisions_Button();
				--dev.log("Enabled decision: "..PRIORITY_DECISIONS[i][1]);
				return;
			end	
		end
	end

	if #AVAILABLE_DECISIONS > 0 then
		for i = 1, #AVAILABLE_DECISIONS do
			if AVAILABLE_DECISIONS[i][1] == decision_name and AVAILABLE_DECISIONS[i][3] == false then
				AVAILABLE_DECISIONS[i][3] = true;
				Highlight_Decisions_Button();
				--dev.log("Enabled decision: "..AVAILABLE_DECISIONS[i][1]);
				return;
			end	
		end
	end
end

function Disable_Decision(decision_name)
	if #PRIORITY_DECISIONS > 0 then
		for i = 1, #PRIORITY_DECISIONS do
			if PRIORITY_DECISIONS[i][1] == decision_name then
				PRIORITY_DECISIONS[i][3] = false;
				--dev.log("Disabled decision: "..PRIORITY_DECISIONS[i][1]);
				return;
			end	
		end
	end

	if #AVAILABLE_DECISIONS > 0 then
		for i = 1, #AVAILABLE_DECISIONS do
			if AVAILABLE_DECISIONS[i][1] == decision_name then
				AVAILABLE_DECISIONS[i][3] = false;
				--dev.log("Disabled decision: "..AVAILABLE_DECISIONS[i][1]);
				return;
			end	
		end
	end
end

------------------------------------------------
---------------- Saving/Loading ----------------
------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		SaveDecisionsTable(context, AVAILABLE_DECISIONS, "AVAILABLE_DECISIONS");
		SaveDecisionsTable(context, PRIORITY_DECISIONS, "PRIORITY_DECISIONS");
	end
);

cm:register_loading_game_callback(
	function(context)
		AVAILABLE_DECISIONS = LoadDecisionsTable(context, "AVAILABLE_DECISIONS");
		PRIORITY_DECISIONS = LoadDecisionsTable(context, "PRIORITY_DECISIONS");
	end
);

function SaveDecisionsTable(context, tab, savename)
	local savestring = "";
	
	for i = 1, #tab do
		savestring = savestring..tab[i][1]..","..tab[i][2]..","..tostring(tab[i][3])..",;";
	end

	cm:save_value(savename, savestring, context);
end

function LoadDecisionsTable(context, savename)
	local savestring = cm:load_value(savename, "", context);
	local tab = {};
	
	if savestring ~= "" then
		local first_split = SplitString(savestring, ";");

		for i = 1, #first_split do
			local second_split = SplitString(first_split[i], ",");
			local trueorfalse = false;

			if second_split[3] == "true" then
				trueorfalse = true;
			end

			local decision = {second_split[1], second_split[2], trueorfalse};
			table.insert(tab, decision);
		end
	end

	return tab;
end
