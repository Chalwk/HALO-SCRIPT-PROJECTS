--[[
=====================================================================================
SCRIPT NAME:      column_sorter.lua
DESCRIPTION:      Utility for organizing datawith multi-column sorting.

Copyright (c) 2023-2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]

local names = {
    "Elijah", "Samuel", "Nathaniel", "Jericho",
    "Ezekiel", "Isaiah", "Christopher", "Jordan",
    "Benjamin", "Anthony", "Felicity", "Chalwk"
}

local max_rows = 5
local max_columns = 5
local max_results = 50

api_version = '1.12.0.0'

function OnScriptLoad()
    register_callback(cb['EVENT_GAME_START'], 'OnStart')
    OnStart()
end

local function spacing(n)
    local str = ""
    for _ = 1, n do
        str = str .. " "
    end
    return str
end

function OnStart()
    if (get_var(0, '$gt') ~= 'n/a') then

        local row = {}
        local row_count = 0
        local longest_name = 0
        local longest_name_index = 0
        local longest_name_length = 0
        local longest_name_spacing = 0

        for i = 1, #names do
            local name = names[i]
            local name_length = string.len(name)
            if (name_length > longest_name_length) then
                longest_name_length = name_length
                longest_name_index = i
            end
        end

        longest_name = names[longest_name_index]
        longest_name_spacing = string.len(longest_name)

        for i = 1, #names do
            local name = names[i]
            local name_length = string.len(name)
            local s = longest_name_spacing - name_length
            row[#row + 1] = name .. spacing(s)
            if (#row == max_columns) then
                row_count = row_count + 1
                local str = table.concat(row, "    ")
                cprint(str)
                row = {}
            end
        end

        if (#row > 0) then
            row_count = row_count + 1
            local str = table.concat(row, "    ")
            cprint(str)
        end
    end
end

function OnScriptUnload()
    -- N/A
end