```lua
-- String split function.
-- Tableizer that returns an array of strings separated by the delimiter.

-- @param s (string) String to tokenize
-- @param d (string) String delimiter
-- @return table of strings
local function StrSplit(s, d)
    local args = {}
    for arg in s:gmatch('([^' .. d .. ']+)') do
        args[#args + 1] = arg
    end
    return args
end

-- Example usage:

local content = "This is an example string."
local t = StrSplit(content, '%s')
-- output: [table] {'this', 'is', 'an', 'example', 'string'}
```
---
```lua
-- RCON console-clear function. 
-- Writes 25 blank lines to the rcon buffer.

-- @param p (number) The memory address index of the player to affect.
local function CLS(p)
    for _ = 1, 25 do
        rprint(p, " ")
    end
end
```
---
```lua
-- Send a message to everyone except player (n).

-- @param str (string) The message to send.
-- @param player_to_ignore (number) The memory address index of the player to ignore.
local function SendExclude(str, player_to_ignore)
    for i = 1, 16 do
        if player_present(i) then
            if (i ~= player_to_ignore) then
                -- SAPP's say() function will write to the chat buffer.
                -- Use rprint() if you want it to appear in rcon.
                say(i, str)
            end
        end
    end
end
```
---
```lua
-- Returns player invisibility state.

-- @param player (number) player index.
-- @return invisibility state (number | 1 = true, 0 = false)
local function IsInvisible(player)
    local dyn = get_dynamic_player(player)
    return (dyn ~= 0 and read_float(dyn + 0x37C) == 1) 
end
```
---
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
        x, y, z = read_vector3d(dyn + 0x5c)
    elseif (object ~= 0) then
        x, y, z = read_vector3d(object + 0x5c)
    end
    return x, y, (crouch == 0 and z + 0.65 or z + 0.35 * crouch)
end
```
