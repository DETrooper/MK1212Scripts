-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: DECISIONS
-- 	By: DETrooper
--
-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------

mkDecisions = {};
mkDecisions.decisions = {};
mkDecisions.decision_registry = {}; -- Stored decision data such as functions.

require("mechanics/decisions/mechanics_decisions_ui");

function mkDecisions:Add_Decisions_Listeners()
	self:Add_Decisions_UI_Listeners();
end

function mkDecisions:Add_Decision(decision_key, faction_name, enabled, priority)
	-- Check first if the decision already exists!
	if #self.decisions > 0 then
		for _, decision in ipairs(self.decisions) do
			if decision[1] == decision_key then
				return;
			end
		end
	end

	-- Decision does not already exist, so add it.
	local decision = {decision_key, faction_name, enabled, priority};

	table.insert(self.decisions, {decision_key, faction_name, enabled, priority});
end

function mkDecisions:Remove_Decision(decision_key)
	if #self.decisions > 0 then
		for _, decision in ipairs(self.decisions) do
			if decision[1] == decision_key then
				--dev.log("Removing decision: "..decision[1]);
				table.remove(self.decisions, i);
				--dev.log("Decision removed.");
				return;
			end	
		end
	end
end

function mkDecisions:Register_Decision(decision_key, tooltip, required_regions, map_information, callback)
	self.decision_registry[decision_key] = {};

	self.decision_registry[decision_key].tooltip = tooltip;
	self.decision_registry[decision_key].required_regions = required_regions;
	self.decision_registry[decision_key].map_information = map_information;
	self.decision_registry[decision_key].callback = callback;
end

function mkDecisions:Enable_Decision(decision_key)
	if #self.decisions > 0 then
		for _, decision in ipairs(self.decisions) do
			if decision[1] == decision_key and decision[3] == false then
				decision[3] = true;
				mkDecisions:Highlight_Decisions_Button();
				--dev.log("Enabled decision: "..decision[1]);
				return;
			end	
		end
	end
end

function mkDecisions:Disable_Decision(decision_key)
	if #self.decisions > 0 then
		for _, decision in ipairs(self.decisions) do
			if decision[1] == decision_key then
				decision[3] = false;
				--dev.log("Disabled decision: "..decision[1]);
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
		SaveDecisionsTable(context, mkDecisions.decisions, "mkDecisions.decisions");
	end
);

cm:register_loading_game_callback(
	function(context)
		mkDecisions.decisions = LoadDecisionsTable(context, "mkDecisions.decisions");
	end
);

function SaveDecisionsTable(context, tab, savename)
	local savestring = "";
	
	for i = 1, #tab do
		savestring = savestring..tab[i][1]..","..tab[i][2]..","..tostring(tab[i][3])..","..tostring(tab[i][4])..",;";
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
			local trueorfalse2 = false;

			if second_split[3] == "true" then
				trueorfalse = true;
			end
			
			if second_split[4] == "true" then
				trueorfalse2 = true;
			end

			local decision = {second_split[1], second_split[2], trueorfalse, trueorfalse2};
			table.insert(tab, decision);
		end
	end

	return tab;
end
