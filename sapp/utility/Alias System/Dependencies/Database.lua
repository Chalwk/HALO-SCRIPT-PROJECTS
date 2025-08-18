-- Alias System [Database File] (v1.0)
-- Copyright (c) 2022, Jericho Crosby

local Alias = {
    default = {
        hashes = {},
        ip_addresses = {}
    }
}

local open = io.open
function Alias:GetRecords()

    local content = ''
    local file = open(self.dir, 'r')
    if (file) then
        content = file:read('*all')
        file:close()
    end

    local data = self.json:decode(content)
    if (not data) then
        data = { hashes = {}, ip_addresses = {} }
        self:Update(data)
    end
    self.records = data

    return data
end

return Alias