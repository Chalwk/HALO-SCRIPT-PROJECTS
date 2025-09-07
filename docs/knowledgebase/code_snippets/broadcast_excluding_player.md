Sends a chat message to all connected players except the specified one.

**Parameters:**

* `message` `string` - Message to send.
* `exclude_player` `number` - Player index to exclude.

**Function Definition:**

```lua
local function sendExclude(message, exclude_player)
    for i = 1, 16 do
        if player_present(i) and i ~= exclude_player then
            say(i, message)
        end
    end
end
```