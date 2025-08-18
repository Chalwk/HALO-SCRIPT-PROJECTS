local event = {}

function event:on_quit(player)

end

register_callback(cb['EVENT_LEAVE'], 'on_quit')

return event