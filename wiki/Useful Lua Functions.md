## SAPP-Specific Methods

---

### 1. Retrieve Weapon Slot

```lua
--- Retrieves the weapon slot byte from a dynamic player object.
-- @param dyn_player number Dynamic player memory address.
-- @return number Weapon slot (byte).
local function get_weapon_slot(dyn_player)
    return read_byte(dyn_player + 0x2F2)
end
```

---

### 2. Get Tag Reference Address

```lua
--- Retrieves the memory address of a tag given its class and name.
-- @param class string Tag class identifier (e.g., "weap", "vehi").
-- @param name string Tag name (e.g., "weapons\\pistol\\pistol").
-- @return number|nil Memory address of the tag data or nil if not found.
local function get_tag(class, name)
    local tag = lookup_tag(class, name)
    return tag and read_dword(tag + 0xC) or nil
end
```

---

### 3. Get Current Weapon Tag Identifier

```lua
--- Retrieves the tag identifier of the weapon currently held by the player.
-- @param dyn number Dynamic player memory address.
-- @return number|nil Tag identifier of the current weapon, or nil if none.
local function get_current_weapon(dyn)
    local weapon_id = read_dword(dyn + 0x118)
    local weapon_obj = get_object_memory(weapon_id)
    if weapon_obj == nil or weapon_obj == 0 then return nil end
    return read_dword(weapon_obj)
end
```

---

### 4. Check if Player is in Vehicle

```lua
--- Determines if the player is currently inside a vehicle.
-- @param dyn number Dynamic player memory address.
-- @return boolean True if player is in a vehicle, false otherwise.
local function is_in_vehicle(dyn)
    return read_dword(dyn + 0x11C) ~= 0xFFFFFFFF
end
```

---

### 5. Clear Player's RCON Console

```lua
--- Clears the player's RCON console by printing multiple blank lines.
-- @param player_index number Player index (1–16).
local function clear_rcon_console(player_index)
    for _ = 1, 25 do
        rprint(player_index, " ")
    end
end
```

---

### 6. Broadcast Message Excluding One Player

```lua
--- Sends a chat message to all connected players except the specified one.
-- @param message string Message to send.
-- @param exclude_player number Player index to exclude.
local function send_message_exclude(message, exclude_player)
    for i = 1, 16 do
        if player_present(i) and i ~= exclude_player then
            say(i, message)
        end
    end
end
```

---

### 7. Check Player Invisibility State

```lua
--- Determines if the specified player is currently invisible.
-- @param player_index number Player index (1–16).
-- @return boolean True if invisible, false otherwise.
local function is_player_invisible(player_index)
    local dyn = get_dynamic_player(player_index)
    return dyn ~= 0 and read_float(dyn + 0x37C) == 1
end
```

---

### 8. Get Player World Coordinates

```lua
--- Retrieves the player's world coordinates with crouch height adjustment.
-- @param dyn_player number Dynamic player memory address.
-- @return number x Player X coordinate.
-- @return number y Player Y coordinate.
-- @return number z Player Z coordinate.
local function get_player_position(dyn_player)
    local crouch = read_float(dyn_player + 0x50C)
    local vehicle_id = read_dword(dyn_player + 0x11C)
    local vehicle_obj = get_object_memory(vehicle_id)

    local x, y, z
    if vehicle_id == 0xFFFFFFFF then
        x, y, z = read_vector3d(dyn_player + 0x5C)
    elseif vehicle_obj ~= 0 then
        x, y, z = read_vector3d(vehicle_obj + 0x5C)
    end

    local z_offset = (crouch == 0) and 0.65 or 0.35 * crouch
    return x, y, z + z_offset
end
```

### 9. Get Objective (oddball or flag)

```lua
--- Checks if the player currently holds an objective (oddball or flag).
-- @param dyn_player number Dynamic player memory address.
-- @return boolean True if player has an objective, false otherwise.
local function has_objective(dyn_player)
    local base_tag_table = 0x40440000
    local weapon_offset = 0x2F8
    local slot_size = 4
    local tag_entry_size = 0x20
    local tag_data_offset = 0x14
    local bit_check_offset = 0x308
    local bit_index = 3

    for i = 0, 3 do
        local weapon_ptr = read_dword(dyn_player + weapon_offset + slot_size * i)
        if weapon_ptr ~= 0xFFFFFFFF then
            local obj = get_object_memory(weapon_ptr)
            if obj ~= 0 then
                local tag_address = read_word(obj)
                local tag_data_base = read_dword(base_tag_table)
                local tag_data = read_dword(tag_data_base + tag_address * tag_entry_size + tag_data_offset)
                if read_bit(tag_data + bit_check_offset, bit_index) == 1 then
                    return true
                end
            end
        end
    end

    return false
end
```

---

## Pure Lua Utility Functions

---

### 1. String Split

```lua
--- Splits a string into substrings by a delimiter pattern.
-- @param input string Input string to split.
-- @param delimiter string Lua pattern delimiter.
-- @return table Array of substrings.
local function string_split(input, delimiter)
    local result = {}
    for substring in input:gmatch("([^" .. delimiter .. "]+)") do
        result[#result + 1] = substring
    end
    return result
end
```

---

### 2. Table Length (Key Count)

```lua
--- Counts the number of keys in a table.
-- @param tbl table Input table.
-- @return number Number of keys.
local function table_length(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end
```

---

### 3. Shuffle Table Elements (Fisher-Yates)

```lua
--- Randomly shuffles elements of a numerically indexed table.
-- @param tbl table Table to shuffle.
local function shuffle_table(tbl)
    for i = #tbl, 2, -1 do
        local j = math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
end
```

---

### 4. Deep Copy Table

```lua
--- Creates a deep copy of a table, including nested tables and metatables.
-- @param orig table Original table.
-- @return table Deep copy of the original.
local function deep_copy(orig)
    if type(orig) ~= "table" then
        return orig
    end

    local copy = {}
    for key, value in pairs(orig) do
        copy[deep_copy(key)] = deep_copy(value)
    end
    return setmetatable(copy, deep_copy(getmetatable(orig)))
end
```

---

### 5. Non-blocking Timer Using Coroutines

```lua
--- Executes a function after a specified delay using coroutine for non-blocking wait.
-- @param delay number Delay in seconds.
-- @param func function Function to execute after delay.
-- @return thread Coroutine object (requires repeated resumption).
local function timer(delay, func)
    local co = coroutine.create(function()
        local start = os.clock()
        while os.clock() - start < delay do
            coroutine.yield()
        end
        func()
    end)

    -- To run, repeatedly resume co in your main loop:
    -- while coroutine.status(co) ~= "dead" do coroutine.resume(co) end

    return co
end
```

---
