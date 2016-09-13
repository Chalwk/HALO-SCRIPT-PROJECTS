--[[ 
Document Name: Aim Bot Detection Script
Modified by: «ÖWV»Çhälwk for use by OWV Clan.
Credits to the original creators;

Xfire : Chalwk77
Website: www.owvclan.com

UPDATED: 30/12/2014
Update Reason: Bug Fixes and UI Improvements.
===========================================================================================================================================================================
]]
Max_Score = 50						-- Score needed before action is taken on the player. (recommended it to be between 50 - 100) <<<< DO NOT TOUCH UNLESS YOU KNOW WHAT YOU'RE DOING
Score_Timeout = 3					-- Time needed for a player to loose a specified amount of points. (In seconds)
Points_Reduced = 1					-- Points that will be lost when the timeout has been reached.
Max_Ping = 1000						-- Max Ping the server will monitor to see if a player is Aim Botting.
Warnings_Needed = 1					-- Amount of warnings needed before an action is taken on the palyer.
Default_Action = "notify"			-- Action the server will take by itself if a player is caught aim botting. (default 'notify'). Valid Actions: 'kick', 'ban'.
Default_Ban_Time = 0 				-- How long the player will be banned. 0 = indefinite.
LogWarnings = true					-- Logs snaps and warnings to Aim-Bot Records.log
Notify_Player = false				-- Should the player be notified that they have been suspected of Aim Botting? - (NOT RECOMMENDED)
Notify_Admins = true            	-- Should admins be notified that a player has been suspected of Aim Botting? - (recommended)
Notify_Server = false            	-- Should the server be notified that a player has been suspected of Aim Botting. (Means every paly in the server)
Same_Team_Detection = true         	-- Should it check if players are on he same team? (recommended)
Snap_Maximum_Angle = 180            	-- Max snap angle detectable. (180 degrees - recommended) <<<< DO NOT TOUCH UNLESS YOU KNOW WHAT YOU'RE DOING
Snap_Minimum_Angle = 5					-- Min snap angle detectable. (5 recommended) <<<< DO NOT TOUCH UNLESS YOU KNOW WHAT YOU'RE DOING
Snap_Stop_Angle = 0.42				-- Recommended between 3.5 to 4.5
Degrees_Subtracted = 0.015			-- Degrees removed after the specified Distance_Variables. <<<< DO NOT TOUCH UNLESS YOU KNOW WHAT YOU'RE DOING
Distance_Variables = 4.5				-- Distance needed to subtract the amount of degrees above. <<<< DO NOT TOUCH UNLESS YOU KNOW WHAT YOU'RE DOING
--=========================================================================================================================================================================
--		This is the table of what degree snaps will give the amount of score. 
--		It is used like so...
--				score_snap_angle =  {{Degree, Degree, Score Added},
--				{50, 90, 50}, {90, 120, 60}
--				}

SCORE_SNAP_TABLE =  {
	{4, 8, 10}, {9, 14, 15},
	{15, 20, 17}, {21, 26, 19},
	{25, 32, 21}, {33, 38, 23},
	{39, 44, 25}, {45, 50, 27},
	{51, 56, 29}, {57, 62, 31},
	{63, 68, 33}, {69, 74, 33},
	{75, 80, 27}, {81, 86, 25},
	{85, 92, 23}, {92, 98, 21},
	{99, 180, 19}
}

-- DO NOT TOUCH --
CAMERA_TABLE = {}
MONITOR_TABLE = {}
SNAP_TABLE = {}
WARNING_TABLE = {}
SNAP_TABLE = {}
PLAYER_SCORE = {}
isSpawning = {}
actionTaken = {}
loc = {}

function GetRequiredVersion() return 200 end

--			Called when a player has been suspected of Aim Botting. This is called before the player has been tallied for snapping.
--			The return value determines if the player should be tallied. Returning true tallies the player, returning false doesn't.

function OnAimbotDetection(player)
	return (not isSpawning[player] )
end

function OnScriptLoad(process, game, persistent)
	for i = 0,15 do
		loc[i] = {}
		PLAYER_SCORE[i] = 0
	end
	log_file = getprofilepath() .. "\\logs\\Aim-Bot Records.log"
	registertimer(Score_Timeout * 1000, "ScoreTimeoutTimer", Points_Reduced)
end

function OnServerCommand(player, command, password)
	local timestamp = os.date ("%H:%M:%S: %d/%m/%Y")
	local response = nil
	t = tokenizecmdstring(command)
	count = #t
	if t[1] == "sv_aimbotrecord" then -- For Individule players.
		response = false
		if t[2] and rresolveplayer( t[2] ) then
			local id = rresolveplayer( t[2] )
			sendresponse("-------------------------------------", player)
			sendresponse("   AIM-BOT DETECTION RECORDS", player)
			sendresponse("Viewing Records for: " ..getname(id), player)
			sendresponse("Snaps   |   Angle   |   Date & Time ", player)
			sendresponse("("..PLAYER_SCORE[id]..")                  (" ..tostring(count)..")        " ..timestamp, player)
			sendresponse("<no more records to display>", player)
			sendresponse("-------------------------------------", player)
		else
			sendresponse("Error. You need to specify a player. Use  sv_aimbotrecord [ Player ID ]", player)
		end
	elseif t[1] == "sv_aimbotrecords" then -- For All Players currently in the server.
		response = false
		sendresponse("-------------------------------------", player)
		sendresponse("   AIM-BOT DETECTION RECORDS", player)
		sendresponse("Viewing Records for all players", player)
		sendresponse("Name     |   Snaps     |   Angle     |   Date & Time ", player)
	for i = 0,15 do
		if getplayer(i) then
		sendresponse(getname(i) .. "    (".. PLAYER_SCORE[i]..")             (" ..tostring(count)..")        " ..timestamp, player)
		sendresponse("<no more records to display>", player)
		sendresponse("-------------------------------------", player)
				end
			end
		end
	return response
end

function OnPlayerJoin(player)
	SNAP_TABLE[player] = 0
	WARNING_TABLE[player] = 0
	PLAYER_SCORE[player] = 0
	SNAP_TABLE[player] = {0}
end

function OnPlayerLeave(player)
	CAMERA_TABLE[player] = nil
	MONITOR_TABLE[player] = nil
	SNAP_TABLE[player] = nil
	WARNING_TABLE[player] = nil
	PLAYER_SCORE[player] = 0
	SNAP_TABLE[player] = {0}
end

function OnPlayerKill(killer, victim, mode)
	CAMERA_TABLE[victim] = nil
	MONITOR_TABLE[victim] = nil
	SNAP_TABLE[victim] = 0
end

function OnPlayerSpawn(player)
	CAMERA_TABLE[player] = nil
	MONITOR_TABLE[player] = nil
	SNAP_TABLE[player] = 0
	isSpawning[player] = true
	registertimer(500, "playerIsSpawning", player)
end

function OnPlayerSpawnEnd(player)
	CAMERA_TABLE[player] = nil
	MONITOR_TABLE[player] = nil
	SNAP_TABLE[player] = 0
end

function OnClientUpdate(player)

	local m_objectId = getplayerobjectid( player )
	local m_object = getobject( m_objectId )
	local x,y,z = getobjectcoords( m_objectId )

	local distance
	if x ~= loc[player][1] or y ~= loc[player][2] or z ~= loc[player][3] then
		if loc[player][1] == nil then
			loc[player][1] = x
			loc[player][2] = y
			loc[player][3] = z
		elseif m_object then
			distance = math.sqrt((loc[player][1] - x)^2 + (loc[player][2] - y)^2 + (loc[player][3] - z)^2)
			local result = true
			if distance >= 10 then result = OnPlayerTeleport( player ) end
			if result == 0 or not result then
				movobjectcoords(m_objectId, loc[player][1], loc[player][2], loc[player][3])
			else
				loc[player][1] = x
				loc[player][2] = y
				loc[player][3] = z
			end
		end
	end

	local camera_x = readfloat(m_object + 0x230)
	local camera_y = readfloat(m_object + 0x234)
	local camera_z = readfloat(m_object + 0x238)

	if CAMERA_TABLE[player] == nil then
		CAMERA_TABLE[player] = {camera_x, camera_y, camera_z}
		return
	end

	local last_camera_x = CAMERA_TABLE[player][1]
	local last_camera_y = CAMERA_TABLE[player][2]
	local last_camera_z = CAMERA_TABLE[player][3]

	CAMERA_TABLE[player] = {camera_x, camera_y, camera_z}

	if 	last_camera_x == 0 and
		last_camera_y == 0 and
		last_camera_z == 0 then
		return
	end

	local movement = math.sqrt(
		(camera_x - last_camera_x) ^ 2 +
		(camera_y - last_camera_y) ^ 2 +
		(camera_z - last_camera_z) ^ 2)

	local angle = math.acos((2 - movement ^ 2) / 2)
	angle = angle * 180 / math.pi

	if MONITOR_TABLE[player] ~= nil then
		MONITOR_TABLE[player] = nil
		local value = ( Snap_Stop_Angle - ( Degrees_Subtracted * ( ( distance or 0 ) / Distance_Variables ) ) )
		if angle < value and OnAimbotDetection(player) then
			for i = 0, 15 do
				if IsLookingAt(player, i) then
					TallyPlayer(player)
					break
				end
			end
		end
		return
	end
	if angle > Snap_Minimum_Angle and angle < Snap_Maximum_Angle then
		MONITOR_TABLE[player] = true
		SNAP_TABLE[player] = angle
	end
end

function OnPlayerTeleport( player )
	isSpawning[player] = true
	registertimer(600, "playerIsSpawning", player)
	return true
end

function playerIsSpawning(id, count, player)
	isSpawning[player] = false
	return false
end

function ScoreTimeoutTimer(id, count, score_depletion)
	for i = 0,15 do
		if PLAYER_SCORE[i] and PLAYER_SCORE[i] ~= 0  then
			PLAYER_SCORE[i] = PLAYER_SCORE[i] - score_depletion
			if PLAYER_SCORE[i] <= 0 then
				PLAYER_SCORE[i] = 0
			end
		end
	end
	return true
end

function TallyPlayer(player)
	if getplayer(player) == nil then
		return
	end
	if getping(player) <= Max_Ping then
		for i = 1,#SCORE_SNAP_TABLE do
			if SNAP_TABLE[player] >= SCORE_SNAP_TABLE[i][1] and SNAP_TABLE[player] <= SCORE_SNAP_TABLE[i][2] then
				PLAYER_SCORE[player] = PLAYER_SCORE[player] + SCORE_SNAP_TABLE[i][3]
				--		ABDS: Aim Bot Detection System
				-- hprintf("* * AIM-BOT DETECTION SYSTEM * *\n" ..tostring(getname(player)) .. " has registered a potential snap! Angle: " .. tostring(SCORE_SNAP_TABLE[i][3]) .. ".\n This player is now being monitored by the server.") -- Script was working before this was enabled.
				break
			end
		end
		if PLAYER_SCORE[player] >= Max_Score then
			if WARNING_TABLE[player] == nil then WARNING_TABLE[player] = 0 end
			WARNING_TABLE[player] = WARNING_TABLE[player] + 1
			if WARNING_TABLE[player] >= Warnings_Needed then
				SNAP_TABLE[player][1] = SNAP_TABLE[player][1] + 1
				local count = SNAP_TABLE[player][1]
				if Default_Action == "kick" then
					svcmd("sv_kick " .. resolveplayer(player))
					if Notify_Player then
						privatesay(player, "You have been kicked for Aim Botting.")
					end
					if Notify_Admins then
						for i = 0, 15 do
							if getplayer(i) ~= nil and isadmin(i) then
								privatesay(i, getname(player) .. " was kicked for Aim Botting.")
							end
						end
					end
					if Notify_Server then
						for i = 0, 15 do
							if getplayer(i) ~= nil then
								if not isadmin(i) then
									privatesay(i, getname(player) .. " was kicked for Aim Botting.")
								end
							end
						end
					end
				elseif Default_Action == "notify" then
					if Notify_Player then
						privatesay(player, "You have been suspected of Aim Botting (Count: " .. tostring(count) ..  ")")
					end
					if Notify_Admins then
						for i = 0, 15 do
							if getplayer(i) ~= nil and isadmin(i) then
								privatesay(i, "* * W A R N I N G * * " .. getname(player) .. " has been suspected of Aim Botting! (Registered Snaps: ".. tostring(count) ..")", false)
								-- hprintf("* * W A R N I N G * * " .. getname(player) .. " has been suspected of Aim Botting! (Registered Snaps: ".. tostring(count) .. ")")
							end
						end
					end
					if Notify_Server then
						for i = 0, 15 do
							if getplayer(i) ~= nil then
								if not isadmin(i) then
									privatesay(i, getname(player) .. " is suspected of Aim Botting. (Count: " .. tostring(count) ..  ")")
								end
							end
						end
					end
				elseif Default_Action == "ban" then
					svcmd("sv_ban " .. resolveplayer(player) .. " " .. Default_Ban_Time)
					if Notify_Player then
						privatesay(player, "You have been banned for Aim Botting.")
					end
					if Notify_Admins then
						for i = 0, 15 do
							if getplayer(i) ~= nil and isadmin(i) then
								privatesay(i, getname(player) .. " was banned for Aim Botting.")
							end
						end
					end
					if Notify_Server then
						for i = 0, 15 do
							if getplayer(i) ~= nil then
								if not isadmin(i) then
									privatesay(i, getname(player) .. " was banned for Aim Botting.")
								end
							end
						end
					end
				end
				-- Action Taken --
				PLAYER_SCORE[player] = 0
				if LogWarnings then
					local name = getname(player) or "Unknown"
					local hash = gethash(player) or "Unknown"
					local ip = getip(player) or "Unknown"
					local ping = getping(player) or "Unknown"
					local line = "%s has been suspected of aim botting. (Hash: %s) (IP: %s) (ping: %s)."
					line = string.format(line, name, hash, ip, ping)
					WriteLog(log_file, line)
				end
			end
		end
	end
end

function sayExcept(message, player)
	for i = 0, 15 do
		if i ~= player then
			privatesay(i, message)
		end
	end
end

function getping(player)
	local m_player = getplayer(player)
	if m_player then return readword(m_player + 0xDC) end
end

function IsLookingAt(player1, player2)

	if getplayer(player1) == nil or getplayer(player2) == nil then -- Check if player slots are in use. 0/16
		return
	end

	local m_playerObjId1 = getplayerobjectid( player1 )
	local m_playerObjId2 = getplayerobjectid( player2 )

	if m_playerObjId1 == nil or m_playerObjId2 == nil then -- Checks if players are alive.
		return
	end

	if Same_Team_Detection and getteam( player1 ) == getteam( player2 ) then -- Checks if players are on the same team.
		return false
	end

	local m_object1 = getobject( m_playerObjId1 )
	local m_object2 = getobject( m_playerObjId2 )
	local camera_x = math.round( readfloat(m_object1 + 0x230) , 1)
	local camera_y = math.round( readfloat(m_object1 + 0x234) , 1)
	local camera_z = math.round( readfloat(m_object1 + 0x238) , 1)
	local location1_x = readfloat(m_object1 + 0x5C)
	local location1_y = readfloat(m_object1 + 0x60)
	local location1_z = checkState( readbyte(m_object1 + 0x2A7) , readfloat(m_object1 + 0x64) )
	local location2_x = readfloat(m_object2 + 0x5C)
	local location2_y = readfloat(m_object2 + 0x60)
	local location2_z = checkState( readbyte(m_object2 + 0x2A7) , readfloat(m_object2 + 0x64) )

	if location1_z == nil  or location2_z == nil then
		return
	end

	local local_x = (location2_x - location1_x)
	local local_y = (location2_y - location1_y)
	local local_z = (location2_z - location1_z)

	local radius = math.sqrt( (local_x) ^ 2 + (local_y) ^ 2 + (local_z) ^ 2 )

	local point_x = math.round(1 / radius * local_x, 1)
	local point_y = math.round(1 / radius * local_y, 1)
	local point_z = math.round(1 / radius * local_z, 1)

	local isLookingAt = (camera_x == point_x and camera_y == point_y and camera_z == point_z)
	return isLookingAt

end

function checkState(state, location_z)
	if state == 2 then
		return location_z + 0.6
	elseif state == 3 then
		return location_z + 0.3
	end
	return nil
end

function sendresponse(message, player)
	if player then
		sendconsoletext(player, message)
	else
		-- hprintf(message)
	end
end

function math.round(number, place)
	return math.floor(number * ( 10 ^ (place or 0) ) + 0.5) / ( 10 ^ (place or 0) )
end

function WriteLog(filename, value)
	local file = io.open(filename, "a")
	if file then
		file:write( string.format("%s\t%s\n", os.date("!%m/%d/%Y %H:%M:%S"), tostring(value) ) )
		file:close()
	end
end