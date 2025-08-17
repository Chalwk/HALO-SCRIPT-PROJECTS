local event = {}

function event:on_start()
    if (get_var(0, '$gt') ~= 'n/a') then

        self.login_session_cache = self.login_session_cache or {}
        self.players = {
            [0] = self:newPlayer({
                id = 0,
                level = self.console_default_level,
                name = '_CONSOLE_',
                hash = 'N/A',
                ip = 'localhost'
            })
        }

        -- Just in case the plugin is loaded mid-game:
        for i = 1, 16 do
            if player_present(i) then
                self:on_join(i)
            end
        end
    end
end

register_callback(cb['EVENT_GAME_START'], 'on_start')

return event