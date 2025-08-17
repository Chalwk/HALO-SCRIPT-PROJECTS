-- Snipers Dream Team Mod [Entry Point File] (v1.0)
-- Copyright (c) 2022, Jericho Crosby <jericho.crosby227@gmail.com>

api_version = "1.12.0.0"

local SDTM = {
    players = {},
    dependencies = {
        ['./SDTM/'] = { 'settings' },
        ['./SDTM/Dependencies/'] = {
            'Portals',
            'Edit Tags',
            'Tea Bagging',
            'Vehicle Spawner',
            'Other Components'
        }
    }
}

-- Loads file dependencies:
-- All files inherit the SDTM object.
function SDTM:LoadDependencies()
    local table = self
    for path, t in pairs(self.dependencies) do
        for _, file in pairs(t) do
            local f = loadfile(path .. file .. '.lua')()
            setmetatable(table, { __index = f })
            table = f
        end
    end
end

-- Called when a new game has started.
-- Loads dependency functions and sets up player tables.
function SDTM:OnStart()

    self.players = {}
    self.map = get_var(0, '$map')
    self.mode = get_var(0, '$mode')

    self:Edit() -- buff map tags                    [Edit Tags]
    self:GetJPTTags() -- does things                [Other Components]
    self:LoadPortals() -- load map portals          [Portals]
    self:LoadVehicles() -- load map vehicles        [Vehicle Spawner]

    if (self.globals) then
        local red_flag = read_dword(self.globals + 0x8)
        local blue_flag = read_dword(self.globals + 0xC)
        self.red_flag, self.blue_flag = red_flag, blue_flag
    end

    for i = 1, 16 do
        if player_present(i) then
            OnJoin(i)
        end
    end
end

-- New Player has joined:
-- * Creates a new player table; Inherits the SDTM parent object.
-- @Param o (player table [table])
-- @Return o (player table [table])
function SDTM:NewPlayer(o)

    setmetatable(o, self)
    self.__index = self

    -- Tea Bagging variables:
    --
    -- victim location coordinates:
    o.loc = {}

    -- player crouch count:
    o.count = 0

    -- player crouch state:
    o.state = 0

    return o
end

-- Returns player map coordinates:
-- @Param dyn (player memory address)  [number]
-- @return x,y,z [32-bit floating point numbers]
--
function SDTM:GetPos(dyn)
    local x, y, z
    local vehicle = read_dword(dyn + 0x11C)
    local object = get_object_memory(vehicle)
    if (vehicle == 0xFFFFFFFF) then
        -- not in a vehicle --
        x, y, z = read_vector3d(dyn + 0x5C)
    elseif (object ~= 0) then
        -- in a vehicle --
        x, y, z = read_vector3d(object + 0x5C)
    end
    return x, y, z
end

-- Returns the MetaID of the tag address:
-- @Param Type (tag class)
-- @Param Name (tag path)
-- @Return tag address [number]
function SDTM:GetTag(Type, Name)
    local Tag = lookup_tag(Type, Name)
    return Tag ~= 0 and read_dword(Tag + 0xC) or nil
end

-- Distance function using pythagoras theorem:
-- @Param x1, y1, z1 (origin x,y,z)  [floating point numbers]
-- @Param x2, y2, z2 (current x,y,z) [floating point numbers]
-- @return Sqrt of (x1-x2)*2+(y1-y2)*2+(z1-z2)*2
--
local sqrt = math.sqrt
function SDTM:GetDist(x1, y1, z1, x2, y2, z2)
    return sqrt((x1 - x2) ^ 2 + (y1 - y2) ^ 2 + (z1 - z2) ^ 2)
end

-- Broadcast Function:
-- @Param msg (message) [string]
-- Temporarily removes the server prefix and replaces it when the relay is done.
--
function SDTM:Broadcast(msg)
    execute_command('msg_prefix ""')
    say_all(msg)
    execute_command('msg_prefix "' .. self.server_prefix .. '"')
end

-- Broadcast Function:
-- @Param msg (message) [string]
-- Temporarily removes the server prefix and replaces it when the relay is done.
--
function SDTM:Send(msg)
    rprint(self.pid, msg)
end

-- Called when a new game has started.
function OnStart()
    if (get_var(0, '$gt') ~= 'n/a') then
        SDTM:OnStart()
    end
end

-- Called every 1/30th second:
-- * Checks if a player is near a portal and teleports them.
-- * Checks if a player is tea bagging someone.
-- * Respawns map vehicles.
function OnTick()
    SDTM:PortalCheck()
    SDTM:TeaBagging()
    SDTM:RespawnVehicle()
end

-- Called when a player has died:
-- * Saves the victims map coordinates.
-- @Param V (victim id) [number]
-- @Param K (killer id) [number]
function OnDeath(V, K)
    SDTM:SaveLoc(V, K)
end

-- Called when a player receives damage:
-- Prevents a player from killing themselves with the sniper.
-- @Param V (victim id) [number]
-- @Param K (killer id) [number]
-- @Param M (DamageTagID) [number]
function OnDamage(V, K, M)
    return SDTM:BlockDamage(V, K, M)
end

-- Called when a player picks up a weapon:
-- @Param P (player id) [number]
-- @Param W (weapon id) [number]
-- @Param T (weapon type) [number]
function OnPickup(P, W, T)
    SDTM:OnPickup(P, W, T)
end

-- Called when a player has finished connecting:
-- @Param P (player id) [number]
function OnJoin(P)
    local name = get_var(P, '$name')
    SDTM.players[P] = SDTM:NewPlayer({
        pid = P,
        name = name
    })
end

-- Called when a player has finished respawning:
-- * Resets the crouch count (used by tea bag feature).
-- @Param P (player id) [number]
function OnSpawn(P)
    SDTM.players[P].count = 0
end

-- Called when a player has quit:
-- * Nullifies the table for this player.
-- @Param P (player id) [number]
function OnQuit(P)
    SDTM.players[P] = nil
end

-- Registers needed event callbacks for SAPP:
function OnScriptLoad()

    SDTM:LoadDependencies()

    register_callback(cb['EVENT_DIE'], 'OnDeath')
    register_callback(cb['EVENT_TICK'], 'OnTick')
    register_callback(cb['EVENT_JOIN'], 'OnJoin')
    register_callback(cb['EVENT_LEAVE'], 'OnQuit')
    register_callback(cb['EVENT_GAME_START'], 'OnStart')
    register_callback(cb['EVENT_DAMAGE_APPLICATION'], 'OnDamage')
end

function OnScriptUnload()
    -- N/A
end