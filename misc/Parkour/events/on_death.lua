local event = {}

function event:on_death(player)

end

register_callback(cb['EVENT_DIE'], 'on_death')

return event