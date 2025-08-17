-- Alias System [Stale File] (v1.0)
-- Copyright (c) 2022, Jericho Crosby <jericho.crosby227@gmail.com>

local time = os.time
local Alias = {}

local diff = os.difftime
local floor = math.floor

function Alias:CheckStale()
    for _, record in pairs(self.records) do
        for a, b in pairs(record) do
            local d, m, y = b.last_activity:match('(%d+)-(%d+)-(%d+)')
            local ref = time { day = d, month = m, year = y }
            local days_from = diff(time(), ref) / (24 * 60 * 60)
            local whole_days = floor(days_from)
            if (whole_days >= self.stale_period) then
                record[a] = nil
                cprint('Deleting stale record for ' .. a, 12)
            end
        end
    end
    return true
end

return Alias