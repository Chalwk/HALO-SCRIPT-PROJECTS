local timer = {}
local clock = os.clock

function timer:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function timer:start()
    self.start_time = clock()
    self.paused_time = 0
    self.paused = false
end

function timer:stop()
    self.start_time = nil
    self.paused_time = 0
    self.paused = false
end

function timer:isStarted()
    return (self.start_time ~= nil)
end

function timer:pause()
    if (not self.paused) then
        self.paused_time = clock()
        self.paused = true
    end
end

function timer:resume()
    if (self.paused) then
        self.start_time = self.start_time + (clock() - self.paused_time)
        self.paused_time = 0
        self.paused = false
    end
end

function timer:restart()
    self:start()
end

function timer:get()
    if (self.start_time) then
        if (self.paused) then
            return self.paused_time - self.start_time
        else
            return clock() - self.start_time
        end
    end
    return clock() -- now
end

function timer:setTime(delay)
    self:start()
    self.start_time = self.start_time + delay
end

return timer