local event = {}

function event:on_end()
    self:updateAliases()
end

register_callback(cb['EVENT_GAME_END'], 'on_end')

return event