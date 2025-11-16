Checks whether a specific vehicle object is currently occupied by any player.

**Parameters:**

* `vehicleObject` `number` - Vehicle object memory address.
  **Returns:**
* `boolean` - `true` if the vehicle is occupied, `false` otherwise.

**Function Definition:**

```lua
local function isVehicleOccupied(vehicleObject)
    -- Loop through all possible player indices (1-16)
    for i = 1, 16 do
        local dyn = get_dynamic_player(i)

        -- Skip if player is not present, not alive, or has no dynamic object
        if player_present(i) and player_alive(i) and dyn ~= 0 then
            local vehicle_id = read_dword(dyn + 0x11C)

            -- Skip if player is not in a vehicle
            if vehicle_id == 0xFFFFFFFF then goto next_player end

            local vehicle_obj = get_object_memory(vehicle_id)
            -- Return true if this player is in the target vehicle
            if vehicle_obj ~= 0 and vehicle_obj == vehicleObject then
                return true
            end

            ::next_player::
        end
    end

    return false
end
```