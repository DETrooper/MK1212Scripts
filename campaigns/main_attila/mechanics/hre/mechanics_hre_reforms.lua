--------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: HOLY ROMAN EMPIRE REFORMS
-- 	By: DETrooper
--
--------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------
-- System for the HRE to reform its centralization and eventually become unified.

mkHRE.current_reform = 0; -- Current HRE reform number.
mkHRE.reforms_votes = {}; -- List of factions voting in support of a reform.
mkHRE.reform_cost = 100; -- How much imperial authority it costs to pass a reform.

mkHRE.reforms = {
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
		["description"] = "Abolish the electoral law and establish a hereditary monarchy, which poses a fatal threat to the various forces within the Holy Roman Empire. The peace bill will be seen as scrap paper, and each other will fight tirelessly for the supreme throne, while external forces will also be eyeing it", 
		["effects"] = {"Abolishes elections and institutes a hereditary monarchy", "loyalty: -2 ", "Corruption: +50% ", "Public Order: 0", "Diplomatic Relations With All Factions: -25 ", "Imperial Authority Growth：+0%", "War will reignite within the territory, and the lords may once again attack each other"}
	},
	{
		["key"] = "hre_reform_renovatio_imperii", 
		["name"] = "Renovatio Imperii", 
		["description"] = "The Holy Roman Empire is finally unified! The hegemony has been achieved", 
		["effects"] = {"Diplomatic Relations With All Factions: +50 ", "Public Order: +25 ", "Building Cost: -15% ", "Corruption: -50% ", "loyalty: +5 ", "Tax Rate: +30%", "sanitation: +3", "Levy Unit From Vassals: +5", "Replenishment: +5%", "Military recruitment capacity:+2", "Unit Morale: +20", "Unit Melee Attack: +5", "Unit Melee Defend: +5", "Population Growth: Burgher and Peasantry Growth +2% "}
	}
};

function mkHRE:Add_Reform_Listeners()
	cm:add_listener(
		"FactionTurnStart_HRE_Reforms",
		"FactionTurnStart",
		true,
		function(context) FactionTurnStart_HRE_Reforms(context) end,
		true
	);

	if cm:is_new_game() then
		self:Calculate_Reform_Votes();
	end
end

function FactionTurnStart_HRE_Reforms(context)
	if not mkHRE.destroyed then
		if context:faction():is_human() == false then
			if context:faction():name() == mkHRE.emperor_key then
				if mkHRE.imperial_authority == mkHRE.reform_cost and #mkHRE.reforms_votes >= math.ceil((#mkHRE.factions - 1) / 2)  then
					mkHRE:Pass_Reform(mkHRE.current_reform + 1);
				end
			end
		else
			mkHRE:Calculate_Reform_Votes();
		end
	end
end

function mkHRE:Calculate_Reform_Votes()
	local tab = {};

	for i = 1, #self.factions do
		local faction_name = self.factions[i];
		local faction = cm:model():world():faction_by_key(faction_name);
		local faction_state = self:Get_Faction_State(faction_name);

		if cm:is_new_game() or faction:is_human() == false then
			if faction_state == "loyal" or faction_state == "puppet" or faction_state == "neutral" then
				table.insert(tab, faction_name);
			end
		elseif faction:is_human() == true then
			if HasValue(self.reforms_votes, faction_name) then
				table.insert(tab, faction_name);
			end
		end
	end

	self.reforms_votes = DeepCopy(tab);
end

-- Build exactly 7 prince-electors (never includes the emperor)
function mkHRE:BuildPrinceElectors()
  self.elector_factions = {}

  -- 1) Add all historical electors except the emperor
  for _, fname in ipairs(self.historical_electors) do
    if fname ~= self.emperor_key
       and FactionIsAlive(fname)
       and HasValue(self.factions, fname)
    then
      table.insert(self.elector_factions, fname)
    end
  end

  -- 2) Fill up to 7 with any other HRE members
  for _, fname in ipairs(self.factions) do
    if #self.elector_factions >= 7 then break end
    if fname ~= self.emperor_key
       and not HasValue(self.elector_factions, fname)
    then
      table.insert(self.elector_factions, fname)
    end
  end

  -- 3) Trim any extras (just in case)
  while #self.elector_factions > 7 do
    table.remove(self.elector_factions)
  end
end

function mkHRE:Pass_Reform(reform_number)
  self.current_reform = reform_number

  -- Remove any prior reform bundles
  for i = 1, reform_number - 1 do
    cm:remove_effect_bundle("mk_effect_bundle_reform_" .. tostring(i), self.emperor_key)
  end

  -- Apply the new reform bundle
  cm:apply_effect_bundle("mk_effect_bundle_reform_" .. tostring(reform_number), self.emperor_key, 0)

  if reform_number == 1 then
    -- Reset votes and pick exactly 7 non-emperor electors
    self.reforms_votes = {}
    self:BuildPrinceElectors()

  elseif reform_number == 5 then
    -- Peace all HRE members (except emperor)
    for _, faction_name in ipairs(self.factions) do
      for _, faction2_name in ipairs(self.factions) do
        if faction_name ~= self.emperor_key
           and faction2_name ~= self.emperor_key
        then
          cm:force_diplomacy(faction_name, faction2_name, "war", false, false)
          local f1 = cm:model():world():faction_by_key(faction_name)
          local f2 = cm:model():world():faction_by_key(faction2_name)
          if f1:at_war_with(f2) then
            cm:force_make_peace(faction_name, faction2_name)
          end
        end
      end
    end

  elseif reform_number == 8 then
    -- (Nothing special here—placeholder for your later logic.)

  elseif reform_number == 9 then
    local faction = cm:model():world():faction_by_key(self.emperor_key)
    local turn_number = cm:model():turn_number()

    -- Grant handover to every non-emperor state
    for _, faction_name in ipairs(self.factions) do
      if self:Get_Faction_State(faction_name) ~= "emperor" then
        cm:grant_faction_handover(self.emperor_key, faction_name,
                                 turn_number-1, turn_number-1, context)
      end
    end

    -- Final population and economy bundles
    if POPULATION_REGIONS_POPULATIONS then
      for i = 0, faction:region_list():num_items() - 1 do
        local region = faction:region_list():item_at(i)
        cm:apply_effect_bundle_to_region(
          "mk_bundle_population_bundle_region",
          region:name(), 0
        )
      end
      Apply_Region_Economy_Factionwide(faction)
    end

    -- Clean up
    self:Remove_Imperial_Expansion_Effect_Bundles(self.emperor_key)
    self:Remove_Unlawful_Territory_Effect_Bundles(self.emperor_key)
    self:HRE_Vanquish_Pretender()
    self:CloseHREPanel(false)

    if IRONMAN_ENABLED then
      Unlock_Achievement("achievement_renovatio_imperii")
    end

    -- Reset HRE tracking tables
    self.factions = {}
    self.factions_to_states = {}
    self.faction_state_change_cooldowns = {}
    self:Button_Check()
  end

  -- Notify the player if they’re in the HRE
  if HasValue(self.factions, cm:get_local_faction()) then
    cm:show_message_event(
      cm:get_local_faction(),
      "message_event_text_text_mk_event_hre_reform_title",
      "message_event_text_text_mk_event_hre_reform_primary_" .. tostring(reform_number),
      "message_event_text_text_mk_event_hre_reform_secondary",
      true, 704
    )
  end

  -- Re-tally votes and deduct authority
  self:Calculate_Reform_Votes()
  self:Change_Imperial_Authority(-self.reform_cost)
end

function mkHRE:Cast_Vote_Reform(faction_name)
	table.insert(self.reforms_votes, faction_name);
end

function mkHRE:Remove_Vote_Reform(faction_name)
	for i = 1, #self.reforms_votes do
		if self.reforms_votes[i] == faction_name then
			table.remove(self.reforms_votes, i);
		end
	end
end

function mkHRE:Get_Reform_Tooltip(reform_key)
	local reformstring = "";

	for i = 1, #self.reforms do
		if self.reforms[i]["key"] == reform_key then
			reformstring = "[[rgba:255:215:0:215]]"..self.reforms[i]["name"].."[[/rgba]]\n[[rgba:219:211:173:150]]"..self.reforms[i]["description"].."[[/rgba]]\n\nEffects:";

			for j = 1, #self.reforms[i]["effects"] do
				reformstring = reformstring.."\n"..self.reforms[i]["effects"][j];
			end

			if self.current_reform < i - 1 then
				reformstring = reformstring.."\n\n[[rgba:255:0:0:150]]"..UI_LOCALISATION["hre_reform_tooltip_locked"].."[[/rgba]]";
			elseif self.current_reform == i - 1 then
				local color1 = "[[rgba:255:0:0:150]]";
				local color2 = "[[rgba:255:0:0:150]]";

				if self.imperial_authority >= self.reform_cost then
					color1 = "[[rgba:8:201:27:150]]";
				end

				if #self.reforms_votes >= math.ceil((#self.factions - 1) / 2) then
					color2 = "[[rgba:8:201:27:150]]";
				end

				reformstring = reformstring.."\n\n"..color1..UI_LOCALISATION["hre_imperial_authority_prefix"].."("..Round_Number_Text(self.imperial_authority).." / "..tostring(self.reform_cost)..")[[/rgba]]\n"..color2..UI_LOCALISATION["hre_votes_prefix"].."("..tostring(#self.reforms_votes).." / "..tostring(math.ceil((#self.factions - 1) / 2))..UI_LOCALISATION["hre_votes_required"].."[[/rgba]]";
			elseif self.current_reform > i - 1 then
				reformstring = reformstring.."\n\n[[rgba:8:201:27:150]]"..UI_LOCALISATION["hre_reform_tooltip_unlocked"].."[[/rgba]]";
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
		cm:save_value("mkHRE.current_reform", mkHRE.current_reform, context);
		SaveTable(context, mkHRE.reforms_votes, "mkHRE.reforms_votes");
	end
);

cm:register_loading_game_callback(
	function(context)
		mkHRE.current_reform = cm:load_value("mkHRE.current_reform", 0, context);
		mkHRE.reforms_votes = LoadTable(context, "mkHRE.reforms_votes");
	end
);