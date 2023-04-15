-- clear out loaded files
system.ClearRequiredFiles();

-- load in battle script library
require "lua_scripts.Battle_Script_Header";

bm = battle_manager:new(empire_battle:new());
dev = require("lua_scripts.dev");

bm:register_phase_change_callback("Deployment", function() Deployment_Phase() end);

function Deployment_Phase()
	local button_withdraw_uic = bm:ui_component("button_withdraw");

	button_withdraw_uic:SetVisible(false);
end
