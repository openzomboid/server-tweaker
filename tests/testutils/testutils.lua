--
-- Copyright (c) 2024 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

string.startswith = function(self, str)
    return self:find('^' .. str) ~= nil
end

testutils = {}

-- scandir recursively finds all lua files in directory and returns them.
function testutils.scandir(directory)
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('find '..directory..' -type f -name "*.lua"')

    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename
    end

    pfile:close()

    return t
end

-- dotdir executes files in directory.
function testutils.dotdir(directory)
    for _, v in pairs(testutils.scandir(directory)) do
        if string.sub(v, -4) == '.lua' and not v:find('_test.lua') then
            dofile(v)
        end
    end
end

function testutils.dotdirtests(directory)
    for _, v in pairs(testutils.scandir(directory)) do
        if string.sub(v, -4) == '.lua' and v:find('_test.lua') then
            dofile(v)
        end
    end
end

function testutils.printTestFiles(directory)
    for _, v in pairs(testutils.scandir(directory)) do
        if string.sub(v, -4) == '.lua' and v:find('_test.lua') then
            print(v)
        end
    end
end

function testutils.green(msg)
    return "\27[32m" .. msg.. "\27[0m"
end

function testutils.red(msg)
    return "\27[31m" .. msg.. "\27[0m"
end

function testutils.len(obj)
    local c = 0
    for _ in pairs(obj) do
        c = c + 1
    end

    return c
end

function testutils.runtests()
    if not testutils.tests then
        testutils.tests = {}
    end

    local testPattern = os.getenv("TEST_PATTERN")

    local ordered = {}

    for key, item in pairs(_G) do
        if type(item) == "function" and key:startswith('Test_') then
            if (testPattern and key:startswith(testPattern)) or not testPattern then
                if not testutils.tests[key] then
                    testutils.tests[key] = item

                    table.insert(ordered, {name = key, fn = item})
                end
            end
        end
    end

    table.sort(ordered, function (a, b) return (a.name < b.name) end)

    for _, value in ipairs(ordered) do
            print("[ RUN  ] " .. value.name)

            local passed = value.fn()
            if passed then
                print(testutils.green("[ PASS ] ") .. value.name)
            else
                print(testutils.red("[ FAIL ] ") .. value.name)
            end
    end

    if testutils.len(testutils.tests) == 0 then
        print("> " .. "No tests available")
    end
end
