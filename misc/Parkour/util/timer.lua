local Timer = {}
local clock = os.clock

function Timer:start()
    self.timer = clock()
end

function Timer:stop()
    self.timer = nil
end

function Timer:getElapsedTime()
    return clock() - self.timer
end

return Timer