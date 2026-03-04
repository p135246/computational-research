# {{PROJECT_NAME}}

## Project goals

{{GOALS}}

## Two approaches

- **Purely metric / structural**: Work with the discrete structure directly — graph distances, combinatorial properties, local neighborhoods. Push this as far as possible before introducing continuous or spectral tools.
- **Spectral / analytic**: Use the graph Laplacian, curvature notions, spectral embeddings, and other analytic tools to capture phenomena that the combinatorial structure alone cannot express.

The interplay between these two approaches is a central question: when does the analytic structure give genuinely new information beyond what the combinatorics provides?

## Code structure

- `Code/Tools.wl` — shared graph utilities (distance, centrality, geodesic extraction)
- `Code/{{PROJECT_NAME}}.wl` — core project functions

## Papers

`Papers/` — reference papers, named as `Author_Year_Title.pdf`
`Papers1.nb` — paper summaries notebook (one section per paper)

## Notes

`Notes/article1.tex` — LaTeX article scaffold (user writes here)
`Notes/notes1.tex` — extended project memory in article form (Claude writes here when asked)
`Notes/references.bib` — BibTeX references

## Loading code

```wolfram
Get["Code/Tools.wl"]
Get["Code/{{PROJECT_NAME}}.wl"]
```
