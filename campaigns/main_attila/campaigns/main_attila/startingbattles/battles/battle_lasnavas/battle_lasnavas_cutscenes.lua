function Play_Cutscene_Intro()

	bm:enable_cinematic_ui(false, true, false);
	bm:camera():fade(false, 0.5);
	
	POS_Cam_Cutscene_Intro_Final = v(82.8, 58.8, -223.8);
	Targ_Cam_Cutscene_Intro_Final = v(104.3, 26.9, -282.4);

	
	local Cutscene_Intro = cutscene:new(
		"Cutscene_Intro_Las_Navas", 							-- unique string name for cutscene
		UC_Player_Army:get_unitcontroller(),							-- unitcontroller over player's army
		30000 										-- duration of cutscene in ms
	);

	

	Cutscene_Intro:set_skippable(true, function() Skip_Cutscene_Intro() end);
	Cutscene_Intro:set_skip_camera(POS_Cam_Cutscene_Intro_Final, Targ_Cam_Cutscene_Intro_Final);
	-- Cutscene_Intro:set_debug();



	cam = Cutscene_Intro:camera();
	local subtitles = Cutscene_Intro:subtitles();
	subtitles:set_alignment("bottom_centre");
	subtitles:clear();
	
	Cutscene_Intro:action(function() cam:fade(false, 0.5) end, 0);
	
	Cutscene_Intro:action(function() ga_germans_01:set_visible_to_all(true); end, 0);
	
	Cutscene_Intro:action(function() cam:move_to(v(232.43269348145, 25.392950057983, -234.86169433594), v(302.34576416016, 29.343503952026, -231.6474609375), 0, true, 60) end, 0);
	Cutscene_Intro:action(function() cam:move_to(v(232.43269348145, 56.646049499512, -234.86169433594), v(302.34576416016, 65.596622467041, -231.6474609375), 8, true, 55) end, 0);
	
	Cutscene_Intro:action(function() subtitles:set_text("MK1212.SB.LN.Intro_01") end, 3000);
	
	Cutscene_Intro:action(function() subtitles:clear() end, 7000);
	
	Cutscene_Intro:action(function() subtitles:set_text("MK1212.SB.LN.Intro_02") end, 10000);
	
	Cutscene_Intro:action(function() cam:move_to(v(-747.61639404297, 6.9360065460205, -297.97338867188), v(-689.02203369141, -12.144090652466, -264.56185913086), 0, true, 50) end, 8000);
	Cutscene_Intro:action(function() cam:move_to(v(-747.61639404297, 39.049613952637, -297.97338867188), v(-689.02203369141, 21.969497680664, -264.56185913086), 9, true, 47) end, 8000);
	
	Cutscene_Intro:action(function() subtitles:clear() end, 16000);	
		
	Cutscene_Intro:action(function() subtitles:set_text("MK1212.SB.LN.Intro_03") end, 17000);
	
	Cutscene_Intro:action(function() cam:move_to(v(-473.09838867188, 27.594551086426, 455.43634033203), v(-477.96810913086, 15.639770507813, 386.53558349609), 0, true, 50) end, 17000);
	
	Cutscene_Intro:action(function() cam:move_to(v(-558.0888671875, 27.149795532227, 12.564566612244), v(-625.67047119141, 17.950527191162, 28.757484436035), 0, true, 45) end, 20500);

	Cutscene_Intro:action(function() subtitles:clear() end, 24000);	
	
	Cutscene_Intro:action(function() ga_germans_01:set_visible_to_all(false); end, 24000);
		
	Cutscene_Intro:action(function() cam:move_to(v(113.0, 12.1, -281.5), v(100.9, 9.4, -212.6), 0, true, 45, 0) end, 24000);
	Cutscene_Intro:action(function() cam:move_to(POS_Cam_Cutscene_Intro_Final, Targ_Cam_Cutscene_Intro_Final, 5, false, 0) end, 25000);
	
	Cutscene_Intro:action(function() subtitles:set_text("MK1212.SB.LN.Intro_04") end, 25000);
	
	Cutscene_Intro:action(function() subtitles:clear() end, 30000);	

	Cutscene_Intro:start();
end;


function Skip_Cutscene_Intro()
	
	cam:fade(true, 0);
	
	ga_germans_01:set_visible_to_all(false);
		
	bm:callback(function() cam:fade(false, 0.5) end, 1000);
end;
