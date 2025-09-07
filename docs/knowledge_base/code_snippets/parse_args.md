Splits a string into substrings based on a delimiter.
Useful for parsing command-line style arguments or CSV-like input.

**Parameters:**

* `input` `string` - The string to split.
* `delimiter` `string` - The character to split on (e.g., `" "`, `","`, `";"`).
  **Returns:**
* `table` - An array-like table containing the split substrings.

**Function Definition:**

```lua
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