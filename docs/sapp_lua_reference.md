# Useful Lua Functions & SAPP Tips

*(SAPP scripting reference with code snippets)*

---

## Introduction

This guide is a collection of **SAPP-specific tips, technical notes, and Lua utility functions**.
It's designed as both a **tutorial** for learning and a **reference** for quick copy/paste coding.

> **Reminder:**
> `1 world unit = 10 feet = 3.048 meters`

---

## SAPP Technical Notes

### Map Vote & Cycle

**Important:** Do **not** use `mapvote_add` in `init.txt`.

- Using `mapvote_add` in `init.txt` causes SAPP to append the entry to `mapvotes.txt` every server boot, creating duplicates.
- Instead, add map vote entries **directly** to `mapvotes.txt`.

**Entry Format:** `map:variant:name:min:max`

* Example:

  ```
  longest:ctf:Longest (CTF):0:16
  ```

### Startup Hang

* Add `max_idle 1` to `init.txt` to avoid the 60-second hang on server boot.

### Player Count (`$pn`)

* During `EVENT_LEAVE`, `get_var(0, "$pn")` does not update immediately.
* Subtract 1 manually:

```lua
function OnLeave()
    local n = tonumber(get_var(0, "$pn")) - 1
    print('Total Players: ' .. n)
end
```

### Random Numbers

* SAPP's built-in `rand()` excludes the max value.
* Fix: increment the upper bound by 1.

```lua
local t = {'a', 'b', 'c'}
local i = rand(1, #t + 1)
print(t[i]) -- ensures 1 to #t
```

### Object Physics Glitch

```lua
--- Teleport a vehicle safely in memory
-- Directly writing a vehicle's position with write_vector3d() can cause glitchy physics.
-- This method reduces, but does not fully eliminate, teleport glitches.

-- Step 1: Update the vehicle's position as usual (example: write_vector3d(object + 0x5C, x, y, z))

-- Step 2: Apply a tiny downward z-velocity to stabilize physics
write_float(object + 0x70, -0.025)

--Unset the no-collision & ignore-physics bits:
write_bit(object + 0x10, 0, 0)
write_bit(object + 0x10, 5, 0)
```

### Assigning More Than 2 Weapons

* Delay tertiary and quaternary assignments by ≥250ms to prevent them from dropping.

---

## SAPP Utility Functions

### 1. Retrieve Weapon Slot

```lua
--- Retrieves the weapon slot byte from a dynamic player object.
-- @param dyn_player number Dynamic player memory address.
-- @return number Weapon slot (byte).
local function getWeaponSlot(dyn_player)
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
local function getTag(class, name)
    local tag = lookup_tag(class, name)
    return tag and read_dword(tag + 0xC) or nil
end
```

---

### 3. Get Current Weapon Tag Identifier

```lua
--- Retrieves the tag identifier of the weapon currently held by the player.
-- @param dyn_player number Dynamic player memory address.
-- @return number|nil Tag identifier of the current weapon, or nil if none.
local function getWeaponMetaID(dyn_player)
    local weapon_id = read_dword(dyn_player + 0x118)
    local weapon_obj = get_object_memory(weapon_id)
    if weapon_obj == nil or weapon_obj == 0 then return nil end
    return read_dword(weapon_obj)
end
```

---

### 4. Check if Player is in Vehicle

```lua
--- Determines if the player is currently inside a vehicle.
-- @param dyn_player number Dynamic player memory address.
-- @return boolean True if player is in a vehicle, false otherwise.
local function inVehicle(dyn_player)
    return read_dword(dyn_player + 0x11C) ~= 0xFFFFFFFF
end
```

---

### 5. Clear Player's RCON Console

```lua
--- Clears the player's RCON console by printing multiple blank lines.
-- @param id number Player index (1-16).
local function clearConsole(id)
    for _ = 1, 25 do
        rprint(id, " ")
    end
end
```

---

### 6. Broadcast Message Excluding One Player

```lua
--- Sends a chat message to all connected players except the specified one.
-- @param message string Message to send.
-- @param exclude_player number Player index to exclude.
local function sendExclude(message, exclude_player)
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
-- @param id number Player index (1-16).
-- @return boolean True if invisible, false otherwise.
local function isPlayerInvisible(id)
    local dyn_player = get_dynamic_player(id)
    local invisible = read_float(dyn_player + 0x37C)
    return dyn_player ~= 0 and invisible == 1
end
```

---

### 8. Get Player World Coordinates

```lua
--- Retrieves the player's world coordinates with crouch height adjustment.
-- @param dyn_player number Dynamic player memory address.
-- @return number x, y, z | Player X, Y, Z coordinate.
local function getPlayerPosition(dyn_player)
    local crouch = read_float(dyn_player + 0x50C)
    local vehicle_id = read_dword(dyn_player + 0x11C)
    local vehicle_obj = get_object_memory(vehicle_id)

    local x, y, z
    if vehicle_id == 0xFFFFFFFF then
        x, y, z = read_vector3d(dyn_player + 0x5C)
    elseif vehicle_obj ~= 0 then
        x, y, z = read_vector3d(vehicle_obj + 0x5C)
    end

    local z_off = (crouch == 0) and 0.65 or 0.35 * crouch
    
    return x, y, z + z_off
end
```

---

### 9. Get Objective (Flag / Oddball)

```lua
--- Checks if the player's currently held weapon is an objective (oddball, flag, or any).
-- @param dyn_player number Dynamic player memory address.
-- @param objective_type string Optional. "oddball", "flag", or "any" (default: "any").
-- @return boolean True if the currently held weapon matches the specified objective type, false otherwise.
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

---

### 10. Get Player Inventory

```lua
--- Returns a table containing the player's weapons with ammo, clip, and stats.
-- Works for SAPP/Halo: CE dynamic player objects.
-- @param dyn_player number: The memory address of the player's dynamic object
-- @return table: An array-like table of weapons and their details
local function getInventory(dyn_player)
    local inventory = {}

    -- Loop through the 4 weapon slots (0-3)
    for i = 0, 3 do
        -- Read the weapon ID from the player's weapon slot
        local weapon = read_dword(dyn_player + 0x2F8 + i * 4)
        -- Get the memory address of the weapon object
        local object = get_object_memory(weapon)

        if object ~= 0 then
            -- If the weapon exists, read its stats into the inventory table
            inventory[i + 1] = {
                id = read_dword(object),                 -- Weapon ID
                ammo = read_word(object + 0x2B6),        -- Primary ammo
                clip = read_word(object + 0x2B8),        -- Primary clip
                ammo2 = read_word(object + 0x2C6),       -- Secondary ammo
                clip2 = read_word(object + 0x2C8),       -- Secondary clip
                heat = read_float(object + 0x240),       -- Weapon heat (for energy weapons like plasma rifle/cannon)
                frags = read_byte(dyn_player + 0x31E),   -- Player's frag count
                plasmas = read_byte(dyn_player + 0x31F)  -- Player's plasma kills
            }
        end
    end

    return inventory
end
```

---

### 11. Get Flag Object Meta & Tag Name

```lua
--[[
    getFlagData() → flag_meta_id, flag_tag_name

    Retrieves the meta ID and tag name of the flag (objective) in the map.

    Returns:
        flag_meta_id   (number)  → Memory reference ID of the flag tag.
        flag_tag_name  (string)  → Name of the flag tag.

    Notes:
        - Iterates through all tags in the base tag table.
        - Checks for weapon class ("weap") with the specific bit set for objectives.
        - Only returns the first tag where the objective type byte equals 0 (flag).
        - Returns nil, nil if no valid flag is found.

    Example Usage:
        local meta_id, tag_name = getFlagData()
        if meta_id then
            print("Flag Meta ID:", meta_id)
            print("Flag Name:", tag_name)
        else
            print("No flag found in this map.")
        end
]]
local flag_meta_id, flag_tag_name
local function getFlagData()
    local base_tag_table = 0x40440000
    local tag_entry_size = 0x20
    local tag_data_offset = 0x14
    local bit_check_offset = 0x308
    local bit_index = 3

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

---

### 12. Check if Player is In Range

```lua
--- Determines if two 3D points are within a specified radius.
-- Uses squared distance comparison for efficiency.
-- @param x1, y1, z1 number Coordinates of the first point.
-- @param x2, y2, z2 number Coordinates of the second point.
-- @param radius number Radius distance.
-- @return boolean True if points are within radius, false otherwise.
local function inRange(x1, y1, z1, x2, y2, z2, radius)
    local dx = x1 - x2
    local dy = y1 - y2
    local dz = z1 - z2
    return (dx * dx + dy * dy + dz * dz) <= (radius * radius)
end
```

---

### 13. Send Global/Private Message

```lua
--- Sends a formatted message to all players (global) or a single player (private).
--
-- @param player_id number|nil Player index (1–16) to send a private message.
--        If nil, the message is broadcast to all players.
-- @param ... varargs Arguments passed to string.format for message text.
--
-- Notes:
--   - Uses 'say_all()' for global messages, but temporarily removes the
--     server prefix (msg_prefix) so only your message shows.
--   - Private messages are sent with 'rprint()' to the target player.
--   - MSG_PREFIX is expected to be defined elsewhere in your script.
--
-- Example:
--   send(nil, "Server restarting in %d seconds!", 30)   --> Broadcasts to all
--   send(3, "Hello %s, welcome!", get_var(3, "$name"))  --> Sends privately to player 3
local format = string.format
local function send(player_id, ...)
    if not player_id then
        -- No player id given --> send to everyone
        execute_command('msg_prefix ""') -- temporarily remove prefix
        say_all(format(...))             -- global broadcast
        execute_command('msg_prefix "' .. MSG_PREFIX .. '"') -- restore prefix
        return
    end
    -- Send private message to a specific player
    rprint(player_id, format(...))
end
```

---

### 14. Custom Spawn Systems

```lua
--- Writes position and rotation data to a dynamic object in memory.
-- @param dyn number: Dynamic player memory address.
-- @param px number: X coordinate for spawn
-- @param py number: Y coordinate for spawn
-- @param pz number: Z coordinate for spawn
-- @param pR number: Rotation in radians
-- @param z_off number: Optional vertical offset (default 0.3)
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

---

## Pure Lua Utility Functions

### 1. Parse Args

```lua
--- Splits a string into substrings based on a delimiter.
-- Useful for parsing command-line style arguments or CSV-like input.
-- @param input string: The string to split
-- @param delimiter string: The character to split on (e.g., " ", ",", ";")
-- @return table: An array-like table containing the split substrings
local function parseArgs(input, delimiter)
    local result = {}
    -- Use Lua's pattern matching to find sequences between delimiters
    for substring in input:gmatch("([^" .. delimiter .. "]+)") do
        -- Append each substring to the result table
        result[#result + 1] = substring
    end
    return result
end
```

---

### 2. Table Length

```lua
--- Returns the number of elements in a table.
-- This works for tables with string keys (i.e., dictionary-style tables),
-- since the length operator (#) only works reliably on array-like tables.
-- @param tbl table: The table to count elements in
-- @return number: The total number of key-value pairs in the table
local function tableLength(tbl)
    local count = 0
    -- Iterate through all key-value pairs in the table
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end
```

---

### 3. Shuffle Table (Fisher-Yates)

```lua
--- Shuffles the elements of an array-like table in place using the Fisher-Yates algorithm.
-- This function only works for sequential (array-style) tables with integer keys.
-- Each element has an equal chance of ending up in any position.
-- @param tbl table: The array-like table to shuffle
local function shuffleTable(tbl)
    -- Start from the end of the table and work backwards
    for i = #tbl, 2, -1 do
        -- Pick a random index from 1 to i
        local j = math.random(i)
        -- Swap the elements at positions i and j
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
end
```

---

### 4. Deep Copy Table

**Note:** This version will recurse into everything, including keys, values, and metatables. That's powerful, but it can
cause infinite loops if the table is self-referential.

```lua
--- Creates a deep copy of a table, including nested tables and metatables.
-- Unlike a shallow copy, this recursively duplicates all table keys/values.
-- Non-table values (strings, numbers, booleans, etc.) are returned as-is.
-- @param orig any: The value or table to copy
-- @return any: A fully independent copy of the original
local function deepCopy(orig)
    -- If it's not a table, return the value directly
    if type(orig) ~= "table" then
        return orig
    end

    -- Create a new table to hold the copy
    local copy = {}

    -- Recursively copy each key-value pair
    for key, value in pairs(orig) do
        copy[deep_copy(key)] = deep_copy(value)
    end

    -- Preserve the original table's metatable (also copied recursively)
    return setmetatable(copy, deep_copy(getmetatable(orig)))
end
```

---

### 5. Non-blocking Timer (Coroutine)

```lua
--- Creates a coroutine-based timer that runs a function after a delay.
-- The coroutine must be resumed regularly (e.g., inside a game loop or scheduler)
-- until the delay has passed, at which point the given function is executed.
-- @param delay number: The delay in seconds before executing the function
-- @param func function: The function to call after the delay
-- @return thread: A coroutine that manages the timer
local function timer(delay, func)
    -- Create a coroutine to track elapsed time
    local co = coroutine.create(function()
        local start = os.clock()
        -- Keep yielding until the delay has passed
        while os.clock() - start < delay do
            coroutine.yield()
        end
        -- Execute the callback function once the time is up
        func()
    end)

    return co
end
```

---