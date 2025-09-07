Determines if two 3D points are within a specified radius.
Uses squared distance comparison for efficiency.

**Parameters:**

* `x1, y1, z1` `number` - Coordinates of the first point.
* `x2, y2, z2` `number` - Coordinates of the second point.
* `radius` `number` - Radius distance.
  **Returns:**
* `boolean` - `true` if points are within radius, `false` otherwise.

**Function Definition:**

```lua
local function inRange(x1, y1, z1, x2, y2, z2, radius)
    local dx = x1 - x2
    local dy = y1 - y2
    local dz = z1 - z2
    return (dx * dx + dy * dy + dz * dz) <= (radius * radius)
end
```