------------------------------------------------------------------------------
------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - SLOTS
-- 	By: DETrooper
--
------------------------------------------------------------------------------
------------------------------------------------------------------------------

local dev = require("lua_scripts.dev");

function Add_MK1212_Slots_Listeners()
	cm:add_listener(
		"OnPanelOpenedCampaign_Slots_UI",
		"PanelOpenedCampaign",
		true,
		function(context) OnPanelOpenedCampaign_Slots_UI(context) end,
		true
	);
	cm:add_listener(
		"OnTimeTrigger_Slots_UI",
		"TimeTrigger",
		true,
		function(context) OnTimeTrigger_Slots_UI(context) end,
		true
	);

	if cm:is_new_game() then
		local faction_list = cm:model():world():faction_list();
		
		for i = 0, faction_list:num_items() - 1 do
			local current_faction = faction_list:item_at(i);
			
			if current_faction:is_horde() == false then
				if current_faction:is_human() == true then
					local regions = current_faction:region_list();

					for j = 0, regions:num_items() - 1 do
						local region = regions:item_at(j);
						local slot_list = region:settlement():slot_list();

						dev.log("Region: "..region:name().." # of slots: "..slot_list:num_items());

						for k = 0, slot_list:num_items() - 1 do
							local slot = slot_list:item_at(k);
							dev.log("Slot "..k..": "..slot:name());
							dev.log("Slot type: "..slot:type());

							if slot:has_building() then
								dev.log("Slot building: "..slot:building():name());
							end
						end
					end
				end
			end
		end
	end
end

function OnPanelOpenedCampaign_Slots_UI(context)
	if context.string == "settlement_panel" then
		cm:add_time_trigger("Slots_Visible", 1);
	end
end

function OnTimeTrigger_Slots_UI(context)
	if context.string == "Slots_Visible" then
		local root = cm:ui_root();
		local main_settlement_panel_uic = UIComponent(root:Find("main_settlement_panel"));

		for i = 0, main_settlement_panel_uic:ChildCount() - 1 do
			local child = UIComponent(main_settlement_panel_uic:Find(i));

			if child:Id() == "capital" then
				local settlement_uic = UIComponent(child:Find("settlement_capital"));
				local slot_1_uic = UIComponent(settlement_uic:Find("building_slot_1"));
				local slot_2_uic = UIComponent(settlement_uic:Find("building_slot_2"));
				local slot_3_uic = UIComponent(settlement_uic:Find("building_slot_3"));
				local slot_4_uic = UIComponent(settlement_uic:Find("building_slot_4"));
				local slot_5_uic = UIComponent(settlement_uic:Find("building_slot_5"));
				local slot_6_uic = UIComponent(settlement_uic:Find("building_slot_6"));
				local slot_7_uic = UIComponent(settlement_uic:Find("building_slot_7"));

				output_uicomponent(slot_1_uic);
				output_uicomponent(slot_2_uic);
				output_uicomponent(slot_3_uic);
				output_uicomponent(slot_4_uic);
				output_uicomponent(slot_5_uic);
				output_uicomponent(slot_6_uic);
				output_uicomponent(slot_7_uic);

				dev.log(slot_6_uic:CallbackId());
				dev.log(slot_7_uic:CallbackId());
			end
		end
	end
end

function uicomponent_to_str(uic)
	if not is_uicomponent(uic) then
		return "";
	end;
	
	if uic:Id() == "root" then
		return "root";
	else
		return uicomponent_to_str(UIComponent(uic:Parent())) .. " > " .. uic:Id();
	end;	
end;

function output_uicomponent(uic)
	if not is_uicomponent(uic) then
		return;
	end;
	
	local out = false;
	
	if __game_mode == __lib_type_campaign then
		out = output;
	else
		if __game_mode == __lib_type_battle then
			local bm = get_bm();
			
			out = function(str) bm:out(str) end;
		else
			out = print;
		end;
	end;
	
	-- not sure how this can happen, but it does ...
	if not pcall(function() out("uicomponent " .. tostring(uic:Id()) .. ":") end) then
		out("output_uicomponent() called but supplied component seems to not be valid, so aborting");
		return;
	end;
	
	if __game_mode == __lib_type_campaign then
		inc_tab();
	end;
	
	dev.log("path from root:\t\t" .. uicomponent_to_str(uic));
	
	local pos_x, pos_y = uic:Position();
	local size_x, size_y = uic:Bounds();

	dev.log("position on screen:\t" .. tostring(pos_x) .. ", " .. tostring(pos_y));
	dev.log("size:\t\t\t" .. tostring(size_x) .. ", " .. tostring(size_y));
	dev.log("state:\t\t" .. tostring(uic:CurrentState()));
	dev.log("visible:\t\t" .. tostring(uic:Visible()));
	dev.log("priority:\t\t" .. tostring(uic:Priority()));
	dev.log("children:");
	
	if __game_mode == __lib_type_campaign then
		inc_tab();
	end;
	
	for i = 0, uic:ChildCount() - 1 do
		local child = UIComponent(uic:Find(i));
		
		dev.log(tostring(i) .. ": " .. child:Id());
	end;
	
	if __game_mode == __lib_type_campaign then
		dec_tab();
		dec_tab();
	end;

	dev.log("");
end;