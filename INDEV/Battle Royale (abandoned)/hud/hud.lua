local hud = {}
local time = os.time
local floor = math.floor
local format = string.format

local function getPrimaryHUD(self, distance)

    distance = floor(distance)
    local size = self.safe_zone.size
    local timer = self.safe_zone.timer

    if (not timer.crunch_time) then
        local shrink = timer:get()
        shrink = floor(self.duration - shrink)
        return format('Safe Zone: %s / %s | Shrink in: %s', distance, size, shrink)
    else
        local time_remaining = self.end_after - timer:get()
        local h, m, s = self:secondsToTime(time_remaining)
        return format('Safe Zone: %s / %s | CRUNCH TIME: %s:%s:%s | NEXT KILL WINS', distance, size, h, m, s)
    end

    return ''
end

function hud:setHUD(HUD, distance)
    if (HUD == 'primary') then
        self.messages.primary = getPrimaryHUD(self, distance)
    elseif (HUD == "warning") then
        self.messages.primary = 'You are outside the safe zone!'
    end
end

function hud:newMessage(content, duration)

    local id = self.id
    duration = duration or 5

    self.messages[#self.messages + 1] = {
        content = content,
        finish = time() + duration,
        stdout = function(message)
            rprint(id, message.content)
        end
    }
end

function hud:displaySecondaryHUD()

    if (not self.game or not self.game.started) then
        return
    end

    self:cls()
    self:say(self.messages.primary)

    for i, v in pairs(self.messages) do
        if (v and v.finish) then
            if (time() >= v.finish) then
                self.messages[i] = nil
            else
                v:stdout()
            end
        end
    end
end

return hud