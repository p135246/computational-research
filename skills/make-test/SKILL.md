---
name: make-test
description: >
  Create tests for a topic in a Wolfram research project using the Wolfram
  testing framework (VerificationTest + TestReport). Generates TopicTest.wl
  and creates or updates Test1.nb. Trigger on "make tests for X", "test X",
  "create tests", "add tests for X", "write tests", or "verify X".
---

# Make Test

Creates test files for an existing topic scope using the Wolfram testing framework.

## What you need

1. **Topic name** — the CamelCase scope name (e.g. `RicciCurvature`).
   Must match an existing `Code/<Topic>.wl`.
2. **Project root** — the directory containing `Code/`, `CLAUDE.md`, etc.

Read `Code/<Topic>.wl` to understand what functions exist and need testing.

## What to create

### 1. Test code file

Create `Code/<Topic>Test.wl`:
```wolfram
(* ::Package:: *)
SetDirectory[NotebookDirectory[]]
Get["Code/<Topic>.wl"]

tests = {
  VerificationTest[
    <function call>,
    <expected result>,
    TestID -> "<Topic>-<FunctionName>-basic"
  ],
  VerificationTest[
    <edge case call>,
    <expected result>,
    TestID -> "<Topic>-<FunctionName>-edge"
  ]
};
```

Write tests for each public function in `<Topic>.wl`:
- Basic correctness: known input → known output
- Edge cases: empty input, trivial cases, boundary values
- Type checking: verify output structure matches expectations

Use `VerificationTest` with descriptive `TestID` strings.

### 2. Test notebook

Create `Test1.nb` in the project root (or update existing).

If `Test1.nb` already exists, read it and append a new section for this topic
using the read → append → rewrite workflow.

Notebook structure for each topic section:
```
## <Topic> Tests
  Get["Code/<Topic>Test.wl"]
  report = TestReport[tests]
  report
  report["TestResults"] // Dataset
```

If creating `Test1.nb` from scratch:
```
# Tests
## Setup
  SetDirectory[NotebookDirectory[]]

## <Topic> Tests
  Get["Code/<Topic>Test.wl"]
  report = TestReport[tests]
  report
  report["TestResults"] // Dataset
```

Use the **create-notebook** skill's ExportString pipeline for creation.

### 3. Update CLAUDE.md

Add `<Topic>Test.wl` and `Test1.nb` to the Code structure section.

## After creating tests

Tell the user:
- How many tests were created and for which functions
- The test file location
- They can run all tests by evaluating the `<Topic> Tests` section in `Test1.nb`
- Mention `TestReport` output: shows pass/fail counts and details
