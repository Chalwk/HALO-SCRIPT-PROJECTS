local event = {}

-- [!] This is not currently being used:
local function UpdateVectors(object, x, y, z)

    object = get_object_memory(object)
    if (object == 0) then
        return
    end

    -- update x,y,z coordinates:
    write_float(object + 0x5C, x)
    write_float(object + 0x60, y)
    write_float(object + 0x64, z)

    -- update velocities:
    write_float(object + 0x68, 0) -- x vel
    write_float(object + 0x6C, 0) -- y vel
    write_float(object + 0x70, 0) -- z vel

    -- update yaw, pitch, roll
    write_float(object + 0x90, 0) -- yaw
    write_float(object + 0x8C, 0) -- pitch
    write_float(object + 0x94, 0) -- roll
end

function event:on_tick()

    self:preGameTimer() -- pre-game timer
    self:landing() -- sky spawning / god mode timer
    self:outsideSafeZone() -- checks if player is outside the safe zone
    self:shrinkSafeZone() -- safe zone shrinking
    self:monitorLoot(self.loot.crates) -- loot crate monitor
    self:monitorLoot(self.loot.random) -- loot crate monitor

    self:trackNuke() -- nuke projectile tracker

    for _, v in pairs(self.players) do

        --
        -- warning: The order of these functions is important.
        --

        v:crateIntersect()

        --[[
        -- todo:    Move speed modifiers to a separate recursive function that is delayed by 1 second.
        -- todo:    This is to prevent micro-stuttering when modifying a players speed.
        ]]

        if (v.stun) then
            v:stunPlayer()
        else
            v:setSpeed()
        end

        v:spectate()
        v:newWeapon()
        v:customAmmo()
        v:degrade()
        v:displaySecondaryHUD()
    end

    --for object, v in pairs(self.barrier) do
    --    UpdateVectors(object, v.x, v.y, v.z)
    --end
end

register_callback(cb['EVENT_TICK'], 'on_tick')

return event