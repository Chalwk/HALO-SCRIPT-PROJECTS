SAPP's built-in `rand()` excludes the maximum value.
Fix: increment the upper bound by `1` to include it.

**Example Usage:**
```lua
local t = {'a', 'b', 'c'}
local i = rand(1, #t + 1)
print(t[i]) -- ensures 1 to #t
```