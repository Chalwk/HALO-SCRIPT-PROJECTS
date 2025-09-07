Determines if the specified player is currently invisible.

**Parameters:**

* `id` `number` - Player index (1–16).

**Returns:**

* `boolean` - `true` if invisible, `false` otherwise.

**Function Definition:**

```lua
local function isPlayerInvisible(id)
    local dyn_player = get_dynamic_player(id)
    local invisible = read_float(dyn_player + 0x37C)
    return dyn_player ~= 0 and invisible == 1
end
```