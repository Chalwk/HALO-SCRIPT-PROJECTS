Retrieves the player's world (x, y, z) coordinates with crouch height adjustment.

**Parameters:**

* `dyn_player` `number` - Dynamic player memory address.
  **Returns:**
* `x, y, z` `number` - Player’s X, Y, Z coordinates, adjusted for crouch.

**Function Definition:**

```lua
local function getPlayerPosition(dyn_player)
    local crouch = read_float(dyn_player + 0x50C)
    local vehicle_id = read_dword(dyn_player + 0x11C)
    local vehicle_obj = get_object_memory(vehicle_id)

    local x, y, z
    if vehicle_id == 0xFFFFFFFF then
        x, y, z = read_vector3d(dyn_player + 0x5C)
    elseif vehicle_obj ~= 0 then
        x, y, z = read_vector3d(vehicle_obj + 0x5C)
    end

    local z_off = (crouch == 0) and 0.65 or 0.35 * crouch
    
    return x, y, z + z_off
end
```