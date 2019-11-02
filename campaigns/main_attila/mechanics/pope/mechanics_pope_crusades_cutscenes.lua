----------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - MECHANICS: POPE CRUSADES CUTSCENES
-- 	By: DETrooper
--
----------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------
cam_base_h = 1.0699998140335;
cam_base_r = 0;

rome_cam_x = 210.7190246582;
rome_cam_y = 289.27972412109;

cairo_cam_x = 359.13610839844;
cairo_cam_y = 124.70960998535;

jerusalem_cam_x = 405.98037719727;
jerusalem_cam_y = 169.33947753906;

function Cutscene_Fifth_Crusade_Construct()
	local faction_name = cm:get_local_faction();
	local capital = cm:model():world():faction_by_key(faction_name):home_region();
	local has_capital = false; -- default to false
	local capital_x = 0;
	local capital_y = 0;

	if cm:model():world():faction_by_key(faction_name):has_home_region() == true then
		has_capital = true;
		capital_x = capital:settlement():logical_position_x();
		capital_y = capital:settlement():logical_position_y();
	end

	local cached_x, cached_y, cached_h, cached_r = CampaignUI.GetCameraPosition();

	cutscene_fifth_crusade = campaign_cutscene:new(
		"Cutscene_Fifth_Crusade",						-- string name for this cutscene
		60,								-- length of cutscene in seconds
		function() Cutscene_Fifth_Cruade_End() end				-- end callback
	);

	cutscene_fifth_crusade:set_skippable(true, function() Cutscene_Fifth_Crusade_Skipped() end);
	cutscene_fifth_crusade:set_skip_camera(cached_x, cached_y, cached_h,  cached_r);

	cutscene_fifth_crusade:action(function() cm:make_region_visible_in_shroud(faction_name, "att_reg_italia_roma") end, 0);
	cutscene_fifth_crusade:action(function() cm:make_region_visible_in_shroud(faction_name, "att_reg_aegyptus_oxyrhynchus") end, 0);
	cutscene_fifth_crusade:action(function() cm:make_region_visible_in_shroud(faction_name, "att_reg_palaestinea_aelia_capitolina") end, 0);
	
	cutscene_fifth_crusade:action(
		function() 
			cm:scroll_camera_with_direction(
				2, 
				{cached_x, cached_y, cached_h, cached_r},
				{cached_x, cached_y, cam_base_h, cam_base_r}
			) 
		end, 
		0
	);
	
	cutscene_fifth_crusade:action(
		function() 
			CampaignUI.ShowObjective("MK1212.Crusades.Cutscene_01", 18000, 500);
			cm:scroll_camera_with_direction(
				5, 
				{cached_x, cached_y, cam_base_h, cam_base_r},
				{rome_cam_x, rome_cam_y, cam_base_h, cam_base_r}
			) 
		end, 
		2
	);

	cutscene_fifth_crusade:action(
		function() 
			cm:scroll_camera_with_direction(
				5, 
				{rome_cam_x, rome_cam_y, cam_base_h, cam_base_r},
				{rome_cam_x, rome_cam_y, cam_base_h, cam_base_r - 0.15}
			) 
		end, 
		7
	);
	
	cutscene_fifth_crusade:action(
		function() 
			cm:scroll_camera_with_direction(
				10, 
				{rome_cam_x, rome_cam_y, cam_base_h, cam_base_r - 0.15},
				{cairo_cam_x, cairo_cam_y, cam_base_h, cam_base_r}
			) 
		end, 
		12
	);

	cutscene_fifth_crusade:action(
		function() 
			CampaignUI.ShowObjective("MK1212.Crusades.Cutscene_02", 18000, 500);
			cm:scroll_camera_with_direction(
				5, 
				{cairo_cam_x, cairo_cam_y, cam_base_h, cam_base_r},
				{cairo_cam_x, cairo_cam_y, cam_base_h, cam_base_r - 0.15}
			) 
		end, 
		22
	);
	
	cutscene_fifth_crusade:action(
		function() 
			cm:scroll_camera_with_direction(
				10, 
				{cairo_cam_x, cairo_cam_y, cam_base_h, cam_base_r - 0.15},
				{jerusalem_cam_x, jerusalem_cam_y, cam_base_h, cam_base_r}
			) 
		end, 
		27
	);

	cutscene_fifth_crusade:action(
		function() 
			cm:scroll_camera_with_direction(
				5, 
				{jerusalem_cam_x, jerusalem_cam_y, cam_base_h, cam_base_r},
				{jerusalem_cam_x, jerusalem_cam_y, cam_base_h, cam_base_r - 0.15}
			) 
		end, 
		37
	);

	cutscene_fifth_crusade:action(
		function() 
			local faction = cm:model():world():faction_by_key(faction_name);

			if faction:state_religion() == "att_rel_chr_catholic" then
				CampaignUI.ShowObjective("MK1212.Crusades.Cutscene_03", 18000, 500);
			elseif faction_name == CURRENT_CRUSADE_TARGET_OWNER then
				CampaignUI.ShowObjective("MK1212.Crusades.Cutscene_03_Crusade_Target", 18000, 500);
			else
				CampaignUI.ShowObjective("MK1212.Crusades.Cutscene_03_Non_Christian", 18000, 500);				
			end

			if has_capital == true then
				cm:scroll_camera_with_direction(
					5, 
					{jerusalem_cam_x, jerusalem_cam_y, cam_base_h, cam_base_r - 0.15},
					{capital_x * 0.67, capital_y * 0.76, cam_base_h, cam_base_r}
				)
			else
				cm:scroll_camera_with_direction(
					5, 
					{jerusalem_cam_x, jerusalem_cam_y, cam_base_h, cam_base_r - 0.15},
					{cached_x, cached_y, cam_base_h, cam_base_r}
				)				
			end
		end, 
		42
	);

	cutscene_fifth_crusade:action(
		function() 
			if has_capital == true then
				cm:scroll_camera_with_direction(
					2, 
					{capital_x * 0.67, capital_y * 0.76, cam_base_h, cam_base_r},
					{capital_x * 0.67, capital_y * 0.76, cached_h, cached_r}
				) 
			else
				cm:scroll_camera_with_direction(
					2, 
					{cached_x, cached_y, cam_base_h, cam_base_r},
					{cached_x, cached_y, cached_h, cached_r}
				) 
			end
		end, 
		58
	);

	cutscene_fifth_crusade:start();
end;

function Cutscene_Fifth_Crusade_Skipped()
	Cutscene_Fifth_Cruade_End();
end;

function Cutscene_Fifth_Cruade_End()
	ui_state.events_rollout:set_allowed(true);
	ui_state.events_panel:set_allowed(true);
	Force_Declare_Wars_Crusade(5);
end;

-------------------------------------------------------
--	Construct and then start the cutscene
-------------------------------------------------------

function Cutscene_Fifth_Crusade_Play()
	local root = cm:ui_root();
	local btnDecisions = UIComponent(root:Find("Decisions_Button"));
	local btnCrusade = UIComponent(root:Find("Crusade_Button"));
	btnDecisions:SetVisible(false);
	btnCrusade:SetVisible(false);

	ui_state.events_rollout:set_allowed(false, true);
	ui_state.events_panel:set_allowed(false, true);
	Cutscene_Fifth_Crusade_Construct();
end;