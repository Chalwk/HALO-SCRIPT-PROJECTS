local victim = {}
local time = os.time

function victim:stunPlayer()

    local id = self.id
    local interval = self.stun.interval
    local speed = self.stun.speed

    if (time() > interval) then
        self.stun = nil
        return
    end

    execute_command('s ' .. id .. ' ' .. speed)
end

return victim