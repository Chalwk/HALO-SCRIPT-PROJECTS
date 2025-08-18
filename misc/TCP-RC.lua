-- SERVER PORT --
Server_Port = 2310

-- Counts --
First_Timer = 700
Server_Refresh = 1000 -- 1000 MilliSeconds. Rate in (MilliSeconds) to check for new Clients.
Client_Refresh = 10 -- Rate in (Seconds) to check for new Messages.
Client_Timeout = 30 -- Time in (Seconds) that users have to log in.
SpawnKill_Deaths = 5
math.inf = 1 / 0

-- Strings --
socket = require("socket")
User_File = "RC Admins.txt"

-- Booleans --
Enable_Logging = true
Status_Timer = nil
RC_Name = nil
Persistent = nil
server = nil
Team_Play = true 

-- Tables --
Red_Spawn_Coords = {}
Blue_Spawn_Coords = {}
Last_Damage = {} -- Death Messages Script
Team_Change = {} -- Death Messages Script
CTF_Flag = {} -- OnPlayerScore Script
Scores = {} -- OnPlayerScore Script
Kills = {} -- DeathMessages Script
Consecutive_Deaths = {} -- Spawn Protection Script
User_Table = {}
Client_Table = {}
commands_table = {
	"/pl",
}

function GetRequiredVersion() return 200 end
function OnScriptLoad(processid, game, persistent)
	gametype_game = readbyte(0x671340 + 0x30)
    team_play = readbyte(0x671340 + 0x34) 
	Persistent = persistent
	if game == "PC" then
		header = 0x614B4C
	elseif game == "CE" then
		header = 0x598A8C
	end
	-- Spawns Script Start
	---------------------------------------------
	if game == true or game == "PC" then
		GAME = "PC"
		map_name = readstring(0x698F21)
		gametype_base = 0x671340
	else
		GAME = "CE"
		map_name = readstring(0x61D151)
		gametype_base = 0x5F5498
	end
	-- Spawns Script End
	---------------------------------------------
	local file = io.open(getprofilepath() .. "//" .. User_File)
	if file then
		for line in file:lines() do
			local data = tokenizestring(line, ",")
			local name = data[1]
			local password = data[2]
			local level = tonumber(data[3])
			table.insert(User_Table, {name = name, password = password, level = level})
		end
		file:close()
	end

	server = socket.tcp()
	server:bind("*", Server_Port)
	server:listen()
	server:settimeout(0)
	registertimer(Server_Refresh, "ServerTimer")
	Status_Timer = registertimer(5000, "StatusTimer") -- 15000 (15 seconds)
-------------------------------- DEATH MESSAGES --------------------------------
		for i = 0, 15 do
		if getplayer(i) then
			Team_Change[i] = false
		end	
	end
	Last_Damage = {}
	Team_Change = {}	
-------------------------------- DEATH MESSAGES -------------------------------- 
	Team_Play = GetTeamPlay()
	LoadCoords()
end

function OnScriptUnload()
	for id, client in pairs(Client_Table) do
		client["socket"]:send(client["buffer"])
		client["socket"]:close()
		Client_Table[id] = nil
	end
	if server ~= nil then
		server:close()
		server = nil
	end
end


function OnPlayerSpawn(player, m_objectId)

	if Team_Play then
		local team = getteam(player)
		local m_object = getobject(m_objectId)
		
		if team == 0 then
			local redcoord = RedSpawnPoints()
			if redcoord then
				local name = getname(player)
				SendRCMessage("")
				SendRCMessage(name .. " has spawned!") -- Debugging.
				local fx, fy, fz = getobjectcoords(red_rot)
				local px, py, pz = getobjectcoords(m_objectId)
				local vx = fx - px
				local vy = fy - py
				local vz = fz - pz
				local magnitude = math.sqrt(vx*vx + vy*vy + vz*vz)
				vx = vx / magnitude
				vy = vy / magnitude
				vz = vz / magnitude		
				writefloat(m_object + 0x74, vx)
				writefloat(m_object + 0x78, vy)
				writefloat(m_object + 0x7c, vz)			
			end
			
		elseif team == 1 then
			local blucoord = BlueSpawnPoints()
			if blucoord then		
				local name = getname(player)
				SendRCMessage("")
				SendRCMessage(name .. " has spawned!") -- Debugging.
				local fx, fy, fz = getobjectcoords(blue_rot)
				local px, py, pz = getobjectcoords(m_objectId)
				local vx = fx - px
				local vy = fy - py
				local vz = fz - pz
				local magnitude = math.sqrt(vx*vx + vy*vy + vz*vz)
				vx = vx / magnitude
				vy = vy / magnitude
				vz = vz / magnitude		
				writefloat(m_object + 0x74, vx)
				writefloat(m_object + 0x78, vy)
				writefloat(m_object + 0x7c, vz)					
			end
		end
		
	end			
end

function RedSpawnPoints(arg)
	local redspawncount = #Red_Spawn_Coords
	if redspawncount > 0 then
		return getrandomnumber(1, redspawncount+1)
	end
	return nil	
end

function BlueSpawnPoints(arg)
	local bluspawncount = #Blue_Spawn_Coords
	if bluspawncount > 0 then
		return getrandomnumber(1, bluspawncount+1)
	end
	return nil	
end

function LoadCoords()
	if map_name == "bloodgulch" then
					-- RED BEGIN --		
		Red_Spawn_Coords[1] = {0}
						-- RED END --
		------------------------------------------------
						-- BLUE BEGIN --
		------------------------------------------------
		Blue_Spawn_Coords[1] = {0}
	end
end


function OnVehicleEntry(player, veh_id, seat, mapid, relevant)
	local timestamp = os.date ("%H:%M:%S     ") -- Displays the Time
	local name = getname(player) -- Retrieves Player Name
	if mapid == ghost_mapId then -- // Ghost
		vehicle_name = "Ghost"
		if seat == (0) then -- Drivers Seat
			seat_name = "Drivers"
		end

elseif mapid == hog_mapId then -- // Warthog
		vehicle_name = "Warthog"
		if seat == (0) then -- Drivers Seat
			seat_name = "Drivers"
		elseif seat == (1) then -- Passengers Seat
			seat_name = "Passengers"
		elseif seat == (2) then -- Gunners Seat
			seat_name = "Gunners"
		end

elseif mapid == tank_mapId then -- // Scorpion Tank
		vehicle_name = "Scorpion Tank"
		if seat == (0) then -- Drivers Seat
			seat_name = "Drivers"
		elseif seat == (1) then -- Passengers Seat
			seat_name = "Passengers"
		elseif seat == (2) then -- Passengers Seat
			seat_name = "Passengers" 
		elseif seat == (3) then -- Passengers Seat
			seat_name = "Passengers"
		elseif seat == (4) then -- Passengers Seat
			seat_name = "Passengers"
		end

elseif mapid == banshee_mapId then -- // Banshee
		vehicle_name = "Banshee"
		if seat == (0) then  -- Pilots Seat
			seat_name = "Piolts"
		end	

elseif mapid == turret_mapId then -- // Covenant Turret
		vehicle_name = "Covenant Turret"
		if seat == (0) then -- Drivers Seat
			seat_name = "Controllers"
		end	

elseif mapid == rhog_mapId then -- // Rocket Hog
		vehicle_name = "Rocket hog"
		if seat == (0) then -- Drivers Seat
			seat_name = "Drivers"
		elseif seat == (1) then -- Passengers Seat
			seat_name = "Passengers"
		elseif seat == (2) then -- Gunners Seat
			seat_name = "Gunners"
		end
	end
	SendRCMessage(timestamp .. "          V E H I C L E   E N T R Y")
	SendRCMessage(tostring(name) .. " entered the " .. tostring(seat_name) .. " Seat of a " .. tostring(vehicle_name) .. ".")
		local m_playerObjId = getplayerobjectid(player)
			if m_playerObjId then
				if isinvehicle(player) then
					local m_vehicleId = readdword(getobject(m_playerObjId) + 0x11C)
                     m_objectId = m_vehicleId
					elseif m_playerObjId then
                     m_objectId = m_playerObjId
				end
             if m_objectId then
         local x,y,z = getobjectcoords(m_objectId) -- Retrieves Player Coordinates
		 SendRCMessage("Coodrinates: X: " .. x .. " Y: " .. y .. " Z: " .. z) -- Returns Player Coordinates
			end    
        end
     return true
end
--[[
function Command_Players(executor, command, count, admin)
	if count == 1 then
		local timestamp = os.date ("%H:%M:%S     ") -- Displays the Time
        local name
        if admin ~= nil then
                if getplayer(admin) then
                        name = getname(admin)
                end
        else
                if RC_Name ~= nil then
                        name = RC_Name .. " (RC) "
                else
                        name = " Master Server"
                end
        end
		SendRCMessage("Executing \"" .. command .. "\" from " .. name)
		SendRCMessage("Player Search:", command , executor)
		SendRCMessage("[ ID.    -    Name.    -    Team.    -    IP.    -    Ping. ]", command , executor)
		for i = 0,15 do
			if getplayer(i) then
				local name = getname(i)
				local id = resolveplayer(i)
				local player_team = getteam(i)
				local port = getport(i)
				local ip = getip(i)
				local hash = gethash(i)
				local ping = readword(getplayer(i) + 0xDC) 
                if team_play then
    				if player_team == 0 then
    					player_team = "Red Team"
    				elseif player_team == 1 then
    					player_team = "Blue Team"
    				else
    					player_team = "Hidden"
    				end
                else
                    player_team = "FFA"
                end
				SendRCMessage(" (".. id ..")  " .. name .. "   |   " .. player_team .. "  -  (IP: ".. ip ..")  -  (Ping: "..ping..")", command, executor)
			end
		end
	else
		SendRCMessage("Error 001: Invalid Syntax: " .. command, command, executor)
	end
		RC_Name = nil
	return true
end

--]]	

function OnServerCommand(admin, command)
--[[
-------------------------------------------------------------------
-- \pl Command
    local response = nil
	local temp = tokenizecmdstring(command)
	local cmd = temp[1]
	if admin and cmd ~= "cls" then
		if "sv_" ~= string.sub(cmd, 0,3) then
			command = "sv_" .. command
		end
	end
	t = tokenizecmdstring(command)
	count = #t
	if t[1] == "sv_players" or t[1] == "sv_pl" then
		response = false
		Command_Players(admin, t[1], count)
end
-------------------------------------------------------------------
]]
		local timestamp = os.date ("%H:%M:%S     ")
        local name
        if admin ~= nil then -- Access
                if getplayer(admin) then
                        name = getname(admin)
                end
        else
                if RC_Name ~= nil then
                        name = RC_Name .. " (RC) "
                else
                        name = " Master Server"
                end
        end
			 hprintf("* Executing \"" .. command .. "\" from " .. name)
			 SendRCMessage("Executing \"" .. command .. "\" from " .. name)
			 SendRCMessage("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
			log("Executing \"" .. command .. "\" from " .. name)
 
        local args = tokenizecmdstring(command)
        if string.lower(args[1]) == "sv_add_user" then
                sv_add_user(admin, args)
                return false
        elseif string.lower(args[1]) == "sv_delete_user" then
                sv_delete_user(admin, args)
                return false
        elseif string.lower(args[1]) == "sv_user_list" then
                sv_user_list(admin, args)
                return false
        elseif string.lower(args[1]) == "sv_cur_users" then
                sv_cur_users(admin, args)
                return false
        end
        RC_Name = nil
        return true
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- On Player Score wont work if the script is " Persistent ".
function OnPlayerScore(player, score, gametype) end
function OnClientUpdate(player)
local timestamp = os.date ("%H:%M:%S     ")
local name = getname(player)
local player_team = getteam(player)
    if team_play then
    	if player_team == 0 then
			player_team = "the Red Team."
	elseif player_team == 1 then
			player_team = "the Blue Team."
	else
			player_team = "Hidden"
		end
	else
		player_team = "FFA"
	end
	if gethash(player) then
local score = getscore(player)
		if score > Scores[gethash(player)] then
			OnPlayerScore(player, score, gametype_game)
				Scores[gethash(player)] = score
				SendRCMessage(timestamp .. "F L A G   C A P T U R E    -    " ..tostring(name).. " captured a flag for " ..player_team)
				SendRCMessage(tostring(name).. " has (" ..score.. ") total flag captures.")
			log(timestamp .. "F L A G   C A P T U R E    -    " ..tostring(name).. " captured a flag for " ..player_team)
			log(tostring(name).. " has (" ..score.. ") total flag captures.")
		end
	end
end

function getscore(player)
        local score = 0
        local timed = false
        if gametype_game == 1 then
                score = readword(getplayer(player) + 0xC8)
        elseif gametype_game == 2 then
                local Kills = readword(getplayer(player) + 0x9C)
                local antikills = 0
                if team_play == 0 then
                    antikills = readword(getplayer(player) + 0xB0)
            else
                    antikills = readword(getplayer(player) + 0xAC)
                end
                score = Kills - antikills
        elseif gametype_game == 3 then
                oddball_type = readbyte(0x671340 + 0x8C)
                if oddball_type == 0 or oddball_type == 1 then
                    score = readdword(0x639E5C, player)
                    timed = true
                else
                    score = readword(getplayer(player) + 0xC8)
                end
        elseif gametype_game == 4 then
                score = readword(getplayer(player) + 0xC4)
                timed = true
        elseif gametype_game == 5 then
                score = readword(getplayer(player) + 0xC6)
        end
        if timed == true then
                score = math.floor(score / 30)
        end                    
        return score
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function OnNewGame(map)
-- Spawn Script Start
------------------------------------------
	if GAME == "PC" then
		map_name = readstring(0x698F21)
		gametype_base = 0x671340
	elseif GAME == "CE" then
		map_name = readstring(0x61D151)
		gametype_base = 0x5F5498
	end
	-- Spawn Script End
------------------------------------------	
		local timestamp = os.date ("%H:%M:%S     ")
		ghost_mapId = gettagid("vehi", "vehicles\\ghost\\ghost_mp")
		rhog_mapId = gettagid("vehi", "vehicles\\rwarthog\\rwarthog")
		hog_mapId = gettagid("vehi", "vehicles\\warthog\\mp_warthog")
		banshee_mapId = gettagid("vehi", "vehicles\\banshee\\banshee_mp")
		turret_mapId = gettagid("vehi", "vehicles\\c gun turret\\c gun turret_mp")
		tank_mapId = gettagid("vehi", "vehicles\\scorpion\\scorpion_mp")
		overshield_tag_id = gettagid("eqip", "powerups\\over shield")
		camouflage_tag_id = gettagid("eqip", "powerups\\active camouflage")
	Map = map
	SendRCMessage(timestamp .. "* A new game has started on map " .. tostring(Map))
	log("A new game has started on map " .. tostring(Map))
	current_players = 0
------------------------------------- DEATH MESSAGES	
		for i = 0, 15 do
		if getplayer(i) then
			Team_Change[i] = false
		end	
	end
	Last_Damage = {}
	Team_Change = {}
------------------------------------- DEATH MESSAGES
	Team_Play = GetTeamPlay()
	LoadCoords()
	if map_name == "bloodgulch" then
		red_rot = createobject(gettagid("scen", "scenery\\flag_base\\flag_base"), 0, 0, false, 60.987, -121.606, 0.274)
		blue_rot = createobject(gettagid("scen", "scenery\\flag_base\\flag_base"), 0, 0, false, 60.987, -121.606, 0.274)
	end
end
 	
function GetTeamPlay()
    if readbyte(gametype_base + 0x34) == 1 then
        return true
	else
        return false
	end
end	
	
function OnGameEnd(mode)
	local timestamp = os.date ("%H:%M:%S     ")
	if mode == 1 then
		SendRCMessage(timestamp .. "* The game is ending...")
		log("The Game is ending...")
		if not Persistent then
		log("The connection will be closed...")
		log("* WARNING - Script should be 'Persistent' to avoid this!")
			SendRCMessage(timestamp .. "* The connection will be closed...")
			SendRCMessage(timestamp .. "* WARNING - Script should be 'Persistent' to avoid this!")
		end
		if Status_Timer ~= nil then
			removetimer(Status_Timer)
		end
	end
end

function OnNameRequest(hash, name)
	local timestamp = os.date ("%H:%M:%S: %d/%m/%Y")
	log("--------------------------------------------------------------------------------------------")
	log("            - - |   P L A Y E R   A T T E M P T I N G   T O   J O I N   | - -")
	log("                 - - - - - - - - - - - - - - - - - - - - - - - - - - - -                    ")
	log("Player Name: ".. name)
	log("CD Hash: " .. hash)
	log("Join Time: " .. timestamp)
	SendRCMessage("--------------------------------------------------------------------------------------------")
	SendRCMessage("            - - |   P L A Y E R   A T T E M P T I N G   T O   J O I N   | - -")
	SendRCMessage("                 - - - - - - - - - - - - - - - - - - - - - - - - - - - -                    ")
	SendRCMessage("Player Name: ".. name)
	SendRCMessage("CD Hash: " .. hash)
	SendRCMessage("Join Time: " .. timestamp)
end
-------------------------------------------------------------------------------- DEATH MESSAGES
function OnDamageApplication(receiving, causing, tagid, hit, backtap)
	if receiving then
		local r_object = getobject(receiving)
		if r_object then
			local receiver = objectaddrtoplayer(r_object)
			if receiver then
				local r_hash = gethash(receiver)
				local tagname,tagtype = gettaginfo(tagid)
				Last_Damage[r_hash] = tagname
			end
		end
	end
end
-------------------------------------------------------------------------------- DEATH MESSAGES
function OnPlayerSpawnEnd(player, m_objectId)
	local timestamp = os.date ("%H:%M:%S     ")
	if getplayer(player) then
		local hash = gethash(player)
		Last_Damage[hash] = nil
		Team_Change[player] = false
	end	
	local name = getname(player)
	if player then
		if Consecutive_Deaths[player][1] == SpawnKill_Deaths then
			local m_playerObjId = getplayerobjectid(player)
			if m_playerObjId then
				local m_object = getobject(m_playerObjId)
				if m_object then
					SendRCMessage(timestamp .. "S P A W N   P R O T E C T I O N   -   " ..name.. " has been given Spawn Protection.")
				end
			end
			Consecutive_Deaths[player][1] = 0
		end
	end
end
-------------------------------------------------------------------------------- DEATH MESSAGES
function OnPlayerJoin(player)
------------------------------------- DEATH MESSAGES
		Consecutive_Deaths[player] = {0}
		Scores[gethash(player)] = 0
	if getplayer(player) then
		Team_Change[player] = false
	end	
------------------------------------- DEATH MESSAGES	
	local name = getname(player)
	local hash = gethash(player)
	local ip = getip(player)
	local port = getport(player)
	local id = resolveplayer(player)
	local ping = readword(getplayer(player) + 0xDC)
	local player_team = getteam(player) -- Get Team
	
	if team_play then
    	if player_team == 0 then
			player_team = "the Red Team."
	elseif player_team == 1 then
			player_team = "the Blue Team."
	else
			player_team = "Hidden"
		end
	else
		player_team = "the FFA"
	end
	log("A C C E S S: | "..name.. " connected successfully.  |  (" ..ip.. ")  |  ("..port..") Ping: (" ..ping..")")
	log(name.. " | has been assigned ID number: ("..id..")")
	log("ASSIGNED TEAM | {" .. tostring(player) .. "} has been assigned to " ..player_team)
	log("--------------------------------------------------------------------------------------------")
	SendRCMessage("A C C E S S: | "..name.. " connected successfully.  |  (" ..ip.. ")  |  ("..port..") Ping: (" ..ping..")")
	SendRCMessage(name.. " | has been assigned ID number: ("..id..")")
	SendRCMessage("ASSIGNED TEAM | " ..name .. " has been assigned to " ..player_team)
	SendRCMessage("--------------------------------------------------------------------------------------------")
		if current_players == nil then
		current_players = 1
	else
		current_players = current_players + 1
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function OnServerChat(player, chattype, message)
	local timestamp = os.date ("%H:%M:%S     ")
 	local type = nil
        if chattype == 0 then
                type = "GLOBAL"
        elseif chattype == 1 then
                type = "TEAM"
        elseif chattype == 2 then
                type = "VEHICLE"		  
        end
		
        if player ~= nil and type ~= nil then
            local name = getname(player)
            local id = resolveplayer(player)

                SendRCMessage(timestamp .. "  C   H   A   T   -   " ..name ..  " (" .. id .. ") " .. type ..": ''" .. message .. "''")
				log(name .. " C   H   A   T   -   " ..name ..  " (" .. id .. ") " .. type ..": " .. message)
        end
end		
--[[		
--------------------------------------------------------------------------------------------
-- \pl Command
	AllowChat = nil
	local mlen = #message
    local spcount = 0
    for i=1, #message do
        local c = string.sub(message, i,i)
        if c == ' ' then
            spcount = spcount+1
        end
    end
    if mlen == spcount then
        spcount = 0
        return 0
    end
	
	local t = tokenizestring(message, " ")
	local count = #t
	if t[1] == nil then
		return nil
	end
		if string.sub(t[1], 1, 1) == "/" then
			AllowChat = true
		elseif string.sub(t[1], 1, 1) == "\\" then
			AllowChat = false
		end
		cmd = t[1]:gsub("\\", "/")
		local found1 = cmd:find("/")
		local found2 = cmd:find("/", 2)
		local valid_command
		if found1 and not found2 then
			for k,v in pairs(commands_table) do
				if cmd == v then
					valid_command = true
					break
				end
			end
			if not valid_command then
				SendRCMessage("Error 002: Invalid Command ", t[1], player)
			end
		end
	if cmd == "/pl" then
	Command_Players(player, t[1], count)
	end
end   
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
]]
function OnPlayerLeave(player)
			local timestamp = os.date ("%H:%M:%S, %d/%m/%Y:")
			local name = getname(player)
			local id = resolveplayer(player)
			local port = getport(player)
			local ip = getip(player)
			local ping = readword(getplayer(player) + 0xDC)
			local hash = gethash(player)
		log(name .. " (" .. id .. ") | Quit The Game .")
		SendRCMessage("P L A Y E R   Q U I T   T H E   G A M E")	
		SendRCMessage("-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -")
		SendRCMessage(name .. " (" .. id .. ") | Quit The Game.")
		SendRCMessage("IP Address: (".. ip ..")   Quit Time: ("..timestamp..")   Player Ping: ("..ping..")")
		SendRCMessage("CD Hash: " ..hash)
		current_players = current_players - 1
		SendRCMessage("-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -")
end

function OnPlayerKill(killer, victim, mode)
	local timestamp = os.date ("%H:%M:%S     ")
	local msg = ""
	if mode == 0 then -- Killed by the Server.
		msg = "* " .. getname(victim) .. " (" .. resolveplayer(victim) .. ") was killed by the server."
	elseif mode == 1 then -- Killed by Falling or Team-Change.
		msg = "* " .. getname(victim) .. " (" .. resolveplayer(victim) .. ") died."
	elseif mode == 2 then -- Killed by a mysterious force.
		msg = "* " .. getname(victim) .. " (" .. resolveplayer(victim) .. ") was killed by a mysterious force."
	elseif mode == 3 then -- Killed by Vehicle.
		msg = "* " .. getname(victim) .. " (" .. resolveplayer(victim) .. ") was squashed by a vehicle."
	elseif mode == 4 then -- Killed by another player, killer is not always valid, victim is always valid.
		msg = "* " .. getname(victim) .. " (" .. resolveplayer(victim) .. ") was killed by " .. getname(killer) .. " (player " .. resolveplayer(killer) .. ")."
	elseif mode == 5 then -- Killed by Team Mate (Betrayed)
		msg = "* " .. getname(victim) .. " (" .. resolveplayer(victim) .. ") was betrayed by " .. getname(killer) .. " (player " .. resolveplayer(killer) .. ")."
	elseif mode == 6 then -- Suicide
		msg = "* " .. getname(victim) .. " (" .. resolveplayer(victim) .. ") committed suicide."
	end

	if msg ~= "" then
		log(msg)
	end
------------------------------------------------------------- DEATH MESSAGES BEGIN HERE ------------------------------------------------------------------------------------		
	local response = false		
	if mode == 0 then -- Killed by the server.
		response = false
		
	local KillMessage = GenerateKillType(killslang)
	if getplayer(victim) then
			SendRCMessage(timestamp .. "D  E  A  T  H    -   " ..getname(victim) .. " was killed by the server.")
		end
		
elseif mode == 1 then -- Killed by Falling or Team-Change.
		response = false
		if getplayer(victim) then
			local vhash = gethash(victim)
			if not Team_Change[victim] then
				response = false
				if Last_Damage[vhash] == "globals\\distance" or Last_Damage[vhash] == "globals\\falling" then -- Falling
				SendRCMessage(timestamp .. "D  E  A  T  H    -   " ..getname(victim) .. " fell and perished!")
				end	
			else
				response = false
				SendRCMessage(timestamp .. "T E A M   C H A N G E  " ..getname(victim) .. " has changed teams!")
				Team_Change[victim] = false		
			end	
		end		
elseif mode == 2 then -- Killed by a Mysterious Force.
		response = false
		if getplayer(victim) then
				SendRCMessage(timestamp .. "D  E  A  T  H    -   " ..getname(victim) .. " was killed by a mysterious force...")			
		end			
elseif mode == 3 then -- Killed by Vehicle.
		response = false
		if getplayer(victim) then
			local vhash = gethash(victim)
				SendRCMessage(timestamp .. "D  E  A  T  H    -   " ..getname(victim) .. " was squashed by a vehicle.")
		end			
elseif mode == 4 then -- Killed by another player, killer is not always valid, victim is always valid.
		Consecutive_Deaths[victim][1] = Consecutive_Deaths[victim][1] + 1 -- Victim
		if killer then -- Killer
			if Consecutive_Deaths[killer][1] ~= 0 then -- Killer
				Consecutive_Deaths[killer][1] = 0 -- Killer
			end
		end
		response = false
		local KillMessage = GenerateKillType(killslang)
		if getplayer(victim) then
			local vhash = gethash(victim)
			if Last_Damage[vhash] then
				if getplayer(killer) ~= nil then
					if string.find(Last_Damage[vhash], "melee") then -- Weapon Meele		
					SendRCMessage(timestamp .. "D  E  A  T  H    -   " ..getname(killer) .. " " .. GenerateHitSlang(hit) .. " " .. getname(victim) .. " in the " .. GenerateHeadSlang(head) .."!")
elseif Last_Damage[vhash] == "globals\\distance" or Last_Damage[vhash] == "globals\\falling" then
					SendRCMessage(timestamp .. "D  E  A  T  H    -   " ..getname(victim) .. " fell and perished!")
elseif Last_Damage[vhash] == "globals\\vehicle_collision" then -- On Vehicle Collision
					SendRCMessage(timestamp .. "D  E  A  T  H    -   " ..getname(killer) .. " ran over " .. getname(victim))
elseif string.find(Last_Damage[vhash], "banshee") then -- Banshee (General)
					SendRCMessage(timestamp .. "D  E  A  T  H    -   " ..getname(killer) .. " " .. KillMessage .. " " .. getname(victim) .. " with a banshee.")
elseif Last_Damage[vhash] == "vehicles\\banshee\\mp_fuel rod explosion" then -- Fuel Rod Explosion / Banshee
					SendRCMessage(timestamp .. "D  E  A  T  H    -   " ..getname(killer) .. " " .. KillMessage .. " " .. getname(victim) .. " with a Banshee's Fuel Rod.")
elseif Last_Damage[vhash] == "vehicles\\banshee\\banshee bolt" then	-- Banshee Bolt
					SendRCMessage(timestamp .. "D  E  A  T  H    -   " ..getname(killer) .. " " .. KillMessage .. " " .. getname(victim) .. " with a Banshee's Plasma Guns.")
elseif Last_Damage[vhash] == "vehicles\\c gun turret\\mp bolt" then -- Turret Bolt
					SendRCMessage(timestamp .. "D  E  A  T  H    -   " ..getname(killer) .. " " .. KillMessage .. " " .. getname(victim) .. " with the covenant turret.")
elseif Last_Damage[vhash] == "vehicles\\ghost\\ghost bolt" then -- Ghost Bolt
					SendRCMessage(timestamp .. "D  E  A  T  H    -   " ..getname(killer) .. " " .. KillMessage .. " " .. getname(victim) .. " with the ghost plasma guns.")
elseif Last_Damage[vhash] == "vehicles\\scorpion\\bullet" then -- Scorpion Tank Bullet
					SendRCMessage(timestamp .. "D  E  A  T  H    -   " ..getname(killer) .. " " .. KillMessage .. " " .. getname(victim) .. " with a Scorpion Tank")
elseif Last_Damage[vhash] == "vehicles\\scorpion\\shell explosion" then -- Scorpion tank Shell Explosion
					SendRCMessage(timestamp .. "D  E  A  T  H    -   " ..getname(killer) .. " " .. KillMessage .. " " .. getname(victim) .. " with a Sniper Rifle!")
elseif Last_Damage[vhash] == "vehicles\\warthog\\bullet" then -- Warthog chain-gun bullet
					SendRCMessage(timestamp .. "D  E  A  T  H    -   " ..getname(killer) .. " " .. KillMessage .. " " .. getname(victim) .. " with a warthog chain-gun.")
elseif Last_Damage[vhash] == "weapons\\assault rifle\\bullet" then -- Assault Rifle Bullet
					SendRCMessage(timestamp .. "D  E  A  T  H    -   " ..getname(killer) .. " " .. KillMessage .. " " .. getname(victim) .. " with an assault rifle.")
elseif Last_Damage[vhash] == "weapons\\flamethrower\\burning" or Last_Damage[vhash] == "weapons\\flamethrower\\explosion" or Last_Damage[vhash] == "weapons\\flamethrower\\impact damage" then -- Flame Thrower
					SendRCMessage(timestamp .. "D  E  A  T  H    -   " ..getname(killer) .. " " .. KillMessage .. " " .. getname(victim) .. " with a flame-thrower.")
elseif Last_Damage[vhash] == "weapons\\frag grenade\\explosion" then -- Frag Grenade Explosion
					SendRCMessage(timestamp .. "D  E  A  T  H    -   " ..getname(killer) .. " " .. KillMessage .. " " .. getname(victim) .. " with a Frag Grenade!")
elseif Last_Damage[vhash] == "weapons\\needler\\detonation damage" or Last_Damage[vhash] == "weapons\\needler\\explosion" or Last_Damage[vhash] == "weapons\\needler\\impact damage" then -- Needler
					SendRCMessage(timestamp .. "D  E  A  T  H    -   " ..getname(killer) .. " " .. KillMessage .. " " .. getname(victim) .. " with a needler.")
elseif Last_Damage[vhash] == "weapons\\pistol\\bullet" then -- Pistol Bullet
					SendRCMessage(timestamp .. "D  E  A  T  H    -   " ..getname(killer) .. " " .. KillMessage .. " " .. getname(victim) .. " with a Pistol!")
elseif Last_Damage[vhash] == "weapons\\plasma grenade\\attached" or Last_Damage[vhash] == "weapons\\plasma grenade\\explosion" then -- Plasma Grenade
					SendRCMessage(timestamp .. "D  E  A  T  H    -   " ..getname(killer) .. " " .. KillMessage .. " " .. getname(victim) .. " with a plasma grenade.")
elseif Last_Damage[vhash] == "weapons\\plasma pistol\\bolt" or Last_Damage[vhash] == "weapons\\plasma rifle\\charged bolt" then -- Plasma Pistol Bolt 
					SendRCMessage(timestamp .. "D  E  A  T  H    -   " ..getname(killer) .. " " .. KillMessage .. " " .. getname(victim) .. " with a plasma pistol.")
elseif Last_Damage[vhash] == "weapons\\plasma rifle\\bolt" then -- Plasma Rifle Bolt
					SendRCMessage(timestamp .. "D  E  A  T  H    -   " ..getname(killer) .. " " .. KillMessage .. " " .. getname(victim) .. " with a plasma rifle.")
elseif Last_Damage[vhash] == "weapons\\plasma_cannon\\effects\\plasma_cannon_explosion" or Last_Damage[vhash] == "weapons\\plasma_cannon\\impact damage" then -- Plasma Cannon Explosion
					SendRCMessage(timestamp .. "D  E  A  T  H    -   " ..getname(killer) .. " " .. KillMessage .. " " .. getname(victim) .. " with a fuel-rod gun.")
elseif Last_Damage[vhash] == "weapons\\rocket launcher\\explosion" then -- Rocket Hog - Rocket Launcher Explosion
					if isinvehicle(killer) then -- Vehicle Weapon (RHog, Rocket Launcher)
					SendRCMessage(timestamp .. "D  E  A  T  H    -   " ..getname(killer) .. " " .. KillMessage .. " " .. getname(victim) .. " with a warthog rocket.")
					else -- Rocket Launcher (weapon)
					SendRCMessage(timestamp .. "D  E  A  T  H    -   " ..getname(killer) .. " " .. KillMessage .. " " .. getname(victim) .. " with a rocket launcher.")
					end
elseif Last_Damage[vhash] == "weapons\\shotgun\\pellet" then -- Shotgun
					SendRCMessage(timestamp .. "D  E  A  T  H    -   " ..getname(killer) .. " " .. KillMessage .. " " .. getname(victim) .. " with a shotgun.")
elseif Last_Damage[vhash] == "weapons\\sniper rifle\\sniper bullet" then -- Sniper Rifle
					SendRCMessage(timestamp .. "D  E  A  T  H    -   " ..getname(killer) .. " " .. KillMessage .. " " .. getname(victim) .. " with a sniper rifle!")
					end
				end	
			end
		end	
elseif mode == 5 then -- Killed by Team Mate (BETRAYED)
		response = true
		if getplayer(killer) then
			SendRCMessage(timestamp .. "B E T R A Y   -   " ..killer.. " has been warned for betraying team mates.")
		end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------	
													-- S U I C I D E S -- 
elseif mode == 6 then -- Suicide
		response = false	
		if getplayer(victim) then
			local vhash = gethash(victim)
			if Last_Damage[vhash] then 
				if Last_Damage[vhash] == "weapons\\frag grenade\\explosion" then -- Frag Grenade
						SendRCMessage(timestamp .. "S  U  I  C  I  D  E   -  " .. getname(victim) .. " has Committed suicide with a Frag Grenade.")					
elseif Last_Damage[vhash] == "weapons\\plasma grenade\\attached" or Last_Damage[vhash] == "weapons\\plasma grenade\\explosion"	then -- Plasma Grenade
						SendRCMessage(timestamp .. "S  U  I  C  I  D  E   -  " .. getname(victim) .. " has Committed suicide with a Plasma Grenade.")
elseif Last_Damage[vhash] == "vehicles\\scorpion\\shell explosion" then	-- Sniper Rifle (Note to Self: Sniper rounds are replaced with tank shells on OWV 3)
						SendRCMessage(timestamp .. "S  U  I  C  I  D  E   -  " .. getname(victim) .. " has Committed Suicide with a Sniper Rifle.")					
					end
				end
			else 
			SendRCMessage(timestamp .. "S  U  I  C  I  D  E   -   " .. getname(victim) .. " has Committed Suicide.")
		end	
	end
	return response
end

function GenerateKillType(killslang)
	local killcount = #KillType
	local rand_type = getrandomnumber(1, killcount+1)
	local kill_type = string.format("%s",  KillType[rand_type])
	if kill_type then
		return kill_type
	else
		return "killed"
	end
end	

function GenerateHeadSlang(head)
	local headcount = #HeadSlang
	local rand_type = getrandomnumber(1, headcount+1)
	local head_type = string.format("%s",  HeadSlang[rand_type])
	if head_type then
		return head_type
	else
		return "head"
	end
end	

function GenerateHitSlang(hit)
	local hitcount = #HitSlang
	local rand_type = getrandomnumber(1, hitcount+1)
	local hit_type = string.format("%s",  HitSlang[rand_type])
	if hit_type then
		return hit_type
	else
		return "hit"
	end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Kill Type, Head Slang, and Hit Slang.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
KillType = {"killed"}
HeadSlang = {"mouth", "skull", "head", "brains", "trap", "chops", "gob"}
HitSlang = {"smacked", "punched", "whacked", "clocked", "thumped", "slugged", "smashed", "hammered", "beat", "slapped", "bashed", "clobbered", "socked"}

function OnTeamChange(player, old_team, new_team, relevant)
	if getplayer(player) then
		Team_Change[player] = true
		end	
	return nil
end

function getrealteam(team)
	
	local Team = nil
	if team == 0 then
		Team = "Red"
	elseif team == 1 then
		Team = "Blue"
	end
	return Team
end

function ServerTimer(id, count)
	if server == nil then
		return false
	end
	local client, e = server:accept()
	if e == nil then
		client:settimeout(0)
		local id = registertimer(Client_Refresh, "ClientTimer")
		Client_Table[id] = {socket = client, buffer = ""}
		respond("                           ----- TCP WARNING -----")
		respond("                TCP has detected someone in the server lobby")
		Client_Table[id]["buffer"] = Client_Table[id]["buffer"] .. "=============================================================================================================================================================\r\n"
		Client_Table[id]["buffer"] = Client_Table[id]["buffer"] .. "                                             O  W  V  3\r\n"
		Client_Table[id]["buffer"] = Client_Table[id]["buffer"] .. "                        O  N  E     W  O  R  L  D     V  I  R  T  U  A  L\r\n"
		Client_Table[id]["buffer"] = Client_Table[id]["buffer"] .. "                                      M A S T E R   S E R V E R\r\n"
		Client_Table[id]["buffer"] = Client_Table[id]["buffer"] .. "               ------------------------------------------------------------------\r\n"
		Client_Table[id]["buffer"] = Client_Table[id]["buffer"] .. "\r\n"
		Client_Table[id]["buffer"] = Client_Table[id]["buffer"] .. "Server Name: OWV-3, One World Virtual SDTM - OWV Clan\r\n"
		Client_Table[id]["buffer"] = Client_Table[id]["buffer"] .. "Local Server IP: 192.168.20.101\r\n"
		Client_Table[id]["buffer"] = Client_Table[id]["buffer"] .. "Public Server IP: 121.73.101.37\r\n" 
		Client_Table[id]["buffer"] = Client_Table[id]["buffer"] .. "Ports: 2302, 2303, 2304, 2305, 2306, 2307, 2308, 2309, 2310\r\n"
		Client_Table[id]["buffer"] = Client_Table[id]["buffer"] .. "Server is broadcasting on all frequencies: 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 1.10 - 1.10\r\n"
		Client_Table[id]["buffer"] = Client_Table[id]["buffer"] .. "Game Mode: Capture The Flag - (CTF)\r\n"
		Client_Table[id]["buffer"] = Client_Table[id]["buffer"] .. "Scripts Running: Commands, ABD4, OWV3, MBoard4, CIDs, OVE1, OVE2, CP, IPA, OPS, DMsgs4, RQ, SPWNS, msgs, CYB, SL, SL2, SL3, RC\r\n"
		Client_Table[id]["buffer"] = Client_Table[id]["buffer"] .. "REMOTE CONTROL: IP = L - 192.168.20.101 / P - 121.73.101.37 - Username: *****, Password: *****\r\n"
		Client_Table[id]["buffer"] = Client_Table[id]["buffer"] .. "=============================================================================================================================================================\r\n"
		Client_Table[id]["buffer"] = Client_Table[id]["buffer"] .. "\r\n"
		Client_Table[id]["buffer"] = Client_Table[id]["buffer"] .. "Welcome to One World Virtual 3, Master Server.\r\n"
		Client_Table[id]["buffer"] = Client_Table[id]["buffer"] .. "---------------------------------\r\n"
		Client_Table[id]["buffer"] = Client_Table[id]["buffer"] .. "* Please Log In with your Username and Password by typing: login [user-name] [password]\r\n"
		Client_Table[id]["buffer"] = Client_Table[id]["buffer"] .. "----------------------------------------------------------------------------------------------------------\r\n"
		Client_Table[id]["buffer"] = Client_Table[id]["buffer"] .. "\r\n"
		Client_Table[id]["buffer"] = Client_Table[id]["buffer"] .. "\r\n"
	elseif e == "timeout" then 
	else
		for id_, client_ in pairs(Client_Table) do
			client_["socket"]:close()
			Client_Table[id_] = nil
		end
		server:close()
		server = nil
		return false
	end
	return true
end

function StatusTimer(id, count)
	if current_players == nil then
		current_players = 0
	end
	SendRCMessage("* Updating...           There are currently: (" .. current_players .. " / " .. readword(0x4029CE88 + 0x28) .. " players online)")
	return true
end

function ClientTimer(id, count)
	local client = Client_Table[id]
	if client == nil then
		return false
	end
	local msg, e = client["socket"]:receive()
	if e == nil then
		if #msg > 0 then
			local args = tokenizecmdstring(msg)
			local cmd = args[1]
			if cmd ~= "login" then
				if client['user'] == nil then
					client["buffer"] = client["buffer"] .. "* Error 003:          You must login first.\r\n"
					respond("* Error 003:          You must login first.")
					return true
				end
			elseif cmd == "login" then
				if #args ~= 3 then
					client["buffer"] = client["buffer"] .. "* Error 004:          You must enter a username and password before you can procede.\r\n"
					respond("* Error 004:          You must enter a username and password before you can procede.")
				end
			end
			if client["user"] ~= nil then
				RC_Name = client["user"]
				local response = svcmd(msg, true)
				for k, v in pairs(response) do
					client["buffer"] = client["buffer"] .. "* " .. v .. "\r"
					log(v)
				end
			else
				local args = tokenizecmdstring(msg)
				if #args == 2 then
					local user = args[1]
					local pass = args[2]
					local is_valid = false
					for i, v in ipairs(User_Table) do
						if v["name"] == user and v["password"] == pass then
							is_valid = true
						end
					end
					if is_valid then
						local in_use = false
						for id_, client_ in pairs(Client_Table) do
							if client_["user"] == user then
								in_use = true
							end
						end
						if in_use then
							client["buffer"] = client["buffer"] .. "* Error 005:          Username is already logged in.\r\n"
							respond("* Error 005:          Username is already logged in.")
						else
							local ip, port = client["socket"]:getpeername()
							client["user"] = user
								client["buffer"] = client["buffer"] .. "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\r\n"
								client["buffer"] = client["buffer"] .. "Connection Established...    Your IP has been logged: " .. ip .. "  Port: " .. port .. "\r\n"
								client["buffer"] = client["buffer"] .. "* Welcome " .. user .. "     -   You have successfully logged in!\r\n"
								client["buffer"] = client["buffer"] .. "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\r\n"
								client["buffer"] = client["buffer"] .. "\r\n"
								respond("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
								respond("Connection Established...    Your IP has been logged: " .. ip .. "  Port: " .. port)
								respond("* Welcome " .. user .. "     -   You have successfully logged in!")
								respond("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
							log("\r\n")
							log("SERVER LOG IN: " .. user .. " has logged into the RC Server.  IP: " .. ip .. "  Port: " .. port)
							if Map == nil then
								mapcycle_pointer = readdword(header) 
								Map = readstring(readdword(mapcycle_pointer))
							end
							if current_players == nil then
								current_players = 0 
							end 
							client["buffer"] = client["buffer"] .. "* Updating...           There are currently: (" .. current_players .. " / " .. readword(0x4029CE88 + 0x28) .. " players online)\r\n"
							local ip, port = client["socket"]:getpeername()
							for id_, client_ in pairs(Client_Table) do
								if client_["user"] ~= nil and client_["user"] ~= client["user"] then
									client_["buffer"] = client_["buffer"] .. "~~~ U S E R   L O G G E D   I N:\r\n" .. user .. " has logged in. IP Address: " .. ip .. " Port: " .. port .. ".\r\n"
									respond(" U S E R   L O G G E D   I N:\r\n" .. user .. " has logged in. IP Address: " .. ip .. " Port: " .. port .. ".")
									log("\r\n")
									log("USER LOGGED IN: " .. user .. " has logged into the Master Server. IP Address: " .. ip .. " Port: " .. port .. ".")
								end
							end
						end
					else
						client["buffer"] = client["buffer"] .. "* Error 006:          Invalid Username or Password.\r\n"
						client["buffer"] = client["buffer"] .. "* Please Try Again...\r\n"
						respond("* Error 006:          Invalid Username or Password.")
						respond("* Please Try Again...")
					end
				elseif #args == 3 then
					if args[1] == "login" then
						local user = args[2]
						local pass = args[3]
						local is_valid = false

						for i, v in ipairs(User_Table) do
							if v["name"] == user and v["password"] == pass then
								is_valid = true
							end
						end
						if is_valid then
							local in_use = false
							for id_, client_ in pairs(Client_Table) do
								if client_["user"] == user then
									in_use = true
								end
							end
							if in_use then
								client["buffer"] = client["buffer"] .. "* Error 009:          Username is already in use\r\n"
								client["buffer"] = client["buffer"] .. "* There is a known bug with this client caused when the TCP Client is closed and reopened and the script is saying that the username is already logged in.\r\n"
								client["buffer"] = client["buffer"] .. "* This is due to the fact that the TCP client never actually closes the socket connection. This can not be fixed on my end.\r\n"
								respond("* Error 009:          Username is already in use")
								respond("* There is a known bug with this client caused when the TCP Client is closed and reopened and the script is saying that the username is already logged in.")
								respond("* This is due to the fact that the TCP client never actually closes the socket connection. This can not be fixed on my end.")
							else
								local ip, port = client["socket"]:getpeername()
								client["user"] = user
								client["buffer"] = client["buffer"] .. "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\r\n"
								client["buffer"] = client["buffer"] .. "Connection Established...    Your IP has been logged: " .. ip .. "  Port: " .. port .. "\r\n"
								client["buffer"] = client["buffer"] .. "* Welcome " .. user .. "     -   You have successfully logged in!\r\n"
								client["buffer"] = client["buffer"] .. "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\r\n"
								respond("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
								respond("Connection Established...    Your IP has been logged: " .. ip .. "  Port: " .. port)
								respond("* Welcome " .. user .. "     -   You have successfully logged in!")
								respond("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
								log("\r\n")
								log("SERVER LOG IN: " .. user .. " has logged into the RC Server.  IP: " .. ip .. "  Port: " .. port)
								if Map == nil then
									mapcycle_pointer = readdword(header) 
									Map = readstring(readdword(mapcycle_pointer))
								end
								if current_players == nil then
									current_players = 0
								end
								client["buffer"] = client["buffer"] .. "* Updating...           There are currently: (" .. current_players .. " / " .. readword(0x4029CE88 + 0x28) .. " players online)\r\n"
								local ip, port = client["socket"]:getpeername()
								for id_, client_ in pairs(Client_Table) do
									if client_["user"] ~= nil and client_["user"] ~= client["user"] then
										client_["buffer"] = client_["buffer"] .. "~~~ U S E R   L O G G E D   I N:\r\n" .. user .. " has logged in. IP Address: " .. ip .. " Port: " .. port .. ".\r\n"
										respond(" U S E R   L O G G E D   I N:\r\n" .. user .. " has logged in. IP Address: " .. ip .. " Port: " .. port .. ".")
										log("\r\n")
										log("USER LOGGED IN: " .. user .. " has logged into the Master Server. IP Address: " .. ip .. " Port: " .. port .. ".")
									end
								end
							end
						else
							client["buffer"] = client["buffer"] .. "* Error 007:          Invalid Username or Password.\r\n"
							client["buffer"] = client["buffer"] .. "* Please Try Again...\r\n"
							respond("* Error 007:          Invalid Username or Password.")
							respond(" Please Try Again...")
						end
					else
						client["buffer"] = client["buffer"] .. "* Error 008:          You are not logged in.\r\n"
						client["buffer"] = client["buffer"] .. "* Please Log In with your Userame and Password by typing: 'login'(space)[user-name](space)[password]\r\n"
					respond("* Error 008:          You are not logged in.")
					respond("* Please Log In with your Userame and Password by typing: 'login'(space)[user-name](space)[password]")
					end
				else
					client["buffer"] = client["buffer"] .. "* Syntax: login [user name] [password].\r\n"
					respond("* Syntax: login [user name] [password].")
				end
			end
		end
	elseif e == "timeout" then
	elseif e == "closed" then
		client["socket"]:close()
		Client_Table[id] = nil
		if client["user"] ~= nil then
			for id_, client_ in pairs(Client_Table) do
				if client_["user"] ~= nil and client_["user"] ~= client["user"] then
					client["buffer"] = client["buffer"] .. "* " .. client["user"] .. " has logged out.\r\n"
					respond("* " .. client["user"] .. " has logged out.")
					log(client["user"] .. " has logged out!")
				end
			end
		end
		return false
	else
		client["socket"]:close()
		Client_Table[id] = nil
		if client["user"] ~= nil then
			for id_, client_ in pairs(Client_Table) do
				if client_["user"] ~= nil and client_["user"] ~= client["user"] then
					client["buffer"] = client["buffer"] .. "* " .. client["user"] .. " has logged out.\r\n"
					respond("* " .. client["user"] .. " has logged out.")
					log(client["user"] .. " has logged out!")
				end
			end
		end
		return false
	end

	if #client["buffer"] > 0 then
		client["socket"]:send(client["buffer"])
		client["buffer"] = ""
	end

	if Client_Refresh * count >= Client_Timeout * 1000 and client["user"] == nil then
		client["socket"]:send("* Server Error 010: Server Error 010: Log in timed out.\r\n")
		respond("* Server Error 010: Log in timed out.")
		client["socket"]:close()
		Client_Table[id] = nil
		return false
	end
	return true
end
--[[-------------------------------------------------------------------------------------------
										Commands Begin ...
-------------------------------------------------------------------------------------------]]--
function sv_add_user(player, args)
	if #args == 1 then
		respond("Syntax: sv_add_user [name] [password]")
		return
	elseif #args == 2 then
		respond("Syntax: sv_add_user [name] [password]")
		return
	elseif #args == 3 then
		local name = args[2]
		local password = args[3]
		local name_exists = false
		for i, v in ipairs(User_Table) do
			if v["name"] == name then
				name_exists = true
			end
		end
		if name_exists then
			respond("sv_add_user: The name " .. name .. " is already in use.")
			return
		end
		table.insert(User_Table, {name = name, password = password})
		local file = io.open(getprofilepath() .. "//" .. User_File, "w")
		if file then
			for i, v in ipairs(User_Table) do
				file:write(v['name'] .. "," .. v['password'] .. "\n")
			end
			file:close()
		end
		respond(name .. " can now use remote control.")
	elseif #args > 3 then
		respond("Syntax: sv_add_user [name] [password]")
		return
	end
end

function sv_delete_user(player, args)
	if #args ~= 2 then
		respond("Syntax: sv_delete_user <index>")
		return
	else
		if tonumber(args[2]) < 0 or tonumber(args[2]) > #User_Table then
			respond("sv_delete_user: The index " .. index .. " does not exist.")
			return
		end
		respond(User_Table[tonumber(args[2])]["name"] .. " is no longer a user.")
		for id, client in pairs(Client_Table) do
			if client["user"] == User_Table[tonumber(args[2])]["name"] then
				client["socket"]:send(client["buffer"])
				client["socket"]:close()
				Client_Table[id] = nil
			end
		end
		table.remove(User_Table, tonumber(args[2]))
		local file = io.open(getprofilepath() .. "//" .. User_File, "w")
		if file then
			for i, v in ipairs(User_Table) do
				file:write(v['name'] .. "," .. v['password'] .. "\n")
			end
			file:close()
		end
	end
end

function sv_user_list(player, args)
	if #args == 1 then
		respond("Position:\tName:\t\t\t\t")
		for i, v in ipairs(User_Table) do
			respond("[" .. i .. "]\t\t\t\t\t" .. v["name"])
		end
	else
		respond("Syntax: sv_user_list")
		return
	end
end

function sv_cur_users(player, args)
	respond("Current users logged into the Server:")
	log("Current users in the server are:")
	for id, client in pairs(Client_Table) do
		if client["user"] ~= nil then
			respond(client["user"])
			log(client['user'])
		end
	end
end
--[[-------------------------------------------------------------------------------------------
										... Commands End
-------------------------------------------------------------------------------------------]]--
function SendRCMessage(msg)
	for id, client in pairs(Client_Table) do
		if client["user"] ~= nil then
			client["buffer"] = client["buffer"] .. msg .. "\r\n"
		end
	end
end

function log(msg)
	if Enable_Logging == true then
		WriteDataToFile("RC Logs.txt", msg)
	end
end

function WriteDataToFile(filename, value)

	local file = io.open(getprofilepath() .. "\\logs\\" .. filename, "a")
	if file then
		local timestamp = os.date("%Y/%m/%d %H:%M:%S")
		local line = string.format("%s\t%s\n", timestamp, tostring(value))
		file:write(line)
		file:close() 
	end
end