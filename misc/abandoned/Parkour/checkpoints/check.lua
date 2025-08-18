local checkpoint = {}

local distanceThreshold = 1

function checkpoint:isNearCheckpoint(dyn)

    --if not self.timer.start_time or not checkpoints then
    --    return
    --    return
    --end

    local checkpoints = self[self.map].checkpoints
    local checkpointTable = checkpoints[self.checkpointIndex]
    if not checkpointTable then
        return false
    end

    local cx, cy, cz = checkpointTable[1], checkpointTable[2], checkpointTable[3]
    local playerPosition = self:getPlayerPosition(dyn)
    local px, py, pz = playerPosition.x, playerPosition.y, playerPosition.z

    local distance = self:calculateDistance(px, py, pz, cx, cy, cz)
    return distance <= distanceThreshold
end

return checkpoint