--[[
--=====================================================================================================--
Script Name: Battle Royal (beta v1.0), for SAPP (PC & CE)
Description: N/A

[!] NOT READY FOR DOWNLOAD

Copyright (c) 2019, Jericho Crosby <jericho.crosby227@gmail.com>
* Notice: You can use this document subject to the following conditions:
https://github.com/Chalwk77/Halo-Scripts-Phasor-V2-/blob/master/LICENSE

* Written by Jericho Crosby (Chalwk)
--=====================================================================================================--
]]--

api_version = "1.12.0.0"
local mod, boundry = { }, { }

-- ==== Battle Royal Configuration [starts] ==== --
mod.players_needed = 0

-- BOUNDRY SETTINGS:
-----------------------------
-- Maximum Boundry Size
boundry.max_size = 100
-- Mininum Boundry Size
boundry.min_size = 5
-- The boundry radius will shrink by this amount every 'boundry.duration' seconds.
boundry.shrink_amount = 30
-- Time between shrink cycles
boundry.duration = 5

boundry.maps = {
    ["timberland"] = { 1.179, -1.114, -21.197, 100},
    ["sidewinder"] = { nil },
    ["ratrace"] = { nil },
    ["bloodgulch"] = { nil },
    ["beavercreek"] = { nil },
    ["boardingaction"] = { nil },
    ["carousel"] = { nil },
    ["dangercanyon"] = { nil },
    ["deathisland"] = { nil },
    ["gephyrophobia"] = { nil },
    ["icefields"] = { nil },
    ["infinity"] = { nil },
    ["hangemhigh"] = { nil },
    ["damnation"] = { nil },
    ["putput"] = { nil },
    ["prisoner"] = { nil },
    ["wizard"] = { nil },
    ["longest"] = { nil },
}
-- ==== Battle Royal Configuration [ends] ==== --

-- Boundry variables
local bX, bY, bZ, bR
local start_trigger = true

-- debugging
local debug_object, delete_object = { }

function OnScriptLoad()
    register_callback(cb["EVENT_JOIN"], "OnPlayerConnect")
end

local player_count = function()
    return tonumber(get_var(0, "$pn"))
end

local boundry_coords = function()
    local mapname = get_var(0, "$map")
    local coords = boundry.maps[mapname]
    if (coords ~= nil) then
        return coords
    end
end

function OnPlayerConnect(PlayerIndex)
    if (start_trigger) and (player_count() >= mod.players_needed) then
        start_trigger = false
        local mapname = get_var(0, "$map")
        local coords = boundry.maps[mapname]
        if (coords ~= nil) then        
            bX, bY, bZ, bR = coords[1], coords[2], coords[3], coords[4]
            
            -- For Debugging (temp)
            delete_object = true
            --
            
            -- Create new timer array:
            boundry.timer = { }
            boundry.timer = 0
            boundry.init_timer = true
            
            -- Register a hook into SAPP's tick event.
            register_callback(cb["EVENT_TICK"], "OnTick")
        end
    end
end

function boundry:shrink()
    if (bR ~= nil) then 
        bR = (bR - boundry.shrink_amount)
        if (bR < boundry.min_size) then
            bR = boundry.min_size
        end
    end
end

local function inSphere(px, py, pz, x, y, z, r)
    local coords = ( (px - x) ^ 2 + (py - y) ^ 2 + (pz - z) ^ 2)
    if (coords < r) then
        return true
    elseif (coords >= r + 1) then
        return false
    end
end

-- DEBUGGING:
function delete()
    for i = 1,#debug_object do
        local object = get_object_memory(debug_object[i])
        if (object ~= nil and object ~= 0) then
            destroy_object(debug_object[i])
            delete_object = true
        end
    end
end

function OnTick()
    for i = 1,16 do
        if player_present(i) then
            local player_object = get_dynamic_player(i)
            
            if (player_object ~= 0) then
                cls(i, 25)
                local px,py,pz = read_vector3d(player_object + 0x5c) 
                if inSphere(px,py,pz, bX, bY, bZ, bR) then
                    -- 
                else
                    -- Camo serves as a visual indication to the player
                    -- that they are outside the boundry:
                    execute_command("camo " .. i .. " 1")
                end
            end
            
            if (boundry.timer ~= nil) and (boundry.init_timer) then
                boundry.timer = boundry.timer + 0.030
                
                if (delete_object) then
                    delete_object = false
                    local debug_obj = spawn_object("eqip", "powerups\\active camouflage", bX, bY, bZ + 0.5)
                    debug_object[#debug_object + 1] = debug_obj
                    timer(1500, "delete")    
                end                
                
                if ( boundry.timer >= (boundry.duration) ) then
                    if (bR > boundry.min_size and bR <= boundry.max_size) then
                        boundry.timer = 0
                        boundry:shrink()
                        say(i, "THE PLAYABLE BOUNDRY HAS SHRUNKEN " .. boundry.shrink_amount .. " WORLD UNITS", 4+8)
                    elseif (bR <= boundry.min_size) then
                        boundry.init_timer = false
                        boundry.timer = 0
                        
                        -- TO DO:
                        -- ...
                        
                        -- DEBUGGING:
                        say(i, "THE PLAYABLE BOUNDRY IS NOW AT A MINIMUM SIZE OF " .. boundry.min_size .. " (actual: " .. bR .. ")", 4+8)
                    end
                end
            end
        end
    end
end

function cls(PlayerIndex, count)
    count = count or 25
    if (PlayerIndex) then
        for _ = 1, count do
            rprint(PlayerIndex, " ")
        end
    end
end
