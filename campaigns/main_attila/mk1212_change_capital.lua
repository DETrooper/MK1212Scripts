------------------------------------------------------------------------------
------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - CHANGE CAPITAL
-- 	By: DETrooper
--  .exe Created By: Mr. Jox
--
------------------------------------------------------------------------------
------------------------------------------------------------------------------

-- Todo: Fill in later.
local regions_to_arrays = {
	["att_reg_aegyptus_berenice"] = 120,
	["att_reg_aegyptus_oxyrhynchus"] = 121,
	["att_reg_aethiopia_adulis"] = 48,
	["att_reg_aethiopia_aksum"] = 42,
	["att_reg_aethiopia_pachoras"] = 43,
	["att_reg_africa_carthago"] = 144,
	["att_reg_africa_constantina"] = 72,
	["att_reg_africa_hadrumentum"] = 35,
	["att_reg_aquitania_avaricum"] = 54,
	["att_reg_aquitania_burdigala"] = 105,
	["att_reg_aquitania_elusa"] = 62,
	["att_reg_arabia_felix_eudaemon"] = 90,
	["att_reg_arabia_felix_omana"] = 55,
	["att_reg_arabia_felix_zafar"] = 65,
	["att_reg_arabia_magna_dumatha"] = 73,
	["att_reg_arabia_magna_hira"] = 49,
	["att_reg_arabia_magna_yathrib"] = 104,
	["att_reg_armenia_duin"] = 75,
	["att_reg_armenia_payttakaran"] = 184,
	["att_reg_armenia_tosp"] = 139,
	["att_reg_asia_cyzicus"] = 181,
	["att_reg_asia_ephesus"] = 122,
	["att_reg_asia_synnada"] = 14,
	["att_reg_asorstan_arbela"] = 74,
	["att_reg_asorstan_ctesiphon"] = 159,
	["att_reg_asorstan_meshan"] = 91,
	["att_reg_baetica_corduba"] = 183,
	["att_reg_baetica_hispalis"] = 123,
	["att_reg_baetica_malaca"] = 85,
	["att_reg_belgica_augusta_treverorum"] = 155,
	["att_reg_belgica_colonia_agrippina"] = 16,
	["att_reg_belgica_durocorterum"] = 64,
	["att_reg_bithynia_amasea"] = 179,
	["att_reg_bithynia_ancyra"] = 34,
	["att_reg_bithynia_nicomedia"] = 124,
	["att_reg_britannia_inferior_eboracum"] = 92,
	["att_reg_britannia_inferior_lindum"] = 56,
	["att_reg_britannia_inferior_segontium"] = 27,
	["att_reg_britannia_superior_camulodunon"] = 112,
	["att_reg_britannia_superior_corinium"] = 157,
	["att_reg_britannia_superior_londinium"] = 46,
	["att_reg_caledonia_et_hibernia_eblana"] = 28,
	["att_reg_caledonia_et_hibernia_eildon"] = 172,
	["att_reg_caledonia_et_hibernia_tuesis"] = 173,
	["att_reg_cappadocia_caesarea_eusebia"] = 88,
	["att_reg_cappadocia_melitene"] = 26,
	["att_reg_cappadocia_trapezus"] = 82,
	["att_reg_carthaginensis_carthago_nova"] = 99,
	["att_reg_carthaginensis_segobriga"] = 66,
	["att_reg_carthaginensis_toletum"] = 176,
	["att_reg_caucasia_gabala"] = 107,
	["att_reg_caucasia_kotais"] = 94,
	["att_reg_caucasia_mtskheta"] = 18,
	["att_reg_cilicia_iconium"] = 114,
	["att_reg_cilicia_myra"] = 153,
	["att_reg_cilicia_tarsus"] = 1,
	["att_reg_dacia_apulum"] = 76,
	["att_reg_dacia_petrodava"] = 150,
	["att_reg_dacia_romula"] = 141,
	["att_reg_dalmatia_domavia"] = 108,
	["att_reg_dalmatia_salona"] = 4,
	["att_reg_dalmatia_siscia"] = 149,
	["att_reg_dardania_scupi"] = 40,
	["att_reg_dardania_serdica"] = 37,
	["att_reg_dardania_viminacium"] = 38,
	["att_reg_frisia_angulus"] = 116,
	["att_reg_frisia_flevum"] = 47,
	["att_reg_frisia_tulifurdum"] = 39,
	["att_reg_gallaecia_asturica"] = 36,
	["att_reg_gallaecia_bracara"] = 126,
	["att_reg_gallaecia_brigantium"] = 125,
	["att_reg_germania_aregelia"] = 131,
	["att_reg_germania_lupfurdum"] = 58,
	["att_reg_germania_uburzis"] = 98,
	["att_reg_germano_sarmatia_duna"] = 169,
	["att_reg_germano_sarmatia_oium"] = 140,
	["att_reg_germano_sarmatia_palteskja"] = 151,
	["att_reg_gothiscandza_ascaucalis"] = 156,
	["att_reg_gothiscandza_gothiscandza"] = 89,
	["att_reg_gothiscandza_rugion"] = 142,
	["att_reg_hercynia_budorgis"] = 57,
	["att_reg_hercynia_casurgis"] = 50,
	["att_reg_hercynia_nitrahwa"] = 93,
	["att_reg_hyperborea_kariskos"] = 51,
	["att_reg_hyperborea_moramar"] = 9,
	["att_reg_hyperborea_sylis"] = 3,
	["att_reg_italia_fiorentia"] = 53,
	["att_reg_italia_neapolis"] = 109,
	["att_reg_italia_roma"] = 41,
	["att_reg_khwarasan_abarshahr"] = 152,
	["att_reg_khwarasan_harey"] = 44,
	["att_reg_khwarasan_merv"] = 45,
	["att_reg_libya_augila"] = 117,
	["att_reg_libya_paraetonium"] = 70,
	["att_reg_libya_ptolemais"] = 111,
	["att_reg_liguria_genua"] = 115,
	["att_reg_liguria_mediolanum"] = 17,
	["att_reg_liguria_segusio"] = 177,
	["att_reg_lugdunensis_lugdunum"] = 113,
	["att_reg_lugdunensis_rotomagus"] = 77,
	["att_reg_lugdunensis_turonum"] = 52,
	["att_reg_lusitania_emerita_augusta"] = 69,
	["att_reg_lusitania_olisipo"] = 135,
	["att_reg_lusitania_pax_augusta"] = 167,
	["att_reg_macedonia_corinthus"] = 118,
	["att_reg_macedonia_dyrrhachium"] = 170,
	["att_reg_macedonia_thessalonica"] = 154,
	["att_reg_magna_graecia_rhegium"] = 119,
	["att_reg_magna_graecia_syracusae"] = 59,
	["att_reg_magna_graecia_tarentum"] = 67,
	["att_reg_makran_harmosia"] = 174,
	["att_reg_makran_phra"] = 147,
	["att_reg_makran_pura"] = 127,
	["att_reg_mauretania_caesarea"] = 160,
	["att_reg_mauretania_tamousiga"] = 128,
	["att_reg_mauretania_tingis"] = 129,
	["att_reg_maxima_sequanorum_argentoratum"] = 60,
	["att_reg_maxima_sequanorum_octodurus"] = 130,
	["att_reg_maxima_sequanorum_vesontio"] = 132,
	["att_reg_media_atropatene_ecbatana"] = 29,
	["att_reg_media_atropatene_ganzaga"] = 71,
	["att_reg_media_atropatene_rhaga"] = 61,
	["att_reg_mediterraneus_occidentalis_ajax"] = 168,
	["att_reg_mediterraneus_occidentalis_caralis"] = 101,
	["att_reg_mediterraneus_occidentalis_palma"] = 79,
	["att_reg_mediterraneus_orientalis_constantia"] = 19,
	["att_reg_mediterraneus_orientalis_gortyna"] = 83,
	["att_reg_mediterraneus_orientalis_rhodes"] = 20,
	["att_reg_narbonensis_aquae_sextiae"] = 133,
	["att_reg_narbonensis_narbo"] = 161,
	["att_reg_narbonensis_vienna"] = 63,
	["att_reg_osroene_amida"] = 68,
	["att_reg_osroene_edessa"] = 6,
	["att_reg_osroene_nisibis"] = 78,
	["att_reg_palaestinea_aelia_capitolina"] = 185,
	["att_reg_palaestinea_aila"] = 80,
	["att_reg_palaestinea_nova_trajana_bostra"] = 162,
	["att_reg_pannonia_savaria"] = 81,
	["att_reg_pannonia_sirmium"] = 171,
	["att_reg_pannonia_sopianae"] = 148,
	["att_reg_persis_behdeshir"] = 145,
	["att_reg_persis_siraf"] = 0,
	["att_reg_persis_stakhr"] = 21,
	["att_reg_phazania_cydamus"] = 146,
	["att_reg_phazania_dimmidi"] = 84,
	["att_reg_phazania_garama"] = 86,
	["att_reg_raetia_et_noricum_augusta_vindelicorum"] = 15,
	["att_reg_raetia_et_noricum_iuvavum"] = 87,
	["att_reg_raetia_et_noricum_virunum"] = 164,
	["att_reg_sarmatia_asiatica_anacopia"] = 2,
	["att_reg_sarmatia_asiatica_samandar"] = 106,
	["att_reg_sarmatia_asiatica_tanais"] = 12,
	["att_reg_sarmatia_europaea_chersonessus"] = 25,
	["att_reg_sarmatia_europaea_gelonus"] = 7,
	["att_reg_sarmatia_europaea_olbia"] = 175,
	["att_reg_scandza_alabu"] = 95,
	["att_reg_scandza_hafn"] = 96,
	["att_reg_scandza_hrefnesholt"] = 178,
	["att_reg_scythia_bolghar"] = 97,
	["att_reg_scythia_ra"] = 163,
	["att_reg_scythia_sarai"] = 100,
	["att_reg_spahan_issatis"] = 180,
	["att_reg_spahan_spahan"] = 102,
	["att_reg_spahan_susa"] = 103,
	["att_reg_syria_antiochia"] = 5,
	["att_reg_syria_emesa"] = 110,
	["att_reg_syria_tyrus"] = 134,
	["att_reg_tarraconensis_caesaraugusta"] = 11,
	["att_reg_tarraconensis_pompaelo"] = 22,
	["att_reg_tarraconensis_tarraco"] = 30,
	["att_reg_thracia_constantinopolis"] = 165,
	["att_reg_thracia_marcianopolis"] = 10,
	["att_reg_thracia_trimontium"] = 136,
	["att_reg_transcarpathia_arheimar"] = 137,
	["att_reg_transcarpathia_belz"] = 31,
	["att_reg_transcarpathia_leopolis"] = 138,
	["att_reg_transcaspia_dahistan"] = 143,
	["att_reg_transcaspia_kath"] = 166,
	["att_reg_transcaspia_siahkuh"] = 182,
	["att_reg_tripolitana_leptis_magna"] = 8,
	["att_reg_tripolitana_macomades"] = 13,
	["att_reg_tripolitana_sabrata"] = 23,
	["att_reg_venetia_aquileia"] = 24,
	["att_reg_venetia_ravenna"] = 32,
	["att_reg_venetia_verona"] = 33,
};

function Add_MK1212_Change_Capital_Listeners()
	cm:add_listener(
		"OnComponentLClickUp_Change_Capital_UI",
		"ComponentLClickUp",
		true,
		function(context) OnComponentLClickUp_Change_Capital_UI(context) end,
		true
	);
	cm:add_listener(
		"OnSettlementSelected_Change_Capital_UI",
		"SettlementSelected",
		true,
		function(context) OnSettlementSelected_Change_Capital_UI(context) end,
		true
	);
	cm:add_listener(
		"OnPanelOpenedCampaign_Change_Capital_UI",
		"PanelOpenedCampaign",
		true,
		function(context) OnPanelOpenedCampaign_Change_Capital_UI(context) end,
		true
	);
	cm:add_listener(
		"TimeTrigger_Change_Capital_UI",
		"TimeTrigger",
		true,
		function(context) TimeTrigger_Change_Capital_UI(context) end,
		true
	);

	-- Create prompt and set it invisible.
	UIComponent(cm:ui_root():CreateComponent("change_capital_prompt", "ui/new/popup_change_capital_prompt")):SetVisible(false);
end

function OnComponentLClickUp_Change_Capital_UI(context)
	if SETTLEMENT_PANEL_OPEN == true then
		local root = cm:ui_root();

		if context.string == "button_change_capital_ok" then
			local change_capital_prompt_uic = UIComponent(root:Find("change_capital_prompt"));

			change_capital_prompt_uic:SetVisible(false);
			
			if IRONMAN_ENABLED then
				Save_Game_Ironman(0.1);
			else
				cm:autosave_at_next_opportunity();
			end

			cm:add_time_trigger("Run_Change_Capital_Executable", 0.5);
			cm:add_time_trigger("Reload_Game", 3);
		elseif context.string == "button_change_capital" then
			local change_capital_prompt_uic = UIComponent(root:Find("change_capital_prompt"));

			if change_capital_prompt_uic:Visible() == true then
				change_capital_prompt_uic:SetVisible(false);
				change_capital_prompt_uic:UnLockPriority();
			else
				change_capital_prompt_uic:SetVisible(true);
				change_capital_prompt_uic:LockPriority(500);

				if REGION_SELECTED and REGION_SELECTED ~= "" then
					local heading_text = string.gsub(UI_LOCALISATION["change_capital_prompt_header"], "dy_region", REGIONS_NAMES_LOCALISATION[REGION_SELECTED] or "Unknown Region");

					UIComponent(change_capital_prompt_uic:Find("heading_txt")):SetStateText(heading_text);
				end
			end
		elseif context.string == "root" or context.string == "button_change_capital_cancel" then
			local change_capital_prompt_uic = UIComponent(root:Find("change_capital_prompt"));

			if change_capital_prompt_uic:Visible() == true then
				change_capital_prompt_uic:SetVisible(false);
				change_capital_prompt_uic:UnLockPriority();
			end
		else
			cm:add_time_trigger("Show_Change_Capital_Button", 0.1);
		end
	end
end

function OnSettlementSelected_Change_Capital_UI(context)
	if SETTLEMENT_PANEL_OPEN == true then
		cm:add_time_trigger("Show_Change_Capital_Button", 0);
	end
end

function OnPanelOpenedCampaign_Change_Capital_UI(context)
	if context.string == "settlement_panel" then
		cm:add_time_trigger("Show_Change_Capital_Button", 0);
	end
end

function TimeTrigger_Change_Capital_UI(context)
	if context.string == "Reload_Game" then
		local root = cm:ui_root();
		local change_capital_prompt_uic = UIComponent(root:Find("change_capital_prompt"));

		change_capital_prompt_uic:UnLockPriority();
		root:TriggerShortcut("quick_load");
	elseif context.string == "Run_Change_Capital_Executable" then
		local region_array = regions_to_arrays[REGION_SELECTED] + 1;

		if not region_array then
			return;
		end

		local exe_exists = util.fileExists("faction_capital_change.exe");
		local dll_exists = util.fileExists("faction_capital_change.dll");
		local json_exists = util.fileExists("faction_capital_change.deps.json");
		local json_config_exists = util.fileExists("faction_capital_change.runtimeconfig.json");

		if not exe_exists or not dll_exists or not json_exists or not json_config_exists then
			require("lua_scripts/change_capital_binaries");
	
			if not exe_exists then
				local changeCapitalExe = io.open("faction_capital_change.exe", "wb");
				local binary = "";
					
				for i = 1, #change_capital_exe_binaries do
					local number = tonumber("0x"..change_capital_exe_binaries[i]);
					local char = string.char(number);
		
					binary = binary..char;
				end
		
				changeCapitalExe:write(binary);
				changeCapitalExe:close();
			end

			if not dll_exists then
				local changeCapitalDll = io.open("faction_capital_change.dll", "wb");
				local binary = "";
					
				for i = 1, #change_capital_dll_binaries do
					local number = tonumber("0x"..change_capital_dll_binaries[i]);
					local char = string.char(number);
		
					binary = binary..char;
				end
		
				changeCapitalDll:write(binary);
				changeCapitalDll:close();
			end

			if not json_exists then
				local changeCapitalJson = io.open("faction_capital_change.deps.json", "wb");
				local binary = "";
					
				for i = 1, #change_capital_json_binaries do
					local number = tonumber("0x"..change_capital_json_binaries[i]);
					local char = string.char(number);
		
					binary = binary..char;
				end
		
				changeCapitalJson:write(binary);
				changeCapitalJson:close();
			end

			if not json_config_exists then
				local changeCapitalJsonConfig = io.open("faction_capital_change.runtimeconfig.json", "wb");
				local binary = "";
					
				for i = 1, #change_capital_json_config_binaries do
					local number = tonumber("0x"..change_capital_json_config_binaries[i]);
					local char = string.char(number);
		
					binary = binary..char;
				end
		
				changeCapitalJsonConfig:write(binary);
				changeCapitalJsonConfig:close();
			end
		end
	
		local command = "faction_capital_change.exe "..tostring(region_array).." attila";
	
		os.execute(command);
	elseif context.string == "Show_Change_Capital_Button" then
		if REGION_SELECTED ~= "" then
			local region = cm:model():world():region_manager():region_by_key(REGION_SELECTED);
			local region_owning_faction = region:owning_faction();
	
			if region_owning_faction:name() == cm:get_local_faction() then
				if region_owning_faction:has_home_region() and region_owning_faction:home_region():name() ~= region:name() then
					local root = cm:ui_root();
					local change_capital_prompt_uic = UIComponent(root:Find("change_capital_prompt"));

					if change_capital_prompt_uic:Visible() == true then
						change_capital_prompt_uic:SetVisible(false);
						change_capital_prompt_uic:UnLockPriority();
					end

					local button_change_capital_uic = find_uicomponent_by_table(root, {"settlement_panel", "main_settlement_panel", "capital", "button_change_capital"});

					if button_change_capital_uic then
						button_change_capital_uic:SetVisible(true);
					end
				end
			end
		end
	end
end
