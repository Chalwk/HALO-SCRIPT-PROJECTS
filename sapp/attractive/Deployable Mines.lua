--[[
--=====================================================================================================--
Script Name: Deployable Mines, for SAPP (PC & CE)
Description: This Lua script allows players to deploy mines that explode
             when enemies come within a certain radius.

Copyright (c) 2019-2024, Jericho Crosby <jericho.crosby227@gmail.com>
Notice: You can use this script subject to the following conditions:
https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================================--
]]--

-- Configuration table for the deployable mines script
local config = {
    -- Number of mines a player can deploy per life
    mines_per_life = 20,

    -- Time in seconds before a deployed mine despawns
    despawn_rate = 60,

    -- Radius within which a mine will explode when an enemy is detected
    radius = 0.7,

    -- Toggle for displaying death messages
    death_messages = false,

    -- Toggle for allowing mines to kill teammates
    mines_kill_teammates = false,

    -- Object type and path for the mine
    mine_object = { 'eqip', 'powerups\\health pack' },

    -- Table defining which vehicles can deploy mines
    vehicles = {
        ['vehicles\\ghost\\ghost_mp'] = true,
        ['vehicles\\rwarthog\\rwarthog'] = true,
        ['vehicles\\warthog\\mp_warthog'] = true,
        ['vehicles\\banshee\\banshee_mp'] = true,
        ['vehicles\\scorpion\\scorpion_mp'] = false,
        ['vehicles\\c gun turret\\c gun turret_mp'] = false
    },

    -- Prefix for server messages
    server_prefix = "**SAPP**"
}

-- SAPP Lua API Version
api_version = '1.12.0.0'

-- State variables
local players = {}
local time = os.time
local sqrt = math.sqrt
local dma_original, dma
local ffa, falling, distance

-- Function to disable default death messages
local function DisableDeathMessages()
    if config.death_messages then
        dma = sig_scan("8B42348A8C28D500000084C9") + 3
        dma_original = read_dword(dma)
        safe_write(true)
        write_dword(dma, 0x03EB01B1)
        safe_write(false)
    end
end

-- Function to enable default death messages
local function EnableDeathMessages()
    safe_write(true)
    write_dword(dma, dma_original)
    safe_write(false)
end

-- Function to get the position of a player or vehicle
local function GetPos(DyN)
    local pos = {}
    local VehicleID = read_dword(DyN + 0x11C)
    local vehicle = get_object_memory(VehicleID)

    if VehicleID == 0xFFFFFFFF then
        pos.x, pos.y, pos.z = read_vector3d(DyN + 0x5c)
    elseif vehicle ~= 0 then
        pos.vehicle = vehicle
        pos.seat = read_word(DyN + 0x2F0)
        pos.x, pos.y, pos.z = read_vector3d(vehicle + 0x5c)
    end

    return pos
end

-- Function to calculate the distance between two points
local function Dist(x1, y1, z1, x2, y2, z2)
    return sqrt((x1 - x2) ^ 2 + (y1 - y2) ^ 2 + (z1 - z2) ^ 2)
end

-- Class for managing mines
local Mines = {}
Mines.__index = Mines

function Mines:NewPlayer(o)
    setmetatable(o, self)
    o.meta = 0
    o.killer = 0
    o.flashlight = 0
    o.mines = config.mines_per_life
    return o
end

function Mines:NewMine(pos)
    if self.mines == 0 then
        rprint(self.pid, "No more mines for this life!")
        return
    elseif pos.seat then
        if pos.seat ~= 0 then
            rprint(self.pid, 'You must be in the driver\'s seat')
            return
        elseif not config.vehicles[read_string(read_dword(read_word(pos.vehicle) * 32 + 0x40440038))] then
            rprint(self.pid, 'This vehicle cannot deploy mines')
            return
        end

        local x, y, z = pos.x, pos.y, pos.z
        local mine = spawn_object('', '', x, y, z, 0, self.mine)
        self.objects[mine] = {
            owner = self.pid,
            expiration = time() + config.despawn_rate,
            destroy = function(m, mx, my, mz)
                destroy_object(m)
                Mines.objects[m] = nil
                if mx then
                    EditRocket()
                    local proj = spawn_projectile(self.projectile, 0, mx, my, mz)
                    local object = get_object_memory(proj)
                    write_float(object + 0x68, 0)
                    write_float(object + 0x6C, 0)
                    write_float(object + 0x70, -9999)
                    timer(1000, "EditRocket", "true")
                end
            end
        }

        self.mines = self.mines - 1
        rprint(self.pid, 'Mine Deployed! ' .. self.mines .. '/' .. config.mines_per_life)
    end
end

-- Event handler for script load
function OnScriptLoad()
    register_callback(cb['EVENT_GAME_START'], 'OnStart')
    OnStart()
end

-- Function to get tag ID
local function GetTag(Type, Name)
    local Tag = lookup_tag(Type, Name)
    return (Tag ~= 0 and read_dword(Tag + 0xC)) or nil
end

-- Event handler for game start
function OnStart()
    if get_var(0, '$gt') ~= 'n/a' then
        Mines.mine = GetTag(config.mine_object[1], config.mine_object[2])
        Mines.explosion = GetTag('jpt!', 'weapons\\rocket launcher\\explosion')
        Mines.projectile = GetTag('proj', 'weapons\\rocket launcher\\rocket')

        if Mines.mine and Mines.explosion and Mines.projectile then
            falling = GetTag('jpt!', 'globals\\falling')
            distance = GetTag('jpt!', 'globals\\distance')
            ffa = (get_var(0, '$ffa') == '1')

            Mines.jpt = {}
            Mines.objects = {}

            local tag_count = read_dword(0x4044000C)
            local tag_address = read_dword(0x40440000)

            for i = 0, tag_count - 1 do
                local tag = tag_address + 0x20 * i
                local tag_name = read_string(read_dword(tag + 0x10))
                local tag_class = read_dword(tag)
                if tag_class == 1785754657 and tag_name == 'weapons\\rocket launcher\\explosion' then
                    local tag_data = read_dword(tag + 0x14)
                    Mines.jpt = {
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

            DisableDeathMessages()

            register_callback(cb['EVENT_JOIN'], 'OnJoin')
            register_callback(cb['EVENT_TICK'], 'OnTick')
            register_callback(cb['EVENT_LEAVE'], 'OnQuit')
            register_callback(cb['EVENT_SPAWN'], 'OnSpawn')
            register_callback(cb["EVENT_DIE"], 'CheckDamage')
            register_callback(cb['EVENT_TEAM_SWITCH'], 'OnSwitch')
            register_callback(cb["EVENT_DAMAGE_APPLICATION"], 'CheckDamage')
            return
        end

        EnableDeathMessages()
        unregister_callback(cb["EVENT_DIE"])
        unregister_callback(cb['EVENT_JOIN'])
        unregister_callback(cb['EVENT_TICK'])
        unregister_callback(cb['EVENT_LEAVE'])
        unregister_callback(cb['EVENT_SPAWN'])
        unregister_callback(cb['EVENT_TEAM_SWITCH'])
        unregister_callback(cb["EVENT_DAMAGE_APPLICATION"])
    end
end

-- Event handler for script unload
function OnScriptUnload()
    EnableDeathMessages()
end

-- Event handler for player join
function OnJoin(playerId)
    players[playerId] = Mines:NewPlayer({
        pid = playerId,
        name = get_var(playerId, '$name'),
        team = get_var(playerId, '$team')
    })
end

-- Event handler for player quit
function OnQuit(playerId)
    for mine, t in pairs(Mines.objects) do
        if t.owner == playerId then
            t.destroy(mine)
        end
    end
end

-- Event handler for player spawn
function OnSpawn(playerId)
    players[playerId].meta = 0
    players[playerId].killer = 0
    players[playerId].mines = config.mines_per_life
end

-- Event handler for team switch
function OnSwitch(playerId)
    players[playerId].team = get_var(playerId, '$team')
end

-- Function to check and handle damage
function CheckDamage(Victim, Killer, MetaID)
    if config.death_messages then
        local killer, victim = tonumber(Killer), tonumber(Victim)
        local v = players[victim]
        if v then
            if MetaID then
                v.meta = MetaID
                return
            end

            local k = players[killer]
            local mine_k = players[v.killer]

            local squashed = (killer == 0)
            local guardians = (killer == nil)
            local suicide = (killer == victim)
            local pvp = (killer > 0 and killer ~= victim)
            local fell = (v.meta_id == falling or v.meta_id == distance)
            local betrayal = (k and not ffa and (v.team == k.team and killer ~= victim))

            execute_command("msg_prefix \"\"")
            if v.meta == Mines.explosion and mine_k then
                say_all(v.name .. " was blown up by " .. mine_k.name .. "'s mine!")
            elseif guardians then
                say_all(v.name .. ' killed by guardians')
            elseif suicide then
                say_all(v.name .. ' committed suicide')
            elseif fell or squashed then
                say_all(v.name .. ' died')
            elseif betrayal then
                say_all(v.name .. ' was betrayed by ' .. k.name)
            elseif pvp then
                say_all(v.name .. ' was killed by ' .. k.name)
            end
            execute_command("msg_prefix \" **" .. config.server_prefix .. "**\"")
        end
    end
end

-- Function to edit rocket properties
function EditRocket(rollback)
    for address, v in pairs(Mines.jpt) do
        if not rollback then
            write_dword(address, v[1])
        else
            write_dword(address, v[2])
        end
    end
end

-- Event handler for game tick
local function handlePlayerMines(v, DyN)
    local flashlight = read_bit(DyN + 0x208, 4)
    if v.flashlight ~= flashlight and flashlight == 1 then
        v:NewMine(GetPos(DyN))
    end
    v.flashlight = flashlight
end

--- Handles the expiration and detonation of mines.
-- This function iterates through the player's deployed mines and checks if they have expired.
-- If a mine has expired, it is destroyed. If a mine is still active, it checks for proximity to other players.
-- If an enemy player is within the explosion radius, the mine is detonated.
-- @param v The player object containing the mine data.
-- @param i The player's ID.
local function handleMineExpiration(v, i)
    for mine, t in pairs(v.objects) do
        if time() >= t.expiration then
            t.destroy(mine)
        elseif t.owner ~= i and player_alive(i) and get_dynamic_player(i) ~= 0 then
            local object = get_object_memory(mine)
            if object ~= 0 then
                if not v.ffa and not config.mines_kill_teammates and v.team == get_var(t.owner, '$team') then
                    goto next
                end
                local pos = GetPos(get_dynamic_player(i))
                local mx, my, mz = read_vector3d(object + 0x5C)
                if Dist(pos.x, pos.y, pos.z, mx, my, mz) <= config.radius then
                    v.killer = t.owner
                    t.destroy(mine, mx, my, mz)
                end
            end
            ::next::
        end
    end
end

function OnTick()
    for i, v in pairs(players) do
        if v then
            local DyN = get_dynamic_player(i)
            if player_alive(i) and DyN ~= 0 then
                handlePlayerMines(v, DyN)
            end
            handleMineExpiration(v, i)
        end
    end
end