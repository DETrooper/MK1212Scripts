--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: HOLY ROMAN EMPIRE
-- 	By: DETrooper
--
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

mkHRE = {};

require("mechanics/hre/mechanics_hre_factions");
require("mechanics/hre/mechanics_hre_lists");
require("mechanics/hre/mechanics_hre_decrees");
require("mechanics/hre/mechanics_hre_elections");
require("mechanics/hre/mechanics_hre_events");
require("mechanics/hre/mechanics_hre_reforms");
require("mechanics/hre/mechanics_hre_regions");
require("mechanics/hre/mechanics_hre_ui");

mkHRE.destroyed = false;

function mkHRE:Add_HRE_Listeners()
	local faction_name = cm:get_local_faction();

	if not self.destroyed then
		if self.current_reform < 9 then
			self:Add_Faction_Listeners();
			self:Add_Decree_Listeners();
			self:Add_Election_Listeners();
			self:Add_Event_Listeners();
			self:Add_Reform_Listeners();
			self:Add_Region_Listeners();
		end
	end

	self:Add_UI_Listeners();

	if cm:is_new_game() and (table.HasValue(self.factions, faction_name) or self.emperor_pretender_key == faction_name) then
		cm:show_message_event(
			faction_name,
			"message_event_text_text_mk_event_mk1212_hreintro_title",
			"message_event_text_text_mk_event_mk1212_hreintro_primary",
			"message_event_text_text_mk_event_mk1212_hreintro_secondary",
			true, 
			713
		);
	end

	self:Button_Check();
end

function mkHRE:Button_Check()
	local root = cm:ui_root();
	local btnHRE = UIComponent(root:Find("button_hre"));
	local faction_name = cm:get_local_faction();

	if (table.HasValue(self.factions, faction_name) or faction_name == self.emperor_pretender_key) and self.current_reform < 9 then
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
		cm:save_value("mkHRE.destroyed", mkHRE.destroyed, context);
	end
);

cm:register_loading_game_callback(
	function(context)
		mkHRE.destroyed = cm:load_value("mkHRE.destroyed", false, context);
	end
);
