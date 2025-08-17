local event = {}

function event:on_pickup(id)

end

register_callback(cb['EVENT_WEAPON_PICKUP'], 'on_pickup')

return event