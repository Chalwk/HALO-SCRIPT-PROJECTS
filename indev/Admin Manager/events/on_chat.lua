local event = {
    overrides = {
        'login',
        'change_password'
    }
}

local function isChatCommand(s)
    return s:sub(1, 1) == '/' or s:sub(1, 1) == '\\'
end

function event:on_chat(id, message)

    local player = self.players[id]
    if not player or player:isMuted() then
        return false
    end

    -- SAPP command overrides:
    local chat_command = isChatCommand(message)
    if (chat_command) then
        local args = self:stringSplit(message)
        for i = 1, #self.overrides do
            local command = self.management[self.overrides[i]]
            if (args[1]:sub(2) == self.overrides[i]) then
                return false, command:run(id, args)
            end
        end

        --- ADMIN CHAT:
    elseif (player.a_chat) then
        player:adminChat(message)
        return false
    end

    return true
end

register_callback(cb['EVENT_CHAT'], 'on_chat')

return event