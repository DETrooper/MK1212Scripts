--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: HOLY ROMAN EMPIRE
-- 	By: DETrooper
--
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

require("mechanics/hre/mechanics_hre_factions");
require("mechanics/hre/mechanics_hre_lists");
require("mechanics/hre/mechanics_hre_decrees");
require("mechanics/hre/mechanics_hre_elections");
require("mechanics/hre/mechanics_hre_events");
require("mechanics/hre/mechanics_hre_reforms");
require("mechanics/hre/mechanics_hre_regions");
require("mechanics/hre/mechanics_hre_ui");

HRE_DESTROYED = false;
--HRE_MESSAGE_SHOWN = false;

function Add_HRE_Listeners()
	local faction_name = cm:get_local_faction();

	if not HRE_DESTROYED then
		if CURRENT_HRE_REFORM < 9 then
			Add_HRE_Faction_Listeners();
			Add_HRE_Decrees_Listeners();
			Add_HRE_Election_Listeners();
			Add_HRE_Event_Listeners();
			Add_HRE_Reforms_Listeners();
			Add_HRE_Region_Listeners();
		end
	end

	Add_HRE_UI_Listeners();

	if cm:is_new_game() and (HasValue(HRE_FACTIONS, faction_name) or HRE_EMPEROR_PRETENDER_KEY == faction_name) then
		cm:show_message_event(
			faction_name,
			"message_event_text_text_mk_event_mk1212_hreintro_title",
			"message_event_text_text_mk_event_mk1212_hreintro_primary",
			"message_event_text_text_mk_event_mk1212_hreintro_secondary",
			true, 
			713
		);

		--HRE_MESSAGE_SHOWN = true;
	end

	HRE_Button_Check();
end

function HRE_Button_Check()
	local root = cm:ui_root();
	local btnHRE = UIComponent(root:Find("button_hre"));
	local faction_name = cm:get_local_faction();

	if (HasValue(HRE_FACTIONS, faction_name) or faction_name == HRE_EMPEROR_PRETENDER_KEY) and CURRENT_HRE_REFORM < 9 then
		btnHRE:SetVisible(true);
	else
		btnHRE:SetVisible(false);
	end
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:register_saving_game_callback(
	function(context)
		cm:save_value("HRE_DESTROYED", HRE_DESTROYED, context);
		--cm:save_value("HRE_MESSAGE_SHOWN", HRE_MESSAGE_SHOWN, context);
	end
);

cm:register_loading_game_callback(
	function(context)
		HRE_DESTROYED = cm:load_value("HRE_DESTROYED", false, context);
		--HRE_MESSAGE_SHOWN = cm:load_value("HRE_MESSAGE_SHOWN", false, context);
	end
);
