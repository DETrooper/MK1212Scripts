-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - BYZANTIUM: RECONQUEST
-- 	By: DETrooper
--
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-- Whichever faction restores the Byzantine Empire will recieve messages for reconquering old Byzantine Empire provinces or key cities.
-- By reconquering all of these, the Byzantine Empire will form the Roman Empire.

BYZ_AFRICA = false;
BYZ_ANATOLA= false;
BYZ_DALMATIA = false;
BYZ_EGYPT = false;
BYZ_ITALY = false;
BYZ_GREECE = false;
BYZ_ORIENS = false;
LATIN_EMPIRE_DEAD = false;

ROMAN_EMPIRE_RESTORED = false;

function Add_Byzantium_Reconquest_Listeners()
	if ROMAN_EMPIRE_RESTORED == false then
		cm:add_listener(
			"FactionTurnStart_Byzantium_Regions_Check",
			"FactionTurnStart",
			true,
			function(context) FactionTurnStart_Byzantium_Regions_Check(context) end,
			true
		);
		cm:add_listener(
			"CharacterEntersGarrison_Byzantium_Regions_Check",
			"CharacterEntersGarrison",
			true,
			function(context) CharacterEntersGarrison_Byzantium_Regions_Check(context) end,
			true
		);
	end

	if cm:is_multiplayer() == false then
		Register_Decision(
			"restore_roman_empire", 
			function() 
				local faction_name = cm:get_local_faction();
				local has_regions_africa = Has_Required_Regions(BYZANTINE_EMPIRE_FACTION, BYZ_REGIONS_AFRICA);
				local has_regions_anatolia = Has_Required_Regions(BYZANTINE_EMPIRE_FACTION, BYZ_REGIONS_ANATOLIA);
				--local has_regions_cyrenaica = Has_Required_Regions(BYZANTINE_EMPIRE_FACTION, BYZ_REGIONS_CYRENAICA);
				local has_regions_dalmatia = Has_Required_Regions(BYZANTINE_EMPIRE_FACTION, BYZ_REGIONS_DALMATIA);
				local has_regions_egypt = Has_Required_Regions(BYZANTINE_EMPIRE_FACTION, BYZ_REGIONS_EGYPT);
				local has_regions_italy = Has_Required_Regions(BYZANTINE_EMPIRE_FACTION, BYZ_REGIONS_ITALY);
				local has_regions_greece = Has_Required_Regions(BYZANTINE_EMPIRE_FACTION, BYZ_REGIONS_GREECE);
				local has_regions_oriens = Has_Required_Regions(BYZANTINE_EMPIRE_FACTION, BYZ_REGIONS_ORIENS);
			
				local conditionstring = "Conditions:\n\n([[rgba:8:201:27:150]]Y[[/rgba]]) - Is the Byzantine Empire.\n([[rgba:8:201:27:150]]Y[[/rgba]]) - The Roman Empire does not exist.\n";
			
				if LATIN_EMPIRE_DEAD == true then
					conditionstring = conditionstring.."([[rgba:8:201:27:150]]Y[[/rgba]]) - The Latin Empire does not exist.\n";
				else
					conditionstring = conditionstring.."([[rgba:255:0:0:150]]X[[/rgba]]) - The Latin Empire does not exist.\n";
				end

				if mkHRE and HasValue(mkHRE.factions, faction_name) then
					conditionstring = conditionstring.."([[rgba:255:0:0:150]]X[[/rgba]]) - Is not a member of the Holy Roman Empire.\n";
				else
					conditionstring = conditionstring.."([[rgba:8:201:27:150]]Y[[/rgba]]) - Is not a member of the Holy Roman Empire.\n";
				end
			
				if cm:model():world():region_manager():region_by_key("att_reg_thracia_constantinopolis"):owning_faction():name() == BYZANTINE_EMPIRE_FACTION then
					conditionstring = conditionstring.."([[rgba:8:201:27:150]]Y[[/rgba]]) - Own the region of "..REGIONS_NAMES_LOCALISATION["att_reg_thracia_constantinopolis"]..".\n";
				else
					conditionstring = conditionstring.."([[rgba:255:0:0:150]]X[[/rgba]]) - Own the region of "..REGIONS_NAMES_LOCALISATION["att_reg_thracia_constantinopolis"]..".\n";
				end
			
				if has_regions_greece == true then
					conditionstring = conditionstring.."([[rgba:8:201:27:150]]Y[[/rgba]]) - Own the entirety of Greece.\n";
				else
					conditionstring = conditionstring.."([[rgba:255:0:0:150]]X[[/rgba]]) - Own the entirety of Greece.\n";
				end
			
				if has_regions_anatolia == true then
					conditionstring = conditionstring.."([[rgba:8:201:27:150]]Y[[/rgba]]) - Own the entirety of Anatolia.\n";
				else
					conditionstring = conditionstring.."([[rgba:255:0:0:150]]X[[/rgba]]) - Own the entirety of Anatolia.\n";
				end
			
				if has_regions_oriens == true then
					conditionstring = conditionstring.."([[rgba:8:201:27:150]]Y[[/rgba]]) - Own the entirety of the Levant.\n";
				else
					conditionstring = conditionstring.."([[rgba:255:0:0:150]]X[[/rgba]]) - Own the entirety of the Levant.\n";
				end
			
				if has_regions_egypt == true then
					conditionstring = conditionstring.."([[rgba:8:201:27:150]]Y[[/rgba]]) - Own the entirety of Egypt.\n";
				else
					conditionstring = conditionstring.."([[rgba:255:0:0:150]]X[[/rgba]]) - Own the entirety of Egypt.\n";
				end
				
				if has_regions_africa == true then
					conditionstring = conditionstring.."([[rgba:8:201:27:150]]Y[[/rgba]]) - Own the entirety of Tunisia and Tripolitania.\n";
				else
					conditionstring = conditionstring.."([[rgba:255:0:0:150]]X[[/rgba]]) - Own the entirety of Tunisia and Tripolitania.\n";
				end
			
				if has_regions_italy == true then
					conditionstring = conditionstring.."([[rgba:8:201:27:150]]Y[[/rgba]]) - Own the entirety of Italy.\n";
				else
					conditionstring = conditionstring.."([[rgba:255:0:0:150]]X[[/rgba]]) - Own the entirety of Italy.\n";
				end
			
				if has_regions_dalmatia == true then
					conditionstring = conditionstring.."([[rgba:8:201:27:150]]Y[[/rgba]]) - Own the entirety of Dalmatia.";
				else
					conditionstring = conditionstring.."([[rgba:255:0:0:150]]X[[/rgba]]) - Own the entirety of Dalmatia.";
				end
			
				conditionstring = conditionstring.."\n\nEffects:\n\n- Become the [[rgba:255:215:0:215]]Roman Empire[[/rgba]].";
			
				return conditionstring;
			end, 
			REGIONS_ROME, 
			{map_name = "kingdom_roman_empire_map", x = "1200", y = "900", map_pips = REGIONS_ROME_FACTION_PIPS_LOCATIONS},
			Roman_Empire_Restored
		);
	end
end

function FactionTurnStart_Byzantium_Regions_Check(context)
	if context:faction():name() == BYZANTINE_EMPIRE_FACTION then
		Byzantium_Regions_Check(context:faction():name());
	end
end

function CharacterEntersGarrison_Byzantium_Regions_Check(context)
	if context:character():faction():name() == BYZANTINE_EMPIRE_FACTION then
		Byzantium_Regions_Check(context:character():faction():name());
	end
end

function Byzantium_Regions_Check(faction_name)
	local latins = cm:model():world():faction_by_key(LATIN_EMPIRE_KEY);

	if latins:is_null_interface() == false then
		if latins:has_home_region() ~= true and latins:has_faction_leader() ~= true and latins:military_force_list():num_items() == 0 then
			LATIN_EMPIRE_DEAD = true;
		else
			LATIN_EMPIRE_DEAD = false;
		end
	end

	local has_constantinople = false;

	if cm:model():world():region_manager():region_by_key("att_reg_thracia_constantinopolis"):owning_faction():name() == faction_name then
		has_constantinople = true;
	end

	local has_regions_africa = Has_Required_Regions(faction_name, BYZ_REGIONS_AFRICA);
	local has_regions_anatolia = Has_Required_Regions(faction_name, BYZ_REGIONS_ANATOLIA);
	--local has_regions_cyrenaica = Has_Required_Regions(faction_name, BYZ_REGIONS_CYRENAICA);
	local has_regions_dalmatia = Has_Required_Regions(faction_name, BYZ_REGIONS_DALMATIA);
	local has_regions_egypt = Has_Required_Regions(faction_name, BYZ_REGIONS_EGYPT);
	local has_regions_italy = Has_Required_Regions(faction_name, BYZ_REGIONS_ITALY);
	local has_regions_greece = Has_Required_Regions(faction_name, BYZ_REGIONS_GREECE);
	local has_regions_oriens = Has_Required_Regions(faction_name, BYZ_REGIONS_ORIENS);

	--local has_regions_pentarchy = Has_Required_Regions(faction_name, BYZ_REGIONS_PENTARCHY);
	
	if has_regions_africa == true and BYZ_AFRICA == false then
		BYZ_AFRICA = true;
		cm:show_message_event(
			BYZANTINE_EMPIRE_FACTION, 
			"message_event_text_text_mk_event_byz_imperial_reconquest_title", 
			"message_event_text_text_mk_event_byz_africa_reconquered_primary", 
			"message_event_text_text_mk_event_byz_africa_reconquered_secondary", 
			true, 
			705
		);
	end;

	if has_regions_anatolia == true and BYZ_ANATOLIA == false then
		BYZ_ANATOLIA = true;
		cm:show_message_event(
			BYZANTINE_EMPIRE_FACTION, 
			"message_event_text_text_mk_event_byz_imperial_reconquest_title", 
			"message_event_text_text_mk_event_byz_anatolia_reconquered_primary", 
			"message_event_text_text_mk_event_byz_anatolia_reconquered_secondary", 
			true, 
			705
		);
	end;

	if has_regions_dalmatia == true and BYZ_DALMATIA == false then
		BYZ_DALMATIA = true;
		cm:show_message_event(
			BYZANTINE_EMPIRE_FACTION, 
			"message_event_text_text_mk_event_byz_imperial_reconquest_title", 
			"message_event_text_text_mk_event_byz_dalmatia_reconquered_primary", 
			"message_event_text_text_mk_event_byz_dalmatia_reconquered_secondary", 
			true, 
			705
		);
	end;

	if has_regions_egypt == true and BYZ_EGYPT == false then
		BYZ_EGYPT = true;
		cm:show_message_event(
			BYZANTINE_EMPIRE_FACTION, 
			"message_event_text_text_mk_event_byz_imperial_reconquest_title", 
			"message_event_text_text_mk_event_byz_egypt_reconquered_primary", 
			"message_event_text_text_mk_event_byz_egypt_reconquered_secondary", 
			true, 
			705
		);
	end;

	if has_regions_italy == true and BYZ_ITALY == false then
		BYZ_ITALY = true;
		cm:show_message_event(
			BYZANTINE_EMPIRE_FACTION, 
			"message_event_text_text_mk_event_byz_imperial_reconquest_title", 
			"message_event_text_text_mk_event_byz_italy_reconquered_primary", 
			"message_event_text_text_mk_event_byz_italy_reconquered_secondary", 
			true, 
			705
		);
	end;

	if has_regions_greece == true and BYZ_GREECE == false then
		BYZ_GREECE = true;
		cm:show_message_event(
			BYZANTINE_EMPIRE_FACTION, 
			"message_event_text_text_mk_event_byz_imperial_reconquest_title", 
			"message_event_text_text_mk_event_byz_greece_reconquered_primary", 
			"message_event_text_text_mk_event_byz_greece_reconquered_secondary", 
			true, 
			705
		);
	end;

	if has_regions_oriens == true and BYZ_ORIENS == false then
		BYZ_ORIENS = true;
		cm:show_message_event(
			BYZANTINE_EMPIRE_FACTION, 
			"message_event_text_text_mk_event_byz_imperial_reconquest_title", 
			"message_event_text_text_mk_event_byz_oriens_reconquered_primary", 
			"message_event_text_text_mk_event_byz_oriens_reconquered_secondary", 
			true, 
			705
		);
	end;

	if ROMAN_EMPIRE_RESTORED == false and LATIN_EMPIRE_DEAD == true and has_constantinople == true and has_regions_africa == true and has_regions_anatolia == true and has_regions_dalmatia == true and has_regions_egypt == true and has_regions_italy == true and has_regions_greece == true and has_regions_oriens == true then
		if cm:is_multiplayer() == true or cm:model():world():faction_by_key(faction_name):is_human() == false then
			Roman_Empire_Restored(faction_name);
		elseif (not mkHRE or (mkHRE and HasValue(mkHRE.factions, faction_name) ~= true)) then
			Enable_Decision("restore_roman_empire");
		end
	end
end

function Roman_Empire_Restored(faction_name)
	ROMAN_EMPIRE_RESTORED = true;
	Rename_Faction(BYZANTINE_EMPIRE_FACTION, "mk_faction_roman_empire");
	FACTIONS_DFN_LEVEL[BYZANTINE_EMPIRE_FACTION] = 5;

	if cm:is_multiplayer() == false then
		Remove_Decision("restore_roman_empire");

		if IRONMAN_ENABLED then
			Unlock_Achievement("achievement_basileia_rhomaion");
		end
	end

	cm:show_message_event(
		BYZANTINE_EMPIRE_FACTION, 
		"message_event_text_text_mk_event_byz_imperial_reconquest_title", 
		"message_event_text_text_mk_event_byz_roman_empire_restored_primary",
		"message_event_text_text_mk_event_byz_roman_empire_restored_secondary",
		true, 
		705
	);

	if NICKNAMES then
		Add_Character_Nickname(cm:model():world():faction_by_key(faction_name):faction_leader():cqi(), "the_glorious", false);
	end

	cm:remove_listener("FactionTurnStart_Byzantium_Regions_Check");
	cm:remove_listener("CharacterEntersGarrison_Byzantium_Regions_Check");
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		cm:save_value("BYZ_AFRICA", BYZ_AFRICA, context);
		cm:save_value("BYZ_ANATOLIA", BYZ_ANATOLIA, context);
		cm:save_value("BYZ_DALMATIA", BYZ_DALMATIA, context);
		cm:save_value("BYZ_EGYPT", BYZ_EGYPT, context);
		cm:save_value("BYZ_ITALY", BYZ_ITALY, context);
		cm:save_value("BYZ_GREECE", BYZ_GREECE, context);
		cm:save_value("BYZ_ORIENS", BYZ_ORIENS, context);
		cm:save_value("LATIN_EMPIRE_DEAD", LATIN_EMPIRE_DEAD, context);
		cm:save_value("ROMAN_EMPIRE_RESTORED", ROMAN_EMPIRE_RESTORED, context);
	end
);

cm:register_loading_game_callback(
	function(context)
		BYZ_AFRICA = cm:load_value("BYZ_AFRICA", false, context);
		BYZ_ANATOLIA = cm:load_value("BYZ_ANATOLIA", false, context);
		BYZ_DALMATIA = cm:load_value("BYZ_DALMATIA", false, context);
		BYZ_EGYPT = cm:load_value("BYZ_EGYPT", false, context);
		BYZ_ITALY = cm:load_value("BYZ_ITALY", false, context);
		BYZ_GREECE = cm:load_value("BYZ_GREECE", false, context);
		BYZ_ORIENS = cm:load_value("BYZ_ORIENS", false, context);
		LATIN_EMPIRE_DEAD = cm:load_value("LATIN_EMPIRE_DEAD", false, context);
		ROMAN_EMPIRE_RESTORED = cm:load_value("ROMAN_EMPIRE_RESTORED", false, context);
	end
);
