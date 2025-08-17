local loot = {}

function loot:monitorLoot(objects)

    local game_started = (self.game and self.game.started)
    local looting = (self.looting and self.looting.enabled)
    if (not game_started or not looting or not objects) then
        return
    end

    for meta_id, v in pairs(objects) do

        local object_memory = get_object_memory(meta_id)
        if (object_memory == 0) then
            if (not v.timer) then
                v.timer = self:new()
                v.timer:start()
            elseif (v.timer:get() >= v.delay) then
                v.timer = nil -- just in case

                local tag = v.tag
                local x, y, z = v.x, v.y, v.z

                local object_meta = self:spawnObject(tag, x, y, z)
                objects[object_meta] = v
                objects[meta_id] = nil
                --else
                --    print('Respawning ' .. v.tag_class .. '/' .. v.tag_name .. ' in ' .. v.delay - v.timer:get() .. ' seconds')
            end
        end
    end
end

return loot