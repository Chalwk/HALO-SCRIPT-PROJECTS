--[[
--=====================================================================================================--
Script Name: Block or Replace Objects, for SAPP (PC & CE)
Description: Block or replace objects easily.

Copyright (c) 2022, Jericho Crosby
Notice: You can use this script subject to the following conditions:
https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================================--
]]--

local tags = {

    -- Replace Format:
    -- {tag path to replace, replacement tag path}

    -- Block format:
    -- {tag path to replace}

    ["mode_name_here"] = {

        -- EXAMPLE BLOCK:
        { "eqip", "weapons\\frag grenade\\frag grenade" },

        -- EXAMPLE REPLACE:
        { "weap", "weapons\\assault rifle\\assault rifle", "weap", "weapons\\pistol\\pistol" },
        --
        -- repeat the structure to add more replace/block entries for this mode.
        --
    },

    -- repeat the structure to add more mode entries:
    ["mode_name_here"] = {

    }
}

api_version = "1.12.0.0"

local block, replace

function OnScriptLoad()
    register_callback(cb['EVENT_GAME_START'], "OnStart")
    OnStart()
end

local function GetTag(Type, Name)
    local Tag = lookup_tag(Type, Name)
    return (Tag ~= 0 and read_dword(Tag + 0xC)) or nil
end

function OnStart()
    if (get_var(0, "$gt") ~= 'n/a') then

        block, replace = {}, {}

        local mode = get_var(0, "$mode")
        if (tags[mode]) then
            for i = 1, #tags[mode] do
                local t = tags[mode][i]
                if (#t > 2) then
                    replace[GetTag(t[1], t[2])] = GetTag(t[3], t[4])
                else
                    block[GetTag(t[1], t[2])] = true
                end
            end
            register_callback(cb['EVENT_OBJECT_SPAWN'], "BlockReplace")
            return
        end
        unregister_callback(cb['EVENT_OBJECT_SPAWN'])
    end
end

function BlockReplace(_, MapID)
    if (replace[MapID]) then
        return true, replace[MapID]
    elseif (block[MapID]) then
        return false
    end
end

function OnScriptUnload()
    -- N/A
end