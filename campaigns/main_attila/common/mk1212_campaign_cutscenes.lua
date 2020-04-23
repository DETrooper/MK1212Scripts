------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - CAMPAIGN CUTSCENES
-- 	By: DETrooper
--
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- Plays the video and audio of cinematic cutscenes (ca_vp8 files & wwise strings).

CUTSCENES_LIST = {
	-- movie_event_strings key (must be one of the strings that can be found in attila's .dll, so I use old Rome II cutscenes), wwise audio file name (as found in even_data.dat).
	["mk1212_crusades_intro"] = {"faction_win_pun_carthage", "Play_Movie_INTRO"},
};

CURRENT_CUTSCENE = "nil";

function Add_MK1212_Campaign_Cutscene_Listeners()
	cm:add_listener(
		"PanelClosedCampaign_Campaign_Cutscenes",
		"PanelClosedCampaign",
		true,
		function(context) PanelClosedCampaign_Campaign_Cutscenes(context) end,
		true
	);
end

function PanelClosedCampaign_Campaign_Cutscenes(context) 
	if context.string == "event_movie_panel" then
		if CURRENT_CUTSCENE ~= "nil" then
			Cutscene_Skipped(CURRENT_CUTSCENE);
		end
	end
end

function Cutscene_Play(cutscene_name)
	CURRENT_CUTSCENE = cutscene_name;

	cm:play_movie_in_ui(CUTSCENES_LIST[cutscene_name][1]);
	cm:play_sound(CUTSCENES_LIST[cutscene_name][2]);
end

function Cutscene_Skipped(cutscene_name)
	CURRENT_CUTSCENE = "nil";

	cm:stop_sound(CUTSCENES_LIST[cutscene_name][2]);
end
