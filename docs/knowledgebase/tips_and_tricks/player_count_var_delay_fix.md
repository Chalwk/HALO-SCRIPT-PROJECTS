During `EVENT_LEAVE`, `get_var(0, "$pn")` does not update immediately.
Subtract `1` manually to get the correct player count.

**Example Usage:**
```lua
function OnLeave()
    local n = tonumber(get_var(0, "$pn")) - 1
    print('Total Players: ' .. n)
end
```