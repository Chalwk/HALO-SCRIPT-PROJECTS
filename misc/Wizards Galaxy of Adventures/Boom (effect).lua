-- Custom Explosion Effect (for Shoo)
-- By Chalwk, v 1.0

local custom_command = "boom"
local proj = { "proj", "weapons\\rocket launcher\\rocket" }
local permission_level = 1
local enable_messages = false

local messages = {
    [1] = "|cBoom! You blew up %victim_name%",
    [2] = "|cBoom! You were blown up by %killer_name%",
    [3] = "|cBoom! You blew yourself up!"
}

api_version = "1.12.0.0"
local rocket_objects = {}
local gsub, gmatch = string.gsub, string.gmatch
local tag_data

local function ValidTag(obj_type, obj_name)
    local tag = lookup_tag(obj_type, obj_name)
    return tag ~= 0 and read_dword(tag + 0xC) or nil
end

local function TagData()
    local tag_address = read_dword(0x40440000)
    local tag_count = read_dword(0x4044000C)

    for i = 0, tag_count - 1 do
        local tag = tag_address + 0x20 * i
        local tag_name = read_string(read_dword(tag + 0x10))
        local tag_class = read_dword(tag)

        if tag_class == 1785754657 and tag_name == "weapons\\rocket launcher\\explosion" then
            if ValidTag(proj[1], proj[2]) then
                return read_dword(tag + 0x14)
            end
        end
    end

    return nil
end

function OnScriptLoad()
    register_callback(cb['EVENT_TICK'], "OnTick")
    register_callback(cb['EVENT_GAME_START'], "OnNewGame")
    register_callback(cb["EVENT_COMMAND"], "OnServerCommand")

    if get_var(0, "$gt") ~= "n/a" then
        rocket_objects = {}
        tag_data = TagData()
    end
end

function OnScriptUnload()
    -- Empty function to handle script unload
end

local function ModifyRocketProjectile()
    write_dword(tag_data + 0x0, 1084227584)
    write_dword(tag_data + 0x4, 1084227584)
    write_dword(tag_data + 0x1d0, 1065353216)
    write_dword(tag_data + 0x1d4, 1065353216)
    write_dword(tag_data + 0x1d8, 1065353216)
    write_dword(tag_data + 0x1f4, 1092616192)
end

local function RollbackRocketProjectile()
    write_dword(tag_data + 0x0, 1056964608)
    write_dword(tag_data + 0x4, 1073741824)
    write_dword(tag_data + 0x1d0, 1117782016)
    write_dword(tag_data + 0x1d4, 1133903872)
    write_dword(tag_data + 0x1d8, 1134886912)
    write_dword(tag_data + 0x1f4, 1086324736)
end

function OnTick()
    if #rocket_objects > 0 then
        for i = #rocket_objects, 1, -1 do
            if not rocket_objects[i] or get_object_memory(rocket_objects[i]) == 0 then
                table.remove(rocket_objects, i)
            end
        end

        if #rocket_objects == 0 then
            RollbackRocketProjectile()
        end
    end
end

function OnNewGame()
    if get_var(0, "$gt") ~= "n/a" then
        rocket_objects = {}
        tag_data = TagData()
    end
end

local function CmdSplit(CMD)
    local args = {}
    for Params in gmatch(CMD, "([^%s]+)") do
        args[#args + 1] = Params
    end
    return args
end

local function Respond(PlayerIndex, Message, Color, ChatType)
    if PlayerIndex == 0 then
        Color = Color or 2 + 8
        cprint(Message, Color)
    else
        if ChatType == "rcon" then
            rprint(PlayerIndex, Message)
        else
            say(PlayerIndex, Message)
        end
    end
end

local function SendExplosionMessages(Executor, TargetID)
    local TargetName = get_var(TargetID, "$name")
    local ExecutorName = get_var(Executor, "$name") or "The Server"

    if Executor ~= TargetID then
        Respond(Executor, gsub(messages[1], "%%victim_name%%", TargetName), 2 + 8, "rcon")
        Respond(TargetID, gsub(messages[2], "%%killer_name%%", ExecutorName), 2 + 8, "rcon")
    else
        Respond(Executor, messages[3], 2 + 8, "rcon")
    end
end

local function SetProjectileProperties(projectile)
    write_float(projectile + 0x68, 0)
    write_float(projectile + 0x6C, 0)
    write_float(projectile + 0x70, -9999)
end

local function GetXYZ(DynamicPlayer)
    local coordinates = {}
    local VehicleID = read_dword(DynamicPlayer + 0x11C)

    if VehicleID == 0xFFFFFFFF then
        coordinates.x, coordinates.y, coordinates.z = read_vector3d(DynamicPlayer + 0x5c)
    else
        coordinates.x, coordinates.y, coordinates.z = read_vector3d(get_object_memory(VehicleID) + 0x5c)
    end

    return coordinates
end

local function ExecuteBoomEffect(Executor, TargetID)
    local DynamicPlayer = get_dynamic_player(TargetID)

    if DynamicPlayer ~= 0 then
        local coords = GetXYZ(DynamicPlayer)
        local payload = spawn_object(proj[1], proj[2], coords.x, coords.y, coords.z + 5)

        if payload then
            local projectile = get_object_memory(payload)

            if projectile ~= 0 then
                rocket_objects[#rocket_objects + 1] = payload
                ModifyRocketProjectile()
                SetProjectileProperties(projectile)

                if enable_messages then
                    SendExplosionMessages(Executor, TargetID)
                end
            end
        end
    end
end

local function GetPlayers(P, Args)
    local pl = {}

    if Args[2] == nil or Args[2] == "me" then
        pl[#pl + 1] = P
    elseif Args[2]:match("%d+") and player_present(Args[2]) then
        pl[#pl + 1] = Args[2]
    elseif Args[2] == "all" or Args[2] == "*" then
        for i = 1, 16 do
            if player_present(i) then
                pl[#pl + 1] = i
            end
        end
    else
        Respond(P, "Invalid Player ID or Player not Online", 4 + 8, "rcon")
        Respond(P, "Command Usage: " .. Args[1] .. " [number: 1-16] | */all | me", 4 + 8, "rcon")
    end

    return pl
end

local function HandleBoomCommand(Executor, CMD)
    if tag_data then
        local lvl = tonumber(get_var(Executor, "$lvl"))

        if lvl >= permission_level then
            local players = GetPlayers(Executor, CMD)

            if players then
                for _, TargetID in ipairs(players) do
                    if TargetID ~= 0 then
                        ExecuteBoomEffect(Executor, TargetID)
                    else
                        Respond(Executor, "Server cannot be exploded!", 4 + 8, "rcon")
                    end
                end
            end
        else
            Respond(Executor, "You do not have permission to execute this command", 4 + 8, "rcon")
        end
    else
        Respond(Executor, "Internal Map Error. Command Failed", 4 + 8, "rcon")
    end
end

function OnServerCommand(Executor, Command, _, _)
    local CMD = CmdSplit(Command)

    if CMD and CMD[1] then
        CMD[1] = string.lower(CMD[1])

        if CMD[1] == custom_command then
            HandleBoomCommand(Executor, CMD)
            return false
        end
    end
end