local timer = require('timer')

local time = os.time
local date = os.date
local diff = os.difftime

local now_pattern = '%Y-%m-%dT%H:%M:%S'
local pattern = '(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)'

local function ShowDifference()
    local time_stamp = '2022-03-13T10:09:50'
    local cy, cm, cd, chr, cmin, csec = time_stamp:match(pattern)
    local creation_reference = time { year = cy, month = cm, day = cd, hour = chr, min = cmin, sec = csec }

    local time_now = date(now_pattern, time())
    local y, m, d, hr, min, sec = time_now:match(pattern)
    local now_reference = time { year = y, month = m, day = d, hour = hr, min = min, sec = sec }
    local seconds_since_creation = diff(now_reference, creation_reference)

    print(seconds_since_creation)
end

-- Set a repeating timer to call ShowDifference every second
timer.setInterval(1000, ShowDifference)