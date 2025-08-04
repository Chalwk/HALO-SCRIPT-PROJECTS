--[[
--=====================================================================================================--
Script Name: Custom Teleports, for SAPP (PC & CE)
Description: This script allows you to create custom teleporter-pairs on a per-map basis.

Copyright (c) 2019-2024, Jericho Crosby <jericho.crosby227@gmail.com>
Notice: You can use this script subject to the following conditions:
https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================================--
]]--

api_version = "1.12.0.0"
-----------------
-- CONFIG STARTS
-----------------
-- If true, players must crouch to activate a teleport:
-- Default: false
--
local crouchActivated = false
-- Teleport configuration table:
--
local Teleports = {

    --[[
        format: {oX, oY, oZ, R, dX, dY, dZ, zOff}
        oX =     origin x
        oY =     origin y
        oZ =     origin z
        R =      origin x,y,z trigger radius
        dX =     destination x coord
        dY =     destination y coord
        dZ =     destination z coord
        zOff =   Extra height above ground at dZ
    ]]
    ["bloodgulch"] = {

        -- RED BASE (health pack to rocket launcher)
        { 98.80, -156.30, 1.70, 0.5, 72.58, -126.33, 1.18, 0 },

        -- BLUE BASE (health pack to rocket launcher)
        { 36.87, -82.33, 1.70, 0.5, 72.58, -126.33, 1.18, 0 },

        --
        -- Repeat the structure to add more portal sets.
        --
    }
}
---------------
-- CONFIG ENDS
---------------

local map
local last_teleport = {}
local teleport_cooldown = 0

local function isCrouching(dyn)
    return read_float(dyn + 0x50C) == 1
end

local function inVehicle(dyn)
    return read_dword(dyn + 0x11C) == 0xFFFFFFF
end

function OnScriptLoad()
    register_callback(cb['EVENT_LEAVE'], 'OnQuit')
    register_callback(cb['EVENT_GAME_START'], 'OnStart')
    OnStart()
end

local function PrintTeleportStatus(numTeleports)
    if numTeleports > 0 then
        cprint(string.format('[Custom Teleports] Loaded %d teleports for map %s', numTeleports, map), 12)
    else
        cprint(string.format('[Custom Teleports] No teleports configured for map %s', map), 12)
    end
end

function OnStart()
    if get_var(0,' $gt') ~= 'n/a' then
        map = get_var(0, '$map')
        local config = Teleports[map]

        if config and #config > 0 then
            PrintTeleportStatus(#config)
            register_callback(cb['EVENT_TICK'], 'OnTick')
        else
            unregister_callback(cb['EVENT_TICK'])
            PrintTeleportStatus(0)
        end
    end
end

local function getXYZ(dyn)
    local x, y, z = read_vector3d(dyn + 0x5C)
    if (crouchActivated) then
        z = (read_float(dyn + 0x50C) == 0 and z + 0.65)  or (z + 0.35 * read_float(dyn + 0x50C))
    end

    return x, y, z
end

local function teleportPlayer(player, dyn, config)
    local zOff = isCrouching(dyn) and 0 or config[8]
    write_vector3d(dyn + 0x5C, config[5], config[6], config[7] + zOff)
    rprint(player, 'WOOSH!')
    last_teleport[player] = os.time()
end

local function getDistance(x1, y1, z1, x2, y2, z2)

    -- Return a large distance if x1, y1, or z1 are nil to handle edge cases
    if not x1 or not y1 or not z1 then return math.huge end

    local dx = x1 - x2
    local dy = y1 - y2
    local dz = z1 - z2

    return math.sqrt(math.pow(dx, 2) + math.pow(dy, 2) + math.pow(dz, 2))
end

function OnTick()
    for i = 1, 16 do

        if not player_present(i) or not player_alive(i) then goto continue end

        local dyn = get_dynamic_player(i)
        if inVehicle(dyn) then goto continue end

        local x, y, z = getXYZ(dyn)

        if crouchActivated and not isCrouching(dyn) then
            goto continue
        elseif teleport_cooldown > 0 and os.time() < last_teleport[i] + teleport_cooldown then
            goto continue
        end

        for _, config in ipairs(Teleports[map]) do
            local dist = getDistance(x, y, z, config[1], config[2], config[3])
            if dist <= config[4] then
                teleportPlayer(i, dyn, config)
                break
            end
        end

        :: continue ::
    end
end

function OnQuit(id)
    last_teleport[id] = nil
end

function OnScriptUnload()
    unregister_callback(cb['EVENT_TICK'])
end