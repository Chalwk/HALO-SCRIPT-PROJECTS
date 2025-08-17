--[[
--=====================================================================================================--
Script Name: Script Manager (v1.0), for SAPP (PC & CE)
Description: This mod will handle script loading and unloading.
             You can specify on a per-map/per-gamemode basis what scripts are loaded.

Copyright (c) 2019, Jericho Crosby <jericho.crosby227@gmail.com>
Notice: You can use this script subject to the following conditions:
https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================================--
]]--

api_version = "1.12.0.0"

local manager = { }
-- ======================= CONFIGURATION STARTS ======================= --
manager.settings = {

    -- EXAMPLE:
    ["mapname"] = { use = true, { "script1", "script2", "script3", "script4" }, "HLN1", "HLN2", "HLN3" },


    ["bc_raceway_mp"] = { use = true, { "" }, "HLN5" },
    ["snowtorn_cove"] = { use = true, { "" }, "HLN10" },
    ["LostCove_race"] = { use = true, { "" }, "HLN10" },
    ["DeathIsland_Race"] = { use = true, { "" }, "HLN10" },
    ["Gauntlet_Race"] = { use = true, { "" }, "HLN10" },
    ["Prime_C3_Race"] = { use = true, { "" }, "HLN15" },
    ["Camtrack-Arena-Race"] = { use = true, { "" }, "HLN10" },
    ["wraths-dojo"] = { use = true, { "" }, "HLN5" },
    ["Devils_Drop_Race"] = { use = true, { "" }, "HLN15" },
    ["city_race"] = { use = true, { "" }, "HLN15" },
    ["racist"] = { use = true, { "" }, "HLN5" },
    ["Facing_WorldsRX"] = { use = true, { "" }, "HLN10" },
    ["Mystic"] = { use = true, { "" }, "HLN15" },
    ["cmt_Snow_Grove"] = { use = true, { "" }, "HLN10" },
    ["Geomar_Final"] = { use = true, { "" }, "HLN15" },
    ["revelations"] = { use = true, { "" }, "HLN3" },
    ["portent"] = { use = true, { "" }, "HLN15" },
    ["fates_gulch"] = { use = true, { "" }, "HLN15" },
    ["twist_beta"] = { use = true, { "" }, "HLN10" },
    ["homestead"] = { use = true, { "" }, "HLN15" },
    ["New_Mombasa_Race"] = { use = true, { "" }, "HLN15" },
    ["lake-natalie"] = { use = true, { "" }, "HLN15" },
    ["snipercanyonredux"] = { use = true, { "" }, "HLN5" },
    ["siege"] = { use = true, { "" }, "HLN10" },
    ["luigi_raceway_v2"] = { use = true, { "" }, "HLN15" },
    ["vestige"] = { use = true, { "" }, "HLN10" },
    ["Lake_Serenity"] = { use = true, { "" }, "HLN15" },
    ["dieing_forest"] = { use = true, { "" }, "HLN15" },
    ["pandora_swamp"] = { use = true, { "" }, "HLN10" },
    ["hypothermia_v0.2"] = { use = true, { "" }, "HLN10" },
    ["six"] = { use = true, { "" }, "HLN5" },
    ["Bacons_race_track_v2"] = { use = true, { "" }, "HLNTEST15P" },
    ["Quagmire_Daylight"] = { use = true, { "" }, "HLN10" },
    ["Massacre_Mountain_Race"] = { use = true, { "" }, "HLN3" },
    ["TLSstronghold"] = { use = true, { "" }, "HLN15" },
    ["Equinox_V2"] = { use = true, { "" }, "HLN10" },
    ["hogracing_day"] = { use = true, { "" }, "HLN10" },
    ["Beryl_Rescue"] = { use = true, { "" }, "HLN10" },
    ["Greenvalley_Canyon"] = { use = true, { "" }, "HLN15" },
    ["MeatLocker_Race"] = { use = true, { "" }, "HLN10" },
    ["rock fields"] = { use = true, { "" }, "HLN15" },
    ["broadsword_race"] = { use = true, { "" }, "HLN10" },
    ["windisland-mod"] = { use = true, { "" }, "HLN15" },
    ["Blockfort__Race"] = { use = true, { "" }, "HLN10" },
    ["concealed"] = { use = true, { "" }, "HLN15" },
    ["monster_jam"] = { use = true, { "" }, "HLN5" },
    ["sewage-facility"] = { use = true, { "" }, "HLNEX5X" },
    ["pit_v2_top_race"] = { use = true, { "" }, "HLN25X" },
    ["TM_Immolate"] = { use = true, { "" }, "HLN5" },
    ["decoy_race"] = { use = true, { "" }, "HLN10" },
    ["Summit"] = { use = true, { "" }, "HLNRALLY1" },
    ["bc_clearing_ground_mp"] = { use = true, { "" }, "HLN5" },
    ["Hillbilly Mudbog"] = { use = true, { "" }, "HLN10" },
    ["daglash"] = { use = true, { "" }, "HLN10" },
    ["novasphobia_beta"] = { use = true, { "" }, "HLN10" },
    ["Navy's_playground"] = { use = true, { "" }, "HLN10" },
    ["Elara"] = { use = true, { "" }, "HLN15" },
    ["incoming"] = { use = true, { "" }, "HLN10" },
    ["measure_me"] = { use = true, { "" }, "HLN15" },
    ["Abandoned Turf"] = { use = true, { "" }, "HLN10" },
    ["jarassicpark"] = { use = true, { "" }, "HLN10" },
    ["wreck_island"] = { use = true, { "" }, "HLN10" },
    ["granulation"] = { use = true, { "" }, "HLN5" },
    ["winder_pass"] = { use = true, { "" }, "HLN10" },
    ["rampin"] = { use = true, { "" }, "HLN5" },
    ["Medical Block"] = { use = true, { "" }, "HLN5" },
    ["lava_base_rpg1"] = { use = true, { "" }, "HLN3" },
    ["atephobic"] = { use = true, { "" }, "HLN10" },
    ["barrel"] = { use = true, { "" }, "HLN10" },
    ["dessication_pb1"] = { use = true, { "" }, "HLN10" },
    ["CMT_G3_Vestigial"] = { use = true, { "" }, "HLN10" },
    ["Tusken_Raid"] = { use = true, { "" }, "HLN3" },
    ["war_field"] = { use = true, { "" }, "HLN15" },
    ["waspmania"] = { use = true, { "" }, "HLNTEST10" },
    ["Oasis"] = { use = true, { "" }, "HLN10" },
    ["lemondrop"] = { use = true, { "" }, "HLN15" },
    ["lost-castle"] = { use = true, { "" }, "HLNTEST15P" },
    ["Launch Bay"] = { use = true, { "" }, "HLN15" },
    ["spaceneedle_outpost"] = { use = true, { "" }, "HLN5" },
    ["glupo_aco"] = { use = true, { "" }, "HLNTEST10" },
    ["wpitest1_race"] = { use = true, { "" }, "HLN10" },
    ["CMT_JungleWarfare"] = { use = true, { "" }, "HLN15" },
    ["CnR_Island"] = { use = true, { "" }, "HLN_RaceFFA3" },
    ["Bear's_Turf_final"] = { use = true, { "" }, "HLN10" },
    ["3Tiers"] = { use = true, { "" }, "HLNTEST10" },
    ["hmmt_crashsite-3250"] = { use = true, { "" }, "HLN15" },
    ["Terralan"] = { use = true, { "" }, "HLN5" },
    ["storm"] = { use = true, { "" }, "HLN15" },
    ["mooncrater1.0b"] = { use = true, { "" }, "HLN5" },
    ["doublegulchv2"] = { use = true, { "" }, "HLN10" },
    ["starcanyon"] = { use = true, { "" }, "HLN10" },
    ["HGK_snowhold"] = { use = true, { "" }, "HLN15" },
    ["Infinite_Storm"] = { use = true, { "" }, "HLNFFA1X" },
    ["hq_racetrack"] = { use = true, { "" }, "HLN5" },
    ["Pimp Hogs 2"] = { use = true, { "" }, "HLN15" },
    ["RMT_hog_run_beta"] = { use = true, { "" }, "HLN5" },
    ["ancient_forest"] = { use = true, { "" }, "HLN10" },
    ["the_halo_hq"] = { use = true, { "" }, "HLN10" },
    ["bfm_final"] = { use = true, { "" }, "HLN15" },
    ["islandthunder_race"] = { use = true, { "" }, "HLN15" },
    ["CalibrationX"] = { use = true, { "" }, "HLN10" },
    ["sentinel_beta"] = { use = true, { "" }, "HLN15" },
    ["water_in-a_well"] = { use = true, { "" }, "HLNRALLY1" },
    ["Gallows"] = { use = true, { "" }, "HLN15" },
    ["island-of-murky-water"] = { use = true, { "" }, "HLN10" },
    ["Crimson_Woods"] = { use = true, { "" }, "HLN15" },
    ["camden_place"] = { use = true, { "" }, "HLN15" },
    ["Outpost_Rio_Classic"] = { use = true, { "" }, "HLN15" },
    ["frostyassault_beta1"] = { use = true, { "" }, "HLN25X" },
    ["Halcyon"] = { use = true, { "" }, "HLNTEST10" },
    ["Nervous_Canyon_Race"] = { use = true, { "" }, "HLN10" },
    ["contortion"] = { use = true, { "" }, "HLN10" },
    ["Majestic"] = { use = true, { "" }, "HLN5" },
    ["icetigaurus_beta"] = { use = true, { "" }, "HLN5" },
    ["glenns_map"] = { use = true, { "" }, "HLNTEST10" },
    ["Chronopolis_Mod"] = { use = true, { "" }, "HLN15" },
    ["Escalade-Mount"] = { use = true, { "" }, "HLNTEST10" },
    ["nightglow"] = { use = true, { "" }, "HLN15" },
    ["boxx"] = { use = true, { "" }, "HLN10" },
    ["nightcamp_ce"] = { use = true, { "" }, "HLN15" },
    ["battle_coast"] = { use = true, { "" }, "HLN10" },
    ["miniforest"] = { use = true, { "" }, "HLN25X" },
    ["lavaflows"] = { use = true, { "" }, "HLN3" },
    ["blizzard"] = { use = true, { "" }, "HLN15" },
    ["highlow"] = { use = true, { "" }, "HLN15" },
    ["bloodground_aco"] = { use = true, { "" }, "HLN10" },
    ["head_on"] = { use = true, { "" }, "HLN5" },
    ["Mayan_Sacrifice"] = { use = true, { "" }, "HLN10" },
    ["porter_creek"] = { use = true, { "" }, "HLN_HORSERACE1" },
    ["ministunt"] = { use = true, { "" }, "HLNEX5" },
    ["fojaxfield"] = { use = true, { "" }, "HLN10" },
    ["Aerorace2_Fixed"] = { use = true, { "" }, "HLN3" },
    ["mute_city_beta_2"] = { use = true, { "" }, "HLN3" },
    ["FreeLands Mod"] = { use = true, { "" }, "HLN5" },
    ["grove_final"] = { use = true, { "" }, "HLN10" },
    ["filtration"] = { use = true, { "" }, "HLN5" },
    ["a-small-race-track"] = { use = true, { "" }, "HLN10" },
    ["race_warofhog"] = { use = true, { "" }, "HLN10" },
    ["warfront_day"] = { use = true, { "" }, "HLN15" },
    ["desert_battle"] = { use = true, { "" }, "HLN10" },
    ["the_devil_fight"] = { use = true, { "" }, "HLN10" },
    ["the-great-valley"] = { use = true, { "" }, "HLN15" },
    ["secrets_of_egypt"] = { use = true, { "" }, "HLN10" },
    ["jungleRAIDV2BETA"] = { use = true, { "" }, "HLN15" },
    ["Gearshift"] = { use = true, { "" }, "HLN15" },
    ["hillbillies"] = { use = true, { "" }, "HLN15" },
    ["rainwash0.5"] = { use = true, { "" }, "HLN10" },
    ["arachnoid_alpha-0"] = { use = true, { "" }, "HLN3" },
    ["public_01"] = { use = true, { "" }, "HLN15" },
    ["destruction"] = { use = true, { "" }, "HLN25" },
    ["h2-blow-city"] = { use = true, { "" }, "HLN10" },
    ["public_02"] = { use = true, { "" }, "HLN15" },
    ["ccf"] = { use = true, { "" }, "HLN3" },
    ["cs-v2"] = { use = true, { "" }, "HLN5" },
    ["halomp-reuniontour"] = { use = true, { "" }, "HLN10" },
    ["circumference"] = { use = true, { "" }, "HLN5" },
    ["death_karts"] = { use = true, { "" }, "HLN3" },
    ["[h3] core"] = { use = true, { "" }, "HLNMRX10" },
    ["idiotic"] = { use = true, { "" }, "HLN15" },
    ["The-Quick-the-Dead"] = { use = true, { "" }, "HLN3" },
    ["orion_final"] = { use = true, { "" }, "HLN15" },
    ["elarav10"] = { use = true, { "" }, "HLNTEST15P" },
    ["Super_Stunt_Track"] = { use = true, { "" }, "HLN3" },
    ["signs"] = { use = true, { "" }, "HLN15" },
    ["volcano_enhanced"] = { use = true, { "" }, "HLN10" },
    ["hydrolysis"] = { use = true, { "" }, "HLN3" },
    ["ut2k4_deck"] = { use = true, { "" }, "HLN5" },
    ["ddzarea"] = { use = true, { "" }, "HLN3" },
    ["icext"] = { use = true, { "" }, "HLN15" },
    ["revolucion_mexicana"] = { use = true, { "" }, "HLNMR5" },
    ["hemoasis"] = { use = true, { "" }, "HLN15" },
    ["erosion"] = { use = true, { "" }, "HLN15" },
    ["discovery"] = { use = true, { "" }, "HLN15" },
    ["last_hope"] = { use = true, { "" }, "HLN10" },
    ["last_fight"] = { use = true, { "" }, "HLN15" },
    ["imposing"] = { use = true, { "" }, "HLNMRPS15" },
    ["glenns_castle"] = { use = true, { "" }, "HLN_HORSERACE1" },
    ["augury"] = { use = true, { "" }, "HLN15" },
    ["Freezing_Point"] = { use = true, { "" }, "HLN15" },
    ["erasus"] = { use = true, { "" }, "HLNMRPS10" },
    ["Sneak"] = { use = true, { "" }, "HLN10" },
    ["war_ahead"] = { use = true, { "" }, "HLNTEST10" },
    ["jump_pit"] = { use = true, { "" }, "HLN3" },
    ["Train.Station"] = { use = true, { "" }, "HLN10" },
    ["pipedream"] = { use = true, { "" }, "HLNTEST10" },
    ["forest_plains"] = { use = true, { "" }, "HLN15" },
    ["Collide_Beta_1"] = { use = true, { "" }, "HLN10" },
    ["fm_timby"] = { use = true, { "" }, "HLN15" },
    -- Repeat the structure to add custom maps.
}
-- ======================= CONFIGURATION ENDS ======================= --

function OnScriptLoad()
    register_callback(cb["EVENT_GAME_START"], "OnGameStart")
    if (get_var(0, "$gt") ~= "n/a") then
        manager:Handle("load")
    end
end

function OnScriptUnload()
    manager:Handle("unload")
end

function OnGameStart()
    if (get_var(0, "$gt") ~= "n/a") then
        manager:Handle("load")
    end
end

function manager:Handle(state)
    local current_map, mode = get_var(0, "$map"), get_var(0, "$mode")

    local scripts, modes = {}

    for map, _ in pairs(manager.settings) do
        if (map == current_map and manager.settings[map].use) then
            for _, data in pairs(manager.settings[map]) do
                if (data ~= "" and data ~= nil) then
                    if (type(data) == 'table') then
                        for i = 1, #data do
                            if (data[i] ~= "" or data[i] ~= nil) then
                                scripts[#scripts + 1] = data[i]
                            end
                        end
                    end
                    if (#scripts > 0) then
                        if (type(data) == 'string' and data == mode) then
                            for i = 1, #scripts do
                                if (state == "load") then
                                    manager:LoadScript(scripts[i])
                                else
                                    manager:UnloadScript(scripts[i])
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

function manager:LoadScript(script)
    execute_command('lua_load ' .. ' "' .. script .. '"')
end

function manager:UnloadScript(script)
    execute_command('lua_unload ' .. ' "' .. script .. '"')
end

-- For a future update:
return manager
