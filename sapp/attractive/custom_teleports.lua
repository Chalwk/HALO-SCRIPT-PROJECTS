--[[
=====================================================================================
SCRIPT NAME:      custom_teleports.lua
DESCRIPTION:      Creates configurable instant teleport zones that transport players
                  between defined locations when entering activation areas.

FEATURES:
                  - Map-specific teleport configuration
                  - Adjustable activation radius
                  - Optional crouch activation requirement
                  - Cooldown system to prevent abuse
                  - Vehicle usage protection

USAGE:
                  1. Add teleport entries for each supported map in CFG table
                  2. Format: {srcX, srcY, srcZ, radius, destX, destY, destZ, zOffset}
                  3. Set CROUCH_ACTIVATED true for crouch-only activation

EXAMPLE CONFIG:
                  ["bloodgulch"] = {
                      {98.80, -156.30, 1.70, 0.5, 72.58, -126.33, 1.18, 0}, -- Red to mid
                      {36.87, -82.33, 1.70, 0.5, 72.58, -126.33, 1.18, 0}    -- Blue to mid
                  }

Copyright (c) 2022-2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]

-----------------
-- CONFIG STARTS
-----------------

-- If true, players must crouch to activate a teleport:
local CROUCH_ACTIVATED = false

local CFG = {
    ["bloodgulch"] = {
        -- Teleport 1: Red base health pack to rocket launcher mid-map
        { 98.80, -156.30, 1.70, 0.5, 72.58, -126.33, 1.18, 0 },
        -- Teleport 2: Blue base health pack to rocket launcher mid-map
        { 36.87, -82.33,  1.70, 0.5, 72.58, -126.33, 1.18, 0 }
    },

    -- Add more maps here
}

---------------
-- CONFIG ENDS
---------------

api_version = "1.12.0.0"

local map
local map_cfg
local last_teleport = {}
local teleport_cooldown = 0

local format = string.format
local os_time = os.time
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

local function print_teleport_status(numTeleports)
    if numTeleports > 0 then
        cprint(format('[Custom Teleports] Loaded %d teleports for map %s', numTeleports, map), 12)
    else
        cprint(format('[Custom Teleports] No teleports configured for map %s', map), 12)
    end
end

function OnStart()
    if get_var(0, '$gt') == 'n/a' then return end

    map = get_var(0, '$map')
    local cfg = CFG[map]

    if cfg then
        map_cfg = cfg
        print_teleport_status(#cfg)
        register_callback(cb['EVENT_TICK'], 'OnTick')
    else
        unregister_callback(cb['EVENT_TICK'])
        print_teleport_status(0)
    end
end

function OnTick()

    for i = 1, 16 do
        if not player_present(i) or not player_alive(i) then goto continue end

        local dyn = get_dynamic_player(i)
        if dyn == 0 then goto continue end
        if read_dword(dyn + 0x11C) == 0xFFFFFFF then goto continue end -- In vehicle check

        local position = dyn + 0x5C
        local x, y, z = read_vector3d(position)

        -- Handle crouch height adjustment
        if CROUCH_ACTIVATED then
            local crouch_state = read_float(dyn + 0x50C)
            if crouch_state ~= 1 then goto continue end
            z = z + 0.35
        end

        -- Check teleport cooldown
        local last = last_teleport[i]
        if last and os_time() < last + teleport_cooldown then goto continue end

        for j = 1, #map_cfg do
            local t = map_cfg[j]
            local originX = x - t[1]
            local originY = y - t[2]
            local originZ = z - t[3]
            local radius = t[4]
            local distSq = originX * originX + originY * originY + originZ * originZ

            if distSq <= radius * radius then
                local destinationX, destinationY, destinationZ = t[5], t[6], t[7]
                local zOff = (CROUCH_ACTIVATED and 0) or t[8]
                write_vector3d(position, destinationX, destinationY, destinationZ + zOff)
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