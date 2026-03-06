---
name: add-topic
description: >
  Add a new topic scope to an existing Wolfram research project. Creates the
  core code file, visualization file, and a topic notebook with illustrated
  function calls. Used repeatedly during project scaffolding and independently
  later. Trigger on "add topic X", "new topic X", "create scope for X",
  "add X to the project", or when the computational-exploration skill needs
  to create the initial topic scope.
---

# Add Topic

Adds a new topic (functional scope) to the current research project.

## What you need

1. **Topic name** — CamelCase, e.g. `RicciCurvature`, `HypergraphEmbedding`.
   If called during scaffolding, the project name is the initial topic name.
2. **Topic description** — one sentence about what this scope covers.
3. **Project root** — the directory containing `Code/`, `CLAUDE.md`, etc.

If the user already provided these, don't ask again.

## What to create

### 1. Code files

Create two files in `Code/`:

**`Code/<Topic>.wl`** — core functions:
```wolfram
(* ::Package:: *)
BeginPackage["<Topic>`"]

(* function declarations go here *)

Begin["`Private`"]

(* function definitions go here *)

End[]
EndPackage[]
```

Populate with the main functions relevant to the topic. Each function should
have a clear name following the pattern `<Topic><Action>` (e.g.
`RicciCurvatureCompute`, `RicciCurvatureOnGraph`). Start with 2-5 functions
that cover the basic operations for the topic.

**`Code/<Topic>Visualization.wl`** — visualization functions:
```wolfram
(* ::Package:: *)
BeginPackage["<Topic>Visualization`"]

(* visualization function declarations *)

Begin["`Private`"]

(* visualization function definitions *)

End[]
EndPackage[]
```

Populate with visualization functions like `<Topic>Plot`, `<Topic>Show`,
`<Topic>Highlight`, etc. These should use the core functions from `<Topic>.wl`.

### 2. Topic notebook

Create `<Topic>1.nb` in the project root. If `<Topic>1.nb` already exists,
increment to `<Topic>2.nb`, etc.

Use the **create-notebook** skill's ExportString pipeline.

Notebook structure:
```
# <Topic>
## Setup
  Get["Code/Tools.wl"]
  Get["Code/<Topic>.wl"]
  Get["Code/<Topic>Visualization.wl"]

## <FunctionName1>
  Short description of what the function does.
  <example call>
  <expected output or description>

## <FunctionName2>
  ...

(repeat for each main function)
```

Each function section should contain:
- A brief text description (1-2 sentences)
- One or more example calls showing typical usage
- A short note on expected output

### 3. Update CLAUDE.md

Append the new scope to the Code structure section in the project's `CLAUDE.md`:
```
- `Code/<Topic>.wl` + `<Topic>Visualization.wl` — <brief description>
```

## After adding the topic

Tell the user:
- What files were created
- List the main functions defined
- The notebook is ready at `<Topic>N.nb`
- They can add experiments later with `/computational-research:make-experiment`
- They can add tests later with `/computational-research:make-test`
