-- Alias System [Results File] (v1.0)
-- Copyright (c) 2022, Jericho Crosby <jericho.crosby227@gmail.com>

local Alias = {}

local floor = math.floor
local concat = table.concat

function Alias:GetPage(page)
    local max = self.max_results
    local start = (max) * page
    local start_page = (start - max + 1)
    local end_page = start
    return start_page, end_page
end

function Alias:GetPageCount(total)
    local max = self.max_results
    local pages = total / (max)
    if (pages ~= floor(pages)) then
        pages = floor(pages) + 1
    end
    return pages
end

local function spacing(n)
    local Str = ''
    for i = 1, n do
        if i == floor(n / 2) then
            Str = Str .. ''
        end
        Str = Str .. ' '
    end
    return ',' .. Str
end

function Alias:FormatTable(table)

    local max = self.max_results
    local spaces = self.spaces

    local longest = 0
    for i = 1, #table do
        if (table[i]:len() > longest) then
            longest = table[i]:len()
        end
    end

    local rows, row, count = {}, 1, 1
    for k, v in pairs(table) do
        if (count % max == 0) or (k == #table) then
            rows[row] = (rows[row] or '') .. v
        else
            rows[row] = (rows[row] or '') .. v .. spacing(longest - v:len() + spaces)
        end
        if (count % max == 0) then
            row = row + 1
        end
        count = count + 1
    end

    return concat(rows)
end

local function GetNames(t)
    local results = {}
    for name, _ in pairs(t) do
        if (name ~= 'last_activity') then
            results[#results + 1] = name
        end
    end
    return results
end

function Alias:ShowResults(Table, Page, ID)

    Table = GetNames(self.records[Table][ID])
    local total_pages = self:GetPageCount(#Table)

    if (Page > 0 and Page <= total_pages) then

        local start_index, end_index = 1, self.max_columns
        local start_page, end_page = self:GetPage(Page)

        local results = { }
        for page_num = start_page, end_page do
            if Table[page_num] then
                results[#results + 1] = Table[page_num]
            end
        end

        while (end_index < #Table + self.max_columns) do

            local t = { }
            for i = start_index, end_index do
                t[i] = results[i]
            end
            self:Send(self:FormatTable(t))

            start_index = end_index + 1
            end_index = end_index + self.max_columns
        end

        self:Send('[Page ' .. Page .. '/' .. total_pages .. '] Showing ' .. #results .. '/' .. #Table .. ' aliases for: ' .. ID)
        if (self.known_pirated_hashes[ID]) then
            self:Send('This hash is pirated.')
        end
    else
        self:Send('Invalid Page ID. Please type a page between 1-' .. total_pages)
    end
end

return Alias