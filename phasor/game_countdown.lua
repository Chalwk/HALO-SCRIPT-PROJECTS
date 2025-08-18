-- Name: game_countdown.lua
-- Copyright (c) 2016-2018 Jericho Crosby (Chalwk)

-- Settings
game_started = false

function OnScriptUnload()

end

function ScriptLoad()

end

function GetRequiredVersion()
    return
    200
end

function OnNewGame(map)
    CountDown = registertimer(1000, "NewGameTimer")
end

function OnGameEnd(stage)
    if stage == 1 then
        if CountDown then
            CountDown = nil
        end
    end
end

function NewGameTimer(id, count)
    if count == 6 then
        say("Begin!")
        game_started = true
        return false
    else
        say("The game will start in: " .. 6 - count)
        return true
    end
end