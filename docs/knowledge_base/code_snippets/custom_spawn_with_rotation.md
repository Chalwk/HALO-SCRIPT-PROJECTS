Writes position and rotation data to the dynamic object in memory.

**Parameters:**

* `dyn` `number` - Dynamic player memory address.
* `px` `number` - X coordinate for spawn.
* `py` `number` - Y coordinate for spawn.
* `pz` `number` - Z coordinate for spawn.
* `pR` `number` - Rotation in radians.
* `z_off` `number` *(optional)* - Vertical offset (default `0.3`).

**Function Definition:**

```lua
local function spawnObject(dyn, px, py, pz, pR, z_off)
    z_off = z_off or 0.3  -- default offset if not provided

    local x = px
    local y = py
    local z = pz + z_off
    local r = pR

    -- Write the 3D position to the dynamic object memory
    write_vector3d(dyn + 0x5C, x, y, z)

    -- Write the forward vector (direction) for rotation
    -- Convert rotation in radians to a unit vector on the XY plane
    write_vector3d(dyn + 0x74, math.cos(r), math.sin(r), 0)
end
```