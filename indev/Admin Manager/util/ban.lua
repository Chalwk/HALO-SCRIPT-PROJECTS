local util = {

    parser = {
        ['-y'] = 'years',
        ['-mo'] = 'months',
        ['-d'] = 'days',
        ['-h'] = 'hours',
        ['-m'] = 'minutes',
        ['-s'] = 'seconds',
        ['-r'] = 'reason'
    },

    -- List of known pirated hashes:
    known_pirated_hashes = {
        ['388e89e69b4cc08b3441f25959f74103'] = true,
        ['81f9c914b3402c2702a12dc1405247ee'] = true,
        ['c939c09426f69c4843ff75ae704bf426'] = true,
        ['13dbf72b3c21c5235c47e405dd6e092d'] = true,
        ['29a29f3659a221351ed3d6f8355b2200'] = true,
        ['d72b3f33bfb7266a8d0f13b37c62fddb'] = true,
        ['76b9b8db9ae6b6cacdd59770a18fc1d5'] = true,
        ['55d368354b5021e7dd5d3d1525a4ab82'] = true,
        ['d41d8cd98f00b204e9800998ecf8427e'] = true,
        ['c702226e783ea7e091c0bb44c2d0ec64'] = true,
        ['f443106bd82fd6f3c22ba2df7c5e4094'] = true,
        ['10440b462f6cbc3160c6280c2734f184'] = true,
        ['3d5cd27b3fa487b040043273fa00f51b'] = true,
        ['b661a51d4ccf44f5da2869b0055563cb'] = true,
        ['740da6bafb23c2fbdc5140b5d320edb1'] = true,
        ['7503dad2a08026fc4b6cfb32a940cfe0'] = true,
        ['4486253cba68da6786359e7ff2c7b467'] = true,
        ['f1d7c0018e1648d7d48f257dc35e9660'] = true,
        ['40da66d41e9c79172a84eef745739521'] = true,
        ['2863ab7e0e7371f9a6b3f0440c06c560'] = true,
        ['34146dc35d583f2b34693a83469fac2a'] = true,
        ['b315d022891afedf2e6bc7e5aaf2d357'] = true,
        ['63bf3d5a51b292cd0702135f6f566bd1'] = true,
        ['6891d0a75336a75f9d03bb5e51a53095'] = true,
        ['325a53c37324e4adb484d7a9c6741314'] = true,
        ['0e3c41078d06f7f502e4bb5bd886772a'] = true,
        ['fc65cda372eeb75fc1a2e7d19e91a86f'] = true,
        ['f35309a653ae6243dab90c203fa50000'] = true,
        ['50bbef5ebf4e0393016d129a545bd09d'] = true,
        ['a77ee0be91bd38a0635b65991bc4b686'] = true,
        ['3126fab3615a94119d5fe9eead1e88c1'] = true,
        ['2f02b641060da979e2b89abcfa1af3d6'] = true,
        ['ac73d9785215e196074d418d1cce825b'] = true,
        ['54f4d0236653a6da6429bfc79015f526'] = true
    }
}

local _time = os.time
local _date = os.date
local _pairs = pairs
local _format = string.format
local _tonumber = tonumber

local function parseReason(args, value, i)
    for j = i + 2, #args do
        local next_arg = args[j]
        if (next_arg:sub(1, 1) == '-') then
            break
        end
        value = value .. ' ' .. next_arg
    end
    return value
end

function util:banSyntaxParser(args)

    local parsed_args = {}
    for i = 1, #args do

        local arg = args[i]
        local flag = self.parser[arg]
        local value = args[i + 1]

        if (flag and value) then

            value = parseReason(args, value, i)

            if (value:sub(1, 1) == '-' or flag ~= 'reason' and _tonumber(value) == nil) then
                self:send('Invalid value for flag: ' .. flag .. ' - ' .. value)
                return false
            elseif (flag == 'reason') then
                value = value:gsub('"', '')
            end

            parsed_args[flag] = (type(value) == 'string' and value or _tonumber(value))

        elseif (flag and not value) then
            self:send('Missing value for flag: ' .. flag)
            return false
        end
    end

    return parsed_args
end

function util:banSTDOUT(args)

    local id = args.id
    local pirated = args.pirated
    local admin_name = args.admin_name
    local offender_name = args.offender_name
    local reason = args.reason
    local expiration = args.expiration

    local years = expiration.year
    local months = expiration.month
    local days = expiration.day
    local hours = expiration.hour
    local minutes = expiration.min
    local seconds = expiration.sec

    local placeholders = {
        ['$id'] = id,
        ['$pirated'] = (pirated and 'Yes' or 'No'),
        ['$admin'] = admin_name,
        ['$offender'] = offender_name,
        ['$reason'] = reason,
        ['$years'] = years,
        ['$months'] = months,
        ['$days'] = days,
        ['$hours'] = hours,
        ['$minutes'] = minutes,
        ['$seconds'] = seconds
    }

    local output = self.output
    for k, v in _pairs(placeholders) do
        output = output:gsub(k, v)
    end

    return output
end

function util:newBan(args)
    return {
        added_on = self:getDate(),
        added_by = args.admin_name,
        offender = args.offender_name,
        ip = args.ip or nil,
        hash = args.hash or nil,
        reason = args.reason,
        time = args.time,
        id = self:setBanID(args.type)
    }
end

local function noTime(y, mo, d, h, m, s)
    return (y == 0 and mo == 0 and d == 0 and h == 0 and m == 0 and s == 0)
end

local function futureTime(time)
    local now = _time()
    local y, mo, d, h, m, s = time.y, time.mo, time.d, time.h, time.m, time.s
    return {
        year = _tonumber(_date('%Y', now)) + y,
        month = _tonumber(_date('%m', now)) + mo,
        day = _tonumber(_date('%d', now)) + d,
        hour = _tonumber(_date('%H', now)) + h,
        min = _tonumber(_date('%M', now)) + m,
        sec = _tonumber(_date('%S', now)) + s
    }
end

function util:generateExpiration(time)

    local y = (time.years or 0)
    local mo = (time.months or 0)
    local d = (time.days or 0)
    local h = (time.hours or 0)
    local m = (time.minutes or 0)
    local s = (time.seconds or 0)
    local default = self.default_ban_duration

    local no_time = noTime(y, mo, d, h, m, s)
    return (no_time and futureTime(default) or futureTime({
        y = y,
        mo = mo,
        d = d,
        h = h,
        m = m,
        s = s
    }))
end

function util:setBanID(ban_table)
    local id = 0
    for _, entry in _pairs(ban_table) do
        if (entry.id > id) then
            id = entry.id
        end
    end
    return id + 1
end

function util:getBanEntryByID(ban_table, id)
    for entry, v in _pairs(ban_table) do
        if (v.id == id) then
            return entry
        end
    end
    self:send('Ban ID not found.')
    return nil
end

function util:isMuted()
    local ip = self.ip
    local hash = self.hash
    local ip_muted = self.bans['mute']['ip'][ip]
    local hash_muted = self.bans['mute']['hash'][hash]
    return ip_muted or hash_muted
end

function util:setPirated(group, type, hash)
    local pirated = self.known_pirated_hashes
    pirated = (hash and pirated[hash] and true or false) or nil
    self.bans[group][type].pirated = pirated
end

function util:hashBan(reason, time, admin)

    local hash_bans = self.bans['hash']
    local name, hash, ip = self.name, self.hash, self.ip
    hash_bans[hash] = self:newBan({
        admin_name = admin.name,
        offender_name = name,
        ip = ip,
        reason = reason,
        time = time,
        type = hash_bans
    })
    self:setPirated('hash', hash, hash)
    self:kick()
    self:updateBans()
end

function util:hashBanProceed(offender, parsed, admin)

    local reason = parsed.reason or 'No reason given.'
    local expiration = self:generateExpiration(parsed)

    offender:hashBan(reason, expiration, admin)
    local stdout = self:banSTDOUT({
        admin_name = admin.name,
        offender_name = offender.name,
        reason = reason,
        expiration = expiration,
    })

    admin:send(stdout)
    self:log(stdout, self.logging.management)
end

function util:ipBan(reason, time, admin)
    local name, hash, ip = self.name, self.hash, self.ip
    local ip_bans = self.bans['ip']
    ip_bans[ip] = self:newBan({
        admin_name = admin.name,
        offender_name = name,
        hash = hash,
        reason = reason,
        time = time,
        type = ip_bans
    })
    self:setPirated('ip', ip, hash)
    self:kick()
    self:updateBans()
end

function util:nameBan(target)

    local name_to_ban = target
    local player = self.players[target]

    if (type(target) == 'number') then
        name_to_ban = player.name
        player:kick()
    elseif (type(target) == 'string' and name_to_ban:len() > 11) then
        self:send('Name too long. Max 11 characters.')
        return
    end

    local ip = self.ip -- admin ip (for logging)
    local name = self.name -- admin name (for logging)
    local hash = self.hash -- admin hash (for logging)

    local name_bans = self.bans['name']

    name_bans[name_to_ban] = {
        name = name_to_ban, -- redundant but needed for the ban list
        added_by = name,
        added_on = self:getDate(),
        ip = ip,
        hash = hash,
        id = self:setBanID(name_bans)
    }

    self:send(_format('Added (%s) to the name-ban list.', name_to_ban))
    self:log(_format('%s name-banned (%s)', name, name_to_ban), self.logging.management)
    self:updateBans()
end

function util:mute(parent, child, reason, time, admin)
    local text_bans = self.bans['mute'][parent]
    text_bans[child] = self:newBan({
        admin_name = admin.name,
        offender_name = self.name,
        reason = reason,
        time = time,
        type = text_bans
    })
    self:updateBans()
end

function util:unban(args)

    local admin = args.admin
    local parent = args.parent
    local child = args.child
    local sub = args.sub

    local message = ''
    local entry = self.bans[parent][child]

    if (entry[sub]) then
        message = self.output:format(entry[sub].offender, sub)
        entry[sub] = nil
    else
        message = self.output:format(entry.offender, child)
        self.bans[parent][child] = nil
    end

    admin:send(message)
    self:updateBans()
end

local function isBanned(self, parent, child)
    if (self.bans[parent][child]) then
        self:kick()
        return true
    end
    return false
end

function util:rejectPlayer()

    if (self.id == 0) then
        return
    end

    local name = self.name
    local hash = self.hash
    local ip = self.ip
    local log = self.logging.management

    if (isBanned(self, 'hash', hash)) then
        self:log(_format('%s tried to join, but is hash-banned.', name), log)
        return true
    elseif (isBanned(self, 'ip', ip)) then
        self:log(_format('%s tried to join, but is ip-banned.', name), log)
        return true
    elseif (isBanned(self, 'name', name)) then
        self:log(_format('%s tried to join, but is name-banned.', name), log)
        return true
    elseif (self:isMuted()) then
        self:log(_format('%s joined and is muted.', name), log)
        return false -- allow muted players to join
    end

    return false
end

return util