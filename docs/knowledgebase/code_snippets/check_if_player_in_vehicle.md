Determines if the player is currently inside a vehicle.

**Parameters:**

* `dyn_player` `number` - Dynamic player memory address.
  **Returns:**
* `boolean` - `true` if the player is in a vehicle, `false` otherwise.

**Function Definition:**

```lua
local function inVehicle(dyn_player)
    return read_dword(dyn_player + 0x11C) ~= 0xFFFFFFFF
end
```