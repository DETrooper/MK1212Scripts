-- this line needs to be present - due to the way this script file is loaded by the main script it
-- does not have access to the global script environment. This line gives it access.
setfenv(1, _G.script_env);

-- set the fullscreen intro cinematic
set_intro_cinematic("mk1212_faction_intro_spa");
