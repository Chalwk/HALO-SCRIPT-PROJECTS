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
                      {98.80, -156.30, 1.70, 0.5, 72.58, -126.33, 1.18, 0}, -- Red base health pack to rocket launcher mid-map
                      {36.87, -82.33, 1.70, 0.5, 72.58, -126.33, 1.18, 0}    -- Blue base health pack to rocket launcher mid-map
                  }

LAST UPDATED:     August 19, 2025

Copyright (c) 2022-2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]

-----------------
-- CONFIG STARTS
-----------------

local CROUCH_ACTIVATED = false  -- Set to true for crouch-only activation
local COOLDOWN = 0              -- Cooldown in seconds (0 = disabled)

local CFG = {
    ["bloodgulch"] = {
        { 98.80, -156.30, 1.70, 0.5, 72.58, -126.33, 1.18, 0 },
        { 36.87, -82.33,  1.70, 0.5, 72.58, -126.33, 1.18, 0 }
    },

    -- Add more maps here
}

---------------
-- CONFIG ENDS
---------------

api_version = "1.12.0.0"

local map_cfg
local last_teleport = {}

local rprint = rprint
local os_time = os.time
local read_float = read_float
local read_dword = read_dword
local player_alive = player_alive
local read_vector3d = read_vector3d
local write_vector3d = write_vector3d
local player_present = player_present
local get_dynamic_player = get_dynamic_player

function OnScriptLoad()
    register_callback(cb['EVENT_LEAVE'], 'OnQuit')
    register_callback(cb['EVENT_GAME_START'], 'OnStart')
    OnStart()
end

local function precompute_teleports(cfg)
    for _, t in ipairs(cfg) do
        local cx, cy, cz = t[1], t[2], t[3]
        local radius = t[4] or 0.0

        t.cx, t.cy, t.cz = cx, cy, cz
        t.radius = radius
        t.radius_sq = radius * radius

        t.destX, t.destY, t.destZ = t[5], t[6], t[7]
        t.zOff = t[8] or 0

        -- Axis-aligned bounding box for a cheap early reject
        t.minX, t.maxX = cx - radius, cx + radius
        t.minY, t.maxY = cy - radius, cy + radius
        t.minZ, t.maxZ = cz - radius, cz + radius
    end
end

function OnStart()
    if get_var(0, '$gt') == 'n/a' then return end

    local map = get_var(0, '$map')
    local cfg = CFG[map]

    if cfg then

        local tmp = {}
        for i, entry in ipairs(cfg) do tmp[i] = { unpack(entry) } end

        precompute_teleports(tmp)
        map_cfg = tmp

        register_callback(cb['EVENT_TICK'], 'OnTick')
    else
        unregister_callback(cb['EVENT_TICK'])
    end
end

function OnTick()
    for i = 1, 16 do
        if not player_present(i) or not player_alive(i) then goto continue end

        local dyn = get_dynamic_player(i)
        if dyn == 0 then goto continue end

        -- vehicle check
        if read_dword(dyn + 0x11C) == 0xFFFFFFF then goto continue end

        local position = dyn + 0x5C
        local x, y, z = read_vector3d(position)

        if CROUCH_ACTIVATED then
            local crouch_state = read_float(dyn + 0x50C)
            if crouch_state ~= 1 then goto continue end
            z = z + 0.35
        end

        -- cooldown check
        local last = last_teleport[i]
        if last and os_time() < last + COOLDOWN then goto continue end

        -- iterate teleporters:
        for _, t in ipairs(map_cfg) do

            if x >= t.minX and x <= t.maxX
            and y >= t.minY and y <= t.maxY
            and z >= t.minZ and z <= t.maxZ then

                local dx = x - t.cx
                local dy = y - t.cy
                local dz = z - t.cz
                local distSq = dx * dx + dy * dy + dz * dz

                if distSq <= t.radius_sq then
                    local zOff = (CROUCH_ACTIVATED and 0) or t.zOff

                    write_vector3d(position, t.destX, t.destY, t.destZ + zOff)
                    rprint(i, 'WOOSH!')
                    last_teleport[i] = os_time()
                    break
                end
            end
        end

        ::continue::
    end
end

function OnQuit(id)
    last_teleport[id] = nil
end

function OnScriptUnload() end