-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - NICKNAMES: LISTS
-- 	By: DETrooper
--
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------

-- Key can be a faction name for faction leader or a cqi to give to specific characters directly.
HISTORICAL_CHARACTERS_TO_NICKNAMES = {
	["mk_fact_aragon"] = "the_catholic",
	["mk_fact_brabant"] = "the_courageous",
	["mk_fact_castile"] = "the_noble",
	["mk_fact_denmark"] = "the_conqueror",
	["mk_fact_navarre"] = "the_strong",
	["mk_fact_portugal"] = "the_fat",
	["mk_fact_scotland"] = "the_rough",
	["mk_fact_sweden"] = "the_survivor",
};

-- Priorities should be from 1 (highest) to 3 (lowest).
NICKNAMES = {
	["the_arian"] = {priority = 2}, -- Religious conversion nickname.
	["the_bewitched"] = {priority = 1}, -- Has trait 'att_trait_general_physical_all_innate_deformed'.
	["the_blind"] = {priority = 2}, -- Has trait 'att_trait_general_physical_all_blind'.
	["the_bogomilist"] = {priority = 2}, -- Religious conversion nickname.
	["the_bold"] = {priority = 2}, -- Won 5 offensive ambush battles.
	["the_brave"] = {priority = 3}, -- Has trait 'att_trait_general_personality_all_bravery'.
	["the_cathar"] = {priority = 2}, -- Religious conversion nickname.
	["the_catholic"] = {priority = 2}, -- Religious conversion nickname.
	["the_christian"] = {priority = 2}, -- Religious conversion nickname.
	["the_conqueror"] = {priority = 3}, -- Personally conquered 10 regions.
	["the_courageous"] = {priority = 2},
	["the_cruel"] = {priority = 3}, -- Executed captives 5 times.
	["the_crusader"] = {priority = 2}, -- Has traits 'mk_trait_crusades_crusader' or 'mk_trait_crusades_crusader_king'.
	["the_drunkard"] = {priority = 3}, -- Has trait 'att_trait_all_personality_all_drink'.
	["the_exile"] = {priority = 2}, -- Lost the capital of the faction.
	["the_fair"] = {priority = 3}, -- Reigned for 20 years without a revolt (while having more than 4 regions in their faction).
	["the_fat"] = {priority = 3},
	["the_first_crowned"] = {priority = 2}, -- Unique nickname given to the faction leader of Serbia via event.
	["the_fool"] = {prioity = 3}, -- Has trait 'att_trait_all_personality_all_easily_deceived'.
	["the_glorious"] = {priority = 1}, -- Formed a unique Empire.
	["the_great"] = {priority = 1}, -- Personally conquered 30 regions.
	["the_heretic"] = {priority = 2}, -- Religious conversion nickname.
	["the_hero"] = {priority = 1}, -- Won 5 heroic victories.
	["the_ibadi"] = {priority = 2}, -- Religious conversion nickname.
	["the_jew"] = {priority = 2}, -- Religious conversion nickname.
	["the_lame"] = {priority = 2}, -- Has traits 'att_trait_general_physical_all_maimed_arm' or 'att_trait_general_physical_all_maimed_leg'.
	["the_mad"] = {priority = 2}, -- Has trait 'att_trait_general_personality_all_mad'.
	["the_manichaean"] = {priority = 2}, -- Religious conversion nickname.
	["the_merciless"] = {priority = 2}, -- Executed captives 20 times.
	["the_noble"] = {priority = 2},
	["the_old"] = {priority = 3}, -- Aged 65+.
	["the_orthodox"] = {priority = 2}, -- Religious conversion nickname.
	["the_pagan"] = {priority = 2}, -- Religious conversion nickname.
	["the_rough"] = {priority = 3},
	["the_ruthless"] = {priority = 2}, -- Has trait 'att_trait_general_military_all_high_casualties'.
	["the_shiite"] = {priority = 2}, -- Religious conversion nickname.
	["the_strong"] = {priority = 3}, -- Has trait 'att_trait_all_physical_all_healthy'.
	["the_sunni"] = {priority = 2}, -- Religious conversion nickname.
	["the_survivor"] = {priority = 2},
	["the_terrible"] = {priority = 2}, -- Has trait 'att_trait_general_military_all_looter'.
	["the_undefeated"] = {priority = 1}, -- Won 25 battles undefeated.
	["the_undying"] = {priority = 2}, -- Aged 90+.
	["the_unlucky"] = {prioirty = 3}, -- Has trait 'att_trait_all_personality_all_unlucky'.
	["the_victorious"] = {priority = 2}, -- Won 25 battles.
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
	["att_trait_all_personality_all_drink"] = "the_drunkard",
	["att_trait_all_personality_all_easily_deceived"] = "the_fool",
	["att_trait_all_personality_all_unlucky"] = "the_unlucky",
	["att_trait_all_physical_all_healthy"] = "the_strong",
	["att_trait_general_military_all_high_casualties"] = "the_ruthless",
	["att_trait_general_military_all_looter"] = "the_terrible",
	["att_trait_general_physical_all_blind"] = "the_blind",
	["att_trait_general_physical_all_innate_deformed"] = "the_bewitched",
	["att_trait_general_physical_all_maimed_arm"] = "the_lame",
	["att_trait_general_physical_all_maimed_leg"] = "the_lame",
	["att_trait_general_personality_all_bravery"] = "the_brave",
	["att_trait_general_personality_all_mad"] = "the_mad"
};
