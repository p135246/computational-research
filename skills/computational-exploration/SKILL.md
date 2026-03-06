---
name: computational-exploration
description: >
  Scaffold a new Wolfram-model research project with the standard folder structure
  (Code/, Resources/, Article/, numbered notebooks) and pre-populated templates,
  then perform computational exploration. Also use this skill to perform
  computational explorations within an existing research project, adding results
  to it. Use this skill whenever Pavel asks to start a new project, create a new
  research project, set up a project folder, scaffold a project, begin investigating
  a new topic, or explore something computationally. Trigger on phrases like
  "new project on X", "let's start a project about Y", "set up folders for Z",
  "init project", "explore X computationally", "investigate Y", or "let's look
  into Z". Even if he just says "I want to explore [topic]" and it sounds like
  the beginning of a new research effort or computational exploration, use this skill.
---

# Wolfram-Model Research Project Scaffolder

You are setting up a new research project for the user.
Every project follows the same physical layout and intellectual pattern: it connects
some area of mathematics or physics to Wolfram models (hypergraph rewriting, multiway
systems, rulial space, etc.) and develops the connection through Wolfram Language
computation and structured research notes in LaTeX.

## What to ask the user

Before scaffolding, you need:

1. **Project name** — a CamelCase name like `SyntheticInfrageometry` or
   `DiscreteRicciFlow`. This becomes the root folder name and the base name for
   notebooks.
2. **Topic description** — a sentence or two about what the project is about.
   For example: "Studying axiomatic geometry on graphs using shortest-path metrics"
   or "Ollivier-Ricci curvature on hypergraph rewriting systems". This goes into
   the CLAUDE.md and the research notes abstract.
3. **Research depth** (optional) — how deep to go. See next section.

The scaffold script also fills in the **author name** and **email** for LaTeX
templates. Infer these from the user's profile or chat context. If unknown,
the script defaults to `Pavel H\'ajek` / `p135246@gmail.com`.

If the user already provided the project name and topic in their message, don't
ask again.

## Research depth

The user can request different levels of depth. Detect from their wording:

| Level | Triggers | Papers | Step 7b | Topic scope |
|-------|----------|--------|---------|-------------|
| **Short** | "short", "quick", "brief", "just the basics" | 1 key paper | Skip | Minimal functions, brief notebook |
| **Standard** (default) | — | 2–5 papers | Full | Thorough initial topic |
| **Deep** | "deep", "thorough", "comprehensive" | Exhaustive search | Full + extra sources | Multiple initial topics, detailed implementations |

This affects:
- Step 7: number of papers downloaded
- Step 7b: whether to search Wolfram Community (skip for short)
- add-topic calls: how many functions to create, how detailed the notebook

## Cowork mode vs local mode

This skill runs in two environments:

- **Local mode** (default): Claude runs on the user's machine. The filesystem is
  directly accessible to both scripts and MCP tools. `mcp__wolfram__create_notebook`
  can write to any local path.
- **Cowork mode**: Claude runs in a remote VM. The user's workspace is mounted
  (typically at a path like `/sessions/<id>/mnt/<folder>/`). Key differences:
  - The Wolfram MCP kernel runs in a **separate** environment and **cannot** write
    to the mounted filesystem (you'll get `[Errno 30] Read-only file system`).
  - The scaffold script must be told where to write files (the mounted workspace
    path), since its default CWD is the VM session root, not the workspace.
  - Notebook creation must use the **ExportString fallback** exclusively — generate
    the notebook content as a string via MCP, then write it to the mounted
    filesystem using the Write/Bash tool.

**Detection heuristic**: Cowork mode is likely when:
- The working directory contains `/sessions/` or `/mnt/` in its path, or
- `check-env.sh` reports no local Wolfram MCP, but `mcp__wolfram__ping` succeeds

When Cowork mode is detected, set `WORKSPACE_PATH` to the mounted workspace
directory (the directory where the project folder should be created) and use it
throughout.

## Step 0: Environment check (before anything else)

Run `${CLAUDE_PLUGIN_ROOT}/scripts/check-env.sh` to verify the environment.

Then, **regardless of what the script reports**, test MCP availability directly
by calling `mcp__wolfram__ping`. This is the authoritative test — the script can
only detect local MCP installations, but in Cowork mode the MCP is available
remotely.

Use the combined results to determine the mode:

| check-env.sh MCP result | mcp__wolfram__ping | Mode |
|-------------------------|--------------------|------|
| Detected | pong | Local — use MCP tools directly |
| Not detected | pong | **Cowork** — MCP works but can't write to local filesystem |
| Not detected | fails | No MCP — use ExportString fallback or skip notebooks |
| Detected | fails | Unusual — try ExportString fallback |

- If **wolframscript is missing**: warn the user, then proceed with all non-notebook
  steps. Skip notebook creation (steps 6 and 6b) and note at the end that notebooks
  must be created manually once Wolfram is installed.
- If **Wolfram MCP is unavailable** (both local detection and ping fail): notebook
  creation will use the ExportString fallback described in step 6. Proceed normally.
- If **both are missing**: scaffold files only; note both limitations clearly.
- If **Cowork mode detected**: set `WORKSPACE_PATH` to the mounted workspace directory
  and pass it to the scaffold script. Use ExportString for all notebook creation.

## Folder structure to create

```
<ProjectName>/
├── CLAUDE.md
├── <Topic>1.nb                ← topic notebook (created by add-topic skill)
├── Test1.nb                   ← test notebook (created by make-test skill, not at scaffold time)
├── Code/
│   ├── Tools.wl               ← shared general utilities
│   ├── <Topic>.wl             ← core functions (created by add-topic)
│   ├── <Topic>Visualization.wl  ← visualization (created by add-topic)
│   ├── <Topic>Experiment.wl   ← experiments (created by make-experiment, not at scaffold time)
│   └── <Topic>Test.wl         ← tests (created by make-test, not at scaffold time)
├── Resources1.nb              ← paper summaries notebook (one section per paper)
├── Resources/                 ← reference PDFs only (Author_Year_Title.pdf)
└── Article/
    ├── article1.tex           ← LaTeX scaffold for user's article (user writes here)
    ├── notes1.tex             ← article-form working notes (Claude writes here on request)
    └── references.bib         ← BibTeX file with header comment
```

`<Topic>` starts as `<ProjectName>` for the initial scope. New topics are added
via `/computational-research:add-topic`.

All created files use number suffixes (`<Topic>1.nb`, `Resources1.nb`, etc.).
When the user asks for a new notebook, increment the number (`<Topic>2.nb`,
`Resources2.nb`). Edits to an existing file keep the same number unless the user
explicitly asks for a new one.

## Step-by-step

### 1. Scaffold directories and file templates (script)

Run the scaffold script:

**Local mode:**
```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/scaffold-project.sh" "<ProjectName>" "<topic description>" "." "<Author Name>" "<email>"
```

**Cowork mode** (pass the mounted workspace path as third argument):
```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/scaffold-project.sh" "<ProjectName>" "<topic description>" "$WORKSPACE_PATH" "<Author Name>" "<email>"
```

The script `cd`s into the output directory before creating the project tree, so
all paths resolve correctly regardless of where the shell's CWD is.

The script creates:
- `<ProjectName>/Code/Tools.wl` — shared general utilities
- `<ProjectName>/CLAUDE.md` — from claude_template.md with substitutions
- `<ProjectName>/Article/article1.tex` — LaTeX article scaffold
- `<ProjectName>/Article/notes1.tex` — working notes file
- `<ProjectName>/Article/references.bib` — with standard Wolfram references

**Note:** The script does NOT create topic-specific code files (`<Topic>.wl`,
`<Topic>Visualization.wl`). Those are created by the add-topic skill in step 6.

If the script fails (e.g., permission issue), fall back to creating these files
manually using the templates in `${CLAUDE_PLUGIN_ROOT}/skills/computational-exploration/assets/`.

The generated CLAUDE.md uses the template from `assets/claude_template.md`:
replace `{{PROJECT_NAME}}` with the actual project name and `{{TOPIC_DESCRIPTION}}`
with the user's topic description. Fill in 2-3 concrete goals inferred from the
topic. The CLAUDE.md serves as the persistent memory for the project — write it
as if explaining the project to a colleague who will pick it up cold.

### 2. article1.tex purpose

The LaTeX article scaffold (`Article/article1.tex`) is the **user's writing space** — a
minimal skeleton with just an Introduction section and a Bibliography. The user adds
new sections as the article develops. Don't fill it with content — keep it clean.

### 3. notes1.tex purpose and rules

`notes1.tex` is a **collection of topic sections** that serves as working notes and
source material for `article1.tex`. Each section covers one topic — a definition,
a result, an observation, a conjecture, etc. Notes accumulate as a flat list of
topic sections. Claude writes to it when explicitly asked; the user draws from it
when composing the final article.

**Usage rules for notes1.tex:**
- **Only write when the user explicitly asks.** Triggers: "note this", "write this
  down", "record that", "add to notes". Do not auto-append during normal work.
- Each new topic gets its own `\section{}`. Keep sections concise and self-contained.
- Write mathematically precise text with citations where applicable.
- Include tentative conjectures, open questions, partial results.

**Versioning rule (important):**
When `notes1.tex` grows past ~300 lines of content (excluding the preamble), or when
the user explicitly asks to start a fresh notes file:
1. Add a pointer at the end of the current file: "Continued in notes2.tex"
2. Create `notes2.tex` with a back-pointer at the top
3. Continue appending to the new file

### 4. Create references.bib

Already created by the scaffold script with standard Wolfram-model references.
Add additional BibTeX entries whenever papers are downloaded (step 7).

### 5. Code files and scope convention

The Code/ layout follows a topic-based scope pattern. Each topic can have up to
four files:

- **`Tools.wl`** — shared general utilities used across the whole project.
- **`<Topic>.wl`** — core functions (created by add-topic skill).
- **`<Topic>Visualization.wl`** — visualization functions (created by add-topic skill).
- **`<Topic>Experiment.wl`** — experiment functions (created by make-experiment skill, on demand).
- **`<Topic>Test.wl`** — tests using `VerificationTest` + `TestReport` (created by make-test skill, on demand).

`Topic` is a CamelCase functional grouping (e.g. `RicciCurvature`,
`HypergraphEmbedding`). The project name is used as the initial topic name.
As the project grows, add new topics via `/computational-research:add-topic`.
Never put visualization code in the core `.wl` file.

### 6. Create the initial topic

Use the **add-topic** skill (`/computational-research:add-topic`) with the project
name as the initial topic. This creates:
- `Code/<ProjectName>.wl` — core functions
- `Code/<ProjectName>Visualization.wl` — visualization functions
- `<ProjectName>1.nb` — topic notebook with sections per function and illustrated calls

The add-topic skill handles code file creation, function population, and notebook
generation via the create-notebook ExportString pipeline.

### 6b. Create the resources notebook

Create `Resources1.nb` in the project root using the same ExportString pipeline.
Build a minimal markdown with just the title:

```
# Resources — <ProjectName>
```

Run the pipeline and write the result to `<ProjectName>/Resources1.nb`.

### 7. Download key reference papers

Every project needs a literature foundation. This step is **not optional** —
do it as part of scaffolding, not as a follow-up suggestion.

1. **Search for papers** using the arXiv MCP (`mcp__arxiv__search_papers`) with
   relevant keywords and categories. Identify 2–5 key papers: the foundational /
   seminal paper, 1–2 recent developments, and anything bridging the topic to
   discrete/graph-theoretic settings or Wolfram models.

2. **Download each paper.** Try `mcp__arxiv__download_paper` first. If the PDF
   can't be saved to the filesystem directly, use `mcp__arxiv__read_paper` or
   `mcp__arxiv-latex-mcp__get_paper_prompt` / `mcp__arxiv-latex-mcp__get_paper_section`
   to read the full content.

3. **Save with the naming convention** `Author_Year_Title.pdf` in `Resources/`:
   first author's last name, publication year, short title (2–4 words, underscores).
   Examples: `Ollivier_2009_RicciCurvatureMarkovChains.pdf`

4. **Add a summary section to Resources1.nb.** To append to an existing notebook,
   use the read → append → rewrite workflow:
   1. Read the existing `.nb` file content as a string
   2. Build the new cells as markdown (Section heading + Text cells for each paper)
   3. Convert the new markdown to notebook cells via the create-notebook pipeline
      (`ImportString` → post-process → get cell list)
   4. Merge the new cells into the existing notebook expression and `ExportString`
      the result, then write it back to disk

   Alternatively, if the notebook is short, rebuild the entire notebook from
   scratch as markdown (title + all existing paper sections + new paper section)
   and run the full pipeline.

   Each paper gets:
   - Section cell: "Author Year — Short Title"
   - Text cell: full title, authors, year, arXiv ID or DOI
   - Text cell: 3–4 sentence abstract summary (in your own words)
   - Text cell: key definitions
   - Text cell: key results (one sentence each)
   - Text cell: **"Relevance to this project"** — map concepts to the discrete /
     graph-theoretic / Wolfram-model setting (most important part)

   **Do NOT create separate .md summary files in Resources/.**

5. **Add BibTeX entries** to `Article/references.bib` for every paper downloaded.

### 7b. Search Wolfram web resources for topic connections

After downloading arXiv papers, search the official Wolfram web resources for community
notebooks and conceptual grounding related to the project topic. This step is **not optional**.

1. **Scan the Technical Introduction** using `WebFetch` on
   `https://wolframphysics.org/technical-introduction/`. Read the table of contents and
   identify any sections that directly relate to the project topic. Summarise the relevant
   connections in a Text cell appended to `<ProjectName>1.nb` (using the read → append →
   rewrite workflow described in step 7).

2. **Search the Wolfram Community Summer School** using `WebFetch` on
   `https://community.wolfram.com/content?curTag=wolfram%20summer%20school`
   to find posts whose titles or descriptions match the project topic. For each relevant
   post found:
   - Fetch the post page with `WebFetch` to check for downloadable `.nb` attachments
   - If a `.nb` file is available, download it and save to `Resources/` using the naming
     convention `Author_Year_Title.nb` (same as PDFs)
   - Append a summary section to `Resources1.nb` (same format as paper summaries in step 7,
     adapted for a notebook: title, author, year, topic, key techniques, relevance)

3. If no directly downloadable notebooks are found, record the relevant post URLs in a
   Text cell in `Resources1.nb` under a "Wolfram Community Resources" section header.
   Use the same read → append → rewrite workflow.

### 8. Paper management convention (ongoing)

Throughout the project's life, whenever new papers are added:
- Use `/computational-research:add-resource <arXivID or search>` for ongoing resource addition
- Always rename to `Author_Year_Title.pdf` format in `Resources/`
- Always append a new section to `Resources1.nb` (or latest ResourcesN.nb) using the
  read → append → rewrite workflow described in step 7
- Always add BibTeX entries to `Article/references.bib`

### 9. Notes management convention (ongoing)

Throughout the project's life:
- **Only write to notes when explicitly asked.** Triggers: "note this", "write this
  down", "record that", "add to notes".
- Append to the current `notesN.tex`. Write in article form with proper citations.
- When notes grow past ~300 lines of content, bump the version (see step 3 above).
- The article file (`article1.tex`) is the user's writing space — don't append
  running notes there.

## After scaffolding

Tell the user:
- The project is set up at `<path>/<ProjectName>/`
- Briefly describe what's in each folder
- **List the papers that were downloaded and summarised**
- **List any Wolfram Community notebooks downloaded and relevant Technical Introduction sections found**
- Mention they can start working in `<ProjectName>1.nb`
- Explain the notes/article relationship: `Article/notes1.tex` is the article-form
  working notes (say "note this" to have Claude write here); `Article/article1.tex`
  is the final article scaffold they write themselves, drawing from notes1.tex
- Mention available skills for ongoing work:
  - `/computational-research:add-resource` — add papers and references
  - `/computational-research:add-topic` — add a new topic scope
  - `/computational-research:make-experiment` — create experiments for a topic
  - `/computational-research:make-test` — create tests for a topic
- Suggest next steps based on the papers and topic
