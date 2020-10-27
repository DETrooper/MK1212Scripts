--------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: HOLY ROMAN EMPIRE REFORMS
-- 	By: DETrooper
--
--------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------
-- System for the HRE to reform its centralization and eventually become unified.

CURRENT_HRE_REFORM = 0;
HRE_REFORMS_VOTES = {};
HRE_REFORM_COST = 100;

HRE_REFORMS = {
	-- Reforms are unlocked in order from first to last.
	{
		["key"] = "hre_reform_kufursten", 
		["name"] = "Confirm Permanent Prince-Electors", 
		["description"] = "The emperor is only elected by a select group of electors.", 
		["effects"] = {"The Prince-electors are established, limiting elections to 7 voting factions."}
	},
	{
		["key"] = "hre_reform_reichstag", 
		["name"] = "Formalize the Imperial Diet", 
		["description"] = "The Imperial Diet becomes the formal consultative and legislative body of the empire with representatives from the empire's estates.", 
		["effects"] = {"+25 Diplomatic Relations With All Factions."}
	},
	{
		["key"] = "hre_reform_reichspfennig", 
		["name"] = "Institute the Common Penny", 
		["description"] = "Institute the levy of a widespread poll tax.", 
		["effects"] = {"+20% Income From Vassals."}
	},
	{
		["key"] = "hre_reform_reichskreise", 
		["name"] = "Organize the Imperial Circles", 
		["description"] = "Regroup regions of the empire into administrative territories to better manage the empire.", 
		["effects"] = {"+5% Tax Rate.", "+1 Levy Unit From Vassals."}
	},
	{
		["key"] = "hre_reform_ewiger_landfriede", 
		["name"] = "Enact Perpetual Public Peace", 
		["description"] = "Outlaws feuds and organizes legal structure into a single body, with the Emperor as the ultimate arbiter.", 
		["effects"] = {"Factions in the Holy Roman Empire can no longer declare war on each other.", "+1 Public Order.", "+25% Imperial Authority Growth."}
	},
	{
		["key"] = "hre_reform_reichskammergericht", 
		["name"] = "Establish the Imperial Chamber Court", 
		["description"] = "Creates the Imperial Chamber Court to hear cases and apply imperial law.", 
		["effects"] = {"+2 Public Order."}
	},
	{
		["key"] = "hre_reform_reichsregiment", 
		["name"] = "Establish the Imperial Government", 
		["description"] = "Create an executive organ led by the estates, acting as representatives of the emperor.", 
		["effects"] = {"+25% Imperial Authority Growth.", "+15% Building Cost.", "+5% Corruption."}
	},
	{
		["key"] = "hre_reform_erbkaisertum", 
		["name"] = "Adopt Hereditary Succession", 
		["description"] = "Abolishes elections and institutes a hereditary monarchy.", 
		["effects"] = {"The emperorship is now always inherited by the emperor's faction.", "Elections are abolished."}
	},
	{
		["key"] = "hre_reform_renovatio_imperii", 
		["name"] = "Renovatio Imperii", 
		["description"] = "The Holy Roman Empire is united into one faction!", 
		["effects"] = {"+2 Public Order.", "-15% Building Cost.", "-5% Corruption."}
	}
};

function Add_HRE_Reforms_Listeners()
	cm:add_listener(
		"FactionTurnStart_HRE_Reforms",
		"FactionTurnStart",
		true,
		function(context) FactionTurnStart_HRE_Reforms(context) end,
		true
	);

	if cm:is_new_game() then
		Calculate_Reform_Votes();
	end
end

function FactionTurnStart_HRE_Reforms(context)
	if not HRE_DESTROYED then
		if context:faction():is_human() == false then
			if context:faction():name() == HRE_EMPEROR_KEY then
				if HRE_IMPERIAL_AUTHORITY == HRE_REFORM_COST and #HRE_REFORMS_VOTES >= math.ceil((#HRE_FACTIONS - 1) / 2)  then
					Pass_HRE_Reform(CURRENT_HRE_REFORM + 1);
				end
			end
		else
			Calculate_Reform_Votes();
		end
	end
end

function Calculate_Reform_Votes()
	local tab = {};

	for i = 1, #HRE_FACTIONS do
		local faction_name = HRE_FACTIONS[i];
		local faction = cm:model():world():faction_by_key(faction_name);
		local faction_state = HRE_Get_Faction_State(faction_name);

		if cm:is_new_game() or faction:is_human() == false then
			if faction_state == "loyal" or faction_state == "puppet" or faction_state == "neutral" then
				table.insert(tab, faction_name);
			end
		elseif faction:is_human() == true then
			if HasValue(HRE_REFORMS_VOTES, faction_name) then
				table.insert(tab, faction_name);
			end
		end
	end

	HRE_REFORMS_VOTES = DeepCopy(tab);
end

function Pass_HRE_Reform(reform_number)
	CURRENT_HRE_REFORM = reform_number;

	for i = 1, reform_number - 1 do
		cm:remove_effect_bundle("mk_effect_bundle_reform_"..tostring(i), HRE_EMPEROR_KEY);
	end

	cm:apply_effect_bundle("mk_effect_bundle_reform_"..tostring(reform_number), HRE_EMPEROR_KEY, 0);

	if reform_number == 1 then
		-- We need to add 7 Prince-Electors.

		for i = 1, #HRE_FACTIONS_HISTORICAL_ELECTORS do
			local faction_name = HRE_FACTIONS_HISTORICAL_ELECTORS[i];

			if FactionIsAlive(faction_name) and HasValue(HRE_FACTIONS, faction_name) then
				table.insert(HRE_FACTIONS_ELECTORS, faction_name);
			end
		end

		if #HRE_FACTIONS_ELECTORS < 7 then
			Add_New_Electors_HRE_Elections();
		end
	elseif reform_number == 5 then
		for i = 1, #HRE_FACTIONS do
			local faction_name = HRE_FACTIONS[i];

			for j = 1, #HRE_FACTIONS do
				local faction2_name = HRE_FACTIONS[j];

				if faction_name ~= HRE_EMPEROR_KEY and faction2_name ~= HRE_EMPEROR_KEY then
					cm:force_diplomacy(faction_name, faction2_name, "war", false, false);

					if cm:model():world():faction_by_key(faction_name):at_war_with(cm:model():world():faction_by_key(faction2_name)) then
						cm:force_make_peace(faction_name, faction2_name);
					end
				end
			end
		end
	elseif reform_number == 8 then
		
	elseif reform_number == 9 then
		local turn_number = cm:model():turn_number();

		for i = 1, #HRE_FACTIONS do
			local faction_name = HRE_FACTIONS[i];

			if HRE_Get_Faction_State(faction_name) ~= "emperor" then
				cm:grant_faction_handover(HRE_EMPEROR_KEY, faction_name, turn_number-1, turn_number-1, context);
			end
		end

		HRE_Vanquish_Pretender();
		CloseHREPanel(false);

		if IRONMAN_ENABLED then
			Unlock_Achievement("achievement_renovatio_imperii");
		end

		HRE_FACTIONS = {};
		HRE_FACTIONS_STATES = {};
		HRE_FACTIONS_STATE_CHANGE_COOLDOWNS = {};

		HRE_Button_Check();
	end

	if HasValue(HRE_FACTIONS, cm:get_local_faction()) then
		cm:show_message_event(
			cm:get_local_faction(),
			"message_event_text_text_mk_event_hre_reform_title",
			"message_event_text_text_mk_event_hre_reform_primary_"..tostring(reform_number),
			"message_event_text_text_mk_event_hre_reform_secondary",
			true, 
			704
		);
	end

	Calculate_Reform_Votes();
	HRE_Change_Imperial_Authority(-HRE_REFORM_COST);
end

function Cast_Vote_For_Current_Reform_HRE(faction_name)
	table.insert(HRE_REFORMS_VOTES, faction_name);
end

function Remove_Vote_For_Current_Reform_HRE(faction_name)
	for i = 1, #HRE_REFORMS_VOTES do
		if HRE_REFORMS_VOTES[i] == faction_name then
			table.remove(HRE_REFORMS_VOTES, i);
		end
	end
end

function Get_Reform_Tooltip(reform_key)
	local reformstring = "";

	for i = 1, #HRE_REFORMS do
		if HRE_REFORMS[i]["key"] == reform_key then
			reformstring = "[[rgba:255:215:0:215]]"..HRE_REFORMS[i]["name"].."[[/rgba]]\n[[rgba:219:211:173:150]]"..HRE_REFORMS[i]["description"].."[[/rgba]]\n\nEffects:";

			for j = 1, #HRE_REFORMS[i]["effects"] do
				reformstring = reformstring.."\n"..HRE_REFORMS[i]["effects"][j];
			end

			if CURRENT_HRE_REFORM < i - 1 then
				reformstring = reformstring.."\n\n[[rgba:255:0:0:150]]The previous reform must be unlocked first![[/rgba]]";
			elseif CURRENT_HRE_REFORM == i - 1 then
				local color1 = "[[rgba:255:0:0:150]]";
				local color2 = "[[rgba:255:0:0:150]]";

				if HRE_IMPERIAL_AUTHORITY >= HRE_REFORM_COST then
					color1 = "[[rgba:8:201:27:150]]";
				end

				if #HRE_REFORMS_VOTES >= math.ceil((#HRE_FACTIONS - 1) / 2) then
					color2 = "[[rgba:8:201:27:150]]";
				end

				reformstring = reformstring.."\n\n"..color1.."Imperial Authority: ("..Round_Number_Text(HRE_IMPERIAL_AUTHORITY).." / "..tostring(HRE_REFORM_COST)..")[[/rgba]]\n"..color2.."Votes: ("..tostring(#HRE_REFORMS_VOTES).." / "..tostring(math.ceil((#HRE_FACTIONS - 1) / 2)).." Required)[[/rgba]]";
			elseif CURRENT_HRE_REFORM > i - 1 then
				reformstring = reformstring.."\n\nThis reform has already been unlocked!";
			end
		end
	end

	return reformstring;
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		cm:save_value("CURRENT_HRE_REFORM", CURRENT_HRE_REFORM, context);
		SaveTable(context, HRE_REFORMS_VOTES, "HRE_REFORMS_VOTES");
	end
);

cm:register_loading_game_callback(
	function(context)
		CURRENT_HRE_REFORM = cm:load_value("CURRENT_HRE_REFORM", 0, context);
		HRE_REFORMS_VOTES = LoadTable(context, "HRE_REFORMS_VOTES");
	end
);
