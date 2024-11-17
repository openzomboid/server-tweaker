-- getFileWriter writes data to file.
-- r  - read mode
-- w  - write mode (overwrites existing)
-- a  - append mode (appends to existing)
-- b  - binary mode
-- r+ - update mode (existing data preserved)
-- w+ - update mode (existing data erased)
-- a+ - append update mode (existing data preserved, append at end of file only)
-- TODO: createIfNull is wrong here.
function getFileWriter(filename, createIfNull, append)
    local mode = "w"
    if createIfNull == true then
        mode = "w+"
    elseif append == true then
        mode = "a"
    end
    filename = os.getenv("TESTDATA_PATH") .. "/" .. filename
    local file = io.open(filename, mode)

    local writer = {}

    function writer:exists()
        return file ~= nil
    end

    function writer:write(line)
        if not writer:exists() then return nil end

        file:write(line)
    end

    function writer:close()
        if file then file:close() end
    end

    return writer
end

function getFileReader(filename, createIfNull)
    local mode = "r"
    if createIfNull == true then
        mode = "r+"
    end
    filename = os.getenv("TESTDATA_PATH") .. "/" .. filename
    local file = io.open(filename, mode)
    local seek = 0

    local reader = {}

    function reader:exists()
        return file ~= nil
    end

    function reader:readAll()
        if not reader:exists() then return {} end

        local lines = {}
        while true do
            local line = file:read()
            if line == nil then break end

            lines[#lines + 1] = string.gsub(line, "\r", "")
        end

        return lines
    end

    local lines = reader:readAll()

    function reader:readLine()
        if seek < #lines then
            seek = seek+1
            return lines[seek]
        end

        return nil
    end

    function reader:close()
        if file then file:close() end
    end

    return reader
end

function getPlayerScreenLeft(playerNum)
    return 1920
end

function getPlayerScreenWidth(playerNum)
    return 1080
end

function getText(code)
    return "test text"
end

function getTextManager()
    return TextManager
end

function getServerOptions()
    return ServerOptions
end

function getCore()
    return Core
end

function getTexture(name)
    return {}
end

function getCell()
    return IsoCell
end
