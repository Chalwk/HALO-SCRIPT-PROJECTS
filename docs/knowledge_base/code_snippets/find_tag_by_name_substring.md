```lua
-- Scan tag table for tags whose path/name contains substring.
-- class_filter is optional (string like 'weap','eqip','vehi'); pass nil to search all classes.
local function findTagByNameSubstring(substring, class_filter)
    local base_tag_table = 0x40440000
    substring = substring:lower()
    local tag_array = read_dword(base_tag_table)
    local tag_count = read_dword(base_tag_table + 0xC)
    for i = 0, tag_count - 1 do
        local tag = tag_array + 0x20 * i
        local class = read_dword(tag) -- class as 4-char code (weap, eqip, etc)
        if class_filter == nil or class == read_dword(lookup_tag(class_filter, "")) then
            local name_ptr = read_dword(tag + 0x10)
            if name_ptr ~= 0 then
                local name = read_string(name_ptr)
                if name and name:lower():find(substring, 1, true) then
                    return read_dword(tag + 0xC) -- return MetaIndex
                end
            end
        end
    end
    return nil
end
```