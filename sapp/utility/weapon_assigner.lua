--=====================================================================================--
-- SCRIPT NAME:      Weapon Assigner
-- DESCRIPTION:      Dynamically assigns weapons to players based on map and game mode.
--                   Supports per-map and per-game-mode loadouts for Red, Blue, and FFA
--                   teams with up to four weapons per player. Validates weapon tags and
--                   provides fallback configurations.
--
-- AUTHOR:           Chalwk (Jericho Crosby)
-- COMPATIBILITY:    Halo PC/CE | SAPP 1.12.0.0
--
-- Copyright (c) 2022-2025 Jericho Crosby
-- LICENSE:          MIT License
--                   https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================--

--[[
CONFIGURATION GUIDE:

The "Config" table defines which weapons players spawn with on a per-map, per-game-mode basis.

1. **weapon_tags Table**
   - This table lists all available weapons by assigning them a numerical index.
   - Each weapon is represented by its corresponding tag path.
   - You do NOT need to modify this unless you want to add custom weapons.

2. **maps Table**
   - This table contains configurations for specific maps.
   - Each map has a "default" configuration and optional game-mode-specific configurations.
   - The "default" configuration applies if no specific game mode is configured for that map.
   - Each configuration contains weapon assignments for "red", "blue", and "ffa" (Free-for-All) teams.
   - Each weapon assignment is defined as an array of numerical indices that refer to "weapon_tags".
   - You can assign up to **4 weapons** per player.

Example:
   - "bloodgulch": The "["default"]" setup gives both Red and Blue teams the pistol (1) and sniper rifle (2).
   - "["example_game_mode"]": Red team gets three weapons (pistol, sniper, plasma cannon), Blue gets four weapons, and FFA gets three.

How to customize:
1. To change weapon loadouts, modify the numerical indices inside the team tables.
2. To add a new map, create a new entry in "maps" with a structure similar to the examples provided.
3. To add a new game mode to a map, define a new key within that map's table and specify the weapons for each team.

]]

api_version = "1.12.0.0"

local Config = {
    weapon_tags = {
        [1] = 'weapons\\pistol\\pistol',
        [2] = 'weapons\\sniper rifle\\sniper rifle',
        [3] = 'weapons\\plasma_cannon\\plasma_cannon',
        [4] = 'weapons\\rocket launcher\\rocket launcher',
        [5] = 'weapons\\plasma pistol\\plasma pistol',
        [6] = 'weapons\\plasma rifle\\plasma rifle',
        [7] = 'weapons\\assault rifle\\assault rifle',
        [8] = 'weapons\\flamethrower\\flamethrower',
        [9] = 'weapons\\needler\\mp_needler',
        [10] = 'weapons\\shotgun\\shotgun',
        [11] = 'weapons\\ball\\ball',
        [12] = 'weapons\\gravity rifle\\gravity rifle',
    },
    maps = {
        bloodgulch = {
            default = { red = { 1, 2 }, blue = { 1, 2 }, ffa = { 1, 2 } },
            ["example_game_mode"] = { red = { 1, 2, 3 }, blue = { 4, 1, 8, 10 }, ffa = { 5, 6, 7 } }
        },
        another_map = {
            default = { red = { 1, 2, 7 }, blue = { 1, 2, 7 }, ffa = { 1, 2, 7 } },
            ["custom_game_mode"] = { red = { 5, 6, 3, 8 }, blue = { 5, 6, 3, 8 }, ffa = { 1, 7, 2 } }
        }
    }
}

local loadout
local weapons = {}
local map, mode, isFFA

local function GetTag(class, name)
    local Tag = lookup_tag(class, name)
    return Tag ~= 0 and read_dword(Tag + 0xC) or nil
end

local function tagsToID()
    weapons = {}

    local weaponList = Config.maps[map] and (Config.maps[map][mode] or Config.maps[map].default)

    if not weaponList then
        cprint("[Weapon Assigner] -> ERROR: No configuration found for map '" .. map .. "' and mode '" .. mode .. "'.", 12)
        return false
    end

    if not Config.maps[map][mode] then
        cprint("[Weapon Assigner] -> WARNING: Game-mode '" .. mode .. "' is not configured for map '" .. map .. "'. Falling back to default weapons table.", 12)
    end

    local temp = {}
    for team, weapon_table in pairs(weaponList) do
        temp[team] = {}
        for _, weaponIndex in ipairs(weapon_table) do
            local tag_name = Config.weapon_tags[weaponIndex]
            if not tag_name then
                cprint("[Weapon Assigner] -> ERROR: Invalid weapon index '" .. weaponIndex .. "' for team '" .. team .. "'.", 12)
                return false
            end

            local meta_id = GetTag('weap', tag_name)
            if meta_id then
                temp[team][meta_id] = weaponIndex
            else
                cprint("[Weapon Assigner] -> ERROR: Weapon tag '" .. tag_name .. "' is not valid for map '" .. map .. "' and team '" .. team .. "'.", 12)
                return false
            end
        end
    end

    weapons = temp
    return true
end

function AssignWeapon(weaponID, player)
    assign_weapon(weaponID, player)
end

function OnSpawn(player)
    local team = get_var(player, '$team')
    loadout = weapons[isFFA and 'ffa' or team]
    execute_command("wdel " .. player)
    local assigned = 0
    for meta_id, _ in pairs(loadout) do
        if assigned < 4 then
            local weapon = spawn_object('', '', 0, 0, 0, 0, meta_id)
            if assigned < 2 then
                AssignWeapon(weapon, player)
            else
                timer(250, 'AssignWeapon', weapon, player)
            end
            assigned = assigned + 1
        end
    end
end

function OnStart()
    if get_var(0, '$gt') ~= 'n/a' then
        map = get_var(0, '$map')
        mode = get_var(0, '$mode')
        isFFA = (get_var(0, '$ffa') == '1')
        if tagsToID() then
            register_callback(cb['EVENT_SPAWN'], 'OnSpawn')
        else
            unregister_callback(cb['EVENT_SPAWN'])
        end
    end
end

function OnScriptLoad()
    register_callback(cb['EVENT_GAME_START'], 'OnStart')
end

function OnScriptUnload()
    -- N/A
end