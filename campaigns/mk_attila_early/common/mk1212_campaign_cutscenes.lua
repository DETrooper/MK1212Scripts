------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - CAMPAIGN CUTSCENES
-- 	By: DETrooper
--
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- Plays the video and audio of cinematic cutscenes (ca_vp8 files & wwise strings).

local cutscenes_list = {
	-- movie_event_strings key (must be one of the strings that can be found in attila's .dll, so I use old Rome II cutscenes). ONLY NECESSARY IF YOU USE cm:play_movie_in_ui() INSTEAD OF cm:register_movies()
	-- wwise audio file name (as found in event_data.dat).
	["mk1212_crusades_intro"] = {"faction_win_pun_carthage", "Play_Movie_INTRO"},
	["mk1212_faction_intro_byz"] = {"faction_win_pun_rome", "Play_Movie_att_seal_2d"},
	["mk1212_faction_intro_spa"] = {"gaul_roman_intervention_hellen", "Play_Movie_att_seal_2c"},
};

local current_cutscene;
local intro_cinematic_str;

function Add_MK1212_Campaign_Cutscene_Listeners()
	cm:add_listener(
		"PanelClosedCampaign_Campaign_Cutscenes",
		"PanelClosedCampaign",
		true,
		function(context) PanelClosedCampaign_Campaign_Cutscenes(context) end,
		true
	);

	if cm:is_new_game() then
		cm:add_listener(
			"LoadingScreenDismissed_Intro_Cinematic",
			"LoadingScreenDismissed",
			true,
			function()
				if intro_cinematic_str then
					Cutscene_Play(intro_cinematic_str)
				end
			end,
			false
		);
	end
end

function PanelClosedCampaign_Campaign_Cutscenes(context)
	if context.string == "event_movie_panel" then
		if current_cutscene then
			Cutscene_Ended(current_cutscene);
		end
	end
end

function Cutscene_Play(cutscene_name)
	current_cutscene = cutscene_name;

	cm:play_movie_in_ui(cutscenes_list[cutscene_name][1]); -- This function plays the movie based off a hardcoded string ID found in attila's .dll, which can be linked to the movie file in the movie_event_strings db.
	--cm:register_movies(cutscene_name); -- This function lets us use the actual video name instead of a hardcoded one. However, PanelClosedCampaign will not fire which is not desirable if we wish to stop the audio playing alongside it.
	cm:play_sound(cutscenes_list[current_cutscene][2]); -- This method of adding audio can desync but it's better than nothing :(
end

function Cutscene_Ended(cutscene_name)
	current_cutscene = nil;

	cm:stop_sound(cutscenes_list[cutscene_name][2]);
end

function set_intro_cinematic(str)
	intro_cinematic_str = str;
end;
