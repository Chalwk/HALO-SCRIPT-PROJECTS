local event = {}

function event:on_tick()

    if not self[self.map] then
        return
    end

    for playerId, data in ipairs(self.players) do
        if data:isValidPlayer() then
            local dyn = get_dynamic_player(playerId)
            if data:hasCrossedStartLine(dyn) and not data.timer then
                data.timer:start()
            elseif data.timer and data:isNearCheckpoint(dyn) then
                data:advanceCheckpoint()
            elseif data:hasCrossedFinishLine(dyn) then
                data.timer:stop()
                data:saveStats()
            end
        end
    end

    self:createAnchor()
end

register_callback(cb['EVENT_TICK'], 'on_tick')

return event