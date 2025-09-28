--[[
===============================================================================
SCRIPT NAME:      weapon_assigner.lua
DESCRIPTION:      Custom weapon assignment system that automatically gives players
                  specific weapon loadouts based on map, game mode, and team.
                  - Configurable per map and game mode
                  - Team-specific weapon sets (Red, Blue, FFA)
                  - Supports both stock and custom game modes

LAST UPDATED:     28/08/2025

Copyright (c) 2024-2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
===============================================================================
]]

-- Configuration start --------------------------------------------------------
-- Weapon tag definitions: Maps friendly names to actual Halo tag paths
-- Add new weapons here using the format: friendly_name = 'tag\\path\\to\\weapon'
local weapon_tags = {
    pistol = 'weapons\\pistol\\pistol',
    sniper = 'weapons\\sniper rifle\\sniper rifle',
    plasma_cannon = 'weapons\\plasma_cannon\\plasma_cannon',
    rocket_launcher = 'weapons\\rocket launcher\\rocket launcher',
    plasma_pistol = 'weapons\\plasma pistol\\plasma pistol',
    plasma_rifle = 'weapons\\plasma rifle\\plasma rifle',
    assault_rifle = 'weapons\\assault rifle\\assault rifle',
    flamethrower = 'weapons\\flamethrower\\flamethrower',
    needler = 'weapons\\needler\\mp_needler',
    shotgun = 'weapons\\shotgun\\shotgun',
    gravity_rifle = 'weapons\\gravity rifle\\gravity rifle'
}

-- Grenade configuration
-- Add grenade counts per team for each map and game mode
-- Format: frags = number, plasmas = number
local maps = {

    default = {
        red = {
            weapons = { 'pistol', 'assault_rifle' },
            grenades = { frags = 1, plasmas = 1 }
        },
        blue = {
            weapons = { 'pistol', 'assault_rifle' },
            grenades = { frags = 1, plasmas = 1 }
        },
        ffa = {
            weapons = { 'pistol', 'sniper' },
            grenades = { frags = 1, plasmas = 1 }
        }
    },

    -- EXAMPLE MAPS:

    ['destiny'] = {
        ['MOSH_PIT_CTF'] = {
            red = {
                weapons = { 'pistol', 'sniper' },
                grenades = { frags = 1, plasmas = 1 }
            },
            blue = {
                weapons = { 'pistol', 'sniper' },
                grenades = { frags = 1, plasmas = 1 }
            }
        },
        ['MOSH_PIT_TEAM_SLAYER'] = {
            red = {
                weapons = { 'pistol', 'sniper' },
                grenades = { frags = 1, plasmas = 1 }
            },
            blue = {
                weapons = { 'pistol', 'sniper' },
                grenades = { frags = 1, plasmas = 1 }
            }
        },
        ['MOSH_PIT_FFA_SLAYER'] = {
            ffa = {
                weapons = { 'pistol', 'sniper' },
                grenades = { frags = 1, plasmas = 1 }
            }
        },
    },
    ['graveyard'] = {
        ['MOSH_PIT_CTF'] = {
            red = {
                weapons = { 'pistol', 'sniper' },
                grenades = { frags = 1, plasmas = 1 }
            },
            blue = {
                weapons = { 'pistol', 'sniper' },
                grenades = { frags = 1, plasmas = 1 }
            }
        },
        ['MOSH_PIT_TEAM_SLAYER'] = {
            red = {
                weapons = { 'pistol', 'sniper' },
                grenades = { frags = 1, plasmas = 1 }
            },
            blue = {
                weapons = { 'pistol', 'sniper' },
                grenades = { frags = 1, plasmas = 1 }
            }
        },
        ['MOSH_PIT_FFA_SLAYER'] = {
            ffa = {
                weapons = { 'pistol', 'sniper' },
                grenades = { frags = 1, plasmas = 1 }
            }
        },
    }
}
-- Configuration end ----------------------------------------------------------

api_version = '1.12.0.0'

local current_loadout = {}
local map_name, game_mode, is_ffa

local table_insert = table.insert
local pairs, ipairs = pairs, ipairs

local function getTagID(tag_path)
    local tag = lookup_tag('weap', tag_path)
    return tag ~= 0 and read_dword(tag + 0xC) or nil
end

local function initialize()
    current_loadout = {}
    local config = maps[map_name]

    local mode_config = config[game_mode] or config.default
    if not mode_config then
        cprint("Weapon Assigner: No configuration found for map '"
            .. map_name .. "' and mode '"
            .. game_mode .. "'", 12)
        return false
    end

    for team, loadout in pairs(mode_config) do
        current_loadout[team] = { weapons = {}, grenades = loadout.grenades }

        for _, weapon_name in ipairs(loadout.weapons) do
            local tag_id = getTagID(weapon_name)
            if not tag_id then
                cprint("Weapon Assigner: Invalid weapon '" .. weapon_name .. "' for team " .. team, 12)
                return false
            end
            table_insert(current_loadout[team].weapons, tag_id)
        end
    end

    return true
end

function OnSpawn(id)
    local team = is_ffa and 'ffa' or get_var(id, '$team')
    local loadout = current_loadout[team]
    if not loadout then return end

    execute_command("wdel " .. id)

    for i, tag_id in ipairs(loadout.weapons) do
        if i <= 4 then
            local weapon = spawn_object('', '', 0, 0, 0, 0, tag_id)
            if i <= 2 then
                assign_weapon(weapon, id)
            else
                timer(250, 'assign_weapon', weapon, id)
            end
        end
    end

    local grenades = loadout.grenades
    execute_command('nades ' .. id .. ' ' .. grenades.frags .. ' 1')
    execute_command('nades ' .. id .. ' ' .. grenades.plasmas .. ' 2')
end

function OnStart()
    if get_var(0, '$gt') == 'n/a' then return end

    map_name, game_mode, is_ffa = get_var(0, '$map'), get_var(0, '$mode'), get_var(0, '$ffa') == '1'

    if initialize() then
        register_callback(cb['EVENT_SPAWN'], 'OnSpawn')
    else
        unregister_callback(cb['EVENT_SPAWN'])
    end
end

function OnScriptLoad()
    register_callback(cb['EVENT_GAME_START'], 'OnStart')
    OnStart()
end

function OnScriptUnload() end
