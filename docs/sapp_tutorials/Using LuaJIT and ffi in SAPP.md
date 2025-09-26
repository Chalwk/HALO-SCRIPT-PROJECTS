SAPP uses **LuaJIT**, under the hood, which is a high-performance just-in-time compiler for **Lua 5.1**. This means most
Lua 5.1 code works, plus you get advanced features like the `ffi` library** to interface with C functions and memory.

## 1. What LuaJIT Gives You

* Fully compatible with **Lua 5.1**
* `ffi` library: call C functions, define structs, manipulate memory
* Performance improvements for math-heavy or iterative code

> Note: SAPP scripts run in a sandboxed environment. Some OS APIs may be restricted, and unsafe memory operations can
> crash the server.

---

## 2. Checking if `ffi` is Available

You can test if your SAPP version exposes `ffi`:

```lua
function OnScriptLoad()
    if pcall(function() require("ffi") end) then
        print("ffi is available")
    else
        print("ffi is NOT available")
    end
end
```

* `pcall` prevents crashes if `ffi` is blocked
* Output appears in the server console

---

## 3. Fully Functional Demo: Ticks Since Boot

Real-world FFI use: calling `GetTickCount` from Windows to get milliseconds since system boot.

```lua
api_version = '1.12.0.0'

local ffi = require("ffi")

-- Declare the C function we want to call
ffi.cdef[[
    unsigned long GetTickCount(void);
]]

function OnScriptLoad()
    -- Call the function and print result to the server console
    local ticks = ffi.C.GetTickCount()
    cprint(string.format("Ticks since boot: %d", ticks), 10) -- print in green
    
    register_callback(cb["EVENT_TICK"], "OnTick")
end

-- Print ticks every 10 seconds
function OnTick()
    if (os.clock() % 10) < 0.05 then
        local ticks = ffi.C.GetTickCount()
        cprint(string.format("Ticks since boot: %d", ticks), 10) -- print in green
    end
end
```

**How It Works**

1. **`api_version`**: Required for SAPP 1.12.0.0 scripts
2. **`ffi.cdef`**: Declares the C function signature
3. **`ffi.C.GetTickCount()`**: Calls the Windows API to get milliseconds since system boot
4. **`cprint`**: Prints colored text to the server console (SAPP built-in)
5. **`OnTick`**: Prints ticks every 10 seconds to show live updates

## 4. Key Tips and Safety

* Stick to **safe, read-only operations** at first
* Avoid writing memory directly unless you know the exact structure
* Remember: SAPP Lua is sandboxed, so not all OS APIs or memory operations are available