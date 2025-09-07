Relocates a player off-map by modifying their world coordinates.

See #"Get Player World Coordinates" for the `getPlayerPosition()` helper function.

**Technical Note:** Writing to `0xF8`, `0xFC`, and `0x100` hides the player from other players, but from the playerId's
perspective, they remain on the map in a "spectator-like" state.
**Parameters:**

* `playerId` `number` - Index of the player (1–16).
  **Usage:**
* Call this function every tick to maintain the hidden state.

**Function Definition:**

```lua
local function vanish(playerId)
    -- Get the static player table address
    local static_player = get_player(playerId)
    if not static_player then return end

    -- Get the dynamic player object
    local dyn_player = get_dynamic_player(playerId)
    if dyn_player == 0 then return end

    -- Get current player position
    local x, y, z = getPlayerPosition(dyn_player)
    if not x then return end

    -- Off-map offsets
    local x_off, y_off, z_off = -1000, -1000, -1000

    -- Relocate player off-map by writing new coordinates to player table
    write_float(static_player + 0xF8, x + x_off)
    write_float(static_player + 0xFC, y + y_off)
    write_float(static_player + 0x100, z + z_off)
end
```