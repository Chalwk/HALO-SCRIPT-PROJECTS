--=====================================================================================--
-- SCRIPT NAME:      Timer Library
-- DESCRIPTION:      A lightweight, high-performance timer utility for tracking
--                   elapsed time in seconds. Supports start, stop, pause, resume,
--                   and retrieval of elapsed time. Suitable for precise timing in
--                   high-frequency event-driven scripts.
--
-- USAGE:
--   local Timer = loadfile("Timer Library.lua")()
--   local t = Timer:new()
--   t:start()
--   -- ... do stuff ...
--   local elapsed = t:get()
--
-- FUNCTIONS:
--   :new()      -> Create a new timer instance
--   :start()    -> Start or restart the timer
--   :stop()     -> Stop and reset the timer
--   :pause()    -> Pause an active timer
--   :resume()   -> Resume a paused timer
--   :get()      -> Get elapsed time in seconds
--
-- AUTHOR:           Chalwk (Jericho Crosby)
-- COMPATIBILITY:    Halo PC/CE | SAPP 1.12.0.0
--
-- Copyright (c) 2018-2025 Jericho Crosby <jericho.crosby227@gmail.com>
-- LICENSE:          MIT License
--                   https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================--

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