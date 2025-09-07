Shuffles the elements of an array-like table in place using the Fisher-Yates algorithm.
Works only for sequential (array-style) tables with integer keys.
Each element has an equal chance of ending up in any position.

**Parameters:**

* `tbl` `table` - The array-like table to shuffle.

**Function Definition:**

```lua
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