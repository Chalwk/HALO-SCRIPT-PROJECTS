Checks if the player's currently held weapon is an objective (oddball, flag, or any).

**Parameters:**

* `dyn_player` `number` - Dynamic player memory address.
* `objective_type` `string` *(optional)* - `"oddball"`, `"flag"`, or `"any"` (default: `"any"`).
  **Returns:**
* `boolean` - `true` if the currently held weapon matches the specified objective type, `false` otherwise.

**Function Definition:**

```lua
local function hasObjective(dyn_player, objective_type)
    local base_tag_table = 0x40440000
    local tag_entry_size = 0x20
    local tag_data_offset = 0x14
    local bit_check_offset = 0x308
    local bit_index = 3

    objective_type = objective_type or "any"
    local weapon_id = read_dword(dyn_player + 0x118)
    local weapon_obj = get_object_memory(weapon_id)
    if weapon_obj == nil or weapon_obj == 0 then return false end

    local tag_address = read_word(weapon_obj)
    local tag_data_base = read_dword(base_tag_table)
    local tag_data = read_dword(tag_data_base + tag_address * tag_entry_size + tag_data_offset)

    if read_bit(tag_data + bit_check_offset, bit_index) ~= 1 then return false end

    local obj_byte = read_byte(tag_data + 2)
    local is_oddball = (obj_byte == 4)
    local is_flag = (obj_byte == 0)

    if objective_type == "oddball" then
        return is_oddball
    elseif objective_type == "flag" then
        return is_flag
    else
        return is_oddball or is_flag
    end
end
```