-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - INVASIONS: LISTS
-- 	By: DETrooper
--
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
-- REGIONS_GOLDEN_HORDE and REGIONS_ILKHANATE are in kingdoms/list_regions.lua

INVASION_SPAWN_ZONES = {
	["mk_fact_golden_horde"] = {x1 = 895, x2 = 901, y1 = 489, y2 = 460};
	["mk_fact_ilkhanate"] = {x1 = 955, x2 = 994, y1 = 383, y2 = 377};
	["mk_fact_timurids"] = {x1 = 955, x2 = 994, y1 = 383, y2 = 377};
};

INVASION_ARMY_TEMPLATES = {
	["mk_fact_goldenhorde"] = {
		["cavalry"] = {
			["minimum"] = {
				["mk_gold_t1_nokor"] = 4, -- Heavy Hybrid Shock Cav
				["mk_gold_t1_mongol_horse_archers"] = 6, -- Light Archer Cav
				["mk_gold_t1_mongol_lancers"] = 4, -- Light Shock Cav
				["mk_mon_t1_catapult"] = 1, -- Artillery
			},
			["adds"] = {"mk_gold_t1_tammachi_lancers", "mk_gold_t1_tammachi_horse_archers", "mk_gold_t1_mongol_horse_archers", "mk_gold_t1_mongol_lancers", "mk_gold_t1_mangudai"},
		},
		["siege"] = {
			["minimum"] = {
				["mk_gold_t1_nokor"] = 2, -- Heavy Hybrid Shock Cav
				["mk_gold_t1_mongol_horse_archers"] = 4, -- Light Archer Cav
				["mk_gold_t1_tserig_swordsmen"] = 7, -- Siege Infantry
				["mk_mon_t1_catapult"] = 2, -- Artillery
			},
			["adds"] = {"mk_gold_t1_grenade_throwers", "mk_gold_t1_tserig_archers", "mk_mon_t1_fire_lance_infantry", "mk_gold_t1_tserig_swordsmen", "mk_gold_t1_tserig_spearmen"},
		}
	},
	["mk_fact_ilkhanate"] = {
		["cavalry"] = {
			["minimum"] = {
				["mk_ilkhan_t1_nokor"] = 4, -- Heavy Hybrid Shock Cav
				["mk_ilkhan_t1_mongol_horse_archers"] = 6, -- Light Archer Cav
				["mk_ilkhan_t1_mongol_lancers"] = 4, -- Light Shock Cav
				["mk_mon_t1_catapult"] = 1, -- Artillery
			},
			["adds"] = {"mk_ilkhan_t1_tammachi_lancers", "mk_ilkhan_t1_tammachi_horse_archers", "mk_ilkhan_t1_mongol_horse_archers", "mk_ilkhan_t1_mongol_lancers"},
		},
		["siege"] = {
			["minimum"] = {
				["mk_ilkhan_t1_nokor"] = 2, -- Heavy Hybrid Shock Cav
				["mk_ilkhan_t1_mongol_horse_archers"] = 4, -- Light Archer Cav
				["mk_ilkhan_t1_tserig_swordsmen"] = 7, -- Siege Infantry
				["mk_mon_t1_catapult"] = 2, -- Artillery
			},
			["adds"] = {"mk_ilkhan_t1_grenade_throwers", "mk_ilkhan_t1_tserig_archers", "mk_mon_t1_fire_lance_infantry", "mk_ilkhan_t1_tserig_swordsmen", "mk_ilkhan_t1_tserig_spearmen", "mk_ilkhan_t1_dismounted_nokor"},
		}
	},
	["mk_fact_timurids"] = {
		["cavalry"] = {
			["minimum"] = {
				["mk_ilkhan_t2_nokor"] = 4, -- Heavy Hybrid Shock Cav
				["mk_khw_t2_boynukars"] = 5, -- Medium Hybrid Shock Cav
				["mk_khw_t2_boynukar_archers"] = 5, -- Light Archer Cav
				["mk_mon_t2_rocket"] = 1, -- Rocket Artillery
			},
			["adds"] = {"mk_khw_t2_boynukars", "mk_khw_t2_turkoman_lancers", "mk_khw_t2_boynukar_archers", "mk_ghu_t3_hathnal_cannon_elephants", "mk_mon_t2_rocket"},
		},
		["siege"] = {
			["minimum"] = {
				["mk_ilkhan_t2_nokor"] = 2, -- Heavy Hybrid Shock Cav
				["mk_ilkhan_t3_tserig_swordsmen"] = 7, -- Siege Infantry
				["mk_khw_t2_turkoman_archers"] = 3, -- Light Foot Archers
				["mk_mon_t1_trebuchet"] = 1, -- Artillery
				["mk_mon_t2_rocket"] = 1, -- Rocket Artillery
			},
			["adds"] = {"mk_ilkhan_t3_grenade_throwers", "mk_ilkhan_t2_handgunners", "mk_ilkhan_t2_tserig_crossbowmen", "mk_khw_t2_turkoman_archers", "mk_ilkhan_t2_dismounted_nokor", "mk_ilkhan_t2_war_elephants", "mk_ghu_t3_hathnal_cannon_elephants", "mk_mon_t2_rocket"},
		}
	},
};
