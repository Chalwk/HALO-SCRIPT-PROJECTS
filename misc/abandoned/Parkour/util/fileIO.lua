local fileIO = {}

function fileIO:readFile(filePath)
    local file, err = io.open(filePath, "r")
    if file then
        local content = file:read("*all")
        file:close()
        return content
    else
        return nil, err
    end
end

function fileIO:writeFile(filePath, content)
    local file, err = io.open(filePath, "w")
    if file then
        local jsonContent = self.json:encode_pretty(content)
        file:write(jsonContent)
        file:close()
    else
        return nil, err
    end
end

function fileIO:loadStats()

    local content, err = self:readFile(self.database_path)
    if not content then
        return nil, err
    end

    local ip = self.ip
    local parkourTimesDB = self.json:decode(content)

    if parkourTimesDB[ip] then
        return parkourTimesDB[ip]
    end

    parkourTimesDB[ip] = {
        name = self.name,
        [self.map] = {
            bestTime = 0,
            checkpoints = {}
        }
    }
    return parkourTimesDB[ip]
end

return fileIO