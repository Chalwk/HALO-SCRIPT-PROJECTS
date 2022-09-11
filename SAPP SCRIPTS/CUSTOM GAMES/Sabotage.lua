--[[
--=====================================================================================================--
Script Name: Sabotage, for SAPP (PC & CE)
Description:

> Bomb spawns in the middle of the map.
> Players have to take the bomb to red zone and plant it.
- Bomb timer initiates when the bomb is planted.
- Bomb timer is 30 seconds.

> Enemies can defuse the bomb (crouch to defuse)

Game over if:
- Bomb explodes
- Bomb is defused

If the game timer runs out, teams go into sudden death.
* No respawns


Copyright (c) 2022, Jericho Crosby <jericho.crosby227@gmail.com>
* Notice: You can use this document subject to the following conditions:
https://github.com/Chalwk77/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================================--
]]--

local Sabotage = {

    -- Tag class & name of the object to represent the bomb:
    --
    bomb = { 'weap', 'weapons\\ball\\ball' },


    -- Time (in seconds) to activate the bomb:
    -- Default: 10
    --
    plant_time = 10,


    -- Time (in seconds) :
    -- Default: 60
    --
    explosion_delay = 60,


    -- Time (in seconds) to defuse the bomb:
    -- Default: 15
    --
    defuse_time = 15,


    -- If true, more than one teammate can defuse the bomb at the same time:
    -- Default: false
    --
    team_defuse = false,


    -- A message relay function temporarily removes the server prefix,
    -- and will restore it to this when done:
    --
    prefix = '**ADMIN**',


    --
    -- List of maps that this mod will work on:
    --
    ["bloodgulch"] = {

        -- X,Y,Z location where the bomb will initially spawn:
        -- Format: { x, y, z, trigger radius }
        --
        spawn_location = { 65.749, -120.409, 0.118 },

        -- Location where the bomb must be planted:
        -- Format: { x, y, z, trigger radius }
        --
        base_locations = {
            ['red'] = { 95.687797546387, -159.44900512695, -0.10000000149012, 5 },
            ['blue'] = { 40.240600585938, -79.123199462891, -0.10000000149012, 5 }
        }
    },

    ["deathisland"] = {
        spawn_location = { -30.282, 31.312, 16.601 },
        base_locations = {
            ['red'] = { -26.576030731201, -6.9761986732483, 9.6631727218628, 5 },
            ['blue'] = { 29.843469619751, 15.971487045288, 8.2952880859375, 5 }
        }
    },

    ["icefields"] = {
        spawn_location = { -26.032, 32.365, 9.007 },
        base_locations = {
            ['red'] = { 24.85000038147, -22.110000610352, 2.1110000610352, 5 },
            ['blue'] = { -77.860000610352, 86.550003051758, 2.1110000610352, 5 }
        }
    },

    ["infinity"] = {
        spawn_location = { 9.631, -64.030, 7.776 },
        base_locations = {
            ['red'] = { 0.67973816394806, -164.56719970703, 15.039022445679, 5 },
            ['blue'] = { -1.8581243753433, 47.779975891113, 11.791272163391, 5 }
        }
    },

    ["sidewinder"] = {
        spawn_location = { 2.051, 55.220, -2.801 },
        base_locations = {
            ['red'] = { -32.038200378418, -42.066699981689, -3.7000000476837, 5 },
            ['blue'] = { 30.351499557495, -46.108001708984, -3.7000000476837, 5 }
        }
    },

    ["timberland"] = {
        spawn_location = { 1.250, -1.487, -21.264 },
        base_locations = {
            ['red'] = { 17.322099685669, -52.365001678467, -17.751399993896, 5 },
            ['blue'] = { -16.329900741577, 52.360000610352, -17.741399765015, 5 }
        }
    },

    ["dangercanyon"] = {
        spawn_location = { -0.477, 55.331, 0.239 },
        base_locations = {
            ['red'] = { -12.104507446289, -3.4351840019226, -2.2419033050537, 5 },
            ['blue'] = { 12.007399559021, -3.4513700008392, -2.2418999671936, 5 }
        }
    },

    ["beavercreek"] = {
        spawn_location = { 14.015, 14.238, -0.911 },
        base_locations = {
            ['red'] = { 29.055599212646, 13.732000350952, -0.10000000149012, 5 },
            ['blue'] = { -0.86037802696228, 13.764800071716, -0.0099999997764826, 5 }
        }
    },

    ["boardingaction"] = {
        spawn_location = { 4.374, -12.832, 7.220 },
        base_locations = {
            ['red'] = { 1.723109960556, 0.4781160056591, 0.60000002384186, 5 },
            ['blue'] = { 18.204000473022, -0.53684097528458, 0.60000002384186, 5 }
        }
    },

    ["carousel"] = {
        spawn_location = { 0.033, 0.003, -0.856 },
        base_locations = {
            ['red'] = { 5.6063799858093, -13.548299789429, -3.2000000476837, 5 },
            ['blue'] = { -5.7499198913574, 13.886699676514, -3.2000000476837, 5 }
        }
    },

    ["chillout"] = {
        spawn_location = { 1.392, 4.700, 3.108 },
        base_locations = {
            ['red'] = { 7.4876899719238, -4.49059009552, 2.5, 5 },
            ['blue'] = { -7.5086002349854, 9.750340461731, 0.10000000149012, 5 }
        }
    },

    ["damnation"] = {
        spawn_location = { -2.002, -4.301, 3.399 },
        base_locations = {
            ['red'] = { 9.6933002471924, -13.340399742126, 6.8000001907349, 5 },
            ['blue'] = { -12.17884349823, 14.982703208923, -0.20000000298023, 5 }
        }
    },

    ["gephyrophobia"] = {
        spawn_location = { 63.513, -74.088, -1.062 },
        base_locations = {
            ['red'] = { 26.884338378906, -144.71551513672, -16.049139022827, 5 },
            ['blue'] = { 26.727857589722, 0.16621616482735, -16.048349380493, 5 }
        }
    },

    ["hangemhigh"] = {
        spawn_location = { 21.020, -4.632, -4.229 },
        base_locations = {
            ['red'] = { 13.047902107239, 9.0331249237061, -3.3619771003723, 5 },
            ['blue'] = { 32.655700683594, -16.497299194336, -1.7000000476837, 5 }
        }
    },

    ["longest"] = {
        spawn_location = { -0.84, -14.54, 2.41 },
        base_locations = {
            ['red'] = { -12.791899681091, -21.6422996521, -0.40000000596046, 5 },
            ['blue'] = { 11.034700393677, -7.5875601768494, -0.40000000596046, 5 }
        }
    },

    ["prisoner"] = {
        spawn_location = { 0.902, 0.088, 1.392 },
        base_locations = {
            ['red'] = { -9.3684597015381, -4.9481601715088, 5.6999998092651, 5 },
            ['blue'] = { 9.3676500320435, 5.1193399429321, 5.6999998092651, 5 }
        }
    },

    ["putput"] = {
        spawn_location = { -2.350, -21.121, 0.902 },
        base_locations = {
            ['red'] = { -18.89049911499, -20.186100006104, 1.1000000238419, 5 },
            ['blue'] = { 34.865299224854, -28.194700241089, 0.10000000149012, 5 }
        }
    },

    ["ratrace"] = {
        spawn_location = { 8.662, -11.159, 0.221 },
        base_locations = {
            ['red'] = { -4.2277698516846, -0.85564690828323, -0.40000000596046, 5 },
            ['blue'] = { 18.613000869751, -22.652599334717, -3.4000000953674, 5 }
        }
    },

    ["wizard"] = {
        spawn_location = { -5.035, -5.064, -2.750 },
        base_locations = {
            ['red'] = { -9.2459697723389, 9.3335800170898, -2.5999999046326, 5 },
            ['blue'] = { 9.1828498840332, -9.1805400848389, -2.5999999046326, 5 }
        }
    },
}

local map
local bomb
local bomb_planted
local explosion_timer

local players = { }
local time = os.time

api_version = '1.12.0.0'

function OnScriptLoad()
    register_callback(cb['EVENT_GAME_START'], 'OnStart')
    OnStart()
end

function Sabotage:NewPlayer(o)

    setmetatable(o, { __index = self })
    self.__index = self

    return o
end

local function GetTag(Class, Name)
    local tag = lookup_tag(Class, Name)
    return (tag ~= 0 and read_dword(tag + 0xC)) or nil
end

function Sabotage:SpawnBomb()

    local x = map.spawn_location[1]
    local y = map.spawn_location[2]
    local z = map.spawn_location[3]

    local z_off = 0.3

    local meta_id = bomb.meta_id

    local object = spawn_object('', '', x, y, z + z_off, 0, meta_id)
    local object_mem = get_object_memory(object)
    if (object_mem ~= 0) then
        bomb.object = object
        bomb.object_mem = object_mem
    end
end

function Sabotage:NewTimer(finish)
    return {
        start = time,
        finish = time() + finish
    }
end

local function Say(Ply, Msg)
    local prefix = Sabotage.prefix
    if (not Ply) then
        execute_command('msg_prefix ""')
        say_all(Msg)
        execute_command('msg_prefix "' .. prefix .. '"')
        return
    end
    for _ = 1, 25 do
        rprint(Ply, ' ')
    end
    rprint(Ply, '|c' .. Msg)
end

local function ProgressBar(start, finish, plant_time)

    local bar = ''
    local time_remaining = finish - start()

    for i = 1, time_remaining do
        if (i > (time_remaining / finish) * plant_time) then
            bar = bar .. '='
        end
    end

    return bar
end

function Sabotage:PlantBomb(timer)

    local start = timer.start
    local finish = timer.finish

    if (start() >= finish) then

        -- prevent interaction with bomb:
        execute_command('disable_object ' .. '"' .. self.bomb[2] .. '" 0')

        -- Force player to drop bomb:
        drop_weapon(self.id)

        -- set the team bomb belongs to:
        bomb.team = self.team

        bomb_planted = true

        explosion_timer = self:NewTimer(self.explosion_delay)

        Say(_, 'Bomb has been planted!')
        return
    end

    local bar = ProgressBar(start, finish, self.plant_time)
    Say(self.id, 'Planting the bomb [' .. bar .. ']')

    for i = 1, 16 do
        if (i ~= self.id) then
            Say(i, self.name .. ' is planting the bomb!')
        end
    end
end

function Sabotage:DefuseBomb(timer)

    local start = timer.start()
    local finish = timer.finish

    if (not bomb.defuser) then
        bomb.defuser = self.id
    end

    local defuser = bomb.defuser
    if (not self.team_defuse and self.id ~= defuser) then
        Say(self.id, players[defuser].name .. ' is already defusing the bomb!')
        return
    elseif (self.team_defuse) then
        start = start + 1
    end

    if (start >= finish) then

        Say(_, bomb.team .. ' won!')
        Say(_, 'Bomb has been defused!')
        bomb = nil

        bomb_planted = false
        execute_command('sv_map_next')
        return
    end

    local bar = ProgressBar(start, finish, self.plant_time)
    Say(self.id, 'Defusing the bomb [' .. bar .. ']')
end

function OnStart()

    local game_type = (get_var(0, '$gt'))
    if (game_type ~= 'n/a') then

        local team_slayer = (get_var(0, '$ffa') == '0' and game_type == 'slayer')
        if (team_slayer) then

            bomb_planted = false

            map = get_var(0, '$map')
            map = Sabotage[map]
            if (map) then

                local class, name = Sabotage.bomb[1], Sabotage.bomb[2]
                local tag = GetTag(class, name)
                bomb = { meta_id = tag }

                players = { } -- reset the table (just in case)
                for i = 1, 16 do
                    if player_present(i) then
                        OnJoin(i)
                    end
                end

                register_callback(cb['EVENT_TICK'], 'OnTick')
                register_callback(cb['EVENT_JOIN'], 'OnJoin')
                register_callback(cb['EVENT_LEAVE'], 'OnQuit')
                register_callback(cb['EVENT_DIE'], 'SpawnDeath')
                register_callback(cb['EVENT_SPAWN'], 'SpawnDeath')
                register_callback(cb['EVENT_WEAPON_DROP'], 'OnDrop')
                register_callback(cb['EVENT_TEAM_SWITCH'], 'OnTeamSwitch')

                Sabotage:SpawnBomb()

                return
            end

            unregister_callback(cb['EVENT_DIE'])
            unregister_callback(cb['EVENT_TICK'])
            unregister_callback(cb['EVENT_JOIN'])
            unregister_callback(cb['EVENT_SPAWN'])
            unregister_callback(cb['EVENT_LEAVE'])
            unregister_callback(cb['EVENT_WEAPON_DROP'])
            unregister_callback(cb['EVENT_TEAM_SWITCH'])
            error('Map not configured!')
        else
            error('This script only supports Team Slayer.')
        end
    end
end

local sqrt = math.sqrt
local function GetDist(x1, y1, z1, x2, y2, z2)
    local dist = ((x1 - x2) ^ 2 + (y1 - y2) ^ 2 + (z1 - z2) ^ 2)
    return sqrt(dist)
end

local function GetXYZ(dyn)

    local x, y, z
    local vehicle = read_dword(dyn + 0x11C)
    local object = get_object_memory(vehicle)

    if (vehicle == 0xFFFFFFFF) then
        x, y, z = read_vector3d(dyn + 0x5C)
    elseif (object ~= 0) then
        x, y, z = read_vector3d(object + 0x5C)
    end

    return x, y, z
end

function Sabotage:HasBomb(dyn)
    for i = 0, 3 do
        local weapon = read_dword(dyn + 0x2F8 + 0x4 * i)
        local object = get_object_memory(weapon)
        if (weapon ~= 0xFFFFFFFF and object ~= 0) then
            local tag_address = read_word(object)
            local tag_data = read_dword(read_dword(0x40440000) + tag_address * 0x20 + 0x14)
            if (read_bit(tag_data + 0x308, 3) == 1) then
                self.has_bomb = true
                return true
            end
        end
    end
    return false
end

local function UpdateVectors(object, x, y, z)

    -- update orb x,y,z map coordinates:
    write_float(object + 0x5C, x)
    write_float(object + 0x60, y)
    write_float(object + 0x64, z)

    -- update orb velocities:
    write_float(object + 0x68, 0) -- x vel
    write_float(object + 0x6C, 0) -- y vel
    write_float(object + 0x70, 0) -- z vel

    -- update orb yaw, pitch, roll
    write_float(object + 0x90, 0) -- yaw
    write_float(object + 0x8C, 0) -- pitch
    write_float(object + 0x94, 0) -- roll
end

function Sabotage:OnTick()

    if (bomb_planted) then

        local team = bomb.team
        local object = bomb.object_mem
        local loc = map.base_locations[team]
        local x, y, z = loc[1], loc[2], loc[3]
        UpdateVectors(object, x, y, z)

        local start = explosion_timer.start
        local finish = explosion_timer.finish

        if (start() >= finish) then
            bomb_planted = false
            execute_command('sv_map_next')
            Say(_, 'Bomb has exploded!')
            Say(_, bomb.team .. ' won!')
            return
        end
    end

    for i, v in ipairs(players) do

        local dyn = get_dynamic_player(i)
        if (player_alive(i) and dyn ~= 0) then

            local has_bomb = v:HasBomb(dyn)
            if (has_bomb and not bomb_planted) then

                if (v.assign) then
                    v.assign = false
                    assign_weapon(i, bomb.object)
                end

                local px, py, pz = GetXYZ(dyn)
                local loc = map.base_locations[v.team]

                local bx, by, bz = loc[1], loc[2], loc[3]
                local radius = loc[4]
                local dist = GetDist(px, py, pz, bx, by, bz)
                local crouching = read_bit(dyn + 0x208, 0)

                if (dist <= radius and crouching == 1) then
                    if (not v.timer) then
                        v.timer = v:NewTimer(v.plant_time)
                    else
                        v:PlantBomb(v.timer)
                    end
                else
                    v.timer = nil
                end
            elseif (bomb_planted and v.team ~= bomb.team) then

                local loc = map.base_locations[bomb.team]
                local bx, by, bz = loc[1], loc[2], loc[3]
                local radius = loc[4]
                local px, py, pz = GetXYZ(dyn)
                local crouching = read_bit(dyn + 0x208, 0)
                local dist = GetDist(px, py, pz, bx, by, bz)

                if (dist <= radius and crouching == 1) then
                    if (not v.timer) then
                        v.timer = v:NewTimer(self.defuse_time)
                    else
                        v:DefuseBomb(v.timer)
                    end
                else
                    v.timer = nil
                    bomb.defuser = nil
                end
            end
        end
    end
end

function OnJoin(Ply)
    players[Ply] = Sabotage:NewPlayer({
        id = Ply,
        name = get_var(Ply, '$name'),
        team = get_var(Ply, '$team')
    })
end

function OnQuit(Ply)
    players[Ply] = nil
end

function OnTeamSwitch(Ply)
    players[Ply].team = get_var(Ply, '$team')
end

function OnTick()
    Sabotage:OnTick()
end

function SpawnDeath(Ply)
    local player = players[Ply]

    player.timer = nil
    player.assign = false
    player.has_bomb = false

    if (Ply == bomb.defuser) then
        bomb.defuser = nil
    end
end

function OnDrop(Ply)
    local player = players[Ply]
    if (player.has_bomb) then
        player.assign = true
    end
end

function OnScriptUnload()
    -- N/A
end