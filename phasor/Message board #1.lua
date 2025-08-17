--[[
------------------------------------
Script Name: HPC MessageBoard V2, for PhasorV2+

Copyright � 2016 Jericho Crosby <jericho.crosby227@gmail.com>
Notice: You can use this script subject to the following conditions:
https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE

* IGN: Chalwk
-----------------------------------
]]--


One = 5
Two = 10
Three = 15
Four = 20
Five = 25
Six = 30
Seven = 35
Eight = 40
Nine = 45
Ten = 50

Msg_1 = " Message One"
Msg_2 = " Message Two"
Msg_3 = " Message Three"
Msg_4 = " Message Four"
Msg_5 = " Message Five"
Msg_6 = " Message Six"
Msg_7 = " Message Seven"
Msg_8 = " Message Eight"
Msg_9 = " Message Nine"
Msg_10 = " Message Ten"

function GetRequiredVersion()
    return 200
end
function OnScriptLoad(processid, game, persistent)
end
function OnScriptUnload()
end

function OnNewGame(map)
    registertimer(One * 1000, "AutoOne")
    registertimer(Two * 1000, "AutoTwo")
    registertimer(Three * 1000, "AutoThree")
    registertimer(Four * 1000, "AutoFour")
    registertimer(Five * 1000, "AutoFive")
    registertimer(Six * 1000, "AutoSix")
    registertimer(Seven * 1000, "AutoSeven")
    registertimer(Eight * 1000, "AutoEight")
    registertimer(Nine * 1000, "AutoNine")
    registertimer(Ten * 1000, "AutoTen")
end

function OnGameEnd(stage)
    removetimer(One)
    removetimer(Two)
    removetimer(Three)
    removetimer(Four)
    removetimer(Five)
    removetimer(Six)
    removetimer(Seven)
    removetimer(Eight)
    removetimer(Nine)
    removetimer(Ten)
end

function AutoOne(id, count)
    say(Msg_1, false)
    hprintf(Msg_1)
    return 1
end

function AutoTwo(id, count)
    say(Msg_2, false)
    hprintf(Msg_2)
    return 1
end