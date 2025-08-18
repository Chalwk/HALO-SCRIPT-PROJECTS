local event = {}

local function disable_objects()
    execute_command('disable_object "weapons\\flag\\flag" 0') -- Disable flag
    execute_command('disable_object "weapons\\ball\\ball" 0') -- Disable oddball
end

function event:on_start()

    self.map = get_var(0, '$map')

    if self[self.map] == nil or get_var(0, '$gt') == 'n/a' then
        return
    end

    self.players = {}
    self.oddballs = {}

    disable_objects()

    self:initialize_start_and_finish_lines()
    self:createCheckpoints()
end

register_callback(cb['EVENT_GAME_START'], 'on_start')

return event
