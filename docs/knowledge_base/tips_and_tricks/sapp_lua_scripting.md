**Understanding the SAPP Lua API Structure**

Before writing any code, ensure your script declares the correct API version and the three essential functions. This is the foundational skeleton for any SAPP Lua script.

* **`api_version`**: Always declare this at the top of your script. The API version must match the version SAPP is using. You can check the current version with the `lua_api_v` command in your server console. If the major version differs, the script won't load.
* **Required Functions**: Your script must include `OnScriptLoad()`, `OnScriptUnload()`, and optionally `OnError()`.

    * `OnScriptLoad()`: This is where you initialize your script and register all your event callbacks.
    * `OnScriptUnload()`: Use this for cleanup tasks, like resetting server states or unregistering callbacks.
    * `OnError(Message)`: Highly recommended for debugging. You can use `print(debug.traceback())` inside this function to get stack traces when errors occur.

**Example Skeleton Code:**

```lua
api_version = "1.12.0.0" -- Always use the correct version

function OnScriptLoad()
    -- Initialization and callback registration happens here
    register_callback(cb['EVENT_SPAWN'], "OnPlayerSpawn")
    register_callback(cb['EVENT_DIE'], "OnPlayerDeath")
    register_callback(cb['EVENT_CHAT'], "OnChatMessage")
end

function OnScriptUnload()
    -- Cleanup code (optional but good practice)
end

function OnError(Message)
    -- Enhanced error logging
    print(debug.traceback())
end
```

---

## Registering Event Callbacks Efficiently

Callbacks are how your script reacts to events in the game (e.g., a player spawning, dying, or chatting). For performance, **only register the callbacks you absolutely need**.

* **Key Event Callbacks**:

    * `cb['EVENT_SPAWN']`: Triggered when a player spawns.
    * `cb['EVENT_DIE']`: Triggered when a player dies.
    * `cb['EVENT_CHAT']`: Triggered when a chat message is sent. Returning `false` blocks the message.
    * `cb['EVENT_COMMAND']`: Triggered when a player executes a command. You can use this to create custom admin commands or block existing ones. Returning `false` blocks the command.
    * `cb['EVENT_OBJECT_SPAWN']`: Triggered when an object (weapon, vehicle, etc.) is created. You can even return a different MapID to change what object spawns.
    * `cb['EVENT_DAMAGE_APPLICATION']`: Triggered when damage is applied. This is incredibly powerful; you can modify damage amounts or block damage entirely. *Tip: To block fall damage without causing issues, use `return true, 0` instead of `return false`*.

**Example: Custom Command Handling**

```lua
function OnCommand(PlayerIndex, Command, Environment, Password)
    -- Check if a player is trying to use the server's 'kick' command without permission
    if Command == "some_command" then
        say(PlayerIndex, "You are not authorized to use that command!")
        return false -- Block the command from executing
    end
    return true -- Allow the command to proceed
end
```

---

## Leveraging SAPP's Built-In Functions

SAPP provides powerful built-in functions to interact with the game and server. Utilizing these is key to writing effective scripts.

* **`execute_command("command_string")`**: This function allows your Lua script to execute any server command. You can use it to kick players, change maps, or adjust settings programmatically.
* **`say(PlayerIndex, "message")` and `say_all("message")`**: Use these to send chat messages to a specific player or all players, respectively. Great for sending alerts or instructions.
* **`get_var(PlayerIndex, "$variable")`**: This fetches the value of a SAPP variable (e.g., `"$hp"` for health, `"$warnings"` for warning count). Essential for checking player statuses. Pass `0` instead of PlayerIndex to get a server variable.
* **`rand(min, max)`**: Generates a cryptographically secure random number. Useful for adding randomness to events, like random weapon spawns or random player effects.

**Example: Random Teleport on Spawn**

```lua
function OnPlayerSpawn(PlayerIndex)
    local x = rand(-50, 50) -- Generate random coordinates
    local y = rand(-50, 50)
    local z = rand(10, 20)
    execute_command("teleport " .. PlayerIndex .. " " .. x .. " " .. y .. " " .. z)
    say(PlayerIndex, "You have been teleported to a random location!")
end
```

---

## Localizing Heavily Used Globals and Functions

Cache frequently used globals into locals at the top of the script or function (e.g., `local table_insert = table.insert`) - local variable access is faster than global table lookups. This is a small win but helps in hot code paths.

---

## Managing Script Lifecycle and Errors

Properly managing how your script loads, unloads, and handles errors is crucial for server stability.

* **Load/Unload Commands**: Remember to use `lua_load <scriptname>` and `lua_unload <scriptname>` to activate or deactivate your scripts.
* **Error Handling**: The `OnError` function is your best friend for debugging. Without it, a runtime error in your script might cause it to fail silently, making problems very hard to trace. The `debug.traceback()` function provides a call stack, showing you exactly where the error occurred.
---

## Optimizing Math Operations

When you pass arguments via `execute_command("lua_call ...")`, SAPP passes them as strings. Convert once and cache (e.g., `tonumber(arg)` at the entry) instead of repeatedly parsing.

---

## Using Provided API Helpers (Player Checks, Indices)

SAPP exposes convenience functions like `player_present()`, `player_alive()`, and `to_player_index()`. Use them instead of custom checks to avoid edge-case bugs with slot indices and spectators.

---

## Be GC-Aware, Control Collection During Quiet Moments

**Lua's** GC can cause pauses. If you must, use `collectgarbage()` tactically (e.g., do a manual `collectgarbage("step", N)` or full collect during round end/idle). Use this sparingly; measure first.

---

## Minimize Garbage - Reuse Tables / Object Pools

Create simple `newtable` / `freetable` helpers to avoid allocating lots of tiny temp tables each tick. Reusing tables reduces GC churn and frame hitches.

**Simple pool pattern:**

```lua
local pool = {}

local function newtable()
  return table.remove(pool) or {}
end

local function freetable(t)
  for k in pairs(t) do t[k] = nil end
  pool[#pool+1] = t
end
```

Recycling tables is a common technique to reduce GC pressure.

---

## Avoid Heavy Work Inside Callbacks - Batch & Defer

If an event can fire often (weapon pickups, player damage), do the minimum in the callback, then push work to a timer or queue processed at a lower frequency (e.g., every 200ms).

**Pattern:**

* Callback - push a light record into a table.
* Timer every 200ms - drain the table and do heavier processing.

---

## Use `timer(ms, callback, ...)` for Delayed/Repeating Work

SAPP provides `timer()` so you can schedule work after X milliseconds. If the callback returns `true`, it repeats.

**Example (run once after 5s):**

```lua
function OnPlayerJoin(PlayerIndex)
  timer(5000, "PostJoinTask", PlayerIndex)
end

function PostJoinTask(PlayerIndex)
  -- returns nothing -> runs once
  say_all("5s passed for "..PlayerIndex)
end
```

This avoids per-tick loops.

---

## Security & Sanity Checks

* **Validate every client command**: check player index exists, check admin level for privileged commands, check numeric ranges and types. Don't `loadstring` arbitrary strings from clients.
* **Rate-limit resource-hungry actions** (spawns, custom commands). Per-player cooldown tables are simple and effective.
* **Anti-tampering**: assume a modified client will attempt odd commands; log suspicious behaviour server-side for review. SAPP offers anti-cheat utilities, use them.

---

## Networking, Tickrate & Hit Detection

* **Tickrate reality:** The classic Halo engine runs at ~**30 Hz** simulation/tick; this affects per-tick movement and projectile traversal (impacts interpolation/extrapolation decisions). Higher/lower tickrates change projectile behavior and timers, be conservative when using timing constants. See [hllmn](https://hllmn.net/blog/2023-09-18_h1x-net) for more information.

* **Per-tick math:** convert velocities to per-tick deltas: `per_tick = (WU_per_s / tickrate)`. That's how far a projectile moves each server tick. Use per-tick math for prediction and collision checks.

* **Latency compensation patterns:** timestamp inputs (client-side) and use server reconciliation if you simulate player movement for e.g., anti-cheat. For most server-side scripts you'll: record authoritative server states, apply client inputs when received (with reasonable bounds), and, when necessary, perform conservative validation (did the player have line-of-sight at that time?). See general netcode patterns (extrapolation/prediction/reconciliation). See [Wikipedia Netcode](https://en.wikipedia.org/wiki/Netcode) for more information.

* **Projectiles vs hitscan:** Understand weapon behavior (some weapons are effectively projectile-based with very high velocity; others are closer to hitscan). For CE, a common pistol projectile value is documented (community references give `300 WU/s` for pistol projectile speed). Use those tag values for accurate projectile travel math if you need exact behavior.

---

## Event Handling Patterns & Anti-Spam

* **Debounce & coalesce:** If event X can fire many times quickly (weapon fire, damage), push a small entry into a queue and process it on a short repeating timer (e.g., every 50-200ms).

* **Rate-limit player actions:** track timestamps per player for sensitive commands or calls (e.g., /spawngun). If `now - last_cmd < limit` reject silently or warn.

* **Priority queues:** for tasks of different criticality (e.g., immediate score updates vs. log writes), use separate queues to avoid blocking critical flows.