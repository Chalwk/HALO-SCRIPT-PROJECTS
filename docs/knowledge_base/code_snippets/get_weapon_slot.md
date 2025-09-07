Retrieves the weapon slot byte from the dynamic player object.

**Parameters:**

* `dyn_player` `number` - Dynamic player memory address.
  **Returns:**
* `number` - Weapon slot (byte).

**Function Definition:**

```lua
local function getWeaponSlot(dyn_player)
    return read_byte(dyn_player + 0x2F2)
end
```