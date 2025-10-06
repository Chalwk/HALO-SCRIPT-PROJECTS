--[[
=====================================================================================
SCRIPT NAME:      deployable_mines.lua
DESCRIPTION:      Adds tactical mine deployment system allowing players to place
                  explosive traps that trigger when enemies approach.

FEATURES:         - Vehicle-based mine deployment system
                  - Configurable mine count per life
                  - Timed despawn for placed mines
                  - Adjustable explosion radius
                  - Team damage toggle
                  - Death message customization
                  - Vehicle-specific deployment restrictions

LAST UPDATED:     7/10/2025

Copyright (c) 2022-2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]

-- CONFIG START -----------------------------------------------
local MINES_PER_LIFE = 20
local DESPAWN_RATE = 60
local TRIGGER_RADIUS = 0.7
local MINES_KILL_TEAMMATES = false
local MINE_OBJECT = 'powerups\\health pack'
local PROJECTILE_OBJECT = 'weapons\\rocket launcher\\rocket'
local VEHICLES = {
    ['vehicles\\ghost\\ghost_mp'] = true,                                                  -- stock
    ['vehicles\\rwarthog\\rwarthog'] = true,                                               -- stock
    ['vehicles\\warthog\\mp_warthog'] = true,                                              -- stock
    ['halo3\\vehicles\\warthog\\mp_warthog'] = true,                                       -- [h3]_sandtrap
    ['halo3\\vehicles\\mongoose\\mongoose'] = true,                                        -- [h3]_sandtrap
    ['levels\\test\\racetrack\\custom_hogs\\mp_warthog_green'] = true,                     -- bc_raceway_final_mp
    ['levels\\test\\racetrack\\custom_hogs\\mp_warthog_blue'] = true,                      -- bc_raceway_final_mp
    ['levels\\test\\racetrack\\custom_hogs\\mp_warthog_multi1'] = true,                    -- bc_raceway_final_mp
    ['levels\\test\\racetrack\\custom_hogs\\mp_warthog_multi2'] = true,                    -- bc_raceway_final_mp
    ['levels\\test\\racetrack\\custom_hogs\\mp_warthog_multi3'] = true,                    -- bc_raceway_final_mp
    ['vehicles\\rwarthog\\boogerhawg'] = true,                                             -- cityscape-adrenaline
    ['vehicles\\g_warthog\\g_warthog'] = true,                                             -- hypothermia_race
    ['vehicles\\m257_multvp\\m257_multvp'] = true,                                         -- mongoose_point
    ['vehicles\\puma\\puma_lt'] = true,                                                    -- mystic_mod
    ['vehicles\\puma\\rpuma_lt'] = true,                                                   -- mystic_mod
    ['cmt\\vehicles\\evolved_h1-spirit\\warthog\\_warthog_mp\\warthog_mp'] = true,         -- tsce_multiplayerv1
    ['cmt\\vehicles\\evolved_h1-spirit\\warthog\\_warthog_rocket\\warthog_rocket'] = true, -- tsce_multiplayerv1
    ['halo3\\vehicles\\warthog\\rwarthog'] = true,                                         -- hornets_nest
    ['vehicles\\warthog\\art_cwarthog'] = true,                                            -- grove_final
    ['vehicles\\rwarthog\\art_rwarthog_shiny'] = true,                                     -- grove_final
}
-- CONFIG END -------------------------------------------------

api_version = '1.12.0.0'

local players = {}
local Mines = {}
Mines.__index = Mines

local time = os.time
local MINE_ID, PROJECTILE_ID
local jpt = {}

local sapp_events = {
    [cb['EVENT_TICK']] = 'OnTick',
    [cb['EVENT_JOIN']] = 'OnJoin',
    [cb['EVENT_LEAVE']] = 'OnQuit',
    [cb['EVENT_SPAWN']] = 'OnSpawn',
    [cb['EVENT_TEAM_SWITCH']] = 'OnSwitch'
}

local function registerCallbacks(register)
    for event, callback in pairs(sapp_events) do
        if register then
            register_callback(event, callback)
        else
            unregister_callback(event)
        end
    end
end

local function getPos(dyn_player)
    local vehicle_id = read_dword(dyn_player + 0x11C)
    local vehicle_object = get_object_memory(vehicle_id)
    local pos = {}

    if vehicle_id == 0xFFFFFFFF then
        pos.x, pos.y, pos.z = read_vector3d(dyn_player + 0x5c)
    elseif vehicle_object ~= 0 then
        pos.vehicle = vehicle_object
        pos.seat = read_word(dyn_player + 0x2F0)
        pos.x, pos.y, pos.z = read_vector3d(vehicle_object + 0x5c)
    end

    return pos
end

local function inRange(x1, y1, z1, x2, y2, z2)
    local dx = x1 - x2
    local dy = y1 - y2
    local dz = z1 - z2
    return (dx * dx + dy * dy + dz * dz) <= TRIGGER_RADIUS
end

local function getTag(Type, Name)
    local Tag = lookup_tag(Type, Name)
    return (Tag ~= 0 and read_dword(Tag + 0xC)) or nil
end

function Mines:NewPlayer(o)
    setmetatable(o, self)
    o.flashlight = 0
    o.mines = MINES_PER_LIFE
    return o
end

function Mines:NewMine(pos, cur_time)
    if self.mines == 0 then
        rprint(self.id, "No more mines for this life!")
        return
    end

    if not pos.seat then return end
    if pos.seat ~= 0 then
        rprint(self.id, 'You must be in the driver\'s seat')
        return
    end

    local vehicle_tag = read_string(read_dword(read_word(pos.vehicle) * 32 + 0x40440038))
    if not VEHICLES[vehicle_tag] then
        rprint(self.id, 'This vehicle cannot deploy mines')
        return
    end

    local mine = spawn_object('', '', pos.x, pos.y, pos.z, 0, MINE_ID)
    Mines.objects[mine] = {
        owner = self.id,
        expiration = cur_time + DESPAWN_RATE,
        destroy = function(m, mx, my, mz)
            destroy_object(m)
            Mines.objects[m] = nil
            if mx then
                EditRocket()
                local proj = spawn_projectile(PROJECTILE_ID, 0, mx, my, mz)
                local object = get_object_memory(proj)
                write_float(object + 0x68, 0)
                write_float(object + 0x6C, 0)
                write_float(object + 0x70, -9999)
                timer(1000, "EditRocket", "true")
            end
        end
    }

    self.mines = self.mines - 1
    rprint(self.id, 'Mine Deployed! ' .. self.mines .. '/' .. MINES_PER_LIFE)
end

function OnScriptLoad()
    register_callback(cb['EVENT_GAME_START'], 'OnStart')
    OnStart()
end

function OnStart()
    if get_var(0, '$gt') == 'n/a' then return end

    jpt = {}

    MINE_ID = getTag('eqip', MINE_OBJECT)
    PROJECTILE_ID = getTag('proj', PROJECTILE_OBJECT)

    -- If either mine ID or projectile ID is nil, disable the script
    if not MINE_ID or not PROJECTILE_ID then
        registerCallbacks(false)
        error('Deployable Mines: Failed to load! Could not find valid mine or projectile tags.')
        return
    end

    Mines.objects = {}
    local tag_count = read_dword(0x4044000C)
    local tag_address = read_dword(0x40440000)

    for i = 0, tag_count - 1 do
        local tag = tag_address + 0x20 * i
        local tag_name = read_string(read_dword(tag + 0x10))
        local tag_class = read_dword(tag)
        if tag_class == 1785754657 and tag_name == 'weapons\\rocket launcher\\explosion' then
            local tag_data = read_dword(tag + 0x14)
            jpt = {
                [tag_data + 0x1d0] = { 1148846080, 1117782016 },
                [tag_data + 0x1d4] = { 1148846080, 1133903872 },
                [tag_data + 0x1d8] = { 1148846080, 1134886912 },
                [tag_data + 0x1f4] = { 1092616192, 1086324736 }
            }
            break
        end
    end

    for i = 1, 16 do
        if player_present(i) then
            OnJoin(i)
        end
    end

    registerCallbacks(true)
end

function OnJoin(id)
    players[id] = Mines:NewPlayer({
        id = id,
        name = get_var(id, '$name'),
        team = get_var(id, '$team')
    })
end

function OnQuit(id)
    for mine, t in pairs(Mines.objects) do
        if t.owner == id then
            t.destroy(mine)
        end
    end
    players[id] = nil
end

function OnSpawn(id)
    local player = players[id]
    if player then
        player.mines = MINES_PER_LIFE
    end
end

function OnSwitch(id)
    local player = players[id]
    if player then
        player.team = get_var(id, '$team')
    end
end

function EditRocket(rollback)
    for address, v in pairs(jpt) do
        write_dword(address, rollback and v[2] or v[1])
    end
end

local function handlePlayerMines(player, dyn_player, cur_time)
    local flashlight = read_bit(dyn_player + 0x208, 4)
    if player.flashlight ~= flashlight and flashlight == 1 then
        player:NewMine(getPos(dyn_player), cur_time)
    end
    player.flashlight = flashlight
end

local function handleMineExpiration(player, i, cur_time)
    for mine, t in pairs(Mines.objects) do
        if cur_time >= t.expiration then
            t.destroy(mine)
        elseif t.owner ~= i and player_alive(i) then
            local dyn_player = get_dynamic_player(i)
            if dyn_player == 0 then goto continue end

            local object = get_object_memory(mine)
            if object == 0 then goto continue end

            if not MINES_KILL_TEAMMATES and player.team == get_var(t.owner, '$team') then
                goto continue
            end

            local pos = getPos(dyn_player)
            local mx, my, mz = read_vector3d(object + 0x5C)
            if inRange(pos.x, pos.y, pos.z, mx, my, mz) then
                t.destroy(mine, mx, my, mz)
            end
        end
        ::continue::
    end
end

function OnTick()
    local cur_time = time()
    for i, player in pairs(players) do
        if not player then goto continue end

        local dyn_player = get_dynamic_player(i)
        if player_alive(i) and dyn_player ~= 0 then
            handlePlayerMines(player, dyn_player, cur_time)
        end

        handleMineExpiration(player, i, cur_time)
        ::continue::
    end
end

function OnScriptUnload() end
