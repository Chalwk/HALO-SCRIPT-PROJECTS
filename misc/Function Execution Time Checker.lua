-- Table that holds the averages:
local times = { {}, {} }

-- How many times to execute the functions in question:
local iterations = 100000 -- 10mil iterations

-- How many times to run the test per function in question:
local test_iterations = 100

-- Performance test function:
local function PerformanceTest(method, func)
    for _ = 1, test_iterations do
        local t = os.clock()
        for i = 1, iterations do
            if (method == 1) then
                func(i)
            else
                func(i)
            end
            times[method][#times[method] + 1] = os.clock() - t
        end
    end
end

--
-- Execute performance tests:
--

-- first method:
PerformanceTest(1, function(i)
    local t = {}
    t[#t + 1] = i
end)

-- second method:
PerformanceTest(2, function(i)
    local t = {}
    table.insert(t, i)
end)

-- Gets the average times of t{}:
local function GetAverage(t)
    local time = 0
    for _, v in pairs(t) do
        time = time + v
    end
    return time / #t
end

-- Format @n to @p decimal places:
local function _nFormat(n, p)
    return ("%." .. p .. "f"):format(n)
end

-- Return seconds/ms based on n:
local function ms(n)
    return (n >= 1 and " seconds") or " ms"
end

local min = math.min
local max = math.max
local function PrintResults()

    -- Store averages:
    local t1 = GetAverage(times[1])
    local t2 = GetAverage(times[2])

    -- Get longest/shortest times:
    local longest = max(t1, t2)
    local shortest = min(t1, t2)

    -- Calculate fastest %:
    local remainder = (longest - shortest)
    local percent = _nFormat(remainder / longest * 100, 3)

    -- Format averages:
    local s1 = _nFormat(t1, 7) .. ms(t1)
    local s2 = _nFormat(t2, 7) .. ms(t2)

    -- Print results:
    if (t1 < t2) then
        print("METHOD 1 / " .. percent .. "% faster / Average time " .. s1)
        print("METHOD 2 finished in " .. s2)
    else
        print("METHOD 2 / " .. percent .. "% faster / Average time " .. s2)
        print("METHOD 1 finished in " .. s1)
    end
    print("Iterations: " .. iterations)
end

PrintResults()