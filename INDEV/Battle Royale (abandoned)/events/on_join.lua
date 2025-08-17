local event = {}

function event:newPlayer(o)

    setmetatable(o, self)
    self.__index = self

    o.lives = self.max_lives
    o.messages = { primary = '' }
    o.speed = {
        current = self.default_running_speed
    }

    return o
end

function event:on_join(id)

    self.players[id] = self:newPlayer({
        id = id,
        name = get_var(id, '$name')
    })

    self:phaseCheck(false, id)
end

register_callback(cb['EVENT_JOIN'], 'on_join')

return event