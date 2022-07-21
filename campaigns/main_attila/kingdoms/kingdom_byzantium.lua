----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - KINGDOM: BYZANTIUM
-- 	By: DETrooper
--
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------

EPIRUS_KEY = "mk_fact_epirus";
NICAEA_KEY = "mk_fact_nicaea";
TREBIZOND_KEY = "mk_fact_trebizond";
BYZANTINE_EMPIRE_FACTION = "NIL";

function Add_Kingdom_Byzantium_Listeners()
	if BYZANTINE_EMPIRE_FACTION == "NIL" then
		cm:add_listener(
			"FactionTurnStart_Byzantium_Check",
			"FactionTurnStart",
			true,
			function(context) Byzantium_Check(context) end,
			true
		);
		cm:add_listener(
			"CharacterEntersGarrison_Constantinople",
			"CharacterEntersGarrison",
			true,
			function(context) Constantinople_Check_Occupied(context) end,
			true
		);
		cm:add_listener(
			"MissionIssued_Byzantium",
			"MissionIssued",
			true,
			function(context) MissionIssued_Byzantium(context) end,
			true
		);
	end

	if cm:is_multiplayer() == false then
		Register_Decision(
			"restore_byzantine_empire", 
			function() 	
				local conditionstring = "Conditions:\n\n([[rgba:8:201:27:150]]Y[[/rgba]]) - Is the Empire of Nicaea, Empire of Trebizond, or Desposate of Epirus.\n([[rgba:8:201:27:150]]Y[[/rgba:8:201:27:150]]) - The Byzantine Empire does not exist.\n";
				local faction_name = cm:get_local_faction();

				if mkHRE and HasValue(mkHRE.factions, faction_name) then
					conditionstring = conditionstring.."([[rgba:255:0:0:150]]X[[/rgba]]) - Is not a member of the Holy Roman Empire.\n";
				else
					conditionstring = conditionstring.."([[rgba:8:201:27:150]]Y[[/rgba]]) - Is not a member of the Holy Roman Empire.\n";
				end
	
				if cm:model():world():region_manager():region_by_key("att_reg_thracia_constantinopolis"):owning_faction():name() == cm:get_local_faction() then
					conditionstring = conditionstring.."([[rgba:8:201:27:150]]Y[[/rgba]]) - Own the region of Constantinople.";
				else
					conditionstring = conditionstring.."([[rgba:255:0:0:150]]X[[/rgba]]) - Own the region of Constantinople.";		
				end
			
				conditionstring = conditionstring.."\n\nEffects:\n\n- Become the [[rgba:255:215:0:215]]Byzantine Empire[[/rgba]].";
			
				return conditionstring;
			end, 
			"att_reg_thracia_constantinopolis", 
			nil, 
			Byzantine_Empire_Restored
		);

		if cm:is_new_game() then
			local faction_name = cm:get_local_faction();
			
			if faction_name == EPIRUS_KEY or faction_name == NICAEA_KEY or faction_name == TREBIZOND_KEY then
				Add_Decision("restore_byzantine_empire", faction_name, false, true);
			end
		end
	end
end

function Byzantium_Check(context)
	local faction_name = context:faction():name();
	
	if faction_name == EPIRUS_KEY or faction_name == NICAEA_KEY or faction_name == TREBIZOND_KEY then
		Constantinople_Check(faction_name);
	end
end

function Constantinople_Check(faction_name)
	local region = cm:model():world():region_manager():region_by_key("att_reg_thracia_constantinopolis");
		
	if region:owning_faction():name() == faction_name then
		Constantinople_Taken(faction_name);
	else
		if cm:is_multiplayer() == false and cm:model():world():faction_by_key(faction_name):is_human() == true then
			Disable_Decision("restore_byzantine_empire");
		end
	end
end

function Constantinople_Check_Occupied(context)
	local faction_name = context:character():faction():name();

	if faction_name == EPIRUS_KEY or faction_name == NICAEA_KEY or faction_name == TREBIZOND_KEY then
		if context:character():region():name() == "att_reg_thracia_constantinopolis" then
			Constantinople_Taken(faction_name);
		end
	else
		if context:character():region():name() == "att_reg_thracia_constantinopolis" and cm:is_multiplayer() == false and context:character():faction():is_human() == true then
			Disable_Decision("restore_byzantine_empire");
		end
	end
end

function Constantinople_Taken(faction_name)
	if cm:is_multiplayer() == true or cm:model():world():faction_by_key(faction_name):is_human() == false then
		Byzantine_Empire_Restored(faction_name);
	elseif (not mkHRE or (mkHRE and HasValue(mkHRE.factions, faction_name) ~= true)) then
		Enable_Decision("restore_byzantine_empire");
	end
end

function Byzantine_Empire_Restored(faction_name)
	FACTIONS_DFN_LEVEL[faction_name] = 4;
	BYZANTINE_EMPIRE_FACTION = faction_name;
	Rename_Faction(faction_name, faction_name.."_lvl"..tostring(FACTIONS_DFN_LEVEL[faction_name]));

	Add_Byzantium_Reconquest_Listeners(); -- Moves to byzantium/byzantium_reconquest.lua

	if cm:is_multiplayer() == false then
		Remove_Decision("restore_byzantine_empire");

		if cm:model():world():faction_by_key(faction_name):is_human() then
			Add_Decision("restore_roman_empire", faction_name, false, true);
		end
	end

	cm:show_message_event(
		faction_name, 
		"message_event_text_text_mk_event_byz_empire_restored_title", 
		"message_event_text_text_mk_event_byz_empire_restored_primary",
		"message_event_text_text_mk_event_byz_empire_restored_secondary_"..faction_name,
		true, 
		718
	);

	cm:remove_listener("FactionTurnStart_Byzantium_Check");
	cm:remove_listener("CharacterEntersGarrison_Constantinople");
	cm:remove_listener("MissionIssued_Byzantium");
end

function MissionIssued_Byzantium(context)
	local faction_name = context:faction():name();

	if faction_name == EPIRUS_KEY or faction_name == NICAEA_KEY or faction_name == TREBIZOND_KEY then
		local mission_name = context:mission():mission_record_key();
		
		if mission_name == "mk_mission_kingdom_byzantium" then
			Constantinople_Check(faction_name);
		end
	end
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		cm:save_value("BYZANTINE_EMPIRE_FACTION", BYZANTINE_EMPIRE_FACTION, context);
	end
);

cm:register_loading_game_callback(
	function(context)
		BYZANTINE_EMPIRE_FACTION = cm:load_value("BYZANTINE_EMPIRE_FACTION", "NIL", context);
	end
);
