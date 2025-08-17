local event = {}

function event:on_start()
    if (get_var(0, '$gt') ~= 'n/a') then
        self:initialize()
    end
end

register_callback(cb['EVENT_GAME_START'], 'on_start')

return event