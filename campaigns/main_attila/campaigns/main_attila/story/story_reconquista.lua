----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - STORY: RECONQUISTA
-- 	By: DETrooper
--
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------

ARAGON_KEY = "mk_fact_aragon";
CASTILE_KEY = "mk_fact_castile";
NAVARRE_KEY = "mk_fact_navarre";
PORTUGAL_KEY = "mk_fact_portugal";
RECONQUISTA_MISSION_TURN = 3;

ARAGON_RELIGION = "att_rel_chr_catholic";
CASTILE_RELIGION = "att_rel_chr_catholic";
NAVARRE_RELIGION = "att_rel_chr_catholic";
PORTUGAL_RELIGION = "att_rel_chr_catholic";
RECONQUISTA_COMPLETE = false;

REGIONS_SPAIN_RECONQUISTA = {
	"att_reg_baetica_corduba",
	"att_reg_baetica_hispalis",
	"att_reg_baetica_malaca",
	"att_reg_carthaginensis_carthago_nova",
	"att_reg_carthaginensis_segobriga",
	"att_reg_carthaginensis_toletum",
	"att_reg_gallaecia_asturica",
	"att_reg_gallaecia_bracara",
	"att_reg_gallaecia_brigantium",
	"att_reg_lusitania_emerita_augusta",
	"att_reg_lusitania_pax_augusta",
	"att_reg_lusitania_olisipo",
	"att_reg_tarraconensis_caesaraugusta",
	"att_reg_tarraconensis_pompaelo",
	"att_reg_tarraconensis_tarraco"
};

function Add_Reconquista_Story_Events_Listeners()
	if RECONQUISTA_COMPLETE == false then
		cm:add_listener(
			"FactionTurnStart_Reconquista",
			"FactionTurnStart",
			true,
			function(context) FactionTurnStart_Reconquista(context) end,
			true
		);
	end
end

function FactionTurnStart_Reconquista(context)
	local faction_name = context:faction():name();

	if faction_name == ARAGON_KEY or faction_name == CASTILE_KEY or faction_name == NAVARRE_KEY or faction_name == PORTUGAL_KEY then
		local turn_number = cm:model():turn_number();
		local regions_catholic = Are_Regions_Religion("att_rel_chr_catholic", REGIONS_SPAIN_RECONQUISTA);

		if context:faction():is_human() then
			if turn_number == RECONQUISTA_MISSION_TURN and context:faction():state_religion() == "att_rel_chr_catholic" then
				cm:trigger_mission(faction_name, "mk_mission_story_reconquista_spain");
			elseif turn_number > RECONQUISTA_MISSION_TURN and context:faction():state_religion() ~= "att_rel_chr_catholic" then
				if faction_name == ARAGON_KEY and ARAGON_RELIGION == "att_rel_chr_catholic" then
					cm:override_mission_succeeded_status(ARAGON_KEY, "mk_mission_story_reconquista_spain", false);
					ARAGON_RELIGION = context:faction():state_religion();
				elseif faction_name == CASTILE_KEY and CASTILE_RELIGION == "att_rel_chr_catholic" then
					cm:override_mission_succeeded_status(CASTILE_KEY, "mk_mission_story_reconquista_spain", false);
					CASTILE_RELIGION = context:faction():state_religion();
				elseif faction_name == NAVARRE_KEY and NAVARRE_RELIGION == "att_rel_chr_catholic" then
					cm:override_mission_succeeded_status(NAVARRE_KEY, "mk_mission_story_reconquista_spain", false);
					NAVARRE_RELIGION = context:faction():state_religion();
				elseif faction_name == PORTUGAL_KEY and PORTUGAL_RELIGION == "att_rel_chr_catholic" then
					cm:override_mission_succeeded_status(PORTUGAL_KEY, "mk_mission_story_reconquista_spain", false);
					PORTUGAL_RELIGION = context:faction():state_religion();
				end
			end
		end
		
		if regions_catholic == true and RECONQUISTA_COMPLETE == false then
			RECONQUISTA_COMPLETE = true;

			if ARAGON_RELIGION == "att_rel_chr_catholic" then
				cm:override_mission_succeeded_status(ARAGON_KEY, "mk_mission_story_reconquista_spain", true);
			end

			if CASTILE_RELIGION == "att_rel_chr_catholic" then
				cm:override_mission_succeeded_status(CASTILE_KEY, "mk_mission_story_reconquista_spain", true);
			end	

			if NAVARRE_RELIGION == "att_rel_chr_catholic" then
				cm:override_mission_succeeded_status(NAVARRE_KEY, "mk_mission_story_reconquista_spain", true);
			end

			if PORTUGAL_RELIGION == "att_rel_chr_catholic" then
				cm:override_mission_succeeded_status(PORTUGAL_KEY, "mk_mission_story_reconquista_spain", true);
			end

			local faction_list = cm:model():world():faction_list();

			for i = 0, faction_list:num_items() - 1 do
				local current_faction = faction_list:item_at(i);
				
				cm:show_message_event(
					current_faction:name(),
					"message_event_text_text_mk_event_spa_reconquista_title", 
					"message_event_text_text_mk_event_spa_reconquista_success_primary", 
					"message_event_text_text_mk_event_spa_reconquista_success_secondary", 
					true, 
					704
				);
			end
		end
	end	
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		cm:save_value("RECONQUISTA_COMPLETE", RECONQUISTA_COMPLETE, context);
	end
);

cm:register_loading_game_callback(
	function(context)
		RECONQUISTA_COMPLETE = cm:load_value("RECONQUISTA_COMPLETE", false, context);
	end
);