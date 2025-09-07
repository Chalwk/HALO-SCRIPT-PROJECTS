**Version 1**

**Message Templates (Local Constants):**

```lua
local HELLO_MESSAGE     = "Hello world!"
local PLAYER_JOINED     = "Player %s has joined the game."
local PLAYER_SCORE      = "%s scored %d points in %d minutes."
```

**Version 1: Format function using `string.format`**

```lua
-- Formats a string with optional arguments, similar to string.format
local function formatMessage(message, ...)
    -- Check if any extra arguments are provided
    if select('#', ...) > 0 then
        -- Format the string with the provided arguments
        return message:format(...)
    end

    -- Return the original string if no arguments are given
    return message
end
```

**Usage Examples:**

```lua
-- Example 1: No formatting arguments, returns original string
print(formatMessage(HELLO_MESSAGE))
-- Output: Hello world!

-- Example 2: Formatting with one argument
print(formatMessage(PLAYER_JOINED, "Chalwk"))
-- Output: Player Chalwk has joined the game.

-- Example 3: Formatting with multiple arguments
print(formatMessage(PLAYER_SCORE, "Chalwk", 150, 12))
-- Output: Chalwk scored 150 points in 12 minutes.
```

---

**Version 2:**

**Define message templates as constants:**

```lua
-- Message templates
local SCORE_MESSAGE   = "$name scored $points points in $minutes minutes."
local JOIN_MESSAGE    = "Player $name has joined the server."
local LEAVE_MESSAGE   = "Player $name has left the server."
```

**Placeholder-based formatting function:**

```lua
-- Replaces placeholders in messages with values from a table
local function formatMessage(message, vars)
    return (message:gsub("%$(%w+)", function(key)
        return vars[key] or "$" .. key  -- Leave unmatched placeholders intact
    end))
end
```

**Usage Examples:**

```lua
-- Player joins
local msg1 = formatMessage(JOIN_MESSAGE, {name = "Chalwk"})
print(msg1)
-- Output: Player Chalwk has joined the server.

-- Player scores points
local msg2 = formatMessage(SCORE_MESSAGE, {name = "Chalwk", points = 150, minutes = 12})
print(msg2)
-- Output: Chalwk scored 150 points in 12 minutes.

-- Player leaves (placeholder not fully provided)
local msg3 = formatMessage(LEAVE_MESSAGE, {})
print(msg3)
-- Output: Player $name has left the server.  (unmatched placeholders remain)
```