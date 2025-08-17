local event = {}

function event:on_unload()
    self:unregisterLevelVariable()
end

return event