Scans the map's tag table in memory to find all weapons, vehicles, and equipment. For each tag, it reads the class,
name, metadata ID, and some key data bytes, then prints them in a readable format. Essentially, it's a tool for
exploring and debugging the properties of objects on a Halo map.

```lua
local format = string.format
local base_tag_table = 0x40440000

local function getClassName(class)
    return class == 0x76656869 and "vehi" 
    or class == 0x77656170 and "weap" 
    or class == 1701931376 and "eqip"
end

local function scanMapObjects()
    local tag_array = read_dword(base_tag_table)
    local tag_count = read_dword(base_tag_table + 0xC)

    for i = 0, tag_count - 1 do
        local tag = tag_array + 0x20 * i
        local class = read_dword(tag)
        local class_name = getClassName(class)

        if class_name then
            local name_ptr = read_dword(tag + 0x10)
            local name = (name_ptr ~= 0) and read_string(name_ptr) or "<no-name>"
            local meta = read_dword(tag + 0xC)
            local tag_data = read_dword(tag + 0x14)
            if tag_data ~= 0 then
                local b2 = read_byte(tag_data + 0x2)
                local b8 = read_byte(tag_data + 0x8)
                local d0 = read_dword(tag_data + 0x0)
                local d4 = read_dword(tag_data + 0x4)
                cprint(format(class_name .. " meta=%u tag_data=0x%X name=%s | b2=%d b8=%d d0=0x%X d4=0x%X",
                    meta, tag_data, name, b2, b8, d0, d4), 12)
            else
                cprint(format(class_name .. " meta=%u tag_data=nil name=%s", meta, name), 12)
            end
        end
    end
end
```