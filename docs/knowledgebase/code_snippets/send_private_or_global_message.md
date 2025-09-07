Sends a formatted message to all players (global) or a single player (private).

**Parameters:**

* `player_id` `number|nil` - Player index (1–16) to send a private message.
    * If `nil`, the message is broadcast to all players.
* `...` `varargs` - Arguments passed to `string.format` for message text.

**Notes:**

* Uses `say_all()` for global messages, but temporarily removes the server prefix (`msg_prefix`) so only your message
  shows.
* Private messages are sent with `rprint()` to the target player.
* `MSG_PREFIX` is expected to be defined elsewhere in your script.

**Example Usage:**

```lua
-- Broadcast to all players
send(nil, "Server restarting in %d seconds!", 30)

-- Send privately to player 3
send(3, "Hello %s, welcome!", get_var(3, "$name"))
```

**Function Definition:**

```lua
local format = string.format

local function send(player_id, ...)
    if not player_id then
        -- No player id given > send to everyone
        execute_command('msg_prefix ""') -- temporarily remove prefix
        say_all(format(...)) -- global broadcast
        execute_command('msg_prefix "' .. MSG_PREFIX .. '"') -- restore prefix
        return
    end
    -- Send private message to a specific player
    rprint(player_id, format(...))
end
```