--[[
=====================================================================================
SCRIPT NAME:      page_browsing_lib.lua
DESCRIPTION:      Lightweight pagination library for formatted console output.

                  Key Features:
                  - Configurable page/column layouts
                  - Server console & player output
                  - Low-memory table processing
                  - Auto-adjusted spacing

                  Usage:
                  local PageBrowser = loadfile("page_browsing_lib.lua")()
                  PageBrowser:ShowResults(player_id, page, max_results,
                                        max_columns, spaces, data_table)

Copyright (c) 2018-2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]

-- Cache frequently used globals
local floor       = math.floor
local max         = math.max
local concat      = table.concat
local rep         = string.rep
local cprint      = cprint
local rprint      = rprint

local PageBrowser = {}

-- Calculate start & end index for a given page
local function GetPage(page, max_results)
    local start = max_results * page
    return start - max_results + 1, start
end

-- Calculate total number of pages
local function GetPageCount(total, max_results)
    return floor((total - 1) / max_results) + 1
end

-- Generate spacing between columns
local function Spacing(n)
    return (n > 0) and rep(" ", n) or ""
end

-- Format results into table-like string
local function FormatTable(data_table, max_columns, spaces)
    local longest = 0
    for i = 1, #data_table do
        local len = #data_table[i]
        if len > longest then
            longest = len
        end
    end

    local spaceCache = Spacing(spaces)
    local rows, colCount = {}, 0

    for i = 1, #data_table do
        rows[#rows + 1] = data_table[i]
        rows[#rows + 1] = spaceCache
        rows[#rows + 1] = Spacing(longest - #data_table[i])
        colCount = colCount + 1

        if colCount == max_columns or i == #data_table then
            rows[#rows + 1] = "\n"
            colCount = 0
        end
    end

    return concat(rows)
end

-- Send output to player or console
local function Respond(player_id, message)
    if player_id == 0 then
        cprint(message)
    else
        rprint(player_id, message)
    end
end

--- Display paginated results
function PageBrowser:ShowResults(player_id, page, max_results, max_columns, spaces, data_table)
    max_results       = max(1, max_results or 1)
    max_columns       = max(1, max_columns or 1)
    spaces            = max(0, spaces or 0)
    page              = page or 1

    local total_items = #data_table
    local total_pages = GetPageCount(total_items, max_results)

    if page > 0 and page <= total_pages then
        local start_idx, end_idx = GetPage(page, max_results)
        local results, resCount = {}, 0

        for i = start_idx, end_idx do
            local val = data_table[i]
            if val then
                resCount = resCount + 1
                results[resCount] = val
            end
        end

        if resCount > 0 then
            Respond(player_id, FormatTable(results, max_columns, spaces))
        end

        Respond(player_id, "[Page " .. page .. "/" .. total_pages ..
            "] Showing " .. resCount .. "/" .. total_items .. " results")
    else
        Respond(player_id, "Invalid Page ID. Please enter a page between 1 and " .. total_pages)
    end
end

return PageBrowser
