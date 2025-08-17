local crates = {}

function crates:crateIntersect()

    if (not self.looting.enabled or not self.loot.crates) then
        return
    end

    local dyn = get_dynamic_player(self.id)
    if (dyn == 0 or not player_alive(self.id)) then
        return
    end

    local px, py, pz = self:getXYZ(dyn)

    for meta_id, v in pairs(self.loot.crates) do

        local object = get_object_memory(meta_id)
        if (object == 0) then
            goto next
        end

        local ox, oy, oz = v.x, v.y, v.z
        local distance = self:getDistance(px, py, pz, ox, oy, oz)
        if (distance <= 1) then
            destroy_object(meta_id)
            self:openCrate()
        end
        :: next ::
    end
end

-- Get a random spoil:
-- @t: table (self.looting.spoils)
local function getSpoils(t)

    local total = 0
    for k, _ in pairs(t) do
        total = total + k
    end

    local index = 0
    local random = rand(1, total + 1)

    for k, v in pairs(t) do
        index = index + k
        if (random <= index) then
            return v
        end
    end
end

function crates:openCrate()

    local spoils = getSpoils(self.looting.spoils)

    if (not spoils) then
        self:newMessage('Something went wrong. Unable to unlock spoils.', 5)
        return
    end

    local f = spoils._function_
    if (not self[f]) then
        error('Unable to execute function "' .. f .. '", not found.')
        return
    end

    local success = self[f](self, spoils)
    if (not success) then
        self:newMessage('Something went wrong. Unable to unlock spoils.')
    end
end

return crates