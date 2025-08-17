local event = {}

local function endGame(self)

    local lives = {}
    for _, v in pairs(self.players) do
        if (v.lives > 0) then
            lives[#lives + 1] = v
        end
    end

    if (#lives == 1) then
        execute_command('sv_map_next')
        local winner = lives[1]
        self:say(string.format('[VICTORY] %s has won the game!', winner.name), true)
        return true
    end

    return false
end

function event:on_death(victim)

    if (not self.game or not self.game.started) then
        return
    end

    victim = tonumber(victim)
    victim = self.players[victim]
    if (not victim) then
        return
    end

    victim.weapon_parts = nil -- weapons parts loot
    victim.stun = nil -- stun grenades
    victim.can_stun = nil -- stun grenades

    if (not victim.can_spectate) then
        return
    end

    victim.lives = victim.lives - 1
    if (victim.lives <= 0) then
        victim.spectator = true
        victim:setSpectatorBits()

        local game_over = endGame(self)
        if (game_over) then
            return
        end

        for _, v in pairs(self.players) do
            v:newMessage(victim.name .. ' has been eliminated', 5)
        end

        return
    end

    local life = (victim.lives == 1 and 'life' or 'lives')
    victim:newMessage('You have ' .. victim.lives .. ' ' .. life .. ' remaining', 5)
end

register_callback(cb['EVENT_DIE'], 'on_death')

return event