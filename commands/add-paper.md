Add a paper to the current research project.

$ARGUMENTS is one of:
- An arXiv ID (e.g. `2301.12345` or `arxiv:2301.12345`)
- A search query (e.g. `Ricci curvature hypergraphs`)
- A DOI or URL

Steps:
1. **Find the paper**:
   - If arXiv ID: use `mcp__arxiv__download_paper` to download it. Also use
     `mcp__arxiv-latex-mcp__get_paper_abstract` to get metadata.
   - If search query: use `mcp__arxiv__search_papers` with relevant categories
     to find the best match, confirm with the user if ambiguous.

2. **Save the PDF** to `Papers/` as `Author_Year_Title.pdf` (first author's last
   name, year, 2–4 word title, underscores, no special characters).

3. **Add summary section to Papers1.nb** (or latest PapersN.nb) by reading the
   existing notebook, appending new cells, and rewriting via the ExportString
   pipeline (see the create-notebook skill). Include:
   - Section cell: "Author Year — Short Title"
   - Text cell: full title, authors, year, arXiv ID / DOI
   - Text cell: 3–4 sentence abstract summary in your own words
   - Text cell: key definitions
   - Text cell: key results (one sentence each)
   - Text cell: **"Relevance to this project"** — map the paper's concepts to the
     current project's discrete/graph-theoretic/Wolfram-model setting

4. **Add BibTeX entry** to `Notes/references.bib`.

5. Confirm what was done: paper saved as X, section added to PapersN.nb, BibTeX entry added.
