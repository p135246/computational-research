# computational-research

A Claude plugin for AI-assisted computational research with Wolfram Language.
Scaffolds research projects, creates Mathematica notebooks, manages papers and
community resources, and handles LaTeX notes.

Read the motivation behind this plugin:
[AI-Assisted Computational Research](https://p135246.github.io/wolfram/software/2026/03/04/ai-assisted-computational-research.html)

## Installation

### 1. Add the marketplace

```bash
claude plugin marketplace add WolframInstitute/ClaudePluginMarketplace
```

In Claude Desktop, go to Settings → Plugins → Add Marketplace and enter
`WolframInstitute/ClaudePluginMarketplace`.

### 2. Install the plugin

```bash
claude plugin install computational-research@WolframInstitute
```

In Claude Desktop, find **computational-research** in the marketplace and click
Install.

## Requirements

- [Wolfram Engine](https://www.wolfram.com/engine/) or Mathematica
- [wolframscript](https://www.wolfram.com/wolframscript/) in PATH

## MCP Servers

This plugin relies on four MCP servers. They must be installed and configured
manually.

| Server | Purpose | Source |
|--------|---------|--------|
| **Wolfram** (official) | Wolfram Language evaluation | Paclet `Wolfram/MCPServer` (Mathematica 14.2+) |
| **wolfram** (unofficial) | Notebook creation and editing | [sw1sh/WolframMCP](https://github.com/sw1sh/WolframMCP) |
| **arxiv** | Search and download arXiv papers | [blazickjp/arxiv-mcp-server](https://github.com/blazickjp/arxiv-mcp-server) |
| **arxiv-latex-mcp** | Read LaTeX source of arXiv papers | [takashiishida/arxiv-latex-mcp](https://github.com/takashiishida/arxiv-latex-mcp) |

You need **at least one** Wolfram MCP. The unofficial one is required for notebook
creation/editing; the official one suffices for evaluation only. Both arXiv servers
are needed for the full paper management workflow.

## Skills

| Skill | Description |
|-------|-------------|
| **computational-exploration** | Scaffold a new research project and perform computational exploration, or explore within an existing project |
| **create-notebook** | Create `.nb` files from structured content via the Wolfram MCP |
| **list-topics** | List all topics in a project with descriptions and source references |

## Slash Commands

| Command | Description |
|---------|-------------|
| `/computational-research:check-env` | Check Wolfram kernel and MCP server availability |
| `/computational-research:new-project` | Scaffold a new research project |
| `/computational-research:add-resource` | Add a paper or resource to the current project |
| `/computational-research:load-project` | Summarize project status and suggest next steps |

## Conventions

- **Resource naming**: `Author_Year_Title.pdf` or `.nb` in `Resources/`
- **Resource summaries**: always in `Resources1.nb` (never as separate files)
- **Notes versioning**: `notes1.tex` → `notes2.tex` when it exceeds ~300 lines
- **Article file**: `article1.tex` is your writing space — Claude doesn't touch it
- **Writing to notes**: only when explicitly asked ("note this", "write this down")

## Future Extensions

- **notes-to-article** — seamlessly move note sections into the article at a given place
- **setup-experiment** — scaffold a computational experiment notebook
- Auto-install MCP servers via slash command
- Move toward more standard plugin format with better integration

## License

MIT
