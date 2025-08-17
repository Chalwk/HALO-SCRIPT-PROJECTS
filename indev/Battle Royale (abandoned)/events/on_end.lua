local event = {}

function event:on_end()
    self.game = nil
    self.safe_zone = nil
end

register_callback(cb['EVENT_GAME_END'], 'on_end')

return event