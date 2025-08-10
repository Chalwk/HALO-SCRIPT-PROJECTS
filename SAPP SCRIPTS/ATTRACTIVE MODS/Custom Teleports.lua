--=====================================================================================--
-- SCRIPT NAME:      Custom Teleports
-- DESCRIPTION:      Adds configurable, map-specific teleport points in Halo PC/CE.
--                   Players entering a defined activation radius are instantly moved
--                   to a set destination on the same map.
--
-- AUTHOR:           Chalwk (Jericho Crosby)
-- COMPATIBILITY:    Halo PC/CE | SAPP 1.12.0.0
--
-- Copyright (c) 2025 Jericho Crosby <jericho.crosby227@gmail.com>
-- LICENSE:          MIT License
--                   https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================--

-----------------
-- CONFIG STARTS
-----------------

-- If true, players must crouch to activate a teleport:
local crouchActivated = false

-- Teleport definitions by map name:
-- Format:
--   ["map_name"] = {
--       { srcX, srcY, srcZ, radius, destX, destY, destZ, zOffset },
--       ...
--   }
--
-- srcX, srcY, srcZ     = Teleport activation point coordinates (where player stands)
-- radius               = Activation radius (in world units; spherical)
-- destX, destY, destZ  = Destination point coordinates (where player appears)
-- zOffset              = Extra height offset applied at destination
--
-- Example below for "bloodgulch" with two teleporters:
local Teleports = {
    ["bloodgulch"] = {
        -- Teleport 1: Near red base to a point mid-map
        { 98.80, -156.30, 1.70, 0.5, 72.58, -126.33, 1.18, 0 },
        -- Teleport 2: Near blue base to the same mid-map point
        { 36.87, -82.33,  1.70, 0.5, 72.58, -126.33, 1.18, 0 }
    },

    -- Add more maps here
}

---------------
-- CONFIG ENDS
---------------

api_version = "1.12.0.0"

local map
local last_teleport = {}
local teleport_cooldown = 0

-- Cache global functions
local os_time = os.time
local string_format = string.format
local read_float = read_float
local read_dword = read_dword
local read_vector3d = read_vector3d
local write_vector3d = write_vector3d
local player_present = player_present
local player_alive = player_alive
local get_dynamic_player = get_dynamic_player

function OnScriptLoad()
    register_callback(cb['EVENT_LEAVE'], 'OnQuit')
    register_callback(cb['EVENT_GAME_START'], 'OnStart')
    OnStart()
end

local function PrecomputeSquaredRadii(config)
    for i = 1, #config do
        local r = config[i][4]
        config[i].sq_radius = r * r
    end
end

local function PrintTeleportStatus(numTeleports)
    if numTeleports > 0 then
        cprint(string_format('[Custom Teleports] Loaded %d teleports for map %s', numTeleports, map), 12)
    else
        cprint(string_format('[Custom Teleports] No teleports configured for map %s', map), 12)
    end
end

function OnStart()
    if get_var(0, '$gt') == 'n/a' then return end

    map = get_var(0, '$map')
    local config = Teleports[map]

    if config and #config > 0 then
        PrecomputeSquaredRadii(config)
        PrintTeleportStatus(#config)
        register_callback(cb['EVENT_TICK'], 'OnTick')
    else
        unregister_callback(cb['EVENT_TICK'])
        PrintTeleportStatus(0)
    end
end

function OnTick()
    local config = Teleports[map]
    if not config then return end

    for i = 1, 16 do
        if not player_present(i) or not player_alive(i) then goto continue end

        local dyn = get_dynamic_player(i)
        if read_dword(dyn + 0x11C) == 0xFFFFFFF then goto continue end -- In vehicle check

        local position = dyn + 0x5C
        local x, y, z = read_vector3d(position)

        -- Handle crouch height adjustment
        if crouchActivated then
            local crouch_state = read_float(dyn + 0x50C)
            if crouch_state ~= 1 then goto continue end
            z = z + 0.35
        end

        -- Check teleport cooldown
        local last = last_teleport[i]
        if last and os_time() < last + teleport_cooldown then goto continue end

        for j = 1, #config do
            local t = config[j]
            local dx = x - t[1]
            local dy = y - t[2]
            local dz = z - t[3]
            local distSq = dx * dx + dy * dy + dz * dz

            if distSq <= t.sq_radius then
                local zOff = (crouchActivated and 0) or t[8]
                write_vector3d(position, t[5], t[6], t[7] + zOff)
                rprint(i, 'WOOSH!')
                last_teleport[i] = os_time()
                break
            end
        end

        ::continue::
    end
end

function OnQuit(id)
    last_teleport[id] = nil
end

function OnScriptUnload() end