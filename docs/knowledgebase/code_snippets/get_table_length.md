Returns the number of elements in a table.
Works for tables with string keys (dictionary-style tables), since the length operator (`#`) only works reliably on
array-like tables.

**Parameters:**

* `tbl` `table` - The table to count elements in.
  **Returns:**
* `number` - The total number of key-value pairs in the table.

**Function Definition:**

```lua
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

### Examples

#### 1. Array-style table (numeric keys)

```lua
local t1 = {10, 20, 30, 40}
print(tableLength(t1)) -- 4
```

#### 2. Dictionary-style table (string keys)

```lua
local t2 = {name = "Jay", age = 32, city = "Christchurch"}
print(tableLength(t2)) -- 3
```

#### 3. Mixed keys (numeric + string)

```lua
local t3 = {1, 2, 3, foo = "bar", hello = "world"}
print(tableLength(t3)) -- 5
```

#### 4. Empty table

```lua
local t4 = {}
print(tableLength(t4)) -- 0
```

#### 5. Nested tables

```lua
local t5 = {
    name = "Kai",
    hobbies = {"drawing", "music"},
    info = {height = 165, weight = 50}
}
print(tableLength(t5)) -- 3  (top-level keys only)
```

#### 6. Sparse array (holes in numeric indices)

```lua
local t6 = {}
t6[1] = "a"
t6[3] = "b"
print(tableLength(t6)) -- 2 (only counts actual keys present)
```