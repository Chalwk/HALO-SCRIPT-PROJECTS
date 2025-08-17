-- Snipers Dream Team Mod [Tea Bagging File] (v1.0)
-- Copyright (c) 2022, Jericho Crosby <jericho.crosby227@gmail.com>

local SDTM = {}
local time = os.time

-- Check if player is crouching over a players body:
-- * Sends teabag message
-- @Param dyn (memory address of player)
-- @Param v (player table of the victim)
function SDTM:Crouching(dyn, v)
    local crouch = read_bit(dyn + 0x208, 0)
    local crouch_count = self.t_bag_crouch_count
    if (crouch ~= self.state and crouch == 1) then
        self.count = self.count + 1
    elseif (self.count >= crouch_count) then
        local msg = self.t_bag_message
        msg = msg:gsub('$name', self.name):gsub('$victim', v.name)
        v.loc[self.pid], self.count = nil, 0
        self:Broadcast(msg)
    end
    self.state = crouch
end

-- Check if player is within self.t_bag_radius w/units of a victim's corpse:
-- @Param v (player table of the victim)
function SDTM:Check(v)
    local dyn = get_dynamic_player(self.pid)
    for id, pos in pairs(v.loc) do
        if (time() >= pos.finish) then
            v.loc[id] = nil
        elseif player_alive(self.pid) then
            local r = self.t_bag_radius
            local x1, y1, z1 = pos.x, pos.y, pos.z -- victim pos
            local x2, y2, z2 = self:GetPos(dyn) -- player pos
            if (x2 and self:GetDist(x1, y1, z1, x2, y2, z2) <= r) then
                self:Crouching(dyn, v)
            end
        end
    end
end

-- Loop through all players and see if they are tea bagging anyone:
function SDTM:TeaBagging()
    for i, k in pairs(self.players) do
        for j, v in pairs(self.players) do
            if (i ~= j and #v.loc > 0) then
                k:Check(v)
            end
        end
    end
end

-- Save the death location coordinates of the person who just died:
-- @Param Victim (victim id)
-- @Param Killer  (killer id)
function SDTM:SaveLoc(Victim, Killer)

    local victim = tonumber(Victim)
    local killer = tonumber(Killer)

    if (killer > 0 and killer ~= victim) then
        local v = self.players[victim]
        local dyn = get_dynamic_player(victim)

        -- save their map coordinates:
        if (v and dyn ~= 0) then
            local x, y, z = v:GetPos(dyn)
            v.loc[#v.loc + 1] = {
                x = x, y = y, z = z,
                finish = time() + v.t_bag_expiration
            }
        end
    end
end

return SDTM