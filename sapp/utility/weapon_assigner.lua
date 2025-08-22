--[[
===============================================================================
SCRIPT NAME:      weapon_assigner.lua
DESCRIPTION:      Custom weapon assignment system that automatically gives players
                  specific weapon loadouts based on map, game mode, and team.
                  - Configurable per map and game mode
                  - Team-specific weapon sets (Red, Blue, FFA)
                  - Supports both stock and custom game modes

LAST UPDATED:     22/08/2025

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

-- Map and game mode configuration:
-- Format: ['map_name'] = {
--     ['game_mode'] = {
--         team_name = { 'weapon1', 'weapon2', ... },
--         ...
--     },
--     ...
-- }
--
-- Key points:
-- - Use 'default' for fallback configuration when specific game mode isn't defined
-- - Teams: 'red', 'blue', 'ffa' (for free-for-all modes)
-- - Weapon names must match keys in the weapon_tags table above
-- - First 2 weapons are equipped immediately, others are added to inventory
local maps = {
    ['bloodgulch'] = {
        ['default'] = {
            red = { 'pistol', 'assault_rifle' },
            blue = { 'pistol', 'assault_rifle' },
            ffa = { 'pistol', 'shotgun' }
        },
        ['ctf'] = {
            red = { 'pistol', 'sniper', 'rocket_launcher' },
            blue = { 'pistol', 'plasma_rifle', 'flamethrower' }
        },
        ['custom_gamemode'] = {
            red = { 'pistol', 'pistol', 'pistol' },
            blue = { 'pistol', 'pistol', 'pistol' }
        }
        -- Add more game mode/types here (stock or custom)
    },

    -- Add more maps here following the same format
    -- ['map_name'] = {
    --     ['game_mode'] = {
    --         red = { 'weapon1', 'weapon2' },
    --         blue = { 'weapon1', 'weapon2' },
    --         ffa = { 'weapon1', 'weapon2' }
    --     }
    -- }
}
-- Configuration end ----------------------------------------------------------

api_version = '1.12.0.0'

local current_loadout = {}
local map_name, game_mode, is_ffa

local table_insert = table.insert
local pairs, ipairs = pairs, ipairs

local function resolve_weapon_tag(weapon_name)
    local tag_path = weapon_tags[weapon_name]
    if not tag_path then return nil end

    local tag = lookup_tag('weap', tag_path)
    return tag ~= 0 and read_dword(tag + 0xC) or nil
end

local function initialize_loadout()
    current_loadout = {}
    local config = maps[map_name] or {}

    local mode_config = config[game_mode] or config.default
    if not mode_config then
        cprint("Weapon Assigner: No configuration found for map '" .. map_name .. "'", 12)
        return false
    end

    for team, weapons in pairs(mode_config) do
        current_loadout[team] = {}
        for _, weapon_name in ipairs(weapons) do
            local tag_id = resolve_weapon_tag(weapon_name)
            if not tag_id then
                cprint("Weapon Assigner: Invalid weapon '" .. weapon_name .. "' for team " .. team, 12)
                return false
            end
            table_insert(current_loadout[team], tag_id)
        end
    end

    return true
end

function OnSpawn(id)
    local team = is_ffa and 'ffa' or get_var(id, '$team')
    local weapons = current_loadout[team] or current_loadout.default

    if not weapons then return end

    execute_command("wdel " .. id)

    for i, tag_id in ipairs(weapons) do
        if i <= 4 then
            print(i, tag_id)
            local weapon = spawn_object('', '', 0, 0, 0, 0, tag_id)
            if i <= 2 then
                assign_weapon(weapon, id)
            else
                timer(250, 'assign_weapon', weapon, id)
            end
        end
    end
end

function OnStart()
    if get_var(0, '$gt') == 'n/a' then return end

    map_name, game_mode, is_ffa = get_var(0, '$map'), get_var(0, '$mode'), get_var(0, '$ffa') == '1'

    if initialize_loadout() then
        register_callback(cb['EVENT_SPAWN'], 'OnSpawn')
        cprint("Weapon Assigner: Loadout initialized for " .. map_name, 10)
    else
        unregister_callback(cb['EVENT_SPAWN'])
        cprint("Weapon Assigner: Using default game weapons", 10)
    end
end

function OnScriptLoad()
    register_callback(cb['EVENT_GAME_START'], 'OnStart')
    OnStart()
end

function OnScriptUnload() end