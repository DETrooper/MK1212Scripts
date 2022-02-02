------------------------------------------------------------------------------
------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - CHANGE CAPITAL
-- 	By: DETrooper
--  .exe Created By: Mr. Jox
--
------------------------------------------------------------------------------
------------------------------------------------------------------------------

local debug = false;
local regions_to_arrays = {
	[1] = "att_reg_persis_siraf",
	[2] = "att_reg_cilicia_tarsus",
	[3] = "att_reg_sarmatia_asiatica_anacopia",
	[4] = "att_reg_hyperborea_sylis",
	[5] = "att_reg_dalmatia_salona",
	[6] = "att_reg_syria_antiochia",
	[7] = "att_reg_osroene_edessa",
	[8] = "att_reg_sarmatia_europaea_gelonus",
	[9] = "att_reg_tripolitana_leptis_magna",
	[10] = "att_reg_hyperborea_moramar",
	[11] = "att_reg_thracia_marcianopolis",
	[12] = "att_reg_tarraconensis_caesaraugusta",
	[13] = "att_reg_sarmatia_asiatica_tanais",
	[14] = "att_reg_tripolitana_macomades",
	[15] = "att_reg_asia_synnada",
	[16] = "att_reg_raetia_et_noricum_augusta_vindelicorum",
	[17] = "att_reg_belgica_colonia_agrippina",
	[18] = "att_reg_liguria_mediolanum",
	[19] = "att_reg_caucasia_mtskheta",
	[20] = "att_reg_mediterraneus_orientalis_constantia",
	[21] = "att_reg_mediterraneus_orientalis_rhodes",
	[22] = "att_reg_persis_stakhr",
	[23] = "att_reg_tarraconensis_pompaelo",
	[24] = "att_reg_tripolitana_sabrata",
	[25] = "att_reg_venetia_aquileia",
	[26] = "att_reg_sarmatia_europaea_chersonessus",
	[27] = "att_reg_cappadocia_melitene",
	[28] = "att_reg_britannia_inferior_segontium",
	[29] = "att_reg_caledonia_et_hibernia_eblana",
	[30] = "att_reg_media_atropatene_ecbatana",
	[31] = "att_reg_tarraconensis_tarraco",
	[32] = "att_reg_transcarpathia_belz",
	[33] = "att_reg_venetia_ravenna",
	[34] = "att_reg_venetia_verona",
	[35] = "att_reg_bithynia_ancyra",
	[36] = "att_reg_africa_hadrumentum",
	[37] = "att_reg_gallaecia_asturica",
	[38] = "att_reg_dardania_serdica",
	[39] = "att_reg_dardania_viminacium",
	[40] = "att_reg_frisia_tulifurdum",
	[41] = "att_reg_dardania_scupi",
	[42] = "att_reg_italia_roma",
	[43] = "att_reg_aethiopia_aksum",
	[44] = "att_reg_aethiopia_pachoras",
	[45] = "att_reg_khwarasan_harey",
	[46] = "att_reg_khwarasan_merv",
	[47] = "att_reg_britannia_superior_londinium",
	[48] = "att_reg_frisia_flevum",
	[49] = "att_reg_aethiopia_adulis",
	[50] = "att_reg_arabia_magna_hira",
	[51] = "att_reg_hercynia_casurgis",
	[52] = "att_reg_hyperborea_kariskos",
	[53] = "att_reg_lugdunensis_turonum",
	[54] = "att_reg_italia_fiorentia",
	[55] = "att_reg_aquitania_avaricum",
	[56] = "att_reg_arabia_felix_omana",
	[57] = "att_reg_britannia_inferior_lindum",
	[58] = "att_reg_hercynia_budorgis",
	[59] = "att_reg_germania_lupfurdum",
	[60] = "att_reg_magna_graecia_syracusae",
	[61] = "att_reg_maxima_sequanorum_argentoratum",
	[62] = "att_reg_media_atropatene_rhaga",
	[63] = "att_reg_aquitania_elusa",
	[64] = "att_reg_narbonensis_vienna",
	[65] = "att_reg_belgica_durocorterum",
	[66] = "att_reg_arabia_felix_zafar",
	[67] = "att_reg_carthaginensis_segobriga",
	[68] = "att_reg_magna_graecia_tarentum",
	[69] = "att_reg_osroene_amida",
	[70] = "att_reg_lusitania_emerita_augusta",
	[71] = "att_reg_libya_paraetonium",
	[72] = "att_reg_media_atropatene_ganzaga",
	[73] = "att_reg_africa_constantina",
	[74] = "att_reg_arabia_magna_dumatha",
	[75] = "att_reg_asorstan_arbela",
	[76] = "att_reg_armenia_duin",
	[77] = "att_reg_dacia_apulum",
	[78] = "att_reg_lugdunensis_rotomagus",
	[79] = "att_reg_osroene_nisibis",
	[80] = "att_reg_mediterraneus_occidentalis_palma",
	[81] = "att_reg_palaestinea_aila",
	[82] = "att_reg_pannonia_savaria",
	[83] = "att_reg_cappadocia_trapezus",
	[84] = "att_reg_mediterraneus_orientalis_gortyna",
	[85] = "att_reg_phazania_dimmidi",
	[86] = "att_reg_baetica_malaca",
	[87] = "att_reg_phazania_garama",
	[88] = "att_reg_raetia_et_noricum_iuvavum",
	[89] = "att_reg_cappadocia_caesarea_eusebia",
	[90] = "att_reg_gothiscandza_gothiscandza",
	[91] = "att_reg_arabia_felix_eudaemon",
	[92] = "att_reg_asorstan_meshan",
	[93] = "att_reg_britannia_inferior_eboracum",
	[94] = "att_reg_hercynia_nitrahwa",
	[95] = "att_reg_caucasia_kotais",
	[96] = "att_reg_scandza_alabu",
	[97] = "att_reg_scandza_hafn",
	[98] = "att_reg_scythia_bolghar",
	[99] = "att_reg_germania_uburzis",
	[100] = "att_reg_carthaginensis_carthago_nova",
	[101] = "att_reg_scythia_sarai",
	[102] = "att_reg_mediterraneus_occidentalis_caralis",
	[103] = "att_reg_spahan_spahan",
	[104] = "att_reg_spahan_susa",
	[105] = "att_reg_arabia_magna_yathrib",
	[106] = "att_reg_aquitania_burdigala",
	[107] = "att_reg_sarmatia_asiatica_samandar",
	[108] = "att_reg_caucasia_gabala",
	[109] = "att_reg_dalmatia_domavia",
	[110] = "att_reg_italia_neapolis",
	[111] = "att_reg_syria_emesa",
	[112] = "att_reg_libya_ptolemais",
	[113] = "att_reg_britannia_superior_camulodunon",
	[114] = "att_reg_lugdunensis_lugdunum",
	[115] = "att_reg_cilicia_iconium",
	[116] = "att_reg_liguria_genua",
	[117] = "att_reg_frisia_angulus",
	[118] = "att_reg_libya_augila",
	[119] = "att_reg_macedonia_corinthus",
	[120] = "att_reg_magna_graecia_rhegium",
	[121] = "att_reg_aegyptus_berenice",
	[122] = "att_reg_aegyptus_oxyrhynchus",
	[123] = "att_reg_asia_ephesus",
	[124] = "att_reg_baetica_hispalis",
	[125] = "att_reg_bithynia_nicomedia",
	[126] = "att_reg_gallaecia_brigantium",
	[127] = "att_reg_gallaecia_bracara",
	[128] = "att_reg_makran_pura",
	[129] = "att_reg_mauretania_tamousiga",
	[130] = "att_reg_mauretania_tingis",
	[131] = "att_reg_maxima_sequanorum_octodurus",
	[132] = "att_reg_germania_aregelia",
	[133] = "att_reg_maxima_sequanorum_vesontio",
	[134] = "att_reg_narbonensis_aquae_sextiae",
	[135] = "att_reg_syria_tyrus",
	[136] = "att_reg_lusitania_olisipo",
	[137] = "att_reg_thracia_trimontium",
	[138] = "att_reg_transcarpathia_arheimar",
	[139] = "att_reg_transcarpathia_leopolis",
	[140] = "att_reg_armenia_tosp",
	[141] = "att_reg_germano_sarmatia_oium",
	[142] = "att_reg_dacia_romula",
	[143] = "att_reg_gothiscandza_rugion",
	[144] = "att_reg_transcaspia_dahistan",
	[145] = "att_reg_africa_carthago",
	[146] = "att_reg_persis_behdeshir",
	[147] = "att_reg_phazania_cydamus",
	[148] = "att_reg_makran_phra",
	[149] = "att_reg_pannonia_sopianae",
	[150] = "att_reg_dalmatia_siscia",
	[151] = "att_reg_dacia_petrodava",
	[152] = "att_reg_germano_sarmatia_palteskja",
	[153] = "att_reg_khwarasan_abarshahr",
	[154] = "att_reg_cilicia_myra",
	[155] = "att_reg_macedonia_thessalonica",
	[156] = "att_reg_belgica_augusta_treverorum",
	[157] = "att_reg_gothiscandza_ascaucalis",
	[158] = "att_reg_britannia_superior_corinium",
	[159] = "att_reg_aegyptus_alexandria",
	[160] = "att_reg_asorstan_ctesiphon",
	[161] = "att_reg_mauretania_caesarea",
	[162] = "att_reg_narbonensis_narbo",
	[163] = "att_reg_palaestinea_nova_trajana_bostra",
	[164] = "att_reg_scythia_ra",
	[165] = "att_reg_raetia_et_noricum_virunum",
	[166] = "att_reg_thracia_constantinopolis",
	[167] = "att_reg_transcaspia_kath",
	[168] = "att_reg_lusitania_pax_augusta",
	[169] = "att_reg_mediterraneus_occidentalis_ajax",
	[170] = "att_reg_germano_sarmatia_duna",
	[171] = "att_reg_macedonia_dyrrhachium",
	[172] = "att_reg_pannonia_sirmium",
	[173] = "att_reg_caledonia_et_hibernia_eildon",
	[174] = "att_reg_caledonia_et_hibernia_tuesis",
	[175] = "att_reg_makran_harmosia",
	[176] = "att_reg_sarmatia_europaea_olbia",
	[177] = "att_reg_carthaginensis_toletum",
	[178] = "att_reg_liguria_segusio",
	[179] = "att_reg_scandza_hrefnesholt",
	[180] = "att_reg_bithynia_amasea",
	[181] = "att_reg_spahan_issatis",
	[182] = "att_reg_asia_cyzicus",
	[183] = "att_reg_transcaspia_siahkuh",
	[184] = "att_reg_baetica_corduba",
	[185] = "att_reg_armenia_payttakaran",
	[186] = "att_reg_palaestinea_aelia_capitolina"
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

			if not debug then
				cm:add_time_trigger("Reload_Game", 3);
			end
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
		local region_array;

		for i = 1, #regions_to_arrays do
			if regions_to_arrays[i] == REGION_SELECTED then
				region_array = i;
			end
		end

		if not region_array then
			return;
		end

		local exe_exists = util.fileExists("faction_capital_change.exe");
		local exe_config_exists = util.fileExists("faction_capital_change.exe.config");
		local dll_exists = util.fileExists("faction_capital_change.dll");
		local json_exists = util.fileExists("faction_capital_change.deps.json");
		local json_config_exists = util.fileExists("faction_capital_change.runtimeconfig.json");

		-- delete old files if they exist
		if dll_exists or json_exists or json_config_exists then
			if exe_exists then
				os.remove("faction_capital_change.exe");
			end

			if dll_exists then
				os.remove("faction_capital_change.dll");
			end

			if json_exists then
				os.remove("faction_capital_change.deps.json");
			end

			if json_config_exists then
				os.remove("faction_capital_change.runtimeconfig.json");
			end

			exe_exists = false;
			dll_exists = false;
			json_exists = false;
			json_config_exists = false;
		end

		if not exe_exists or not exe_config_exists then
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

			if not exe_config_exists then
				local changeCapitalExeConfig = io.open("faction_capital_change.exe.config", "wb");
				local binary = "";
					
				for i = 1, #change_capital_exe_config_binaries do
					local number = tonumber("0x"..change_capital_exe_config_binaries[i]);
					local char = string.char(number);
		
					binary = binary..char;
				end
		
				changeCapitalExeConfig:write(binary);
				changeCapitalExeConfig:close();
			end

			--[[if not dll_exists then
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
			end]]--
		end

		local command;
	
		if debug then
			--Print out list of regions and region array numbers for the table above.
			command = "faction_capital_change.exe debug attila";
		else
			command = "faction_capital_change.exe "..tostring(region_array).." attila";
		end
	
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
