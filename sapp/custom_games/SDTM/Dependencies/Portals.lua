-- Snipers Dream Team Mod [Portals File] (v1.0)
-- Copyright (c) 2022, Jericho Crosby <jericho.crosby227@gmail.com>

local SDTM = {}

-- Called when a new game has started:
-- Loops through portals table: SDTM[map][portals]
-- Sets self.portals to the portal table.
function SDTM:LoadPortals()
    local map = self.map
    map = self[map]
    if (map and map.portals and #map.portals > 0) then
        self.portals = (map.portals) or nil
    end
end

-- Make sure player is present, alive and isn't in a vehicle:
-- @Param Ply (player id)
-- @Return dyn (player memory address) or nil
local function CanTeleport(Ply)
    if (Ply and player_present(Ply) and player_alive(Ply)) then
        local dyn = get_dynamic_player(Ply)
        if (dyn ~= 0 and (read_dword(dyn + 0x11C) == 0xFFFFFFFF)) then
            return dyn
        end
    end
    return nil
end

-- Called every 1/30th second.
-- * Checks if a player is near a portal and teleports them.
function SDTM:PortalCheck()
    if (self.portals) then
        for i, v in pairs(self.players) do
            local dyn = CanTeleport(i)
            if (dyn) then

                -- Get their map coordinates:
                local x, y, z = self:GetPos(dyn)

                -- Loop through all custom portals:
                for _, b in pairs(self.portals) do

                    -- extra height above ground at destination z-coord:
                    local z_off = 0.1

                    -- origin x,y,z:
                    local ox, oy, oz = b[1], b[2], b[3]

                    -- origin trigger radius:
                    local trigger_distance = b[4]

                    -- Check distance between player and origin portal:
                    if v:GetDist(x, y, z, ox, oy, oz) <= trigger_distance then

                        -- destination x,y,z,r:
                        local dx, dy, dz, dr = b[5], b[6], b[7], b[8]

                        -- Update player vector position:
                        write_vector3d(dyn + 0x5C, dx, dy, dz + z_off)

                        -- Update player rotation (I don't think this works unless the player is pre-spawning):
                        -- But it's here because reasons...
                        write_vector3d(dyn + 0x74, math.cos(dr), math.sin(dr), 0)

                        -- Send whoosh message:
                        v:Send('Whoosh!')

                        --cprint(dx .. ', ' .. dy .. ', ' .. dz .. ', ' .. dr)

                        -- don't break here, skip to next player:
                        goto next
                    end
                end
            end
            :: next ::
        end
    end
end

return SDTM
