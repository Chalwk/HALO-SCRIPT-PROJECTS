local event = {}

function event:on_command(id, command)

    local args = self:stringSplit(command)
    local target_command = args[1]

    local admin = self.players[id]
    command = self.management[target_command]

    local server_management = (command ~= nil) and id == 0
    local player_management = (command ~= nil) and (command.enabled)
    local player_management_disabled = (id > 0 and command ~= nil and not command.enabled)

    if (not target_command) then
        return

        -- Make sure terminal always has access to management commands:
    elseif (server_management) then
        return false, command:run(id, args)

        -- Player executed enabled management command:
    elseif (player_management) then
        admin:commandSpy(target_command)
        return false, command:run(id, args)

        -- Player executed disabled management command:
    elseif (player_management_disabled) then
        admin:send('Command (' .. target_command .. ') is disabled.')
        self:log(admin.name .. ' is attempting to execute (' .. target_command
                .. ') but it is disabled.', self.logging.default)
        return false
    end

    -- All other commands:
    local current_level = admin.level
    local required_level, enabled = self:findCommand(target_command)

    ---
    ---
    --- Check if command exists, is enabled, and if the player has permission:
    ---
    ---

    if (required_level == nil) then
        admin:send('Command (' .. target_command .. ') does not exist.')
        self:log(admin.name .. ' is attempting to execute (' .. target_command .. ') but it does not exist.', self.logging.default)
        return false


        -- player is server, allow disabled command:
    elseif (id == 0 and not enabled) then
        goto next


        -- is player, command is disabled:
    elseif (not enabled) then
        admin:send('Command (' .. target_command .. ') is disabled.')
        self:log(admin.name .. ' is attempting to execute (' .. target_command .. ') but it is disabled.', self.logging.default)
        return false


        -- is player or server but does not have permission:
        -- Host has the option to change server permission which is why we don't explicitly check for id == 0.
    elseif (enabled and current_level < required_level) then
        admin:send('Insufficient Permission.')
        admin:send('You must be level (' .. required_level .. ') or higher.')
        self:log(admin.name .. ' is attempting to execute (' .. target_command
                .. ') but is not a high enough level (current level: '
                .. admin.level .. ') (Required level: '
                .. required_level .. ')', self.logging.default)
        return false
    end

    :: next ::

    self:log('Command: (' .. target_command .. ') was executed by: ' .. admin.name .. ' (' .. id .. ') ' .. '(' .. admin.ip .. ')', self.logging.default)
    admin:commandSpy(target_command)

    return true
end

register_callback(cb['EVENT_COMMAND'], 'on_command')

return event