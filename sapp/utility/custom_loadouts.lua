--=====================================================================================--
-- SCRIPT NAME:      Advanced Loadout System
-- DESCRIPTION:      Players select custom loadouts via commands, which apply on respawn.
--                   Features persistent player loadout settings, admin control
--                   commands, configurable loadouts with weapon/ammo setup, and
--                   optional death messages showing available loadouts.
--
-- AUTHOR:           Chalwk (Jericho Crosby)
-- COMPATIBILITY:    Halo PC/CE | SAPP 1.12.0.0
--
-- Copyright (c) 2024-2025 Jericho Crosby <jericho.crosby227@gmail.com>
-- LICENSE:          MIT License
--                   https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================--

-- CONFIG START ---------------------------------------------------------------
local CFG = {
    -- Whether to show the loadout menu automatically when a player dies
    death_messages = true,

    -- The ID of the loadout players start with by default
    default_loadout = 1,

    -- Command names used to interact with the loadout system via chat
    commands = {
        base = "loadout", -- Base command players type to access the system (e.g. "/loadout")
        list = "list",    -- Subcommand to display available loadouts (e.g. "/loadout list")
        set = "set"       -- Subcommands to assign loadouts to other players (e.g. "/loadout set <id> <loadout_id>")
    },

    -- Weapon tag paths to identify weapons in the game for loadouts
    weapon_tags = {
        pistol = 'weapons\\pistol\\pistol',
        sniper_rifle = 'weapons\\sniper rifle\\sniper rifle',
        plasma_cannon = 'weapons\\plasma_cannon\\plasma_cannon',
        rocket_launcher = 'weapons\\rocket launcher\\rocket launcher',
        plasma_pistol = 'weapons\\plasma pistol\\plasma pistol',
        plasma_rifle = 'weapons\\plasma rifle\\plasma rifle',
        assault_rifle = 'weapons\\assault rifle\\assault rifle',
        flamethrower = 'weapons\\flamethrower\\flamethrower',
        needler = 'weapons\\needler\\mp_needler',
        shotgun = 'weapons\\shotgun\\shotgun'
    },

    -- Define player loadouts: weapons, ammo, and grenade counts
    loadouts = {
        {
            id = 1,           -- Unique loadout ID
            name = "Default", -- Loadout display name
            frags = 1,        -- Number of frag grenades given
            plasmas = 3,      -- Number of plasma grenades given
            weapons = {       -- Weapons included with clip & ammo counts
                ['weapons\\assault rifle\\assault rifle'] = { label = 'Assault Rifle', clip = 60, ammo = 120 },
                ['weapons\\pistol\\pistol'] = { label = 'Pistol', clip = 12, ammo = 48 }
            }
        },
        {
            id = 2,
            name = "LoneWolf",
            frags = 0,
            plasmas = 0,
            weapons = {
                ['weapons\\sniper rifle\\sniper rifle'] = { label = 'Sniper Rifle', clip = 4, ammo = 8 }
            }
        },
        {
            id = 3,
            name = "ShottySnipes",
            frags = 0,
            plasmas = 0,
            weapons = {
                ['weapons\\shotgun\\shotgun'] = { label = 'Shotgun', clip = 12, ammo = 24 },
                ['weapons\\sniper rifle\\sniper rifle'] = { label = 'Sniper Rifle', clip = 4, ammo = 8 }
            }
        },
        {
            id = 4,
            name = "HeavyOrdnance",
            frags = 2,
            plasmas = 0,
            weapons = {
                ['weapons\\rocket launcher\\rocket launcher'] = { label = 'Rocket Launcher', clip = 2, ammo = 4 },
                ['weapons\\plasma_cannon\\plasma_cannon'] = { label = 'Plasma Cannon', clip = 100, ammo = 200 },
                ['weapons\\pistol\\pistol'] = { label = 'Pistol', clip = 12, ammo = 48 }
            }
        }
        -- Add other loadouts here using the same structure as above
    }
}
-- CONFIG END -----------------------------------------------------------------

api_version = '1.12.0.0'

local weapon_datums = {}
local players = {}
local loadouts_by_id = {}
local player_data = {}

local function get_player_name(id) return get_var(id, '$name') end

local function set_grenades(dyn_player, frags, plasmas)
    write_byte(dyn_player + 0x31E, frags)
    write_byte(dyn_player + 0x31F, plasmas)
end

local function get_tag(class, name)
    local tag = lookup_tag(class, name)
    return tag ~= 0 and read_dword(tag + 0xC) or nil
end

local function cache_weapon_datums()
    for _, tag_string in pairs(CFG.weapon_tags) do
        weapon_datums[tag_string] = get_tag('weap', tag_string)
    end
end

function AssignWeapon(id, weapon)
    if weapon then assign_weapon(weapon, id) end
end

local function spawn_weapon(id, tag_string, attributes, slot)
    local tag_datum = weapon_datums[tag_string]
    if not tag_datum then return end

    local weapon = spawn_object('', '', 0, 0, 0, 0, tag_datum)
    local weapon_mem = get_object_memory(weapon)
    if weapon_mem ~= 0 then
        write_word(weapon_mem + 0x2B6, attributes.ammo)
        write_word(weapon_mem + 0x2B8, attributes.clip)
        sync_ammo(weapon)
        if slot <= 2 then
            AssignWeapon(id, weapon)               -- Primary and secondary weapons
        else
            timer(250, 'AssignWeapon', id, weapon) -- tertiary/quaternary
        end
    end
end

local function apply_loadout(id)
    local dyn_player = get_dynamic_player(id)
    if dyn_player == 0 then return end

    execute_command('wdel ' .. id)

    local loadout_id = players[id] or CFG.default_loadout
    local loadout = loadouts_by_id[loadout_id] or loadouts_by_id[CFG.default_loadout]
    if not loadout then return end

    local slot = 0
    for tag_string, attributes in pairs(loadout.weapons) do
        slot = slot + 1
        spawn_weapon(id, tag_string, attributes, slot)
    end

    set_grenades(dyn_player, loadout.frags, loadout.plasmas)
end

local function show_current_loadout(id)
    local loadout_id = players[id] or CFG.default_loadout
    local loadout = loadouts_by_id[loadout_id]
    if loadout then
        rprint(id, "Current Loadout: #" .. loadout_id .. " - " .. loadout.name)
    end
end

local function show_available_loadouts(id)
    rprint(id, "Available Loadouts:")
    for _, loadout in ipairs(CFG.loadouts) do
        local weapon_list = ""
        for _, weapon in pairs(loadout.weapons) do
            weapon_list = weapon_list .. weapon.label .. ", "
        end
        weapon_list = weapon_list:sub(1, -3)

        local status = (players[id] == loadout.id) and "[CURRENT] " or ""
        rprint(id, status .. "/" .. loadout.id .. ": " .. loadout.name ..
            " | Weapons: " .. weapon_list ..
            " | Frags: " .. loadout.frags ..
            " | Plasmas: " .. loadout.plasmas)
    end
    rprint(id, "Use /loadout [number] to select")
end

local function process_loadout_command(id, selected_id)
    if loadouts_by_id[selected_id] then
        players[id] = selected_id
        player_data[get_player_name(id)] = selected_id
        rprint(id, "Loadout #" .. selected_id .. " selected. Will apply on respawn.")
        return true
    end
    return false
end

local function process_admin_command(id, args)
    if tonumber(get_var(id, "$lvl")) < 1 then return false end

    local target_id = tonumber(args[3])
    local loadout_id = tonumber(args[4])

    if not target_id or not player_present(target_id) then
        rprint(id, "Invalid player ID.")
        return false
    end
    if not loadouts_by_id[loadout_id] then
        rprint(id, "Invalid loadout ID.")
        return false
    end

    players[target_id] = loadout_id
    local target_name = get_player_name(target_id)
    player_data[target_name] = loadout_id
    rprint(id, string.format("Set player ID %d (%s) loadout to #%d", target_id, target_name, loadout_id))
end

local function stringSplit(s)
    local args = {}
    for arg in s:gmatch('([^%s]+)') do
        args[#args + 1] = arg:lower()
    end
    return args
end

function OnCommand(id, command)
    if id == 0 then return true end

    command = command:lower()
    local args = stringSplit(command)
    if args[1] ~= CFG.commands.base then return true end

    if #args == 1 then
        show_current_loadout(id)
    elseif args[2] == CFG.commands.list then
        show_available_loadouts(id)
    elseif args[2] == CFG.commands.set then
        process_admin_command(id, args)
    elseif args[2]:match('^%d+$') then
        local selected_id = tonumber(args[2])
        if selected_id then
            process_loadout_command(id, selected_id)
        else
            rprint(id, "Unknown loadout ID. Use /" .. CFG.commands.base .. " " .. CFG.commands.list .. " to see options.")
        end
    else
        rprint(id, "Unknown command. Use /" .. CFG.commands.base .. " " .. CFG.commands.list .. " to see options.")
    end

    return false
end

function OnScriptLoad()
    for _, loadout in ipairs(CFG.loadouts) do
        loadouts_by_id[loadout.id] = loadout
    end

    register_callback(cb['EVENT_JOIN'], 'OnJoin')
    register_callback(cb['EVENT_LEAVE'], 'OnQuit')
    register_callback(cb['EVENT_DIE'], 'OnDeath')
    register_callback(cb['EVENT_SPAWN'], 'OnSpawn')
    register_callback(cb['EVENT_COMMAND'], 'OnCommand')
    register_callback(cb['EVENT_GAME_START'], 'OnGameStart')

    OnGameStart()
end

function OnGameStart()
    if get_var(0, '$gt') == 'n/a' then return end
    cache_weapon_datums() -- import to do this here (not in OnScriptLoad)

    for i = 1, 16 do
        if player_present(i) then
            OnJoin(i)
        end
    end
end

function OnJoin(id)
    local player_name = get_player_name(id)
    players[id] = player_data[player_name] or CFG.default_loadout
end

function OnSpawn(id)
    apply_loadout(id)
end

function OnDeath(id)
    if not CFG.death_messages then return end
    show_available_loadouts(id)
end

function OnQuit(id)
    players[id] = nil
end

function OnScriptUnload() end
