local timer = {}
local floor = math.floor

local function timeRemaining(delay, time)
    return floor(delay - time:get())
end

local function setGodMode(players)
    for _, v in pairs(players) do
        v.god = true
    end
end

function timer:preGameTimer()

    if (not self.game or self.game.started) then
        return
    end

    local delay = self.start_delay
    if (self.game:get() >= delay) then

        self:setSpawns()
        self.game:stop()
        self.game.started = true
        setGodMode(self.players)

        execute_command('sv_map_reset')
        if (self.lock_server) then
            execute_command('sv_password "' .. self.password .. '"')
        end

        -- Start the shrinking timer:
        self.safe_zone.timer = self:new()
        self.safe_zone.timer:start()

        self:spawnLoot(self.looting.random, 'random')
        self:spawnLoot(self.looting.crates, 'crates')

        for _, v in pairs(self.players) do
            v.messages.primary = ''
        end
    else
        self:say('Game will start in ' .. timeRemaining(delay, self.game) .. ' seconds!', true)
    end
end

function timer:phaseCheck(quit, id)

    local player = (id and self.players[id]) or nil

    local count = tonumber(get_var(0, '$pn'))
    count = (quit and count - 1) or count

    local required_players = self.required_players
    local started = (self.game and self.game.started)


    -- Enough players have joined the game, start the pre-game timer:
    if (count >= required_players and not self.game) then
        self.game = self:new()
        self.game:start()


        -- Player has joined mid-game. Put into spectator mode if enabled:
    elseif (not quit and player and count >= required_players and started and self.new_player_spectate) then
        player.spectator = true
        player:setSpectatorBits()
        player:newMessage('You have joined mid-game, you will be able to play next round', 5)


        -- A player has quit the game before the pre-game timer has elapsed.
        -- Reset the timer:
    elseif (quit and self.game and not self.game.started) then
        self.game = nil


        -- The game has started but there is only one player left, end the game:
    elseif (quit and count == 1 and started) then
        execute_command('sv_map_next')
        print('[BATTLE ROYALE] Game ended - last player wins!')


        -- No players left:
    elseif (quit and count == 0) then
        execute_command('sv_map_next')
        print('[BATTLE ROYALE] Game ended - no players left!')
    end
end

return timer