local event = {}

function event:on_quit(id)
    self.players[id] = nil
end

register_callback(cb['EVENT_LEAVE'], 'on_quit')

return event