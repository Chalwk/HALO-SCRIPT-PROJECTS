-- Alias System [New Alias File] (v1.0)
-- Copyright (c) 2022, Jericho Crosby

local Alias = {}

local date = os.date
local function Date()
    local day = date('*t').day
    local month = date('*t').month
    local year = date('*t').year
    return day .. '-' .. month .. '-' .. year
end

function Alias:New(o)

    setmetatable(o, self)
    self.__index = self

    local date_stamp = Date()
    local hashes = self.records.hashes
    local ip_addresses = self.records.ip_addresses

    hashes[o.hash] = hashes[o.hash] or {}
    hashes[o.hash].last_activity = date_stamp
    hashes[o.hash][o.name] = ''

    ip_addresses[o.ip] = ip_addresses[o.ip] or {}
    ip_addresses[o.ip].last_activity = date_stamp
    ip_addresses[o.ip][o.name] = ''

    if (self.update_file_on_join) then
        self:Update()
    end

    return o
end

return Alias