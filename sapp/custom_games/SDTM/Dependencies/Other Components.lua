-- Snipers Dream Team Mod [Other Components File] (v1.0)
-- Copyright (c) 2022, Jericho Crosby <jericho.crosby227@gmail.com>

-- This file is incomplete and will be expanded quite a bit in a future update.

local SDTM = {

    -- Prevent suicide from these damage tags:
    --
    damage_tags = {
        ['jpt!'] = 'vehicles\\scorpion\\shell explosion',

        -- more tags may be added in the future
    }
}

function SDTM:GetJPTTags()
    local t = {}
    self.jpt_tags = nil
    for k, v in pairs(self.damage_tags) do
        local tag = self:GetTag(k, v)
        if (tag) then
            t[tag] = true
        end
    end
    self.jpt_tags = t
end

-- Prevent players from killing themselves with the sniper rifle:
-- @Param Victim (victim id)
-- @Param Killer (killer id)
-- @Param MapID (damage tag address id) [number]
-- @Return [boolean]
function SDTM:BlockDamage(Victim, Killer, MapID)
    local victim = tonumber(Victim)
    local killer = tonumber(Killer)
    if (victim == killer and self.jpt_tags[MapID]) then
        return false
    end
    return true
end

return SDTM