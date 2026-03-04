---
name: wolfram-notebook
description: >
  Create Wolfram Notebooks (.nb) from structured content using the Wolfram MCP.
  Use this skill whenever the user asks to create a notebook, generate a .nb file,
  make a Wolfram/Mathematica notebook, or produce notebook-formatted output.
  Also trigger when the user says things like "put this in a notebook",
  "notebook about X", "create a .nb for Y", "make me a notebook with...",
  or any request where the natural deliverable is a Wolfram Notebook file.
  Even if the user just says "notebook" casually, this skill likely applies.
  Do NOT use this skill for reading or editing existing .nb files — only for creation.
---

# Wolfram Notebook Creator

This skill creates Wolfram Notebooks (.nb) by converting carefully structured Markdown
into notebook expressions via the Wolfram MCP. The core technique is:

```
ExportString[ImportString[markdownString, {"Markdown", "Notebook"}], "NB"]
```

No temporary files are created on any filesystem. The markdown lives as a string in the
Wolfram kernel, gets imported as a Notebook expression, post-processed, then serialized
back to a string via `ExportString`. You then write that string to the target `.nb` file
using the local `Write` tool.

## Which MCP tool to use

Use MCP tools in this priority order:

1. **Official Wolfram MCP** — `mcp__Wolfram__WolframLanguageEvaluator` (capital-W "Wolfram")
   This is the primary tool. Use it whenever available.

2. **Unofficial Wolfram MCP** — `mcp__wolfram__evaluate` (lowercase "wolfram")
   Use as fallback if the official MCP is not available or returns an error.
   Same Wolfram Language code works with both tools.

3. **Last resort** — If neither MCP is available, create a minimal plain-text `.nb`
   file manually using the Write tool with the raw NB format. Warn the user that
   the notebook will not render cell styles correctly without Mathematica opening it
   to evaluate.

To check which MCP is active, call `mcp__wolfram__ping` (unofficial) or attempt a
test evaluation with `1+1` before building the full notebook.

## Backtick escaping — Critical

The Wolfram MCP interprets raw backtick characters (`` ` ``) as Wolfram context marks.
This means triple-backtick fences (`` ``` ``) in markdown strings get corrupted if
written as literal characters.

**Always construct backticks via `FromCharacterCode`:**

```
tick = FromCharacterCode[96];
fence = StringJoin[tick, tick, tick];
```

Then use `fence` when building the markdown string:

```
md = "# Title\n\n" <> fence <> "wolfram\nPlot[Sin[x],{x,0,2Pi}]\n" <> fence <> "\n\n";
```

For inline code, use a single `tick`. For Wolfram package names containing context
marks (e.g., `"Needs[\"MyPackage`\""]`), use:
```
"Needs[\"MyPackage" <> tick <> "\"]"
```

This is the single most important rule. Without it, code blocks will not parse as
Input cells.

## Why ExportString instead of Export

The Wolfram MCP kernel runs in a separate process with its own filesystem. `Export[...]`
writes to the kernel's filesystem, which is **not** the local filesystem where the
user's files live. Use `ExportString` to get the `.nb` content as a string, then use
the `Write` tool to save it locally.

## Pipeline

1. **Compose** well-structured Markdown following the mapping rules below
2. **Evaluate** via the Wolfram MCP: build string → `ImportString` → post-process → `ExportString`
3. **Write** the returned string to the target `.nb` file using the `Write` tool
4. **Verify** by calling `mcp__wolfram__list_cells` on the written file to confirm cell count

## Named templates

When the user doesn't specify a structure, ask which template fits best (or infer from context):

### `research` template
```
# <Title>
## Setup        ← package loads (become InitializationCells)
## Exploration  ← initial computations and visualizations
## Results      ← key findings and summaries
## Discussion   ← interpretation, conjectures, next steps
```

### `paper-analysis` template
```
# <Title>
## Paper Metadata   ← full title, authors, year, arXiv ID
## Summary          ← 3–4 sentence abstract in own words
## Key Definitions  ← brief explanations of terms
## Key Results      ← one sentence per theorem/result
## Relevance        ← connection to current project
## Code             ← reproduce or verify key computations
```

### `computation` template
```
# <Title>
## Setup          ← package loads and configuration
## Algorithm      ← pseudocode or description (CodeText cells)
## Implementation ← actual Wolfram Language code
## Tests          ← verification against known cases
## Visualization  ← plots and graphics
```

## Markdown-to-cell mapping

### Headings → Notebook Structure

| Markdown | Cell Style | Notebook Role |
|----------|-----------|---------------|
| `# Title` | `"Title"` | Notebook title (use once, at top) |
| `## Chapter` | `"Chapter"` | Major division |
| `### Section` | `"Section"` | Section heading |
| `#### Subsection` | `"Subsection"` | Subsection heading |
| `##### Subsubsection` | `"Subsubsection"` | Subsubsection heading |

### Text and Formatting

| Markdown | Result |
|----------|--------|
| Plain paragraph | `Cell["...", "Text"]` |
| `**bold**` | `StyleBox["...", FontWeight->Bold]` |
| `*italic*` | `StyleBox["...", FontSlant->Italic]` |
| inline code (single backtick) | `Cell["...", "InlineCode"]` within TextData |
| `[text](url)` | Clickable hyperlink (ButtonBox) |
| `> blockquote` | Text cell with left border frame |

### Lists

| Markdown | Cell Style |
|----------|-----------|
| `- item` | `"Item"` |
| `  - subitem` (2-space indent) | `"Subitem"` |
| `1. first` | `"ItemNumbered"` |

### Code blocks

| Markdown fence tag | Cell Style | Purpose |
|----------|-----------|---------|
| `wolfram` | `"Input"` | Evaluatable Wolfram code |
| (no tag) | `"Program"` → post-processed to `"CodeText"` | Display-only code |

Use `wolfram` fenced code blocks for evaluatable Wolfram Language input cells.

### Tables

Standard Markdown tables become interactive Tabular/TableView cells.

## Post-processing

After `ImportString`, apply these transformations before `ExportString`:

### 1. Rename `"Program"` → `"CodeText"`

```wolfram
cells /. Cell[content_, "Program", opts___] :> Cell[content, "CodeText", opts]
```

### 2. Initialization cells

Mark Input cells under a "Setup"/"Initialization"/"Dependencies" heading as
initialization cells (auto-evaluate on notebook open):

```wolfram
markInitCells[cellList_List] := Module[{inSetup = False, result = {}},
  Do[Which[
    MatchQ[c, Cell[t_String, "Chapter"|"Section"|"Subsection", ___] /;
      StringMatchQ[t, ("*Setup*"|"*Initialization*"|"*Preamble*"|"*Dependencies*"),
        IgnoreCase -> True]],
      inSetup = True; AppendTo[result, c],
    MatchQ[c, Cell[_, "Title"|"Chapter"|"Section"|"Subsection"|"Subsubsection", ___]],
      inSetup = False; AppendTo[result, c],
    inSetup && MatchQ[c, Cell[_, "Input", ___]],
      AppendTo[result, Append[c, InitializationCell -> True]],
    True, AppendTo[result, c]
  ], {c, cellList}];
  result
];
```

Note: uses `StringMatchQ` with wildcards (not `StringContainsQ`) to avoid false
positives. For example, `"Indefinite Integrals"` must NOT trigger as an init section.

## The complete Wolfram MCP call

Build the full pipeline as a single MCP evaluator call:

```wolfram
Module[{md, nb, cells, markInitCells, tick, fence},

  tick = FromCharacterCode[96];
  fence = StringJoin[tick, tick, tick];

  markInitCells[cellList_List] := Module[{inSetup = False, result = {}},
    Do[Which[
      MatchQ[c, Cell[t_String, "Chapter"|"Section"|"Subsection", ___] /;
        StringMatchQ[t, ("*Setup*"|"*Initialization*"|"*Preamble*"|"*Dependencies*"),
          IgnoreCase -> True]],
        inSetup = True; AppendTo[result, c],
      MatchQ[c, Cell[_, "Title"|"Chapter"|"Section"|"Subsection"|"Subsubsection", ___]],
        inSetup = False; AppendTo[result, c],
      inSetup && MatchQ[c, Cell[_, "Input", ___]],
        AppendTo[result, Append[c, InitializationCell -> True]],
      True, AppendTo[result, c]
    ], {c, cellList}];
    result
  ];

  md = StringJoin[
    "# My Notebook Title\n\n",
    "Introductory text.\n\n",
    "## Setup\n\n",
    fence, "wolfram\nNeeds[\"Pkg", tick, "\"]\n", fence, "\n\n",
    "## Analysis\n\n",
    "Explanatory text.\n\n",
    fence, "wolfram\nPlot[Sin[x], {x, 0, 2 Pi}]\n", fence, "\n"
  ];

  nb = ImportString[md, {"Markdown", "Notebook"}];
  cells = First[nb];
  cells = cells /. Cell[content_, "Program", opts___] :> Cell[content, "CodeText", opts];
  cells = markInitCells[cells];
  ExportString[Notebook[cells], "NB"]
]
```

## After the MCP call

1. Take the string returned by the MCP and write it to the target file:
   ```
   Write tool → target_path/NotebookName.nb → content from ExportString result
   ```

2. **Verify** by calling `mcp__wolfram__list_cells` on the written file. Compare
   the returned cell count to the number of sections and code blocks you defined.
   If there is a large discrepancy, diagnose with
   `ImportString[md, {"Markdown", "Notebook"}] // InputForm` to see what parsed.

## String construction rules

Always build the markdown with `StringJoin` (or `<>`) using `fence` and `tick` variables.
Never write literal backtick characters in the string.

**Escaping rules** (markdown lives inside a Wolfram Language string):

- `\` → `\\`
- `"` → `\"`
- Newlines: `\n`
- Backticks: NEVER literal — always use `tick` / `fence` variables
- Wolfram context marks: use `tick` variable, e.g. `"Needs[\"Package" <> tick <> "\"]"`

## Long notebook pattern

For notebooks with more than ~30 cells, build the markdown in per-section chunks to
avoid string length issues in the MCP:

```wolfram
section1 = StringJoin["## Section 1\n\n", "Text.\n\n", fence, "wolfram\n...\n", fence, "\n\n"];
section2 = StringJoin["## Section 2\n\n", "Text.\n\n", fence, "wolfram\n...\n", fence, "\n\n"];
md = StringJoin["# Title\n\n", section1, section2];
```

Build each section as a separate variable first, then join them. This also makes it
easier to debug which section is causing a parse issue.

## Content best practices

- One `# Title` at the top — only once
- `## Setup` for package loads and configuration (becomes initialization cells)
- One logical operation per `wolfram` code block (each becomes a separate Input cell)
- Narrative Text paragraphs between code blocks to explain what's happening
- Bullet lists for enumerated points
- Tables for structured comparisons
- Untagged fences for pseudocode or expected output (become CodeText)
- Bold (`**term**`) for key terms in explanations
- Keep code blocks focused and well-commented
