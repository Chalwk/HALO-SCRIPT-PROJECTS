local event = {}

function event:on_object_spawn(player, map_id, parent_id, object_id, sapp_spawning)

    if (not sapp_spawning) then
        -- not currently used
    end

    local dyn = get_dynamic_player(player)
    if (player > 0 and dyn ~= 0) then

        -- Prevent players from using special ammo in vehicles:
        player = self.players[player]
        if (not player) then
            return
        elseif player:inVehicle(dyn) then
            return
        end

        local this_weapon = read_dword(dyn + 0x118)
        local object = get_object_memory(this_weapon)

        local weapon = self:getWeapon(object)
        if (not weapon) then
            return
        elseif (weapon.ammo_type == 3 or weapon.ammo_type == 5) then
            return false, player:createProjectile(dyn, weapon)
        elseif (weapon.ammo_type == 6 and map_id == self.rocket_projectile) then
            destroy_object(weapon.weapon)
            self.nukes[#self.nukes + 1] = {
                meta_id = object_id,
                projectile = self.nuke_projectile
            }
        end
    end
end

local function translate(object, x, y, z)
    write_vector3d(object + 0x5C, x, y, z)
    write_float(object + 0x68, 0) -- x velocity
    write_float(object + 0x6C, 0) -- y velocity
    write_float(object + 0x70, -99999) -- z velocity
end

local function createNuke(total, radius, projectile, cx, cy, cz)

    local angle = 0
    local angle_step = 360 / total

    -- Rockets with no spread but spawn in a circle:
    for _ = 1, total do
        local x = cx + (math.cos(angle) * radius)
        local y = cy + (math.sin(angle) * radius)
        local z = cz
        local proj = spawn_projectile(projectile, 0, x, y, z)
        local object = get_object_memory(proj)
        translate(object, x, y, z)
        angle = angle + angle_step
    end

    --Rockets with random spread:
    for _ = 1, 5 do
        local proj = spawn_projectile(projectile, 0, cx, cy, cz)
        local object = get_object_memory(proj)
        local x = cx + rand(-radius, radius + 1)
        local y = cy + rand(-radius, radius + 1)
        local z = cz
        translate(object, x, y, z)
    end
end

-- called every tick:
function event:trackNuke()

    local nukes = self.nukes
    if (not self.game or not self.game.started or (not nukes or nukes and #nukes == 0)) then
        return
    end

    for k, v in pairs(self.nukes) do
        local object = get_object_memory(v.meta_id)
        if (object == 0) then
            self.nukes[k] = nil
            self:modifyNuke()
            createNuke(10, 1, v.projectile, v.x, v.y, v.z)
            createNuke(10, 10, v.projectile, v.x, v.y, v.z)
            self:rollbackNuke()
            goto next
        end
        v.x, v.y, v.z = read_vector3d(object + 0x5C)
        :: next ::
    end
end

register_callback(cb['EVENT_OBJECT_SPAWN'], 'on_object_spawn')

return event