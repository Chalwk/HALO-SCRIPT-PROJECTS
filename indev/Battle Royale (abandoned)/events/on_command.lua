local event = {}

local function stringSplit(s)
    local t = {}
    for param in s:gmatch('([^%s]+)') do
        t[#t + 1] = param:lower()
    end
    return t
end

-- Command listener:
-- Executes the run() method of a command object.
-- @param id (player id)
-- @param command (command string)
-- @return false (to prevent sapp from spamming 'unknown command' error.)
function event:on_command(id, command)

    local args = stringSplit(command)
    local cmd = self.cmds[args[1]]

    if (cmd) then
        if (id == 0) then
            cprint('Cannot execute commands from console.', 12)
            return false
        else
            cmd:run(id, args)
            return false
        end
    end

    return true
end

register_callback(cb['EVENT_COMMAND'], 'on_command')

return event