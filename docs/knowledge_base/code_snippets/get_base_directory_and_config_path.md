Here's a pair of functions for retrieving the **base Halo directory** and the **SAPP config directory**. Great for
building dynamic paths in scripts without hardcoding.

```lua
-- Returns the SAPP "config" directory path
-- Example: "C:\YourHaloServer\cg\sapp"
local function getConfigPath()
    return read_string(read_dword(sig_scan('68??????008D54245468') + 0x1))
end

-- Returns the base Server directory (optionally append a folder)
-- Example: "C:\YourHaloServer\" or "C:\YourHaloServer\logs"
local function getBaseDir(folder)
    folder = folder or "" -- optional subfolder
    local exe_path = read_string(read_dword(sig_scan('0000BE??????005657C605') + 0x3))
    local base_path = exe_path:match("(.*\\)") -- strip exe filename
    return base_path .. folder
end

-- Examples:
local base_dir = getBaseDir()       -- "C:\YourHaloServer\"
local maps_dir = getBaseDir("maps") -- "C:\YourHaloServer\maps"
local sapp_cg = getConfigPath()     -- "C:\YourHaloServer\cg\sapp"
```