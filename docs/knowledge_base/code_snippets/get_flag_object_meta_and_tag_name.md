Retrieves the meta ID and tag name of the flag (objective) in the map.

**Returns:**

* `flag_meta_id` (`number`) - Memory reference ID of the flag tag.
* `flag_tag_name` (`string`) - Name of the flag tag.

**Notes:**

* Iterates through all tags in the base tag table.
* Checks for weapon class (`"weap"`) with the specific bit set for objectives.
* Only returns the first tag where the objective type byte equals `0` (flag).
* Returns `nil, nil` if no valid flag is found.

**Function Definition:**

```lua
local flag_meta_id, flag_tag_name
local base_tag_table = 0x40440000
local tag_entry_size = 0x20
local tag_data_offset = 0x14
local bit_check_offset = 0x308
local bit_index = 3

local function getFlagData()
    local tag_array = read_dword(base_tag_table)
    local tag_count = read_dword(base_tag_table + 0xC)

    for i = 0, tag_count - 1 do
        local tag = tag_array + tag_entry_size * i
        local tag_class = read_dword(tag)

        if tag_class == 0x77656170 then -- "weap"
            local tag_data = read_dword(tag + tag_data_offset)
            if read_bit(tag_data + bit_check_offset, bit_index) == 1 then
                if read_byte(tag_data + 2) == 0 then
                    flag_meta_id = read_dword(tag + 0xC)
                    flag_tag_name = read_string(read_dword(tag + 0x10))
                    return flag_meta_id, flag_tag_name
                end
            end
        end
    end

    return nil, nil
end
```