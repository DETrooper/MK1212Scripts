------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - STORY: ARAGON
-- 	By: DETrooper
--
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------

ARAGON_KEY = "mk_fact_aragon";
FRANCE_KEY = "mk_fact_france";
TOULOUSE_KEY = "mk_fact_toulouse";
ARAGON_INTERVENTION_TURN = 2;

ARAGON_CHOICE_MADE = false;

TOULOUSE_SUPPORT_ARMY = 
	"mk_ara_t1_knights,mk_ara_t1_knights,".. -- Heavy Shock Cav
	"mk_ara_t1_spearmen_catalan,mk_ara_t1_spearmen,mk_ara_t1_pikemen,mk_ara_t1_pikemen,".. -- Spear Infantry
	"mk_tou_t1_dismounted_chevaliers,mk_ara_t1_swordsmen_catalan,mk_ara_t1_swordsmen,mk_ara_t1_swordsmen,".. -- Sword Infantry
	"mk_tou_t1_crossbowmen,mk_tou_t1_crossbowmen,mk_ara_t1_levy_crossbowmen,mk_ara_t1_levy_crossbowmen,mk_ara_t1_levy_crossbowmen,".. -- Missile Infantry
	"mk_tou_t1_mounted_crossbowmen,mk_tou_t1_mounted_crossbowmen"; -- Missile Cavalry

function Add_Aragon_Story_Events_Listeners()
	local aragon = cm:model():world():faction_by_key(ARAGON_KEY);

	cm:add_listener(
		"FactionTurnStart_Aragon",
		"FactionTurnStart",
		true,
		function(context) FactionTurnStart_Aragon(context) end,
		true
	);

	if aragon:is_human() == true then
		cm:add_listener(
			"DilemmaChoiceMadeEvent_Aragon",
			"DilemmaChoiceMadeEvent",
			true,
			function(context) DilemmaChoiceMadeEvent_Aragon(context) end,
			true
		);
	end
end

function FactionTurnStart_Aragon(context)
	if context:faction():name() == ARAGON_KEY then
		if cm:model():turn_number() == ARAGON_INTERVENTION_TURN and ARAGON_CHOICE_MADE == false then
			local france = cm:model():world():faction_by_key(FRANCE_KEY);
			local toulouse = cm:model():world():faction_by_key(TOULOUSE_KEY);

			if context:faction():state_religion() == "att_rel_chr_catholic" and context:faction():at_war_with(toulouse) == false and context:faction():at_war_with(france) == false then
				if context:faction():is_human() then
					cm:trigger_dilemma(ARAGON_KEY, "mk_dilemma_story_aragon_albigensian_intervention");
				else
					cm:force_declare_war(ARAGON_KEY, FRANCE_KEY);

					if france:is_human() then
						cm:show_message_event(
							FRANCE_KEY,
							"message_event_text_text_mk_event_albigensian_crusade_title", 
							"message_event_text_text_mk_event_fra_aragon_intervenes_bad_primary", 
							"message_event_text_text_mk_event_fra_aragon_intervenes_bad_secondary", 
							true,
							712
						);
					end

					if toulouse:is_human() then
						cm:show_message_event(
							TOULOUSE_KEY,
							"message_event_text_text_mk_event_albigensian_crusade_title", 
							"message_event_text_text_mk_event_tou_aragon_intervenes_primary", 
							"message_event_text_text_mk_event_tou_aragon_intervenes_secondary", 
							true,
							712
						);
					end

					if PAPAL_FAVOUR_SYSTEM_ACTIVE == true then
						Subtract_Pope_Favour(ARAGON_KEY, 3, "joined_toulouse");
					end

					ARAGON_CHOICE_MADE = true;
				end
			end
		end
	end
end

function DilemmaChoiceMadeEvent_Aragon(context)
	local aragon = cm:model():world():faction_by_key(ARAGON_KEY);

	if context:dilemma() == "mk_dilemma_story_aragon_albigensian_intervention" then
		local france = cm:model():world():faction_by_key(FRANCE_KEY);
		local toulouse = cm:model():world():faction_by_key(TOULOUSE_KEY);

		if context:choice() == 0 then
			-- Choice made to side with Toulouse.
			cm:force_declare_war(ARAGON_KEY, FRANCE_KEY);

			if france:is_human() then
				cm:show_message_event(
					FRANCE_KEY,
					"message_event_text_text_mk_event_albigensian_crusade_title", 
					"message_event_text_text_mk_event_fra_aragon_intervenes_bad_primary", 
					"message_event_text_text_mk_event_fra_aragon_intervenes_bad_secondary", 
					true,
					712
				);
			elseif toulouse:is_human() then
				cm:show_message_event(
					TOULOUSE_KEY,
					"message_event_text_text_mk_event_albigensian_crusade_title", 
					"message_event_text_text_mk_event_tou_aragon_intervenes_primary", 
					"message_event_text_text_mk_event_tou_aragon_intervenes_secondary", 
					true,
					712
				);
			end

			if PAPAL_FAVOUR_SYSTEM_ACTIVE == true then
				Subtract_Pope_Favour(ARAGON_KEY, 3, "joined_toulouse");
			end
		elseif context:choice() == 1 then
			-- Choice made to side with France.
			cm:force_declare_war(ARAGON_KEY, TOULOUSE_KEY);

			if france:is_human() then
				cm:show_message_event(
					FRANCE_KEY,
					"message_event_text_text_mk_event_albigensian_crusade_title", 
					"message_event_text_text_mk_event_fra_aragon_intervenes_primary", 
					"message_event_text_text_mk_event_fra_aragon_intervenes_secondary", 
					true,
					712
				);
			elseif toulouse:is_human() then
				cm:show_message_event(
					TOULOUSE_KEY,
					"message_event_text_text_mk_event_albigensian_crusade_title", 
					"message_event_text_text_mk_event_tou_aragon_intervenes_bad_primary", 
					"message_event_text_text_mk_event_tou_aragon_intervenes_bad_secondary", 
					true,
					712
				);
			end

			if PAPAL_FAVOUR_SYSTEM_ACTIVE == true then
				Add_Pope_Favour(ARAGON_KEY, 2, "joined_albigensian_crusade");
			end

			SetFactionsHostile(FRANCE_KEY, ARAGON_KEY); -- France is angry that you're trying to take Toulouse's regions before it can.
		elseif context:choice() == 2 then
			-- Choice made to give Toulouse monetary support.
			cm:create_force(
				TOULOUSE_KEY, 					-- name of faction
				TOULOUSE_SUPPORT_ARMY,			-- comma-separated units
				"att_reg_narbonensis_narbo", 			-- home region
				185,						-- x coordinate
				405,						-- y coordinate
				TOULOUSE_KEY.."_gifted_army", 			-- string id for army
				true,
				function(cqi)

				end
			);

			if france:is_human() then
				cm:show_message_event(
					FRANCE_KEY,
					"message_event_text_text_mk_event_albigensian_crusade_title", 
					"message_event_text_text_mk_event_fra_aragon_support_bad_primary", 
					"message_event_text_text_mk_event_fra_aragon_support_bad_secondary", 
					true,
					712
				);
			elseif toulouse:is_human() then
				cm:show_message_event(
					TOULOUSE_KEY,
					"message_event_text_text_mk_event_albigensian_crusade_title", 
					"message_event_text_text_mk_event_tou_aragon_support_primary", 
					"message_event_text_text_mk_event_tou_aragon_support_secondary", 
					true,
					712
				);
			end

			if PAPAL_FAVOUR_SYSTEM_ACTIVE == true then
				Subtract_Pope_Favour(ARAGON_KEY, 2, "supported_toulouse");
			end
		elseif context:choice() == 3 then
			-- Choice made to stay out of the Albigensian Crusade.
			if PAPAL_FAVOUR_SYSTEM_ACTIVE == true then
				Subtract_Pope_Favour(ARAGON_KEY, 1, "failed_to_join_albigensian_crusade");
			end
		end

		ARAGON_CHOICE_MADE = true;
	end
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		cm:save_value("ARAGON_CHOICE_MADE", ARAGON_CHOICE_MADE, context);
	end
);

cm:register_loading_game_callback(
	function(context)
		ARAGON_CHOICE_MADE = cm:load_value("ARAGON_CHOICE_MADE", false, context);
	end
);