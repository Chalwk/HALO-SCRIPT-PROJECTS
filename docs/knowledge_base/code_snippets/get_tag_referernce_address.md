Retrieves the memory address of a tag given its class and name.

**Parameters:**

* `class` `string` - Tag class identifier (e.g., `"weap"`, `"vehi"`).
* `name` `string` - Tag name (e.g., `"weapons\\pistol\\pistol"`).
  **Returns:**
* `number|nil` - Memory address of the tag data, or `nil` if not found.

**Function Definition:**

```lua
local function getTag(class, name)
    local tag = lookup_tag(class, name)
    return tag and read_dword(tag + 0xC) or nil
end
```

### See similar function in [get_object_tag_address.md](get_object_tag_address.md)