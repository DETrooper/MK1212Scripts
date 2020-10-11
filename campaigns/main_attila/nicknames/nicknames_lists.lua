-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - NICKNAMES: LISTS
-- 	By: DETrooper
--
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------

HISTORICAL_CHARACTERS_TO_NICKNAMES = {
	["57"] = "the_fair",
};

-- Priorities should be from 1 (highest) to 3 (lowest).
NICKNAMES = {
	["the_arian"] = {priority = 2}, -- Religious conversion nickname.
	["the_bewitched"] = {priority = 1}, -- Has trait 'att_trait_general_physical_all_innate_deformed'.
	["the_blind"] = {priority = 2}, -- Has trait 'att_trait_general_physical_all_blind'.
	["the_bogomilist"] = {priority = 2}, -- Religious conversion nickname.
	["the_brave"] = {priority = 3}, -- Has trait 'att_trait_general_personality_all_bravery'.
	["the_cathar"] = {priority = 2}, -- Religious conversion nickname.
	["the_catholic"] = {priority = 2}, -- Religious conversion nickname.
	["the_conquerer"] = {priority = 3}, -- Personally conquered 10 regions.
	["the_christian"] = {priority = 2}, -- Religious conversion nickname.
	["the_cruel"] = {priority = 2}, -- Executed captives 5 times.
	["the_crusader"] = {priority = 2}, -- Got the 'mk_trait_crusades_crusader' or 'mk_trait_crusades_crusader_king' trait.
	["the_drunkard"] = {priority = 3}, -- Has trait 'att_trait_all_personality_all_drink'.
	["the_exile"] = {priority = 2}, -- Lost the capital of the faction.
	["the_fair"] = {priority = 3}, -- Reigned for 10 years without a revolt.
	["the_glorious"] = {priority = 1}, -- Formed a unique Empire.
	["the_great"] = {priority = 1}, -- Personally conquered 30 regions.
	["the_heretic"] = {priority = 2}, -- Religious conversion nickname.
	["the_ibadi"] = {priority = 2}, -- Religious conversion nickname.
	["the_jew"] = {priority = 2}, -- Religious conversion nickname.
	["the_mad"] = {priority = 2}, -- Has trait 'att_trait_general_personality_all_mad'.
	["the_manichaean"] = {priority = 2}, -- Religious conversion nickname.
	["the_old"] = {priority = 3}, -- Aged 65+.
	["the_orthodox"] = {priority = 2}, -- Religious conversion nickname.
	["the_pagan"] = {priority = 2}, -- Religious conversion nickname.
	["the_ruthless"] = {priority = 2}, -- Has trait 'att_trait_general_military_all_high_casualties'.
	["the_shiite"] = {priority = 2}, -- Religious conversion nickname.
	["the_sunni"] = {priority = 2}, -- Religious conversion nickname.
	["the_terrible"] = {priority = 1}, -- Executed captives 20 times.
	["the_undying"] = {priority = 2}, -- Aged 90+.
	["the_wicked"] = {priority = 2}, -- Excommunciated on more than one occasion.
	["the_zoroastrian"] = {priority = 2} -- Religious conversion nickname.
};

-- Given on conversion to faction leader.
RELIGIONS_TO_NICKNAMES = {
	["att_rel_chr_arian"] = "the_arian",
	["att_rel_chr_catholic"] = "the_catholic",
	["att_rel_chr_orthodox"] = "the_orthodox",
	["att_rel_church_east"] = "the_christian",
	["att_rel_east_manichaeism"] = "the_manichaean",
	["att_rel_east_zoroastrian"] = "the_zoroastrian",
	["att_rel_judaism"] = "the_jew",
	["att_rel_other"] = "the_heretic",
	["att_rel_pag_celtic"] = "the_pagan",
	["att_rel_pag_germanic"] = "the_pagan",
	["att_rel_pag_roman"] = "the_pagan",
	["att_rel_pag_slavic"] = "the_pagan",
	["att_rel_pag_tengri"] = "the_pagan",
	["att_rel_semitic_paganism"] = "the_sunni",
	["mk_rel_chr_bogomilist"] = "the_bogomilist",
	["mk_rel_chr_cathar"] = "the_cathar",
	["mk_rel_ibadi_islam"] = "the_ibadi",
	["mk_rel_shia_islam"] = "the_shiite"
};

TRAITS_TO_NICKNAMES = {
	["att_trait_general_physical_all_innate_deformed"] = "the_bewitched",
	["att_trait_general_physical_all_blind"] = "the_blind",
	["att_trait_general_personality_all_bravery"] = "the_brave",
	["att_trait_all_personality_all_drink"] = "the_drunkard",
	["att_trait_general_personality_all_mad"] = "the_mad",
	["att_trait_general_military_all_high_casualties"] = "the_ruthless",
	["mk_trait_crusades_crusader"] = "the_crusader",
	["mk_trait_crusades_crusader_king"] = "the_crusader"
};
