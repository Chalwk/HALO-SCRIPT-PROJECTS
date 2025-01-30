# Useful Lua Functions

**1. String Split Function**

A function to split a string into an array of substrings based on a specified delimiter.

```lua
-- String split function.
-- Tableizer that returns an array of strings separated by the delimiter.

-- @param s (string) String to tokenize
-- @param d (string) String delimiter
-- @return table of strings
function string.split(s, d)
    local args = {}
    for arg in s:gmatch('([^' .. d .. ']+)') do
        args[#args + 1] = arg
    end
    return args
end

-- Example usage:
local content = "This is an example string."
local t = string.split(content, '%s')
-- output: [table] {'This', 'is', 'an', 'example', 'string'}
```

**2. RCON Console Clear Function**

Writes 25 blank lines to the RCON buffer, effectively clearing the console.

```lua
-- RCON console-clear function. 
-- Writes 25 blank lines to the RCON buffer.

-- @param p (number) The memory address index of the player to affect.
local function CLS(p)
    for _ = 1, 25 do
        rprint(p, " ")
    end
end
```

**3. Send Message Excluding a Player**

Sends a message to all players except the specified player.

```lua
-- Send a message to everyone except player (n).

-- @param str (string) The message to send.
-- @param player_to_ignore (number) The memory address index of the player to ignore.
local function SendExclude(str, player_to_ignore)
    for i = 1, 16 do
        if player_present(i) then
            if (i ~= player_to_ignore) then
                -- SAPP's say() function will write to the chat buffer.
                -- Use rprint() if you want it to appear in RCON.
                say(i, str)
            end
        end
    end
end
```

**4. Check Player Invisibility State**

Returns whether a player is invisible.

```lua
-- Returns player invisibility state.

-- @param player (number) player index.
-- @return invisibility state (number | 1 = true, 0 = false)
local function IsInvisible(player)
    local dyn = get_dynamic_player(player)
    return (dyn ~= 0 and read_float(dyn + 0x37C) == 1)
end
```

**5. Get Player Map Coordinates**

Retrieves the player's map coordinates.

```lua
-- Returns player map coordinates.

-- @param dyn (number) memory address index.
-- @return 3x 32 bit floating point number
local function GetPos(dyn)
    local x, y, z
    local crouch = read_float(dyn + 0x50C)
    local vehicle = read_dword(dyn + 0x11C)
    local object = get_object_memory(vehicle)
    if (vehicle == 0xFFFFFFFF) then
        x, y, z = read_vector3d(dyn + 0x5C)
    elseif (object ~= 0) then
        x, y, z = read_vector3d(object + 0x5C)
    end
    return x, y, (crouch == 0 and z + 0.65 or z + 0.35 * crouch)
end
```

**6. Table Length Function**

Returns the length of a table. This is useful for any non-numeric keys in the table.

```lua
-- Returns the length of a table.

-- @param tbl (table) The table to check.
-- @return (number) The length of the table.
local function TableLength(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end
```

**7. Shuffle Table Function**

Randomly shuffles the elements in a table.

```lua
-- Shuffle the elements of a table.

-- @param tbl (table) The table to shuffle.
local function Shuffle(tbl)
    for i = #tbl, 2, -1 do
        local j = math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
end
```

**8. Deep Copy Function**

Creates a deep copy of a table, allowing for nested tables to be copied.

```lua
-- Deep copy a table.

-- @param orig (table) The original table to copy.
-- @return (table) A new table that is a deep copy of the original.
local function DeepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[DeepCopy(orig_key)] = DeepCopy(orig_value)
        end
        setmetatable(copy, DeepCopy(getmetatable(orig)))
    else
        -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
```

**9. Timer Function**

A simple timer function to execute code after a specified delay.

```lua
-- Timer function to execute code after a delay.

-- @param delay (number) The time in seconds to wait.
-- @param func (function) The function to execute.
local function Timer(delay, func)
    local start = os.time()
    while os.time() - start < delay do
    end -- Busy wait
    func()
end
```