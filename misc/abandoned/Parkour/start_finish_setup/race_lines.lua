local event = {}

-- Spawns a flag at each point of the given line
local function spawn_flag(line)
    local z_off = 0.3
    for _, point in ipairs(line) do
        local x = point.x
        local y = point.y
        local z = point.z + z_off -- Add z_off (0.3) to prevent glitching through the map

        -- Spawn flag at the point
        spawn_object('weap', 'weapons\\flag\\flag', x, y, z)
    end
end

function event:initialize_start_and_finish_lines()

    -- Retrieve the start and finish line coordinates from the map-specific settings
    local start = self[self.map].start
    local finish = self[self.map].finish

    -- Initialize start_line table
    self.start_line = {}
    for i = 1, 2 do
        self.start_line[i] = {
            x = start[(i - 1) * 3 + 1],
            y = start[(i - 1) * 3 + 2],
            z = start[(i - 1) * 3 + 3]
        }
    end

    -- Initialize finish_line table
    self.finish_line = {}
    for i = 1, 2 do
        self.finish_line[i] = {
            x = finish[(i - 1) * 3 + 1],
            y = finish[(i - 1) * 3 + 2],
            z = finish[(i - 1) * 3 + 3]
        }
    end

    spawn_flag(self.start_line)
    spawn_flag(self.finish_line)
end

return event