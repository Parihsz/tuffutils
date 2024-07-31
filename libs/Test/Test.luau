type TestCase = {
	input: (() -> any) | { any },
	expected: (() -> any) | any,
}

type Options = {
	threshold: number?,
	timeLimit: number?,
	compare: ((a: any, b: any, threshold: number) -> boolean)?,
}

type Result = {
	input: (() -> any) | { any },
	expected: any,
	output: any,
	passed: boolean,
	error: string?,
	timeTaken: number,
}

local Test = {}

local function Equal(a: any, b: any, threshold: number): boolean
	if type(a) ~= type(b) then
		return false
	end

	if type(a) == "number" then
		return math.abs(a - b) <= (threshold or 0)
	end

	if type(a) ~= "table" then
		return a == b
	end

	local countA = 0
	local countB = 0

	for k, v in a do
		countA += 1
		if not Equal(v, b[k], threshold) then
			return false
		end
	end

	for _ in b do
		countB += 1
	end

	return countA == countB
end

local function MeasureTime(func: () -> any): (boolean, any, number)
	local startTime = os.clock()
	local success, result = pcall(func)
	local endTime = os.clock()

	return success, result, endTime - startTime
end

function Test.RunTests(testCases: { TestCase }, func: (...any) -> any, providedOptions: Options?): { Result }
	local options = providedOptions or {
		threshold = 0,
		compare = Equal,
		timeLimit = math.huge,
	}

	local threshold = options.threshold or 0
	local compare: any = options.compare or Equal
	local timeLimit = options.timeLimit or math.huge
	local results = table.create(#testCases)

	for _, testCase in testCases do
		local input = testCase.input
		local expected: any = testCase.expected

		local success, output, timeTaken = MeasureTime(function()
			if type(input) == "function" then
				return input()
			else
				return func(table.unpack(input))
			end
		end)

		local expectedOutput
		if type(expected) == "function" then
			expectedOutput = expected()
		else
			expectedOutput = expected
		end

		local passed = success and compare(output, expectedOutput, threshold) and timeTaken <= timeLimit
		local errorMsg = nil

		if not success then
			errorMsg = `Test case failed with input: {input}. Error: {output}`
		elseif timeTaken > timeLimit then
			errorMsg =
				`Test case failed with input: {input}. Time taken: {timeTaken} seconds exceeds time limit of {timeLimit} seconds`
		elseif not passed then
			errorMsg = `Test case failed with input: {input}. Expected: {expectedOutput} but got: {output}`
		end

		table.insert(results, {
			input = input,
			expected = expectedOutput,
			output = output,
			passed = passed,
			error = errorMsg,
			timeTaken = timeTaken,
		})
	end

	return results
end

function Test.Expect(actual: any)
	local matchers = {}

	function matchers.ToEqual(expected: any): boolean
		if actual ~= expected then
			return false
		end
		return true
	end

	function matchers.ToBeTruthy(): boolean
		if not actual then
			return false
		end
		return true
	end

	function matchers.ToBeFalsy(): boolean
		if actual then
			return false
		end
		return true
	end

	function matchers.ToBeReal(): boolean
		if type(actual) ~= "number" or tostring(actual):find("i$") then
			error(`Expected a real number but got {actual}`)
		end
		return true
	end

	function matchers.ToBeUTF8(): boolean
		if type(actual) ~= "string" or not actual:match("^[%z\1-\127\194-\244][\128-\191]*$") then
			return false
		end
		return true
	end

	function matchers.ToBeFinite(): boolean
		if type(actual) ~= "number" or actual ~= actual or actual == math.huge or actual == -math.huge then
			return false
		end
		return true
	end

	function matchers.ToBeNonNil(): boolean
		if actual == nil then
			return false
		end
		return true
	end

	return matchers
end

function Test.Benchmark(func: (...any) -> any, input: any, iterations: number): number
	local totalTime = 0

	for _ = 1, iterations do
		local _, _, timeTaken = MeasureTime(function()
			return func(table.unpack(input))
		end)
		totalTime += timeTaken
	end

	return totalTime / iterations
end

function Test.Race(functions: { [string]: (...any) -> any }, input: any, iterations: number): { string }
	local results = {}

	for name, func in functions do
		local averageTime = Test.Benchmark(func, input, iterations)
		table.insert(results, { name = name, time = averageTime })
	end

	table.sort(results, function(a, b)
		return a.time < b.time
	end)

	local rankedNames: { string } = {}
	for _, result in results do
		table.insert(rankedNames, result.name)
	end

	return rankedNames
end

return Test
