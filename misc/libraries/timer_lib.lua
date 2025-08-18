--[[
=====================================================================================
SCRIPT NAME:      timer_lib.lua
DESCRIPTION:      High-precision timing utility for script performance monitoring.

                  Key Features:
                  - Millisecond accuracy
                  - Start/stop/pause/resume
                  - Instance-based isolation
                  - Low-overhead design

                  Basic Usage:
                  local Timer = loadfile("timer_lib.lua")()
                  local t = Timer:new()
                  t:start()
                  local elapsed = t:get()  -- seconds with decimals

Copyright (c) 2018-2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]

local clock = os.clock

local Timer = {}
Timer.__index = Timer

--- Create a new timer instance
function Timer:new()
    return setmetatable({
        start_time  = nil,
        paused_time = 0,
        paused      = false
    }, self)
end

--- Start or restart the timer
function Timer:start()
    self.start_time  = clock()
    self.paused_time = 0
    self.paused      = false
end

--- Stop and reset the timer
function Timer:stop()
    self.start_time  = nil
    self.paused_time = 0
    self.paused      = false
end

--- Pause the timer
function Timer:pause()
    if not self.paused and self.start_time then
        self.paused_time = clock()
        self.paused      = true
    end
end

--- Resume the timer
function Timer:resume()
    if self.paused then
        self.start_time  = self.start_time + (clock() - self.paused_time)
        self.paused_time = 0
        self.paused      = false
    end
end

--- Get elapsed time in seconds
function Timer:get()
    local start = self.start_time
    if start then
        return self.paused and (self.paused_time - start) or (clock() - start)
    end
    return 0
end

return Timer