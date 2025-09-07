Retrieves the desired aim vector from a dynamic object.

**Parameters:**

* `dyn` `number` - Dynamic object memory address.
  **Returns:**
* `number, number, number` - Desired aim vector components (camera X, camera Y, camera Z).

**Function Definition:**

```lua
local function getAimVector(dyn)
    local aim_x = read_float(dyn + 0x230)
    local aim_y = read_float(dyn + 0x234)
    local aim_z = read_float(dyn + 0x238)

    return aim_x, aim_y, aim_z
end
```