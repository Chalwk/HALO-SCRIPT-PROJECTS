--[[
================================================================================
SCRIPT NAME:      item_spawner.lua
DESCRIPTION:      Item spawning system for weapons, vehicles, and equipment
                  - Spawn weapons, vehicles, equipment, bipeds, and projectiles
                  - Enter vehicles with seat selection
                  - Object caching and cleanup system
                  - Paginated item listing

COMMAND SYNTAX:
    /clean [type]                       - Destroy cached objects of given type
    /enter <alias> [seat] [amount]      - Enter vehicle with seat selection
    /give <alias> [amount]              - Give weapon/equipment
    /itemlist [page]                    - List available items
    /spawn <alias> [amount]             - Spawn object at position

Copyright (c) 2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
================================================================================
]] --

-- CONFIGURATION START ---------------------------------------------------------

local REQUIRED_PERMISSION_LEVEL = 4

-- Object management settings
local DESTROY_ON_QUIT = true
local ITEM_QUANTITY = 1
local MAX_OBJECTS = 200
local DISTANCE_FROM_PLAYER = 2.5

-- Display settings
local MAX_RESULTS_PER_PAGE = 25
local MAX_ITEMS_PER_ROW = 4

local COMMANDS = {
    ["clean"] = true,
    ["enter"] = true,
    ["give"] = true,
    ["itemlist"] = true,
    ["spawn"] = true
}

-- Item definitions with [tag class], {tag path, display name, {aliases}, and seats (for vehicles)}
local ITEMS = {
    ["bipd"] = {
        { "characters\\cyborg_mp\\cyborg_mp", "Cyborg", { "cyborg" } }
    },

    ["eqip"] = {
        { "powerups\\full-spectrum vision",          "Vision Spectrum Cube", { "vscube" } },
        { "powerups\\health pack",                   "Health Pack",          { "health", "hp" } },
        { "powerups\\active camouflage",             "Camouflage",           { "camo", "camouflage" } },
        { "powerups\\over shield",                   "Over Shield",          { "overshield", "os", "sh" } },
        { "weapons\\frag grenade\\frag grenade",     "Frag Grenade",         { "frag", "grenade", "fraggrenade" } },
        { "weapons\\plasma grenade\\plasma grenade", "Plasma Grenade",       { "plasma", "plasmagrenade" } }
    },

    ["vehi"] = {
        { "vehicles\\ghost\\ghost_mp",               "Ghost",   { "ghost" },                 1 },
        { "vehicles\\rwarthog\\rwarthog",            "R-Hog",   { "rhog" },                  3 },
        { "vehicles\\banshee\\banshee_mp",           "Banshee", { "banshee", "banshee_mp" }, 1 },
        { "vehicles\\c gun turret\\c gun turret_mp", "Turret",  { "turret" },                1 },
        { "vehicles\\warthog\\mp_warthog",           "Warthog", { "hog", "warthog" },        3 },
        { "vehicles\\scorpion\\scorpion_mp",         "Tank",    { "tank", "scorpion" },      5 }
    },

    ["weap"] = {
        { "weapons\\gravity rifle\\gravity rifle",     "Gravity Gun",     { "gravitygun" } },
        { "weapons\\flag\\flag",                       "Flag",            { "flag" } },
        { "weapons\\ball\\ball",                       "Skull",           { "skull" } },
        { "weapons\\pistol\\pistol",                   "Pistol",          { "pistol" } },
        { "weapons\\shotgun\\shotgun",                 "Shotgun",         { "shotgun" } },
        { "weapons\\needler\\mp_needler",              "Needler",         { "needler" } },
        { "weapons\\plasma rifle\\plasma rifle",       "Plasma Rifle",    { "prifle", "plasmarifle" } },
        { "weapons\\flamethrower\\flamethrower",       "Flamethrower",    { "flame", "flamethrower" } },
        { "weapons\\plasma_cannon\\plasma_cannon",     "Plasma Cannon",   { "pcannon", "plasmacannon" } },
        { "weapons\\plasma pistol\\plasma pistol",     "Plasma Pistol",   { "ppistol", "plasmapistol" } },
        { "weapons\\assault rifle\\assault rifle",     "Assault Rifle",   { "arifle", "assaultrifle" } },
        { "weapons\\sniper rifle\\sniper rifle",       "Sniper Rifle",    { "sniper", "sniperrifle" } },
        { "weapons\\rocket launcher\\rocket launcher", "Rocket Launcher", { "rocketl", "rocketlauncher" } }
    },

    ["proj"] = {
        { "weapons\\flamethrower\\flame",           "Flames",                    { "flames", "flameproj" } },
        { "weapons\\needler\\mp_needle",            "Needler Needle",            { "needle", "needlerproj" } },
        { "weapons\\rocket launcher\\rocket",       "Rocket",                    { "rocket", "rocketproj" } },
        { "weapons\\pistol\\bullet",                "Pistol Bullet",             { "pistolbullet", "pistolproj" } },
        { "weapons\\plasma pistol\\bolt",           "Plasma Pistol Bolt",        { "ppistolproj" } },
        { "weapons\\sniper rifle\\sniper bullet",   "Sniper Bullet",             { "sniperproj" } },
        { "weapons\\plasma rifle\\bolt",            "Plasma Rifle Bolt",         { "plasmariflebolt" } },
        { "weapons\\assault rifle\\bullet",         "Assault Rifle Bullet",      { "ariflebullet" } },
        { "weapons\\plasma rifle\\charged bolt",    "Plasma Rifle Charged Bolt", { "priflecharged" } },
        { "weapons\\shotgun\\pellet",               "Shotgun Pellet",            { "shotgunproj" } },
        { "weapons\\plasma_cannon\\plasma_cannon",  "Plasma Cannon Shot",        { "fuelrodproj" } },
        { "vehicles\\warthog\\bullet",              "Warthog Bullet",            { "warthogbullet", "warthogproj" } },
        { "vehicles\\scorpion\\bullet",             "Tank Bullet",               { "tankbullet", "tankbulletproj" } },
        { "vehicles\\c gun turret\\mp gun turret",  "Turret Bolt",               { "turretbolt", "turretproj" } },
        { "vehicles\\ghost\\ghost bolt",            "Ghost Bolt",                { "ghostbolt", "ghostproj" } },
        { "vehicles\\scorpion\\tank shell",         "Tank Shell",                { "tankshell", "tankshellproj" } },
        { "vehicles\\banshee\\mp_banshee fuel rod", "Banshee Fuel Rod",          { "bansheerod" } },
        { "vehicles\\banshee\\banshee bolt",        "Banshee Bolt",              { "sheebolt" } }
    }
}
-- CONFIGURATION END -----------------------------------------------------------

api_version = '1.12.0.0'

local get_var, rprint, cprint, player_present, player_alive =
    get_var, rprint, cprint, player_present, player_alive

local lookup_tag, read_dword, spawn_object, get_dynamic_player, get_object_memory =
    lookup_tag, read_dword, spawn_object, get_dynamic_player, get_object_memory

local read_vector3d, read_float, destroy_object, enter_vehicle, assign_weapon =
    read_vector3d, read_float, destroy_object, enter_vehicle, assign_weapon

local table_insert, table_concat, table_sort, ipairs, tonumber =
    table.insert, table.concat, table.sort, ipairs, tonumber

local math_min, math_max, math_ceil, math_atan, math_pi =
    math.min, math.max, math.ceil, math.atan, math.pi

local string_lower, string_match = string.lower, string.match

local players = {}
local catalog = { items = {}, aliases = {} }
local OBJECT_TYPES = {
    ["vehi"] = { name = "vehi", display = "Vehicles" },
    ["weap"] = { name = "weap", display = "Weapons" },
    ["eqip"] = { name = "eqip", display = "Equipment" },
    ["bipd"] = { name = "bipd", display = "Bipeds" },
    ["proj"] = { name = "proj", display = "Projectiles" },
    ["all"] = { name = "all", display = "Everything" }
}

local function atan2(y, x)
    return math_atan(y / x) + ((x < 0) and math_pi or 0)
end

local function create_player(id)
    players[id] = {
        id = id,
        name = get_var(id, '$name'),
        cached_objects = {},
        object_count = 0
    }
    return players[id]
end

local function destroy_oldest_object(player)
    if #player.cached_objects > 0 then
        local object_id = table.remove(player.cached_objects, 1)
        destroy_object(object_id)
        player.object_count = player.object_count - 1
        return true
    end
    return false
end

local function cache_object(player, object_id)
    if player.object_count >= MAX_OBJECTS then
        destroy_oldest_object(player)
    end

    table_insert(player.cached_objects, object_id)
    player.object_count = player.object_count + 1
    return true
end

local function clean_objects(player, object_type)
    local cleaned = 0

    if object_type == "all" then
        for _, object_id in ipairs(player.cached_objects) do
            destroy_object(object_id)
            cleaned = cleaned + 1
        end
        player.cached_objects = {}
        player.object_count = 0
    else
        for _, object_id in ipairs(player.cached_objects) do
            destroy_object(object_id)
            cleaned = cleaned + 1
        end
        player.cached_objects = {}
        player.object_count = 0
    end

    return cleaned
end

local function get_tag(class, name)
    local tag = lookup_tag(class, name)
    return tag ~= 0 and read_dword(tag + 0xC) or nil
end

local function initialize_catalog()
    for tag_class, entries in pairs(ITEMS) do
        for _, item_data in ipairs(entries) do
            local tag_path, display_name, aliases, seats =
                item_data[1], item_data[2], item_data[3], item_data[4]

            local tag_id = get_tag(tag_class, tag_path)
            if tag_id then
                local item = {
                    tag_id = tag_id,
                    display_name = display_name,
                    aliases = aliases or {},
                    seats = seats or 1,
                    is_vehicle = (tag_class == "vehi"),
                    is_weapon = (tag_class == "weap"),
                    is_equipment = (tag_class == "eqip")
                }

                table_insert(catalog.items, item)

                table_insert(catalog.aliases, { name = display_name:lower(), item = item })
                for _, alias in ipairs(aliases or {}) do
                    table_insert(catalog.aliases, { name = alias:lower(), item = item })
                end
            else
                cprint("Warning: Could not find tag " .. tag_class .. ", " .. tag_path, 12)
            end
        end
    end

    cprint("ItemSpawner: Loaded " .. #catalog.items .. " items with " .. #catalog.aliases .. " aliases", 6)
end

local function find_item(search_term)
    search_term = string_lower(search_term)

    -- Exact match first
    for _, alias in ipairs(catalog.aliases) do
        if alias.name == search_term then
            return alias.item
        end
    end

    -- Partial match
    for _, alias in ipairs(catalog.aliases) do
        if string_match(alias.name, search_term) then
            return alias.item
        end
    end

    return nil
end

local function get_all_items() return catalog.items end

local function hasPermission(id)
    local level = tonumber(get_var(id, '$lvl'))
    return level and level >= REQUIRED_PERMISSION_LEVEL
end

local function parse_seat_option(seat_str, max_seats)
    if not seat_str then return 0 end

    if seat_str == "*" then
        return 1 -- Gunner seat
    elseif seat_str == "^" then
        return 2 -- Passenger seat
    elseif seat_str == "-" then
        return 0 -- Driver seat (default)
    else
        local seat_num = tonumber(seat_str)
        if seat_num and seat_num >= 0 and seat_num < max_seats then
            return seat_num
        end
    end

    return 0 -- Default to driver
end

local function getCam(dyn)
    local cam_x = read_float(dyn + 0x230)
    local cam_y = read_float(dyn + 0x234)
    local cam_z = read_float(dyn + 0x238)
    return cam_x, cam_y, cam_z
end

local function get_position(id)
    local dyn = get_dynamic_player(id)
    if dyn == 0 then return end

    local vehicle_id = read_dword(dyn + 0x11C)
    local vehicle_obj = get_object_memory(vehicle_id)

    local x, y, z
    if vehicle_id == 0xFFFFFFFF then
        x, y, z = read_vector3d(dyn + 0x5C)
    elseif vehicle_obj ~= 0 then
        x, y, z = read_vector3d(vehicle_obj + 0x5C)
    end

    local cam_x, cam_y, cam_z = getCam(dyn)

    local distance = DISTANCE_FROM_PLAYER
    local spawn_x = x + (distance * cam_x)
    local spawn_y = y + (distance * cam_y)
    local spawn_z = z + (distance * cam_z)

    local yaw = atan2(cam_y, cam_x)

    return spawn_x, spawn_y, spawn_z, yaw
end

local function spawn_item(id, item, options)
    local player = players[id]
    if not player then return {} end

    local quantity = options.amount or ITEM_QUANTITY
    local seat = options.seat
    local spawned_objects = {}

    for _ = 1, quantity do
        local x, y, z, yaw = get_position(id)
        if not x then break end

        local object_id = spawn_object('', '', x, y, z, yaw, item.tag_id)
        if object_id then
            cache_object(player, object_id)
            table_insert(spawned_objects, object_id)

            if item.is_vehicle and options.enter then
                local seat_index = parse_seat_option(seat, item.seats)
                enter_vehicle(object_id, id, seat_index)
            elseif item.is_weapon then
                assign_weapon(object_id, id)
            elseif item.is_equipment then
                local dyn = get_dynamic_player(id)
                if dyn ~= 0 then
                    local vehicle_id = read_dword(dyn + 0x11C)
                    if vehicle_id == 0xFFFFFFFF then
                        powerup_interact(object_id, id)
                    end
                end
            end
        end
    end

    return spawned_objects
end

local function clean_player_objects(id, object_type)
    local player = players[id]
    if not player then return {} end
    return clean_objects(player, object_type)
end

local function remove_player(id)
    if DESTROY_ON_QUIT and players[id] then
        clean_objects(players[id], "all")
    end
    players[id] = nil
end

local function parse_options(args, start_index)
    local options = { amount = ITEM_QUANTITY, seat = nil }
    for i = start_index, #args do
        local arg = args[i]
        local num = tonumber(arg)
        if num then
            options.amount = num
        elseif arg == "*" or arg == "^" or arg == "-" then
            options.seat = arg
        end
    end

    return options
end

local function handle_clean_command(id, args)
    local type_str = args[2] or "all"

    if not OBJECT_TYPES[type_str] then
        rprint(id, "Invalid object type. Use: vehi, weap, eqip, bipd, proj, or all")
        return
    end

    local cleaned = clean_player_objects(id, type_str)
    rprint(id, "Cleaned " .. cleaned .. " objects")
end

local function handle_enter_command(id, args)
    local vehicle_name = args[2]

    if not vehicle_name then
        rprint(id, "Usage: /enter <vehicle> [seat] [amount]")
        return
    end

    local options = parse_options(args, 3)
    options.enter = true

    local vehicle_item = find_item(vehicle_name)
    if not vehicle_item or not vehicle_item.is_vehicle then
        rprint(id, "Vehicle not found: " .. vehicle_name)
        return
    end

    if not player_alive(id) then
        rprint(id, "You must be alive to enter a vehicle")
        return
    end

    local vehicles = spawn_item(id, vehicle_item, options)
    rprint(id, "Entered " .. #vehicles .. " " .. vehicle_item.display_name .. "(s)")
end

local function handle_give_command(id, args)
    local item_name = args[2]

    if not item_name then
        rprint(id, "Usage: /give <item> [amount]")
        return
    end

    local options = parse_options(args, 3)

    local item = find_item(item_name)
    if not item then
        rprint(id, "Item not found: " .. item_name)
        return
    end

    if not item.is_weapon and not item.is_equipment then
        rprint(id, "Cannot give " .. item.display_name .. ". Use /spawn instead.")
        return
    end

    local items = spawn_item(id, item, options)
    rprint(id, "Gave " .. #items .. " " .. item.display_name .. "(s)")
end

local function format_items_page(items, page, total_pages, items_per_row)
    local result = {}
    local start_index = (page - 1) * MAX_RESULTS_PER_PAGE + 1
    local end_index = math_min(start_index + MAX_RESULTS_PER_PAGE - 1, #items)

    table_insert(result,
        "Page " .. page .. "/" .. total_pages .. " - Showing " .. (end_index - start_index + 1) .. " items")

    local current_row = {}
    for i = start_index, end_index do
        local item = items[i]
        local display_text = item.display_name
        if item.is_vehicle then
            display_text = display_text .. " (" .. item.seats .. " seats)"
        end

        table_insert(current_row, display_text)

        if #current_row >= items_per_row then
            table_insert(result, table_concat(current_row, ", "))
            current_row = {}
        end
    end

    if #current_row > 0 then
        table_insert(result, table_concat(current_row, ", "))
    end

    return result
end

local function sort(items)
    table_sort(items, function(a, b) return a.display_name < b.display_name end)
    return items
end

local function handle_itemlist_command(id, args)
    local page_str = args[2]

    local items = get_all_items()
    if #items == 0 then
        rprint(id, "No items found")
        return
    end

    items = sort(items)

    local total_pages = math_ceil(#items / MAX_RESULTS_PER_PAGE)
    local page = tonumber(page_str) or 1
    page = math_max(1, math_min(page, total_pages))

    rprint(id, "=== Available Items (" .. #items .. " items) ===")

    local output_lines = format_items_page(items, page, total_pages, MAX_ITEMS_PER_ROW)
    for _, line in ipairs(output_lines) do
        rprint(id, line)
    end

    if total_pages > 1 then
        rprint(id, "Use '/itemlist " .. (page + 1) .. "' for next page")
    end
end

local function handle_spawn_command(id, args)
    local item_name = args[2]

    if not item_name then
        rprint(id, "Usage: /spawn <item> [amount]")
        return
    end

    local options = parse_options(args, 3)

    local item = find_item(item_name)
    if not item then
        rprint(id, "Item not found: " .. item_name)
        return
    end

    local player = players[id]
    if not player then
        rprint(id, "Player data not initialized")
    else
        local objects = spawn_item(id, item, options)
        rprint(id, "Spawned " .. #objects .. " " .. item.display_name .. "(s)")
    end
end

local function parse_command_args(command)
    local args = {}
    for substring in command:gmatch("([^%s]+)") do
        table_insert(args, substring)
    end
    return args
end

function OnScriptLoad()
    register_callback(cb['EVENT_JOIN'], "OnJoin")
    register_callback(cb['EVENT_LEAVE'], "OnQuit")
    register_callback(cb['EVENT_COMMAND'], "OnCommand")
    register_callback(cb['EVENT_GAME_START'], "OnStart")

    OnStart() -- in case script is loaded mid-game
end

function OnCommand(id, Command)
    local args = parse_command_args(Command)
    if #args == 0 then return true end

    local cmd = args[1]:lower()

    if COMMANDS[cmd] then
        if id == 0 then
            cprint("Console cannot use this command")
        elseif not hasPermission(id) then
            rprint(id, "Insufficient permissions")
        elseif cmd == "itemlist" or cmd == "clean" then
            if cmd == "clean" then
                handle_clean_command(id, args)
            elseif cmd == "itemlist" then
                handle_itemlist_command(id, args)
            end
        elseif not player_alive(id) then
            rprint(id, "You need to be alive to use this command")
        elseif cmd == "enter" then
            handle_enter_command(id, args)
        elseif cmd == "give" then
            handle_give_command(id, args)
        elseif cmd == "spawn" then
            handle_spawn_command(id, args)
        end

        return false
    end
end

function OnJoin(id)
    create_player(id)
end

function OnQuit(id)
    remove_player(id)
end

function OnStart()
    if get_var(0, '$gt') == 'n/a' then return end

    initialize_catalog()
    for i = 1, 16 do
        if player_present(i) then
            OnJoin(i)
        end
    end
end

function OnScriptUnload()
    for i = 1, 16 do
        if player_present(i) then
            remove_player(i)
        end
    end
end
