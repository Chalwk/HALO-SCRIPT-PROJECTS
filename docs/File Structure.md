To maintain clean, readable, and modular code in (large) SAPP Lua script projects, I use the following organization and
structuring practices.

### Step 1: Creating the project folder

1. Create a folder with a descriptive name for the project (e.g., `TeamBattle`) in the `root` directory of the server (same location as sapp.dll)
2. Inside the project folder, create a subfolder called `events`.

### Step 2: Project Configuration Table (Team-Battle.lua)

1. Create a file named after the project (e.g., `Team-Battle.lua`) to hold the main configuration.
   <br>This is the file that will go into SAPP's `lua` folder.
2. Define a local table named `config` containing project settings and attributes.
3. Include a dependencies table within the `config` table to specify script files to be loaded by the main Lua script.

**Important Note:**
> Event-specific script files should be named according to the event they handle and placed within<br>
> the ./TeamBattle/events/ directory. This is important because the file names in the dependencies table<br> in Team-Battle.lua must match the event names used for registering callbacks.
>
> More on this in the next step.

**Code Example**

```lua
-- Inside Team-Battle.lua

-- This 'config' table holds project-wide settings and configurations, including script dependencies.
-- It contains a 'dependencies' field which is a dictionary of paths to arrays of script file names
-- that need to be loaded and connected together using metatables for inheritance and code organization.
local config = {

    -- The 'dependencies' dictionary holds the project's script dependencies, organized by path and file names
    dependencies = {
        -- The './TeamBattle/' path contains a 'settings' script dependency
        ['./TeamBattle/'] = { 'settings' },
        -- The './TeamBattle/events/' path contains multiple event-related script dependencies
        ['./TeamBattle/events/'] = {
            'on_join', -- A script dependency related to handling player join events
            'on_leave', -- A script dependency related to handling player leave events
            'on_tick', -- A script dependency related to handling server tick events
        },
        -- The './TeamBattle/util/' path contains a 'file_io' script dependency
        ['./TeamBattle/util/'] = {
            'file_io', -- A script dependency for handling file input/output operations
        }
    },

    -- Additional project-wide settings and configurations can be added here.
    -- However, it's recommended to use a separate 'settings.lua' file for user-configurable parameters,
    -- especially for larger projects.
    -- For example:
    teamSize = 4,
    gameDuration = 10, -- minutes
    -- ...
}

```

### Step 3: Separate Event-Specific Files (e.g., on_join.lua)

1. For each event-specific file, create a local table, such as `event`, to contain event handler functions.
2. Implement the event handler function with the same name as the table itself
   <br>(e.g., `on_join` for the `event:on_join` function).
3. At the bottom of each event-specific file, use `register_callback(cb['EVENT_NAME'], 'function_name')` to attach the
   <br>event handler function to the appropriate event. Replace `EVENT_NAME` with the actual event name
   <br>(e.g., '`EVENT_JOIN`') and `function_name` with the name of the function you've defined (e.g., '`on_join`').
   <br>Ensure that the function name matches the table name and the event file name.

**Code Example**

```lua
-- Inside on_join.lua

-- Define a local table named after the event file (e.g., 'on_join')
local event = {}

-- Implement the event handler function with the same name as the table (e.g., 'on_join')
function event:on_join(playerId)
    -- Handle player join event
end

-- Attach the on_join function to the EVENT_JOIN event
-- Make sure the function name matches the table name and the event file name (e.g., 'on_join')
register_callback(cb['EVENT_JOIN'], 'on_join')

-- Return the event table (e.g., 'on_join')
return on_join

```

### Step 4: Dependency Loading (Team-Battle.lua)

- Implement the loadDependencies function within the config table to load the script files specified in the dependencies
  table and set up the necessary metatables for inheritance.
    - Store the `config` table in a local variable `s` for later use.
    - Iterate through each path and its associated table of files in the `dependencies` table.
    - For each file, load and execute the file using `loadfile(path .. file .. '.lua')()`.
    - Set the metatable for the `s` variable, where `__index` refers to the loaded file's functions using `setmetatable(s, { __index = f })`.
    - Update the `s` variable to the loaded file's functions with `s = f`.
    - Check if the file path contains `/events/`. If found, create a global function that calls the function with the
      same name in the loaded file, passing self and any additional arguments
      using `_G[file] = path:find('/events/') and function(...) return f[file](self, ...) end or nil`.
- Implement the `OnScriptLoad` function:
    - Call the `loadDependencies` function from the `config` table to load and set up the script dependencies
      with `config:loadDependencies()`.

```lua
-- Inside Team-Battle.lua
api_version = '1.12.0.0'
local config = {
    dependencies = {
        ['./TeamBattle/'] = { 'settings' },
        ['./TeamBattle/events/'] = {
            'on_join',
            'on_leave',
            'on_tick',
        },
        ['./TeamBattle/util/'] = {
            'file_io',
        }
    }
}

-- Implement the loadDependencies function within the config table
function config:loadDependencies()
    -- Store the 'config' table in a local variable 's'
    local s = self

    -- Iterate through each path and its associated table of files in self.dependencies
    for path, t in pairs(self.dependencies) do

        -- Iterate through each file in the current table
        for _, file in pairs(t) do

            -- Load the file and execute it
            local f = loadfile(path .. file .. '.lua')()

            -- Set the metatable for the s variable, where __index refers to the loaded file's functions
            setmetatable(s, { __index = f })

            -- Assign s to the loaded file's functions
            s = f

            -- Check if the file path contains '/events/'
            _G[file] = path:find('/events/') and function(...)
                -- If found, create a global function that calls the function with the same name 
                -- in the loaded file, passing self and any additional arguments
                return f[file](self, ...)
            end or nil
        end
    end
end

-- Implement the OnScriptLoad function.
-- This function serves as the entry point for the script when it's loaded by SAPP. 
function OnScriptLoad()
    -- Call the loadDependencies function from the config table to load and set up the script dependencies
    config:loadDependencies()
end
```

### Step 4: Organize Files Logically

Organize your project files into logical folders and subfolders for clarity. Use descriptive names for files and folders
to make navigation easier for developers. Ensure file `dependencies` are clearly indicated in the dependencies table
within the `config` table.

File Organization Example:

- TeamBattle/
    - settings.lua
    - events/
        - on_join.lua
        - on_leave.lua
        - on_tick.lua
    - util/
        - file_io.lua

## HELPFUL TIPS:

### 1. Adding Comments and Documentation

Documentation and commenting are crucial for making your code readable, understandable, and maintainable. Here are some
guidelines:

1. **Comments**: Use comments to explain the purpose of a function, variable, or section of code. Single-line comments
   can be created using `--`, and multi-line comments can be enclosed in `--[[` and `--]]`.
2. **Function Documentation**: Document your functions using `---` above the function declaration. Include a brief
   description of the function's purpose, its arguments, and return values.
3. **Project Overview**: Provide a high-level overview of the project and its components at the top of the main Lua
   script. This helps developers understand the project structure and functionality without having to dig through the
   code.

### 2: Version Control

Using version control systems like Git is essential for managing and tracking changes to your project. Here's how to get
started:

1. **Initialize Git**: Run `git init` in the project directory to initialize a new Git repository.
2. **Commit Changes**: After making changes to your project, use `git add` to stage the changes, and then `git commit`
   to record the changes.
3. **Manage Branches**: Use branches to isolate changes and work on multiple features simultaneously. Create branches
   with `git branch` and switch between them with `git checkout`.
4. **Merge Changes**: When you're ready to merge changes back into the main branch, use `git merge` or `git rebase`.
5. **Remote Repositories**: Set up a remote repository (e.g., on GitHub) to collaborate with others and keep your code
   safe.

### 3: Testing and Debugging

Effective testing and debugging are crucial for maintaining code quality and catching issues early in development.
Consider these strategies:

1. Print Statements: Use print statements to output the values of variables or function results, helping you understand
   the flow of your code.
2. Assertion Functions: Use assertion functions (e.g., `assert(condition, error_message)`) to check if a condition holds
   true, raising an error if it doesn't.
3. Test Suites: Create separate Lua scripts for testing individual components of your project, helping you isolate and
   fix issues.