### Map vote/map cycle systems:

1). Do not use the `mapvote_add` command in the _init.txt_ file to add map vote options, otherwise, SAPP will add a new entry to the _mapvotes.txt_ file (therefore creating duplicates) every time the server is booted. Instead, add map vote entries (once) directly to _mapvotes.txt_.

The map vote format is: **map:variant:name:min:max**

| property | description                                                                                                                |
|----------|----------------------------------------------------------------------------------------------------------------------------|
| map      | Name of the map                                                                                                            |
| variant  | Name of the custom game mode or game type<br/>Game modes that contain spaces should be encapsulated in double-quotes (""). |
| name     | User-defined message that appears next to the map vote option at the end of the game.                                      |
| min      | Minimum number of players                                                                                                  |
| max      | Maximum number of players                                                                                                  |

2). SAPPs map vote system will hang for 60 seconds and then select a random map from _mapvotes.txt_ when the server is booted. To prevent SAPP from hanging for 60 seconds, put **max_idle 1** in your init.txt file.

To force the server to start on a specific map, do the following:
- Open _init.txt_ and add this command: **map map_name mode**<br/>
  For example: **map ratrace MyCustomCTF**

----

### SAPPs built-in rand() function:
_For some reason the maximum number is exclusive._

When defining a maximum number, increment it by one:
```lua
local t = {'a', 'b', 'c'}
local i = rand(1, #t + 1)
print(t[i])

-- This guarantees that i (1 thru #t) are potential candidates.
```

### SAPPs **write_vector3d()** function:
Teleporting a vehicle with **write_vector3d()** can cause glitchy behaviour.
Solution: (doesn't work 100% of the time):
- Update the object's position vector as usual, but add a tiny bit of z-velocity. -0.025 should be enough.
- Unset the no-collision & ignore-physics bits:
```lua
write_bit(object + 0x10, 0, 0)
write_bit(object + 0x10, 5, 0)
```

### SAPPs **spawn_object()** function:
If you're trying to spawn an object with a custom rotation, make sure the rotation property is in radians, not degrees.

### Custom spawn systems:
If you are creating a custom spawn system, update the player's position vector during EVENT_PRESPAWN:
```lua
local r = pR      -- rotation in radians (not degrees)
local z_off = 0.3 -- offset (in world units) to prevent them from falling thru the map.
local x = px
local y = py
local z = pz + z_off

-- Update player vector position: (dyn = memory address of the player)
write_vector3d(dyn + 0x5C, x, y, z)

-- Update player rotation: (dyn = memory address of the player)
write_vector3d(dyn + 0x74, math.cos(r), math.sin(r), 0)
```


### Assigning more than 2 weapons:
If you want to assign tertiary and quaternary weapons without them dropping to the ground, you must delay these two assignments by a minimum of 250ms.
See [this script](https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/Miscellaneous/4-weapons%20(example%20script).lua) to learn how.


### SAPPs **$pn** server variable:
If you're trying to count the number of players online during EVENT_LEAVE with get_var(0, '\$pn), you have to manually deduct 1 from n.
This is because get_var(0, '\$pn) does not update immediately.

For example:
```lua
function OnLeave()
    local n = tonumber(get_var(0, "$pn")) - 1
    print('Total Players: ' .. n)
end
```