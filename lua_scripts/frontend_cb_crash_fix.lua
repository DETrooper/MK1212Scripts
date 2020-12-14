---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - CUSTOM BATTLE CRASH FIX
-- 	By: DETrooper
--
---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------

local util = require ("lua_scripts/util");

eh:add_listener(
	"OnUICreated_CB_Crash_Fix",
	"UICreated",
	true,
	function(context) 
		if not svr:LoadBool("SBOOL_Preferences_Checked") then
			CheckPreferences();
			svr:SaveBool("SBOOL_Preferences_Checked", true);
		end
	end,
	true
);
eh:add_listener(
	"OnFrontendScreenTransition_CB_Crash_Fix",
	"FrontendScreenTransition",
	true,
	function(context) OnFrontendScreenTransition_CB_Crash_Fix(context) end,
	true
);

function OnFrontendScreenTransition_CB_Crash_Fix(context)
	tm:callback(
		function()
			local battle_setup_uic = UIComponent(m_root:Find("battle_setup"));

			if battle_setup_uic:Visible() then
				local dropdown_campaign_map_uic = UIComponent(battle_setup_uic:Find("dropdown_campaign_map"));

				dropdown_campaign_map_uic:SetState("inactive");
			end
		end, 
		100
	);
end

-- This function deletes any invalid default army/battle preferences that can cause crashes.
function CheckPreferences()
	local army_setups_path = os.getenv("APPDATA")..[[\The Creative Assembly\Attila\army_setups\]];
	local battle_preferences_path = os.getenv("APPDATA")..[[\The Creative Assembly\Attila\battle_preferences\]];
	local blacklisted_strings = {"bel_attila_map", "cha_attila_map"};
	local openFile;

	local paths_to_search = {
		army_setups_path..".private_ambush_att.army_setup",
		army_setups_path..".private_coastal_battle_att.army_setup",
		army_setups_path..".private_land_att.army_setup",
		army_setups_path..".private_land_def.army_setup",
		army_setups_path..".private_naval_siege_att.army_setup",
		army_setups_path..".private_naval_siege_def.army_setup",
		army_setups_path..".private_river_crossing_att.army_setup",
		army_setups_path..".private_siege_att.army_setup",
		army_setups_path..".private_siege_def.army_setup",
		army_setups_path..".private_unfortified_port_att.army_setup",
		army_setups_path..".private_unfortified_settlement_att.army_setup",
		army_setups_path..".private_unfortified_settlement_def.army_setup",
		battle_preferences_path..".mp.battle_preferences",
		battle_preferences_path..".sp.battle_preferences"
	};

	for i = 1, #paths_to_search do
		local path = paths_to_search[i];

		if util.fileExists(path) then
			local mk_fact_found = false;
			openFile = io.open(path, "rb");

			if openFile then
				local data = openFile:read("*all");
				local validchars = "[%w%p%s]"
				local pattern = string.rep(validchars, 6) .. "+%z"

				for w in string.gfind(data, pattern) do
					if string.find(w, "mk_fact_") then
						mk_fact_found = true;
						openFile:close();
						openFile = nil;
						break;
					end

					for j = 1, #blacklisted_strings do
						if string.find(w, blacklisted_strings[j]) then
							openFile:close();
							openFile = nil;
							os.remove(path);
							break;
						end
					end

					if not openFile then
						break;
					end
				end
			end

			if openFile then
				openFile:close();
				openFile = nil;
			end

			if not mk_fact_found then
				os.remove(path);
			end
		end
	end
end
