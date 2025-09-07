Sets the respawn time for a player - Writes the respawn time directly to the player table memory.

**Parameters:**

* `playerIndex` `number` - Index of the player (1–16).
* `respawnTime` `number` *(optional)* - Time in seconds before the player respawns. Defaults to 3 seconds.

**Function Definition:**

```lua
local function setRespawnTime(playerIndex, respawnTime)
    -- Default respawn time to 3 seconds if not provided
    respawnTime = respawnTime or 3

    -- Get the static memory address of the player's table entry
    local static_player = get_player(playerIndex)

    if static_player then
        -- Write respawn time in ticks (1 tick ≈ 1/33 seconds)
        write_dword(static_player + 0x2C, respawnTime * 33)
    end
end
```