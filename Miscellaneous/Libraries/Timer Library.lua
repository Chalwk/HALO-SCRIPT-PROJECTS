--[[
--=====================================================================================================--
Script Name: Timer Library for SAPP (PC & CE)
Description: This library provides a simple timer utility for use in other scripts.

Usage:
1. Require this script in your main script to use the following functions:
   - timer:new()
   - timer:start()
   - timer:stop()
   - timer:pause()
   - timer:resume()
   - timer:get()

Copyright (c) 2022, Jericho Crosby <jericho.crosby227@gmail.com>
Notice: You can use this script subject to the following conditions:
https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================================--
]]--

local Timer = {}
local clock = os.clock

-- Constructor for the Timer object
function Timer:new()
    local instance = setmetatable({}, self)
    self.__index = self
    -- Initialize timer properties
    instance.start_time = nil
    instance.paused_time = 0
    instance.paused = false
    return instance
end

-- Starts the timer
function Timer:start()
    self.start_time = clock()
    self.paused_time = 0
    self.paused = false
end

-- Stops the timer
function Timer:stop()
    self.start_time = nil
    self.paused_time = 0
    self.paused = false
end

-- Pauses the timer
function Timer:pause()
    if not self.paused and self.start_time then
        self.paused_time = clock()
        self.paused = true
    end
end

-- Resumes the timer
function Timer:resume()
    if self.paused then
        self.start_time = self.start_time + (clock() - self.paused_time)
        self.paused_time = 0
        self.paused = false
    end
end

-- Returns the elapsed time in seconds
function Timer:get()
    if self.start_time then
        return self.paused and (self.paused_time - self.start_time) or (clock() - self.start_time)
    end
    return 0  -- Or return nil if not started
end

return Timer