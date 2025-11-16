Sometimes, directly writing a vehicle's position with `write_vector3d()` can cause glitchy physics. This method reduces,
but does not fully eliminate teleport glitches.

**Usage Notes:**

1. Update the vehicle's position as usual (e.g., `write_vector3d(object + 0x5C, x, y, z)`).
2. Apply a tiny downward Z-velocity to stabilize physics.
3. Unset the no-collision & ignore-physics bits to restore normal behavior.

**Example Fix:**

```lua
-- Apply new position
-- write_vector3d(object + 0x5C, x, y, z)

-- Apply tiny downward velocity
write_float(object + 0x70, -0.025)

-- Unset no-collision & ignore-physics bits
write_bit(object + 0x10, 0, 0)
write_bit(object + 0x10, 5, 0)
```