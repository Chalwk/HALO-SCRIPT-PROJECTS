Returns a table containing the player's weapons with ammo, clip, and stats.

**Parameters:**

* `dyn_player` `number` - The memory address of the player's dynamic object.
  **Returns:**
* `table` - An array-like table of weapons and their details:
    * `id` - Weapon ID
    * `ammo` - Primary ammo count
    * `clip` - Primary clip count
    * `ammo2` - Secondary ammo count
    * `clip2` - Secondary clip count
    * `heat` - Weapon heat (energy weapons)
    * `frags` - Player's frag count
    * `plasmas` - Player's plasma kills

**Function Definition:**

```lua
local function getInventory(dyn_player)
    local inventory = {}

    -- Loop through the 4 weapon slots (0-3)
    for i = 0, 3 do
        local weapon = read_dword(dyn_player + 0x2F8 + i * 4)
        local object = get_object_memory(weapon)

        if object ~= 0 then
            inventory[i + 1] = {
                id = read_dword(object),
                ammo = read_word(object + 0x2B6),
                clip = read_word(object + 0x2B8),
                ammo2 = read_word(object + 0x2C6),
                clip2 = read_word(object + 0x2C8),
                heat = read_float(object + 0x240),
                frags = read_byte(dyn_player + 0x31E),
                plasmas = read_byte(dyn_player + 0x31F)
            }
        end
    end

    return inventory
end
```