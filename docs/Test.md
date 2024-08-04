# Test

This module provides functionality to run tests flexibly, quickly/accurately benchmark, and race various functions.

## Types

### `Compare`
The type for the custom comparison function.

### `TestCase`
Represents a single test case.

- `input: (() -> { any }) | { any }`
  - The input to the function being tested. This can be a function that returns the input or an array of inputs of type `any`.

- `expected: (() -> any) | any`
  - The expected output from the function being tested. This can be a function that returns the expected output or a direct value of type `any`.

### `Options`
Represents optional settings for running tests.

- `threshold: number?`
  - An optional threshold for numerical comparisons, allowing for small differences due to floating point precision.

- `timeLimit: number?`
  - An optional time limit in seconds for each test case. If the function takes longer than this, the test will fail.

- `compare: Compare?`
  - An optional custom comparison function to compare the actual and expected outputs.

### `Result`
Represents the result of a single test case.

- `input: (() -> { any }) | { any }`
  - The input to the function being tested.

- `expected: any`
  - The expected output from the function being tested.

- `output: any`
  - The actual output from the function being tested.

- `passed: boolean`
  - Whether the test passed or not.

- `error: string?`
  - The error message if the test failed.

- `timeTaken: number`
  - The time taken to run the test case.

## Functions

### `Test.RunTests(testCases: { TestCase }, func: (...any) -> any, providedOptions: Options?): { Result }`
Runs a set of test cases on a specified function and returns the results.

- `testCases`: An array of `TestCase` objects to be tested.
- `func`: The function to be tested.
- `providedOptions`: Optional settings for running the tests.

#### Returns
An array of `Result` objects.

### `Test.Expect(actual: any)`
Creates a set of matchers to assert the value of `actual`.

#### Matchers
- `ToEqual(expected: any): boolean`
  - Checks that `actual` is equal to `expected`.

- `ToBeTruthy(): boolean`
  - Checks that `actual` is truthy.

- `ToBeFalsy(): boolean`
  - Checks that `actual` is falsy.

- `ToBeReal(): boolean`
  - Checks the actual value is a real number (not NaN or an imaginary number).

- `ToBeUTF8(): boolean`
  - Checks the actual value is a valid UTF-8 string.

- `ToBeFinite(): boolean`
  - Checks the actual value is a finite number (not NaN or infinity).

- `ToBeNonNil(): boolean`
  - Checks the actual value is not nil.

### `Test.Benchmark(func: (...any) -> any, input: { any }, iterations: number): number`
Benchmarks a function by running it multiple times and returns the average time taken.

- `func`: The function to be benchmarked.
- `input`: The input to the function.
- `iterations`: The number of times to run the function.

#### Returns
The average time taken per iteration.

### `Test.Race(functions: { (...any) -> any }, input: { any }): any`
Runs several functions concurrently and returns the result of the function that completes first.

- `functions`: A table of functions to be raced.
- `input`: The input to be passed to the functions.

#### Returns
The result of the first function to complete.

## Usage

```lua
local Test = require(Test)

local function add(a, b)
    return a + b
end

local testCases = {
    {input = {1, 2}, expected = 3},
    {input = {2, 3}, expected = 5},
    {input = {10, 5}, expected = 15},
}

local options = {
    threshold = 1e-9, --The default, the avoid floating point errors. Can set to 0 if you want.
    timeLimit = 1, --Time limit for the function to run. 
    compare = nil --If you want your own way to compare. In this case, the test module's equal method should work so we don't need it.
}
local addResults = Test.RunTests(testCases, add, options)

for i, result in addResults do
    if result.passed then
        print(`Test Case {i}`)
    else
        warn(`Test Case {i}`) --Alternatively, you can use error() which will skip the rest of the test cases.
    end
    print(`Input: {table.concat(result.input, ", ")}`)
    print(`Expected: {result.expected}`)
    print(`Output: {result.output or result.error}`)
    print(`Passed: {result.passed}`)
    print(`Time Taken: {result.timeTaken}s`)
end
```

#### Matchers
- `ToEqual(expected: any): boolean`
  - Checks that `actual` is equal to `expected`.

- `ToBeTruthy(): boolean`
  - Checks that `actual` is truthy.

- `ToBeFalsy(): boolean`
  - Checks that `actual` is falsy.

- `ToBeReal(): boolean`
  - Checks the actual value is a real number (not NaN or an imaginary number).

- `ToBeUTF8(): boolean`
  - Checks the actual value is a valid UTF-8 string.

- `ToBeFinite(): boolean`
  - Checks the actual value is a finite number (not NaN or infinity).

- `ToBeNonNil(): boolean`
  - Checks the actual value is not nil.

### `Test.Benchmark(func: (...any) -> any, input: any, iterations: number): number`
Benchmarks a function by running it multiple times and returns the average time taken.

- `func`: The function to be benchmarked.
- `input`: The input to the function.
- `iterations`: The number of times to run the function.

#### Returns
The average time taken per iteration.

### `Test.Race



## Usage

```lua
local Test = require(Test)

local function add(a, b)
    return a + b
end

local testCases = {
    {input = {1, 2}, expected = 3},
    {input = {2, 3}, expected = 5},
    {input = {10, 5}, expected = 15},
}

local options = {
    threshold = 1e-9, --The default, the avoid floating point errors. Can set to 0 if you want.
    timeLimit = 1, --Time limit for the function to run. 
    compare = nil --If you want your own way to compare. In this case, the test module's equal method should work so we don't need it.
}
local addResults = Test.RunTests(testCases, add, options)

for i, result in addResults do
    if result.passed then
        print(`Test Case {i}`)
    else
        warn(`Test Case {i}`) --Alternatively, you can use error() which will skip the rest of the test cases.
    end
    print(`Input: {table.concat(result.input, ", ")}`)
    print(`Expected: {result.expected}`)
    print(`Output: {result.output or result.error}`)
    print(`Passed: {result.passed}`)
    print(`Time Taken: {result.timeTaken}s`)
end
```

## Matcher
```lua
local expect = Test.Expect(5)
assert(expect.ToEqual(5)) -- true
assert(not expect.ToEqual(6)) -- false

local expectTruthy = Test.Expect(true)
assert(expectTruthy.ToBeTruthy()) -- true
local expectFalsy = Test.Expect(false)
assert(not expectFalsy.ToBeTruthy()) -- false

local expectFalse = Test.Expect(false)
assert(expectFalse.ToBeFalsy()) -- true
local expectTrue = Test.Expect(true)
assert(not expectTrue.ToBeFalsy()) -- false

local expectReal = Test.Expect(5)
assert(expectReal.ToBeReal()) -- true
local expectNaN = Test.Expect(0/0)
assert(not expectNaN.ToBeReal()) -- false

--The use case for these would be to patch datastore vulnerabilities where you can rollback data. 
--For more info, https://gist.github.com/TheGreatSageEqualToHeaven/e0e1dc2698307c93f6013b9825705899

local expectUTF8 = Test.Expect("Hello, World!")
assert(expectUTF8.ToBeUTF8()) -- true
local expectNonUTF8 = Test.Expect("\255\255\255")
assert(not expectNonUTF8.ToBeUTF8()) -- false

local expectFinite = Test.Expect(5)
assert(expectFinite.ToBeFinite()) -- true
local expectNaNFinite = Test.Expect(0/0)
assert(not expectNaNFinite.ToBeFinite()) -- false

local expectNonNil = Test.Expect(5)
assert(expectNonNil.ToBeNonNil()) -- true
local expectNil = Test.Expect(nil)
assert(not expectNil.ToBeNonNil()) -- false
```

## Benchmarking and Race

### Benchmarking
```lua
local Test = require(Test)

local functionsToBenchmark = {
    Vector3Add = function()
        local v1 = Vector3.new(1, 0, 2)
        local v2 = Vector3.new(3, 0, 4)
        for _ = 1, 1000 do
            local result = v1 + v2
        end
    end,
    Vector2Add = function()
        local v1 = Vector3.new(1, 2)
        local v2 = Vector3.new(3, 4)
        for _ = 1, 1000 do
            local result = v1 - v2
        end
    end,
}

print("Benchmark Results (average time over 1000 iterations):")
for name, func in functionsToBenchmark do
    local averageTime = Test.Benchmark(func, {}, 1000)
    print(`{name}: {averageTime} seconds`)
end
```

### Racing
```lua
local Test = require(Test)

local function V1(str)
    task.wait(5)
    return str .. `{str}! I took 5 seconds`
end

local function V2(str)
    task.wait(2)
    return `{str}! I took 2 seconds`
end

local function V3(str)
    task.wait(3)
    return `{str}! I took 3 seconds`
end

local input = { "Hello" }

local result = Test.Race({ V1, V2, V3 }, input)
print(result)  -- Expected to print: "Hello! I took 2 seconds" since it will finish first

```