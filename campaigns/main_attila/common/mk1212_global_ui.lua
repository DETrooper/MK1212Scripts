-----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - GLOBAL USER INTERFACE CHANGES
-- 	By: DETrooper
--
-----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------

local dev = require("lua_scripts.dev");

SETTLEMENT_PANEL_OPEN = false;

-- THIS TABLE IS TEMPORARY TO AVOID CRASHES
FACTIONS_WITH_IMAGES = {
	"mk_fact_abbasids",
	"mk_fact_achaea",
	"mk_fact_alania",
	"mk_fact_almohads",
	"mk_fact_antioch",
	"mk_fact_aq_qoyunlu",
	"mk_fact_aragon",
	"mk_fact_armenia",
	"mk_fact_austria",
	"mk_fact_ayyubids",
	"mk_fact_bavaria",
	"mk_fact_bohemia",
	"mk_fact_bologna",
	"mk_fact_bosnia",
	"mk_fact_brabant",
	"mk_fact_brandenburg",
	"mk_fact_bulgaria",
	"mk_fact_burgundy",
	"mk_fact_castile",
	"mk_fact_chernigov",
	"mk_fact_croatia",
	"mk_fact_cumans",
	"mk_fact_dauphine",
	"mk_fact_denmark",
	"mk_fact_earldoms",
	"mk_fact_england",
	"mk_fact_epirus",
	"mk_fact_flanders",
	"mk_fact_florence",
	"mk_fact_france",
	"mk_fact_friesland",
	"mk_fact_genoa",
	"mk_fact_georgia",
	"mk_fact_ghurids",
	"mk_fact_goldenhorde",
	"mk_fact_granada",
	"mk_fact_greaterpoland",
	"mk_fact_hafsids",
	"mk_fact_halych",
	"mk_fact_hazaraspids",
	"mk_fact_hospitaller",
	"mk_fact_hre",
	"mk_fact_hungary",
	"mk_fact_ildegizids",
	"mk_fact_ilkhanate",
	"mk_fact_ireland",
	"mk_fact_jerusalem",
	"mk_fact_kazan",
	"mk_fact_khwarazm",
	"mk_fact_kiev",
	"mk_fact_latinempire",
	"mk_fact_leon",
	"mk_fact_lesserpoland",
	"mk_fact_lithuania",
	"mk_fact_lorraine",
	"mk_fact_makuria",
	"mk_fact_mamluks",
	"mk_fact_marinids",
	"mk_fact_mecca",
	"mk_fact_milan",
	"mk_fact_navarre",
	"mk_fact_nicaea",
	"mk_fact_norway",
	"mk_fact_novgorod",
	"mk_fact_oman",
	"mk_fact_ottoman",
	"mk_fact_papacy",
	"mk_fact_pisa",
	"mk_fact_pomerania",
	"mk_fact_portugal",
	"mk_fact_provence",
	"mk_fact_qara_qoyunlu",
	"mk_fact_rebels_african",
	"mk_fact_rebels_arabic",
	"mk_fact_rebels_baltic",
	"mk_fact_rebels_berber",
	"mk_fact_rebels_bulgar",
	"mk_fact_rebels_caucasian",
	"mk_fact_rebels_dutch",
	"mk_fact_rebels_english",
	"mk_fact_rebels_french",
	"mk_fact_rebels_gaelic",
	"mk_fact_rebels_german",
	"mk_fact_rebels_greek",
	"mk_fact_rebels_hungarian",
	"mk_fact_rebels_iranian",
	"mk_fact_rebels_italians",
	"mk_fact_rebels_levantine",
	"mk_fact_rebels_moorish",
	"mk_fact_rebels_nordic",
	"mk_fact_rebels_north_italians",
	"mk_fact_rebels_occitan",
	"mk_fact_rebels_rus",
	"mk_fact_rebels_south_slavic",
	"mk_fact_rebels_spanish",
	"mk_fact_rebels_steppe",
	"mk_fact_rebels_turk",
	"mk_fact_rebels_vlach",
	"mk_fact_rebels_west_slavic",
	"mk_fact_salghurids",
	"mk_fact_savoy",
	"mk_fact_saxony",
	"mk_fact_schwyz",
	"mk_fact_scotland",
	"mk_fact_seljuks",
	"mk_fact_serbia",
	"mk_fact_shirvan",
	"mk_fact_sicily",
	"mk_fact_silesia",
	"mk_fact_sweden",
	"mk_fact_teutonicorder",
	"mk_fact_thessalonica",
	"mk_fact_timurids",
	"mk_fact_tlemcen",
	"mk_fact_toulouse",
	"mk_fact_trebizond",
	"mk_fact_trier",
	"mk_fact_venice",
	"mk_fact_verona",
	"mk_fact_vladimir",
	"mk_fact_volga",
	"mk_fact_wales",
	"mk_fact_wallachia",
	"mk_fact_yotvingians",
	"mk_fact_zagwe",
	"mk_fact_zengids"
};


function Add_MK1212_Global_UI_Listeners()
	cm:add_listener(
		"OnComponentLClickUp_Global_UI",
		"ComponentLClickUp",
		true,
		function(context) OnComponentLClickUp_Global_UI(context) end,
		true
	);
	cm:add_listener(
		"OnPanelOpenedCampaign_Global_UI",
		"PanelOpenedCampaign",
		true,
		function(context) OnPanelOpenedCampaign_Global_UI(context) end,
		true
	);
	cm:add_listener(
		"OnPanelClosedCampaign_Global_UI",
		"PanelClosedCampaign",
		true,
		function(context) OnPanelClosedCampaign_Global_UI(context) end,
		true
	);
	cm:add_listener(
		"OnTimeTrigger_Global_UI",
		"TimeTrigger",
		true,
		function(context) OnTimeTrigger_Global_UI(context) end,
		true
	);

	local root = cm:ui_root();
	root:CreateComponent("garbage", "UI/campaign ui/script_dummy");
end

function OnComponentLClickUp_Global_UI(context)
	if context.string == "button_create_army" then
		cm:add_time_trigger("disable_navy_recruitment", 0.0);
	end
end

function OnPanelOpenedCampaign_Global_UI(context)
	if context.string == "settlement_panel" then
		SETTLEMENT_PANEL_OPEN = true;
	end
end

function OnPanelClosedCampaign_Global_UI(context)
	if context.string == "settlement_panel" then
		SETTLEMENT_PANEL_OPEN = false;
	end
end

function OnTimeTrigger_Global_UI(context)
	if context.string == "disable_navy_recruitment" then
		Disable_Naval_Recruitment();
	end
end

function Disable_Naval_Recruitment()
	local root = cm:ui_root();
	local button_raise_fleet_uic = UIComponent(root:Find("button_raise_fleet"));
	button_raise_fleet_uic:SetState("inactive");
end

function Create_Image(component, name)
	local root = cm:ui_root();
	local garbage = UIComponent(root:Find("garbage"));

	garbage:CreateComponent(name.."_throwaway", "UI/new/images/"..name);
	local uic = UIComponent(garbage:Find(name));
	component:Adopt(uic:Address());
	garbage:DestroyChildren();
end

function Round_Number_Text(number)
	-- Attila really doesn't like floats, so this does some rounding for the purposes of displaying floating point numbers as text.
	local number = tostring(number);

	for i = 1, string.len(number) do
		local char = string.sub(number, i, i);

		if char == "." then
			local tenth = string.sub(number, i + 1, i + 1);
			local hundredth = string.sub(number, i + 2, i + 2);
			
			tenth = tonumber(tenth);
			hundredth = tonumber(hundredth);
			
			if hundredth < 5 then
				if tenth ~= 0 then
					tenth = tenth - 1;
					
					if tenth == 0 then
						number = string.sub(number, 0, i - 1);
						return number;
					end
				else
					number = string.sub(number, 0, i - 1);
					return number;
				end
			elseif hundredth >= 5 then
				if tenth ~= 9 then
					tenth = tenth + 1;
				else
					number = string.sub(number, 0, i - 1);
					
					local new_num = tonumber(number) + 1;
					return tostring(new_num);
				end
			else
				number = string.sub(number, 0, i - 1);
				return number;
			end
			
			number = string.sub(number, 0, i)..tostring(tenth);
			return number;
		end
	end

	return number;
end
