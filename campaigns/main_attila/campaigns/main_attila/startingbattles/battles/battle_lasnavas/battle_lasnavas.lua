-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
--	LAS NAVAS BATTLE SCRIPT
--
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------

----------------------------------------------
--
--  STARTUP
--
----------------------------------------------

-- clear out loaded files
system.ClearRequiredFiles();

-- load in battle script library
require("lua_scripts/battle_script_header");
require("startingbattles/battles/battle_lasnavas/battle_lasnavas_cutscenes");

require "battle_generic_strings";
require "battle_generic_advice";

-- declare battlemanager object
bm = battle_manager:new(empire_battle:new());
cam = bm:camera();

battle_name = "Battle of Las Navas de Tolosa";

bm:set_close_queue_advice(false);

local scripting = require "lua_scripts.episodicscripting";

eh = event_handler:new(AddEventCallBack);
start_advice_tickbox_listener(eh);

----------------------------------------------
--
--  DECLARATIONS
--
----------------------------------------------

Alliances = bm:alliances();
Local_Alliance = bm:local_alliance();
Alliance_Player = Alliances:item(Local_Alliance);
Army_Player = Alliance_Player:armies():item(1);

if Local_Alliance == 1 then
    Alliance_AI = Alliances:item(2);
else
    Alliance_AI = Alliances:item(1);
end;

Army_AI_01 = Alliance_AI:armies():item(1);

UC_Player_Army = unitcontroller_from_army(Army_Player);

----------------------------------------------
--
--  MAIN
--
----------------------------------------------

function Deployment_Phase()
	Play_Cutscene_Intro();
end;

bm:register_phase_change_callback("Deployment", function() Deployment_Phase() end);			-- optional deployment phase callback