Retrieves the tag class and name of an object, with explanation of memory offsets, and demonstrates usage when a player
enters a vehicle.

## Functions:

**`getTag`**
Retrieves the tag class and name of an object.

**Parameters:**

* `object` `number` - Memory address of the object.
  **Returns:**
* `number` - Object class (byte).
* `string` - Tag class (e.g., `"vehi"`).
* `string` - Tag name  (e.g., `"vehicles\\warthog\\mp_warthog"`).

**Function Definition:**

```lua
local function getTag(object)
    -- Read the object tag class (byte at offset 0xB4)
    local tag_class = read_byte(object + 0xB4)
    
    -- Calculate the tag pointer:
    -- 1. read_word(object) gives the object's tag index
    -- 2. Multiply by 32 because each tag entry in the tag table is 32 bytes
    -- 3. Add the base address of the tag table (0x40440038) to get the tag's memory address
    local tag_address = read_word(object) * 32 + 0x40440038
    local tag_name = read_string(read_dword(tag_address))
    
    return tag_class, tag_name
end
```

**Example Usage: OnVehicleEnter**

```lua
function OnVehicleEnter(playerIndex)
    local dyn = get_dynamic_player(playerIndex)
    if dyn == 0 then return end

    local vehicle_id = read_dword(dyn + 0x11C)
    if vehicle_id == 0xFFFFFFFF then return end

    local vehicle_obj = get_object_memory(vehicle_id)
    if vehicle_obj == 0 then return end

    local tag_class, tag_name = getTag(vehicle_obj)
    
    print(tag_class, tag_name) -- Example output: "vehi", "vehicles\\warthog\\mp_warthog"
end
```

### See similar function in [get_tag_referernce_address.md](get_tag_referernce_address.md)