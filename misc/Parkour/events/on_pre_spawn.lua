local event = {}

function event:on_pre_spawn(player)

end

register_callback(cb['EVENT_PRESPAWN'], 'on_pre_spawn')

return event