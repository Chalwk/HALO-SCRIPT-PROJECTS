local event = {}

function event:on_drop(id)

end

register_callback(cb['EVENT_WEAPON_DROP'], 'on_drop')

return event