---
name: wolfram-research-project
description: >
  Scaffold a new Wolfram-model research project with the standard folder structure
  (Code/, Papers/, Notes/, numbered notebooks) and pre-populated templates.
  Use this skill whenever Pavel asks to start a new project, create a new research
  project, set up a project folder, scaffold a project, or begin investigating a
  new topic. Also trigger when he says things like "new project on X", "let's start
  a project about Y", "set up folders for Z", or "init project". Even if he just
  says "I want to explore [topic]" and it sounds like the beginning of a new
  research effort, use this skill.
---

# Wolfram-Model Research Project Scaffolder

You are setting up a new research project for Pavel Hajek at the Wolfram Institute.
Every project follows the same physical layout and intellectual pattern: it connects
some area of mathematics or physics to Wolfram models (hypergraph rewriting, multiway
systems, rulial space, etc.) and develops the connection through Wolfram Language
computation and structured research notes in LaTeX.

## What to ask the user

Before scaffolding, you need two things:

1. **Project name** — a CamelCase name like `SyntheticInfrageometry` or
   `DiscreteRicciFlow`. This becomes the root folder name and the base name for
   notebooks.
2. **Topic description** — a sentence or two about what the project is about.
   For example: "Studying axiomatic geometry on graphs using shortest-path metrics"
   or "Ollivier-Ricci curvature on hypergraph rewriting systems". This goes into
   the CLAUDE.md and the research notes abstract.

If the user already provided these in their message, don't ask again.

## Step 0: Environment check (before anything else)

Run `${CLAUDE_PLUGIN_ROOT}/scripts/check-env.sh` to verify the environment.

- If **wolframscript is missing**: warn the user, then proceed with all non-notebook
  steps. Skip notebook creation (steps 6 and 6b) and note at the end that notebooks
  must be created manually once Wolfram is installed.
- If **Wolfram MCP is unavailable**: notebook creation will use the ExportString
  fallback described in step 6. Proceed normally.
- If **both are missing**: scaffold files only; note both limitations clearly.

## Folder structure to create

```
<ProjectName>/
├── CLAUDE.md
├── <ProjectName>1.nb          ← first Mathematica notebook
├── Code/
│   ├── Tools.wl               ← shared utilities (starter template)
│   └── <ProjectName>.wl       ← main project code (starter template)
├── Papers1.nb                  ← paper summaries notebook (one section per paper)
├── Papers/                     ← reference PDFs only (Author_Year_Title.pdf)
└── Notes/
    ├── article1.tex           ← LaTeX scaffold for user's article (user writes here)
    ├── notes1.tex             ← extended project memory in article form (Claude writes here on request)
    └── references.bib         ← BibTeX file with header comment
```

All created files use number suffixes (`<ProjectName>1.nb`, `Papers1.nb`, etc.).
When the user asks for a new notebook, increment the number (`<ProjectName>2.nb`,
`Papers2.nb`). Edits to an existing file keep the same number unless the user
explicitly asks for a new one.

## Step-by-step

### 1. Scaffold directories and file templates (script)

Run the scaffold script — this replaces the manual mkdir + template steps:

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/scaffold-project.sh" "<ProjectName>" "<topic description>"
```

The script creates:
- `<ProjectName>/Code/Tools.wl` — graph utilities
- `<ProjectName>/Code/<ProjectName>.wl` — empty package stub
- `<ProjectName>/CLAUDE.md` — from claude_template.md with substitutions
- `<ProjectName>/Notes/article1.tex` — LaTeX article scaffold
- `<ProjectName>/Notes/notes1.tex` — project notes file
- `<ProjectName>/Notes/references.bib` — with standard Wolfram references

If the script fails (e.g., permission issue), fall back to creating these files
manually using the templates in `${CLAUDE_PLUGIN_ROOT}/skills/wolfram-research-project/assets/`.

The generated CLAUDE.md uses the template from `assets/claude_template.md`:
replace `{{PROJECT_NAME}}` with the actual project name and `{{TOPIC_DESCRIPTION}}`
with the user's topic description. Fill in 2-3 concrete goals inferred from the
topic. The CLAUDE.md serves as the persistent memory for the project — write it
as if explaining the project to a colleague who will pick it up cold.

### 2. article1.tex purpose

The LaTeX article scaffold (`Notes/article1.tex`) is **Pavel's writing space** — a
skeleton he will write into himself over time to produce a standalone paper. Because
of this:

- Keep the scaffold minimal: section headings, a placeholder abstract, and maybe
  a few seed sentences or TODO comments in each section — but don't fill it with
  extensive content.
- The recurring intellectual theme is: take a concept from mathematics or physics,
  reinterpret it on graphs/hypergraphs/discrete structures in the spirit of the
  Wolfram model, and see what survives, what breaks, and what new phenomena emerge.

Scaffold sections: Introduction / Background / [Topic] on graphs (or hypergraphs) /
Computational results / Discussion and outlook.

### 3. notes1.tex purpose and rules

This is a separate file from the article scaffold. It serves as **extended project
memory** — a readable article-form document where Claude records findings **only
when the user explicitly asks** (e.g. "note this", "write this down", "record that",
"add to notes").

**Usage rules for notes1.tex:**
- **Only write when the user explicitly asks.** Do not auto-append during normal work.
- Write in proper article form — concise, mathematically precise, with citations.
- Organize into sections as notes grow; group related results together.
- Include tentative conjectures, open questions, partial results.

**Step 3 — Versioning rule (important):**
When `notes1.tex` grows past ~300 lines of content (excluding the preamble), or when
the user explicitly asks to start a fresh notes file:
1. Add a pointer at the end of the current file: "Continued in notes2.tex"
2. Create `notes2.tex` with a back-pointer at the top
3. Continue appending to the new file

### 4. Create references.bib

Already created by the scaffold script with standard Wolfram-model references.
Add additional BibTeX entries whenever papers are downloaded (step 7).

### 5. Create starter Code files

Already created by the scaffold script. Both files are ready to use.

### 6. Create the first notebook

Create `<ProjectName>1.nb`. Priority order:

**Primary**: Use `mcp__wolfram__create_notebook` MCP tool:
```
path: "<ProjectName>/<ProjectName>1.nb"
cells: ["Get[\"Code/Tools.wl\"]\nGet[\"Code/<ProjectName>.wl\"]"]
```

**Fallback** (if MCP unavailable or fails): Use the wolfram-notebook skill's
ExportString technique — build a markdown string with a Title cell and a Setup
section containing the package loads, then write the resulting string to
`<ProjectName>/<ProjectName>1.nb` using the Write tool.

### 6b. Create the papers notebook

Create `Papers1.nb` in the project root. Priority order:

**Primary**: Use `mcp__wolfram__create_notebook`:
```
path: "<ProjectName>/Papers1.nb"
cells: []
```
Then add a Title cell via `mcp__wolfram__append_cells_json`:
```
[{"content": "Papers — <ProjectName>", "style": "Title"}]
```

**Fallback**: Use the wolfram-notebook skill's ExportString technique to create
a minimal notebook with just the title.

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

3. **Save with the naming convention** `Author_Year_Title.pdf` in `Papers/`:
   first author's last name, publication year, short title (2–4 words, underscores).
   Examples: `Ollivier_2009_RicciCurvatureMarkovChains.pdf`

4. **Add a summary section to Papers1.nb** via `mcp__wolfram__append_cells_json`.
   Each paper gets:
   - Section cell: "Author Year — Short Title"
   - Text cell: full title, authors, year, arXiv ID or DOI
   - Text cell: 3–4 sentence abstract summary (in your own words)
   - Text cell: key definitions
   - Text cell: key results (one sentence each)
   - Text cell: **"Relevance to this project"** — map concepts to the discrete /
     graph-theoretic / Wolfram-model setting (most important part)

   **Do NOT create separate .md summary files in Papers/.**

5. **Add BibTeX entries** to `Notes/references.bib` for every paper downloaded.

### 8. Paper management convention (ongoing)

Throughout the project's life, whenever new papers are added:
- Use `/computational-research:add-paper <arXivID or search>` for ongoing paper addition
- Always rename to `Author_Year_Title.pdf` format in `Papers/`
- Always append a new section to `Papers1.nb` (or latest PapersN.nb)
- Always add BibTeX entries to `Notes/references.bib`

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
- Mention they can start working in `<ProjectName>1.nb`
- Explain that `Notes/notes1.tex` is the extended project memory — say "note this"
  to record findings in article form with citations
- Explain that `Notes/article1.tex` is the article scaffold to write into themselves
- Mention `/computational-research:add-paper` for adding future papers
- Suggest next steps based on the papers and topic
