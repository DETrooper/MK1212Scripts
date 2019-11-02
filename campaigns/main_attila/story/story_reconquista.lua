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
	local turn_number = cm:model():turn_number();
	local turn_faction = context:faction():name();

	if turn_faction == ARAGON_KEY or turn_faction == CASTILE_KEY or turn_faction == NAVARRE_KEY or turn_faction == PORTUGAL_KEY then
		local regions_catholic = Are_Regions_Religion("att_rel_chr_catholic", REGIONS_SPAIN_RECONQUISTA);

		if turn_number == RECONQUISTA_MISSION_TURN and cm:model():world():faction_by_key(turn_faction):is_human() then
			cm:trigger_mission(turn_faction, "mk_mission_story_reconquista_spain");
		end
		
		if regions_catholic == true and RECONQUISTA_COMPLETE == false then
			RECONQUISTA_COMPLETE = true;

			cm:override_mission_succeeded_status(ARAGON_KEY, "mk_mission_story_reconquista_spain", true);
			cm:override_mission_succeeded_status(CASTILE_KEY, "mk_mission_story_reconquista_spain", true);
			cm:override_mission_succeeded_status(NAVARRE_KEY, "mk_mission_story_reconquista_spain", true);
			cm:override_mission_succeeded_status(PORTUGAL_KEY, "mk_mission_story_reconquista_spain", true);

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
