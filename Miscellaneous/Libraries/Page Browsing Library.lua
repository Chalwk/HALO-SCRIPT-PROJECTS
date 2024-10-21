--[[
--=====================================================================================================--
Script Name: Page Browsing Library for SAPP (PC & CE)
Description: This library allows sending timed RCON messages to a player based on paginated results.

Configuration Steps:
1. Place 'Page Browsing Library.lua' in the server's root directory (same location as sapp.dll).
   Do not change the name of the .lua file.

2. At the top of your Lua script, include the library:
   local PageBrowser = loadfile("Page Browsing Library.lua")()

3. To show results on a page, use:
   PageBrowser:ShowResults(playerID, page, maxResults, maxColumns, spaces, dataTable)

   - playerID    [number]: Memory ID of the player receiving the messages.
   - page        [number]: Page number (default is 1 if not defined).
   - maxResults  [number]: Maximum results per page.
   - maxColumns  [number]: Maximum columns to display.
   - spaces      [number]: Spaces between table elements.
   - dataTable   [table]: Target table containing data.

Copyright (c) 2022, Jericho Crosby <jericho.crosby227@gmail.com>
License: You can use this script subject to the conditions specified here:
https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================================--
]]--

local PageBrowser = {}

--- Calculates the start and end index for the given page number.
-- @param page Number: The page number to calculate indices for.
-- @param max_results Number: The maximum number of results per page.
-- @return Number, Number: The start and end indices for the page.
local function GetPage(page, max_results)
    local start = max_results * page
    return start - max_results + 1, start
end

local floor = math.floor

--- Calculates the total number of pages based on total items and max results per page.
-- @param total Number: The total number of items.
-- @param max_results Number: The maximum results per page.
-- @return Number: The total number of pages.
local function GetPageCount(total, max_results)
    return floor((total - 1) / max_results) + 1  -- Avoid division for better precision
end

--- Generates spacing for table formatting.
-- @param n Number: The number of spaces to generate.
-- @return String: A string of spaces.
local function Spacing(n)
    return string.rep(" ", n)  -- Use string.rep for clarity and efficiency
end

local concat = table.concat

--- Formats a table of results into a string for display.
-- @param data_table Table: The table to format.
-- @param max_results Number: The maximum results per page.
-- @param spaces Number: The spaces between table elements.
-- @return String: Formatted string for display.
local function FormatTable(data_table, max_results, spaces)
    local longest = 0
    for _, value in ipairs(data_table) do
        longest = math.max(longest, #value)  -- Find the length of the longest string
    end

    local rows = {}
    for i = 1, #data_table do
        rows[#rows + 1] = data_table[i] .. Spacing(longest - #data_table[i] + spaces)  -- Format current entry
        if i % max_results == 0 or i == #data_table then
            rows[#rows + 1] = "\n"  -- Add a newline at the end of the row
        end
    end

    return concat(rows)  -- Concatenate all rows into a single string
end

--- Sends a message to the player or console.
-- @param player_id Number: The player ID to send the message to.
-- @param message String: The message content to display.
local function Respond(player_id, message)
    if player_id == 0 then
        cprint(message)  -- Print to console
    else
        rprint(player_id, message)  -- Send RCON message to player
    end
end

--- Displays paginated results to a player.
-- @param player_id Number: The player ID to show results to.
-- @param page Number: The current page number to display.
-- @param max_results Number: The maximum results per page.
-- @param max_columns Number: The maximum number of columns to display.
-- @param spaces Number: The number of spaces between table elements.
-- @param data_table Table: The data table to show results from.
function PageBrowser:ShowResults(player_id, page, max_results, max_columns, spaces, data_table)
    -- Validate parameters
    max_results = math.max(1, max_results or 1)
    max_columns = math.max(1, max_columns or 1)
    spaces = math.max(0, spaces or 0)

    local total_items = #data_table
    local total_pages = GetPageCount(total_items, max_results)

    if page > 0 and page <= total_pages then
        local start_page, end_page = GetPage(page, max_results)
        local results = {}

        for i = start_page, end_page do
            if data_table[i] then
                results[#results + 1] = data_table[i]
            end
        end

        local row = FormatTable(results, max_columns, spaces)  -- Format results into rows
        if row and row ~= "" then
            Respond(player_id, row)  -- Send formatted rows to player
        end

        -- Send footer with page info
        Respond(player_id, '[Page ' .. page .. '/' .. total_pages .. '] Showing ' .. #results .. '/' .. total_items .. ' results')
    else
        Respond(player_id, 'Invalid Page ID. Please enter a page between 1 and ' .. total_pages)
    end
end

return PageBrowser