local intersect = {}

function intersect:hasCrossedStartLine(dyn)
    local start = self.start_line
    local pointA = { x = start[1].x, y = start[1].y, z = start[1].z }
    local pointB = { x = start[2].x, y = start[2].y, z = start[2].z }
    return intersect:hasIntersected(pointA, pointB, dyn)
end

function intersect:hasCrossedFinishLine(dyn)
    local finish = self.finish_line
    local pointA = { x = finish[1].x, y = finish[1].y, z = finish[1].z }
    local pointB = { x = finish[2].x, y = finish[2].y, z = finish[2].z }
    return intersect:hasIntersected(pointA, pointB, dyn)
end

function intersect:hasIntersected(pointA, pointB, dyn)

    local distanceThreshold = 1
    local playerPosition = self:getPlayerPosition(dyn)
    local x1, y1, z1 = pointA.x, pointA.y, pointA.z
    local x2, y2, z2 = pointB.x, pointB.y, pointB.z
    local px, py, pz = playerPosition.x, playerPosition.y, playerPosition.z

    local vectorA = { x = x2 - x1, y = y2 - y1, z = z2 - z1 }
    local vectorB = { x = px - x1, y = py - y1, z = pz - z1 }

    local crossProduct = {
        x = vectorA.y * vectorB.z - vectorA.z * vectorB.y,
        y = vectorA.z * vectorB.x - vectorA.x * vectorB.z,
        z = vectorA.x * vectorB.y - vectorA.y * vectorB.x
    }

    return crossProduct.x * crossProduct.x + crossProduct.y * crossProduct.y + crossProduct.z * crossProduct.z <= distanceThreshold
end

return intersect