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
	[1] = "mk_reg_bushehr",
	[2] = "mk_reg_sis",
	[3] = "mk_reg_maghas",
	[4] = "mk_reg_kursk",
	[5] = "mk_reg_split",
	[6] = "mk_reg_antioch",
	[7] = "mk_reg_aleppo",
	[8] = "mk_reg_sharukan",
	[9] = "mk_reg_tripoli_libya",
	[10] = "mk_reg_ryazan",
	[11] = "mk_reg_tarnovo",
	[12] = "mk_reg_zaragoza",
	[13] = "mk_reg_tana",
	[15] = "mk_reg_dorylaion",
	[16] = "mk_reg_munich",
	[17] = "mk_reg_antwerp",
	[18] = "mk_reg_milan",
	[19] = "mk_reg_tbilisi",
	[20] = "mk_reg_famagusta",
	[21] = "mk_reg_rhodes",
	[22] = "mk_reg_shiraz",
	[23] = "mk_reg_pamplona",
	[24] = "mk_reg_misrata",
	[25] = "mk_reg_venice",
	[26] = "mk_reg_caffa",
	[27] = "mk_reg_malatya",
	[28] = "mk_reg_caernarvon",
	[29] = "mk_reg_dublin",
	[30] = "mk_reg_hamadan",
	[31] = "mk_reg_barcelona",
	[32] = "mk_reg_krakow",
	[33] = "mk_reg_verona",
	[34] = "mk_reg_bologna",
	[35] = "mk_reg_ancyra",
	[36] = "mk_reg_al-mahdiya",
	[37] = "mk_reg_leon",
	[38] = "mk_reg_sredets",
	[39] = "mk_reg_nis",
	[40] = "mk_reg_braunschweig",
	[41] = "mk_reg_scopie",
	[42] = "mk_reg_rome",
	[43] = "mk_reg_lalibela",
	[44] = "mk_reg_dongola",
	[45] = "mk_reg_herat",
	[46] = "mk_reg_merv",
	[47] = "mk_reg_london",
	[48] = "mk_reg_groningen",
	[49] = "mk_reg_massawa",
	[50] = "mk_reg_kufah",
	[51] = "mk_reg_prague",
	[52] = "mk_reg_chernigov",
	[53] = "mk_reg_paris",
	[54] = "mk_reg_pisa",
	[55] = "mk_reg_orleans",
	[56] = "mk_reg_bahla",
	[57] = "mk_reg_nottingham",
	[58] = "mk_reg_wroclaw",
	[59] = "mk_reg_brandenburg",
	[60] = "mk_reg_syracuse",
	[61] = "mk_reg_nancy",
	[62] = "mk_reg_ray",
	[63] = "mk_reg_toulouse",
	[64] = "mk_reg_vienne",
	[65] = "mk_reg_bruges",
	[66] = "mk_reg_marib",
	[67] = "mk_reg_valencia",
	[68] = "mk_reg_taranto",
	[69] = "mk_reg_diyarbakir",
	[70] = "mk_reg_badajoz",
	[71] = "mk_reg_mersa_matruh",
	[72] = "mk_reg_ardabil",
	[73] = "mk_reg_qusantina",
	[75] = "mk_reg_erbil",
	[76] = "mk_reg_dvin",
	[77] = "mk_reg_gyulafehervar",
	[78] = "mk_reg_rouen",
	[79] = "mk_reg_mosul",
	[80] = "mk_reg_palma",
	[81] = "mk_reg_aqaba",
	[82] = "mk_reg_veszprem",
	[83] = "mk_reg_trebizond",
	[84] = "mk_reg_candia",
	[85] = "mk_reg_biskra",
	[86] = "mk_reg_malaga",
	[88] = "mk_reg_vienna",
	[89] = "mk_reg_kayseri",
	[90] = "mk_reg_gdansk",
	[91] = "mk_reg_aden",
	[92] = "mk_reg_basra",
	[93] = "mk_reg_york",
	[94] = "mk_reg_esztergom",
	[95] = "mk_reg_kutaisi",
	[96] = "mk_reg_aarhus",
	[97] = "mk_reg_roskilde",
	[98] = "mk_reg_bilyar",
	[99] = "mk_reg_frankfurt",
	[100] = "mk_reg_murcia",
	[101] = "mk_reg_saqsin",
	[102] = "mk_reg_cagliari",
	[103] = "mk_reg_isfahan",
	[104] = "mk_reg_ahvaz",
	[105] = "mk_reg_mecca",
	[106] = "mk_reg_bordeaux",
	[107] = "mk_reg_derbent",
	[108] = "mk_reg_baku",
	[109] = "mk_reg_ras",
	[110] = "mk_reg_naples",
	[111] = "mk_reg_homs",
	[112] = "mk_reg_barca",
	[113] = "mk_reg_colchester",
	[114] = "mk_reg_lyon",
	[115] = "mk_reg_iconion",
	[116] = "mk_reg_genoa",
	[117] = "mk_reg_hamburg",
	[119] = "mk_reg_mystras",
	[120] = "mk_reg_reggio",
	[121] = "mk_reg_aydhab",
	[122] = "mk_reg_cairo",
	[123] = "mk_reg_smyrna",
	[124] = "mk_reg_seville",
	[125] = "mk_reg_nicaea",
	[126] = "mk_reg_santiago",
	[127] = "mk_reg_braga",
	[128] = "mk_reg_pahrah",
	[129] = "mk_reg_marrakech",
	[130] = "mk_reg_fez",
	[131] = "mk_reg_bern",
	[132] = "mk_reg_erfut",
	[133] = "mk_reg_dijon",
	[134] = "mk_reg_aix-en-provence",
	[135] = "mk_reg_acre",
	[136] = "mk_reg_lisbon",
	[137] = "mk_reg_philippopolis",
	[138] = "mk_reg_kiev",
	[139] = "mk_reg_halych",
	[140] = "mk_reg_van",
	[141] = "mk_reg_gardinas",
	[142] = "mk_reg_targoviste",
	[143] = "mk_reg_stralsund",
	[144] = "mk_reg_gorgan",
	[145] = "mk_reg_tunis",
	[146] = "mk_reg_kerman",
	[148] = "mk_reg_zaranj",
	[149] = "mk_reg_pecs",
	[150] = "mk_reg_zagreb",
	[151] = "mk_reg_suceava",
	[152] = "mk_reg_vilnius",
	[153] = "mk_reg_nishapur",
	[154] = "mk_reg_attaleia",
	[155] = "mk_reg_thessalonica",
	[156] = "mk_reg_trier",
	[157] = "mk_reg_poznan",
	[158] = "mk_reg_bristol",
	[159] = "mk_reg_alexandria",
	[160] = "mk_reg_baghdad",
	[161] = "mk_reg_algiers",
	[162] = "mk_reg_montpellier",
	[163] = "mk_reg_damascus",
	[164] = "mk_reg_suwar",
	[165] = "mk_reg_graz",
	[166] = "mk_reg_constantinopolis",
	[167] = "mk_reg_urgench",
	[168] = "mk_reg_evora",
	[169] = "mk_reg_ajaccio",
	[170] = "mk_reg_riga",
	[171] = "mk_reg_dyrrhachium",
	[172] = "mk_reg_belgrade",
	[173] = "mk_reg_edinburgh",
	[174] = "mk_reg_inverness",
	[175] = "mk_reg_hormuz",
	[176] = "mk_reg_bilgorod",
	[177] = "mk_reg_toledo",
	[178] = "mk_reg_turin",
	[179] = "mk_reg_lodose",
	[180] = "mk_reg_sinope",
	[181] = "mk_reg_yazd",
	[182] = "mk_reg_cyzicus",
	[184] = "mk_reg_cordoba",
	[185] = "mk_reg_tabriz",
	[186] = "mk_reg_jerusalem"
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
