--[[
    ------------------------------------
    Description: HPC OnGameEnd (Messages), Phasor V2+
    Copyright (c) 2016-2018
    * Author: Jericho Crosby
    * IGN: Chalwk
    * Written and Created by Jericho Crosby
    Script Version: 2.5
    -----------------------------------
]]--
function OnGameEnd(stage)
    -- 	stage 1: F1 Screen
    -- 	stage 2: PGCR Appears
    -- 	stage 3: Players may quit
    if stage == 2 then
        for i = 0, 15 do
            if readword(getplayer(i) + 0x9C) == 0 then
                privatesay(i, "You have no kills... noob alert!")
            end
            if readword(getplayer(i) + 0x9C) == 1 then
                privatesay(i, "One kill? You must be new at this...")
            end
            if readword(getplayer(i) + 0x9C) == 2 then
                privatesay(i, "Eh, two kills... not bad. But you still suck.")
            end
            if readword(getplayer(i) + 0x9C) == 3 then
                privatesay(i, "Relax sonny! 3 kills, and you be like... mad bro?")
            end
            if readword(getplayer(i) + 0x9C) == 4 then
                privatesay(i, "Dun dun dun... them 4 kills though!")
            end
            if readword(getplayer(i) + 0x9C) > 4 then
                privatesay(i, "Well, you've got more than 4 kills... #AchievingTheImpossible")
            end
        end
    end
end