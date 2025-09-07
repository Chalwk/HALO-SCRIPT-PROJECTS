Clears a player's RCON/Chat buffer by printing multiple blank lines.

**Parameters:**

* `id` `number` - Player index (1-16) whose console should be cleared.

**Function Definition:**

```lua
local function clearConsole(id)
    for _ = 1, 25 do
        rprint(id, " ")
    end
end
```