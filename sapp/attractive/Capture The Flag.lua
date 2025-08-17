--[[
--=====================================================================================================--
Script Name: Capture the Flag (v1.3), for SAPP (PC & CE)
Description: This script brings CTF-like mechanics to any Slayer (FFA/Team) game type.
             A single flag will spawn somewhere on the map. Return it to any base to score.

Copyright (c) 2021, Jericho Crosby <jericho.crosby227@gmail.com>
* Notice: You can use this document subject to the following conditions:
https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================================--
]]--

-- Configuration settings for the Capture the Flag script
local CTF = {
    respawn_delay = 15, -- Time (in seconds) until a dropped flag will respawn
    trigger_radius = 1.1, -- Radius (in world units) a player must be to capture
    respawn_warning = "The flag was dropped and will respawn in $S second$s", -- Warning message for flag respawn
    message_on_respawn = "The flag has respawned", -- Message broadcast when the flag respawns
    message_on_capture = "$name captured a flag", -- Message broadcast when someone captures the flag
    on_pickup = {
        [1] = "[$team team] $name has the flag!", -- Team slayer message
        [2] = "$name has the flag!", -- FFA message
        [3] = "Return the flag to ANY base for $bonus points.", -- Message to the flag carrier
    },
    points_on_capture = 5, -- Points received for capturing a flag
    score_limit = nil, -- Score limit (set to nil to disable)
    vehicle_capture = false, -- Allow flag capture while in a vehicle
    server_prefix = "**SAPP**", -- Server message prefix
    ["bloodgulch"] = {
        spawn_location = { 65.749, -120.409, 0.118 },
        capture_points = {
            { 95.687797546387, -159.44900512695, -0.10000000149012 },
            { 40.240600585938, -79.123199462891, -0.10000000149012 }
        }
    },
    ["deathisland"] = {
        spawn_location = { -30.282, 31.312, 16.601 },
        capture_points = {
            { -26.576030731201, -6.9761986732483, 9.6631727218628 },
            { 29.843469619751, 15.971487045288, 8.2952880859375 }
        }
    },
    ["icefields"] = {
        spawn_location = { -26.032, 32.365, 9.007 },
        capture_points = {
            { 24.85000038147, -22.110000610352, 2.1110000610352 },
            { -77.860000610352, 86.550003051758, 2.1110000610352 }
        }
    },
    ["infinity"] = {
        spawn_location = { 9.631, -64.030, 7.776 },
        capture_points = {
            { 0.67973816394806, -164.56719970703, 15.039022445679 },
            { -1.8581243753433, 47.779975891113, 11.791272163391 }
        }
    },
    ["sidewinder"] = {
        spawn_location = { 2.051, 55.220, -2.801 },
        capture_points = {
            { -32.038200378418, -42.066699981689, -3.7000000476837 },
            { 30.351499557495, -46.108001708984, -3.7000000476837 }
        }
    },
    ["timberland"] = {
        spawn_location = { 1.250, -1.487, -21.264 },
        capture_points = {
            { 17.322099685669, -52.365001678467, -17.751399993896 },
            { -16.329900741577, 52.360000610352, -17.741399765015 }
        }
    },
    ["dangercanyon"] = {
        spawn_location = { -0.477, 55.331, 0.239 },
        capture_points = {
            { -12.104507446289, -3.4351840019226, -2.2419033050537 },
            { 12.007399559021, -3.4513700008392, -2.2418999671936 }
        }
    },
    ["beavercreek"] = {
        spawn_location = { 14.015, 14.238, -0.911 },
        capture_points = {
            { 29.055599212646, 13.732000350952, -0.10000000149012 },
            { -0.86037802696228, 13.764800071716, -0.0099999997764826 }
        }
    },
    ["boardingaction"] = {
        spawn_location = { 4.374, -12.832, 7.220 },
        capture_points = {
            { 1.723109960556, 0.4781160056591, 0.60000002384186 },
            { 18.204000473022, -0.53684097528458, 0.60000002384186 }
        }
    },
    ["carousel"] = {
        spawn_location = { 0.033, 0.003, -0.856 },
        capture_points = {
            { 5.6063799858093, -13.548299789429, -3.2000000476837 },
            { -5.7499198913574, 13.886699676514, -3.2000000476837 }
        }
    },
    ["chillout"] = {
        spawn_location = { 1.392, 4.700, 3.108 },
        capture_points = {
            { 7.4876899719238, -4.49059009552, 2.5 },
            { -7.5086002349854, 9.750340461731, 0.10000000149012 }
        }
    },
    ["damnation"] = {
        spawn_location = { -2.002, -4.301, 3.399 },
        capture_points = {
            { 9.6933002471924, -13.340399742126, 6.8000001907349 },
            { -12.17884349823, 14.982703208923, -0.20000000298023 }
        }
    },
    ["gephyrophobia"] = {
        spawn_location = { 63.513, -74.088, -1.062 },
        capture_points = {
            { 26.884338378906, -144.71551513672, -16.049139022827 },
            { 26.727857589722, 0.16621616482735, -16.048349380493 }
        }
    },
    ["hangemhigh"] = {
        spawn_location = { 21.020, -4.632, -4.229 },
        capture_points = {
            { 13.047902107239, 9.0331249237061, -3.3619771003723 },
            { 32.655700683594, -16.497299194336, -1.7000000476837 }
        }
    },
    ["longest"] = {
        spawn_location = { -0.84, -14.54, 2.41 },
        capture_points = {
            { -12.791899681091, -21.6422996521, -0.40000000596046 },
            { 11.034700393677, -7.5875601768494, -0.40000000596046 }
        }
    },
    ["prisoner"] = {
        spawn_location = { 0.902, 0.088, 1.392 },
        capture_points = {
            { -9.3684597015381, -4.9481601715088, 5.6999998092651 },
            { 9.3676500320435, 5.1193399429321, 5.6999998092651 }
        }
    },
    ["putput"] = {
        spawn_location = { -2.350, -21.121, 0.902 },
        capture_points = {
            { -18.89049911499, -20.186100006104, 1.1000000238419 },
            { 34.865299224854, -28.194700241089, 0.10000000149012 }
        }
    },
    ["ratrace"] = {
        spawn_location = { 8.662, -11.159, 0.221 },
        capture_points = {
            { -4.2277698516846, -0.85564690828323, -0.40000000596046 },
            { 18.613000869751, -22.652599334717, -3.4000000953674 }
        }
    },
    ["wizard"] = {
        spawn_location = { -5.035, -5.064, -2.750 },
        capture_points = {
            { -9.2459697723389, 9.3335800170898, -2.5999999046326 },
            { 9.1828498840332, -9.1805400848389, -2.5999999046326 }
        }
    }
}

api_version = "1.12.0.0"

-- Function to initialize the script
function OnScriptLoad()
    register_callback(cb["EVENT_GAME_START"], "OnGameStart")
    OnGameStart()
end

-- Function to set up pre-game parameters
function CTF:Init()

    local mode = get_var(0, "$gt")
    if mode == "n/a" then
        return
    end

    self.flag = {}
    self.game_started = false

    local map = self:Proceed(mode)
    if not map then
        unregister_callback(cb["EVENT_GAME_END"])
        unregister_callback(cb["EVENT_TICK"])
        return
    end

    local tag_address = read_dword(0x40440000)
    local tag_count = read_dword(0x4044000C)

    for i = 0, tag_count - 1 do
        local tag = tag_address + 0x20 * i
        if read_dword(tag) == 0x6D617467 then
            local globals_tag = read_dword(tag + 0x14)
            self.flag.id = read_dword(read_dword(globals_tag + 0x164 + 4) + 0xC)

            self.z_off = 0.2
            self.x, self.y, self.z = unpack(self[map].spawn_location)
            self.z = self.z + self.z_off
            self.capture_points = self[map].capture_points
            self:SpawnFlag()
            execute_command("scorelimit " .. (self.score_limit or ""))

            self.game_started = true
            self.announce_pickup = false
            self.team_play = get_var(0, "$ffa") == "0"

            register_callback(cb["EVENT_TICK"], "OnTick")
            register_callback(cb["EVENT_GAME_END"], "OnGameEnd")
            return
        end
    end

    unregister_callback(cb["EVENT_GAME_END"])
    unregister_callback(cb["EVENT_TICK"])
end

-- Function to broadcast a custom server message
function CTF:Broadcast(playerId, message)
    if message ~= "" then
        execute_command('msg_prefix ""')
        if playerId then
            say(playerId, message)
        else
            say_all(message)
        end
        execute_command('msg_prefix "' .. self.server_prefix .. '"')
    end
end

-- Function to teleport the flag back to its starting location
function CTF:SpawnFlag(playerId)
    self:DestroyFlag()
    self.flag.timer = 0
    self.flag.object = spawn_object("", "", self.x, self.y, self.z, 0, self.flag.id)

    local msg = playerId and self.message_on_capture:gsub("$name", get_var(playerId, "$name")) or self.message_on_respawn
    self:Broadcast(nil, msg)
end

-- Function to check if a player is holding the flag
function CTF:GetFlagCarrier()
    for i = 1, 16 do
        if player_present(i) and player_alive(i) and self:HasFlag(i) then
            return i
        end
    end
    self.announce_pickup = true
    return false
end

-- Function to calculate distance using Pythagoras theorem
local function GetDistance(x, y, z, x2, y2, z2, r)
    return math.sqrt((x - x2) ^ 2 + (y - y2) ^ 2 + (z - z2) ^ 2) <= r
end

-- Function to get a player's map coordinates
local function GetXYZ(playerId)
    local dynamic_player = get_dynamic_player(playerId)
    if dynamic_player ~= 0 then
        local VehicleID = read_dword(dynamic_player + 0x11C)
        local VehicleObj = get_object_memory(VehicleID)
        local x, y, z = read_vector3d(dynamic_player + 0x5C)
        if VehicleID == 0xFFFFFFFF then
            return x, y, z, false
        elseif VehicleObj ~= 0 then
            x, y, z = read_vector3d(VehicleObj + 0x5C)
            return x, y, z, true
        end
    end
    return nil
end

-- Function to get the flag object coordinates
function CTF:GetFlagPos()
    local flag = self.flag.object
    if flag then
        local object = get_object_memory(flag)
        if object ~= 0 then
            return read_vector3d(object + 0x5C)
        end
    end
    return nil
end

-- Function to handle pluralization
local function Plural(n)
    return n > 1 and "s" or ""
end

-- Function to handle game tick events
function CTF:GameTick()

    if self.game_started then
        local flag_carrier = self:GetFlagCarrier()
        if not flag_carrier then
            local fx, fy, fz = self:GetFlagPos()
            if fx and not GetDistance(fx, fy, fz, self.x, self.y, self.z - self.z_off, self.trigger_radius) then
                self.flag.timer = self.flag.timer + 1 / 30
                local time = self.respawn_delay - self.flag.timer % 60
                time = tonumber(string.format("%.2f", time))

                if time == self.respawn_delay / 2 then
                    local msg = self.respawn_warning:gsub("$S", time):gsub("$s", Plural(time))
                    self:Broadcast(nil, msg)
                elseif self.flag.timer >= self.respawn_delay then
                    self:SpawnFlag()
                end
            end
            return
        end

        for i = 1, 16 do
            if player_present(i) and player_alive(i) and i == flag_carrier then
                local px, py, pz, in_vehicle = GetXYZ(i)
                if in_vehicle and not self.vehicle_capture then
                    return
                end

                if px then
                    for _, v in pairs(self.capture_points) do
                        if GetDistance(px, py, pz, v[1], v[2], v[3] - self.z_off, self.trigger_radius) then
                            self:SpawnFlag(i)
                            if self.team_play then
                                self:UpdateScore(i, true)
                            else
                                self:UpdateScore(i)
                            end
                            return
                        end
                    end
                end
            end
        end
    end
end

-- Function to update the score
function CTF:UpdateScore(playerId, TeamScore)
    local Amount = self.points_on_capture

    if TeamScore then
        local team = get_var(playerId, "$team") == "red" and 0 or 1
        local team_score = get_var(0, team == 0 and "$redscore" or "$bluescore")
        execute_command("team_score " .. team .. " " .. (team_score - 1 + Amount))
    end

    local score = tonumber(get_var(playerId, "$score"))
    execute_command("score " .. playerId .. " " .. (score - 1 + Amount))
end

-- Function to announce flag pickup
function CTF:AnnouncePickup(playerId)

    self.flag.timer = 0
    if not self.announce_pickup then
        return
    end

    self.announce_pickup = false
    local msg = self.team_play and self.on_pickup[1] or self.on_pickup[2]

    local team = get_var(playerId, "$team")
    local name = get_var(playerId, "$name")
    team = team:gsub("^%l", string.upper)

    msg = msg:gsub("$team", team):gsub("$name", name)
    self:Broadcast(nil, msg)

    msg = self.on_pickup[3]:gsub("$bonus", self.points_on_capture)
    self:Broadcast(playerId, msg)
end

-- Function to check if a player is holding the flag
function CTF:HasFlag(playerId)

    -- Get the dynamic player object
    local dynamicPlayer = get_dynamic_player(playerId)

    -- If the player is not valid, return false
    if dynamicPlayer == 0 then
        return false
    end

    -- Loop through all weapon slots (max of 4 slots)
    for i = 0, 3 do
        local weaponId = read_dword(dynamicPlayer + 0x2F8 + i * 4)

        -- Check if the weapon slot is valid (not empty)
        if weaponId ~= 0xFFFFFFFF then
            local weaponMemory = get_object_memory(weaponId)

            -- Ensure the weapon memory is valid
            if weaponMemory ~= 0 then
                local tagAddress = read_word(weaponMemory)
                local tagData = read_dword(read_dword(0x40440000) + tagAddress * 0x20 + 0x14)

                -- Check if the item is a flag (bit 3 in the tag data)
                if read_bit(tagData + 0x308, 3) == 1 then
                    -- Announce that the player has picked up the flag
                    self:AnnouncePickup(playerId)
                    return true
                end
            end
        end
    end

    -- Return false if no flag was found
    return false
end

-- Function to proceed with the game mode
function CTF:Proceed(mode)
    local map = get_var(0, "$map")
    if mode ~= "slayer" then
        cprint("Capture The Flag - [Only ffa/team slayer is supported]", 10)
        return false
    end
    if not self[map] then
        cprint("Capture The Flag - [" .. map .. " is not configured]", 10)
        return false
    end
    return map
end

-- Function to destroy the flag
function CTF:DestroyFlag()
    destroy_object(self.flag and self.flag.object or 0)
end

-- Event callback for game tick
function OnTick()
    CTF:GameTick()
end

-- Event callback for game start
function OnGameStart()
    CTF:Init()
end

-- Event callback for game end
function OnGameEnd()
    CTF.game_started = false
end

-- Event callback for script unload
function OnScriptUnload()
    CTF:DestroyFlag()
end